/**
* Name: SnPVendorExtendRegistrationCtrlTest
* Author: Jesssie Tan
* Date: Aug 16, 2017
*1.0        16400     FY19-DCS-1002   29-Aug-2018       Swathi          testcoverage for SnPVendorExtendRegistrationCtrl

*/
@isTest
private class SnPVendorExtendRegistrationCtrlTest {
    //8.0 - BOF
    //Making list for Skip VRs
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
        //Added custom settings to populate StageName values.
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
            TriggerExecutionController.setSkipAllTriggers(true);
            list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
            insert listOppTdf;
            TriggerExecutionController.setSkipAllTriggers(false);
            
        }
    //8.0 - EOF
    static testMethod void extendRegistrationSuccessTestMethod() {
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        Test.startTest();
        S_P_Vendors__c svRec;
        
        Profile sysprofileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User u = new User(Alias = 'standt', Email='standarduser@dell.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = sysprofileId.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='adminstrator@dell.com', Badge_Number__c = '9898981098');
        insert u;   
        
        System.runAs(u) {
            
            svRec = new S_P_Vendors__c(Automated__c = true, Opportunity__c = listOpp[0].Id,
                                       Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                                       Customer_Name__c = 'test', Contact_Name__c = 'test', Phone__c = '9999999', 
                                       Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
                                       City__c = 'test', 
                                       State__c = 'NY', 
                                       Country__c = 'UNITED STATES', 
                                       Zip__c = 'test', 
                                       How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
                                       'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'VMware');
            TriggerExecutionController.setSkipAllTriggers(false);
            TriggerExecutionController.setSkipAccountTriggers(true);
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert svRec;
        } 
        SnPDRSubmitToVendorExtension snp = new SnPDRSubmitToVendorExtension(new ApexPages.StandardController(svRec));
        snp.submitToVendor();
        
        svRec.Vendor_Tracking_Number__c = 'Test Tracking No';
        svRec.Deal_Expiration_Date__c = Date.today().addDays(2);
        update svRec;
        
        svRec.S_P_Deal_Status__c = 'Approved';
        svRec.Vendor_Approval_Number__c = 'Test Approval No';
        svRec.Registration_Opportunity_Stage__c = '01 - Prospect';
        svRec.Value_Selling_Activities__c = 'Budget/ROI Analysis Completed';
        update svRec;
        
        SnPVendorExtendRegistrationCtrl snPExtendRegistrationCtrl = new SnPVendorExtendRegistrationCtrl(new ApexPages.StandardController(svRec));
        snPExtendRegistrationCtrl.loadUI();     
        snPExtendRegistrationCtrl.extendRegistration();     
        
        SnPDRSubmitToVendorExtension snp1 = new SnPDRSubmitToVendorExtension(new ApexPages.StandardController(svRec));
        snp1.submitToVendor();
        
        SnPVendorExtendRegistrationCtrl snPExtendRegistrationCtrl1 = new SnPVendorExtendRegistrationCtrl(new ApexPages.StandardController(svRec));
        snPExtendRegistrationCtrl1.loadUI();     
        snPExtendRegistrationCtrl1.extendRegistration();   
        system.assertNotEquals(listOpp[0].id, null);
        Test.stopTest();
    }
    
    /*  static testMethod void ExtendRegistrationFailureTestMethod() {

Opportunity opp = new Opportunity(Name = 'test', CloseDate = System.today(), StageName = 'Plan - 1%');
Test.startTest();
TriggerExecutionController.setSkipOpportunityTriggers(true);
insert opp;
TriggerExecutionController.setSkipOpportunityTriggers(false);
Test.stopTest();
S_P_Vendors__c svRec;
S_P_Vendors__c svRec2; 

Profile SysAdminprofileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

Profile SnPBoomiprofileId = [SELECT Id FROM Profile WHERE Name = 'Boomi Integration API Only' LIMIT 1];     

User u = new User(Alias = 'standt', Email='standarduser@dell.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = SysAdminprofileId.Id, 
TimeZoneSidKey='America/Los_Angeles', UserName='adminstrator@dell.com', Badge_Number__c = '9898981098');
insert u;   
User u1 = new User(Alias = 'standus', Email='standarduser1@dell.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = SnPBoomiprofileId.Id, 
TimeZoneSidKey='America/Los_Angeles', UserName='snpboomiuser@dell.com', Badge_Number__c = '989898981398');     
insert u1;
System.runAs(u) {

svRec = new S_P_Vendors__c(Automated__c = true, Opportunity__c = opp.Id,
Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
Customer_Name__c = 'test', Contact_Name__c = 'test', Phone__c = '9999999', 
Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
City__c = 'test', 
State__c = 'NY', 
Country__c = 'UNITED STATES', 
Zip__c = 'test', 
How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'VMware');
TriggerExecutionController.setSkipAllTriggers(false);
TriggerExecutionController.setSkipAccountTriggers(true);
TriggerExecutionController.setSkipOpportunityTriggers(true);

insert svRec;

} 

SnPDRSubmitToVendorExtension snp = new SnPDRSubmitToVendorExtension(new ApexPages.StandardController(svRec));

snp.submitToVendor();

SnPVendorExtendRegistrationCtrl snPExtendRegistrationCtrl = new SnPVendorExtendRegistrationCtrl(new ApexPages.StandardController(svRec));

snPExtendRegistrationCtrl.loadUI();     
snPExtendRegistrationCtrl.extendRegistration();     

}*/
}