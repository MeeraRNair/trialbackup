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
private class BeforeInsertUpdatePSUVTrigger_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        /*User u = [select id, Badge_Number__c, Name from User 
                  where IsActive = TRUE 
                  AND License_Used__C = 'Salesforce' 
                  Limit 1];*/
       
        Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        //UserRole uRole = [select id from UserRole where name like 'Rep_%' order by name limit 1];
        
        User ISMUser = new User(Username='testISMPSUV' +'@dell.com',
                                    Alias = 'ISMTest', 
                                    Email='testISMPSUV'+'@dell.com',            
                                    LastName='TestISMPSUV',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    //UserType = 'Standard',
                                    EmailEncodingKey='UTF-8',
                                    //Manual_Integrated_User__c = 'Yes', 
                                    //Integration_User_Flag__c = 'Y',
                                    IsActive = TRUE,
                                    //UserRoleId =uRole.Id,
                                    //User_Record_Source__c = 'Manual Integrated', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='ISMPSUV'+System.currentTimeMillis());
        insert ISMUser;
        
        User testISMUser = new User(Username='testingPSUV' +'@dell.com',
                                    Alias = 'PSUVTs', 
                                    Email='testingPSUV'+'@dell.com',            
                                    LastName='TestingPSUV',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    //UserType = 'Standard',
                                    EmailEncodingKey='UTF-8',
                                    Manual_Integrated_User__c = 'Yes', 
                                    Integration_User_Flag__c = 'Y',
                                    IsActive = TRUE,
                                    //UserRoleId =uRole.Id,
                                    //User_Record_Source__c = 'Manual Integrated',
                                    ISM__c= ISMUser.Id,
                                    RSM__c = ISMUser.Id,
                                    Director__c = ISMUser.Id,
                                    ManagerId = ISMUser.Id,
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='PSUV'+System.currentTimeMillis());
        insert testISMUser;
        
        User testUser = new User(Username='testPSUV' +'@dell.com',
                                    Alias = 'PSUV', 
                                    Email='testPSUV'+'@dell.com',            
                                    LastName='TestPSUV',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    //UserType = 'Standard',
                                    EmailEncodingKey='UTF-8',
                                    Manual_Integrated_User__c = 'Yes', 
                                    Integration_User_Flag__c = 'Y',
                                    IsActive = TRUE,
                                    //UserRoleId =uRole.Id,
                                    //User_Record_Source__c = 'Manual Integrated',
                                    ISM__c= ISMUser.Id,
                                    RSM__c = ISMUser.Id,
                                    Director__c = ISMUser.Id,
                                    //Manager__c = ISMUser.Id,
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='PSUV'+System.currentTimeMillis());
        insert testUser;
        
        Account testAccount = new Account(Name='Test Account',Type = 'End User',
                                                OwnerId = testUser.Id);
        insert testAccount;
        AccountTeamMember atm =new AccountTeamMember(userId=testUser.Id,
                               TeamMemberRole='Inside Sales Rep',
                               accountId = testAccount.id);
        insert atm; 
        Peoplesoft_User_View__c psRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =testUser.badge_number__c,
                               Employee_Status__c ='Terminated'
                               );
        Peoplesoft_User_View__c psISMRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =testISMUser.badge_number__c,
                               Employee_Status__c ='Active'
                               );
        insert psISMRecords;
        Peoplesoft_User_View__c ISMRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =ISMUser.badge_number__c,
                               Employee_Status__c ='Active'
                               );
        insert ISMRecords;
        Test.startTest();
        insert psRecords;
        psISMRecords.Employee_Status__c ='Terminated';
        update psISMRecords;
        psISMRecords.Employee_Status__c ='Active';
        update psISMRecords;
        Test.stopTest();
        system.assertequals(psRecords.Employee_Name__c, testUser.Name);
        //system.assertequals(psRecords.Assignment_Flag__c, TRUE);
    }
    
    
    static testMethod void populateEmployeeNameTest() {
        // TO DO: implement unit test
        /*User u = [select id, Badge_Number__c, Name from User 
                  where IsActive = TRUE 
                  AND License_Used__C = 'Salesforce' 
                  Limit 1];*/
       
        Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        //UserRole uRole = [select id from UserRole where name like 'Rep_%' order by name limit 1];
        
        Peoplesoft_User_View__c psRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c = 'PSTest1',
                               Employee_Status__c ='Active'
                               );
        
        User ISMUser = new User(Username='testISMPSUV' +'@dell.com',
                                    Alias = 'ISMTest', 
                                    Email='testISMPSUV'+'@dell.com',            
                                    LastName='TestISMPSUV',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    //UserType = 'Standard',
                                    EmailEncodingKey='UTF-8',
                                    //Manual_Integrated_User__c = 'Yes', 
                                    //Integration_User_Flag__c = 'Y',
                                    IsActive = TRUE,
                                    //UserRoleId =uRole.Id,
                                    //User_Record_Source__c = 'Manual Integrated', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='PSTest1');
        
        
        Test.startTest();
        insert psRecords;
        insert ISMUser;
        update psRecords;
        Test.stopTest();
        
        system.assertequals(psRecords.Badge_Number__c, ISMUser.Badge_Number__c);
        //system.assertequals(psRecords.Assignment_Flag__c, TRUE);
    }
}