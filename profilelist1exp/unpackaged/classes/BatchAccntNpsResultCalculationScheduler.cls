/***********************************************************
    * Name          : BatchAccntNpsResultCalculationScheduler 
    * Description   : The schedulable apex class to calculate the Previous NPS Results/Current NPS Results At Account
    * ---------------------------------------------------------
    * Revision  Name             Date         Description
    * 1.0       Jessie Tan       24-Apr-2014  CR 9548  - Created to calculate the Previous NPS Results/Current NPS Results at
                                                         Account 
************************************************************/

global class BatchAccntNpsResultCalculationScheduler implements Schedulable{
 // public Boolean isTest = false;
  
  global void execute(SchedulableContext sc){
  
    //DBUtils.flushOutTheJobsQueue();                                                       
    ID batchprocessid = Database.executeBatch(new BatchAccntNpsResultCalculation() ,50); 
                
  }
  
}