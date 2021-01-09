global class Batch_ChatterPost_Scheduler implements schedulable {

   global void execute(SchedulableContext sc){
       Batch_ChatterPostOnRequestEscalation m = new Batch_ChatterPostOnRequestEscalation();
       database.executebatch(m);
   }
  
}