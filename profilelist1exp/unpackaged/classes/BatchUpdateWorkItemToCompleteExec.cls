/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      26-OCT-2010   Azwanti         Created for CR4117, R11.10

*/
global class BatchUpdateWorkItemToCompleteExec implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchUpdateWorkItemToComplete buWorkItem = new BatchUpdateWorkItemToComplete();
        buWorkItem.queryPendingWorkItem = 'SELECT Status__c FROM Work_Items__c WHERE (Object_Type__c = \'Account\' AND Status__c = \'In Progress\') OR (Object_Type__c != \'Account\' AND Status__c = \'Pending\')';
        //'SELECT Status__c FROM Work_Items__c WHERE (Status__c = \'Pending\' AND (Previous_Owner__c != \''+dellConfig.glblDataAdminGUID+'\' AND New_Owner__c != \''+dellConfig.glblDataAdminGUID+'\')) OR Status__c = \'In Progress\'';
                
        ID batchprocessid1 = Database.executeBatch(buWorkItem,500);
    }
}