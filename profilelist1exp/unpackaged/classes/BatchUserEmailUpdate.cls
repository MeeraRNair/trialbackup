/* 
History:
Version     Date            Modified By                         CR          Description     
--------------------------------------------------------------------------------------
1.0         16-May-2016     Noorul Syuhada/Shahiruni Wahida      13094       Story 1120079:Update HR email changes automatically in SFDC
2.0         28-April-2016   Jessie                               14186       Identify the users from Peoplesoft who requires changes in is_SSO_user__c field so that email will be sent to them.
*/

global class BatchUserEmailUpdate implements Database.Batchable<sObject>, Database.Stateful {
    
    public Boolean isTest = False;
    Public List<Exception__c> listOfException = new List<Exception__c>();

    DateTime theDate = DateTime.now().addDays(-365);
    
    //1---Query for peoplesoft_user_view__c from 365days
    global database.querylocator start(Database.BatchableContext BC){
    
        System.debug('### BatchUserEmailUpdate STARTS ###');
        
        //2.0 start 
        
        //put the query into custom label so that it can be configured in Testing for any smaller group of users for any testing purpose
                        
        String query = Label.BatchUserEmailUpdateSOQL;
                        
        if(Test.IsRunningTest()){
        
            query = 'Select Integrated_User__c, CreatedDate, badge_number__c, employee_status__c,terminated_in_sfdc__c, email_address__c,Email_New__c from peoplesoft_user_view__c '+
                        'WHERE ((PeopleSoft_Email_Changed__c = true OR CreatedDate >= :theDate) AND Badge_Number__c != null AND email_address__c != null)';
            
                        
        }
        
        System.debug('%%%%%%%%%%%%%%%%%%% query to query all data involved : '+ query);
        
        //2.0 end
        
        return Database.getQueryLocator(query); //query from peoplesoft
    }

    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<string> allBadgeidSet = new Set<string>(); //set all badge_no into allbadgeidset
        
        Map<String, PeopleSoft_User_View__c> peopleSoftMap = new Map<string, peoplesoft_user_view__c>(); //map peoplesoft
        Map<String, String> allIntegratedUserMap = new Map<String, String>();
        Map<String, String> allNonIntegratedUserMap = new Map<String, String>();
        
        PeopleSoft_User_View__c peopleSoftRec; //peoplesoft record

        if(scope.size() > 0){
            try{
                for(sObject obj :scope){
                    peopleSoftRec = (PeopleSoft_User_View__c)obj;
                    if(peopleSoftRec.Integrated_User__c == 'yes'){
                        allIntegratedUserMap.put(peopleSoftRec.Badge_Number__c, peopleSoftRec.Email_New__c);
                    } else{
                        allNonIntegratedUserMap.put(peopleSoftRec.Badge_Number__c, peopleSoftRec.Email_New__c);
                    }
                    //allBadgeIdSet.add(peopleSoftRec.badge_number__c);
                    //peopleSoftMap.put(peopleSoftRec.Badge_Number__c, peopleSoftRec);
                }
                
                if(!allIntegratedUserMap.isEmpty()){
                    processUser(allIntegratedUserMap, true);    
                }
                
                if(!allNonIntegratedUserMap.isEmpty()){
                    processUser(allNonIntegratedUserMap, false);    
                }

            }catch (System.DmlException e){
                system.debug('BatchUserEmailUpdate exception in Execute ---- '+e);
            }    
        }
          
    }
    
    global void finish(Database.BatchableContext info){  
    
        System.debug('### BatchUserEmailUpdate END ###');
        if(listOfException.size() > 0 ){
            //database.SaveResult[] updateExcResults;
            //updateExcResults = database.insert(listOfException, false);
            insert listOfException;
            //System.debug('---exceptions---'+updateExcResults);
        } 
    } 
    
    
    public void processUser(Map<String, String> PSInfo, Boolean integratedUser){
        
        Set<String> PSBadgeIdSet = new Set<String>();
        Set<String> masterEmailSet = new Set<String>();
        
        //2.0 - start
        Set<Id> UserIds = new Set<Id>();
        //2.0 - end 
        
        List<User> userListToUpdate  = new List<User>(); //List of User with all info to update
        Map<String, String> userPSEmailMap = new Map<String, String>();
        
        if(PSInfo.size() > 0){
            for(String badgeId: PSInfo.keySet()){
                PSBadgeIdSet.add(badgeId);
            }
        }

        if(PSBadgeIdSet.size() > 0){
            For(User userList :[select Id, email,Badge_Number__c from user where badge_number__c IN :PSBadgeIdSet AND isActive=true]){
                if(userList.email != PSInfo.get(userList.Badge_Number__c)){ //only include user that has email changed
                    masterEmailSet.add(userList.email);
                    userPSEmailMap.put(userList.email,PSInfo.get(userList.Badge_Number__c)); 
                    //2.0 - start
                    userIds.add(userList.Id);
                    //2.0 - end
                }
            }
        }
        
        if(masterEmailSet.size() > 0){ //Ex : if ada 3 email User 
            
            List<User> userEmailList = [select Id, username, License_Used__c, profileId, email,Old_Email__c From User Where Email IN :masterEmailSet AND isActive=true];
            
            //2.0 Start 
            //To find userId that is assignee of SSO Permission Set
            Set<String> setPermissionSetAssignee = new Set<String>();
            
            for(PermissionSetAssignment psa : [SELECT Id, Assignee.email FROM PermissionSetAssignment  WHERE AssigneeId IN :userIds AND PermissionSet.Name =: Label.SSOPermissionSet]){
                setPermissionSetAssignee.add(psa.assignee.email);
            }        
                        
            for(User emailList : userEmailList){ //checking 2 : in user,search all email : ex: email : syuhada@dell.com, user that also used same email? 
                
                emailList.Old_Email__c = emailList.email;   //to store old email
                emailList.email = userPSEmailMap.get(emailList.email);
                emailList.Is_Integrated_User__c = integratedUser;
                  
                System.debug('@@@@@@@@@ current email: ' + emailList.Old_Email__c);
                System.debug('@@@@@@@@@ new email: ' + emailList.email);
                System.debug('@@@@@@@@@ license used : ' + emailList.License_Used__c);
                System.debug('@@@@@@@@@ assigned permission? : ' + setPermissionSetAssignee.contains(emailList.Old_Email__c));
                System.debug('@@@@@@@@@ contains SSO profile? : ' + Label.SSOProfiles.contains(emailList.ProfileId));
                        
                if(
                    (emailList.License_Used__c == 'Salesforce' || emailList.License_Used__c == 'Chatter Only')
                         &&
                    (setPermissionSetAssignee.contains(emailList.Old_Email__c) || Label.SSOProfiles.contains(emailList.ProfileId))                                         
                                                 
                ){
                                                 
                     emailList.username = emailList.email;
                     emailList.Is_SSO_User__c = true;
                     
                }else{
                 
                     emailList.Is_SSO_User__c = false;
                 
                }               
                    
                userListToUpdate.add(emailList);
                
            }

            TriggerExecutionController.setSkipUserTriggers(true);
            Database.SaveResult[] lstSaveResults = Database.update(userListToUpdate, false);
            
            For(Database.SaveResult result:lstSaveResults ){
                if(!result.isSuccess()){
                    for(Database.Error err : result.getErrors()) {
                        System.debug('@@@@@@@@@Error : ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                
                }
            
            }
            
            TriggerExecutionController.setSkipUserTriggers(false);
            
            //2.0 - end 
            
        }
    }
    
    // Handle all exceptions
    @TestVisible private void handleError(Exception e) {
        System.debug('### Error Stack Trace : ' + e.getStackTraceString());
        System.debug('### Message : ' + e.getMessage());
    }
}