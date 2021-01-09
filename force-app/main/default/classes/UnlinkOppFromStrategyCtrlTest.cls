@isTest(seeAllData=false)
private class UnlinkOppFromStrategyCtrlTest {
    @testSetup static void setup() {
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
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        system.assertEquals('Qualify - 30%',owdSetting.Oppty_Stage30__c );
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        //query user 
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        //insert Account Plan record        
        id apRtId= schema.SObjectType.SFDC_Acct_Plan__c.getRecordTypeInfosByName().get('Direct Relationship Account Plan').getRecordTypeId();
        SFDC_Acct_Plan__c testAP = new SFDC_Acct_Plan__c (RecordTypeId = apRtId, Name = 'Test Account Plan', Account__c = listAccTdf[0].Id, Sales_Manager__c = user.Id);
        insert testAP;
        //insert strategy record
        SFDC_Strategy__c testST 
            = new SFDC_Strategy__c (Name = 'Test Strategy', Strategy_Owner__c = user.Id, SFDC_Acct_Plan__c = testAP.Id,
                                    Enterprise_Business_Issue__c = 'Test Customer Objective', IT_Implications__c = 'Test IT Implications',
                                    Dell_s_Strategy_Response__c = 'Test Dell s Strategy response', When_do_you_plan_to_realize_Strategy__c = '1st Q (This FY)', 
                                    Region__c = 'APJ', Which_LOB_will_you_offer__c = 'Services', Potential_Strategy_Value__c = 10,
                                    Strengths__c = 'Test Strengths', Threats__c = 'Test Threats');
        insert testST;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].accountId=listAccTdf[0].id;
        listOppTdf[0].Related_Strategy__c = testST.Id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void unlinkOppFromStrategySuccessfully() {
        Test.startTest();    
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        UnlinkOppFromStrategyCtrl controller = new UnlinkOppFromStrategyCtrl (new ApexPages.StandardController(listOpp[0])); 
        controller.unlink();
        system.assertNotEquals(listOpp[0].id, null);
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();  
    }
    
    static testMethod void unlinkOppFromStrategyWithErrors() {
        Test.startTest();    
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        UnlinkOppFromStrategyCtrl controller = new UnlinkOppFromStrategyCtrl (new ApexPages.StandardController(listOpp[0])); 
        controller.unlink();
        controller.handleError(new TestException('This is test exception'));
        controller.back();
        system.assertNotEquals(listOpp[0].id, null);
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();  
    }
    public class TestException extends Exception {}
}