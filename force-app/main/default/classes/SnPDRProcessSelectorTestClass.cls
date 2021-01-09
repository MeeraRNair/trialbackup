/**
 * Name: SnPDRProcessSelectorTestClass
 * Author: Patrick Redor
 * Date: May 24,2012
 */
@isTest
private class SnPDRProcessSelectorTestClass {
    
    static testMethod void SnPDealRegistrationRProcessSelectorStressTestMethod() {
        
        Sales_Channel_Group__c testSCG = new Sales_Channel_Group__c (Name = 'Test SCG', Group_ID__c = '12345', 
                                                                            Segment_Name__c = 'FED');
        insert testSCG;
        
        Account acc = new Account(Name = 'Test Account', Sales_Channel__c = testSCG.Id);
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.id, CloseDate = System.today(), StageName = 'Plan - 1%', 
                                                CurrencyIsoCode = 'GBP');
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert opp;
        
        List<S_P_Vendors__c> svRecList = new List<S_P_Vendors__c>();
        List<S_P_Vendor_Automation__c> svAutomationList = new List<S_P_Vendor_Automation__c>();
        List<S_P_Vendor_Automation_Exception__c> svAutoExceptionList = new List<S_P_Vendor_Automation_Exception__c>();
        
        for(integer i = 1; i <= 120; i++){
            svRecList.add(new S_P_Vendors__c(Opportunity__c = opp.Id,
                    Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                    Customer_Name__c = 'test', Contact_Name__c = 'test', Phone__c = '9999999', 
                    Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
                    City__c = 'test', Zip__c = 'test', Total_NET__c = 76556, CurrencyIsoCode = 'GBP', 
                    Country__c = 'UNITED STATES', State__c = 'test', 
                    How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
                    'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'TestVendor' + i));
           svAutomationList.add(new S_P_Vendor_Automation__c(Vendor_Name__c = 'TestVendor' + i, Automation_Type__c = 'Full Automation', Is_Active__c = True));
        }
        
        insert svAutomationList;
        insert svRecList;
        
        for(S_P_Vendor_Automation__c svAuto : svAutomationList){
            svAutoExceptionList.add(new S_P_Vendor_Automation_Exception__c(Object_Name__c = 'S_P_Vendors__c', 
                                  Field_API_Name__c = 'Country__c', Is_Active__c = True, 
                                  Field_Name_Value__c = 'Japan', S_P_Vendor_Automation_ID__c = svAuto.Id));
        }
        insert svAutoExceptionList;
        
        Test.startTest();
            for(S_P_Vendors__c svRec : svRecList){
               //svRec.Is_this_an_ELA_Opportunity__c = 'Yes';
               svRec = SnPDealRegistrationProcessSelector.checkCommVaultFederal(svRec);
            }
            
            for(S_P_Vendor_Automation__c svAuto : svAutomationList){
               svAuto.Automation_Type__c = 'Partial Automation';
            }
            
            Database.update(svRecList);
            Database.update(svAutomationList);
        Test.stopTest();
    }

    static testMethod void SnPDealRegistrationRProcessSelectorTestMethod() {
    
        Opportunity opp = new Opportunity(Name = 'test', CloseDate = System.today(), StageName = 'Plan - 1%');
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);

        insert opp;
        
        S_P_Vendors__c svRec = new S_P_Vendors__c(Automated__c = false, Opportunity__c = opp.Id,
                    Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                    Customer_Name__c = 'test', Contact_Name__c = 'test', Phone__c = '9999999', 
                    Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
                    City__c = 'test', Zip__c = 'test', 
                    Country__c = 'UNITED STATES', State__c = 'test', 
                    How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
                    'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'VMware');
        
        S_P_Vendor_Automation__c svAutomation = new S_P_Vendor_Automation__c(Vendor_Name__c = 'TestVendor', 
                                                          Automation_Type__c = 'Full Automation', Is_Active__c = True);       
        insert svAutomation;
        insert svRec;
        
        S_P_Vendor_Automation_Exception__c svAutoException = new S_P_Vendor_Automation_Exception__c(Object_Name__c = 'S_P_Vendors__c', 
                                                          Field_API_Name__c = 'Country__c', Is_Active__c = True, 
                                                          Field_Name_Value__c = 'Japan', S_P_Vendor_Automation_ID__c = svAutomation.Id);
        insert svAutoException;
        
        // First Iteration: Full Automation and Active
        SnPDealRegistrationProcessSelector sps = new SnPDealRegistrationProcessSelector();
        sps.checkAutomation(svRec, svAutomation);
        
        svAutomation.Automation_Type__c = 'Partial Automation';
        update svAutomation;
        
        // Second Iteration: Partial Automation and Active
        sps.checkAutomation(svRec, svAutomation);
        
        svAutomation.Is_Active__c = false;
        update svAutomation;
        
        // Third Iteration: Partial Automation and Inactive
        sps.checkAutomation(svRec, svAutomation);
        
        svAutomation.Automation_Type__c = 'Full Automation';
        update svAutomation;
        
        // Fourth Iteration: Full Automation and Inactive
        sps.checkAutomation(svRec, svAutomation);
        
        // Reset
        svAutomation.Is_Active__c = true;
        update svAutomation;
        sps.checkAutomation(svRec, svAutomation);
        
        // Test for CommVault Federal checkbox
        // First Run
        SnPDealRegistrationProcessSelector.checkCommVaultFederal(svRec);
        
        // Locking of record
        svRec.S_P_Deal_Status__c = 'Sent to Vendor';
        update svRec;
                
        // Approved status test
        svRec.S_P_Deal_Status__c = 'Approved';
        svRec.Deal_Expiration_Date__c = System.today();
        svRec.Vendor_Approval_Number__c = 't3stV3ndo4Appr0va1N0';
        update svrec;        
        
        svRec.S_P_Deal_Status__c = 'Sent to Vendor';
        
        try {
            update svRec;
        } catch (DmlException e) {
            //Assert Status Code
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , 
                                 e.getDmlStatusCode(0) );
        }
    }
}