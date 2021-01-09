@isTest(SeeAllData=true)
private class SOM_BatchTest {

static testMethod void SOM_GroupBatchTest() {

 List <SOM_Boomi_Log__c> logList = new  List <SOM_Boomi_Log__c>();

 for (Integer i = 0 ; i<10;i++){

 SOM_Boomi_Log__c logRecord = new SOM_Boomi_Log__c (Status__c = 'Pending');
 logList.add(logRecord);
 }
 insert logList;

 Test.startTest();
        String CRON_EXP = '0 0 0 * * ?';
        SOM_BoomiLogScheduler sch = new SOM_BoomiLogScheduler();
        String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest(); 
}
}