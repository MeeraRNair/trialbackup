/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      29-SEPT-2010   Azwanti         Created for CR4117, R11.10
2.0      19-Oct-2010    Carmen          Delete old jobs in start method
*/
global class BatchUpdateAccountTask implements Database.Batchable<sObject>{
    global string queryAccTask;
    Integer TASK_BATCH_SIZE  = 200;
    //For test method
    public boolean isTest = false;
    
    global Database.Querylocator start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(queryAccTask);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Task> listOfTaskToBeUpdated = new List<Task>();
        Work_Items__c workItem;
        String objectType = 'Account';
        String Operation='Update';
        String JobName = 'Batch Update Account Task Owner Transition';
        Map<ID,ID> IdToWorkItemIdMap = new Map<ID,ID>();
        // Buid Map to Work_Items__c to get new ownerID
        // First find all the accounts in the current scope of opportunities
        Set<Id> AcctIDSet = new set<Id>(); 
        for(sobject s : scope){
            Task tasks = (Task)s;
            AcctIDSet.add(tasks.WhatId);
        } 
        // Now build a map of Work_Items__c keyed by accountID
        Map<ID,Work_Items__c> accountWorkItemMap = new Map<ID,Work_Items__c>();
        for (Work_Items__c W : [SELECT Id, Account__c, Previous_Owner__c, New_Owner__c, Status__c, Object_Type__c
                                FROM Work_Items__c
                                WHERE Account__c in :AcctIDSet AND Status__c = 'In Progress' AND Object_Type__c = 'Account' LIMIT : (Limits.getLimitQueryRows() - Limits.getQueryRows())]) {                
            accountWorkItemMap.put(W.Account__c,W); 
        }    

        // Now update the task in the scope     
        for(sobject s : scope){
            Task TaskScope = (Task)s;
            workItem = accountWorkItemMap.get(TaskScope.AccountId); 
            
            if(TaskScope.OwnerId == workItem.Previous_Owner__c) {
                TaskScope.OwnerId = workItem.New_Owner__c;
                listOfTaskToBeUpdated.add(TaskScope);   
                IdToWorkItemIdMap.put(TaskScope.Id, workItem.Id);           
                if(listOfTaskToBeUpdated.size() == TASK_BATCH_SIZE) {
                    Database.SaveResult[] listOfResult = Database.update(listOfTaskToBeUpdated,false);
                    DBUtils.processResult(listOfTaskToBeUpdated,listOfResult,objectType,Operation,JobName,IdToWorkItemIdMap); 
                    listOfTaskToBeUpdated.clear();
                }
            }               
        }
        
        if(listOfTaskToBeUpdated.size() > 0){
            Database.SaveResult[] listOfResult = Database.update(listOfTaskToBeUpdated,false);  
            DBUtils.processResult(listOfTaskToBeUpdated,listOfResult,objectType,Operation,JobName,IdToWorkItemIdMap);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    	if(isTest != true){
	        //1. schedule next apex job : Contact
	        BatchUpdateContactExecute buContactExecute = new BatchUpdateContactExecute();
	        datetime TodayDate = datetime.now();
	        string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
	        system.schedule('5. Batch Update Contact' +String.valueOf(TodayDate), schTime, buContactExecute);
    	}
    }
}