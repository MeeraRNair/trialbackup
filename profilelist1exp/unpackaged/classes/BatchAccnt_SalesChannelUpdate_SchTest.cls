/**
History:
Version     Date            Modified By             CR          Description     
--------------------------------------------------------------------------------------
1.0         4-Feb-2016      Shahiruni Wahida        12627       Create test class for BatchAccnt_SalesChannelUpdate_Schedule
 */

@isTest
private class BatchAccnt_SalesChannelUpdate_SchTest {
	static testMethod void invoke() {

            Test.startTest();
                    String CRON_EXP = '0 0 0 1 1 ? 2025';  
                    String jobId = System.schedule('test BatchAccnt_SalesChannelUpdate_ScheduleTest', CRON_EXP, new BatchAccnt_SalesChannelUpdate_Schedule() );

                    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

                    System.assertEquals(CRON_EXP, ct.CronExpression); 
                   
            Test.stopTest();
    }

}