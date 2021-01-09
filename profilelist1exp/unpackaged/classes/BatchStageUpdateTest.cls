/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
private class BatchStageUpdateTest {
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1,'Deal Registration');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        list<Opportunity> listOppTdf1=TestDataFactory.createNOpportunities(1,'Deal Registration-Submitted');
        listOppTdf1[0].AccountId=listAccTdf[0].id;
        insert listOppTdf1;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void myUnitTest() {
        /*  Account testAccount=new Account(Name='testAccount',
RecordTypeId= PageUtils.getRecordTypeId('Account', 'Partner Account', true));
insert testAccount;
*/
        // Date ToDay  =date.today()-40;
        
        /*   Opportunity testOpportunity1=new Opportunity(RecordTypeId= PageUtils.getRecordTypeId('Opportunity','Deal Registration', true), 
Name='Test Opportunity1',
AccountId= testAccount.Id,
StageName='Plan - 1%',
Region__c='ABU',
Probability =0.0,
Partner_Opportunity_Stage__c='Plan - 1%',
CloseDate = system.today()+10,
Deal_Registration_status__c='New');
insert testOpportunity1;
Opportunity testOpportunity2=new Opportunity(RecordTypeId= PageUtils.getRecordTypeId('Opportunity', 'Deal Registration-Submitted', true), 
Name='Test Opportunity2', 
StageName='Plan - 1%' ,
Region__c='ABU',
CloseDate = system.today()+10,
Deal_Expiration_Date__c= ToDay,
Deal_Registration_status__c='Rejected',
AccountId= testAccount.Id);
insert testOpportunity2;
*/
        Opportunity testOpportunity1=[select id from Opportunity where Recordtype.name='Deal Registration' Limit 1];
        Opportunity testOpportunity2=[select id from Opportunity where Recordtype.name='Deal Registration-Submitted' Limit 1];
        system.assertNotEquals(testOpportunity1.id, null);
        Test.startTest(); 
        BatchStageUpdate batchObj = new BatchStageUpdate();
        batchObj.setTest();
        batchObj.query = 'SELECT Id,RecordTypeId,Name,Competitor_Lost_To__c,StageName,Deal_Registration_status__c FROM Opportunity WHERE StageName!=\'Lost-Cancelled-0%\'AND Deal_Registration_status__c=\'New\'';
        
        Id batchprocessid = database.executebatch(batchObj,1);
        //System.debug('------'+[SELECT Name,StageName from Opportunity where StageName='Lost, Cancelled - 0%']);
        Test.stopTest();
        //System.AssertEquals(database.countquery('SELECT count() FROM Opportunity Where StageName=\'Lost, Cancelled - 0%\''), 1);
        // System.AssertEquals(database.countquery('SELECT count() FROM Opportunity Where Partner_Opportunity_Stage__c=\'Lost, Cancelled - 0%\''), 1);
    }
}