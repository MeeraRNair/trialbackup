/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      12-Oct-2010   Azwanti         Created for CR4117, R11.10

*/
global class BatchUpdateOpptyTaskExecute implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchUpdateOpptyTask buOpptyTask = new BatchUpdateOpptyTask();
        buOpptyTask.queryOpptyTask = 'SELECT WhatId, AccountId, OwnerId '+
                                 'FROM Task WHERE WhatId in (SELECT Opportunity__c FROM Work_Items__c WHERE Status__c = \'Pending\' AND Object_Type__c = \'Opportunity\') AND '+
                                 'IsClosed = false';
        
        ID batchprocessid1 = Database.executeBatch(buOpptyTask,200);
    }
}