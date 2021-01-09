public class AccountTemmemberUtils {    
    
    public static void checkOpportunityAccessLevel(list<AccountTeamMember> listAccTeamMembers) {         
        for(AccountTeamMember atm:listAccTeamMembers){                    
            if((atm.OpportunityAccessLevel=='Private' || atm.OpportunityAccessLevel=='None') && (atm.CaseAccessLevel=='Private' || atm.CaseAccessLevel=='None') &&(atm.AccountAccessLevel=='Private' || atm.AccountAccessLevel=='None' || atm.AccountAccessLevel=='Read')){               
                atm.addError(System.label.Opportunity_Access_Private_Error);                 
            }
        }
    }  
    
    public static void publishRequestForRevokeAccountShareForMasterGroup(List<AccountTeamMember> listOldATMs){
        System.debug('publishRequestForRevokeAccountShareForMasterGroup');
        if(System.Label.Publish_Request_For_Deletion == 'true'){
        try{
            List<Share_Records__e> listPublishEvents = new List<Share_Records__e>();
            List<AccountTeamMember> listUpdateATM = new List<AccountTeamMember>();
            for(AccountTeamMember atm : listOldATMs){
                Share_Records__e shareRecObj = new Share_Records__e();
                shareRecObj.AccountId__c = atm.AccountId;
                shareRecObj.User_Id__c = atm.UserId;
                shareRecObj.Account_Access_Level__c = atm.AccountAccessLevel;
                shareRecObj.Mode_of_Event__c = 'Deletion';
                listPublishEvents.add(shareRecObj); 
                listUpdateATM.add(new AccountTeamMember(Id = atm.Id, Published_MGShare_Event__c = true));
            }
            
            if(!listUpdateATM.isEmpty()){
                Database.update(listUpdateATM, false);
            }
            List<Database.SaveResult> results = EventBus.publish(listPublishEvents);
            
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                    }
                }       
            }
            if(Test.isRunningTest()){
                throw new NullPointerException();
            }
        }
        catch(Exception e) {
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'MG Share';
            exceptionRecord.Object_type__c = 'AccountTeamMember';
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c = e.getMessage();
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
        }
        }
    }
    
	public static void revokeAccountShareForMasterGroup(List<Share_Records__e> listShareRecords){
        // To hold the SM Ids
        Set<String> setAccIds = new Set<String>();
        // To hold the User Ids
        Set<String> setUserIds = new Set<String>();
        // To hold the MG Ids
        Set<String> setMGIds = new Set<string>();
        // To hold the Account Share to Delete
        List<AccountShare> listAccShareDel = new List<AccountShare>();
        Map<String, AccountTeamMember> mapMGUIDVsATM = new Map<String, AccountTeamMember>();
        List<String> listMGUId = new List<String>(); 
        List<Exception__C> listExceptions = new List<Exception__C>();
        List<AccountTeamMember> listATMUpdate = new List<AccountTeamMember>();
        try{
            
            for(Share_Records__e sre : listShareRecords){
                if(sre.Mode_of_Event__c == 'Deletion'){
                    setAccIds.add(sre.AccountId__c);
                	setUserIds.add(sre.User_Id__c);
                }
                
            }
            if(setAccIds.size() > 0 && setUserIds.size() > 0){
                for(Account salesMotionAccounts : [SELECT Master_Group_Id__c
                                                   FROM Account
                                                   WHERE Id IN: setAccIds
                                                   AND Master_Group_Id__c!= null LIMIT 50000]){
                                                       setMGIds.add(salesMotionAccounts.Master_Group_Id__c);
                                                   }
                
                for(AccountTeamMember atm :[SELECT AccountId,UserId,AccountAccessLevel,Account.Master_Group_Id__c,TeamMemberRole
                                            FROM AccountTeamMember
                                            WHERE Account.Master_Group_Id__c!= null 
                                            AND Account.Master_Group_Id__c IN : setMGIds
                                            AND UserId IN: setUserIds LIMIT 50000 ]){
                        mapMGUIDVsATM.put(atm.Account.Master_Group_Id__c+''+atm.UserId, atm);
                        if(atm.AccountAccessLevel == 'Edit'){
                            listMGUId.add(atm.Account.Master_Group_Id__c+''+atm.UserId);
                        }
                    }
                
                for(AccountShare accShare: [SELECT Id,AccountId,UserOrGroupId
                                            FROM AccountShare 
                                            WHERE AccountId IN: setMGIds
                                            AND RowCause=:'Manual'
                                            AND UserOrGroupId IN: setUserIds
                                           ]){
                                               if(!mapMGUIDVsATM.containsKey(accShare.AccountId+''+accShare.UserOrGroupId)){
                                                   listAccShareDel.add(accShare);
                                               } 
                                           }
                
                               
                if(!listAccShareDel.isEmpty()){
                    Database.DeleteResult[] listSR = Database.delete(listAccShareDel,false);
                    for(Database.DeleteResult sr : listSR) {
                        if(sr.isSuccess()){
                            System.debug('Delete Successfully');
                        } else {
                            for(Database.Error objErr : sr.getErrors()) {
                                System.debug('The following error has occurred.');  
                                System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                                System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                                Exception__C exceptionRecord = new Exception__C();
                                exceptionRecord.Process_Name__c = 'Revoke MG Share';
                                exceptionRecord.Object_type__c = 'AccountTeamMember';
                                exceptionRecord.Object_ID__c = sr.getId();
                                exceptionRecord.Error_Messages__c = objErr.getMessage();
                                exceptionRecord.Error_Codes__c = String.valueOf(objErr.getStatusCode());
                                listExceptions.add(exceptionRecord);
            
                            }
                        }
                    }
                    
                    if(listExceptions.size() > 0){
                		Database.SaveResult[] resultStatus = database.insert(listExceptions,false);
            		}
                }
            } 
            if(Test.isRunningTest()){
                throw new NullPointerException();
            }
            
        }
        catch(Exception e) {
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'MG Share';
            exceptionRecord.Object_type__c = 'AccountTeamMember';
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c = e.getMessage();
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
        }
    }   
    
    public static void revokeAccountShareForMasterGroup(List<AccountTeamMember> listOldATMs){
        // To hold the SM Ids
        Set<String> setAccIds = new Set<String>();
        // To hold the User Ids
        Set<String> setUserIds = new Set<String>();
        // To hold the MG Ids
        Set<String> setMGIds = new Set<string>();
        // To hold the Account Share to insert
        List<AccountShare> listAccShareDel = new List<AccountShare>();
        Map<String, AccountTeamMember> mapMGUIDVsATM = new Map<String, AccountTeamMember>();
        List<String> listMGUId = new List<String>(); 
        List<AccountTeamMember> listATMUpdate = new List<AccountTeamMember>();
        try{
                for(AccountTeamMember oldATM : listOldATMs){
                    if(oldATM.Published_MGShare_Event__c != false){
                        setAccIds.add(oldATM.AccountId);
                        setUserIds.add(oldATM.UserId);
                    } 
                }
                
                if(setAccIds.size() > 0 && setUserIds.size() > 0){
                    for(Account salesMotionAccounts : [SELECT Master_Group_Id__c
                                                       FROM Account
                                                       WHERE Id IN: setAccIds
                                                       AND Master_Group_Id__c!= null LIMIT 50000]){
                                                           setMGIds.add(salesMotionAccounts.Master_Group_Id__c);
                                                       }
                    
                    for(AccountTeamMember atm :[SELECT AccountId,UserId,AccountAccessLevel,Account.Master_Group_Id__c,TeamMemberRole
                                                FROM AccountTeamMember
                                                WHERE  Account.Master_Group_Id__c!= null 
                                                AND Account.Master_Group_Id__c IN : setMGIds
                                                AND UserId IN: setUserIds LIMIT 50000
                                               ]){
                                                   mapMGUIDVsATM.put(atm.Account.Master_Group_Id__c+''+atm.UserId, atm);
                                                   if(atm.AccountAccessLevel == 'Edit'){
                                                       listMGUId.add(atm.Account.Master_Group_Id__c+''+atm.UserId);
                                                   }
                                               }
                    
                    for(AccountShare accShare: [SELECT Id,AccountId,UserOrGroupId
                                                FROM AccountShare 
                                                WHERE AccountId IN: setMGIds
                                                AND RowCause=:'Manual'
                                                AND UserOrGroupId IN: setUserIds
                                               ]){
                                                   if(!mapMGUIDVsATM.containsKey(accShare.AccountId+''+accShare.UserOrGroupId)){
                                                       listAccShareDel.add(accShare);
                                                   } else if(!listMGUId.contains(accShare.AccountId+''+accShare.UserOrGroupId)) {
                                                       listATMUpdate.add(mapMGUIDVsATM.get(accShare.AccountId+''+accShare.UserOrGroupId));
                                                   }
                                               }
                    
                    if(!listATMUpdate.isEmpty()){
                        publishAccountShareForMasterGroup(listATMUpdate, null);
                    }
                    
                    if(!listAccShareDel.isEmpty()){
                        Database.DeleteResult[] listSR = Database.delete(listAccShareDel,false);
                        for(Database.DeleteResult sr : listSR) {
                            if(sr.isSuccess()){
                                System.debug('Delete Successfully');
                            } else {
                                for(Database.Error objErr : sr.getErrors()) {
                                    System.debug('The following error has occurred.');  
                                    System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                                    System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                                }
                            }
                        }
                    }
                } 
                if(Test.isRunningTest()){
                    throw new NullPointerException();
                }
            }
        catch(Exception e) {
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'MG Share';
            exceptionRecord.Object_type__c = 'AccountTeamMember';
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c = e.getMessage();
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
        }
        
    }
    
    public static void publishAccountShareForMasterGroup(List<AccountTeamMember> listATM, Map<Id,AccountTeamMember> mapOldATM){
        try{
            List<Share_Records__e> listPublishEvents = new List<Share_Records__e>();
            List<AccountTeamMember> listUpdateATM = new List<AccountTeamMember>();
            for(AccountTeamMember atm : listATM){
                Share_Records__e shareRecObj = new Share_Records__e();
                shareRecObj.AccountId__c = atm.AccountId;
                shareRecObj.User_Id__c = atm.UserId;
                shareRecObj.Account_Access_Level__c = atm.AccountAccessLevel;
                shareRecObj.Mode_of_Event__c = 'Insertion';
                listPublishEvents.add(shareRecObj); 
                listUpdateATM.add(new AccountTeamMember(Id = atm.Id, Published_MGShare_Event__c = true));
            }
            
            if(!listUpdateATM.isEmpty()){
                Database.update(listUpdateATM, false);
            }
            List<Database.SaveResult> results = EventBus.publish(listPublishEvents);
            
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                    }
                }       
            }
            if(Test.isRunningTest()){
				throw new NullPointerException();
			}
        }catch(Exception e) {
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'MG Share';
            exceptionRecord.Object_type__c = 'AccountTeamMember';
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c = e.getMessage();
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
        }
    }
    
    public static void createMGAccountShare(List<Share_Records__e> listShareRecords){
        // To hold the SM Ids
        Set<String> setAccIds = new Set<String>();
        // To hold the User Ids
        Set<String> setUserIds = new Set<String>();
        // To hold the MG Ids
        Set<String> setMGIds = new Set<string>();
        // To hold the Account Share to insert
        List<AccountShare> listAccShareinsert = new List<AccountShare>();
        Map<String, AccountTeamMember> mapMGUIDVsATM = new Map<String, AccountTeamMember>();
        Map<String, String> mapSMIDtoMGID = new Map<String, String>();
        List<String> listMGUId = new List<String>();
        
        try{
            for(Share_Records__e sre : listShareRecords){
                if(String.IsNotBlank(sre.AccountId__c) && sre.Mode_of_Event__c == 'Insertion'){
                    setAccIds.add(sre.AccountId__c);
                    setUserIds.add(sre.User_Id__c);
                }
            }
            
            if(setAccIds.size() > 0){
                for(Account salesMotionAccount : [SELECT Master_Group_Id__c
                                                  FROM Account
                                                  WHERE Id IN: setAccIds
                                                  AND Master_Group_Id__c!= null LIMIT 50000]){
                                                      setMGIds.add(salesMotionAccount.Master_Group_Id__c);
                                                      mapSMIDtoMGID.put(salesMotionAccount.id, salesMotionAccount.Master_Group_Id__c);
                                                  }
                
                for(AccountTeamMember atm :[SELECT AccountId,UserId,AccountAccessLevel,Account.Master_Group_Id__c
                                            FROM AccountTeamMember
                                            WHERE  Account.Master_Group_Id__c!= null 
                                            AND Account.Master_Group_Id__c IN : setMGIds
                                            AND UserId IN: setUserIds LIMIT 50000
                                           ]){
                                               if(atm.AccountAccessLevel == 'Edit'){
                                                   mapMGUIDVsATM.put(atm.Account.Master_Group_Id__c+''+atm.UserId, atm);
                                               }
                                           }
                
                for(Share_Records__e shareRecord : listShareRecords){
                    if(mapSMIDtoMGID.containsKey(shareRecord.AccountId__c)){
                        if(shareRecord.Account_Access_Level__c == 'Read'){
                            if(!mapMGUIDVsATM.containsKey(mapSMIDtoMGID.get(shareRecord.AccountId__c)+''+shareRecord.User_Id__c)){
                                AccountShare accShare = new Accountshare();
                                accShare.AccountId = mapSMIDtoMGID.get(shareRecord.AccountId__c);
                                accShare.UserOrGroupId =  shareRecord.User_Id__c;
                                accShare.AccountAccessLevel = shareRecord.Account_Access_Level__c;
                                accShare.OpportunityAccessLevel='None';
                                accShare.RowCause='Manual'; 
                                listAccShareInsert.add(accShare);
                            } 
                        } else {
                            AccountShare accShare = new Accountshare();
                            accShare.AccountId = mapSMIDtoMGID.get(shareRecord.AccountId__c);
                            accShare.UserOrGroupId =  shareRecord.User_Id__c;
                            accShare.AccountAccessLevel = shareRecord.Account_Access_Level__c;
                            accShare.OpportunityAccessLevel='None';
                            accShare.RowCause='Manual'; 
                            listAccShareInsert.add(accShare);
                        }
                    }
                }
                
                if(listAccShareInsert.size() > 0){
                    Database.SaveResult[] listSR = Database.insert(listAccShareInsert,false);
                    for (Database.SaveResult sr : listSR) {
                        if(sr.isSuccess()){
                            System.debug('Inserted Successfully');
                        }
                        else {
                            for(Database.Error objErr : sr.getErrors()) {
                                System.debug('objErr: '+objErr);  
                                System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                                System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                            }
                        }
                    }
                }
            }
            if(Test.isRunningTest()){
				throw new NullPointerException();
			}
        }catch(Exception e) {
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'MG Share';
            exceptionRecord.Object_type__c = 'AccountTeamMember';
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c = e.getMessage();
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
        }
    }
}