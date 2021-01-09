/**
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      01-SEPT-2015     Azwanti        Created test class for BatchWeeklySummaryOpenLeadEmailScheduler
 */

@isTest
private class bWeeklySummaryOpenLeadEmailSchedulerTest{

    static testMethod void invokeBatchWeeklyleadEmailSchedulerTest() {

            Test.startTest();
                    String CRON_EXP = '0 0 0 1 1 ? 2025';  
                    String jobId = System.schedule('test BatchWeeklySummaryOpenLeadEmailScheduler', CRON_EXP, new BatchWeeklySummaryOpenLeadEmailScheduler() );

                    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

                    System.assertEquals(CRON_EXP, ct.CronExpression); 
                   
            Test.stopTest();
    }
}