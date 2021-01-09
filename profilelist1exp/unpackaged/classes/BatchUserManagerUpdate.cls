global class BatchUserManagerUpdate implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    Public List<Exception__c> listOfException = new List<Exception__c>();
    
    global database.querylocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        set<string>  allBadgeidSet = new set<string>();
        Map<string, User> userMap = new Map<string, USer>();
        Map<string, peoplesoft_user_view__c> peopleSoftMap = new Map<string, peoplesoft_user_view__c>();
        peoplesoft_user_view__c peopleSoftRec; 
        List<User> userListToUpdate   = new List<User>();
        
        try{
            for(sObject obj :scope){
                peopleSoftRec = (peoplesoft_user_view__c)obj;
                allBadgeIdSet.add(peopleSoftRec.badge_number__c);
                allBadgeIdSet.add(peopleSoftRec.Direct_Manager_Badge_Number__c);
                peopleSoftMap.put(peopleSoftRec.Badge_Number__c, peopleSoftRec);
            }
            if(allBadgeidSet.Size() > 0){
                For(User userList :[select username,email,id,title,isactive, badge_number__c,ManagerId 
                                       from user 
                                       where badge_number__c IN :allBadgeidSet]){
                    userMap.put(userList.Badge_Number__c, userList);
                }
            }

            if(peopleSoftMap.Size() > 0){
                for(Peoplesoft_User_view__c ps :peopleSoftMap.Values()){
                    String managerBadgeNumber = ps.Direct_Manager_Badge_Number__c;
                    if(userMap.get(managerBadgeNumber) != NUll && userMap.get(ps.Badge_Number__c) != NUll){ 
                        if( userMap.get(managerBadgeNumber).ISActive ==  True
                            && userMap.get(ps.Badge_Number__c).IsActive == TRUE
                            && userMap.get(ps.Badge_Number__c).ManagerId  != userMap.get(managerBadgeNumber).Id
                            ){
                            userMap.get(ps.Badge_Number__c).ManagerId  = userMap.get(managerBadgeNumber).Id;
                            userListToUpdate.add(userMap.get(ps.Badge_Number__c));
                        }
                    }
                }
            }

            
            if(userListToUpdate.Size() > 0){
                database.SaveResult[] updateResults;
                updateResults = database.update(userListToUpdate, false);

                
                
                List<String> errorCodeDelList = new List<String>();
                List<String> errorMessageDelList = new List<String>();
                for(integer i = 0; i< updateResults.size();i++){       
                    if(updateResults[i].isSuccess()!=true){
                        Exception__c exceptionVar = new Exception__c();        
                        exceptionVar.Object_type__c = 'User';
                        exceptionVar.Object_ID__c = userListToUpdate[i].Id;
                        exceptionVar.Operation__c = 'Update';
                        exceptionVar .Notes__c = 'Badge Number : '+userListToUpdate[i].Badge_number__c;
                        exceptionVar.Process_Name__c = 'User Manager Update';
                        exceptionVar.Email__c = userListToUpdate[i].Email;
                        
                        Database.Error [] errors = updateResults[i].getErrors();
                        errorCodeDelList.clear();
                        errorMessageDelList.clear();
                        // Cycle through the errors
                        for (Database.Error error :errors){
                            errorCodeDelList.add(''+error.getStatusCode());
                            errorMessageDelList.add(''+error.getMessage());
                        }            
                        exceptionVar.Error_Codes__c = StringUtils.joinStrings (errorCodeDelList, ',');
                        string errMsg = StringUtils.joinStrings (errorMessageDelList, ',');
                        if(errMsg.length() > 255) {                       
                            exceptionVar.Error_Messages__c =  errMsg.SubString(0,254);
                        }
                        else{
                            exceptionVar.Error_Messages__c =  errMsg;
                        }
                        listOfException.add(exceptionVar);  
                    } 
                }
            }
       }catch (System.DmlException e){
            system.debug('----Exception Occured--'+e);
       }  
    }
    global void finish(Database.BatchableContext info){  
        if(listOfException.size() > 0 ){
            insert listOfException;

        }
    } 
}