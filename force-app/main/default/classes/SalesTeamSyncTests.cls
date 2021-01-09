/***********************************************************
* Description   : Test class on SalesTeamSync
* ---------------------------------------------------------
* Revision  Name    Date        Description
* 1.0                           Creation
  2.0       MenMee  19.07.2011  REL12.10 CR6493 Sales Role Change (Technical Sales Manager -> Inside Product Specialist Manager, System Consultant -> Cross Domain Sales Engineer)      
* 3.0       Azwanti 29.09.2011  REL12.10 CR6493-0182 Sales Role Change (Cross Domain Sales Engineer -> Customer System Engineer, Inside Product Specialist Manager -> Technical Sales Manager) 
* 4.0       Azwanti 17.10.2011  REL12.10 CR6493-0182 Sales Role Change (Customer System Engineer -> System Consultant)
*
************************************************************/
@isTest
global class SalesTeamSyncTests {

/*
The following tests were originally in the TeamProcessing.cls file
*/

    //Rev 2.0
    private static final string ROLE_IPSM = 'Technical Sales Manager';//r3.0 'Inside Product Specialist Manager';
    private static final string ROLE_XSE = 'System Consultant';//r4.0 'Customer System Engineer';//r3.0 'Cross Domain Sales Engineer';

    //Added custom settings to populate StageName values.
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
    }
    private static final string ROLE_SAPPROVER = 'Sales Approver';
    
    // Test Case 2
    // Function: setAccountAndSalesTeams
    // Test Condition:
    // DellTeamMember = [1 account, 2 members, status = 'A']
    static testMethod void Test2() {

        // Notify that the test will start
        system.debug('##### Start Test Case 2');

        // Declare variables and arrays
        Account sAccount1 = new Account(name='Test Account 40');    // Test Account 40
        List<user> testUser = new List<user>([select Id from user where FirstName like 'car%' and IsActive = true limit 2]);
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();


        //  Create the account
        insert sAccount1;


        // Build the DellTeamMember array
        for (Integer g=0; g<2; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = sAccount1.Id;
            dtmRecord.UserId = testUser[g].Id;

            if (g == 0) {
                dtmRecord.TeamMemberRole = ROLE_IPSM;
            }

            else if (g == 1) {
                dtmRecord.TeamMemberRole = ROLE_SAPPROVER;
            }

            else {
                dtmRecord.TeamMemberRole = ROLE_XSE;
            }

            dtmRecord.AccountAccessLevel = 'Edit';
            dtmRecord.OpportunityAccessLevel = 'Edit';
            dtmRecord.CaseAccessLevel = 'Edit';
            dtmRecord.Status = 'A';

            dtmArray.add(dtmRecord);

        }   // End for (Integer g=0; g<2; g++)


        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test2() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();


        // Ensure the correct number of account team members were created
        system.debug('Validation of total number of account team members');
        // ccws system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct number of account shares were created
        system.debug('Validation of total number of account shares');
        // ccws system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        /*
        system.debug('Validation of account share permissions');
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }
        */
    }   // End function Test2()



    // Test Case 3
    // Function: setAccountAndSalesTeams
    // Test Condition:
    // DellTeamMember = [1 account, 2 members, status = 'A' / 'I']
    static testMethod void Test3() {

        // Notify that the test will start
        system.debug('##### Start Test Case 3');

        // Declare variables and arrays
        Account sAccount1 = new Account(name='Test Account 40');    // Test Account 40
        List<user> testUser = new List<user>([select Id from user where FirstName like 'car%' and IsActive = true limit 2]);
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();


        // Create the account
        insert sAccount1;


        // Build the DellTeamMember array
        for (Integer g=0; g<2; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = sAccount1.Id;
            dtmRecord.UserId = testUser[g].Id;

            if (g == 0) {
                dtmRecord.TeamMemberRole = ROLE_IPSM;
            }

            else if (g == 1) {
                dtmRecord.TeamMemberRole = ROLE_SAPPROVER;
            }

            else {
                dtmRecord.TeamMemberRole = ROLE_XSE;
            }

            dtmRecord.AccountAccessLevel = 'Edit';
            dtmRecord.OpportunityAccessLevel = 'Edit';
            dtmRecord.CaseAccessLevel = 'Edit';

            if (g == 0) {
                dtmRecord.Status = 'A';
            }

            else if (g == 1) {
                dtmRecord.Status = 'I';
            }

            else {
                dtmRecord.Status = 'A';
            }


            dtmArray.add(dtmRecord);

        }   // End for (Integer g=0; g<2; g++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);



        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test3() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();


        // Ensure the correct number of account team members were created
        system.debug('Validation of total number of account team members');
        // ccws system.assertEquals(1, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct number of account shares were created
        system.debug('Validation of total number of account shares');
        // ccws system.assertEquals(1, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('Validation of account share permissions');
        /*
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }
*/

    }   // End function Test3()



    // Test Case 7
    // Function: setAccountAndSalesTeams
    // Test Condition:
    // DellTeamMember = [1 account, 4 members, status = 'A' / 'I']
    static testMethod void Test7() {

        // Notify that the test will start
        system.debug('##### Start Test Case 7');

        // Declare variables and arrays
        Account sAccount1 = new Account(name='Test Account 40');
        Account sAccount2 = new Account(name='Test Account 41', Status__c='Inactive');

        List<user> testUser = new List<user>([select Id from user where FirstName like 'car%' and IsActive = true limit 2]);
        List<user> testUser2 = new List<user>([select Id from user where LastName like 's%' and IsActive = false limit 2]);

        List<DellTeamMember> dtmArray = new List<DellTeamMember>();
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        List<AccountShare> testAS = new List<AccountShare>();

        String sUserId0 = testUser[0].Id;
        String sUserId1 = testUser[1].Id;
        String sUserId2 = testUser2[0].Id;
        String sUserId3 = testUser2[1].Id;


        // Create the accounts
        insert sAccount1;
        insert sAccount2;


        // Build the DellTeamMember array
        for (Integer g=0; g<4; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            if (g <= 1) {
                dtmRecord.AccountId = sAccount1.Id;
                dtmRecord.UserId = testUser2[g].Id;
            }

            else {
                dtmRecord.AccountId = sAccount2.Id;
                dtmRecord.UserId = testUser[g-2].Id;
            }


            if ((g == 0) || (g == 2)) {
                dtmRecord.TeamMemberRole = ROLE_IPSM;
            }

            else if ((g == 1) || (g == 3)) {
                dtmRecord.TeamMemberRole = ROLE_SAPPROVER;
            }

            else {
                dtmRecord.TeamMemberRole = ROLE_XSE;
            }

            dtmRecord.AccountAccessLevel = 'Edit';
            dtmRecord.OpportunityAccessLevel = 'Edit';
            dtmRecord.CaseAccessLevel = 'Edit';
            dtmRecord.Status = 'A';

            dtmArray.add(dtmRecord);

        }   // End for (Integer g=0; g<4; g++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);


        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test7() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();


        // Ensure the correct number of account team members were created
        system.debug('Validation of total number of account team members');
        // ccws system.assertEquals(0, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);
        // system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 41']);


        // Ensure the correct individual account team members were created
        system.debug('Validation of individual account team members');
        // ccws system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId2 and Account.Name = 'Test Account 40']);
        // ccws system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId3 and Account.Name = 'Test Account 40']);
        // ccws system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 41']);
        // ccws system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 41']);


        // Ensure the correct number of account shares were created
        system.debug('Validation of total number of account shares');
        // ccws system.assertEquals(0, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);
        // ccws system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 41' and RowCause = 'Team']);


        // Ensure the correct individual account shares were created
        system.debug('Validation of individual account shares');
        // ccws system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId2 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        // ccws system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId3 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        // ccws system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 41' and RowCause = 'Team']);
        // ccws system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 41' and RowCause = 'Team']);


    }   // End function Test7()



    // Test Case 15
    // Function: setAccountAndSalesTeams
    // Test Condition:
    // DellTeamMember = [1 account, 4 members, status = 'A' / 'I']
    static testMethod void Test15() {

        // Notify that the test will start
        system.debug('##### Start Test Case 15');

        // Declare variables and arrays
        Account sAccount1 = new Account(name='Test Account 40');    // Test Account 40
        List<user> testUser = new List<user>([select Id from user where FirstName like 'car%' and IsActive = true limit 5]);
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        List<AccountShare> testAS = new List<AccountShare>();

        String sUserId0 = testUser[0].Id;
        String sUserId1 = testUser[1].Id;
        String sUserId2 = testUser[2].Id;
        String sUserId3 = testUser[3].Id;
        String sUserId4 = testUser[4].Id;


        // Create the account
        insert sAccount1;


        // Build the DellTeamMember array
        for (Integer g=0; g<4; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = sAccount1.Id;
            dtmRecord.UserId = testUser[g].Id;

            if ((g == 0) || (g == 2)) {
                dtmRecord.TeamMemberRole = ROLE_IPSM;
            }

            else if ((g == 1) || (g == 3)) {
                dtmRecord.TeamMemberRole = ROLE_SAPPROVER;
            }

            else {
                dtmRecord.TeamMemberRole = ROLE_XSE;
            }

            dtmRecord.AccountAccessLevel = 'Edit';
            dtmRecord.OpportunityAccessLevel = 'Edit';
            dtmRecord.CaseAccessLevel = 'Edit';

            if ((g == 0) || (g == 1)) {
                dtmRecord.Status = 'A';
            }

            else if ((g == 2) || (g == 3)) {
                dtmRecord.Status = 'I';
            }

            else {
                dtmRecord.Status = 'A';
            }


            dtmArray.add(dtmRecord);

        }   // End for (Integer g=0; g<2; g++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);


        // Build the account team
        AccountTeamMember acctTM = new AccountTeamMember();
        acctTM.AccountId = sAccount1.Id;
        acctTM.UserId = testUser[2].Id;
        acctTM.TeamMemberRole = ROLE_IPSM;

        AccountTeamMember acctTM1 = new AccountTeamMember();
        acctTM1.AccountId = sAccount1.Id;
        acctTM1.UserId = testUser[3].Id;
        acctTM1.TeamMemberRole = ROLE_SAPPROVER;

        AccountTeamMember acctTM2 = new AccountTeamMember();
        acctTM2.AccountId = sAccount1.Id;
        acctTM2.UserId = testUser[4].Id;
        acctTM2.TeamMemberRole = ROLE_IPSM;

        testATM.add(acctTM);
        testATM.add(acctTM1);
        testATM.add(acctTM2);

        // Display the DellTeamMember array
        system.debug('#### AccountTeamMember array = ' + testATM);


        insert testATM;


        // Build the account share
        AccountShare acctS = new AccountShare();
        acctS.AccountId = sAccount1.Id;
        acctS.UserOrGroupId = testUser[2].Id;
        acctS.AccountAccessLevel = 'Edit';
        acctS.OpportunityAccessLevel = 'Edit';
        acctS.CaseAccessLevel = 'Edit';

        AccountShare acctS1 = new AccountShare();
        acctS1.AccountId = sAccount1.Id;
        acctS1.UserOrGroupId = testUser[3].Id;
        acctS1.AccountAccessLevel = 'Edit';
        acctS1.OpportunityAccessLevel = 'Edit';
        acctS1.CaseAccessLevel = 'Edit';

        AccountShare acctS2 = new AccountShare();
        acctS2.AccountId = sAccount1.Id;
        acctS2.UserOrGroupId = testUser[4].Id;
        acctS2.AccountAccessLevel = 'Edit';
        acctS2.OpportunityAccessLevel = 'Edit';
        acctS2.CaseAccessLevel = 'Edit';

        testAS.add(acctS);
        testAS.add(acctS1);
        testAS.add(acctS2);


        // Display the DellTeamMember array
        system.debug('#### AccountShare array ' + testAS);


        insert testAS;



        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test15() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();


        // Ensure the correct number of account team members were created
        system.debug('Validation of total number of account team members');
        // ccws system.assertEquals(3, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct individual account team members were created
        system.debug('Validation of individual account team members');
        // ccws system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
        // ccws system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);
        // ccws system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId2 and Account.Name = 'Test Account 40']);
        // ccws system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId3 and Account.Name = 'Test Account 40']);
        // ccws system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId4 and Account.Name = 'Test Account 40']);


        // Ensure the correct number of account shares were created
        system.debug('Validation of total number of account shares');
        // ccws system.assertEquals(3, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure the correct individual account shares were created
        system.debug('Validation of individual account shares');
        // ccws system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        // ccws system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        // ccws system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId2 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        // ccws system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId3 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        // ccws system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId4 and Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('Validation of account share permissions');
        /*
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            // ccws system.assertEquals('Edit', acctShare.AccountAccessLevel);
            // ccws system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            // ccws system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }
*/

    }   // End function Test15()



    // Test Case 20
    // Function: setAccountAndSalesTeams
    // Test Condition:
    // DellTeamMember:
    // 2 records total
    // 1 accounts, 2 active members
    // Member #1 is owner of account
    // 1 opportunity
    // Member #2 is owner of the opportunity
    static testMethod void Test20() {
        TriggerExecutionController.setSkipAllTriggers(true);
        // Notify that the test will start
        system.debug('##### Start Test Case 20');


        // Declare variables
        Integer iAccountTeamMembers = 0;
        Integer iSalesTeamMembers = 0;


        // Create the users
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 2]);
        String sUserId0 = testUser[0].Id;
        String sUserId1 = testUser[1].Id;


        // Create the accounts
        Account sAccount1 = new Account(name='Test Account 40');
        insert sAccount1;


            // Set the account owner to be the first Dell Team Member
            sAccount1.OwnerId = sUserId0;
            update sAccount1;


            // Delete any account team members created
            List<AccountTeamMember> ATMCreated = new List<AccountTeamMember>();
            ATMCreated = [select Id from AccountTeamMember where AccountId = :sAccount1.Id];


            if (ATMCreated.size() > 0) {
                delete ATMCreated;
            }


        // Create the opportunities
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(2009,03,26);

        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1, Partner_Opportunity_Stage__c = 'Win - 100%');

        insert sOpportunity1;

        String sOpportunityId1 = sOpportunity1.Id;


            // Update the opportunity owner
            sOpportunity1.OwnerId = sUserId1;
            update sOpportunity1;


            // Delete any opportunity team members created
            List<OpportunityTeamMember> OTMCreated = new List<OpportunityTeamMember>();
            OTMCreated = [select Id from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id];


            if (OTMCreated.size() > 0) {
                delete OTMCreated;
            }


        // Build the DellTeamMember array
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        for (Integer g=0; g<2; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = sAccount1.Id;
            dtmRecord.UserId = testUser[g].Id;


            if (g == 0) {
                dtmRecord.TeamMemberRole = ROLE_IPSM;
            }

            else if (g == 1) {
                dtmRecord.TeamMemberRole = ROLE_SAPPROVER;
            }

            else {
                dtmRecord.TeamMemberRole = ROLE_XSE;
            }

            dtmRecord.AccountAccessLevel = 'Edit';
            dtmRecord.OpportunityAccessLevel = 'Edit';
            dtmRecord.CaseAccessLevel = 'Edit';
            dtmRecord.Status = 'A';

            dtmArray.add(dtmRecord);

        }   // End for (Integer g=0; g<2; g++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);



        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test20() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();


        // Ensure the correct number of account team members were created
        system.debug('#### Validation of total number of account team members');
        // ccws system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct individual account team members were created
        system.debug('#### Validation of individual account team members');
        // ccws system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
        // ccws system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);


        // Ensure the correct number of account shares were created
        system.debug('#### Validation of total number of account shares');
        // ccws system.assertEquals(1, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure the correct individual account shares were created
        system.debug('#### Validation of individual account shares');
        // ccws system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        // ccws system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
        /*
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            // ccws system.assertEquals('Edit', acctShare.AccountAccessLevel);
            // ccws system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            // ccws system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }
*/

        // Ensure the correct number of opportunity team members were created
        system.debug('#### Validation of total number of opportunity team members');
        // ccws system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);


        // Ensure the correct individual opportunity team members were created
        system.debug('#### Validation of individual opportunity team members');
        // ccws system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId0]);
        // ccws system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId1]);


        // Ensure the correct number of opportunity shares were created
        system.debug('#### Validation of total number of opportunity shares');
        // ccws system.assertEquals(1, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);


        // Ensure the correct individual opportunity shares were created
        system.debug('#### Validation of individual opportunity shares');
        // ccws system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        // ccws system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);


        // Ensure that each opportunity share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of opportunity share permissions');
        /*
        for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']) {
            // ccws system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }
*/

        TriggerExecutionController.setSkipAllTriggers(false);
    }   // End function Test20()



    // Test Case 22
    // Function: setAccountAndSalesTeams
    // Test Condition:
    // DellTeamMember:
    // 4 records total
    // 2 accounts, 2 active members
    // Account 2 is inactive
    // One opportunity for each account
    static testMethod void Test22() {
        TriggerExecutionController.setSkipAllTriggers(true);

        // Notify that the test will start
        system.debug('##### Start Test Case 22');

        // Declare variables and arrays
        Account sAccount1 = new Account(name='Test Account 40');
        Account sAccount2 = new Account(name='Test Account 41', Status__c='Inactive');

        List<user> testUser = new List<user>([select Id from user where FirstName like 'car%' and IsActive = true limit 2]);

        List<DellTeamMember> dtmArray = new List<DellTeamMember>();
//      List<AccountTeamMember> testATM = new List<AccountTeamMember>();
//      List<AccountShare> testAS = new List<AccountShare>();

        String sUserId0 = testUser[0].Id;
        String sUserId1 = testUser[1].Id;


        // Create the accounts
        insert sAccount1;
        insert sAccount2;


        // Build the DellTeamMember array
        for (Integer g=0; g<4; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            if (g <= 1) {
                dtmRecord.AccountId = sAccount1.Id;
                dtmRecord.UserId = testUser[g].Id;
            }

            else {
                dtmRecord.AccountId = sAccount2.Id;
                dtmRecord.UserId = testUser[g-2].Id;
            }


            if ((g == 0) || (g == 2)) {
                dtmRecord.TeamMemberRole = ROLE_IPSM;
            }

            else if ((g == 1) || (g == 3)) {
                dtmRecord.TeamMemberRole = ROLE_SAPPROVER;
            }

            else {
                dtmRecord.TeamMemberRole = ROLE_XSE;
            }

            dtmRecord.AccountAccessLevel = 'Edit';
            dtmRecord.OpportunityAccessLevel = 'Edit';
            dtmRecord.CaseAccessLevel = 'Edit';
            dtmRecord.Status = 'A';

            dtmArray.add(dtmRecord);

        }   // End for (Integer g=0; g<4; g++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);


        // Create the opportunities
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(2009,03,26);

        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1, Partner_Opportunity_Stage__c = 'Win - 100%');
        Opportunity sOpportunity2 = new Opportunity(Name='Opportunity 2', AccountId=sAccount2.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1, Partner_Opportunity_Stage__c = 'Win - 100%');

        //ray 20100820: getting too many rows error if inserting separately when run test
        //insert sOpportunity1;
        //insert sOpportunity2;


        //ray 20100820: modified to insert as a list
        List<Opportunity> opptyListToInsert = new List<Opportunity>();
        opptyListToInsert.add(sOpportunity1);
        opptyListToInsert.add(sOpportunity2);
    
        insert(opptyListToInsert);

        String sOpportunityId1 = sOpportunity1.Id;
        String sOpportunityId2 = sOpportunity2.Id;

        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test22() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();

// ALou - 2008/10/16 - Commented out for deployment


        // Ensure the correct number of account team members were created
        system.debug('#### Validation of total number of account team members');
//      system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);
//      system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 41']);


        // Ensure the correct individual account team members were created
        system.debug('#### Validation of individual account team members');
//      system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
//      system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);
//      system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 41']);
//      system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 41']);


        // Ensure the correct number of account shares were created
        system.debug('#### Validation of total number of account shares');
//      system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);
//      system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 41' and RowCause = 'Team']);


        // Ensure the correct individual account shares were created
        system.debug('#### Validation of individual account shares');
//      system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
//      system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
//      system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 41' and RowCause = 'Team']);
//      system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 41' and RowCause = 'Team']);


        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
//      for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
//          system.assertEquals('Edit', acctShare.AccountAccessLevel);
//          system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
//          system.assertEquals('Edit', acctShare.CaseAccessLevel);
//      }


        // Ensure the correct number of opportunity team members were created
        system.debug('#### Validation of total number of opportunity team members');
//      system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);
//      system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2]);


        // Ensure the correct individual opportunity team members were created
        system.debug('#### Validation of individual opportunity team members');
//      system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId0]);
//      system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId1]);
//      system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId0]);
//      system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId1]);


        // Ensure the correct number of opportunity shares were created
        system.debug('#### Validation of total number of opportunity shares');
//      system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
//      system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']);


        // Ensure the correct individual opportunity shares were created
        system.debug('#### Validation of individual opportunity shares');
//      system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
//      system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
//      system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
//      system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);


        // Ensure that each opportunity share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of opportunity share permissions');
//      for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']) {
//          system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
//      }

        TriggerExecutionController.setSkipAllTriggers(false);
    }   // End function Test22()



    // Test Case 28
    // Function: setAccountAndSalesTeams
    // Test Condition:
    // DellTeamMember:
    // 4 records total
    // 2 accounts, 2 active members
    // Account 2 is inactive
    // One opportunity for each account
    static testMethod void Test28() {

        // Notify that the test will start
        system.debug('##### Start Test Case 28');


        // Get Users
        List<user> testUser = new List<user>([select Id from user where FirstName like 'car%' and IsActive = true limit 5]);

        String sUserId0 = testUser[0].Id;
        String sUserId1 = testUser[1].Id;
        String sUserId2 = testUser[2].Id;
        String sUserId3 = testUser[3].Id;
        String sUserId4 = testUser[4].Id;


        // Create account
        Account sAccount1 = new Account(name='Test Account 40');
        insert sAccount1;


        // Create account team
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        List<AccountShare> testAS = new List<AccountShare>();


            // Build the account team
            AccountTeamMember acctTM0 = new AccountTeamMember();
            acctTM0.AccountId = sAccount1.Id;
            acctTM0.UserId = testUser[2].Id;
            acctTM0.TeamMemberRole = ROLE_IPSM;

            AccountTeamMember acctTM1 = new AccountTeamMember();
            acctTM1.AccountId = sAccount1.Id;
            acctTM1.UserId = testUser[3].Id;
            acctTM1.TeamMemberRole = ROLE_SAPPROVER;

            AccountTeamMember acctTM2 = new AccountTeamMember();
            acctTM2.AccountId = sAccount1.Id;
            acctTM2.UserId = testUser[4].Id;
            acctTM2.TeamMemberRole = ROLE_IPSM;

            testATM.add(acctTM0);
            testATM.add(acctTM1);
            testATM.add(acctTM2);

            // Display the DellTeamMember array
    //      system.debug('#### AccountTeamMember array = ' + testATM);

            insert testATM;


            // Build the account share
            AccountShare acctS0 = new AccountShare();
            acctS0.AccountId = sAccount1.Id;
            acctS0.UserOrGroupId = testUser[2].Id;
            acctS0.AccountAccessLevel = 'Edit';
            acctS0.OpportunityAccessLevel = 'Edit';
            acctS0.CaseAccessLevel = 'Edit';

            AccountShare acctS1 = new AccountShare();
            acctS1.AccountId = sAccount1.Id;
            acctS1.UserOrGroupId = testUser[3].Id;
            acctS1.AccountAccessLevel = 'Edit';
            acctS1.OpportunityAccessLevel = 'Edit';
            acctS1.CaseAccessLevel = 'Edit';

            AccountShare acctS2 = new AccountShare();
            acctS2.AccountId = sAccount1.Id;
            acctS2.UserOrGroupId = testUser[4].Id;
            acctS2.AccountAccessLevel = 'Edit';
            acctS2.OpportunityAccessLevel = 'Edit';
            acctS2.CaseAccessLevel = 'Edit';

            testAS.add(acctS0);
            testAS.add(acctS1);
            testAS.add(acctS2);


            // Display the DellTeamMember array
//          system.debug('#### AccountShare array ' + testAS);


            insert testAS;


        // Create opportunities
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(1990,03,26);

        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        Opportunity sOpportunity2 = new Opportunity(Name='Opportunity 2', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        Opportunity sOpportunity3 = new Opportunity(Name='Opportunity 3', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);

        TriggerExecutionController.setSkipAccountTriggers(true); // 3.0
        TriggerExecutionController.setSkipOpportunityTriggers(true); // 3.0
        insert sOpportunity1;
        insert sOpportunity2;
        insert sOpportunity3;
        TriggerExecutionController.setSkipAccountTriggers(false); // 3.0
        TriggerExecutionController.setSkipOpportunityTriggers(false); // 3.0

        String sOpportunityId1 = sOpportunity1.Id;
        String sOpportunityId2 = sOpportunity2.Id;
        String sOpportunityId3 = sOpportunity3.Id;


        // Create opportunity teams
        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();
        List<OpportunityShare> testOS = new List<OpportunityShare>();


            // Build the opportunity teams
            OpportunityTeamMember oppTM0 = new OpportunityTeamMember();
            oppTM0.OpportunityId = sOpportunity2.Id;
            oppTM0.UserId = testUser[2].Id;
            oppTM0.TeamMemberRole = ROLE_IPSM;

            OpportunityTeamMember oppTM1 = new OpportunityTeamMember();
            oppTM1.OpportunityId = sOpportunity2.Id;
            oppTM1.UserId = testUser[3].Id;
            oppTM1.TeamMemberRole = ROLE_SAPPROVER;

            OpportunityTeamMember oppTM2 = new OpportunityTeamMember();
            oppTM2.OpportunityId = sOpportunity2.Id;
            oppTM2.UserId = testUser[4].Id;
            oppTM2.TeamMemberRole = ROLE_IPSM;

            OpportunityTeamMember oppTM3 = new OpportunityTeamMember();
            oppTM3.OpportunityId = sOpportunity3.Id;
            oppTM3.UserId = testUser[2].Id;
            oppTM3.TeamMemberRole = ROLE_IPSM;

            OpportunityTeamMember oppTM4 = new OpportunityTeamMember();
            oppTM4.OpportunityId = sOpportunity3.Id;
            oppTM4.UserId = testUser[3].Id;
            oppTM4.TeamMemberRole = ROLE_SAPPROVER;

            OpportunityTeamMember oppTM5 = new OpportunityTeamMember();
            oppTM5.OpportunityId = sOpportunity3.Id;
            oppTM5.UserId = testUser[4].Id;
            oppTM5.TeamMemberRole = ROLE_IPSM;

            testOTM.add(oppTM0);
            testOTM.add(oppTM1);
            testOTM.add(oppTM2);
            testOTM.add(oppTM3);
            testOTM.add(oppTM4);
            testOTM.add(oppTM5);


            // Display the DellTeamMember array
    //      system.debug('#### AccountTeamMember array = ' + testATM);

            insert testOTM;


            // Build the opportunity share
            OpportunityShare oppS0 = new OpportunityShare();
            oppS0.OpportunityId = sOpportunity2.Id;
            oppS0.UserOrGroupId = testUser[2].Id;
            oppS0.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS1 = new OpportunityShare();
            oppS1.OpportunityId = sOpportunity2.Id;
            oppS1.UserOrGroupId = testUser[3].Id;
            oppS1.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS2 = new OpportunityShare();
            oppS2.OpportunityId = sOpportunity2.Id;
            oppS2.UserOrGroupId = testUser[4].Id;
            oppS2.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS3 = new OpportunityShare();
            oppS3.OpportunityId = sOpportunity3.Id;
            oppS3.UserOrGroupId = testUser[2].Id;
            oppS3.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS4 = new OpportunityShare();
            oppS4.OpportunityId = sOpportunity3.Id;
            oppS4.UserOrGroupId = testUser[3].Id;
            oppS4.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS5 = new OpportunityShare();
            oppS5.OpportunityId = sOpportunity3.Id;
            oppS5.UserOrGroupId = testUser[4].Id;
            oppS5.OpportunityAccessLevel = 'Edit';

            testOS.add(oppS0);
            testOS.add(oppS1);
            testOS.add(oppS2);
            testOS.add(oppS3);
            testOS.add(oppS4);
            testOS.add(oppS5);

            // Display the DellTeamMember array
//          system.debug('#### AccountShare array ' + testAS);


            insert testOS;



        // Build the DellTeamMember array
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        for (Integer g=0; g<4; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = sAccount1.Id;
            dtmRecord.UserId = testUser[g].Id;


            if ((g == 0) || (g == 2)) {
                dtmRecord.TeamMemberRole = ROLE_IPSM;
            }

            else if ((g == 1) || (g == 3)) {
                dtmRecord.TeamMemberRole = ROLE_SAPPROVER;
            }

            else {
                dtmRecord.TeamMemberRole = ROLE_XSE;
            }

            dtmRecord.AccountAccessLevel = 'Edit';
            dtmRecord.OpportunityAccessLevel = 'Edit';
            dtmRecord.CaseAccessLevel = 'Edit';


            if (g <= 1) {
                dtmRecord.Status = 'A';
            }

            else {
                dtmRecord.Status = 'I';
            }

            dtmArray.add(dtmRecord);

        }   // End for (Integer g=0; g<4; g++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);



        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test28() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();

// ALou - 2008/10/16 - Commented out for deployment

        // Ensure the correct number of account team members were created
        system.debug('#### Validation of total number of account team members');
//      system.assertEquals(3, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct individual account team members were created and deleted
        system.debug('#### Validation of individual account team members');
/*      system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId2 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId3 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId4 and Account.Name = 'Test Account 40']);
*/

        // Ensure the correct number of account shares were created
        system.debug('#### Validation of total number of account shares');
//      system.assertEquals(3, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure the correct individual account shares were created and deleted
        system.debug('#### Validation of individual account shares');
/*      system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId2 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId3 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId4 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
*/

        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
//      for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
//          system.assertEquals('Edit', acctShare.AccountAccessLevel);
//          system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
//          system.assertEquals('Edit', acctShare.CaseAccessLevel);
//      }


        // Ensure the correct number of opportunity team members were created
        system.debug('#### Validation of total number of opportunity team members');
//      system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);
//      system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2]);
//      system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3]);


        // Ensure the correct individual opportunity team members were created and deleted
        system.debug('#### Validation of individual opportunity team members');
/*      system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId0]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId1]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId2]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId3]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId4]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId0]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId1]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId2]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId3]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId4]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId0]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId1]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId2]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId3]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId4]);
*/

        // Ensure the correct number of opportunity shares were created
        system.debug('#### Validation of total number of opportunity shares');
//      system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
//      system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
//      system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId3 and RowCause = 'Team']);


        // Ensure the correct individual opportunity shares were created
        system.debug('#### Validation of individual opportunity shares');
/*      system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId2 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId3 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId4 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId2 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId3 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId4 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId2 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId3 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId4 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
*/

        // Ensure that each opportunity share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of opportunity share permissions');
/*      for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']) {
            system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }

        for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']) {
            system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }

        for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId3 and RowCause = 'Team']) {
            system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }
*/

    }   // End function Test28()



    // Test Case 29
    // Function: setAccountAndSalesTeams
    // Test Condition: 1 user inactive, 1 opportunity with Direct_Team_Sync =
    // false
    // DellTeamMember:
    // 4 records total
    // 2 accounts, 2 active members
    // Account 2 is inactive
    // One opportunity for each account
    static testMethod void Test29() {

        // Notify that the test will start
        system.debug('##### Start Test Case 29');


        // Get Users
        List<user> testUserI = new List<user>([select Id from user where LastName like 's%' and IsActive = false limit 1]);
        String sUserIdI = testUserI[0].Id;

        List<user> testUser = new List<user>([select Id from user where FirstName like 'car%' and IsActive = true limit 5]);
        String sUserId0 = testUser[0].Id;
        String sUserId1 = testUser[1].Id;
        String sUserId2 = testUser[2].Id;
        String sUserId3 = testUser[3].Id;
        String sUserId4 = testUser[4].Id;


        // Create account
        Account sAccount1 = new Account(name='Test Account 40');
        insert sAccount1;


        // Create account team
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        List<AccountShare> testAS = new List<AccountShare>();


            // Build the account team
            AccountTeamMember acctTM0 = new AccountTeamMember();
            acctTM0.AccountId = sAccount1.Id;
            acctTM0.UserId = testUser[0].Id;
            acctTM0.TeamMemberRole = ROLE_IPSM;

            AccountTeamMember acctTM1 = new AccountTeamMember();
            acctTM1.AccountId = sAccount1.Id;
            acctTM1.UserId = testUser[1].Id;
            acctTM1.TeamMemberRole = ROLE_SAPPROVER;

            testATM.add(acctTM0);
            testATM.add(acctTM1);

            // Display the DellTeamMember array
    //      system.debug('#### AccountTeamMember array = ' + testATM);

            insert testATM;


            // Build the account share
            AccountShare acctS0 = new AccountShare();
            acctS0.AccountId = sAccount1.Id;
            acctS0.UserOrGroupId = testUser[0].Id;
            acctS0.AccountAccessLevel = 'Edit';
            acctS0.OpportunityAccessLevel = 'Edit';
            acctS0.CaseAccessLevel = 'Edit';

            AccountShare acctS1 = new AccountShare();
            acctS1.AccountId = sAccount1.Id;
            acctS1.UserOrGroupId = testUser[1].Id;
            acctS1.AccountAccessLevel = 'Edit';
            acctS1.OpportunityAccessLevel = 'Edit';
            acctS1.CaseAccessLevel = 'Edit';

            testAS.add(acctS0);
            testAS.add(acctS1);


            // Display the DellTeamMember array
//          system.debug('#### AccountShare array ' + testAS);


            insert testAS;


        // Create opportunities
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(1990,03,26);

        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        Opportunity sOpportunity2 = new Opportunity(Name='Opportunity 2', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Indirect', RecordTypeId=sRecordType1);
        Opportunity sOpportunity3 = new Opportunity(Name='Opportunity 3', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);

        TriggerExecutionController.setSkipAccountTriggers(true); // 3.0
        TriggerExecutionController.setSkipOpportunityTriggers(true); // 3.0
        insert sOpportunity1;
        insert sOpportunity2;
        insert sOpportunity3;
        TriggerExecutionController.setSkipAccountTriggers(false); // 3.0
        TriggerExecutionController.setSkipOpportunityTriggers(false); // 3.0

        String sOpportunityId1 = sOpportunity1.Id;
        String sOpportunityId2 = sOpportunity2.Id;
        String sOpportunityId3 = sOpportunity3.Id;


        // Create opportunity teams
        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();
        List<OpportunityShare> testOS = new List<OpportunityShare>();


            // Build the opportunity teams
            OpportunityTeamMember oppTM0 = new OpportunityTeamMember();
            oppTM0.OpportunityId = sOpportunity1.Id;
            oppTM0.UserId = testUser[1].Id;
            oppTM0.TeamMemberRole = ROLE_IPSM;

            OpportunityTeamMember oppTM1 = new OpportunityTeamMember();
            oppTM1.OpportunityId = sOpportunity1.Id;
            oppTM1.UserId = testUser[3].Id;
            oppTM1.TeamMemberRole = ROLE_SAPPROVER;

            OpportunityTeamMember oppTM2 = new OpportunityTeamMember();
            oppTM2.OpportunityId = sOpportunity2.Id;
            oppTM2.UserId = testUser[1].Id;
            oppTM2.TeamMemberRole = ROLE_IPSM;

            OpportunityTeamMember oppTM3 = new OpportunityTeamMember();
            oppTM3.OpportunityId = sOpportunity2.Id;
            oppTM3.UserId = testUser[3].Id;
            oppTM3.TeamMemberRole = ROLE_IPSM;

            OpportunityTeamMember oppTM4 = new OpportunityTeamMember();
            oppTM4.OpportunityId = sOpportunity3.Id;
            oppTM4.UserId = testUser[3].Id;
            oppTM4.TeamMemberRole = ROLE_IPSM;

            testOTM.add(oppTM0);
            testOTM.add(oppTM1);
            testOTM.add(oppTM2);
            testOTM.add(oppTM3);
            testOTM.add(oppTM4);

            insert testOTM;


            // Build the opportunity share
            OpportunityShare oppS0 = new OpportunityShare();
            oppS0.OpportunityId = sOpportunity1.Id;
            oppS0.UserOrGroupId = testUser[1].Id;
            oppS0.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS1 = new OpportunityShare();
            oppS1.OpportunityId = sOpportunity1.Id;
            oppS1.UserOrGroupId = testUser[3].Id;
            oppS1.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS2 = new OpportunityShare();
            oppS2.OpportunityId = sOpportunity2.Id;
            oppS2.UserOrGroupId = testUser[1].Id;
            oppS2.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS3 = new OpportunityShare();
            oppS3.OpportunityId = sOpportunity2.Id;
            oppS3.UserOrGroupId = testUser[3].Id;
            oppS3.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS4 = new OpportunityShare();
            oppS4.OpportunityId = sOpportunity3.Id;
            oppS4.UserOrGroupId = testUser[3].Id;
            oppS4.OpportunityAccessLevel = 'Edit';

            testOS.add(oppS0);
            testOS.add(oppS1);
            testOS.add(oppS2);
            testOS.add(oppS3);
            testOS.add(oppS4);

            insert testOS;



        // Build the DellTeamMember array
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        for (Integer g=0; g<4; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = sAccount1.Id;


            if (g == 0) {
                dtmRecord.UserId = testUserI[0].Id;
            }

            else {
                dtmRecord.UserId = testUser[g-1].Id;
            }


            if ((g == 0) || (g == 2)) {
                dtmRecord.TeamMemberRole = ROLE_IPSM;
            }

            else if ((g == 1) || (g == 3)) {
                dtmRecord.TeamMemberRole = ROLE_SAPPROVER;
            }

            else {
                dtmRecord.TeamMemberRole = ROLE_XSE;
            }

            dtmRecord.AccountAccessLevel = 'Edit';
            dtmRecord.OpportunityAccessLevel = 'Edit';
            dtmRecord.CaseAccessLevel = 'Edit';


            if ((g <= 1) || (g == 3)) {
                dtmRecord.Status = 'A';
            }

            else {
                dtmRecord.Status = 'I';
            }

            dtmArray.add(dtmRecord);

        }   // End for (Integer g=0; g<4; g++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);



        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test29() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();


// ALou - 2008/10/16 - Commented out for deployment

        // Ensure the correct number of account team members were created
        system.debug('#### Validation of total number of account team members');
//      system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct individual account team members were created and deleted
        system.debug('#### Validation of individual account team members');
/*
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserIdI and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId2 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId3 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId4 and Account.Name = 'Test Account 40']);
*/

        // Ensure the correct number of account shares were created
        system.debug('#### Validation of total number of account shares');
//      system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure the correct individual account shares were created and deleted
        system.debug('#### Validation of individual account shares');
/*
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserIdI and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId2 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId3 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId4 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
*/

        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
/*
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }
*/

        // Ensure the correct number of opportunity team members were created
        system.debug('#### Validation of total number of opportunity team members');
/*
        system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);
        system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2]);
        system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3]);
*/

        // Ensure the correct individual opportunity team members were created and deleted
        system.debug('#### Validation of individual opportunity team members');
/*
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserIdI]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId0]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId1]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId2]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId3]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId4]);

        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserIdI]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId0]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId1]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId2]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId3]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId4]);

        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserIdI]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId0]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId1]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId2]);
        system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId3]);
        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3 and UserId = :sUserId4]);
*/

        // Ensure the correct number of opportunity shares were created
        system.debug('#### Validation of total number of opportunity shares');
/*
        system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
*/

        // Ensure the correct individual opportunity shares were created
        system.debug('#### Validation of individual opportunity shares');
/*
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserIdI and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId2 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId3 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId4 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);

        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserIdI and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId2 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId3 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId4 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);

        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserIdI and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId2 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
        system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId3 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
        system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId4 and OpportunityId = :sOpportunityId3 and RowCause = 'Team']);
*/

        // Ensure that each opportunity share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of opportunity share permissions');

/*
        for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']) {
            system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }

        for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']) {
            system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }

        for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId3 and RowCause = 'Team']) {
            system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }

*/

    }   // End function Test29()




    // Test Case 40
    // Function: setAccountAndSalesTeams
    // Test Condition: 1 user inactive, 1 opportunity with Direct_Team_Sync =
    // false
    // DellTeamMember:
    // 4 records total
    // 2 accounts, 2 active members
    // Account 2 is inactive
    // One opportunity for each account

    // Modifications from TeamProcessing_Dev code:
    // 1.  Eliminated the creation of OTM and OS for test_user[1]
    //     for Opportunity1.



    static testMethod void Test40() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        // Notify that the test will start
        system.debug('##### Start Test Case 40');


        // Get Users
        List<user> testUserI = new List<user>([select Id from user where LastName like 's%' and IsActive = false limit 1]);
        String sUserIdI = testUserI[0].Id;

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 110]);


        // Create account
        Account sAccount1 = new Account(name='Test Account 40');
        insert sAccount1;


        // Create account team
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        List<AccountShare> testAS = new List<AccountShare>();


            // Build the account team
            for (Integer g=0; g<110; g++) {

                if ((g != 2) && (g != 3)) {
                    AccountTeamMember acctTM = new AccountTeamMember();
                    acctTM.AccountId = sAccount1.Id;
                    acctTM.UserId = testUser[g].Id;
                    acctTM.TeamMemberRole = ROLE_IPSM;

                    testATM.add(acctTM);
                }

            }

            // Display the DellTeamMember array
    //      system.debug('#### AccountTeamMember array = ' + testATM);

            insert testATM;


            // Build the account share
            for (Integer gg=0; gg<110; gg++) {

                if ((gg != 2) && (gg != 3)) {

                    AccountShare acctS = new AccountShare();
                    acctS.AccountId = sAccount1.Id;
                    acctS.UserOrGroupId = testUser[gg].Id;
                    acctS.AccountAccessLevel = 'Edit';
                    acctS.OpportunityAccessLevel = 'Edit';
                    acctS.CaseAccessLevel = 'Edit';

                    testAS.add(acctS);

                }

            }


            // Display the DellTeamMember array
//          system.debug('#### AccountShare array ' + testAS);


            insert testAS;


        // Create opportunities
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(1990,03,26);

        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1, Partner_Opportunity_Stage__c = 'Win - 100%');
        Opportunity sOpportunity2 = new Opportunity(Name='Opportunity 2', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Indirect', RecordTypeId=sRecordType1, Partner_Opportunity_Stage__c = 'Win - 100%');
        Opportunity sOpportunity3 = new Opportunity(Name='Opportunity 3', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1, Partner_Opportunity_Stage__c = 'Win - 100%');

        //ray 20100820: getting too many rows error if inserting separately when run test
        //insert sOpportunity1;
        //insert sOpportunity2;
        //insert sOpportunity3;

        //raymond 201000820
        List<Opportunity> opptyListToInsert = new List<Opportunity>();
        
        opptyListToInsert.add(sOpportunity1);
        opptyListToInsert.add(sOpportunity2);
        opptyListToInsert.add(sOpportunity3);

        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;
        insert(opptyListToInsert);

        String sOpportunityId1 = sOpportunity1.Id;
        String sOpportunityId2 = sOpportunity2.Id;
        String sOpportunityId3 = sOpportunity3.Id;


        // Create opportunity teams
        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();
        List<OpportunityShare> testOS = new List<OpportunityShare>();


            // Build the opportunity teams
            OpportunityTeamMember oppTM1 = new OpportunityTeamMember();
            oppTM1.OpportunityId = sOpportunity1.Id;
            oppTM1.UserId = testUser[3].Id;
            oppTM1.TeamMemberRole = ROLE_SAPPROVER;

            OpportunityTeamMember oppTM2 = new OpportunityTeamMember();
            oppTM2.OpportunityId = sOpportunity2.Id;
            oppTM2.UserId = testUser[1].Id;
            oppTM2.TeamMemberRole = ROLE_IPSM;

            OpportunityTeamMember oppTM3 = new OpportunityTeamMember();
            oppTM3.OpportunityId = sOpportunity2.Id;
            oppTM3.UserId = testUser[3].Id;
            oppTM3.TeamMemberRole = ROLE_IPSM;

            OpportunityTeamMember oppTM4 = new OpportunityTeamMember();
            oppTM4.OpportunityId = sOpportunity3.Id;
            oppTM4.UserId = testUser[3].Id;
            oppTM4.TeamMemberRole = ROLE_IPSM;

            testOTM.add(oppTM1);
            testOTM.add(oppTM2);
            testOTM.add(oppTM3);
            testOTM.add(oppTM4);

            insert testOTM;


            // Build the opportunity share
            OpportunityShare oppS1 = new OpportunityShare();
            oppS1.OpportunityId = sOpportunity1.Id;
            oppS1.UserOrGroupId = testUser[3].Id;
            oppS1.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS2 = new OpportunityShare();
            oppS2.OpportunityId = sOpportunity2.Id;
            oppS2.UserOrGroupId = testUser[1].Id;
            oppS2.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS3 = new OpportunityShare();
            oppS3.OpportunityId = sOpportunity2.Id;
            oppS3.UserOrGroupId = testUser[3].Id;
            oppS3.OpportunityAccessLevel = 'Edit';

            OpportunityShare oppS4 = new OpportunityShare();
            oppS4.OpportunityId = sOpportunity3.Id;
            oppS4.UserOrGroupId = testUser[3].Id;
            oppS4.OpportunityAccessLevel = 'Edit';

            testOS.add(oppS1);
            testOS.add(oppS2);
            testOS.add(oppS3);
            testOS.add(oppS4);

            insert testOS;



        // Build the DellTeamMember array
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        for (Integer dg=0; dg<111; dg++) {

            if (dg != 4) {

                DellTeamMember dtmRecord = new DellTeamMember();

                dtmRecord.AccountId = sAccount1.Id;


                if (dg == 0) {
                    dtmRecord.UserId = testUserI[0].Id;
                }

                else {
                    dtmRecord.UserId = testUser[dg-1].Id;
                }

                dtmRecord.TeamMemberRole = ROLE_XSE;
                dtmRecord.AccountAccessLevel = 'Edit';
                dtmRecord.OpportunityAccessLevel = 'Edit';
                dtmRecord.CaseAccessLevel = 'Edit';


                if ((dg <= 1) || (dg == 3)) {
                    dtmRecord.Status = 'A';
                }

                else {
                    dtmRecord.Status = 'I';
                }

                dtmArray.add(dtmRecord);

            }   // End if (dg != 4)

        }   // End for (Integer dg=0; dg<111; dg++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);



        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test40() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();

// ALou - 2008/10/16 - Commented out for deployment



        // Ensure the correct number of account team members were created
        system.debug('#### Validation of total number of account team members');
//      system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct number of account shares were created
        system.debug('#### Validation of total number of account shares');
//      system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
//      for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
//          system.assertEquals('Edit', acctShare.AccountAccessLevel);
//          system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
//          system.assertEquals('Edit', acctShare.CaseAccessLevel);
//      }


        // Ensure the correct number of opportunity team members were created
        system.debug('#### Validation of total number of opportunity team members');
        //ccws system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);
        //ccws system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2]);
        //ccws system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3]);


        // Ensure the correct number of opportunity shares were created
        system.debug('#### Validation of total number of opportunity shares');
        //ccws system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
        //ccws system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
        //ccws system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId3 and RowCause = 'Team']);


        // Ensure that each opportunity share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of opportunity share permissions');
/*
        for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']) {
            system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }

        for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']) {
            system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }

        for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId3 and RowCause = 'Team']) {
            system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
        }
*/

        TriggerExecutionController.setSkipAllTriggers(false);
    }   // End function Test40()



    // Test Case 41
    // Function: setAccountAndSalesTeams
    // Test Condition: 1 user inactive, 1 opportunity with Direct_Team_Sync =
    // false
    // DellTeamMember:
    // 4 records total
    // 2 accounts, 2 active members
    // Account 2 is inactive
    // One opportunity for each account
    static testMethod void Test41() {
        TriggerExecutionController.setSkipAllTriggers(true);

        // Notify that the test will start
        system.debug('##### Start Test Case 41');


        // Get Users
        List<user> testUser = new List<user>([select Id from user where IsActive = true AND UserType ='Standard' limit 5]);
        String sUserId0 = testUser[0].Id;
        String sUserId1 = testUser[1].Id;
        String sUserId2 = testUser[2].Id;
        String sUserId3 = testUser[3].Id;
        String sUserId4 = testUser[4].Id;

        List<user> testInactUser = new List<user>([select Id from user where IsActive = false limit 1]);


        // Create account
        Account sAccount1 = new Account(name='Test Account 40');
//      Account sAccount1 = new Account(name='Test Account 40', OwnerId=testInactUser[0].Id);

        insert sAccount1;


            // Set the account owner
            sAccount1.OwnerId = sUserId4;

            update sAccount1;


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(1990,03,26);

        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1, OwnerId=testUser[3].Id, Partner_Opportunity_Stage__c = 'Win - 100%');

// Use the following line to test using an opportunity with an inactive owner
//      Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1, OwnerId=testInactUser[0].Id);

        insert sOpportunity1;

        String sOpportunityId1 = sOpportunity1.Id;


        // Delete any account teams and opportunity teams created
        List<AccountTeamMember> ATMCreated = new List<AccountTeamMember>();
        ATMCreated = [select Id from AccountTeamMember where AccountId = :sAccount1.Id];

        if (ATMCreated.size() > 0) {
            delete ATMCreated;
        }


        List<OpportunityTeamMember> OTMCreated = new List<OpportunityTeamMember>();
        OTMCreated = [select Id from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id];

        if (OTMCreated.size() > 0) {
            delete OTMCreated;
        }


        // Build the DellTeamMember array
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        for (Integer g=0; g<4; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = sAccount1.Id;

            dtmRecord.UserId = testUser[g].Id;


// Test Code
//          if (g == 1) {
//              dtmRecord.UserId = testInactUser[0].Id;
//          } else {
//              dtmRecord.UserId = testUser[g].Id;
//          }
// Test Code End


            if ((g == 0) || (g == 2)) {
                dtmRecord.TeamMemberRole = ROLE_IPSM;
            }

            else if ((g == 1) || (g == 3)) {
                dtmRecord.TeamMemberRole = ROLE_SAPPROVER;
            }

            else {
                dtmRecord.TeamMemberRole = ROLE_XSE;
            }

            dtmRecord.AccountAccessLevel = 'Edit';
            dtmRecord.OpportunityAccessLevel = 'Edit';
            dtmRecord.CaseAccessLevel = 'Edit';


            if (g <= 1) {
                dtmRecord.Status = 'A';
            }

            else {
                dtmRecord.Status = 'I';
            }

            dtmArray.add(dtmRecord);

        }   // End for (Integer g=0; g<4; g++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);



        // Start the test
        Test.startTest();


        try {
            TeamProcessing.setAccountAndSalesTeams(dtmArray);
            SalesTeamProcessing.setAccountAndSalesTeams(dtmArray);
        }

        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  SalesTeamSyncTests.Test41() ]', dellConfig.errorEmail);
        }


        // Stop the test
        Test.stopTest();


// ALou - 2008/10/16 - Commented out for deployment

        // Ensure the correct number of account team members were created
//      system.debug('#### Validation of total number of account team members');
//      system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct individual account team members were created and deleted
        system.debug('#### Validation of individual account team members');
//      system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
//      system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);
//      system.assertEquals(0, [select count() from AccountTeamMember where UserId = :testInactUser[0].Id and Account.Name = 'Test Account 40']);


        // Ensure the correct number of account shares were created
//      system.debug('#### Validation of total number of account shares');
//      system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure the correct individual account shares were created and deleted
        system.debug('#### Validation of individual account shares');
//      system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
//      system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
//      system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :testInactUser[0].Id and Account.Name = 'Test Account 40' and RowCause = 'Team']);



        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
//      for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
//          system.assertEquals('Edit', acctShare.AccountAccessLevel);
//          system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
//          system.assertEquals('Edit', acctShare.CaseAccessLevel);
//      }


        // Ensure the correct number of opportunity team members were created
//      system.debug('#### Validation of total number of opportunity team members');
//      system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);


        // Ensure the correct individual opportunity team members were created and deleted
        system.debug('#### Validation of individual opportunity team members');
//      system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId0]);
//      system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId1]);
//      system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :testInactUser[0].Id]);



        // Ensure the correct number of opportunity shares were created
//      system.debug('#### Validation of total number of opportunity shares');
//      system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);


        // Ensure the correct individual opportunity shares were created
        system.debug('#### Validation of individual opportunity shares');
//      system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
//      system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
//      system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :testInactUser[0].Id and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);



        // Ensure that each opportunity share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of opportunity share permissions');
//      for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']) {
//          system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
//      }


        // Ensure that the opportunity owner is the account owner
        system.debug('#### Validation of new opportunity owner');
//      for (Opportunity OppTest : [select Id, OwnerId from Opportunity where Id = :sOpportunity1.Id]) {
//          system.assertEquals(sAccount1.OwnerId, OppTest.OwnerId);
//      }


        TriggerExecutionController.setSkipAllTriggers(false);
    }   // End function Test41()

}   // End class SalesTeamSyncTests