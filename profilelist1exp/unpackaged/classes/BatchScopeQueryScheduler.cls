global class BatchScopeQueryScheduler implements Schedulable{
 // public Boolean isTest = false;
  
  global void execute(SchedulableContext sc){
  
    //DBUtils.flushOutTheJobsQueue(); 
    BatchScopeQuery batchScopeQueries = new BatchScopeQuery();
    batchScopeQueries.query = 'SELECT Name, Skip_Trigger__c, Query__c, Field_to_update__c, New_Value__c, Batch_Size__c, Need_Helper__c FROM Batch_Scope_Query__c WHERE Is_Active__c = true';
    ID batchprocessid = Database.executeBatch(batchScopeQueries, 1); 
                
  }
  
}