/* ------------------------------------------------------------------------------------------------------------------------
Version   Date             CR     By                Purpose
1.0       18 Aug 2015      11856      Dipin Raju    scheduler test class
--------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class BatchUpdateLeadStatusUponEndDateSchdTest {       
    static testMethod void t_BatchUpdateLeadStatusUponEndDateSchedule() {
            Test.startTest();
                    String CRON_EXP = '0 0 0 1 1 ? 2025';  
                    String jobId = System.schedule('BatchUpdateLeadStatusUponEndDateSchedule test', CRON_EXP, new BatchUpdateLeadStatusUponEndDateSchedule() );

                    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

                    System.assertEquals(CRON_EXP, ct.CronExpression); 
                   
            Test.stopTest();
    }
}