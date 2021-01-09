global class CustomResult {
	webService List<String> errors = new List<String>();
	webService ID Id;
	webService Boolean isSuccess;
	webService String ExternalID;
	webService ID AccountId;
	webService ID UserId;
	webService ID OpportunityId;
	webService String sfdcObject;
	webService String Operation;

	// Test case to test this class
	static testMethod void createCustomResult() {
		Account testAcc;
		testAcc = new account(name='Test Case createCustomResult');
		insert testAcc;
		
		Test.startTest();
		CustomResult cr = new CustomResult();
		cr.errors.add('Error Message');
		cr.Id = testAcc.Id;
		cr.isSuccess = true;
		cr.ExternalID = 'ExternalID';
		cr.AccountId = testAcc.Id;
		cr.UserId = testAcc.Id;
		cr.OpportunityId = testAcc.Id;
		cr.sfdcObject = 'Account';
		cr.Operation = 'Test';
		System.assertEquals('Test', cr.Operation);
		Test.stopTest();
		
	}
}