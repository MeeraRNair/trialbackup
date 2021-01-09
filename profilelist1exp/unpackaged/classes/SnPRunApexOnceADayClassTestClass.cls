@istest
class SnPRunApexOnceADayClassTestClass {

   static testMethod void SnPRunApexClassTestMethod() {
   
       Test.startTest();

       S_P_Vendor_Automation__c sva = new S_P_Vendor_Automation__c();
       sva.Vendor_Name__c = 'Test Vendor';
       sva.Automation_Type__c = 'Full Automation';
       sva.Is_Active__c = true;
       sva.Expiration_Date__c = System.today().addDays(7);
       insert sva;

       // Schedule the test job
       String jobId = System.schedule('testBasicScheduledApex',
              SnPRunApexOnceADayClass.CRON_EXP, 
              new SnPRunApexOnceADayClass());
  
       // Get the information from the CronTrigger API object 
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         FROM CronTrigger WHERE id = :jobId];

       // Verify the expressions are the same 
       System.assertEquals(SnPRunApexOnceADayClass.CRON_EXP, 
         ct.CronExpression);

       // Verify the job has not run 
       System.assertEquals(0, ct.TimesTriggered);

       Test.stopTest();

       }
}