/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      26-OCT-2010   	Azwanti         Created for CR4117, R11.10
1.2		 28-Apr-2010	Azwanti			CR6069-emergency CR for CR4117
*/
global class BatchUpdateWorkItemToComplete implements Database.Batchable<sObject>{
    global string queryPendingWorkItem;
    //For test method
    public boolean isTest = false;
    
    global Database.Querylocator Start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(queryPendingWorkItem);
    }
    
    global void Execute(Database.BatchableContext BC, List<sObject> scope){
        List<Work_Items__c> workItemToBeComplete = new List<Work_Items__c>();
        for(sObject s: scope){
            Work_Items__c workItem = (Work_Items__c)s;
            workItem.Status__c = 'Auto-Complete';
            workItemToBeComplete.add(workItem); 
        }
        update workItemToBeComplete;
    } 
    
    global void Finish(Database.BatchableContext BC){
    
     	if(isTest != true){
            //1. Scheduled BatchUpdAccountWorkItem after 1 hour/3600sec interval               
        /*    BatchUpdateAccountWorkItemExecute buAccWI = new BatchUpdateAccountWorkItemExecute();
            Integer interval = Integer.valueOf(System.label.BatchUpdWorkItemToComplete_Interval);
            string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(datetime.now(), interval);
            system.schedule('1. Batch Update Account Work Item ' + String.valueOf(datetime.now()), schTime, buAccWI); */
            
            AccountOwnerTransitionUtils.scheduleJobs('Delete Work Items');//1.2
        } 
        
    } 
}