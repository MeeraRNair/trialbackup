/*
* Author  : Krishnakumar M
* Purpose : Buddy Request Functionality
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR14112      05.02      20-Feb-2017     Krishnakumar    Buddy Request - Create Batch Processes to Add/Remove Buddy member to ATM
* 2.0      CR14556      07.02      29-Jun-2017     Krishnakumar    SE148 - Fix for the Defect 3497907 Buddy Access batch process 
* 2.1      D3535012     07.02      30-Jun-2017     Krishnakumar    Defect 3535012:SDET: Buddy is getting removed from ATM even though Buddy was already there in ATM. 
* 3.0      CR16640      08.02      04-Jul-2017     Krishnakumar    SE149 - SE149 - Permanent Fix for the Defect 3497907 Buddy Access batch process
* 3.1      D3634443     08.02      20-Jul-2017     Krishnakumar    Buddy present in ATM gets removed while buddy request access is revoked 
* 4.0      CR14846      10.01      25-Aug-2017     Nagaraju        Sending email when error occured during status update.
*/
public class BuddyUserHelper{
    
    public List<string> listErrorMsg = new List<String>();
    
    public BuddyUserHelper(){
        
    }
    
    public List<AtmGDMRelationClass> createGDMATMRelation(list<GDM_Request__c> listBuddyBackUp, Map<String,List<GDM_Request__c>> mapRepGDM){
        
        Set<ID> setBuddyUser = new Set<ID>();
        Set<ID> setRepId = new Set<ID>();
        Set<ID> setAccountId = new Set<ID>();
        List<AtmGDMRelationClass> listInnercls = null;
        //hold the ROL and a list of GDM Backup that is expired
        Map<String,List<GDM_Request__c>> mapROLReq = new Map<String,List<GDM_Request__c>>(); //3.0
        Set<String> setGDMAtm = new Set<String>();
        
        
        for(GDM_Request__c objBuddyBkp:listBuddyBackUp){
            if(objBuddyBkp.GDM_Request__r.Buddy_Access_End_Date__c <=System.today()){
                setRepId.add(objBuddyBkp.GDM_Request__r.Rep_on_Leave__c);
                setAccountId.add(objBuddyBkp.Account_ID__c);
                setBuddyUser.add(objBuddyBkp.GDM_Request__r.Buddy__c);
                if(mapROLReq.containsKey(objBuddyBkp.GDM_Request__r.Rep_on_Leave__c+''+objBuddyBkp.Account_ID__c)){ //3.1 - Added Account ID as well to get unique record.
                    (mapROLReq.get(objBuddyBkp.GDM_Request__r.Rep_on_Leave__c+''+objBuddyBkp.Account_ID__c)).add(objBuddyBkp);
                }else{
                    mapROLReq.put(objBuddyBkp.GDM_Request__r.Rep_on_Leave__c+''+objBuddyBkp.Account_ID__c, new List<GDM_Request__c>()); 
                    (mapROLReq.get(objBuddyBkp.GDM_Request__r.Rep_on_Leave__c+''+objBuddyBkp.Account_ID__c)).add(objBuddyBkp);    
                }
            }
        }
        if(!setRepId.isEmpty()){
            listInnercls = new List<AtmGDMRelationClass>();
            AtmGDMRelationClass innercls;
            

            
            for(AccountTeamMember objATM:[select id,AccountAccessLevel,AccountId,CaseAccessLevel,ContactAccessLevel,OpportunityAccessLevel,TeamMemberRole,UserId 
                                          FROM AccountTeamMember 
                                          where UserId in : setRepId and AccountId in :setAccountId]){
                                              //construct atmGDMRelationClass for GDM that is expired and the gdm's ROL appear in the ATM. Populate the ROL access with the access currently in the ATM
                                              if(mapROLReq.containsKey(objATM.UserId+''+objATM.AccountID)){
                                                  for(GDM_Request__c objBuddyReq:mapROLReq.get(objATM.UserId+''+objATM.AccountID)){                    
                                                      innercls = new AtmGDMRelationClass();
                                                      innercls.idBuddyUser = objBuddyReq.GDM_Request__r.Buddy__c;
                                                      innercls.idRolUser = objBuddyReq.GDM_Request__r.Rep_on_Leave__c;
                                                      innercls.idGdmReq = objBuddyReq.GDM_Request__c;
                                                      innercls.idAccount = objATM.AccountId;
                                                      innercls.idRepATM = objATM.id;
                                                      innercls.strRepAccountAccess = objATM.AccountAccessLevel;
                                                      innercls.strRepCaseAccess = objATM.CaseAccessLevel;
                                                      innercls.strRepOpportunityAccess = objATM.OpportunityAccessLevel;
                                                      innercls.strRepTeamMemberRole = objATM.TeamMemberRole;
                                                      innercls.dtStartDate = objBuddyReq.GDM_Request__r.Buddy_Access_Start_Date__c;
                                                      innercls.dtEndDate = objBuddyReq.GDM_Request__r.Buddy_Access_End_Date__c;
                                                      listInnercls.add(innercls);
                                                      setGDMAtm.add(objATM.UserId+''+objATM.AccountId);     //2.1            
                                                  }
                                              }
                                          }
            
            //construct atmGDMRelationClass for GDM that is expired and the gdm's ROL NOT appear in the ATM. Populate the ROL access with the access in the backup object
            if(mapRepGDM != null && !mapRepGDM.isEmpty()){
                for(String strRepGDM:mapRepGDM.keySet()){
                    List<GDM_Request__c> listGDMReq = mapRepGDM.get(strRepGDM);
                    for(GDM_Request__c objGDMBkUp:listGDMReq){
                        if(!setGDMAtm.contains(objGDMBkUp.GDM_Request__r.Rep_on_Leave__c+''+objGDMBkUp.Account_ID__c) || setGDMAtm.isEmpty()){ //2.1
                           
                            
                            innercls = new AtmGDMRelationClass();
                            innercls.idBuddyUser = objGDMBkUp.GDM_Request__r.Buddy__c;
                            innercls.idRolUser = objGDMBkUp.GDM_Request__r.Rep_on_Leave__c;
                            innercls.idGdmReq = objGDMBkUp.GDM_Request__c;
                            innercls.idAccount = objGDMBkUp.Account_ID__c;
                            innercls.idRepATM = null;
                            innercls.strRepAccountAccess = objGDMBkUp.Rep_Account_Access_Level__c;
                            innercls.strRepCaseAccess = objGDMBkUp.Rep_Case_Access_Level__c;
                            innercls.strRepOpportunityAccess = objGDMBkUp.Rep_Opportunity_Access_Level__c;
                            innercls.strRepTeamMemberRole = objGDMBkUp.TeamMemberRole__c;
                            innercls.dtStartDate = objGDMBkUp.GDM_Request__r.Buddy_Access_Start_Date__c;
                            innercls.dtEndDate = objGDMBkUp.GDM_Request__r.Buddy_Access_End_Date__c;
                            listInnercls.add(innercls);
                        }
                    }
                }
                
            }
            
            //Populate Buddy Access in the innerclass with current access in the ATM
            List<AccountTeamMember> listBuddyAtm = [select id,AccountAccessLevel,AccountId,CaseAccessLevel,ContactAccessLevel,OpportunityAccessLevel,TeamMemberRole,UserId,LastModifiedById 
                                                    FROM AccountTeamMember 
                                                    where UserId in : setBuddyUser and AccountId in :setAccountId];
            
            for(AccountTeamMember objATM:listBuddyAtm){
                for(AtmGDMRelationClass innerclass:listInnercls){
                    if(innerclass.idBuddyUser == objATM.UserId && innerclass.idAccount == objATM.AccountId){
                        innerclass.idBuddyATM = objATM.id;
                        innerclass.idLastModifiedBy = objATM.LastModifiedById;
                        innerclass.strBuddyAccountAccess = objATM.AccountAccessLevel;
                        innerclass.strBuddyCaseAccess = objATM.CaseAccessLevel;
                        innerclass.strBuddyOpportunityAccess = objATM.OpportunityAccessLevel;
                        innerclass.strBuddyTeamMemberRole = objATM.TeamMemberRole;
                    }                    
                }
            }
        }
        return listInnercls;
    }
    
    // Called from Addition ATM Batch (Batch_BuddyAddition.cls)
    public Map<String,AccountTeamMember> calculateAccessLevels(List<AtmGDMRelationClass> listAtmGDM){
        Map<String,AccountTeamMember> mapBuddyAccess =new Map<String,AccountTeamMember>();
        AccountTeamMember buddyATMAccess;
        for(AtmGDMRelationClass innerCls:listAtmGDM){
            if(!mapBuddyAccess.containsKey(innerCls.idBuddyUser+''+innerCls.idAccount)){
                buddyATMAccess = new AccountTeamMember();
                buddyATMAccess.AccountAccessLevel = innerCls.strBuddyAccountAccess;
                buddyATMAccess.CaseAccessLevel = innerCls.strBuddyCaseAccess;
                buddyATMAccess.OpportunityAccessLevel = innerCls.strBuddyOpportunityAccess;
                buddyATMAccess.AccountID = innerCls.idAccount;
                buddyATMAccess.UserId = innerCls.idBuddyUser;
                buddyATMAccess.TeamMemberRole = (innerCls.strBuddyTeamMemberRole != null)?innerCls.strBuddyTeamMemberRole:innerCls.strRepTeamMemberRole;
                mapBuddyAccess.put(innerCls.idBuddyUser+''+innerCls.idAccount, buddyATMAccess);
            }else{
                buddyATMAccess = mapBuddyAccess.get(innerCls.idBuddyUser+''+innerCls.idAccount); 
            }
            buddyATMAccess.AccountAccessLevel = compareLevels(buddyATMAccess.AccountAccessLevel,innerCls.strRepAccountAccess);
            buddyATMAccess.CaseAccessLevel = compareLevels(buddyATMAccess.CaseAccessLevel,innerCls.strRepCaseAccess);
            buddyATMAccess.OpportunityAccessLevel = compareLevels(buddyATMAccess.OpportunityAccessLevel,innerCls.strRepOpportunityAccess);              
            mapBuddyAccess.put(innerCls.idBuddyUser+''+innerCls.idAccount, buddyATMAccess); 
        }
        return mapBuddyAccess;
    }
    
    
    // Called from Revoke ATM Batch (Batch_BuddyRevoke.cls)
    // should return buddy ATM access where it holds the access we want to insert into ATM after recalc. For Buddy that has Is_New_Buddy__c in the backup, it shold have no record in this map return
    public Map<String,AccountTeamMember> calculateAccesslevels(List<AtmGDMRelationClass> listInnercls,Map<String,List<GDM_Request__c>> mapBackupBuddy){
        Map<String,AccountTeamMember> mapBuddyAccess =new Map<String,AccountTeamMember>();
        AccountTeamMember buddyATMAccess;
        for(AtmGDMRelationClass innerCls:listInnercls){
            if(mapBackupBuddy.containsKey(innerCls.idAccount)){
                buddyATMAccess = null;
                for(GDM_Request__c objGDMBkUp:mapBackupBuddy.get(innerCls.idAccount)){
                    //for gdm that still has non expired request, we need to calc the buddy access by lookig at the future request ROL access
                    if(objGDMBkUp.GDM_Request__r.Buddy_Access_End_Date__c > system.today()){
                        if(!mapBuddyAccess.containsKey(objGDMBkUp.GDM_Request__r.Buddy__c+''+objGDMBkUp.Account_ID__c)){          
                            //prepopulate the buddy access from backup GDM buddy access
                            buddyATMAccess = new AccountTeamMember();              
                            buddyATMAccess.AccountAccessLevel = objGDMBkUp.AccountAccessLevel__c;
                            buddyATMAccess.CaseAccessLevel = objGDMBkUp.CaseAccessLevel__c;
                            buddyATMAccess.OpportunityAccessLevel = objGDMBkUp.OpportunityAccessLevel__c;
                            buddyATMAccess.AccountID = innerCls.idAccount;
                            buddyATMAccess.UserId = objGDMBkUp.GDM_Request__r.Buddy__c;
                            buddyATMAccess.TeamMemberRole = objGDMBkUp.TeamMemberRole__c;
                            mapBuddyAccess.put(objGDMBkUp.GDM_Request__r.Buddy__c+''+objGDMBkUp.Account_ID__c, buddyATMAccess);                        
                        }else{
                            buddyATMAccess = mapBuddyAccess.get(objGDMBkUp.GDM_Request__r.Buddy__c+''+objGDMBkUp.Account_ID__c);
                        }
                        //compare and add the ATM by recalc with the gdm backup ROL access                          
                        buddyATMAccess.AccountAccessLevel = compareLevels(buddyATMAccess.AccountAccessLevel,objGDMBkUp.Rep_Account_Access_Level__c);
                        buddyATMAccess.CaseAccessLevel = compareLevels(buddyATMAccess.CaseAccessLevel,objGDMBkUp.Rep_Case_Access_Level__c);
                        buddyATMAccess.OpportunityAccessLevel = compareLevels(buddyATMAccess.OpportunityAccessLevel,objGDMBkUp.Rep_Opportunity_Access_Level__c);
                        mapBuddyAccess.put(objGDMBkUp.GDM_Request__r.Buddy__c+''+objGDMBkUp.Account_ID__c, buddyATMAccess); 
                        
                    }else if(!objGDMBkUp.Is_New_Buddy__c && !mapBuddyAccess.containsKey(objGDMBkUp.GDM_Request__r.Buddy__c+''+objGDMBkUp.Account_ID__c)){
                        buddyATMAccess = new AccountTeamMember();              
                        buddyATMAccess.AccountAccessLevel = objGDMBkUp.AccountAccessLevel__c;
                        buddyATMAccess.CaseAccessLevel = objGDMBkUp.CaseAccessLevel__c;
                        buddyATMAccess.OpportunityAccessLevel = objGDMBkUp.OpportunityAccessLevel__c;
                        buddyATMAccess.AccountID = innerCls.idAccount;
                        buddyATMAccess.UserId = objGDMBkUp.GDM_Request__r.Buddy__c;
                        buddyATMAccess.TeamMemberRole = objGDMBkUp.TeamMemberRole__c;
                        mapBuddyAccess.put(objGDMBkUp.GDM_Request__r.Buddy__c+''+objGDMBkUp.Account_ID__c, buddyATMAccess); 
                    }
                }
            }
        }
        
        return mapBuddyAccess;
    }
    
    private String compareLevels(String strBuddyAccess, String strRolAccess){
        if('Edit'.equalsIgnorecase(strBuddyAccess)){
            return 'Edit';
        }else if('Edit'.equalsIgnorecase(strRolAccess)){
            return 'Edit';
        }else if(strBuddyAccess == strRolAccess){
            return strBuddyAccess;
        }else if(strBuddyAccess == null || 'None'.equalsIgnorecase(strBuddyAccess)){
            return strRolAccess;
        }else{
            return strBuddyAccess;
        }
    }
    
    
    //3.0
    public void processError(List<AtmGDMRelationClass> listInnercls,List<AccountTeamMember> listATM,Exception ex){
        
        listErrorMsg.add('Insert - Error Message - '+ex.getMessage()+'\n');
        for(AccountTeamMember objATM : listATM){
            for(AtmGDMRelationClass atmGDM:listInnercls){                
                if(objATM.userid == atmGDM.idBuddyUser && objATM.accountId == atmGDM.idAccount){
                    listErrorMsg.add('Acc ID - '+  atmGDM.idAccount + ' GDM ID - '+ atmGDM.idGdmReq +'\n'); 
                }
            }
        }    
           
    }
    
    public void processError(Map<ID,List<AtmGDMRelationClass>> mapATMGDM ,List<ID> listATMID,Exception ex){       
        listErrorMsg.add('Remove - Error Message - '+ex.getMessage()+'\n');
        for(ID idATM : listATMID){         
            for(AtmGDMRelationClass atmGDM:mapATMGDM.get(idATM)){                
                listErrorMsg.add('Acc ID - '+  atmGDM.idAccount + ' GDM ID - '+ atmGDM.idGdmReq +'\n');                                                                      
            }
        }
    }
       
    
    //4.0 Start
    public void processError(List<GDM_Request__c> listGDMStatus,Database.Saveresult[] objSR,String strSubject,String strMsg){
        List<Exception__c> listException = new List<Exception__c>();
        for(integer i = 0; i< objSR.size();i++){
            if(!objSR[i].isSuccess()){
                Database.Error objError = objSR[i].getErrors().get(0);
                listException.add(new Exception__c(Error_Messages__c = '-GDM Insert failed-'+objError.getMessage(),Object_type__c='GDM_Request__c',Object_ID__c=listGDMStatus.get(i).id, Operation__c='Update',Process_Name__c='Buddy Request - GDM Status Update',Notes__c='Batch_BuddyAddition class - GDM Request Status Update -  finish Method'));
                strMsg+= 'GDM Request ID - '+ listGDMStatus.get(i).id+'\n';
                strMsg+='Error Message - '+ objError.getMessage()+'\n';
            }
        }
        if(!listException.isEmpty()){
            strMsg+='\nRegards,\nRubicon SFDC Team.';
            sendEmail(strSubject,strMsg);
            insert listException;
        }
    }
    
    public void notifyError(ID idBatchJob){
        AsyncApexJob a = [  Select ApexClass.Name, Id, Status, NumberOfErrors, JobItemsProcessed, 
                          TotalJobItems, CreatedBy.Email 
                          From AsyncApexJob where Id =:idBatchJob 
                         ];
        if (a.NumberOfErrors>0 || listErrorMsg.size()>0) {           
            String strSub = a.ApexClass.Name+': ' + a.Status +'- ATM Operation Failed.';
            String strMessage = 'The batch Apex job processed '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures.\n\n';
            for(String strErr:listErrorMsg){
                strMessage+=strErr+'\n';
            }        
            sendEmail(strSub,strMessage);
        }
    }
    
    public void sendEmail(String strSubject,String strMsg){
        List<Messaging.SingleEmailMessage> listMails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage objSingleMail;
        
        String strQuery = 'select id,email from user where Email in '+Label.GDM_Request_Error_Email;
        List<User> listUserEmail = Database.query(strQuery);
        for(User objUser:listUserEmail){
            objSingleMail = new Messaging.SingleEmailMessage(); 
            objSingleMail.setSubject(strSubject);
            objSingleMail.setTargetObjectId(objUser.id);
            objSingleMail.setPlainTextBody(strMsg); 
            objSingleMail.setSaveAsActivity(false);
            listMails.add(objSingleMail);
        }
        
        If( !listMails.isEmpty() ){
            Messaging.sendEmail(listMails);
        }
    }
    //4.0 End
}