@isTest
private class BatchDealLostCancelTest {
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(2,'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Deal Registration-Submitted');
        insert listOppTdf;
    }
    static testMethod void testpartnerAccount() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc=[SELECT ID FROM Account LIMIT 2];
        listAcc[1].Type = 'Partner';
        update listAcc; 
        list<Opportunity> listOpp=[SELECT ID FROM Opportunity LIMIT 2];
        for(Opportunity opp : listOpp){
            opp.AccountID=listAcc[1].id;
            opp.StageName = 'Plan - 1%';
            opp.Request_Status__c='Submitted';
        }
        listOpp[1].RecordtypeId=TestDataFactory.getRecordTypeIdbyName('Deal Registration', 'Opportunity');
        listOpp[0].Deal_Registration_Status__c= 'Rejected';
        listOpp[1].Deal_Registration_Status__c= 'New';
        update listOpp;
        Test.startTest();
        BatchDealLostCancel batchObj = new BatchDealLostCancel();
        batchObj.setTest();
        batchObj.query = 'SELECT Id,RecordTypeId,Name,Competitor_Lost_To__c,StageName,Deal_Registration_status__c FROM Opportunity WHERE StageName!=\'Lost-Cancelled-0%\'AND Deal_Registration_status__c=\'New\'';
        Id batchprocessid = database.executebatch(batchObj,1);
        Test.stopTest();
        System.AssertNotEquals(database.countquery('SELECT count() FROM Opportunity Where StageName=\'Lost, Cancelled - 0%\''), 1);
    }
    static testMethod void  batchDealLostCancelScheduleTest() {
        Test.StartTest();
        BatchDealLostCancelSchedule sh1 = new BatchDealLostCancelSchedule();      
        String strsch = '0 0 23 * * ?';
        system.schedule('Test check', strsch, sh1);
        system.assertNotEquals(strsch, null);
        Test.stopTest();
    }
}