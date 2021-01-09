/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      28-SEPT-2010   Azwanti         Created for CR4117, R11.10

*/
global class BatchUpdateOpportunityExecute implements Schedulable{
    global ID batchOpptyId;
    
    global void execute(SchedulableContext sc){
        BatchUpdateOpportunity buOppty = new BatchUpdateOpportunity();
        buOppty.QueryForOpp = 'SELECT Id FROM Opportunity '+ 
                              'WHERE AccountId in (select Account__c FROM Work_Items__c where Status__c = \'In Progress\' AND Object_Type__c = \'Account\')';
                                                    
        batchOpptyId = Database.executeBatch(buOppty,200);
    }
}