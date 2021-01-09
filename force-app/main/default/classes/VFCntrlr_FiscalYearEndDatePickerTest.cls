/********************************************************************
* Name      : VFCntrlr_FiscalYearEndDatePickerTest 
* Description  : Test class for VFCntrlr_FiscalYearEndDatePicker
* -----------------------------------------------------------------------------------------------------------
* Revision      Name      Date            Description
* 1.0           Josipinna   07.07.2011      Test class for VFCntrlr_FiscalYearEndDatePicker
*************************************************************************************************************/
@isTest
private class VFCntrlr_FiscalYearEndDatePickerTest {
	
	static Account testAccount;
	static List<User> testUserList;
    static List<AccountTeamMember> testATM;
    static String actualURL;
   
   
    static testMethod void doSave_test() {
    	System.debug('*****************START doSave_test*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.FiscalYearEndDatePicker;
    	Test.setCurrentPage(pageRef);

              
        ApexPages.StandardController AccRec = new ApexPages.StandardController(testAccount);  	
    	VFCntrlr_FiscalYearEndDatePicker controller = new VFCntrlr_FiscalYearEndDatePicker(AccRec);    	
								    	    	
    	Test.startTest();

    	controller.doSave();
    	
    	Test.stopTest();
    	
  	
    	// Query record
    	Account AccountRec =[SELECT Id FROM Account WHERE Id =: testAccount.Id];
    									 
    	System.assertEquals(testAccount.Id, AccountRec.Id);

    	System.debug('***************** END doSave_test*****************');
    }  
    
    static testMethod void doCancel_test() {
    	System.debug('*****************START doCancel_test*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.FiscalYearEndDatePicker;
    	Test.setCurrentPage(pageRef);

              
        ApexPages.StandardController AccRec = new ApexPages.StandardController(testAccount);  	
    	VFCntrlr_FiscalYearEndDatePicker controller = new VFCntrlr_FiscalYearEndDatePicker(AccRec);    	
		actualURL = controller.doCancel().getUrl();							    	    	
    	Test.startTest();

    	controller.doCancel();
    	
    	Test.stopTest();
    	
  	
    	// Query record
    	Account AccountRec =[SELECT Id FROM Account WHERE Id =: testAccount.Id];
    									 
    	System.assertEquals(testAccount.Id, AccountRec.Id);
		System.assertEquals('/'+testAccount.Id, actualURL);

    	System.debug('***************** END doCancel_test*****************');
    }      
 
    
  // Create test data
    public static void testDataCreation() {
    	
    	System.debug('***************** START testDataCreation *****************');
    	testUserList = new List<User>();

    	Profile profile = [select id from profile where name = 'System Administrator' limit 1];
                                
        for (integer i = 0; i < 2; i++) {
            User testUser = new User(Username='Test'+i+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test'+i, 
                                        Email='Test'+i+'@dell.com',            
                                        FirstName = 'User'+i,
                                        LastName='Test'+i, 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+i+System.currentTimeMillis());
        		testUserList.add(testUser);
        }
        insert testUserList;
   
        
		// Create account
		testAccount = new Account(name='TestAccount');
		insert testAccount;

		// Create account team
		testATM = new List<AccountTeamMember>();

			// Build the account team
			AccountTeamMember acctTM0 = new AccountTeamMember();
			acctTM0.AccountId = testAccount.Id;
			acctTM0.UserId = testUserList[0].Id;
			acctTM0.TeamMemberRole = 'Account Administrator';
	
			AccountTeamMember acctTM1 = new AccountTeamMember();
			acctTM1.AccountId = testAccount.Id;
			acctTM1.UserId = testUserList[1].Id;
			acctTM1.TeamMemberRole = 'Sales Approver';

			testATM.add(acctTM0);		
			testATM.add(acctTM1);	


			insert testATM;        

        System.debug('***************** END testDataCreation *****************');

    
    }     	
	
}