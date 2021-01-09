@isTest(SeeAllData=true)
private class SnP_MSThresholdRecalcButtonCntrlrTest{
	static testMethod void SnP_MSThresholdRecalcButtonControllerTest1(){
        Account acc = new Account(Name = 'Test Account');
        Database.insert(acc);
        
        Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%',
                                          CurrencyIsoCode = 'USD');
        Database.insert(opp);
        
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = opp.Id, How_did_you_uncover_this_opportunity__c = 'sample',
            Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
            One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
            Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
            Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
            Software_Licensing_Specialist__c = 'sample',    Is_this_an_Enterprise_Agreement__c = 'Yes');
    
        Database.insert(mainSV);
        
        S_P_Vendor_Additional_Information__c addlInfoEa = new S_P_Vendor_Additional_Information__c(Total__c = 1000,
      		SIP_Threshold_Met__c = 'No', Deal_Reg_Status__c = 'Incomplete', Agreement_Level__c = 'A1', Level__c = 'EA', 
            EA_Fees_Total__c = 1000, SnP_Vendor_ID__c = null, Products_Included__c = null,
			S_P_Vendors_ID__c = mainSv.Id , CurrencyIsoCode = 'HKD');
        
        Database.insert(addlInfoEa);
        
        Exception__c exceptionVar = new Exception__c();        
        exceptionVar.Object_type__c = 'S&P Vendor Additional Information';
        exceptionVar.Object_ID__c = addlInfoEa.Id;
        exceptionVar.Operation__c = 'Update';
        exceptionVar.Title__c = addlInfoEa.Agreement_Level__c;
        exceptionVar.Process_Name__c = 'Microsoft Recalculation';
        exceptionVar.Email__c = 'test';
        exceptionVar.Error_Messages__c = 'test';
        exceptionVar.Notes__c = 'test';
        
        Database.insert(exceptionVar);
        
        S_P_Vendor_Product_Threshold__c thresh1 = new S_P_Vendor_Product_Threshold__c(Agreement_Level__c = 'A1', Level__c = 'EA', /*Minimum_Revenue__c = 10000,*/ 
            Percentage__c = 10, /*Product_Description__c = '', Product_Family__c = '',*/ Threshold_Required__c = TRUE);
        
        Database.insert(thresh1);
        
        Test.startTest();
        ApexPages.StandardController ms = new ApexPages.StandardController(thresh1);
        SnP_MSThresholdRecalcButtonController sc = new SnP_MSThresholdRecalcButtonController(ms);
        PageReference recalc = Page.SnPMSThresholdRecalcButtonPage;
        Test.setCurrentPageReference(recalc);
        Test.stopTest();
        
        sc.goBack();
        
    }
    
    static testMethod void SnP_MSThresholdRecalcButtonControllerTest2(){
    	Account acc = new Account(Name = 'Test Account');
        Database.insert(acc);
        
        Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%',
                                          CurrencyIsoCode = 'USD');
        Database.insert(opp);
        
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = opp.Id, How_did_you_uncover_this_opportunity__c = 'sample',
            Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
            One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
            Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
            Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
            Software_Licensing_Specialist__c = 'sample',    Is_this_an_Enterprise_Agreement__c = 'Yes');
    
        Database.insert(mainSV);
        
        
        S_P_Vendor_Additional_Information__c addlInfoProd = new S_P_Vendor_Additional_Information__c(Total__c = 1000,
      		SIP_Threshold_Met__c = 'No', Deal_Reg_Status__c = null, Agreement_Level__c = null, Level__c = 'Product', 
            EA_Fees_Total__c = null, SnP_Vendor_ID__c = null, Products_Included__c = 'VDI',
			S_P_Vendors_ID__c = mainSv.Id, CurrencyIsoCode = 'HKD');
        
        Database.insert(addlInfoProd);
        
        S_P_Vendor_Product_Selection__c prodSel = new S_P_Vendor_Product_Selection__c(Total__c = 1000, SIP_Fees__c = 1000, 
        	SIP_Incentive__c = 'Windows 7', New_Products_Only__c = 'Windows', 
            S_P_Vendor_Additional_Information_ID__c = addlInfoProd.Id);
        
        Database.insert(prodSel);
        
        Exception__c exceptionVar = new Exception__c();        
        exceptionVar.Object_type__c = 'S&P Vendor Additional Information';
        exceptionVar.Object_ID__c = addlInfoProd.Id;
        exceptionVar.Operation__c = 'Update';
        exceptionVar.Title__c = 'Windows 7';
        exceptionVar.Process_Name__c = 'Microsoft Recalculation';
        exceptionVar.Email__c = 'test';
        exceptionVar.Error_Messages__c = 'test';
        exceptionVar.Notes__c = 'test';
        
        Database.insert(exceptionVar);
        
        Exception__c exceptionVar1 = new Exception__c();        
        exceptionVar1.Object_type__c = 'S&P Vendor Product Selection';
        exceptionVar1.Object_ID__c = prodSel.Id;
        exceptionVar1.Operation__c = 'Update';
        exceptionVar1.Title__c = 'Windows 7';
        exceptionVar1.Process_Name__c = 'Microsoft Recalculation';
        exceptionVar1.Email__c = 'test';
        exceptionVar1.Error_Messages__c = 'test';
        exceptionVar1.Notes__c = 'test';
        
        Database.insert(exceptionVar1);
        
        
        S_P_Vendor_Product_Threshold__c thresh2 = new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
            Percentage__c = 10, Product_Description__c = 'Windows', Product_Family__c = 'Windows 7', Threshold_Required__c = TRUE);
        
        Database.insert(thresh2);
        
        Test.startTest();
        ApexPages.StandardController ms = new ApexPages.StandardController(thresh2);
        SnP_MSThresholdRecalcButtonController sc = new SnP_MSThresholdRecalcButtonController(ms);
        PageReference recalc = Page.SnPMSThresholdRecalcButtonPage;
        Test.setCurrentPageReference(recalc);
        Test.stopTest();
        
        sc.goBack();
    }
}