/*
REVISION HISTORY
================
Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           6-dec-2019          Implimented TestDataFactory        
*/
@isTest(seeAllData=false)
public class OppProdIncumbencyPopupCtrl_Test {
    Public static list<Account> listAcc;
    Public static list<Opportunity> listOpp;
    Public static list<OpportunityLineItem> listOppLineItem;
    @testSetup
    static void createTestData(){
        
        // Create common test OWD settings
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
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Account_VRs__c = true;
        insert vr;
        createCustomSetting();
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'End-User Account');
        listAccTdf[0].Networking__c=true;
        listAccTdf[0].CSG__c = true;
        listAccTdf[0].Server__c = true;
        listAccTdf[0].Storage__c = true;
        listAccTdf[0].CSG_Direct_Preference__c=false;
        insert listAccTdf;
        TriggerExecutionController.setSkipAllTriggers(True);
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountID=listAccTdf[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(True);
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItemTdf[0].OpportunityId=listOppTdf[0].Id;
        insert listOppLineItemTdf;
    }
    
    static void createCustomSetting(){
        insert new OpportunityProductIncumbencyCheck__c(showpopup__c=false,SetupOwnerId=UserInfo.getOrganizationId());
    }
    
    @isTest
    static void testAccountOppMistmatch(){
        
        PageReference pref = Page.OppProdIncumbencyPopup;
        Test.setCurrentPageReference(pref);
        
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        
        listOppLineItem=[SELECT ID,OpportunityId FROM OpportunityLineItem LIMIT 1];
        ApexPages.StandardController controller = new ApexPages.StandardController(listOpp[0]);
        
        OppProdIncumbencyPopup_Ctrl extension = new OppProdIncumbencyPopup_Ctrl(controller);
        extension.checkForEngageChannelPopUp_new(listOpp[0].id);
        
        Test.stopTest();
        
        system.assertEquals(listOpp[0].id,listOppLineItem[0].OpportunityId);
    }
    
    @isTest
    static void testAcceptanceCriteria(){
        PageReference pref = Page.OppProdIncumbencyPopup;
        Test.setCurrentPageReference(pref);
        
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        
        List<String> liststr=new List<String>{'Networking Product','Networking'};
            listOppLineItem=[SELECT ID,OpportunityId FROM OpportunityLineItem LIMIT 1];
        listOpp[0].Latest_product_id__c = listOppLineItem[0].id;
        
        update listOpp;
        ApexPages.StandardController controller = new ApexPages.StandardController(listOpp[0]);
        
        OppProdIncumbencyPopup_Ctrl extension = new OppProdIncumbencyPopup_Ctrl(controller);
        extension.removeNewlyAddedIds();
        
        Test.stopTest();
        system.assertEquals(listOpp[0].id,listOppLineItem[0].OpportunityId);
        
    }
    @isTest
    static void testMultipleIncumbencies(){
        
        PageReference pref = Page.OppProdIncumbencyPopup;
        Test.setCurrentPageReference(pref);
        
        List<Account> accList = [Select Id,CSG__c,Server__c,Storage__c from Account];
        
        
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        List<String> liststr=new List<String>{'Networking Product','Networking'};
            listOppLineItem=[SELECT ID,OpportunityId FROM OpportunityLineItem LIMIT 1];
        ApexPages.StandardController controller = new ApexPages.StandardController(listOpp[0]);
        OppProdIncumbencyPopup_Ctrl extension = new OppProdIncumbencyPopup_Ctrl(controller);
        Test.stopTest();
    }
}