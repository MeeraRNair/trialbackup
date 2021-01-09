/************************************************************************
Author        : Rahul Mishra
Description   : Test class for controller 'LookUpController'
Last Revised  : 30 Nov 2017
*************************************************************************/
@isTest 
private class LookUpController_Test {
    @testSetup
    static void dataSetup(){
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].Name = 'TestAccount';
        insert listAccTdf;
    }
    // Method to validate user search
    static testMethod void validateAccount() {
        /* List<Account> listAccount = new List<Account>();
Account objAcc = new Account(Name = 'TestAccount');
insert objAcc;
*/
        Account objAcc=[select id,name from Account where Name='TestAccount' Limit 1];
        List<Account> listAccount = LookUpController.fetchAccount('TestAccount');
        system.assertEquals(listAccount.size(), 1);
    }
}