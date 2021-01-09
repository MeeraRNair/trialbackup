/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      29-SEPT-2010   Azwanti         Created for CR4117, R11.10

*/ 
global class BatchUpdateAccountTaskExecute implements Schedulable{
    
    global void execute(SchedulableContext sc){
        BatchUpdateAccountTask buAccountTask = new BatchUpdateAccountTask();
        buAccountTask.queryAccTask = 'SELECT WhatId, AccountId, OwnerId '+
                                     'FROM Task WHERE WhatId in (SELECT Account__c FROM Work_Items__c WHERE Status__c = \'In Progress\' AND Object_Type__c = \'Account\') AND '+
                                     'IsClosed = false';
                                              
        ID batchprocessid1 = Database.executeBatch(buAccountTask,200); 
    }
}