/************************************************************************
Author        : Rahul Mishra
Description   : Test class for controller 'LookUpController'
Last Revised  : 30 Nov 2017
*************************************************************************/
@isTest 
private class LookupContactController_Test { 
    @testSetup
    static void dataSetup(){
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].name='TestAcc';
        insert listAccTdf;
        list<Contact> listConTdf=TestDataFactory.createNContacts(1);
        listConTdf[0].FirstName = 'Test1';
        listConTdf[0].LastName = 'Contact';
        listConTdf[0].AccountId = listAccTdf[0].Id;
        insert listConTdf;
    }
    // Validate contact list when parent account is not supplied
    static testMethod void validateContactWithOutParent() {
        /* List<Contact> listContact = new List<Contact>();

Account objAccount = new Account(Name = 'TestAcc');
insert objAccount;

Contact objContact = new Contact(FirstName = 'Test1', LastName = 'Contact', AccountId = objAccount.Id, phone = '63635566', MobilePhone = '63544454', Email = 'test@gmail.com');
insert objContact;
*/
        Account objAccount=[select id from Account where name='TestAcc' limit 1];
        Contact objContact=[select id,FirstName,LastName,AccountId,email from Contact where FirstName='Test1' limit 1];
        List<Contact> listContact = LookupContactController.fetchContact('Test1', '');
        system.assertEquals(listContact.size(), 1);
        List<Contact> listContact1 = LookupContactController.fetchContact('Contact', objAccount.Id);
        system.assertEquals(listContact.size(), 1);
    }
    
    // Validate contact list when parent account is not supplied
    
    /* static testMethod void validateContactWithParent() {

List<Contact> listContact = new List<Contact>();

Account objAccount = new Account(Name = 'TestAcc1');
insert objAccount;

Contact objContact = new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = objAccount.Id, phone = '63635466', MobilePhone = '635444574', Email = 'test1@gmail.com');
insert objContact;

listContact = LookupContactController.fetchContact('Contact1', objAccount.Id);
system.assertEquals(listContact.size(), 1);
}*/
    
}