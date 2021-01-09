/*
History:
Version     Date            Modified By     CR          Description     
--------------------------------------------------------------------------------------
1.0         19-May-2016     Rajkumar        14340       Added Column Account Owner ID 
*/

global class BatchAccountHandoverSchedule implements schedulable{
    global void execute (SchedulableContext SC){
        string query;
        //1.0 - Added Column Account Owner ID
        query = 'SELECT Id, Account__c, Incoming_rep__c, Outgoing_rep__c, Transition_Start_date__c, account__r.OwnerID,  Account_Access_Share__c, Incoming_rep__r.Email, Account_ID__c, Incoming_rep__r.Isactive '+
                'FROM Account_Handover__c '+
                'WHERE Account_Access_Share__c = false ' +
                'AND Incoming_rep__c != null AND Transition_Start_date__c <= Today';        
                 
                 query += System.Label.Account_Handover_Ids != 'Manual PIT Testing'  ? ' And Id IN : setofids ' : '' ;  
                 BatchAccountHandover BatchPSA = new BatchAccountHandover();                    
                 BatchPSA.query= query; 
                 database.executebatch(BatchPSA,200);  
    } 
  
}