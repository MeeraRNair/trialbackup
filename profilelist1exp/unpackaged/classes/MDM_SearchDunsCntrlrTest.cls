@isTest
private class MDM_SearchDunsCntrlrTest {
	
	private static testMethod void testSearchByIdAndName() {
		list<Account> lstAccounts = new list<Account>();
	   	for(Integer i = 0; i<10; i++) {
	    	lstAccounts.add(new Account(Name = 'Tester'+i, Account_ID__c = '12345'+i, Account_Country_Code__c = 'US', ShippingCity = 'Testcity', ShippingState  = 'Teststate', ShippingPostalCode = 'US', ShippingCountry = 'US'));
	    }
	    insert lstAccounts;
	    
		Account accInstance = new Account(Name = 'Tester', Account_Country_Code__c = 'US', ShippingCity = 'Testcity', ShippingState = 'Teststate', ShippingPostalCode = 'US', ShippingCountry = 'US');
	   	insert accInstance;
	   	
	    list<Country__c> lstCountries = new list<Country__c>();
	    lstCountries.add(new Country__c(Name = 'United States', Code__c = 'US', Region__c = 'LATAM', DNB_ISO_Country_Code__c = 'US', DNB_Country_Code__c = 'US', DNB_Region__c = 'AMER'));
	    lstCountries.add(new Country__c(Name = 'India', Code__c = 'IN', DNB_ISO_Country_Code__c = 'IN', DNB_Country_Code__c = 'IN'));
	    insert lstCountries;
	   	
	    Test.startTest();
	    
	    PageReference pageRef = new PageReference('/apex/MDM_SearchDunsPage?close='+true);
	    Test.setCurrentPage(pageRef);
	    ApexPages.StandardController stdController;
	    MDM_SearchDunsCntrlr mdmController;
	    
	    // Search by Id
	    stdController = new ApexPages.StandardController(lstAccounts[0]);
	    mdmController = new MDM_SearchDunsCntrlr(stdController);
	    for(Integer i=1; i<10; i++) {
            stdController = new ApexPages.StandardController(lstAccounts[i]);
            ApexPages.currentPage().getParameters().put('newid', lstAccounts[i].Id);
            
            Test.setMock(HttpCalloutMock.class, new MDM_SearchDunsHttpResponseGenerator());
            mdmController = new MDM_SearchDunsCntrlr(stdController);
            mdmController.selectedDuns();
            mdmController.searchMethod = 'Duns Number' + 'Affinity ID' + 'Customer Number' + 'DUNS Name' + 'Country' + 'State' + 'City' + 'Postal Code' + 'BUID' + 'Region';
            mdmController = new MDM_SearchDunsCntrlr(stdController);
        }
        
        
        // Search by Name
        pageRef = new PageReference('/apex/MDM_SearchDunsPage?close='+true);
	    Test.setCurrentPage(pageRef);
	    stdController = new ApexPages.StandardController(accInstance);
	    
	    // To cover AccountId = null scenario
	    mdmController = new MDM_SearchDunsCntrlr(stdController);
	    
        ApexPages.currentPage().getParameters().put('Id', accInstance.Id);
        Test.setMock(HttpCalloutMock.class, new MDM_SearchDunsHttpResponseGenerator());
        
        mdmController.showDunsName = false;
        mdmController.showCountry = false;
        mdmController.showPostalCode = false;
        mdmController.iDunsName = null;
        mdmController.iCountry = null;
        mdmController.iPostalCode = null;
        
		mdmController.showDunsNumber = true;
        mdmController.iDunsId = null;
        mdmController.callMDM();
        mdmController.showDunsNumber = false;
        
        mdmController.showAffinity = true;
        mdmController.iAffinityId = null;
        mdmController.callMDM();
        mdmController.showAffinity = false;
        
        mdmController.showCusNum = true;
        mdmController.iCustNum = null;
        mdmController.callMDM();
        mdmController.showCusNum = false;
        
        mdmController.showBUID = true;
        mdmController.iBUID = null;
        mdmController.callMDM();
        mdmController.showBUID = false;
        
        mdmController.showDunsName = true;
        mdmController.iDunsName = null;
        mdmController.callMDM();
        mdmController.showDunsName = false;
        
        mdmController.showCountry = true;
        mdmController.iCountry = null;
        mdmController.callMDM();
        mdmController.showCountry = false;
        
        mdmController.showState = true;
        mdmController.iState = null;
        mdmController.callMDM();
        mdmController.showState = false;
        
        mdmController.showPostalCode = true;
        mdmController.iPostalCode = null;
        mdmController.callMDM();
        mdmController.showPostalCode = false;
        
        mdmController.showCity = true;
        mdmController.iCity = null;
        mdmController.callMDM();
        mdmController.showCity = false;

		mdmController.showRegion = true;
        mdmController.iRegion = null;
        mdmController.callMDM();
        mdmController.showRegion = false;
        
        mdmController.iDunsId = 'abcdefg';
        mdmController.callMDM();
        mdmController.iDunsId = null;
        
        mdmController.iAffinityId = 'abcdefg';
        mdmController.callMDM();
        mdmController.iAffinityId = null;
        
        mdmController.iCustNum = 'abcdefg';
        mdmController.callMDM();
        mdmController.iCustNum = null;
        
        mdmController.iBUID = 'abcdefg';
        mdmController.callMDM();
        mdmController.iBUID = null;
        
        mdmController.searchMethod = '';
        mdmController.selectSearch();
        
        mdmController.searchMethod = 'Duns Number' + 'Affinity ID' + 'Customer Number' + 'DUNS Name' + 'Country' + 'State' + 'City' + 'Postal Code' + 'BUID' + 'Region';
        mdmController.callMDM();
        mdmController.selectSearch();
        
        MDM_SearchDunsHttpResponseGenerator.bSearchById = false;
        mdmController = new MDM_SearchDunsCntrlr(stdController);
		
		mdmController.test();
		mdmController.getItems();
		mdmController.getCountries();
		mdmController.setCountries(new String[]{'United States', 'India'});
		mdmController.getRegionOptions();
		mdmController.getSearchOptions();
		mdmController.selectSearch();
		mdmController.getShowDunsNumber();
		mdmController.getShowAffinity();
		mdmController.getShowCusNum();
		mdmController.getShowBUID();
		mdmController.getShowDunsName();
		mdmController.getShowCountry();
		mdmController.getShowState();
		mdmController.getShowCity();
		mdmController.getShowPostalCode();
		mdmController.getShowRegion();
		mdmController.getshowResultTable();
		mdmController.getshowResultBlock();
		mdmController.reset();
		
	    Test.stopTest();
	}

}