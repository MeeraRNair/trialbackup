global class Batch_TRTUpdateonPT_Scheduler implements Schedulable {
 global void execute(SchedulableContext sc){
       Batch_TRTUpdateonPT batchTRT = new Batch_TRTUpdateonPT();
       database.executebatch(batchTRT,20);
   }
}