/***********************************************************
* Name          : VFCntrlr_GoalDealCreationTest 
* Description   : Test class for VFCntrlr_GoalDealCreation
* ---------------------------------------------------------
* Revision      Name    Date            Description
* 1.0           MenMee  08.03.2010		Creation          
* 2.0           Meenu   08-Jan-2019     FY20-DCE-0202 16970 Field Trip clean up for Opportunity (Removed/Commented 	cfi_cfs_yes_no__c field)
*
************************************************************/

@isTest
private class VFCntrlr_GoalDealCreationTest {
	static Opportunity testOpp;

    static testMethod void createGoalDeal_getVendavoURL() {
        System.debug('***************** START createGoalDeal_getVendavoURL *****************');
        
        CreateTestData();
        
        PageReference pageRef = Page.GoalDealCreation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testOpp.Id);
        GoalIntegrationUtils.isRunTest = true;
        GoalIntegrationUtils.isErrorResponse = true;        
        
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(testOpp);
        VFCntrlr_GoalDealCreation controller = new VFCntrlr_GoalDealCreation(con);
                
        Test.startTest();
        controller.createGoalDeal();       
        Test.stopTest();
        
        //TestMethod do not support Web service callouts, just to get the error message       
		System.assertEquals('The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.', controller.errorMessage);                
				                
        System.debug('***************** END createGoalDeal_getVendavoURL *****************');
    }  
    
    static testMethod void createGoalDeal_noRecordExceptionTest() {
        System.debug('***************** START createGoalDeal_noRecordExceptionTest *****************');
        
        CreateTestData();
        
        PageReference pageRef = Page.GoalDealCreation;
        Test.setCurrentPage(pageRef);
         		             
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(testOpp);
        delete testOpp;
        
        Test.startTest();   
        VFCntrlr_GoalDealCreation controller = new VFCntrlr_GoalDealCreation(con);              
        Test.stopTest();
                
		System.assertEquals('Could not find a valid Opportunity record', controller.errorMessage);
		                
        System.debug('***************** END createGoalDeal_noRecordExceptionTest *****************');
    }
    
    static testMethod void unsupportedBrowserWarning_getErrorMessage() {
    	System.debug('***************** START unsupportedBrowserWarning_getErrorMessage *****************');

        CreateTestData();
        
        PageReference pageRef = Page.GoalDealCreation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testOpp.Id);
        
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(testOpp);
        VFCntrlr_GoalDealCreation controller = new VFCntrlr_GoalDealCreation(con);
        
        Test.startTest();
        controller.unsupportedBrowserWarning();    
        Test.stopTest();    	
        
        System.assertEquals('Unsupported Browser Detected. Please use Internet Explorer to open GOAL application.', controller.errorMessage);
    	
    	System.debug('***************** END unsupportedBrowserWarning_getErrorMessage *****************');
    }
    
     static testMethod void doBack_backToDetailedPage() {
    	System.debug('***************** START doBack_backToDetailedPage *****************');

        CreateTestData();
        
        PageReference pageRef = Page.GoalDealCreation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testOpp.Id);
        
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(testOpp);
        VFCntrlr_GoalDealCreation controller = new VFCntrlr_GoalDealCreation(con);
        
        Test.startTest();
        string actualURL = controller.doBack().getURL();    
        Test.stopTest();    	
        
        System.assertEquals('/'+StringUtils.subString(testOpp.Id, 0, 15), actualURL);
            	
    	System.debug('***************** END doBack_backToDetailedPage *****************');
    }
    
    static testMethod void doBackOpportunity_backToDetailedPage() {
    	System.debug('***************** START doBackOpportunity_backToDetailedPage *****************');

        CreateTestData();
        
        PageReference pageRef = Page.GoalDealCreation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testOpp.Id);
        
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(testOpp);
        VFCntrlr_GoalDealCreation controller = new VFCntrlr_GoalDealCreation(con);
        
        Test.startTest();
        string actualURL = controller.backToOpportunity;    
        Test.stopTest();    	
        
        System.assertEquals('/'+StringUtils.subString(testOpp.Id, 0, 15), actualURL);
            	
    	System.debug('***************** END doBackOpportunity_backToDetailedPage *****************');
    }
       
    private static void CreateTestData() {
		
		
		Account testAccount = new Account(name = 'Test Account');
		insert testAccount;
		
		RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];  
		
		 /* 2.0  08-Jan-2019 Meenu  FY20-DCE-0202 16970 Field Trip clean up for Opportunity, remove cfi_cfs_yes_no__c reference   */  
        testOpp = new Opportunity(RecordTypeId= rectype.Id, 
                                Name='Test Opportunity', AccountId= testAccount.Id, CurrencyIsoCode='USD',
                                Type='Deal/Bid Direct', CloseDate= system.today(), 
                                Solution_Type__c='Business Processing', StageName='Plan - 1%');    
		insert testOpp;
	}
}