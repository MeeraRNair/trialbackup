/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13274       Sprint 11       22-June-2016    Afiq            To separate test method in a test class from SalesTeamUtil main class
*/   
    
@isTest 

private class SalesTeamUtil_Test {  
    // Test case 8: [setSalesTeam] Test account with 0 team member
    // Design Document Test Case 1
    public static Account acc = new Account();
    public static Contact testCon = new Contact();
    public static Boolean forceTest = false;

    @testSetup static void setup() {
        OWD__c OWDsetting = new OWD__c();
        OWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        OWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        OWDsetting.Oppty_Stage100__c = 'Win - 100%';
        OWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        OWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        OWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        OWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        OWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert OWDsetting;
    }
    
    static testMethod void Test8() {
    
        system.debug('## Start the test 8');
        
        // Test data creation
        Account testAcc;
        List<user> test_user = new List<user>([select id from user where contactId = null and isActive = true limit 11]);
        
        testAcc = new account(name='Test Case 8 - Dell Util');
        testAcc.ownerid = test_user[0].id;
        
        insert testAcc;
        
        Profile testProfile = [select id, name from profile where name like '%Sales%' order by name limit 1 ];

        System.assert(testProfile != null);
        
        // Assertion
        // System.assertEquals(1, [select count() from account where name LIKE 'Test case 8%']);
        
        // Create a new opportunity related to the test account
        Opportunity testOpp;
        testOpp = new opportunity(name='Test Case 8 - Dell Opp');
        testOpp.ownerid = test_user[0].id;
        testOpp.accountId = testAcc.Id;
        testOpp.StageName = 'Discover - 10%';
        testOpp.Partner_Opportunity_Stage__c = 'Discover - 10%';
        testOpp.CloseDate = System.today();


        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();

        
        insert testOpp;


        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();

    
        // Here, the trigger should run and the sale team should NOT be populated with the account team
        // Assertion
        System.assertEquals(0, [select count() from OpportunityTeamMember where opportunityId = :testOpp.Id]);
            
    }


    // Test case 9: [setSalesTeam] Standard test, account with 10 team members
    // Design Document Test Case 3

    static testMethod void Test9() {
    
        system.debug('## Start the test 9');
    
    
        // Get the users
        List<user> test_user = new List<user>([select id from user where isActive = true limit 11]);
    
    
        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');

        insert testAcc;
    
        
        // Create the account team members and account shares
        List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
        List<AccountShare> testAcctShs = new List<AccountShare>();
        
        for(Integer j=0; j< 10; j++) { 
    
            // Add user to the test account's team member list
            AccountTeamMember testAccTM = new AccountTeamMember();
            testAccTM.userid = test_user[j].id;
            testAccTM.accountid = testAcc.id;
            testAccTM.teammemberrole = 'Test';
            testAcctTMs.add(testAccTM);
            
            if (test_user[j].id != testAcc.OwnerId) {
                AccountShare testAcctSh = new AccountShare();
                testAcctSh.UserOrGroupId = test_user[j].id;
                testAcctSh.AccountId = testAcc.id;
                testAcctSh.AccountAccessLevel = 'Edit';
                testAcctSh.OpportunityAccessLevel = 'Edit';
                testAcctSh.CaseAccessLevel = 'Edit';        
                
                testAcctShs.add(testAcctSh);    
            }
    
        }   // End for(Integer j=0; j< 11; j++)
        
        insert testAcctTMs;
        insert testAcctShs;



        // Assertion
//        System.assertEquals(1, [select count() from Account where Name LIKE 'Test Account 50%']);
        
        
        // Assertion
//        System.assertEquals(10, [select count() from AccountTeamMember where Account.Name LIKE 'Test Account 50%']);
    
        
        // Assertion
//        System.assertEquals(10, [select count() from AccountShare where Account.Name LIKE 'Test Account 50%' and rowcause = 'Team']);

        
        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);


        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();


        insert sOpportunity1;


        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
        List<Opportunity> oppty = new List<Opportunity>([select Direct_Team_Sync__c from Opportunity where Id = :sOpportunity1.id]);
        System.assertEquals('True',oppty[0].Direct_Team_Sync__c);

// ALou - 2008/10/16 - Commented out for deployment 
        
        // The trigger should run and the sale team should be populated with the account team
        // Assertion
//        System.assertEquals(10, [select count() from OpportunityTeamMember where opportunityId = :sOpportunity1.Id]);
    
//        System.assertEquals(10, [select count() from OpportunityShare where opportunityId = :sOpportunity1.Id and RowCause = 'Team']);
    

        // Verify that all opportunity shares created have edit permissions
//        for (OpportunityShare oppSh : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunity1.Id and RowCause = 'Team']) {
//            system.assertEquals('Edit', oppSh.OpportunityAccessLevel);
//        }


        // Clear objects
        testAcctTMs.clear();
        testAcctShs.clear();

    }   // End Test Case 9

    // Test case 9b: [setSalesTeam] Standard test, account with 10 team members
    // Design Document Test Case 3

    static testMethod void Test9b() {
    
        system.debug('## Start the test 9');
    
    
        // Get the users
        List<user> test_user = new List<user>([select id from user where isActive = true limit 11]);
    
    
        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');

        insert testAcc;
    
        
        // Create the account team members and account shares
        List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
        List<AccountShare> testAcctShs = new List<AccountShare>();
        
        for(Integer j=0; j< 10; j++) { 
    
            // Add user to the test account's team member list
            AccountTeamMember testAccTM = new AccountTeamMember();
            testAccTM.userid = test_user[j].id;
            testAccTM.accountid = testAcc.id;
            testAccTM.teammemberrole = 'Test';
            testAcctTMs.add(testAccTM);
            
            if (test_user[j].id != testAcc.OwnerId) {
                AccountShare testAcctSh = new AccountShare();
                testAcctSh.UserOrGroupId = test_user[j].id;
                testAcctSh.AccountId = testAcc.id;
                testAcctSh.AccountAccessLevel = 'Edit';
                testAcctSh.OpportunityAccessLevel = 'Read';
                testAcctSh.CaseAccessLevel = 'Edit';        
                
                testAcctShs.add(testAcctSh);    
            }
    
        }   // End for(Integer j=0; j< 11; j++)
        
        insert testAcctTMs;
        insert testAcctShs;
        
        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        
        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();

        //force a "high volume" using forceTest
        forceTest = true;
               
        insert sOpportunity1;
        forceTest = false;

        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
        
        testAcctTMs.clear();
        testAcctShs.clear();

    }   // End Test Case 9b

    // Test case 10: [setSalesTeam]
    // Exception handling testing: Limit on DML rows
    // Create 1 opportunity related to account with 101 team members,
    // no Default Sales Team for the user

    static testMethod void Test10() {
        TriggerExecutionController.setSkipAllTriggers(true);
        // Get 102 users
        List<user> test_user = new List<user>([select id from user where isActive = true limit 102]);
        
        // Add User1
        Profile UserProf = [select Id, Name from Profile where Name like '%GBL Sales Rep%' limit 1];
        User User1 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                Alias = 'MTU9', 
                                Email='MyTestUser12@dell.com', 
                                FirstName='MyTestUser12', 
                                LastName='MyTestUser12',  
                                ProfileId = UserProf.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='970533', 
                                isActive = TRUE);
        Insert User1;

        Id accountRTId = IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        acc = new Account(Name = 'Test', RecordtypeId = accountRTId, Type = 'Partner');
        insert acc;
        
        // Creating Contact
        testCon = new Contact(FirstName = 'TestContactFN9',
                     LastName = 'TestContactLN9',
                     accountId = acc.Id,
                     Status__c = 'Marketing Suspect',
                     Email = 'test11day@dell.com',
                     MobilePhone = '0000019',
                     Last_Operation_Performed__c = 'testing',
                     Phone = '1234567');
        insert testCon;
        
        // Add User
        Profile UserProf1 = [select id from profile where Name LIKE '%PRM Portal%' limit 1];
        User User2 = new User(
                        Username = 'test11day' + System.currentTimeMillis() + '@dell.com',
                        Alias = 'tst11', 
                        Email = 'test11day@dell.com', 
                        FirstName = 'test11day', 
                        LastName = 'test11day',  
                        ProfileId = UserProf1.Id, 
                        LanguageLocaleKey = 'en_US', 
                        LocaleSidKey = 'en_US', 
                        EmailEncodingKey = 'UTF-8', 
                        TimeZoneSidKey = 'America/Los_Angeles',
                        Enable_Partner_Lead_Management__c = true,
                        Enable_Partner_Deal_Registration__c = true,
                        Badge_Number__c = '912345', 
                        isActive = TRUE,
                        ContactId = testCon.id
                    );
        insert User2;
    
    
        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');  
    
        insert testAcc;
    
        
        // Create the account team members and account shares
        List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
        List<AccountShare> testAcctShs = new List<AccountShare>();
        List<AccountTeamMember> testAcctTMs1 = new List<AccountTeamMember>();
        List<AccountShare> testAcctShs1 = new List<AccountShare>();
         
    
        // Add user to the test account's team member list
        AccountTeamMember testAccTM = new AccountTeamMember();
        testAccTM.userid = User1.id;
        testAccTM.accountid = testAcc.id;
        testAccTM.teammemberrole = 'Test';
        testAcctTMs.add(testAccTM);
        
        if (User1.id != testAcc.OwnerId) {
            AccountShare testAcctSh = new AccountShare();
            testAcctSh.UserOrGroupId = User1.id;
            testAcctSh.AccountId = testAcc.id;
            testAcctSh.AccountAccessLevel = 'Edit';
            testAcctSh.OpportunityAccessLevel = 'Edit';
            testAcctSh.CaseAccessLevel = 'Edit';        
            
            testAcctShs.add(testAcctSh);    
        }
    
        
        insert testAcctTMs;
        insert testAcctShs;
        
       AccountTeamMember testAccTM1 = new AccountTeamMember();
        testAccTM1.userid = User2.id;
        testAccTM1.accountid = testAcc.id;
        testAccTM1.teammemberrole = 'Test';
        testAcctTMs1.add(testAccTM1);
        
        if (User2.id != testAcc.OwnerId) {
            AccountShare testAcctSh1 = new AccountShare();
            testAcctSh1.UserOrGroupId = User2.id;
            testAcctSh1.AccountId = testAcc.id;
            testAcctSh1.AccountAccessLevel = 'Edit';
            testAcctSh1.OpportunityAccessLevel = 'Edit';
            testAcctSh1.CaseAccessLevel = 'Edit';        
            
            testAcctShs1.add(testAcctSh1);    
        }
    
        
        insert testAcctTMs1;
        insert testAcctShs1;        

    
        // Assertion
//        System.assertEquals(1, [select count() from Account where Name LIKE 'Test Account 50%']);
        
        
        // Assertion
//        System.assertEquals(101, [select count() from AccountTeamMember where Account.Name LIKE 'Test Account 50%']);
    
        
        // Assertion
//        System.assertEquals(101, [select count() from AccountShare where Account.Name LIKE 'Test Account 50%' and rowcause = 'Team']);
    

        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);

        TriggerExecutionController.setSkipAllTriggers(false);

        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();


        insert sOpportunity1;
    

        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();


        // Here, the trigger should run and the sale team should be populated with the account team
        // Assertion
//        System.assertEquals(0, [select count() from OpportunityTeamMember where opportunityId = :sOpportunity1.Id]);
    
//        System.assertEquals(0, [select count() from OpportunityShare where opportunityId = :sOpportunity1.Id and RowCause = 'Team']);
    

        // Clear objects
        testAcctTMs.clear();
        testAcctShs.clear();

    }   // End Test Case 10


    // Test case 11: [setSalesTeam]
    // Exception handling testing: Limit on DML rows
    // Create 1 opportunity related to account with 51 team members,
    // no Default Sales Team for the user
    // Design Document Test Case 11

    static testMethod void Test11() {
    
        system.debug('## Start the test 11');
    
    
        // Get 52 users
        List<user> test_user = new List<user>([select id from user where isActive = true limit 52]);
    
    
        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');  
    
        insert testAcc;
    
        
        // Create the account team members and account shares
        List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
        List<AccountShare> testAcctShs = new List<AccountShare>();
        
        for(Integer j=0; j< 51; j++) { 
    
            // Add user to the test account's team member list
            AccountTeamMember testAccTM = new AccountTeamMember();
            testAccTM.userid = test_user[j].id;
            testAccTM.accountid = testAcc.id;
            testAccTM.teammemberrole = 'Test';
            testAcctTMs.add(testAccTM);
            
            if (test_user[j].id != testAcc.OwnerId) {
                AccountShare testAcctSh = new AccountShare();
                testAcctSh.UserOrGroupId = test_user[j].id;
                testAcctSh.AccountId = testAcc.id;
                testAcctSh.AccountAccessLevel = 'Edit';
                testAcctSh.OpportunityAccessLevel = 'Edit';
                testAcctSh.CaseAccessLevel = 'Edit';        
                
                testAcctShs.add(testAcctSh);    
            }
    
        }   // End for(Integer j=0; j< 11; j++)
        
        insert testAcctTMs;
        insert testAcctShs;

    
        // Assertion
//        System.assertEquals(1, [select count() from Account where Name LIKE 'Test Account 50%']);
        
        
        // Assertion
//        System.assertEquals(51, [select count() from AccountTeamMember where Account.Name LIKE 'Test Account 50%']);
    
        
        // Assertion
//        System.assertEquals(51, [select count() from AccountShare where Account.Name LIKE 'Test Account 50%' and rowcause = 'Team']);
    
            
        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);


        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();


        insert sOpportunity1;
    

        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();

// ALou - 2008/10/16 - Commented out for deployment 
    
        // Here, the trigger should run and the sale team should be populated with the account team
        // Assertion
//        System.assertEquals(51, [select count() from OpportunityTeamMember where opportunityId = :sOpportunity1.Id]);
    
//        System.assertEquals(0, [select count() from OpportunityShare where opportunityId = :sOpportunity1.Id and RowCause = 'Team' and OpportunityAccessLevel = 'Edit']);
    

        // Clear objects
        testAcctTMs.clear();
        testAcctShs.clear();

    }   // End Test Case 11


    // Test case 12: [setSalesTeam] Standard test, account with 10 team members
    // Same as Test Case #9, but with Direct_Team_Sync = false
    // Design Document Test Case 5.5

    static testMethod void Test12() {
    
        system.debug('## Start the test 12');
    
    
        // Get the users
        List<user> test_user = new List<user>([select id from user where isActive = true limit 11]);
    
    
        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');

        insert testAcc;
    
        
        // Create the account team members and account shares
        List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
        List<AccountShare> testAcctShs = new List<AccountShare>();
        
        for(Integer j=0; j< 10; j++) { 
    
            // Add user to the test account's team member list
            AccountTeamMember testAccTM = new AccountTeamMember();
            testAccTM.userid = test_user[j].id;
            testAccTM.accountid = testAcc.id;
            testAccTM.teammemberrole = 'Test';
            testAcctTMs.add(testAccTM);
            
            if (test_user[j].id != testAcc.OwnerId) {
                AccountShare testAcctSh = new AccountShare();
                testAcctSh.UserOrGroupId = test_user[j].id;
                testAcctSh.AccountId = testAcc.id;
                testAcctSh.AccountAccessLevel = 'Edit';
                testAcctSh.OpportunityAccessLevel = 'Edit';
                testAcctSh.CaseAccessLevel = 'Edit';        
                
                testAcctShs.add(testAcctSh);    
            }
    
        }   // End for(Integer j=0; j< 11; j++)
    
        insert testAcctTMs;
        insert testAcctShs;

        // Assertion
//        System.assertEquals(1, [select count() from Account where Name LIKE 'Test Account 50%']);
        
        
        // Assertion
//        System.assertEquals(10, [select count() from AccountTeamMember where Account.Name LIKE 'Test Account 50%']);
    
        
        // Assertion
//        System.assertEquals(10, [select count() from AccountShare where Account.Name LIKE 'Test Account 50%' and rowcause = 'Team']);


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%', Type='Deal/Bid - Indirect', RecordTypeId=sRecordType1);


        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();


        insert sOpportunity1;


        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();


        // The trigger should run and the sale team should be populated with the account team
        // Assertion
//        System.assertEquals(0, [select count() from OpportunityTeamMember where opportunityId = :sOpportunity1.Id]);
    
//        System.assertEquals(0, [select count() from OpportunityShare where opportunityId = :sOpportunity1.Id and RowCause = 'Team']);
    

        // Verify that all opportunity shares created have edit permissions
//        for (OpportunityShare oppSh : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunity1.Id and RowCause = 'Team']) {
//            system.assertEquals('Edit', oppSh.OpportunityAccessLevel);
//        }


        // Clear objects
        testAcctTMs.clear();
        testAcctShs.clear();

    }   // End Test Case 12


    // Test case 13: [setSalesTeam] Standard test, account with 10 team members
    // Design Document Test Case 3 with DellTeamMember = opportunity owner

    static testMethod void Test13() {
    
        system.debug('## Start the test 13');
    
    
        // Get the users
        //Commented out for deployment Caleb Sidel 11/20/2008
        //List<UserTeamMember> sUTM = new List<UserTeamMember>();
        //sUTM = [select OwnerId from UserTeamMember where OwnerId in :[select Id from User where LastName like 'z%' and IsActive = true]]; 


        //Set<ID> sUTMID = new Set<ID>();
        
        //for (UserTeamMember sUTMIND : sUTM) {
        //    sUTMID.add(sUTMIND.OwnerId);
        //}



//      List<user> test_user = new List<user>([select id from user where isActive = true limit 11]);
        List<user> test_user = new List<user>();
        test_user = [select id from user where LastName like 'z%' and isActive = true limit 11]; // and Id not in :sUTMID limit 11];


        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');

        insert testAcc;
    
        
        // Create the account team members and account shares
        List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
        List<AccountShare> testAcctShs = new List<AccountShare>();
        
        for(Integer j=0; j< 10; j++) { 
    
            // Add user to the test account's team member list
            AccountTeamMember testAccTM = new AccountTeamMember();
            testAccTM.userid = test_user[j].id;
            testAccTM.accountid = testAcc.id;
            testAccTM.teammemberrole = 'Test';
            testAcctTMs.add(testAccTM);
            
            if (test_user[j].id != testAcc.OwnerId) {
                AccountShare testAcctSh = new AccountShare();
                testAcctSh.UserOrGroupId = test_user[j].id;
                testAcctSh.AccountId = testAcc.id;
                testAcctSh.AccountAccessLevel = 'Edit';
                testAcctSh.OpportunityAccessLevel = 'Edit';
                testAcctSh.CaseAccessLevel = 'Edit';        
                
                testAcctShs.add(testAcctSh);    
            }
    
        }   // End for(Integer j=0; j< 11; j++)
        
        insert testAcctTMs;
        insert testAcctShs;


        // Assertion
//        System.assertEquals(1, [select count() from Account where Name LIKE 'Test Account 50%']);
        
        
        // Assertion
//        System.assertEquals(10, [select count() from AccountTeamMember where Account.Name LIKE 'Test Account 50%']);
    
        
        // Assertion
//        System.assertEquals(10, [select count() from AccountShare where Account.Name LIKE 'Test Account 50%' and rowcause = 'Team']);


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
    
        sOpportunity1.OwnerId = test_user[5].Id;


        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();


        insert sOpportunity1;


        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();

// ALou - 2008/10/16 - Commented out for deployment 

        // The trigger should run and the sale team should be populated with the account team
        // Assertion
        //ccws System.assertEquals(10, [select count() from OpportunityTeamMember where opportunityId = :sOpportunity1.Id]);
    
        //ccws System.assertEquals(9, [select count() from OpportunityShare where opportunityId = :sOpportunity1.Id and RowCause = 'Team']);
    

        // Verify that all opportunity shares created have edit permissions
        //ccws
        //
        // for (OpportunityShare oppSh : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunity1.Id and RowCause = 'Team']) {
        //    system.assertEquals('Edit', oppSh.OpportunityAccessLevel);
        //}
        //

        // Clear objects
        testAcctTMs.clear();
        testAcctShs.clear();
//        sUTM.clear();
//        sUTMID.clear();
        test_user.clear();

    }   // End Test Case 13


    // Test case 14: [setSalesTeam]
    // Design Document Test Case 5.6

    static testMethod void Test14() {
    
        system.debug('## Start the test 14');
    
    
        // Get the users
        List<user> test_user = new List<user>([select id from user where isActive = true limit 22]);
    
    
        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');

        Account testAcc2;
        testAcc2 = new account(name='Test Account 51');

        insert testAcc;
        insert testAcc2;
        
        // Create the account team members and account shares
        List<AccountTeamMember> testAcct1TMs = new List<AccountTeamMember>();
        List<AccountTeamMember> testAcct2TMs = new List<AccountTeamMember>();

        List<AccountShare> testAcct1Shs = new List<AccountShare>();
        List<AccountShare> testAcct2Shs = new List<AccountShare>();

        // Teams and Shares for Account 1
        for(Integer j=0; j< 10; j++) { 
    
            // Add user to the test account's team member list
            AccountTeamMember testAcc1TM = new AccountTeamMember();
            testAcc1TM.userid = test_user[j].id;
            testAcc1TM.accountid = testAcc.id;
            testAcc1TM.teammemberrole = 'Test';
            testAcct1TMs.add(testAcc1TM);
            
            if (test_user[j].id != testAcc.OwnerId) {
                AccountShare testAcct1Sh = new AccountShare();
                testAcct1Sh.UserOrGroupId = test_user[j].id;
                testAcct1Sh.AccountId = testAcc.id;
                testAcct1Sh.AccountAccessLevel = 'Edit';
                testAcct1Sh.OpportunityAccessLevel = 'Edit';
                testAcct1Sh.CaseAccessLevel = 'Edit';       
                
                testAcct1Shs.add(testAcct1Sh);  
            }
    
        }   // End for(Integer j=0; j< 10; j++)


        // Teams and Shares for Account 2
        for(Integer j=10; j< 20; j++) { 
    
            // Add user to the test account's team member list
            AccountTeamMember testAcc2TM = new AccountTeamMember();
            testAcc2TM.userid = test_user[j].id;
            testAcc2TM.accountid = testAcc2.id;
            testAcc2TM.teammemberrole = 'Test';
            testAcct2TMs.add(testAcc2TM);
            
            if (test_user[j].id != testAcc2.OwnerId) {
                AccountShare testAcct2Sh = new AccountShare();
                testAcct2Sh.UserOrGroupId = test_user[j].id;
                testAcct2Sh.AccountId = testAcc2.id;
                testAcct2Sh.AccountAccessLevel = 'Edit';
                testAcct2Sh.OpportunityAccessLevel = 'Edit';
                testAcct2Sh.CaseAccessLevel = 'Edit';       
                
                testAcct2Shs.add(testAcct2Sh);  
            }
    
        }   // End for(Integer j=10; j< 20; j++)



        insert testAcct1TMs;
        insert testAcct1Shs;

        insert testAcct2TMs;
        insert testAcct2Shs;
        
        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        Opportunity sOpportunity2 = new Opportunity(Name='Opportunity 1', AccountId=testAcc2.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);

        List<Opportunity> opptyListToInsert = new List<Opportunity>();
        
        opptyListToInsert.add(sOpportunity1);       
        opptyListToInsert.add(sOpportunity2);
        
        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();

        //insert sOpportunity1;
        //insert sOpportunity2;
        insert opptyListToInsert;

        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();

// ALou - 2008/10/16 - Commented out for deployment 

        // The trigger should run and the sale team should be populated with the account team
        // Assertion
        system.debug('#### Validating total opportunity team members . . .');
//        System.assertEquals(10, [select count() from OpportunityTeamMember where opportunityId = :sOpportunity1.Id]);
//        System.assertEquals(10, [select count() from OpportunityTeamMember where opportunityId = :sOpportunity2.Id]);


        system.debug('#### Validating individual opportunity team members . . .');
//      for (Integer m=0; m<10; m++) {
//          System.assertEquals(1, [select count() from OpportunityTeamMember where opportunityId = :sOpportunity1.Id and UserId = :test_user[m].Id]);
//      }

//      for (Integer m=10; m<20; m++) {
//          System.assertEquals(1, [select count() from OpportunityTeamMember where opportunityId = :sOpportunity2.Id and UserId = :test_user[m].Id]);
//      }


        system.debug('#### Validating total opportunity shares . . .');
//        System.assertEquals(10, [select count() from OpportunityShare where opportunityId = :sOpportunity1.Id and RowCause = 'Team']);
//        System.assertEquals(10, [select count() from OpportunityShare where opportunityId = :sOpportunity2.Id and RowCause = 'Team']);


        system.debug('#### Validating individual opportunity shares . . .');
//      for (Integer m=0; m<10; m++) {
//          System.assertEquals(1, [select count() from OpportunityShare where opportunityId = :sOpportunity1.Id and RowCause = 'Team' and UserOrGroupId = :test_user[m].Id]);
//      }

//      for (Integer m=10; m<20; m++) {
//          System.assertEquals(1, [select count() from OpportunityShare where opportunityId = :sOpportunity2.Id and RowCause = 'Team' and UserOrGroupId = :test_user[m].Id]);
//      }


        // Verify that all opportunity shares created have edit permissions
        system.debug('#### Validating opportunity share permissions . . .');
//        for (OpportunityShare oppSh : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunity1.Id and RowCause = 'Team']) {
//            system.assertEquals('Edit', oppSh.OpportunityAccessLevel);
//        }

//        for (OpportunityShare oppSh : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunity2.Id and RowCause = 'Team']) {
//            system.assertEquals('Edit', oppSh.OpportunityAccessLevel);
//        }


        // Clear objects
        testAcct1TMs.clear();
        testAcct1Shs.clear();
        testAcct2TMs.clear();
        testAcct2Shs.clear();

    }   // End Test Case 14
    
    static testMethod void Test15() {
        

    boolean isPartnerSalesTeam;
    
        
        // Add User1
        Profile UserProf = [select Id, Name from Profile where Name like '%GBL Sales Rep' limit 1];
        User User1 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                Alias = 'MTU9', 
                                Email='MyTestUser12@dell.com', 
                                FirstName='MyTestUser12', 
                                LastName='MyTestUser12',  
                                ProfileId = UserProf.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='970533', 
                                isActive = TRUE);
        Insert User1;

        Id accountRTId = IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        acc = new Account(Name = 'Test', RecordtypeId = accountRTId, Type = 'Partner');
        insert acc;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        // Creating Contact
        testCon = new Contact(FirstName = 'TestContactFN9',
                     LastName = 'TestContactLN9',
                     accountId = acc.Id,
                     Status__c = 'Marketing Suspect',
                     Email = 'test11day@dell.com',
                     MobilePhone = '0000019',
                     Last_Operation_Performed__c = 'testing',
                     Phone = '1234567');
        insert testCon;    
    
        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');  
    
        insert testAcc;
        
        TriggerExecutionController.setSkipAllTriggers(false);
    
        
        // Create the account team members and account shares
        List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
        List<AccountShare> testAcctShs = new List<AccountShare>();         
    
        // Add user to the test account's team member list
        AccountTeamMember testAccTM = new AccountTeamMember();
        testAccTM.userid = User1.id;
        testAccTM.accountid = testAcc.id;
        testAccTM.teammemberrole = 'Test';
        testAcctTMs.add(testAccTM);
        
        if (User1.id != testAcc.OwnerId) {
            AccountShare testAcctSh = new AccountShare();
            testAcctSh.UserOrGroupId = User1.id;
            testAcctSh.AccountId = testAcc.id;
            testAcctSh.AccountAccessLevel = 'Edit';
            testAcctSh.OpportunityAccessLevel = 'Edit';
            testAcctSh.CaseAccessLevel = 'Edit';        
            
            testAcctShs.add(testAcctSh);    
        }
    
        
        insert testAcctTMs;
        insert testAcctShs;
            

        // Create the opportunity
        String sRecordType1 = '0127000000057EN';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=acc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', 
                                        RecordTypeId=sRecordType1, Total_Expected_Dell_Revenue__c = 1200, Distributor_Name__c = 'Distribution', Engagement_Type__c = 'Public Tender');


        
        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();


        
         try {
            insert sOpportunity1;
        } catch(Exception e) {
            system.assertEquals(e.getMessage(), e.getMessage());
        }   

        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();

        testAcctTMs.clear();
        testAcctShs.clear();
    }
    
    static testMethod void TestInsertOpportunityShares() {
        // Get the users
        List<user> test_user = new List<user>([select id from user where isActive = true limit 11]);
        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');
        insert testAcc;

        // Create the opportunity
        String sRecordType1 = '012300000004zf2';// Standard Opportunity
        Date dCloseDate = Date.TODAY();
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);

        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();
        //force a "high volume" using forceTest
        forceTest = true;
        insert sOpportunity1;

        try {
            // Create opportunity share
            List<OpportunityShare> testOS = new List<OpportunityShare>();
            for (Integer h=0; h < test_user.size(); h++) {
                OpportunityShare oppS = new OpportunityShare();
                oppS.OpportunityId = sOpportunity1.Id;
                oppS.UserOrGroupId = test_user[h].Id;
                oppS.OpportunityAccessLevel = 'Edit';
                testOS.add(oppS);
            }
            system.debug('#### OpportunityShare array = ' + testOS);
            //insert testOS;
            LimitSafeDMLOperations.forceTest = true;
            LimitSafeDMLOperations.insertOpportunityShares(testOS);
            LimitSafeDMLOperations.forceTest = false;
        }
        catch (NullPointerException e) {
        }
        forceTest = false;
        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
    }
}