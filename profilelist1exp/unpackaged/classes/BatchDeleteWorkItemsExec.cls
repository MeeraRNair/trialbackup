/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     25-NOV-2010   	Azwanti         Created for CR4117, R12.1
2.0		27-MAR-2013		MenMee			CR8107 Delete work items less than last 7 days instead on last 7 days
*/
global class BatchDeleteWorkItemsExec implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchDeleteWorkItems bdWorkItem = new BatchDeleteWorkItems();
        //2.0
        //bdWorkItem.queryOldWorkItem = 'Select Id, Status__c, CreatedDate from Work_Items__c where (Status__c = \'Auto-Complete\' OR Status__c = \'Completed\' OR Status__c = \'Closed-Duplicate\') AND CreatedDate = LAST_N_DAYS:7';
        bdWorkItem.queryOldWorkItem = 'Select Id, Status__c, CreatedDate from Work_Items__c where (Status__c = \'Auto-Complete\' OR Status__c = \'Completed\' OR Status__c = \'Closed-Duplicate\') AND CreatedDate < LAST_N_DAYS:7';
        system.debug('######### bdWorkItem.queryOldWorkItem: '+bdWorkItem.queryOldWorkItem);
        ID batchprocessid1 = Database.executeBatch(bdWorkItem,500); 
    }
}