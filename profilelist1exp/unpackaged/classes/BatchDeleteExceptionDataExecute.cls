/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      25-NOV-2010    Azwanti         Created for CR4117, R12.1
2.0      18-OCT-2011    Azwanti         CR6657 - Lattice Exception handling: to delete exception records created more than 60 days.
*/
global class BatchDeleteExceptionDataExecute implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchDeleteExceptionData bdException = new BatchDeleteExceptionData();
        bdException.queryOldException = 'Select Id, CreatedDate from Exception__c where CreatedDate < LAST_N_DAYS:60';//r2.0 LAST_MONTH';
        // 'Select Id, CreatedDate from Exception__c where CreatedDate < 2011-03-01T00:00:00Z and CreatedDate > 2011-01-31T23:59:59Z';//for R12.5 SIT test only
                
        ID batchprocessid1 = Database.executeBatch(bdException,500); 
    }
}