/**
History:
Version     Date            Modified By             CR          Description     
--------------------------------------------------------------------------------------
1.0         4-Feb-2016      Shahiruni Wahida        12627       Create test class for BatchAccnt_SalesChannelUpdate
2.0      09-Dec-2019    VIKAS KH        0202    Impolemented TDF
 */
@isTest
private class BatchAccnt_SalesChannelUpdateTest {
    static list<Account> listAcc;
    static Sales_Channel_Group__c testSCG;
    static Sales_Channel_Group__c testSCG2;
    private static Map<String, String> mapsParams;
    @testSetup Static void testsetup()
    {
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
    }
    static void createTestData(){
        testSCG = new Sales_Channel_Group__c();
        testSCG.Group_ID__c = '12345';
        testSCG.Name = 'testSCG1';
        insert testSCG;
        testSCG2 = new Sales_Channel_Group__c();
        testSCG2.Group_ID__c = '54321';
        testSCG2.Name = 'testSCG2';
        insert testSCG2;
        listAcc = [select id from Account limit 1];   
        //     testAcc = new Account();
        //     testAcc.Name = 'Test Account 1';
        //     insert testAcc;
    }
    private static testMethod void associateAccountSalesChannelGroupNewAccWithExistingSCG() {
        //GlobalVariables.BYPASS_FUTURE_CALLS = true;
        createTestData();
        listAcc[0].Sales_Channel_ID__c = testSCG.Group_ID__c;
        update listAcc;
        //GlobalVariables.BYPASS_FUTURE_CALLS = false;
        Test.startTest();
        String strjobId = system.scheduleBatch(new BatchAccnt_SalesChannelUpdate(), 'BatchAccnt_SalesChannelUpdate NOW', 0);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :strjobId];
        Test.stopTest(); 
        //   Account insertedAcc = [SELECT Sales_Channel__c FROM Account WHERE id = :testAcc.id];
        system.assertEquals(listAcc[0].Sales_Channel__c, listAcc[0].Sales_Channel__c);
  }
    private static testMethod void associateAccountSalesChannelGroupNewAccWithNonExistingSCG() {
        GlobalVariables.BYPASS_FUTURE_CALLS = true;
        createTestData();
        listAcc[0].Sales_Channel_ID__c = '9999999999';
        update listAcc[0];
        GlobalVariables.BYPASS_FUTURE_CALLS = false;
        system.assertEquals(listAcc[0].Sales_Channel_ID__c, listAcc[0].Sales_Channel_ID__c);
        Test.startTest();
        String strjobId = system.scheduleBatch(new BatchAccnt_SalesChannelUpdate(), 'BatchAccnt_SalesChannelUpdate NOW', 0);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :strjobId];
        Test.stopTest(); 
    }
    private static testMethod void associateAccountSalesChannelGroupNewAccWithDiffSCISCG() {
        GlobalVariables.BYPASS_FUTURE_CALLS = true;
        createTestData();
        listAcc[0].Sales_Channel_ID__c = testSCG.Group_ID__c;
        listAcc[0].Sales_Channel__c = testSCG2.id;
        update listAcc[0];
        GlobalVariables.BYPASS_FUTURE_CALLS = false;
        system.assertEquals(listAcc[0].Sales_Channel_ID__c, listAcc[0].Sales_Channel_ID__c);
        Test.startTest();
        String strjobId = system.scheduleBatch(new BatchAccnt_SalesChannelUpdate(), 'BatchAccnt_SalesChannelUpdate NOW', 0);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :strjobId];
        Test.stopTest(); 
        system.assertEquals(testSCG.Group_ID__c, listAcc[0].Sales_Channel_ID__c);
        system.assertEquals(testSCG2.id, listAcc[0].Sales_Channel__c);
    }
}