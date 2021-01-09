@isTest   //(SeeAllData=true)
private class Batch_DealExpirationNotifyExecuteTest {

    static testmethod void testOpptyArchiveSchedule() {
        //Running the schedulable
        Test.startTest();       
        String CRON_EXP = '0 0 0 * * ?';
        Batch_DealExpirationNotificationExecute sch = new Batch_DealExpirationNotificationExecute();
        String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);    
                
        Test.stopTest();
    }
    
    static testmethod void testOpptyArchiveSchedule1() {
        //Running the schedulable
        Test.startTest();     
        Batch_DealExpirationNotification opptyArchive = new Batch_DealExpirationNotification();
        Batch_DealExpirationNotificationExecute.executeBatch(opptyArchive);
        Test.stopTest();  
    }
}