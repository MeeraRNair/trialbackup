/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
* venu            Implimented TestDataFactory      
*/
@isTest
private class DateFormatterTest {
    
    static Account testAccount;
    //static Account testAccountforContact;
    static Contact testContact;
    static Opportunity testOpportunity;
    static User testNull;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        listAccTdf[0].name = 'Test 1';
        insert listAccTdf;
        list<Contact> listConTdf=TestDataFactory.CreateNContacts(1);
        listConTdf[0].AccountId=listAccTdf[0].id;
        insert listConTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].Name='Test 3';
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void testDateFormatterAccount() {
        
        /*testAccount = new Account(
name='Test 1'
);
insert testAccount;
*/
        testAccount = [SELECT LastModifiedDate, Id FROM Account WHERE name = 'Test 1' Limit 1];
        ApexPages.standardController controller = new ApexPages.standardController(testAccount);
        DateFormatter d= new DateFormatter(controller);
        System.assert(d.getISODate() <> null);    
    }
    static testMethod void testDateFormatterContact() {
        
        /*testAccountforContact = new Account(
name='Test 2'
);
insert testAccountforContact;*/
        testAccount = [SELECT LastModifiedDate, Id FROM Account WHERE name = 'Test 1' Limit 1];
        
        /*testContact = new Contact(
Phone = '123',
LastName = 'Test 2',
AccountId =	testAccountforContact.Id		
);
insert testContact;
*/
        testContact = [SELECT LastModifiedDate FROM Contact WHERE AccountId =: testAccount.id Limit 1];
        ApexPages.standardController controller = new ApexPages.standardController(testContact);
        DateFormatter d= new DateFormatter(controller);
        System.assert(d.getISODate() <> null);    
    }   
    static testMethod void testDateFormatterOpportunity() {
        
        /*testOpportunity = new Opportunity(
Name = 'Test 3',
StageName = 'Test 3',
CloseDate = Date.today()+1			
);
insert testOpportunity;
*/
        testOpportunity = [SELECT LastModifiedDate FROM Opportunity WHERE Name='Test 3' limit 1];
        ApexPages.standardController controller = new ApexPages.standardController(testOpportunity);
        DateFormatter d= new DateFormatter(controller);
        System.assert(d.getISODate() <> null);    
    }
    static testMethod void testDateFormatterNull() {
        
        testNull= [SELECT LastModifiedDate FROM User LIMIT 1];
        ApexPages.standardController controller = new ApexPages.standardController(testNull);
        DateFormatter d= new DateFormatter(controller);
        System.assert(d.getISODate() == null);    
    }	
}