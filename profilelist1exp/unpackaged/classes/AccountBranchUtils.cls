/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0		CR 2573									Manju 			Utility Class  for Account Branch (Duplicate check and Delete)
 * 2.0      CR 10751	16.03       03-Dec-2014     Ragu            Optimized deleteAllAccBrAndLOBs() and formatted all methods.
 *
 */

public class AccountBranchUtils {
    
    // Method to check and delete Accoutn branches and its LOBs
    public static void checkAndDeleteAccountBranches(map<String, Account_Branch__c> accountBranchMap, set<String> accBranchIdSet, set<String> accountIdSet) {
        // Variables
        Database.DeleteResult[] deleteResult;
        set<String> deletableLOBNameSet = new set<String>{'Open', 'Closed'};
        set<String> errorAddedBranchSet = new set<String>();
        map<String, list<LOB_Registration__c>> branchToLOBRegDeleteMap =  new map<String, list<LOB_Registration__c>>();
        list<LOB_Registration__c> LOBRegForDeleteList =  new list<LOB_Registration__c>();
        String delAccountBranch = System.Label.CR_2573_Del_Account_Branch;
        
    	// CRQ0241 Reminder : uncomment after type change  
      	for(LOB_Registration__c LOBRegItem : [SELECT Registered_End_User__c, LOB_Name__c,Location__c, LOB_registration_status__c
                                              FROM LOB_Registration__c WHERE Location__c in: accBranchIdSet and Registered_End_User__c in: accountIdSet]) {
            String branchId = LOBRegItem.Location__c;
            if(!errorAddedBranchSet.contains(branchId)) {
                if(!deletableLOBNameSet.contains(LOBRegItem.LOB_registration_status__c)) {
                    Trigger.oldMap.get(branchId).addError(delAccountBranch);
                    errorAddedBranchSet.add(LOBRegItem.Location__c);
                }
                else {
                    addToBranchLOBRegMap(branchToLOBRegDeleteMap,branchId,LOBRegItem);
                }
            }       
        }
        for(String branchId : branchToLOBRegDeleteMap.keySet()) {
            if(!errorAddedBranchSet.contains(branchId)) { 
                LOBRegForDeleteList.addAll(branchToLOBRegDeleteMap.get(branchId));
            }       
        }
        if(LOBRegForDeleteList.size() > 0) {
            deleteResult  = Database.delete(LOBRegForDeleteList,false);
        }  
    }
    
    public static void addToBranchLOBRegMap(map<String, list<LOB_Registration__c>> branchToLOBRegDeleteMap, String branchId, LOB_Registration__c LOBrecord) {
        if(branchToLOBRegDeleteMap == null) {
            branchToLOBRegDeleteMap = new map<String, list<LOB_Registration__c>>();
        }
        if(branchToLOBRegDeleteMap.get(branchId) == null) {
            branchToLOBRegDeleteMap.put(branchId,new list<LOB_Registration__c>{LOBrecord});
        }
        else {
            branchToLOBRegDeleteMap.get(branchId).add(LOBrecord);
        }
    }    
    
    // Method to prevent duplicates
    public static void preventDuplicates(list<Account_Branch__c> insertedBranches) {
        set<String> accountIdSet = new set<String>();
        set<String> branchNameSet= new set<String>();
        map<String, set<String>> accountIdToBranchSetMap = new map<String, set<String>>();
        
        for(Account_Branch__c accBrItem : insertedBranches) {
            accountIdSet.add(accBrItem.Account__c);
            branchNameSet.add(accBrItem.Name);
        }
        for(Account_Branch__c accBrItem : [SELECT Id, Name, Account__c FROM Account_Branch__c WHERE
                                           Account__c in: accountIdSet and Name in: branchNameSet]) {
            putItemsToSringtoSetofStringMap(accountIdToBranchSetMap, accBrItem.Account__c, accBrItem.Name);
        }
        for(Account_Branch__c accBrItem : insertedBranches) {
            boolean duplicate = false;
            set<String> existingBranchNameSet = accountIdToBranchSetMap.get(accBrItem.Account__c);
            
            if(existingBranchNameSet != null) {
                if(existingBranchNameSet.contains(accBrItem.Name)) {
                    accBrItem.addError('Account Branch already exists');
                    duplicate = true;
                    continue;
                }
            }
            if(!duplicate) {
                putItemsToSringtoSetofStringMap(accountIdToBranchSetMap, accBrItem.Account__c, accBrItem.Name);
            }
        }
    }
    
    // Method for preventing duplicates in the same batch
    public static void putItemsToSringtoSetofStringMap(map<String, set<String>> currentMap, String accountId, String accBrName) { 
        if(currentMap == null) {
            currentMap= new map<String, set<String>>();
        }
        if(currentMap.get(accountId) == null) {
            currentMap.put(accountId, new set<String>{accBrName});
        }
        else {
            currentMap.get(accountId).add(accBrName);
        }
    }
    
    // Method to delete all Account Branches and its LOBs if 'Participating in LOB' is unchecked
    public static void deleteAllAccBrAndLOBs(set<Id> setAccountIds) {
        // CRQ0241 Reminder : uncomment after type change 
        list<LOB_Registration__c> lstLOBRegistrations = [select Id, Name, Registered_End_User__c from LOB_Registration__c where Registered_End_User__c in :setAccountIds];
        if(lstLOBRegistrations != null && !lstLOBRegistrations.isEmpty()) {
            Database.delete(lstLOBRegistrations, false);
        }
        
        list<Account_Branch__c> lstAccountBranches = [select Id, Name, Account__c from Account_Branch__c where Account__c in :setAccountIds];
        if(lstAccountBranches != null && !lstAccountBranches.isEmpty()) {
            Database.delete(lstAccountBranches, false);
        }
    }
    
    // Method to delete all Account Branches and its LOBs if 'Participating in LOB' is unchecked - Need to be commented
    public static void deleteAllAccBrAndLOBs(map<String, Account> accountMap, set<String> accountIdSet) {
        Database.DeleteResult[] deleteAccBrResult;
        Database.DeleteResult[] deleteLobResult;
        List<Account_Branch__c> listOfAccBranches = new List<Account_Branch__c>();
        for(Account_Branch__c accBrItem : [SELECT Id, Name, Account__c FROM Account_Branch__c WHERE Account__c in: accountIdSet]) {
            listOfAccBranches.add(accBrItem);
        }
        // CRQ0241 reminder : uncomment after type change 
        List<LOB_Registration__c> listOfLobRecs = [SELECT Registered_End_User__c,LOB_Name__c, Location__c, LOB_registration_status__c
                                                   FROM LOB_Registration__c WHERE Registered_End_User__c in: accountIdSet];
        if(listOfLobRecs.size() > 0) {
            deleteLobResult  = Database.delete(listOfLobRecs, false);
        }
        if(listOfAccBranches.size() > 0) {
            deleteAccBrResult  = Database.delete(listOfAccBranches, false);
        } 
    }
    
}