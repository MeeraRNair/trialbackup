@IsTest
private class PartnerRegistrationGetSupEmailComCtTest {

    private static testMethod void testNullEmailReturns() {
        PartnerRegistrationGetSupEmailCompCtrl controller = new PartnerRegistrationGetSupEmailCompCtrl();
        System.assertEquals(null, controller.getPartnerSupportEmail());
        Account testAcct = new Account(name='test');
        insert testAcct;
        controller.partnerRequestId = testAcct.id;
        System.assertEquals(null, controller.getPartnerSupportEmail());
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',Last_Name__c = 'Doe',Company__c = 'Tyama');
        insert request;
        controller.partnerRequestId = request.id;
        System.assertEquals(null, controller.getPartnerSupportEmail());
    }
    
    private static testMethod void testEmailRetrieved() {
        Country__c country = new Country__c(Name = 'Double Z', Code__c = 'ZZ',
            Partner_Support_Email__c='john.doe@acme.com');
        insert country;
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Company__c = 'Tyama',
            Country__c = country.id);
        insert request;
        PartnerRegistrationGetSupEmailCompCtrl controller = new PartnerRegistrationGetSupEmailCompCtrl();
        controller.partnerRequestId = request.id;
        System.assertEquals(country.Partner_Support_Email__c, controller.getPartnerSupportEmail());
    }
}