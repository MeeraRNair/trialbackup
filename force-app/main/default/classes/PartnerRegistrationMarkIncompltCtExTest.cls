@IsTest
private class PartnerRegistrationMarkIncompltCtExTest {
 
    private static testmethod void testScreenIsForUpdateOnly(){
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama');
        PartnerRegistrationMarkIncompltCtrlExt extension = new PartnerRegistrationMarkIncompltCtrlExt(
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
        PartnerRegistrationMarkIncompltCtrlExt extension = new PartnerRegistrationMarkIncompltCtrlExt(
            new ApexPages.standardController(request)); 
        TestUtils.assertNoErrorMessagesExist();
        
        //populate the message explaining what is incomplete
        System.assert(StringUtils.isBlank(extension.registration.Incomplete_Description__c));
        extension.registration.Incomplete_Description__c = 'test 123';
        
        //save
        PageReference next = extension.doSave();
        TestUtils.assertNoErrorMessagesExist();
        System.assertNotEquals(next,null);
        System.assertEquals(next.getUrl(),'/'+request.id);
    } 
    
    private static testmethod void testMessageToPartnerRequiredValidation(){
        //set up test
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama');
        insert request;
        PartnerRegistrationMarkIncompltCtrlExt extension = new PartnerRegistrationMarkIncompltCtrlExt(
            new ApexPages.standardController(request)); 
        TestUtils.assertNoErrorMessagesExist();
        
        //save; validation error message should be generated because extension.registration.Incomplete_Description__c 
        //  is not populated
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
        PartnerRegistrationMarkIncompltCtrlExt extension = new PartnerRegistrationMarkIncompltCtrlExt(
            new ApexPages.standardController(request)); 
        TestUtils.assertNoErrorMessagesExist();
        
        PageReference next = extension.doCancel();
        TestUtils.assertNoErrorMessagesExist();
        System.assertNotEquals(next,null);
        System.assertEquals(next.getUrl(),'/'+request.id);
    }
    
}