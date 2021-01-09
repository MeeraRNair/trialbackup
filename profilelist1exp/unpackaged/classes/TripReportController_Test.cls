/************************************************************************

Author        : Rahul Mishra
Description   : Controller class to test
'TripReport' lightning component
Last Revised  : 30 Nov 2017


*************************************************************************/


@isTest 
private class TripReportController_Test { 
    
    // Method to validate the options from Goal Picklist
    
    static testMethod void validateTripReportGoal() {
        
        List<String> listGoals = new List<String>();
        listGoals = TripReportController.getGoalOptions();
        
        system.assertEquals(listGoals.size()>0, true);
    }
    
    // Method to validate the options from Type Picklist
    
    static testMethod void validateTripReportType() {
        
        List<String> listTypes = new List<String>();
        listTypes = TripReportController.getTypeOptions();
        
        system.assertEquals(listTypes.size()>0, true);
    }
    
    // Method to validate theAccountList
    
    static testMethod void validateAccountList() {
        
        List<Account> listAccount = new List<Account>();
        Account objAccount = new Account(Name = 'TestAcc');
        insert objAccount;
        listAccount = TripReportController.getAccountList('TestAcc');
        
        system.assertEquals(listAccount.size(), 1);
    }
    
    // Method to validate trip report recored is created or not
    
    static testMethod void validateTripReport() {
        
        Account objAccount = new Account(Name = 'TestAcc');
        insert objAccount;
        
        Contact objContact = new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = objAccount.Id, phone = '63635466', MobilePhone = '635444574', Email = 'test1@gmail.com');
        insert objContact;
        
        Profile profileId = [select id from profile where name='Standard User'];
        
        User objUser = new User(alias = 'test123', email='test156723@dell.com',
                                emailencodingkey='UTF-8', firstname='Testing', lastname = 'User', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = profileId.Id, country='United States', Badge_Number__c = '47657455544',
                                timezonesidkey='America/Los_Angeles', username='test125673@dell.com');
        insert objUser;
        
        CustomerInteraction__c trpReport = new CustomerInteraction__c(Goal_Objective__c = 'SME', Date__c = Date.today(), 
                                                                      Name = 'TestTrip_1',Customer_Attendee1__c = objContact.Id,
                                                                      Account__c = objAccount.Id, Type__c = 'Dell Visit', Summary__c = 'Test Summary', 
                                                                      Action_Items__c = 'Test Action Items', Send_Notification_Email__c = true,
                                                                      Secondary_Dell_Attendee__c = objUser.id, 
                                                                      Dell_Executive_Attendee_1__c = objUser.id,
                                                                      Primary_Dell_Attendee__c = objUser.id,
                                                                      Customer_Attendee2__c = objContact.Id);
        insert trpReport;
        TripReportController.saveTripReport(trpReport);
    }
}