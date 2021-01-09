// Call the batch class only when is Enabled for track is check
/**
* Controller logic for granting or revoking access to sales motion accounts.
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
*                       FY20-0402     19-Dec-2018     Sneha         Logic to implement revoke and grant access
*                       FY20-0402     11-Feb-2018     Sneha         PMD Violations
*/
global class ManageAccessForSalesMotion implements Database.Batchable<sObject>,Database.Stateful {
    
    // Map to hold the User id Vs Sales Motion Accounts
    Map<String, List<String>> mapUsrIdToSM = new Map<String, List<String>>();
    private String strOperationType;
    
    public ManageAccessForSalesMotion(Map<String, List<String>> mapUsrToSM,String stroperation) {
        System.debug('mapUsrToSM key set in cons:'+mapUsrToSM.keySet());
        mapUsrIdToSM = mapUsrToSM;
        strOperationType = stroperation;
        System.debug('mapUsrIdToSM key set in cons:'+mapUsrIdToSM.keySet());
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        String strQuery;
        System.debug('mapUsrIdToSM key set:'+mapUsrIdToSM.keySet());
        Set<String> setKeys = mapUsrIdToSM.keySet();
        
        strQuery ='SELECT Id,IsActive,ContactId,UserRoleId,Enable_as_Partner_Group_Administrator__c,Enable_Partner_Admin__c, '+
            '(SELECT Id,Contact.EligibleTracks__c,Contact.AccountId,Contact.Account.Partner_Track__c FROM Partner_User__r) '+
            'FROM USER WHERE Id IN : setKeys';
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext bc, List<User> listscope){
        
        // To hold the Account Share to insert
        List<AccountShare> listAccShareInsert = new List<AccountShare>();
        // To hold the Account Share to delete
        List<AccountShare> listAccShareDel = new List<AccountShare>();
        //To hold the existing Account Share records
        List<AccountShare> listAccShareExists = new List<AccountShare>();
        System.debug('mapUsrIdToSM key set in cons:'+mapUsrIdToSM.keySet());
        if(String.isNotBlank(strOperationType)){
            // Check if the share record already exists
            listAccShareExists = [SELECT Id,AccountId,UserOrGroupId
                                  FROM AccountShare
                                  WHERE RowCause=:'Manual' 
                                  AND UserOrGroupId IN: mapUsrIdToSM.keySet() 
                                 ];
        }
        System.debug('listAccShareExists'+listAccShareExists.size());
        //map to hold the User vs AccountId's
        Map<String,List<AccountShare>> mapShareUsrToSM = new Map<String,List<AccountShare>>();
        if(listAccShareExists.size() > 0){
            for(AccountShare accSh : listAccShareExists){
                if(mapShareUsrToSM.containsKey(accSh.UserOrGroupId)){
                    mapShareUsrToSM.get(accSh.UserOrGroupId).add(accSh);
                }
                else{
                    mapShareUsrToSM.put(accSh.UserOrGroupId,new List<AccountShare>{ accSh }); 
                }
                
            }
            System.debug('mapShareUsrToSM::'+mapShareUsrToSM);
        }
        if(mapUsrIdToSM.size() > 0){
            for(String strUsrId : mapUsrIdToSM.keySet()){
                if(mapShareUsrToSM.containsKey(strUsrId) && mapShareUsrToSM.get(strUsrId)!= null){
                    if(String.isNotBlank(strOperationType) && strOperationType == System.Label.Revoke_Access_Type){
                        for(String strAccId : mapUsrIdToSM.get(strUsrId)){
                          for(AccountShare accShare : mapShareUsrToSM.get(strUsrId)){
                                if(accShare.AccountId.equals(strAccId)){
                                    listAccShareDel.add(accShare);
                                }
                            }
                       }
                        
                     }
                    else if(String.isNotBlank(strOperationType) && strOperationType == System.Label.Grant_Access_Type){
                        List<String> listAccountIds = new List<String>();
                       for(AccountShare accShare : mapShareUsrToSM.get(strUsrId)){
                          listAccountIds.add(accShare.AccountId);
                       }
                       for(String strAccId : mapUsrIdToSM.get(strUsrId)){
                         if(listAccountIds.equals(strAccId)){
                            System.debug('::GRANT::Account Share already exists for the user '+strUsrId+' and account '+strAccId+' combination:');
                         }
                         else{
                              System.debug('::GRANT::Account Share doesnt exists for the user '+strUsrId+' and account '+strAccId+' combination:');
                              AccountShare accShare = new Accountshare();
                              accShare.AccountId = strAccId;
                              accShare.UserOrGroupId = strUsrId;
                              accShare.AccountAccessLevel = 'Read';
                              accShare.OpportunityAccessLevel='None';
                              accShare.RowCause='Manual';
                              listAccShareInsert.add(accShare);
                        }
                     }
                    }
                }
        else{
                      if(String.isNotBlank(strOperationType) && strOperationType == System.Label.Grant_Access_Type){
                            for(String strAccId : mapUsrIdToSM.get(strUsrId)){
                                AccountShare accShare = new Accountshare();
                                accShare.AccountId = strAccId;
                                accShare.UserOrGroupId = strUsrId;
                                accShare.AccountAccessLevel = 'Read';
                                //accShare.CaseAccessLevel ='Read';
                                accShare.OpportunityAccessLevel='None';
                                accShare.RowCause='Manual';
                                listAccShareInsert.add(accShare);
                            }
                        }
                    }                    
      }
        }
        System.debug('listAccShareInsert'+listAccShareInsert.size());
        System.debug('listAccShareDel'+listAccShareDel.size());
        if(listAccShareInsert.size() > 0){
            Database.SaveResult[] listSR = Database.insert(listAccShareInsert,false);
            for (Database.SaveResult sr : listSR) {
                if(sr.isSuccess()){
                    System.debug('Inserted Successfully');
                }
                else {
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('The following error has occurred.');  
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                        
                        
                    }
                }
                
            }
            
            
        }
        if(listAccShareDel.size() > 0){
            Database.DeleteResult[] listSR = Database.delete(listAccShareDel,false);
            for (Database.DeleteResult sr : listSR) {
                if(sr.isSuccess()){
                    System.debug('Delete Successfully');
                }
                else {
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('The following error has occurred.');  
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                        
                        
                    }
                }
                
            }
            
        }
        
    }
    global void finish(Database.BatchableContext bc){}
    
    
    
}