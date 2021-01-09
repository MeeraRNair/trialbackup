/*
REVISION HISTORY
================
Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           23-11-2019         Implimented TestDataFactory        
*/
@isTest
private class SnP_ContactSelectionCntrlrTest {
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].accountId=listAccTdf[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }    
    static testMethod void testWithContact(){
        triggerexecutioncontroller.setSkipAllTriggers(true);
        test.startTest();
        list<Account> listAcc=[select id from Account Limit 1];
        Contact cont = new Contact(FirstName = 'Jackson', LastName = 'Teller' , Job_Function_Role__c = 'Others', 
                                   Phone = '000000', Email = 'jteller@testing.com', 
                                   AccountId = listAcc[0].Id);
        insert cont;
        
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        S_P_Vendors__c sv = new S_P_Vendors__c(Automated__c = false, Opportunity__c = listOpp[0].Id,
                                               Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                                               Customer_Name__c = 'test', Contact_Name__c = 'test', Phone__c = '9999999', 
                                               Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
                                               City__c = 'test', Zip__c = 'test', Title__c = 'trewr',
                                               Country__c = 'UNITED STATES', State__c = 'test', Website__c = 'te.com',
                                               Expected_Close_Date__c = system.today(), Project_Description__c = 'test',
                                               Deal_Size__c = 50, 
                                               How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
                                               'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'VMware');
        
        insert sv;
        triggerexecutioncontroller.setSkipAllTriggers(false);
        SnP_ContactSelectionCntrlr svCont = new SnP_ContactSelectionCntrlr(new ApexPages.StandardController(sv));
        svCont.redirect();
        svCont.goToContactSelection();
        svCont.acctId = listAcc[0].Id;
        svCont.searchString = 'test';
        svCont.doSearch(); 
        svCont.contactInfo = '';
        svCont.doSelect();
        svCont.contactInfo = svCont.getContactWrapperList().get(0).contWrap.Id;
        svCont.doSelect();
        svCont.next();
        svCont.previous();
        svCont.getContactWrapperList();
        test.stopTest();
    }
}