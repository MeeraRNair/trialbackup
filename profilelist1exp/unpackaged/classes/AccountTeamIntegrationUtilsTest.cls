@isTest
/***********************************************************
* Description   : 
* ---------------------------------------------------------
* Revision  Name    Date        Description
* 1.0       					Creation
  2.0       Azwanti	29.09.2011  REL12.10 CR6493-0182 Sales Role Change (Cross Domain Sales Engineer -> Customer System Engineer,
  								Inside Product Specialist Manager -> Technical Sales Manager)      
* 3.0		Azwanti	17.10.2011	REL12.10 CR6493-0182 Sales Role Change (Customer System Engineer -> System Consultant)
*
*
************************************************************/
/**
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 4.0      13477       FY17-DCS-1002   07-Sep-2016     Fenny           Summer ’16 seasonal release that has been causing Account team owner and members to have Ready only access to their Accounts and Related objects.
 **/
private class AccountTeamIntegrationUtilsTest {


private static Map<String, String> sParams;

	//CR Sales Role Change (Technical Sales Manager -> Inside Product Specialist Manager, System Consultant -> Cross Domain Sales Engineer)
	private static final string ROLE_IPSM = 'Technical Sales Manager';//r2.0 'Inside Product Specialist Manager';
	private static final string ROLE_XSE = 'System Consultant';//r3.0 'Customer System Engineer';//r2.0 'Cross Domain Sales Engineer'
	private static final string ROLE_SAPPROVER = 'Sales Approver';
	
// Test Condition:
    // DellTeamMember = [1 account, 2 members, status is null]
    static testMethod void setAccountTeam_SetDTMStatusNULL() {

        // Notify that the test will start
        system.debug('##### Start setAccountTeam_SetDTMStatusNULL #####');

        // Declare variables and arrays
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account 40');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 2);
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        // Build the DellTeamMember array
        for (Integer g=0; g<2; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = testAcc.Id;
            dtmRecord.UserId = testUserList[g].Id;

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
            dtmRecord.Status = '';

            dtmArray.add(dtmRecord);
        }   // End for (Integer g=0; g<2; g++)

        // Start the test
        Test.startTest();

        try {
            AccountTeamIntegrationUtils.setAccountTeam(dtmArray);
        }
        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  AccountTeamIntegrationUtilsTest.setAccountAndSalesTeams_SetDTMStatusNULL() ]' , dellConfig.errorEmail);
        }

        // Stop the test
        Test.stopTest();

        // Ensure the correct number of account team members were created
        system.debug('Validation of total number of account team members');
        system.assertEquals(0, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct number of account shares were created
        system.debug('Validation of total number of account shares');
        system.assertEquals(0, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        system.debug('##### End setAccountTeam_SetDTMStatusNULL #####');
    }


    // Test Condition:
    // DellTeamMember = [1 account, 2 members, status = 'A']
    static testMethod void setAccountTeam_SetDTMStatusA() {

        // Notify that the test will start
        system.debug('##### Start setAccountTeam_SetDTMStatusA #####');

        // Declare variables and arrays
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account 40');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 2);
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        // Build the DellTeamMember array
        for (Integer g=0; g<2; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = testAcc.Id;
            dtmRecord.UserId = testUserList[g].Id;

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
            AccountTeamIntegrationUtils.setAccountTeam(dtmArray);
        }
        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  AccountTeamIntegrationUtilsTest.setAccountAndSalesTeams_SetDTMStatusA() ]' , dellConfig.errorEmail);
        }

        // Stop the test
        Test.stopTest();

        // Ensure the correct number of account team members were created
        system.debug('Validation of total number of account team members');
        system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct number of account shares were created
        system.debug('Validation of total number of account shares');
        system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);


        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('Validation of account share permissions');
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }

        system.debug('##### End setAccountTeam_SetDTMStatusA #####');
    }


// Test Condition:
    // DellTeamMember = [1 account, 2 members, status = 'A' / 'I']
    static testMethod void setAccountTeam_SetDTMStatusAOrI() {

        // Notify that the test will start
        system.debug('##### Start setAccountTeam_SetDTMStatusAOrI #####');

        // Declare variables and arrays
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account 40');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 2);
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        // Build the DellTeamMember array
        for (Integer g=0; g<2; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = testAcc.Id;
            dtmRecord.UserId = testUserList[g].Id;

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
        }

        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array' + dtmArray);

        // Start the test
        Test.startTest();

        try {
            AccountTeamIntegrationUtils.setAccountTeam(dtmArray);
        }
        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  AccountTeamIntegrationUtilsTest.setAccountTeam_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
        }

        // Stop the test
        Test.stopTest();

        // Ensure the correct number of account team members were created
        system.debug('Validation of total number of account team members');
        system.assertEquals(1, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);

        // Ensure the correct number of account shares were created
        system.debug('Validation of total number of account shares');
        system.assertEquals(1, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);

        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('Validation of account share permissions');
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }
        system.debug('##### End setAccountTeam_SetDTMStatusAOrI #####');
    }

    // Test Condition:
    // DellTeamMember = [2 account, 4 members, status = 'A' / 'I']
    static testMethod void setAccountTeam_AccStatusAOrI_SetDTMStatusAOrI() {
        // Notify that the test will start
        system.debug('##### End setAccountTeam_AccStatusAOrI_SetDTMStatusAOrI #####');
        ProcessFlowTriggerController.isTest = true;

        // Declare variables and arrays
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account 40');
        Account testAcc1 = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        sParams.put('str_name', 'Test Account 41');
        sParams.put('str_status__c', 'Inactive');
        Account testAcc2 = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 2);

        sParams.put('bln_IsActive', 'false');
        List<SObject> testUserList2 = TestDataGenerator.getObject(new User(), 2, sParams);
        sParams.clear();

        String sUserId0 = testUserList[0].Id;
        String sUserId1 = testUserList[1].Id;
        String sUserId2 = testUserList2[0].Id;
        String sUserId3 = testUserList2[1].Id;

        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        // Build the DellTeamMember array
        for (Integer g=0; g<4; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            if (g <= 1) {
                dtmRecord.AccountId = testAcc1.Id;
                dtmRecord.UserId = testUserList2[g].Id;
            }
            else {
                dtmRecord.AccountId = testAcc2.Id;
                dtmRecord.UserId = testUserList[g-2].Id;
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
            AccountTeamIntegrationUtils.setAccountTeam(dtmArray);
        }
        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  AccountTeamIntegrationUtilsTest.setAccountTeam_AccStatusAOrI_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
        }

        // Stop the test
        Test.stopTest();

        // Ensure the correct number of account team members were created
        system.debug('Validation of total number of account team members');
        system.assertEquals(0, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);
        system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 41']);

        // Ensure the correct individual account team members were created
        system.debug('Validation of individual account team members');
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId2 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId3 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 41']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 41']);

        // Ensure the correct number of account shares were created
        system.debug('Validation of total number of account shares');
        system.assertEquals(0, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 41' and RowCause = 'Team']);

        // Ensure the correct individual account shares were created
        system.debug('Validation of individual account shares');
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId2 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId3 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 41' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 41' and RowCause = 'Team']);

        system.debug('##### End setAccountTeam_AccStatusAOrI_SetDTMStatusAOrI #####');
    }

    // Test Condition:
    // DellTeamMember = [1 account, 5 members, status = 'A' / 'I']
    static testMethod void setAccountTeam_AccStatusA_SetDTMStatusAOrI() {

        // Notify that the test will start
        system.debug('##### Start setAccountTeam_AccStatusA_SetDTMStatusAOrI #####');

        // Declare variables and arrays
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account 40');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 5);

        List<DellTeamMember> dtmArray = new List<DellTeamMember>();
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        //List<AccountShare> testAS = new List<AccountShare>(); // 4.0: Commented

        String sUserId0 = testUserList[0].Id;
        String sUserId1 = testUserList[1].Id;
        String sUserId2 = testUserList[2].Id;
        String sUserId3 = testUserList[3].Id;
        String sUserId4 = testUserList[4].Id;

        // Build the DellTeamMember array
        for (Integer g=0; g<4; g++) {

            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = testAcc.Id;
            dtmRecord.UserId = testUserList[g].Id;

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
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_UserId', sUserId2);
        sParams.put('str_TeamMemberRole', ROLE_IPSM);
        // 4.0: START
		sParams.put('str_AccountAccessLevel', 'Edit');
		sParams.put('str_OpportunityAccessLevel', 'Edit');
		sParams.put('str_CaseAccessLevel', 'Edit');
		// 4.0: END
        AccountTeamMember acctTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 1, sParams, false)[0];
        sParams.clear();
        testATM.add(acctTM);

        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_UserId', sUserId3);
        sParams.put('str_TeamMemberRole', ROLE_SAPPROVER);
        // 4.0: START
		sParams.put('str_AccountAccessLevel', 'Edit');
		sParams.put('str_OpportunityAccessLevel', 'Edit');
		sParams.put('str_CaseAccessLevel', 'Edit');
		// 4.0: END
        acctTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 1, sParams, false)[0];
        sParams.clear();
        testATM.add(acctTM);

        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_UserId', sUserId4);
        sParams.put('str_TeamMemberRole', ROLE_IPSM);
		// 4.0: START
		sParams.put('str_AccountAccessLevel', 'Edit');
		sParams.put('str_OpportunityAccessLevel', 'Edit');
		sParams.put('str_CaseAccessLevel', 'Edit');
		// 4.0: END
        acctTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 1, sParams, false)[0];
        sParams.clear();
        testATM.add(acctTM);
        insert testATM;

        // Display the DellTeamMember array
        system.debug('#### AccountTeamMember array = ' + testATM);

        /* 4.0: START Commented
		// Build the account share
        for (integer i=2; i<5; i++) {
            sParams.put('str_AccountId', testAcc.id);
            sParams.put('str_UserOrGroupId', testUserList[i].Id);
            sParams.put('str_AccountAccessLevel', 'Edit');
            sParams.put('str_OpportunityAccessLevel', 'Edit');
            sParams.put('str_CaseAccessLevel', 'Edit');
            AccountShare acctS = (AccountShare) TestDataGenerator.getObject(new AccountShare(), 1, sParams, false)[0];
            sParams.clear();
            testAS.add(acctS);
        }
        insert testAS;

        // Display the DellTeamMember array
        system.debug('#### AccountShare array ' + testAS); 
		
		4.0: END Commented */

        // Start the test
        Test.startTest();

        try {
            AccountTeamIntegrationUtils.setAccountTeam(dtmArray);
        }
        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  AccountTeamIntegrationUtilsTest.setAccountTeam_AccStatusA_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
        }

        // Stop the test
        Test.stopTest();

        // Ensure the correct number of account team members were created
        system.debug('Validation of total number of account team members');
        system.assertEquals(3, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);

        // Ensure the correct individual account team members were created
        system.debug('Validation of individual account team members');
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId2 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId3 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId4 and Account.Name = 'Test Account 40']);

        // Ensure the correct number of account shares were created
        system.debug('Validation of total number of account shares');
        system.assertEquals(3, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);

        // Ensure the correct individual account shares were created
        system.debug('Validation of individual account shares');
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId2 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId3 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId4 and Account.Name = 'Test Account 40' and RowCause = 'Team']);

        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('Validation of account share permissions');
        for (AccountShare acctShare : [select Id,userorgroupid, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }
        system.debug('##### End setAccountTeam_AccStatusA_SetDTMStatusAOrI #####');
    }

    // Test Condition:
    // DellTeamMember:
    // 2 records total
    // 1 accounts, 2 active members
    // Member #1 is owner of account
    // 1 opportunity
    // Member #2 is owner of the opportunity
    static testMethod void setAccountTeam_DiffOwnerForAccOpp() {

        // Notify that the test will start
        system.debug('##### Start setAccountTeam_DiffOwnerForAccOpp #####');

        // Declare variables
        Integer iAccountTeamMembers = 0;
        Integer iSalesTeamMembers = 0;
        sParams = new Map<String, String>();

        // Create the users
        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 2);
        String sUserId0 = testUserList[0].Id;
        String sUserId1 = testUserList[1].Id;

        // Create the accounts
        sParams.put('str_name', 'Test Account 40');
        sParams.put('str_OwnerId', sUserId0);
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        // Build the DellTeamMember array
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        for (Integer g=0; g<2; g++) {
            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = testAcc.Id;
            dtmRecord.UserId = testUserList[g].Id;

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
            AccountTeamIntegrationUtils.setAccountTeam(dtmArray);
        }
        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  AccountTeamIntegrationUtilsTest.setAccountTeam_DiffOwnerForAccOpp() ]', dellConfig.errorEmail);
        }

        // Stop the test
        Test.stopTest();

        // Ensure the correct number of account team members were created
        system.debug('#### Validation of total number of account team members');
        system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);

        // Ensure the correct individual account team members were created
        system.debug('#### Validation of individual account team members');
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);

        // Ensure the correct number of account shares were created
        system.debug('#### Validation of total number of account shares');
        // 4.0: Change the expected result to 2, because Summer'16 onwards, Account owner will have 2 AccountShare records with RowCause 'Owner' & 'Team'
        system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);

        // Ensure the correct individual account shares were created
        system.debug('#### Validation of individual account shares');
        // 4.0: Change the expected result to 1, because Summer'16 onwards, Account owner will have 2 AccountShare records with RowCause 'Owner' & 'Team'
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);

        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }

        system.debug('##### End setAccountTeam_DiffOwnerForAccOpp #####');
    }

    // Test Condition:
    // DellTeamMember:
    // 4 records total
    // 2 accounts, 2 active members
    // Account 2 is inactive
    static testMethod void setAccountTeam_AccStatusAOrI_UserStatusA_SetDTMStatusA() {

        // Notify that the test will start
        system.debug('##### Start setAccountTeam_AccStatusAOrI_UserStatusA_SetDTMStatusA #####');
        ProcessFlowTriggerController.isTest = true;

        // Declare variables and arrays
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account 40');
        Account testAcc1 = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        sParams.put('str_name', 'Test Account 41');
        sParams.put('str_status__c', 'Inactive');
        Account testAcc2 = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 2);

        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        String sUserId0 = testUserList[0].Id;
        String sUserId1 = testUserList[1].Id;

        // Build the DellTeamMember array
        for (Integer g=0; g<4; g++) {
            DellTeamMember dtmRecord = new DellTeamMember();

            if (g <= 1) {
                dtmRecord.AccountId = testAcc1.Id;
                dtmRecord.UserId = testUserList[g].Id;
            }
            else {
                dtmRecord.AccountId = testAcc2.Id;
                dtmRecord.UserId = testUserList[g-2].Id;
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
            AccountTeamIntegrationUtils.setAccountTeam(dtmArray);
        }
        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  AccountTeamIntegrationUtilsTest.setAccountTeam_AccStatusAOrI_UserStatusA_SetDTMStatusA() ]', dellConfig.errorEmail);
        }

        // Stop the test
        Test.stopTest();

        // Ensure the correct number of account team members were created
        system.debug('#### Validation of total number of account team members');
        system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);
        system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 41']);

        // Ensure the correct individual account team members were created
        system.debug('#### Validation of individual account team members');
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 41']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 41']);

        // Ensure the correct number of account shares were created
        system.debug('#### Validation of total number of account shares');
        system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 41' and RowCause = 'Team']);

        // Ensure the correct individual account shares were created
        system.debug('#### Validation of individual account shares');
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 41' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 41' and RowCause = 'Team']);


        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }
        system.debug('##### End setAccountTeam_AccStatusAOrI_UserStatusA_SetDTMStatusA #####');
    }

    // Test Condition:
    // DellTeamMember:
    // 4 records total
    // 1 accounts, 5 active members
    static testMethod void setAccountTeam_AccStatusA_UserStatusA_SetDTMStatusAOrI() {
        system.debug('##### Start setAccountTeam_AccStatusA_UserStatusA_SetDTMStatusAOrI #####');

        sParams = new Map<String, String>();
        // Get Users
        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 5);

        String sUserId0 = testUserList[0].Id;
        String sUserId1 = testUserList[1].Id;
        String sUserId2 = testUserList[2].Id;
        String sUserId3 = testUserList[3].Id;
        String sUserId4 = testUserList[4].Id;

        List<User> userList = new List<User>();
        for (integer i=2; i<5; i++)
            userList.add((User)testUserList[i]);
        TestDataGenerator.setUserList(userList);

        // Create account
        sParams.put('str_name', 'Test Account 40');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        // Create account team
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_TeamMemberRole', ROLE_IPSM);
		// 4.0: START
        sParams.put('str_AccountAccessLevel', 'Edit');
        sParams.put('str_OpportunityAccessLevel', 'Edit');
        sParams.put('str_CaseAccessLevel', 'Edit');
		// 4.0: END
        TestDataGenerator.getObject(new AccountTeamMember(), 3, sParams);
        sParams.clear();

        /* 4.0: START Commented
		// Build the account share
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_AccountAccessLevel', 'Edit');
        sParams.put('str_OpportunityAccessLevel', 'Edit');
        sParams.put('str_CaseAccessLevel', 'Edit');
        TestDataGenerator.getObject(new AccountShare(), 3, sParams);
        sParams.clear();
		4.0: END Commented */

        // Build the DellTeamMember array
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        for (Integer g=0; g<4; g++) {
            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = testAcc.Id;
            dtmRecord.UserId = testUserList[g].Id;

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
            AccountTeamIntegrationUtils.setAccountTeam(dtmArray);
        }
        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  AccountTeamIntegrationUtilsTest.setAccountTeam_AccStatusA_UserStatusA_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
        }

        // Stop the test
        Test.stopTest();

        // Ensure the correct number of account team members were created
        system.debug('#### Validation of total number of account team members');
        system.assertEquals(3, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);

        // Ensure the correct individual account team members were created and deleted
        system.debug('#### Validation of individual account team members');
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId2 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId3 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId4 and Account.Name = 'Test Account 40']);

        // Ensure the correct number of account shares were created
        system.debug('#### Validation of total number of account shares');
        system.assertEquals(3, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);

        // Ensure the correct individual account shares were created and deleted
        system.debug('#### Validation of individual account shares');
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId2 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId3 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId4 and Account.Name = 'Test Account 40' and RowCause = 'Team']);

        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }

        system.debug('##### End setAccountTeam_AccStatusA_UserStatusA_SetDTMStatusAOrI #####');
    }

    // Test Condition:
    // DellTeamMember:
    // 1 user inactive, 5 active user
    // 4 records total
    // 1 accounts
    static testMethod void setAccountTeam_AccStatusA_UserStatusAOrI_SetDTMStatusAOrI() {

        // Notify that the test will start
        system.debug('##### Start setAccountTeam_AccStatusA_UserStatusAOrI_SetDTMStatusAOrI #####');

        sParams = new Map<String, String>();

        // Get Users
        sParams.put('bln_IsActive', 'false');
        User testUserI = (User) TestDataGenerator.getObject(new User(), 1, sParams)[0];
        sParams.clear();

        String sUserIdI = testUserI.Id;

        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 5);
        String sUserId0 = testUserList[0].Id;
        String sUserId1 = testUserList[1].Id;
        String sUserId2 = testUserList[2].Id;
        String sUserId3 = testUserList[3].Id;
        String sUserId4 = testUserList[4].Id;

        List<User> userList = new List<User>();
        for (integer i=0; i<2; i++)
            userList.add((User)testUserList[i]);
        TestDataGenerator.setUserList(userList);

        // Create account
        sParams.put('str_name', 'Test Account 40');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();

        // Create account team
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_TeamMemberRole', ROLE_IPSM);
		// 4.0: START
        sParams.put('str_AccountAccessLevel', 'Edit');
        sParams.put('str_OpportunityAccessLevel', 'Edit');
        sParams.put('str_CaseAccessLevel', 'Edit');
		// 4.0: END
        TestDataGenerator.getObject(new AccountTeamMember(), 2, sParams);
        sParams.clear();

        /* 4.0: START Commented
		// Build the account share
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_AccountAccessLevel', 'Edit');
        sParams.put('str_OpportunityAccessLevel', 'Edit');
        sParams.put('str_CaseAccessLevel', 'Edit');
        TestDataGenerator.getObject(new AccountShare(), 2, sParams);
        sParams.clear();
		4.0: END Commented */

        // Build the DellTeamMember array
        List<DellTeamMember> dtmArray = new List<DellTeamMember>();

        for (Integer g=0; g<4; g++) {
            DellTeamMember dtmRecord = new DellTeamMember();

            dtmRecord.AccountId = testAcc.Id;

            if (g == 0) {
                dtmRecord.UserId = testUserI.Id;
            }
            else {
                dtmRecord.UserId = testUserList[g-1].Id;
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
            AccountTeamIntegrationUtils.setAccountTeam(dtmArray);
        }
        catch (Exception e) {
            DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  AccountTeamIntegrationUtilsTest.setAccountTeam_AccStatusA_UserStatusAOrI_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
        }

        // Stop the test
        Test.stopTest();

        // Ensure the correct number of account team members were created
        system.debug('#### Validation of total number of account team members');
        system.assertEquals(2, [select count() from AccountTeamMember where Account.Name = 'Test Account 40']);


        // Ensure the correct individual account team members were created and deleted
        system.debug('#### Validation of individual account team members');
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserIdI and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId0 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId1 and Account.Name = 'Test Account 40']);
        system.assertEquals(1, [select count() from AccountTeamMember where UserId = :sUserId2 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId3 and Account.Name = 'Test Account 40']);
        system.assertEquals(0, [select count() from AccountTeamMember where UserId = :sUserId4 and Account.Name = 'Test Account 40']);

        // Ensure the correct number of account shares were created
        system.debug('#### Validation of total number of account shares');
        system.assertEquals(2, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);

        // Ensure the correct individual account shares were created and deleted
        system.debug('#### Validation of individual account shares');
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserIdI and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId2 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId3 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
        system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId4 and Account.Name = 'Test Account 40' and RowCause = 'Team']);

        // Ensure that each account share has EDIT permissions for account
        // opportunity, and case
        system.debug('#### Validation of account share permissions');
        for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
            system.assertEquals('Edit', acctShare.AccountAccessLevel);
            system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
            system.assertEquals('Edit', acctShare.CaseAccessLevel);
        }

        system.debug('##### End setAccountTeam_AccStatusA_UserStatusAOrI #####');
    }
    
    // 4.0: To cover assembleATMDelArray
    static testMethod void Test_assembleATMDelArray() {

        system.debug('#### In test method Test_assembleATMDelArray() now . . . ');

        // Declare variables
        List<DellTeamMember> arrayDTM = new List<DellTeamMember>();
        List<ID> testArrayID = new List<ID>();
        

        // Get Users
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 100]);
        system.debug('#### Array testUser = ' + testUser);


        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }


        // Create account
        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;


        // Create account team
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();

        for (Integer h=0; h < testUser.size(); h++) {
        
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;          
            
            // Add individual ATMs to array of ATMs
            testATM.add(acctTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display and create the AccountTeamMember array
        system.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;
    
    
        // Assert that the account team members where created
        system.assertEquals(100, [select count() from AccountTeamMember where AccountId = :sAccount1.Id and UserId in :testArrayID]);



        // Create the DellTeamMember deletion array
        for (Integer h=0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = new DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            
            // Add individual DTMs to array of DTMs
            arrayDTM.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Test the assemblyDTMDelArray function
        Test.startTest();
        AccountTeamIntegrationUtils.assembleATMDelArray(arrayDTM);
        Test.stopTest();


        // Verify the results
        system.debug('#### Test Verification ');
        system.assertEquals(0, [select count() from AccountTeamMember where AccountId = :sAccount1.Id and UserId in :testArrayID]);


    }   // End Test_assembleATMDelArray()
    
    
}