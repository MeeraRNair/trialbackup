/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      13-Oct-2010   Azwanti         Created for CR4117, R11.10

*/
global class BatchUpdateAccountWorkItemExecute implements Schedulable{
    global void Execute(SchedulableContext sc){
        BatchUpdateAccountWorkItem buAccWorkItem = new BatchUpdateAccountWorkItem();
        buAccWorkItem.queryAccWorkItem = 'Select Id From Work_Items__c '+
            'Where Status__c = \'Pending\' AND Object_Type__c = \'Account\' AND (Previous_Owner__c != \''+dellConfig.glblDataAdminGUID+'\' AND New_Owner__c != \''+dellConfig.glblDataAdminGUID+'\') '+
            (System.Label.BatchUpdAccWorkItem_Row_Limit != '-'? 'ORDER BY LastModifiedDate LIMIT ' + System.Label.BatchUpdAccWorkItem_Row_Limit : '');
        ID batchprocessid = Database.executeBatch(buAccWorkItem, 200);
    }
}