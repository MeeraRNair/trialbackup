/**
* Name: SnPDRSubmitToVendorExtensionTestClass
* Author: Patrick Redor
* Date: May 23,2012
*/
@isTest
private class SnPDRSubmitToVendorExtensionTestClass {
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
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
        insert listOppTdf;
    }
    static testMethod void snpdrSubmitToVendorExtensionTestMethod() {
        Test.startTest();
        S_P_Vendors__c svRec;
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        
        Profile sysAdminprofileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@dell.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = sysAdminprofileId.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='adminstrator@dell.com', Badge_Number__c = '9898981098');
        insert u;   
        System.runAs(u) {
            svRec = new S_P_Vendors__c(Automated__c = false, Opportunity__c = listOpp[0].Id,
                                       Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                                       Customer_Name__c = 'test', Contact_Name__c = 'test', Phone__c = '9999999', 
                                       Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
                                       City__c = 'test', 
                                       State__c = 'NY', 
                                       Country__c = 'UNITED STATES', 
                                       Zip__c = 'test', 
                                       How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
                                       'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'Commvault');
            TriggerExecutionController.setSkipAllTriggers(false);
            TriggerExecutionController.setSkipAccountTriggers(true);
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert svRec;
        }
        system.assertNotEquals(listOpp[0].id, null);
        Test.stopTest();
        SnPDRSubmitToVendorExtension snp = new SnPDRSubmitToVendorExtension(new ApexPages.StandardController(svRec));
        snp.submitToVendor();
        snp.getSvRec().Automated__c = true;
        snp.getSvRec().S_P_Deal_Status__c = 'Sent to Vendor';
        snp.submitToVendor();
        snp.getSvRec().S_P_Deal_Status__c = 'Approved';
        snp.getSvRec().Deal_Expiration_Date__c = System.today();
        snp.getSvRec().Vendor_Approval_Number__c = 't3stV3ndo4Appr0va1N0';
        snp.submitToVendor();        
        snp.getSvRec().Automated__c = true;
        snp.getSvRec().S_P_Deal_Status__c = 'Pending';
        snp.submitToVendor();
        snp.getSvRec().Contact_Name__c = null;
        snp.getSvRec().Customer_Name__c = null;
        snp.submitToVendor();
        snp.setController(snp.getController()); 
        snp.setSvRec(snp.getSvRec());
    }
}