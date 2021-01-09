/**
History:
Version Date                Modified By             Description     
--------------------------------------------------------------------------------------
1.0      14 Sept 2015       Shahiruni Wahida        Created test class for BatchAccountHandoverSendEmailSchedule
 */

@isTest
private class BatchAHSendEmailScheduleTest {

	static testMethod void invoke() {

            Test.startTest();
                    String CRON_EXP = '0 0 0 1 1 ? 2025';  
                    String jobId = System.schedule('test BatchAccountHandoverSendEmailScheduleTest', CRON_EXP, new BatchAccountHandoverSendEmailSchedule() );

                    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

                    System.assertEquals(CRON_EXP, ct.CronExpression); 
                   
            Test.stopTest();
    }

}