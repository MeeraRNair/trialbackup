@isTest
public class DSAUtilsTest{
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c(); 
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert oWDsetting;
        TriggerExecutionController.setSkipAllTriggers(true); 
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        insert listOppTdf;
        
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItemTdf[0].OpportunityId=listOppTdf[0].id;
        insert listOppLineItemTdf;
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
    static testMethod void applyDiscountForDSAOpportunities_Test(){      
        list<OpportunityLineItem> listOppLineItem=[SELECT ID,Opportunityid,pricebookEntryId FROM OpportunityLineItem LIMIT 1];
        Test.StartTest();
        OpportunityLineItem  testLineItemUpd = new OpportunityLineItem(Id=listOppLineItem[0].Id,Discount=0, Opportunityid =listOppLineItem[0].Opportunityid,pricebookEntryId=listOppLineItem[0].pricebookEntryId,Mrgn__c =6,DSA_API_Update__c=true,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1',DPID__c ='0198',Quote__c ='2345');   
        
        Test.StopTest();
    }
}