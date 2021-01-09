@IsTest
private class PartnerRegistrationGetDupDetailsCtlTest {
	
	private static testmethod void testNormalWithDuplicateAccount(){
		Partner_Request__c request1 = new Partner_Request__c();
		request1.First_Name__c = 'Bill';
		request1.Last_Name__c = 'Doe';
		insert request1;
		request1 = [select First_Name__c,Last_Name__c,name from Partner_Request__c where id = :request1.id];
		Account account = new Account(name='test',Partner_Registration__c=request1.id);
		insert account;

		Partner_Request__c request2 = new Partner_Request__c();
		request2.Duplicate_Account__c = account.id;
		insert request2;
		request2 = [select name from Partner_Request__c where id = :request2.id];

		PartnerRegistrationGetDupDetailsCtrl controller = new PartnerRegistrationGetDupDetailsCtrl();
		controller.init();
		controller.partnerRequestId = request2.id;
		
		System.assertEquals(account.name,controller.getCompanyName());
		System.assertEquals(request1.name,controller.getRequestNumber());
		System.assertEquals(request1.First_Name__c + ' ' + request1.Last_Name__c,controller.getRequestorName());
	}

	private static testmethod void testNormalWithDuplicateRegistration(){
		Partner_Request__c request1 = new Partner_Request__c();
		request1.First_Name__c = 'Bill';
		request1.Last_Name__c = 'Doe';
		request1.Company__c = 'test';
		insert request1;
		request1 = [select Company__c,First_Name__c,Last_Name__c,name from Partner_Request__c where id = :request1.id];

		Partner_Request__c request2 = new Partner_Request__c();
		request2.Duplicate_Registration__c = request1.id;
		insert request2;
		request2 = [select name from Partner_Request__c where id = :request2.id];

		PartnerRegistrationGetDupDetailsCtrl controller = new PartnerRegistrationGetDupDetailsCtrl();
		controller.init();
		controller.partnerRequestId = request2.id;
		
		System.assertEquals(request1.Company__c,controller.getCompanyName());
		System.assertEquals(request1.name,controller.getRequestNumber());
		System.assertEquals(request1.First_Name__c + ' ' + request1.Last_Name__c,controller.getRequestorName());
	}
}