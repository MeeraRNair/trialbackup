/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      11-Oct-2010   Azwanti         Created for CR4117, R11.10
2.0      19-Oct-2010   Carmen          Delete old jobs in start method
3.0      21-Jun-2017   Sajith          CR14459 - Modify APEX transition batch ápex job to exclude RL & AP
*/
global class BatchUpdateOpptyTask implements Database.Batchable<sObject>{
    global string queryOpptyTask;
    Map<ID,Work_Items__c> opptyWorkItemMap = new Map<ID,Work_Items__c>();
    //For test method
    public boolean isTest = false;
    
    global Database.Querylocator Start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(queryOpptyTask);
    }
    
    global void Execute(Database.BatchableContext BC, List<sObject> scope){
    	
        List<Work_Items__c> opptyWorkItemtobeCompleted = new List<Work_Items__c>();
        List<Task> listOfTaskToBeUpdated = new List<Task>();
        Work_Items__c workItem;
        Integer TASK_BATCH_SIZE = 500;
        String objectType = 'Task';
        String Operation='Update';
        String JobName = 'Batch Update Oppty Task Owner Transition';
        Map<ID,ID> IdToWorkItemIdMap = new Map<ID,ID>();
        // Buid Map to Work_Items__c to get new ownerID
        Set<Id> OpptyIDSet = new set<Id>(); 
        for(sobject s : scope){
            Task tasks = (Task)s;
            OpptyIDSet.add(tasks.WhatId);
        } 
   
        // Now build a map of Work_Items__c keyed by Opportunity__c
        for (Work_Items__c W : [SELECT Id, Opportunity__c, Previous_Owner__c, New_Owner__c,Status__c
                                FROM Work_Items__c
                                WHERE Opportunity__c in :OpptyIDSet AND Status__c = 'Pending' AND Object_Type__c = 'Opportunity' LIMIT : (Limits.getLimitQueryRows() - Limits.getQueryRows())]) {                
            opptyWorkItemMap.put(W.Opportunity__c,W);
        }    

        // Now update the task in the scope     
        for(sobject s : scope){
            Task taskVar = (Task)s;
            workItem = opptyWorkItemMap.get(taskVar.WhatId);
            
            if(workItem != null && taskVar.OwnerId == workItem.Previous_Owner__c) {
                taskVar.OwnerId = workItem.New_Owner__c;
                listOfTaskToBeUpdated.add(taskVar);         
                IdToWorkItemIdMap.put(taskVar.Id,workItem.Id);  
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
    
    global void Finish(Database.BatchableContext BC){  
		if(isTest != true){
			//3.0 Commenting below code as part of modify APEX transition batch ápex job to exclude RL & AP
            //schedule next apex job : AP tasks
	        //BatchUpdateAccountPlayTaskExecute buAPTask = new BatchUpdateAccountPlayTaskExecute();
	        //datetime TodayDate = datetime.now();
	        //string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
	        //system.schedule('10. Batch Update Account Play Task Owner Transition ' +String.valueOf(TodayDate), schTime, buAPTask);
            
           	//1. schedule next apex job : BatchUpdateWorkItemToComplete
          	BatchUpdateWorkItemToCompleteExec buWorkItem = new BatchUpdateWorkItemToCompleteExec();
          	datetime TodayDate = datetime.now();
          	string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
          	system.schedule('10. Batch Update Work Item to Complete ' +String.valueOf(TodayDate), schTime, buWorkItem);
		}
    }
}