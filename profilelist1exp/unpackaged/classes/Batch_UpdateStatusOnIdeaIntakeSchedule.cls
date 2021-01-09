/**********************************************************************************************
 * Name         : Batch_UpdateStatusOnIdeaIntakeSchedule
 * Description  : Schedule the class Batch_UpdateStatusOnIdeaIntake to take 5 records at a time
 * Created      : 14-1-2015
 * Created By   : Devika Pujari
 ***********************************************************************************************

 **********************************************************************************************/
global class Batch_UpdateStatusOnIdeaIntakeSchedule implements Schedulable{

     global void execute(SchedulableContext sc) {
         Batch_UpdateStatusOnIdeaIntake batchObj = new Batch_UpdateStatusOnIdeaIntake();
         Database.executeBatch(batchObj,5);   
      }                         
}