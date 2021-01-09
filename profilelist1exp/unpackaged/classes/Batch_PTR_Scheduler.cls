global class Batch_PTR_Scheduler implements Schedulable {
 global void execute(SchedulableContext sc){
       Batch_PTR batchPTR = new Batch_PTR();
       database.executebatch(batchPTR,50);
   }
  
}