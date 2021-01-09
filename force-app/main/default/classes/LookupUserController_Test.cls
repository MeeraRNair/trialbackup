/************************************************************************
Author        : Rahul Mishra
Description   : Test class for controller 'LookupUserController'
Last Revised  : 30 Nov 2017
*************************************************************************/
@isTest 
private class LookupUserController_Test { 
    @testSetup
    static void dataSetup(){
        Profile profileId = [select id from profile where name='Standard User'];
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(1);
        listUserTdf[0].ProfileId = profileId.Id;
        listUserTdf[0].firstname='Testing';
        listUserTdf[0].lastname = 'User';
        insert listUserTdf;
    }
    
    // Method to validate user search
    static testMethod void validateUser() {
        List<User> listUser = new List<User>();
        /* Profile profileId = [select id from profile where name='Standard User'];

User objUser = new User(alias = 'test123', email='test123@dell.com',
emailencodingkey='UTF-8', firstname='Testing', lastname = 'User', languagelocalekey='en_US',
localesidkey='en_US', profileid = profileId.Id, country='United States', Badge_Number__c = '476574544',
timezonesidkey='America/Los_Angeles', username='test12563@dell.com');
insert objUser;*/
        User objUser=[select id,email,firstname,lastname,ProfileId,Badge_Number__c,username from User where firstname='Testing' Limit 1];
        listUser = LookupUserController.fetchUser('Testing User');
        system.assertEquals(listUser.size(), 1);
    }
}