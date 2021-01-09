@IsTest
private class PartnerRegistrationDupAcctOwnrMsgCtlTst {

    private static testMethod void testInit() {
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'ACME Computers');
        insert request;
        PartnerRegistrationDupAcctOwnrMsgCtrl controller = new PartnerRegistrationDupAcctOwnrMsgCtrl();
        controller.init();
        controller.setPartnerRequestId(request.id);
        controller.init();
        System.assert(controller.getPartnerRequestId() == request.id);
        System.assert(controller.registration != null);
        System.assert(controller.registration.id == request.id);
        controller = new PartnerRegistrationDupAcctOwnrMsgCtrl();
        Account anAcct = new Account(name='hello');
        insert anAcct;
        controller.setPartnerRequestId(anAcct.id);
    }
    

}