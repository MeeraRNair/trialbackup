@IsTest
private class PartnerRegistrationMarkRejectedCtExTest {

	private static testmethod void testScreenIsForUpdateOnly(){
		Partner_Request__c request = new Partner_Request__c(
		    First_Name__c = 'John',
		    Last_Name__c = 'Doe',
		    Email__c = 'john.doe@acme.com',
		    Company__c = 'Tyama');
		PartnerRegistrationMarkRejectedCtrlExt extension = new PartnerRegistrationMarkRejectedCtrlExt(
			new ApexPages.standardController(request));	
		TestUtils.assertErrorMessagesExist();
	} 
	
	private static testmethod void testNormalFlow(){
		//set up test
		Partner_Request__c request = new Partner_Request__c(
		    First_Name__c = 'John',
		    Last_Name__c = 'Doe',
		    Email__c = 'john.doe@acme.com',
		    Company__c = 'Tyama');
		insert request;
		PartnerRegistrationMarkRejectedCtrlExt extension = new PartnerRegistrationMarkRejectedCtrlExt(
			new ApexPages.standardController(request));	
		TestUtils.assertNoErrorMessagesExist();
		
		//populate the message explaining what is incomplete
		extension.registration.Rejection_Reason__c = 'test 123';
		extension.isVisible 			= false;
		 
		
		//save
		PageReference next = extension.doSave();
		TestUtils.assertNoErrorMessagesExist();
		System.assertNotEquals(next,null);
		System.assertEquals(next.getUrl(),'/'+request.id);
	} 
	
	private static testmethod void testGeneralError(){
		//set up test
		Partner_Request__c request = new Partner_Request__c(
		    First_Name__c = 'John',
		    Last_Name__c = 'Doe',
		    Email__c = 'john.doe@acme.com',
		    Company__c = 'Tyama');
		insert request;
		PartnerRegistrationMarkRejectedCtrlExt extension = new PartnerRegistrationMarkRejectedCtrlExt(
			new ApexPages.standardController(request));	
		
		TestUtils.assertNoErrorMessagesExist();
		
		//populate the message explaining what is incomplete
		extension.registration.Rejection_Reason__c = 'test 123';
		String[] retStrList = extension.doParsePicklistStr(extension.registration.Rejection_Reason__c);    	
    	extension.isVisible 			= extension.isTargetValue(retStrList);
		 
		
		extension.registration.RecordTypeId = [select id from RecordType where SObjectType != 'Partner_Request__c' limit 1].id;
						
		//save
		PageReference next = extension.doSave();
		TestUtils.assertErrorMessagesExist();
	} 
	
	private static testmethod void testRejectionReasonRequiredValidation(){
		//set up test
		Partner_Request__c request = new Partner_Request__c(
		    First_Name__c = 'John',
		    Last_Name__c = 'Doe',
		    Email__c = 'john.doe@acme.com',
		    Company__c = 'Tyama');
		insert request;
		PartnerRegistrationMarkRejectedCtrlExt extension = new PartnerRegistrationMarkRejectedCtrlExt(
			new ApexPages.standardController(request));	
		TestUtils.assertNoErrorMessagesExist();
		
		PageReference next = extension.doSave();
		TestUtils.assertErrorMessagesExist();
	}
	
	private static testmethod void testCancel(){
		//set up test
		Partner_Request__c request = new Partner_Request__c(
		    First_Name__c = 'John',
		    Last_Name__c = 'Doe',
		    Email__c = 'john.doe@acme.com',
		    Company__c = 'Tyama');
		insert request;
		PartnerRegistrationMarkRejectedCtrlExt extension = new PartnerRegistrationMarkRejectedCtrlExt(
			new ApexPages.standardController(request));	
		TestUtils.assertNoErrorMessagesExist();
		
		PageReference next = extension.doCancel();
		TestUtils.assertNoErrorMessagesExist();
		System.assertNotEquals(next,null);
		System.assertEquals(next.getUrl(),'/'+request.id);
	}
}