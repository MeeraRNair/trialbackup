/* 10 -12-2018         Haribabu.A     STORY 5907651 Removed reference for the field direct_account_name__c */
@isTest
public class Vf_OpportunityAposproductpopupTest {
    @testSetup static void setup() {
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
        Sales_Channel_Group__c salesChannelGroup = new Sales_Channel_Group__c();
        salesChannelGroup.Name = 'Test Sales Channel';
        salesChannelGroup.Regional_Parent_Name__c = 'APJ';
        insert salesChannelGroup;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'End-User Account');
        listAccTdf[0].Account_Country__c = 'UNITED STATES';
        listAccTdf[0].Unassigned_End_User_Account__c =false;
        listAccTdf[0].Partner_Relationship__c='Preferred';
        listAccTdf[0].Is_GTM_Partner__c =true;
        listAccTdf[0].Sales_Channel__c = salesChannelGroup.Id;
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(2);
        listOppLineItemTdf[0].OpportunityId=listOppTdf[0].id;
        listOppLineItemTdf[1].OpportunityId=listOppTdf[0].id;
        insert listOppLineItemTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testmethod void testVfOpportunityAposproductpopup() {
        System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;
        list<Account> listAcc=[Select id from Account Limit 1];
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOpp=[Select id from Opportunity Limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        list<OpportunityLineItem> listOppLineItem=[Select id from OpportunityLineItem Limit 2];
        ApexPages.StandardController ctrl = new ApexPages.StandardController(listOpp[0]);
        Vf_OpportunityAposproductpopup opc = new Vf_OpportunityAposproductpopup(ctrl);
        opc.popupDisplay();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}