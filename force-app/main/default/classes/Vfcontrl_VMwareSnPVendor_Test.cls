/*History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0     21-July-2016    Kenny           CR13257 - VMware: auto-display VMware Products within S&P Vendor record with additional info
2.0     03-July-2017    Jessie          Add Product_ID__c to avoid test errors happened during the development/deployment of CR14564 (VMware API – Add Discount %)
*/

@isTest
private class Vfcontrl_VMwareSnPVendor_Test{
    @testSetup static void setup() {
        OWD__c owdsetting = new OWD__c();
        owdsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdsetting.Oppty_Stage10__c = 'Discover - 10%';
        owdsetting.Oppty_Stage100__c = 'Win - 100%';
        owdsetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdsetting.Oppty_Stage60__c = 'Propose - 60%';
        owdsetting.Oppty_Stage90__c = 'Commit - 90%';
        owdsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItemTdf[0].OpportunityId=listOppTdf[0].id;
        insert listOppLineItemTdf;
    }   
    
    private static testMethod void vfcontrlVMwareSnPVendorTestMethod() {
        
        TriggerExecutionController.setSkipAllTriggers(true); 
        list<Opportunity> listOpp=[Select id from Opportunity Limit 1];
        list<OpportunityLineItem> listOppLineItem=[Select id from OpportunityLineItem Limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        S_P_Vendors__c sv = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id,
                                               Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                                               Customer_Name__c = 'testvmware', Contact_Name__c = 'testvmware', Phone__c = '1234567', 
                                               Email__c = 'testvmware@dell.com', Role__c = 'testvmware', Ship_to_Address__c = 'testvmware', 
                                               City__c = 'testvmware', Zip__c = 'testvmware', Total_NET__c = 76556, 
                                               Country__c = 'UNITED STATES', State__c = 'FL', 
                                               CurrencyIsoCode = 'USD', 
                                               How_did_you_uncover_this_opportunity1__c = 'testvmware', Sales_Activities_to_Date__c = 
                                               'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'Testvmware'); 
        insert sv;      
        
        TriggerExecutionController.setSkipAllTriggers(false); 
        
        Test.startTest();
        
        Apexpages.StandardController stdController = new Apexpages.StandardController(sv); 
        Vfcontrl_VMwareSnPVendor opp1 = new Vfcontrl_VMwareSnPVendor(StdController);
        
        PageReference pageRef = Page.SnPDisplayVMware;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',sv.Id);
        
        opp1.displayVMware();
        
        Test.stopTest();            
    }
}