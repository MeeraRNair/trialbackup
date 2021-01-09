global class Batch_AutoCloseOpportunitiesExecute implements Schedulable{

     global void execute(SchedulableContext sc) {
         Batch_AutoCloseOpportunities batchObj = new Batch_AutoCloseOpportunities();
         Database.executeBatch(batchObj,1);   
      }                         
}