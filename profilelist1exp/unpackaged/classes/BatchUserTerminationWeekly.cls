/*
 * Author  : Gan
 * Purpose : BatchUserTerminationWeekly to terminate non chatter user on a weekly basic 
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      15073       FY18-DCS-0102   22-Dec-2017     Gan 
 * 1.1		TFS4530549	FY18-DCS-0102   17-Jan-2018		Gan
 * 2.0		15610		FY19-DCS-0502	10-Apr-2018		Gan				remove the hardcoded date			                                                                    
 * 3.0      15736       FY19-DCE-0602   04-May-2018     Gan			    Fix the error where integration user being terminated due to data error
 
 */
global class BatchUserTerminationWeekly implements Database.Batchable<sObject>, Database.Stateful{
    public String strQuery;
    Public List<Exception__c> listOfException = new List<Exception__c>();
    //1.1
    Public Integer intTerminationThreshold;
    Public List<string> listRowCause;
    
	global database.querylocator start(Database.BatchableContext BC){
        system.debug('---11111----' + strQuery);
        //1.1
        intTerminationThreshold = integer.ValueOf(System.Label.UserTerminationWeeklyThreshold);
        string strRowCause = System.Label.UserTerminationAccShareRowCause;
        listRowCause = strRowCause.split('[,]{1}[\\s]?');
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Id roleId;
        set<string> setRelatedBadge = new set<string>();
        set<string> setEmail = new set<string>();
        set<string> setTerminatedUsername = new set<string>();
        set<string> setPreExistTerminatedUN = new set<string>();
        //1.1
        set<Id> setUserId = new set<Id>();
        set<string> setRowCause = new set<string>();
        user objUser;

        set<string> setIntegratedUserEmail = new set<string>();
        Map<string, string> mapBadgewEmail = new map<string, string>();
        
        List<User> listUserToUpdate = new List<User>();

        try{
            for(UserRole userRoleList :[select Id 
                                        From UserRole
                                        where Name Like '%INTEGRATION TEMP%']){
                roleId = userRoleList.Id; 
            }
            
            for(sObject obj :scope){
                objUser = (user)obj;
                setEmail.add(objUser.email);
                setUserId.add(objUser.id);
                String strTerminatedUN = objUser.username+'.terminated';
                setTerminatedUsername.add(strTerminatedUN);
                listUserToUpdate.add(objUser);
            }
	
            //1.1 
            integer intCountRecord = 0;
            Map<Id,integer> mapUserAccountShare = new Map<id, integer>();
            for (AggregateResult result : [
    			SELECT count(Id) countAccountShare, UserOrGroupId 
     			FROM AccountShare                
     			WHERE RowCause IN :listRowCause                     
     			AND UserOrGroupId IN :setUserId 
                group by UserOrGroupId
            ]) { 
                if(!mapUserAccountShare.containsKey((Id)result.get('UserOrGroupId'))) {
                	mapUserAccountShare.put((Id)result.get('UserOrGroupId'), (Integer)result.get('countAccountShare'));
                }
                else {
                	intCountRecord =  mapUserAccountShare.get((Id)result.get('UserOrGroupId'));
                    intCountRecord += (Integer)result.get('countAccountShare');
                    mapUserAccountShare.put((Id)result.get('UserOrGroupId'), intCountRecord);
                }
                
            }
            system.debug('mapUserAccountShare: ' + mapUserAccountShare);
            
            if(setTerminatedUsername.size() > 0){
                for(User u :[select username, email, badge_number__c 
                   	from user 
                    where (username in :setTerminatedUsername) or email in :setEmail]){
                        if(u.username.toLowerCase().contains('.terminated')) {
                            setPreExistTerminatedUN.add(u.username);    
                        }
                        if(setEmail.contains(u.email)) {
							mapBadgewEmail.put(u.badge_number__c, u.email);
                            setRelatedBadge.add(u.badge_number__c); 
                        }
                    
                 }
            }
            
            for(peoplesoft_user_view__c objPPS :[select id, Badge_Number__c, Integrated_User__c
                             from peoplesoft_user_view__c 
                             where badge_number__c in :setRelatedBadge and Integrated_User__c = 'Yes']){
                
                if(mapBadgewEmail.containsKey(objPPS.Badge_Number__c)){                 
            		setIntegratedUserEmail.add(mapBadgewEmail.get(objPPS.Badge_Number__c));
                }    
            }
            
            for(User u: listUserToUpdate) {
                //1.1
                boolean bIsManual = false;
                if(mapUserAccountShare.containsKey(u.id)) {
                    System.debug('ZY---------count :' + mapUserAccountShare.get(u.id));
                    if( mapUserAccountShare.get(u.id) >= intTerminationThreshold)
                    {
                        System.debug('ZY---------Is Manual');
                        bIsManual = true;
                    }
                }
                
                //1.1 set the date to 2018-01-01 for user that needs manual removal
                if(bIsManual)
                {
                    //2.0
                    u.Due_to_Deactivate__c = system.today() - 180;
                }
                else {
                    //3.0
                    if(setIntegratedUserEmail.contains(u.email)){
                        u.userRoleId = roleId;
                    }
                    
                    String s1 = u.email;
                    String s2 = s1.SubstringafterLast('@');
                    Integer dotCount = s2.countMatches('.');
                    if(Environment.isSandbox() && dotCount >= 2){
                        String s3 = s1.Substringbeforelast('.');
                        u.email = s3 + '.terminated';   
                    }
                    else{
                        //Ver2
                        String s4 = s1.Substringafterlast('.');
                        if(!s4.toLowerCase().contains('terminated')){
                            u.email = u.email + '.terminated';
                        }
                        //Ver2
                    }
                    
                    //Ver3
                    string uName = u.username+'.terminated';
                    if(setPreExistTerminatedUN.size() > 0 && 
                       setPreExistTerminatedUN.contains(uName)){
                           u.username = u.username +'.'+u.Badge_Number__c+'.terminated';
                       }
                    else{
                        u.username = u.username + '.terminated';
                    }
                    
                    //Ver3
                    u.isactive = false;
                    u.title = 'Terminated';
                    u.Due_to_Deactivate__c = null;
                }
            }
            
         
            System.Debug('---UserToUpdateList---'+listUserToUpdate); 
               
            if(listUserToUpdate.Size() > 0){
                
                database.SaveResult[] updateResults;
                GlobalVariables.BYPASS_FUTURE_CALLS = true;
                    
                //ver4
                try{
                	system.debug('----START updating user----');
                    updateResults = database.update(listUserToUpdate, false);
                    system.debug('----END updating user----');      
                }
                catch (Exception ex){
                    system.debug('----Exception Occured--'+ex);
                }
                finally{
                    GlobalVariables.BYPASS_FUTURE_CALLS = false;
                    
                    List<String> listErrorCodeDel = new List<String>();
                    List<String> listErrorMessageDel = new List<String>();
                    
                    for(integer i = 0; i< updateResults.size();i++){       
                        if(updateResults[i].isSuccess()!=true){
                            Exception__c exceptionVar = new Exception__c();        
                            exceptionVar.Object_type__c = 'User';
                            exceptionVar.Object_ID__c = listUserToUpdate[i].Id;
                            exceptionVar.Operation__c = 'Update';
                            exceptionVar.Notes__c = 'Badge Number : '+listUserToUpdate[i].Badge_number__c;
                            exceptionVar.Process_Name__c = 'User Termination Weekly';
                            exceptionVar.Email__c = listUserToUpdate[i].Email;
                            
                            Database.Error [] errors = updateResults[i].getErrors();
                            listErrorCodeDel.clear();
                            listErrorMessageDel.clear();
                            // Cycle through the errors
                            for (Database.Error error :errors){
                                listErrorCodeDel.add(''+error.getStatusCode());
                                listErrorMessageDel.add(''+error.getMessage());
                            }            
                            exceptionVar.Error_Codes__c = StringUtils.joinStrings (listErrorCodeDel, ',');
                            string errMsg = StringUtils.joinStrings (listErrorMessageDel, ',');
                            if(errMsg.length() > 255) {                       
                                exceptionVar.Error_Messages__c =  errMsg.SubString(0,254);
                            }
                            else{
                                exceptionVar.Error_Messages__c =  errMsg;
                            }listOfException.add(exceptionVar);  
                            system.debug('-----listOfException----'+listOfException);
                        } 
                    }   
                }    
            }
       }
       catch (System.DmlException e){
           system.debug('----Exception Occured--'+e);
          
       }         
    }
    
    global void finish(Database.BatchableContext info){
        if(listOfException.size() > 0 ){
                  insert listOfException;
        }
    }
}