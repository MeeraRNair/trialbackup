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
 */
@isTest
private class afterUpdateUserTriggerTest {

    static testMethod void testTermination() {
        // TO DO: implement unit test
       // TriggerExecutionControl__c triggerExeControl =new TriggerExecutionControl__c(Name='User',SkipTriggers__c=true);
       //     insert triggerExeControl;
        Profile psys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user1 = new User(IsActive = true, Email = 'unit_testsys@dell.com', LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = false,
            LastName = 'UT', Alias = 'UT', CommunityNickname = 'UTUsersys', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            ProfileId = psys.Id, UserName = 'unit_testsys@dell.com', Badge_Number__c = 'abcxyz3123',
            System_Admin_or_Delegated_User_Admin__c = true);
        insert user1;
            
               
        system.runAs(user1) {

            Test.startTest();

             //Profile p = [SELECT Id FROM Profile WHERE Id = '00eA0000000hLlP' LIMIT 1];

            User newUser = new User(IsActive = true, Email = 'unit_test@dell.com', LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = false,

            LastName = 'UT', Alias = 'UT', CommunityNickname = 'UTUser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',

            ProfileId = '00eA0000000hLlP', UserName = 'unit_test@dell.com', Badge_Number__c = 'abcxyz123',
            System_Admin_or_Delegated_User_Admin__c = true);

            insert newUser;

            User usr = [Select Id,EmpStatus__c from User where Id =: newUser.Id ];

            usr.EmpStatus__c = 'T';

             update usr;
            

        }
    }
    static testmethod void testUserTrig(){
    
           
        // TO DO: implement unit test
        TriggerExecutionControl__c triggerExeControl =new TriggerExecutionControl__c(Name='User',SkipTriggers__c=true);
            insert triggerExeControl;
        Profile psys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user1 = new User(IsActive = true, Email = 'unit_testsys@dell.com', LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = false,
            LastName = 'UT', Alias = 'UT', CommunityNickname = 'UTUsersys', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            ProfileId = psys.Id, UserName = 'unit_testsys@dell.com', Badge_Number__c = 'abcxyz3123',
            System_Admin_or_Delegated_User_Admin__c = true);
        insert user1;
             
        system.runAs(user1) {

            Test.startTest();

             //Profile p = [SELECT Id FROM Profile WHERE Id = '00eA0000000hLlP' LIMIT 1];

            User newUser = new User(IsActive = true, Email = 'unit_test@dell.com', LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = false,

            LastName = 'UT', Alias = 'UT', CommunityNickname = 'UTUser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',

            ProfileId = '00eA0000000hLlP', UserName = 'unit_test@dell.com', Badge_Number__c = 'abcxyz123',
            System_Admin_or_Delegated_User_Admin__c = true);

            insert newUser;

            User usr = [Select Id,EmpStatus__c from User where Id =: newUser.Id ];

            usr.EmpStatus__c = 'T';

             update usr;
            

        } 
    }
    static testmethod void testUserTrig1(){
    
           
        // TO DO: implement unit test
        
        Profile psys = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user1 = new User(IsActive = true, Email = 'unit_testsys@dell.com', LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = false,
            LastName = 'UT', Alias = 'UT', CommunityNickname = 'UTUsersys', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            ProfileId = psys.Id, UserName = 'unit_testsys@dell.com', Badge_Number__c = 'abcxyz3123',
            System_Admin_or_Delegated_User_Admin__c = true);
        insert user1;
             TriggerExecutionControl__c triggerExeControl =new TriggerExecutionControl__c(Name='User',SkipTriggers__c=false,UsersToSkip__c=user1.id);
            insert triggerExeControl;
        system.runAs(user1) {

            Test.startTest();

             //Profile p = [SELECT Id FROM Profile WHERE Id = '00eA0000000hLlP' LIMIT 1];

            User newUser = new User(IsActive = true, Email = 'unit_test@dell.com', LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = false,

            LastName = 'UT', Alias = 'UT', CommunityNickname = 'UTUser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',

            ProfileId = '00eA0000000hLlP', UserName = 'unit_test@dell.com', Badge_Number__c = 'abcxyz123',
            System_Admin_or_Delegated_User_Admin__c = true);

            insert newUser;

            User usr = [Select Id,EmpStatus__c from User where Id =: newUser.Id ];

            usr.EmpStatus__c = 'T';

             update usr;
            

        } 
    }
}