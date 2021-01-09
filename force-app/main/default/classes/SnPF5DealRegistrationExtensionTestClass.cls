/**
* Name: SnPF5DealRegistrationExtensionTestClass
* Author: Patrick Redor
* Date: May 20, 2013
* Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           6-dec-2019          Implimented TestDataFactory        
*/
@isTest
private class SnPF5DealRegistrationExtensionTestClass {  
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
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }   
    static testMethod void snPF5DealRegistrationExtensionTestMethod(){
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        S_P_Vendor_Automation__c svAuto = new S_P_Vendor_Automation__c(Vendor_Name__c = 'F5', Automation_Type__c = 'Full Automation',
                                                                       Vendor_URL__c = 'https://test.salesforce.com/');
        insert svAuto;
        Sales_Channel_Group__c testSCG = new Sales_Channel_Group__c (Name = 'Test SCG', Group_ID__c = '12345', 
                                                                     Segment_Name__c = '');
        insert testSCG;
        list<Account> listAcc=[SELECT ID FROM Account LIMIT 1];
        listAcc[0].Sales_Channel__c = testSCG.Id;
        listAcc[0].Account_Country__c = 'UNITED STATES';
        update listAcc;
        list<Opportunity> listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        system.assertNotEquals(listOpp[0].id, null);
        list<OpportunityLineItem> listOppLineItem=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItem[0].OpportunityId=listOpp[0].id;
        insert listOppLineItem;
        S_P_Vendors__c sv = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id,
                                               Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                                               Customer_Name__c = 'test', Contact_Name__c = 'test test', Phone__c = '9999999', 
                                               Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
                                               City__c = 'test', Zip__c = 'test', Total_NET__c = 76556, 
                                               Country__c = 'UNITED STATES', State__c = 'FL', 
                                               CurrencyIsoCode = 'USD', Distributor_Name__c = 'Ingram Micro',
                                               How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
                                               'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'F5',
                                               Website__c = 'www.google.com', Industry__c = 'Gove - Federal', Product_Type__c = 'Software Module',
                                               Application_Vendor__c = 'BMC', Estimated_Closed_Date__c = '31-60 Days', Business_Type__c = 'New business', 
                                               Lead_Source__c = 'Other', Project_Description__c = 'test description'); 
        insert sv;
        SnPF5DealRegistrationExtension snpF5DR = new SnPF5DealRegistrationExtension(new ApexPages.StandardController(sv));
        System.debug('*** TEST PAT *** ' + snpF5DR.getGeneratedF5URL());
        listOpp[0].Primary_Product_Delivery_Address_Region__c = 'EMEA';
        testSCG.Segment_Name__c = 'BSD';
        listOpp[0].Primary_Product_Delivery_Address_Region__c = 'LATAM';
        listOpp[0].Primary_Product_Delivery_Address_Region__c = 'APJ';
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}