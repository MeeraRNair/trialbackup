/********************************************************************************************* 
     Author Name   : Adityareddy Pulagam.
     Description   : Scheduling for every 2 days.
     Release       : 14.5 Maintanance Release.
     Date          : 25-4-2013.   
     BR#           : 034
     CR#           : 8009
***********************************************************************************************/

global class BatchLicenseScheduleExecute implements Schedulable{

     global void execute(SchedulableContext sc) {
         BatchLicense batchObj = new BatchLicense();
         Database.executeBatch(batchObj,200);
      //   CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        //     FROM CronTrigger WHERE Id = :sc.getTriggerId()];

       // system.abortjob(ct.id);
      }                         
}