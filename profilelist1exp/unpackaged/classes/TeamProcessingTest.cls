@isTest
/***********************************************************
* Description   : 
* ---------------------------------------------------------
* Revision  Name    Date        Description
* 1.0       					Creation      
* 2.0		Azwanti	29.09.2011	REL12.10 CR6493-0182 Sales Role Change (Cross Domain Sales Engineer -> Customer System Engineer, Inside Product Specialist Manager -> Technical Sales Manager) 
* 3.0		Azwanti	17.10.2011	REL12.10 CR6493-0182 Sales Role Change (Customer System Engineer -> System Consultant)
*
************************************************************/
private class TeamProcessingTest {

	private static Map<String, String> sParams;
	//CR Sales Role Change (Technical Sales Manager -> Inside Product Specialist Manager, System Consultant -> Cross Domain Sales Engineer)
	private static final string ROLE_IPSM = 'Technical Sales Manager'; //r2.0 'Inside Product Specialist Manager';
	private static final string ROLE_XSE = 'System Consultant';//r3.0 'Customer System Engineer';//r2.0 'Cross Domain Sales Engineer';
	private static final string ROLE_SAPPROVER = 'Sales Approver';
	 
	// Test Condition:
	// DellTeamMember = [1 account, 2 members, status = 'A']
	static testMethod void setAccountAndSalesTeams_SetDTMStatusA() {

		// Notify that the test will start
		system.debug('##### Start setAccountAndSalesTeams_SetDTMStatusA #####');

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
		}	// End for (Integer g=0; g<2; g++)

		// Start the test
		Test.startTest();

		try {
			TeamProcessing.setAccountAndSalesTeams(dtmArray);
		}
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  TeamProcessing.setAccountAndSalesTeams_SetDTMStatusA() ]' , dellConfig.errorEmail);
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

		system.debug('##### End setAccountAndSalesTeams_SetDTMStatusA #####');
	}

	// Test Condition:
	// DellTeamMember = [1 account, 2 members, status = 'A' / 'I']
	static testMethod void setAccountAndSalesTeams_SetDTMStatusAOrI() {

		// Notify that the test will start
		system.debug('##### Start setAccountAndSalesTeams_SetDTMStatusAOrI #####');

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
			TeamProcessing.setAccountAndSalesTeams(dtmArray);
		}
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  TeamProcessing.setAccountAndSalesTeams_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
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
		system.debug('##### End setAccountAndSalesTeams_SetDTMStatusAOrI #####');
	}

	// Test Condition:
	// DellTeamMember = [2 account, 4 members, status = 'A' / 'I']
	static testMethod void setAccountAndSalesTeams_AccStatusAOrI_SetDTMStatusAOrI() {
		// Notify that the test will start
		system.debug('##### End setAccountAndSalesTeams_AccStatusAOrI_SetDTMStatusAOrI #####');

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
		}	// End for (Integer g=0; g<4; g++)

		// Display the DellTeamMember array
		system.debug('#### DellTeamMember array' + dtmArray);

		// Start the test
		Test.startTest();

		try {
			TeamProcessing.setAccountAndSalesTeams(dtmArray);
		}
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  TeamProcessingTest.setAccountAndSalesTeams_AccStatusAOrI_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
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

		system.debug('##### End setAccountAndSalesTeams_AccStatusAOrI_SetDTMStatusAOrI #####');
	}

	// Test Condition:
	// DellTeamMember = [1 account, 5 members, status = 'A' / 'I']
	static testMethod void setAccountAndSalesTeams_AccStatusA_SetDTMStatusAOrI() {

		// Notify that the test will start
		system.debug('##### Start setAccountAndSalesTeams_AccStatusA_SetDTMStatusAOrI #####');

		// Declare variables and arrays
		sParams = new Map<String, String>();
		sParams.put('str_name', 'Test Account 40');
		Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
		sParams.clear();

		List<SObject> testUserList = TestDataGenerator.getObject(new User(), 5);

		List<DellTeamMember> dtmArray = new List<DellTeamMember>();
		List<AccountTeamMember> testATM = new List<AccountTeamMember>();
		List<AccountShare> testAS = new List<AccountShare>();

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
		}	// End for (Integer g=0; g<2; g++)

		// Display the DellTeamMember array
		system.debug('#### DellTeamMember array' + dtmArray);

		// Build the account team
		sParams.put('str_AccountId', testAcc.Id);
		sParams.put('str_UserId', sUserId2);
		sParams.put('str_TeamMemberRole', ROLE_IPSM);
		AccountTeamMember acctTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 1, sParams, false)[0];
		sParams.clear();
		testATM.add(acctTM);

		sParams.put('str_AccountId', testAcc.Id);
		sParams.put('str_UserId', sUserId3);
		sParams.put('str_TeamMemberRole', ROLE_SAPPROVER);
		acctTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 1, sParams, false)[0];
		sParams.clear();
		testATM.add(acctTM);

		sParams.put('str_AccountId', testAcc.Id);
		sParams.put('str_UserId', sUserId4);
		sParams.put('str_TeamMemberRole', ROLE_IPSM);
		acctTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 1, sParams, false)[0];
		sParams.clear();
		testATM.add(acctTM);
		insert testATM;

		// Display the DellTeamMember array
		system.debug('#### AccountTeamMember array = ' + testATM);

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

		// Start the test
		Test.startTest();

		try {
			TeamProcessing.setAccountAndSalesTeams(dtmArray);
		}
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  TeamProcessingTest.setAccountAndSalesTeams_AccStatusA_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
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
		system.debug('##### End setAccountAndSalesTeams_AccStatusA_SetDTMStatusAOrI #####');
	}

	// Test Condition:
	// DellTeamMember:
	// 2 records total
	// 1 accounts, 2 active members
	// Member #1 is owner of account
	// 1 opportunity
	// Member #2 is owner of the opportunity
	static testMethod void setAccountAndSalesTeams_DiffOwnerForAccOpp() {

		// Notify that the test will start
		system.debug('##### Start setAccountAndSalesTeams_DiffOwnerForAccOpp #####');

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

		/*
		// The following data creation is not needed
		// AccountTeamUtil.updateSalesTeamsAndShares has been commented at TeamProcessing
		// Create the opportunities
		sParams.put('str_OwnerId', sUserId1);
		Opportunity testOpp = (Opportunity) TestDataGenerator.getObject(new Opportunity(), 1, sParams)[0];
		sParams.clear();
		*/

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
		}	// End for (Integer g=0; g<2; g++)

		// Display the DellTeamMember array
		system.debug('#### DellTeamMember array' + dtmArray);

		// Start the test
		Test.startTest();

		try {
			TeamProcessing.setAccountAndSalesTeams(dtmArray);
		}
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  TeamProcessingTest.setAccountAndSalesTeams_DiffOwnerForAccOpp() ]', dellConfig.errorEmail);
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
		system.assertEquals(1, [select count() from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']);

		// Ensure the correct individual account shares were created
		system.debug('#### Validation of individual account shares');
		system.assertEquals(0, [select count() from AccountShare where UserOrGroupId = :sUserId0 and Account.Name = 'Test Account 40' and RowCause = 'Team']);
		system.assertEquals(1, [select count() from AccountShare where UserOrGroupId = :sUserId1 and Account.Name = 'Test Account 40' and RowCause = 'Team']);

		// Ensure that each account share has EDIT permissions for account
		// opportunity, and case
		system.debug('#### Validation of account share permissions');
		for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
			system.assertEquals('Edit', acctShare.AccountAccessLevel);
			system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
			system.assertEquals('Edit', acctShare.CaseAccessLevel);
		}

		/*
		// The following assert statements are not valid anymore
		// AccountTeamUtil.updateSalesTeamsAndShares has been commented at TeamProcessing
		// Ensure the correct number of opportunity team members were created
		system.debug('#### Validation of total number of opportunity team members');
		system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :testOpp.Id]);


		// Ensure the correct individual opportunity team members were created
		system.debug('#### Validation of individual opportunity team members');
		system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :testOpp.Id and UserId = :sUserId0]);
		system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :testOpp.Id and UserId = :sUserId1]);


		// Ensure the correct number of opportunity shares were created
		system.debug('#### Validation of total number of opportunity shares');
		system.assertEquals(1, [select count() from OpportunityShare where OpportunityId = :testOpp.Id and RowCause = 'Team']);


		// Ensure the correct individual opportunity shares were created
		system.debug('#### Validation of individual opportunity shares');
		system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :testOpp.Id and RowCause = 'Team']);
		system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :testOpp.Id and RowCause = 'Team']);


		// Ensure that each opportunity share has EDIT permissions for account
		// opportunity, and case
		system.debug('#### Validation of opportunity share permissions');
		for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :testOpp.Id and RowCause = 'Team']) {
			system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
		}
		*/
		system.debug('##### End setAccountAndSalesTeams_DiffOwnerForAccOpp #####');
	}

	// Test Condition:
	// DellTeamMember:
	// 4 records total
	// 2 accounts, 2 active members
	// Account 2 is inactive
	static testMethod void setAccountAndSalesTeams_AccStatusAOrI_UserStatusA_SetDTMStatusA() {

		// Notify that the test will start
		system.debug('##### Start setAccountAndSalesTeams_AccStatusAOrI_UserStatusA_SetDTMStatusA #####');

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
		}	// End for (Integer g=0; g<4; g++)

		// Display the DellTeamMember array
		system.debug('#### DellTeamMember array' + dtmArray);

		/*
		// The following data creation is not needed
		// AccountTeamUtil.updateSalesTeamsAndShares has been commented at TeamProcessing
		// Create the opportunities
		sParams.put('str_AccountId', testAcc1.Id);
		Opportunity testOpp1 = (Opportunity) TestDataGenerator.getObject(new Opportunity(), 1, sParams)[0];
		sParams.clear();

		sParams.put('str_AccountId', testAcc2.Id);
		Opportunity testOpp2 = (Opportunity) TestDataGenerator.getObject(new Opportunity(), 1, sParams)[0];
		sParams.clear();
		*/

		// Start the test
		Test.startTest();

		try {
			TeamProcessing.setAccountAndSalesTeams(dtmArray);
		}
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  TeamProcessingTest.setAccountAndSalesTeams_AccStatusAOrI_UserStatusA_SetDTMStatusA() ]', dellConfig.errorEmail);
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

		/*
		// The following assert statements are not valid anymore
		// AccountTeamUtil.updateSalesTeamsAndShares has been commented at TeamProcessing
		// Ensure the correct number of opportunity team members were created
		system.debug('#### Validation of total number of opportunity team members');
		system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);
		system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2]);


		// Ensure the correct individual opportunity team members were created
		system.debug('#### Validation of individual opportunity team members');
		system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId0]);
		system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId1]);
		system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId0]);
		system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2 and UserId = :sUserId1]);


		// Ensure the correct number of opportunity shares were created
		system.debug('#### Validation of total number of opportunity shares');
		system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
		system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']);


		// Ensure the correct individual opportunity shares were created
		system.debug('#### Validation of individual opportunity shares');
		system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
		system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
		system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
		system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId2 and RowCause = 'Team']);


		// Ensure that each opportunity share has EDIT permissions for account
		// opportunity, and case
		system.debug('#### Validation of opportunity share permissions');
		for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']) {
			system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
		}
		*/
		system.debug('##### End setAccountAndSalesTeams_AccStatusAOrI_UserStatusA_SetDTMStatusA #####');
	}

	// Test Condition:
	// DellTeamMember:
	// 4 records total
	// 1 accounts, 5 active members
	static testMethod void setAccountAndSalesTeams_AccStatusA_UserStatusA_SetDTMStatusAOrI() {
		system.debug('##### Start setAccountAndSalesTeams_AccStatusA_UserStatusA_SetDTMStatusAOrI #####');

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
		TestDataGenerator.getObject(new AccountTeamMember(), 3, sParams);
		sParams.clear();

		// Build the account share
		sParams.put('str_AccountId', testAcc.Id);
		sParams.put('str_AccountAccessLevel', 'Edit');
		sParams.put('str_OpportunityAccessLevel', 'Edit');
		sParams.put('str_CaseAccessLevel', 'Edit');
		TestDataGenerator.getObject(new AccountShare(), 3, sParams);
		sParams.clear();

		/*
		// The following data creation is not needed
		// AccountTeamUtil.updateSalesTeamsAndShares has been commented at TeamProcessing
		// Create opportunities
		sParams.put('str_AccountId', testAcc.Id);
		List<SObject> testOppList = TestDataGenerator.getObject(new Opportunity(), 3, sParams);
		sParams.clear();

		String sOpportunityId1 = testOppList[0].Id;
		String sOpportunityId2 = testOppList[1].Id;
		String sOpportunityId3 = testOppList[2].Id;

		// Create opportunity teams
		sParams.put('str_OpportunityId', testOppList[1].Id);
		sParams.put('str_TeamMemberRole', 'TSM');
		TestDataGenerator.getObject(new OpportunityTeamMember(), 3, sParams);
		sParams.clear();

		sParams.put('str_OpportunityId', testOppList[2].Id);
		sParams.put('str_TeamMemberRole', 'TSM');
		TestDataGenerator.getObject(new OpportunityTeamMember(), 3, sParams);
		sParams.clear();

		// Create opportunity share
		sParams.put('str_OpportunityId', testOppList[1].Id);
		//sParams.put('str_OpportunityAccessLevel', 'Edit');
		TestDataGenerator.getObject(new OpportunityTeamMember(), 3, sParams);
		sParams.clear();

		sParams.put('str_OpportunityId', testOppList[2].Id);
		//sParams.put('str_OpportunityAccessLevel', 'Edit');
		TestDataGenerator.getObject(new OpportunityTeamMember(), 3, sParams);
		sParams.clear();
		*/

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
		}	// End for (Integer g=0; g<4; g++)

		// Display the DellTeamMember array
		system.debug('#### DellTeamMember array' + dtmArray);

		// Start the test
		Test.startTest();

		try {
			TeamProcessing.setAccountAndSalesTeams(dtmArray);
		}
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  TeamProcessingTest.setAccountAndSalesTeams_AccStatusA_UserStatusA_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
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

		/*
		// The following assert statements are not valid anymore
		// AccountTeamUtil.updateSalesTeamsAndShares has been commented at TeamProcessing
		// Ensure the correct number of opportunity team members were created
		system.debug('#### Validation of total number of opportunity team members');
		system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);
		system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2]);
		system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3]);

		// Ensure the correct individual opportunity team members were created and deleted
		system.debug('#### Validation of individual opportunity team members');
		system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId0]);
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

		// Ensure the correct number of opportunity shares were created
		system.debug('#### Validation of total number of opportunity shares');
		system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
		system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
		system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId3 and RowCause = 'Team']);

		// Ensure the correct individual opportunity shares were created
		system.debug('#### Validation of individual opportunity shares');
		system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
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

		// Ensure that each opportunity share has EDIT permissions for account
		// opportunity, and case
		system.debug('#### Validation of opportunity share permissions');
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
		system.debug('##### End setAccountAndSalesTeams_AccStatusA_UserStatusA_SetDTMStatusAOrI #####');
	}

	// Test Condition:
	// DellTeamMember:
	// 1 user inactive, 5 active user
	// 4 records total
	// 1 accounts
	static testMethod void setAccountAndSalesTeams_AccStatusA_UserStatusAOrI_SetDTMStatusAOrI() {

		// Notify that the test will start
		system.debug('##### Start setAccountAndSalesTeams_AccStatusA_UserStatusAOrI_SetDTMStatusAOrI #####');

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
		TestDataGenerator.getObject(new AccountTeamMember(), 2, sParams);
		sParams.clear();

		// Build the account share
		sParams.put('str_AccountId', testAcc.Id);
		sParams.put('str_AccountAccessLevel', 'Edit');
		sParams.put('str_OpportunityAccessLevel', 'Edit');
		sParams.put('str_CaseAccessLevel', 'Edit');
		TestDataGenerator.getObject(new AccountShare(), 2, sParams);
		sParams.clear();

		/*
		// The following data creation is not needed
		// AccountTeamUtil.updateSalesTeamsAndShares has been commented at TeamProcessing
		// Create opportunities
		sParams.put('str_AccountId', testAcc.Id);
		List<SObject> testOppList = TestDataGenerator.getObject(new Opportunity(), 3, sParams);
		sParams.clear();

		String sOpportunityId1 = testOppList[0].Id;
		String sOpportunityId2 = testOppList[1].Id;
		String sOpportunityId3 = testOppList[2].Id;

		userList.clear();
		userList.add((User)testUserList[1]);
		userList.add((User)testUserList[3]);
		TestDataGenerator.setUserList(userList);

		// Create opportunity teams
		sParams.put('str_OpportunityId', sOpportunity1.Id);
		sParams.put('str_TeamMemberRole', 'TSM');
		TestDataGenerator.getObject(new OpportunityTeamMember(), 2, sParams);
		sParams.clear();

		sParams.put('str_OpportunityId', sOpportunity2.Id);
		sParams.put('str_TeamMemberRole', 'TSM');
		TestDataGenerator.getObject(new OpportunityTeamMember(), 2, sParams);
		sParams.clear();

		sParams.put('str_OpportunityId', sOpportunity3.Id);
		sParams.put('str_TeamMemberRole', 'TSM');
		sParams.put('str_UserId', testUserList[3].Id);
		TestDataGenerator.getObject(new OpportunityTeamMember(), 1, sParams);
		sParams.clear();

		// Create opportunity share
		sParams.put('str_OpportunityId', sOpportunity1.Id);
		sParams.put('str_OpportunityAccessLevel', 'Edit');
		TestDataGenerator.getObject(new OpportunityShare(), 2, sParams);
		sParams.clear();

		sParams.put('str_OpportunityId', sOpportunity2.Id);
		sParams.put('str_OpportunityAccessLevel', 'Edit');
		TestDataGenerator.getObject(new OpportunityShare(), 2, sParams);
		sParams.clear();

		sParams.put('str_OpportunityId', sOpportunity3.Id);
		sParams.put('str_OpportunityAccessLevel', 'Edit');
		sParams.put('str_UserOrGroupId', testUserList[3].Id);
		TestDataGenerator.getObject(new OpportunityShare(), 2, sParams);
		sParams.clear();
		*/

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
		}	// End for (Integer g=0; g<4; g++)

		// Display the DellTeamMember array
		system.debug('#### DellTeamMember array' + dtmArray);

		// Start the test
		Test.startTest();

		try {
			TeamProcessing.setAccountAndSalesTeams(dtmArray);
		}
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage()+'[ Code:  TeamProcessingTest.setAccountAndSalesTeams_AccStatusA_UserStatusAOrI_SetDTMStatusAOrI() ]', dellConfig.errorEmail);
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

		/*
		// The following assert statements are not valid anymore
		// AccountTeamUtil.updateSalesTeamsAndShares has been commented at TeamProcessing
		// Ensure the correct number of opportunity team members were created
		system.debug('#### Validation of total number of opportunity team members');
		system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);
		system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId2]);
		system.assertEquals(3, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId3]);

		// Ensure the correct individual opportunity team members were created and deleted
		system.debug('#### Validation of individual opportunity team members');
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

		// Ensure the correct number of opportunity shares were created
		system.debug('#### Validation of total number of opportunity shares');
		system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
		system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunityId2 and RowCause = 'Team']);
		system.assertEquals(3, [select count() from OpportunityShare where OpportunityId = :sOpportunityId3 and RowCause = 'Team']);

		// Ensure the correct individual opportunity shares were created
		system.debug('#### Validation of individual opportunity shares');
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

		// Ensure that each opportunity share has EDIT permissions for account
		// opportunity, and case
		system.debug('#### Validation of opportunity share permissions');
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
		system.debug('##### End setAccountAndSalesTeams_AccStatusA_UserStatusAOrI #####');
	}
}