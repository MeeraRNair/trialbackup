@isTest
private class PartnerRegistrationActnHndlrCtrlExtTest {
 
    private static testmethod void testScreenIsForUpdateOnly() {
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'ACME Computers');
        PartnerRegistrationActionHandlerCtrlExt extension = new PartnerRegistrationActionHandlerCtrlExt(
            new ApexPages.standardController(request));
        TestUtils.assertErrorMessagesExist();
        System.assertEquals(extension.doOnLoad(),null); 
    }
    
    private static testmethod void testEmptyAction() {
        TestReferences references = setupTest(null);
        TestUtils.assertErrorMessagesExist();
        references.extension.doOnLoad(); 
    }
    
    private static testmethod void testRequestDoesntExist() {
        PageReference pageRef = Page.PartnerRegistrationActionHandler;
        Test.setCurrentPage(pageRef);       
        ApexPages.currentPage().getParameters().put('action', 'abc123');
        ApexPages.standardController controller = new ApexPages.standardController(new Partner_Request__c(
            First_Name__c = 'John', Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com', Company__c = 'ACME Computers'));
        PartnerRegistrationActionHandlerCtrlExt extension = new PartnerRegistrationActionHandlerCtrlExt(controller);
        TestUtils.assertErrorMessagesExist();
    }
    
    private static testmethod void testInvalidAction() {
        TestReferences references = setupTest('abc123');
        PageReference onLoadResult = references.extension.doOnLoad();
        //TestUtils.assertErrorMessagesExist();
    }
    
    private static testmethod void testForceException() {
        PageReference pageRef = Page.PartnerRegistrationActionHandler;
        Test.setCurrentPage(pageRef);       
        Partner_Request__c req = new Partner_Request__c();
        insert req;

        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'ACME Computers',
            id=(''+req.id).substring(0,10) + 'xxxxx');
        ApexPages.currentPage().getParameters().put('action', PartnerRegistrationActionHandlerCtrlExt.ACTION_MARK_AS_COMPLETE);
        ApexPages.standardController controller = new ApexPages.standardController(request);
        PartnerRegistrationActionHandlerCtrlExt extension = new PartnerRegistrationActionHandlerCtrlExt(controller);
        insert new Account(name='ABC 123');
        PageReference onLoadResult = extension.doOnLoad();
        TestUtils.assertErrorMessagesExist();
    }
    
    
    private static testmethod void testActionMarkAsComplete() {
        testActionWhichFlipsFlagAndSetsStatus(
            PartnerRegistrationActionHandlerCtrlExt.ACTION_MARK_AS_COMPLETE,
            'Review_for_Completeness_Is_Complete_Flag__c',
            PartnerConstants.REG_STATUS_INREVIEW,
            Page.PartnerRegistrationDupSearch.getUrl() + '?id='
        );
    }
    
    private static testmethod void testActionApprove() {
        testActionWhichFlipsFlagAndSetsStatus(
            PartnerRegistrationActionHandlerCtrlExt.ACTION_APPROVE,
            'Approve_Is_Complete_Flag__c',
            PartnerConstants.REG_STATUS_APPROVED,
            '/'
        );
    }
    
    private static testmethod void testActionMarkCreditCheckComplete() {
        testActionWhichFlipsFlagOnly(
            PartnerRegistrationActionHandlerCtrlExt.ACTION_MARK_CREDIT_CHECK_COMPLETE,
            'Perform_Credit_Check_Is_Complete_Flag__c'
        );
    }
    
    private static testmethod void testActionMarkExportCheckComplete() {
        testActionWhichFlipsFlagOnly(
            PartnerRegistrationActionHandlerCtrlExt.ACTION_MARK_EXPORT_COMPLIANCE_CHECK_COMPLETE,
            'Export_Compliance_Check_Is_Complete_Flag__c'
        );
    }
    
    private static testmethod void testActionMarkDeniedPartyCheckComplete() {
        testActionWhichFlipsFlagOnly(
            PartnerRegistrationActionHandlerCtrlExt.ACTION_MARK_DENIED_PARTY_COMPLETE,
            'Check_Denied_Party_List_Is_Complete_Flag__c'
        );
    }   
    
    private static void testActionWhichFlipsFlagAndSetsStatus(
        String action, String field, String status, String location) {

        TestReferences references = setupTest(action);
        PageReference onLoadResult = references.extension.doOnLoad();
        System.assert(onLoadResult != null, 'doOnLoad() returned null');
        System.assertEquals(location + references.request.id, onLoadResult.getUrl());

        assertStatus(references.request.id, status);
        assertFlagSet(references.request.id, field);
        TestUtils.assertNoErrorMessagesExist();
    }
    
    private static void testActionWhichFlipsFlagOnly(String action, String field){
        TestReferences references = setupTest(action);
        PageReference onLoadResult = references.extension.doOnLoad();
        System.assert(onLoadResult != null, 'doOnLoad() returned null');
        System.assertEquals('/' + references.request.id, onLoadResult.getUrl());
        assertFlagSet(references.request.id, field);
        TestUtils.assertNoErrorMessagesExist();
    }
            
    private static void assertStatus(Id theId, String status){
        Partner_Request__c request = [select id, Status__c from Partner_Request__c where id = :theId];
        System.assert(request.Status__c == status,
            'Partner_Request__c.Status__c is \'' + request.Status__c + '\'; expected \'' + status + '\'');
    }
    
    private static void assertFlagSet(Id id, String field){
        Partner_Request__c request = Database.query('select ' + field 
            + ' from Partner_Request__c where id = \'' + String.escapeSingleQuotes(id) + '\'');
        Boolean value = (Boolean) request.get(field);
        System.assert(value, 'Partner_Request__c.' + field + ' is false');
    }
    
    private class TestReferences{
        public ApexPages.standardController controller {get;set;}
        public PartnerRegistrationActionHandlerCtrlExt extension {get;set;}
        public Partner_Request__c request {get;set;}
        
        public TestReferences(
            ApexPages.standardController controller,
            PartnerRegistrationActionHandlerCtrlExt extension, 
            Partner_Request__c request){

            this.controller = controller;
            this.extension = extension;
            this.request = request;
        }
    }
    
    private static TestReferences setupTest(String action){
        PageReference pageRef = Page.PartnerRegistrationActionHandler;
        Test.setCurrentPage(pageRef);       
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'ACME Computers');
        insert request;
        ApexPages.currentPage().getParameters().put('action', action);
        ApexPages.standardController controller = new ApexPages.standardController(request);
        PartnerRegistrationActionHandlerCtrlExt extension = new PartnerRegistrationActionHandlerCtrlExt(controller);
        extension.getIsError();
        return new TestReferences( controller, extension, request);
    } 
    
}