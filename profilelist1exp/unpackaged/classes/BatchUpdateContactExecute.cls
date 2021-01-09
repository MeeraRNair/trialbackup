/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      12-OCT-2010   Azwanti         Created for CR4117, R11.10

*/
global class BatchUpdateContactExecute implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchUpdateContact buContact = new BatchUpdateContact();
        buContact.queryContact = 'SELECT Id, AccountId FROM Contact '+ 
                                'WHERE AccountId in (select Account__c FROM Work_Items__c where Status__c = \'In Progress\' AND ' +
                                'Object_Type__c = \'Account\')';
                                                    
        ID batchprocessid1 = Database.executeBatch(buContact,1000);
    }
}