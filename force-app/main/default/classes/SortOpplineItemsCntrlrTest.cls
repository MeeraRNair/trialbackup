/*
REVISION HISTORY
================
Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           30-10-2019          Implimented TestDataFactory        
*/
@isTest(SeeAlldata =false)
private class SortOpplineItemsCntrlrTest {
    @testSetup static void setup(){
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;

        TriggerExecutionControl__c oTec = new TriggerExecutionControl__c();
        oTec.Name = 'Opportunity';
        oTec.RecursiveCount__c = 2;
        insert oTec;

        TriggerExecutionControl__c oliTect = new TriggerExecutionControl__c();
        oliTect.Name = 'OpportunityLineItem';
        oliTect.RecursiveCount__c = 2;
        insert oliTect;

        TriggerExecutionController.setSkipAllTriggers(true);

        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration-Submitted');
        listOppTdf[0].AccountId=listAccTdf[0].Id;
        insert listOppTdf;
        list<OpportunityLineItem> listOppLineItemtdf=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItemtdf[0].Opportunityid=listOppTdf[0].id;
        insert listOppLineItemtdf;
        
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testSortOpplineItemsCntrlr () {
        test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        list<OpportunityLineItem> listOppLineItem=[select id from OpportunityLineItem Limit 1];
        test.stopTest();
        SortOpplineItemsCntrlr oppR = New SortOpplineItemsCntrlr ();
        oppR.thisOpportunityId = listOpp[0].id;
        oppR.getSorted();
    }
}