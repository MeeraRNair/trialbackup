/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      25-NOV-2010   Azwanti         Created for CR4117, R12.1

*/
global class BatchDeleteWorkItems implements Database.Batchable<sObject>{
	global string queryOldWorkItem;
	//For test method
    public boolean isTest = false;
	
	global Database.Querylocator Start(Database.BatchableContext BC){
		DBUtils.flushOutTheJobsQueue();
		return Database.getQueryLocator(queryOldWorkItem);	
	}
	
	global void Execute(Database.BatchableContext BC, List<sObject> scope){
		List<Work_Items__c> workItemToDeleteList = new List<Work_Items__c>();
		for(sObject s: scope){
			Work_Items__c workItem = (Work_Items__c)s;
			workItemToDeleteList.add(workItem);
		}	
		
		if(workItemToDeleteList.size() > 0){
			Database.DeleteResult[] resultList = Database.delete(workItemToDeleteList,false);
		}
	}
	
	global void Finish(Database.BatchableContext BC){
		if(isTest != true){
	        //1. Scheduled BatchUpdAccountWorkItem after 1 hour/3600sec interval               
	    /*    BatchUpdateAccountWorkItemExecute buAccWI = new BatchUpdateAccountWorkItemExecute();
	        Integer interval = Integer.valueOf(System.label.BatchUpdWorkItemToComplete_Interval);
	        string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(datetime.now(), interval);
	        system.schedule('1. Batch Update Account Work Item ' + String.valueOf(datetime.now()), schTime, buAccWI);  */
	        
	        AccountOwnerTransitionUtils.scheduleJobs('Delete Exceptions');
    	}
	}
}