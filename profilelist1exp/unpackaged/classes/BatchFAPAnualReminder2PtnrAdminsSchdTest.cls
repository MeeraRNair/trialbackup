/* ------------------------------------------------------------------------------------------------------------------------
Version   Date             CR     By                Purpose
1.0       6 Jan 2016       12485  Dipin Raju        scheduler test class
--------------------------------------------------------------------------------------------------------------------------- */
@isTest
private class BatchFAPAnualReminder2PtnrAdminsSchdTest{       
    static testMethod void t_BatchFAPAnualReminder2PartnerAdminsSchd() {
            Test.startTest();
                    String CRON_EXP = '0 0 0 1 1 ? 2025';  
                    String jobId = System.schedule('BatchFAPAnualReminder2PartnerAdminsSchd test', CRON_EXP, new BatchFAPAnualReminder2PartnerAdminsSchd() );

                    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

                    System.assertEquals(CRON_EXP, ct.CronExpression); 
                   
            Test.stopTest();
    }
}