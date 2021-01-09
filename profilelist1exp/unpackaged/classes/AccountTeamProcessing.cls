global class AccountTeamProcessing {
/*
	public static void emailDataInput (List<DellTeamMember> dtmInput) {

		Integer stCount = 0;
		String stTest = '';
		String stAID = '';
		String stUID = '';
		String stTeamMemberRole = '';
		String stStatus = '';
		String stAccountAccessLevel = '';
		String stOpportunityAccessLevel = '';
		String stCaseAccessLevel = '';


		stCount = dtmInput.size();
		stTest += 'Total number of records received = ' + stCount + '.  ';


		if (stCount > 0) {

			// Construct the information received
			for (DellTeamMember tdtm : dtmInput) {
				stAID = tdtm.AccountId;
				stUID = tdtm.UserId;
				stTeamMemberRole = tdtm.TeamMemberRole;
				stStatus = tdtm.Status;
				stAccountAccessLevel = tdtm.AccountAccessLevel;
				stOpportunityAccessLevel = tdtm.OpportunityAccessLevel;
				stCaseAccessLevel = tdtm.CaseAccessLevel;

				stTest += 'DellTeamMember{';
				stTest += 'AccountId: ' + stAID + ', ';
				stTest += 'UserId: ' + stUID + ', ';
				stTest += 'TeamMemberRole: ' + stTeamMemberRole + ', ';
				stTest += 'Status: ' + stStatus + ', ';
				stTest += 'AccountAccessLevel: ' + stAccountAccessLevel + ', ';
				stTest += 'OpportunityAccessLevel: ' + stOpportunityAccessLevel + ', ';
				stTest += 'CaseAccessLevel: ' + stCaseAccessLevel;
				stTest += '}, ';
			}	// End for (DellTeamMember tdtm : dtmInput)
		
		}	// End if (stCount) > 0)


		// Send the email
		dellUtil.sendSupportEmail(stTest, dellConfig.errorEmail);
		

	}	// End function emailDataInput (List<DellTeamMember> dtmDataInput)


	public static void setAccountAndSalesTeamsSub(List<DellTeamMember> dellTeamMembers) {

		// Display the function
		system.debug('#### In function setAccountAndSalesTeamsSub');


		// Declare variables
		List<Id> DTMAcctIDs = new List<Id>();
		List<Id> DTMUserIDs = new List<Id>();
		List<DellTeamMember> DTMUpdateArray = new List<DellTeamMember>();
		List<Id> DTMDeleteAcctIDs = new List<Id>();
		List<Id> DTMDeleteUserIDs = new List<Id>();
		List<DellTeamMember> DTMDeleteArray = new List<DellTeamMember>();
		List<DellTeamMember> DTMNoStatusArray = new List<DellTeamMember>();


		// Test Code
//		emailDataInput (dellTeamMembers);
		// Test Code End


		// Parse records of DellTeamMember into update records and deletion records
		For (DellTeamMember dtm : dellTeamMembers) {

			if (dtm.Status == 'A') {
		
				// Display record status
				system.debug('#### DellTeamMember status = A');
		
		
				// Build the array of account IDs of Dell team members
				DTMAcctIDs.add(dtm.AccountId);
				
				
				// Build the array of user IDs of Dell team members
				DTMUserIDs.add(dtm.UserId);
				

				// Build the array of DellTeamMembers to update in Account Teams
				// and Sales Teams
				DTMUpdateArray.add(dtm);

			}	// End if (dtm.Status == 'A')
		

			else if (dtm.Status == 'I') {		

				// Display record status
				system.debug('#### DellTeamMember status = I');


				// Build the array of account IDs of DellTeamMembers
				DTMDeleteAcctIDs.add(dtm.AccountId);
				
				
				// Build the array of user IDs of DellTeamMembers
				DTMDeleteUserIDs.add(dtm.UserId);
				
				
				// Build the array of DellTeamMembers to delete in Account Teams
				// and Sales Teams
				DTMDeleteArray.add(dtm);

			}	// End if dtm.Status == 'I'


			else {

				// Build the array of DellTeamMembers having no status
				DTMNoStatusArray.add(dtm);

			}	// If (dtm.Status != 'A' / 'I')
			
			
		}	// For (DellTeamMember dtm : dellTeamMembers)



		system.debug('#### Update and deletion array construction has been completed');


		// If records with no status exist, email the designated recipient
		if (DTMNoStatusArray.size() > 0) {
		
			// Email the designated recipient with the records
			dellUtil.sendSupportEmail('TeamProcessing: The following DellTeamMember records do not have a status: ' + DTMNoStatusArray + ' .  Processing of the integration payload set was not stopped.', dellConfig.errorEmail);

			// Clear the arrays
			DTMNoStatusArray.clear();

		}


		// If deletion records exist, perform the deletion from the 
		// AccountTeamMember table and OpportunityTeamMember table
		If (DTMDeleteArray.size() > 0) {

			system.debug('#### DTM deletion array size: ' + DTMDeleteArray.size());

			// Send DellTeamMember update, account ID, and user ID
			// arrays to the AccountTeamMember delete function
			try {
				AccountTeamUtil.deleteAccountTeamMembers(DTMDeleteArray);
			}
			catch (Exception e) {
				//throw new dellUtil.DellException(e.getMessage());
				dellUtil.sendSupportEmail(e.getMessage() + ' TeamProcessing: deleteAccountTeamMembers: The following account team members were not deleted: ' + DTMDeleteArray, dellConfig.errorEmail);
			}

			// Delete inactive members from the OpportunityTeamMember table
			try {
				AccountTeamUtil.deleteSalesTeamMembers(DTMDeleteArray, DTMDeleteAcctIDs, DTMDeleteUserIDs);
			}
			catch (Exception e) {
				//throw new dellUtil.DellException(e.getMessage());
				dellUtil.sendSupportEmail(e.getMessage() + ' TeamProcessing: deleteSalesTeamMembers: The following sales team members were not deleted: ' + DTMDeleteArray, dellConfig.errorEmail);
			}


			// Clear the arrays
			DTMDeleteArray.clear();
			DTMDeleteAcctIDs.clear();
			DTMDeleteUserIDs.clear();

		}	// End If (DTMDeleteArray.size() > 0)


		// if update records exist, perform the update to the account teams and sales teams
		If (DTMUpdateArray.size() > 0) {

			system.debug('#### DTM update array size: ' + DTMUpdateArray.size());


			// Create a map of the active users in the DellTeamMember set
			Map<Id, User> mapActiveUsers = new Map<Id, User>([select Id from User where Id in :DTMUserIDs and IsActive = True]);


			// Send DellTeamMember update, account ID, and user ID
			// arrays to the AccountTeamMember and AccountShare update function
			try {
				AccountTeamUtil.updateAccountTeamAndShare(DTMUpdateArray, DTMAcctIDs, DTMUserIDs, mapActiveUsers);
			}
			catch (Exception e) {
				//throw new dellUtil.DellException(e.getMessage());
				dellUtil.sendSupportEmail(e.getMessage() + ' TeamProcessing: updateAccountTeamAndShare: The following account team members were not inserted: ' + DTMUpdateArray, dellConfig.errorEmail);
			}


			// Add Account Team members to Sales Teams
			try {
				AccountTeamUtil.updateSalesTeamsAndShares(DTMUpdateArray, DTMAcctIDs, DTMUserIDs, mapActiveUsers);
			}
			catch (Exception e) {
				//throw new dellUtil.DellException(e.getMessage());
				dellUtil.sendSupportEmail(e.getMessage() + ' TeamProcessing: updateSalesTeamsAndShares: The following sales team members were not inserted: ' + DTMUpdateArray, dellConfig.errorEmail);
			}	


			// Clear the arrays
			DTMUpdateArray.clear();
			DTMAcctIDs.clear();
			DTMUserIDs.clear();
			mapActiveUsers.clear();

		} // End If (DTMUpdateArray.size() > 0)


	} // End function setAccountAndSalesTeamsSub



	webService static String setAccountAndSalesTeams(List<DellTeamMember> dellTeamMembers) {

		// Display the function
		system.debug('In function setAccountAndSalesTeams now . . .');


		// Declare variables
		String sReturnString = 'Completed';
		String sException = '';


		try {
			setAccountAndSalesTeamsSub(dellTeamMembers);
		}

		catch (Exception e) {

			sException = e.getMessage();
			
			if (sException.contains('UNABLE_TO_LOCK_ROW')) {
				throw new dellUtil.DellException(e);
			}

			else {
				dellUtil.sendSupportEmail('TeamProcessing: Processing of the integration payload set was stopped.  ' + e.getMessage(), dellConfig.errorEmail);
			}

		}


		return sReturnString;

	}	// End function setAccountAndSalesTeams





	// This following test methods are commented out because if not,
	// the running of tests could return errors as some of these test
	// methods require the user to inactive either accounts or users.

///////
	static testMethod void Test0() {

		// Notify that the test will start
		system.debug('##### Start Test Case 0');
	
		// Ensure the correct email address is being used
		system.debug('Validation of email address');
		system.assertEquals('alou@salesforce.com', dellConfig.errorEmail);

	}	// End function Test0()	
////////

	// Test Case 2
	// Function: setAccountAndSalesTeams
	// Test Condition:
	// DellTeamMember = [1 account, 2 members, status = 'A']
	static testMethod void Test2() {
	
		// Notify that the test will start
		system.debug('##### Start Test Case 2');

		// Declare variables and arrays
		Account sAccount1 = new Account(name='Test Account 40');	// Test Account 40
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
				dtmRecord.TeamMemberRole = 'TSM';
			}
			
			else if (g == 1) {
				dtmRecord.TeamMemberRole = 'Sales Approver';
			}
			
			else {
				dtmRecord.TeamMemberRole = 'SC';
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
			setAccountAndSalesTeams(dtmArray);
		}
		
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
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


	}	// End function Test2()



	// Test Case 3
	// Function: setAccountAndSalesTeams
	// Test Condition:
	// DellTeamMember = [1 account, 2 members, status = 'A' / 'I']
	static testMethod void Test3() {
	
		// Notify that the test will start
		system.debug('##### Start Test Case 3');

		// Declare variables and arrays
		Account sAccount1 = new Account(name='Test Account 40');	// Test Account 40
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
				dtmRecord.TeamMemberRole = 'TSM';
			}
			
			else if (g == 1) {
				dtmRecord.TeamMemberRole = 'Sales Approver';
			}
			
			else {
				dtmRecord.TeamMemberRole = 'SC';
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

		}	// End for (Integer g=0; g<2; g++)


		// Display the DellTeamMember array
		system.debug('#### DellTeamMember array' + dtmArray);



		// Start the test
		Test.startTest();
	
		
		try {
			setAccountAndSalesTeams(dtmArray);
		}
		
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
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


	}	// End function Test3()



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
				dtmRecord.TeamMemberRole = 'TSM';
			}
			
			else if ((g == 1) || (g == 3)) {
				dtmRecord.TeamMemberRole = 'Sales Approver';
			}
			
			else {
				dtmRecord.TeamMemberRole = 'SC';
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
			setAccountAndSalesTeams(dtmArray);
		}
		
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
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


	}	// End function Test7()



	// Test Case 15
	// Function: setAccountAndSalesTeams
	// Test Condition:
	// DellTeamMember = [1 account, 4 members, status = 'A' / 'I']
	static testMethod void Test15() {
	
		// Notify that the test will start
		system.debug('##### Start Test Case 15');

		// Declare variables and arrays
		Account sAccount1 = new Account(name='Test Account 40');	// Test Account 40
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
				dtmRecord.TeamMemberRole = 'TSM';
			}
			
			else if ((g == 1) || (g == 3)) {
				dtmRecord.TeamMemberRole = 'Sales Approver';
			}
			
			else {
				dtmRecord.TeamMemberRole = 'SC';
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
		AccountTeamMember acctTM = new AccountTeamMember();
		acctTM.AccountId = sAccount1.Id;
		acctTM.UserId = testUser[2].Id;
		acctTM.TeamMemberRole = 'TSM';

		AccountTeamMember acctTM1 = new AccountTeamMember();
		acctTM1.AccountId = sAccount1.Id;
		acctTM1.UserId = testUser[3].Id;
		acctTM1.TeamMemberRole = 'Sales Approver';

		AccountTeamMember acctTM2 = new AccountTeamMember();
		acctTM2.AccountId = sAccount1.Id;
		acctTM2.UserId = testUser[4].Id;
		acctTM2.TeamMemberRole = 'TSM';
		
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
			setAccountAndSalesTeams(dtmArray);
		}
		
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
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
		for (AccountShare acctShare : [select Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel from AccountShare where Account.Name = 'Test Account 40' and RowCause = 'Team']) {
			system.assertEquals('Edit', acctShare.AccountAccessLevel);
			system.assertEquals('Edit', acctShare.OpportunityAccessLevel);
			system.assertEquals('Edit', acctShare.CaseAccessLevel);
		}		


	}	// End function Test15()



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
		String sRecordType1 = '012300000004zf2';	// Standard Opportunity
		Date dCloseDate = Date.newInstance(2011,03,26);

		Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
		
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
				dtmRecord.TeamMemberRole = 'TSM';
			}
			
			else if (g == 1) {
				dtmRecord.TeamMemberRole = 'Sales Approver';
			}
			
			else {
				dtmRecord.TeamMemberRole = 'SC';
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
			setAccountAndSalesTeams(dtmArray);
		}
		
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
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


		// Ensure the correct number of opportunity team members were created
		system.debug('#### Validation of total number of opportunity team members');
		system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1]);


		// Ensure the correct individual opportunity team members were created
		system.debug('#### Validation of individual opportunity team members');
		system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId0]);
		system.assertEquals(1, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunityId1 and UserId = :sUserId1]);


		// Ensure the correct number of opportunity shares were created
		system.debug('#### Validation of total number of opportunity shares');
		system.assertEquals(1, [select count() from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']);


		// Ensure the correct individual opportunity shares were created
		system.debug('#### Validation of individual opportunity shares');
		system.assertEquals(1, [select count() from OpportunityShare where UserOrGroupId = :sUserId0 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);
		system.assertEquals(0, [select count() from OpportunityShare where UserOrGroupId = :sUserId1 and OpportunityId = :sOpportunityId1 and RowCause = 'Team']);


		// Ensure that each opportunity share has EDIT permissions for account
		// opportunity, and case
		system.debug('#### Validation of opportunity share permissions');
		for (OpportunityShare oppShare : [select Id, OpportunityAccessLevel from OpportunityShare where OpportunityId = :sOpportunityId1 and RowCause = 'Team']) {
			system.assertEquals('Edit', oppShare.OpportunityAccessLevel);
		}		


	}	// End function Test20()



	// Test Case 22
	// Function: setAccountAndSalesTeams
	// Test Condition:
	// DellTeamMember:
	// 4 records total
	// 2 accounts, 2 active members
	// Account 2 is inactive
	// One opportunity for each account
	static testMethod void Test22() {
	
		// Notify that the test will start
		system.debug('##### Start Test Case 22');

		// Declare variables and arrays
		Account sAccount1 = new Account(name='Test Account 40');
		Account sAccount2 = new Account(name='Test Account 41', Status__c='Inactive');

		List<user> testUser = new List<user>([select Id from user where FirstName like 'car%' and IsActive = true limit 2]);

		List<DellTeamMember> dtmArray = new List<DellTeamMember>();
//		List<AccountTeamMember> testATM = new List<AccountTeamMember>();
//		List<AccountShare> testAS = new List<AccountShare>();

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
				dtmRecord.TeamMemberRole = 'TSM';
			}
			
			else if ((g == 1) || (g == 3)) {
				dtmRecord.TeamMemberRole = 'Sales Approver';
			}
			
			else {
				dtmRecord.TeamMemberRole = 'SC';
			}

			dtmRecord.AccountAccessLevel = 'Edit';
			dtmRecord.OpportunityAccessLevel = 'Edit';
			dtmRecord.CaseAccessLevel = 'Edit';
			dtmRecord.Status = 'A';

			dtmArray.add(dtmRecord);

		}	// End for (Integer g=0; g<4; g++)


		// Display the DellTeamMember array
		system.debug('#### DellTeamMember array' + dtmArray);


		// Create the opportunities
		String sRecordType1 = '012300000004zf2';	// Standard Opportunity
		Date dCloseDate = Date.newInstance(2011,03,26);

		Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
		Opportunity sOpportunity2 = new Opportunity(Name='Opportunity 2', AccountId=sAccount2.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
		
		insert sOpportunity1;
		insert sOpportunity2;

		String sOpportunityId1 = sOpportunity1.Id;
		String sOpportunityId2 = sOpportunity2.Id;


		// Start the test
		Test.startTest();
	
		
		try {
			setAccountAndSalesTeams(dtmArray);
		}
		
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
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


	}	// End function Test22()



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
			acctTM0.TeamMemberRole = 'TSM';
	
			AccountTeamMember acctTM1 = new AccountTeamMember();
			acctTM1.AccountId = sAccount1.Id;
			acctTM1.UserId = testUser[3].Id;
			acctTM1.TeamMemberRole = 'Sales Approver';
	
			AccountTeamMember acctTM2 = new AccountTeamMember();
			acctTM2.AccountId = sAccount1.Id;
			acctTM2.UserId = testUser[4].Id;
			acctTM2.TeamMemberRole = 'TSM';
			
			testATM.add(acctTM0);		
			testATM.add(acctTM1);	
			testATM.add(acctTM2);
	
			// Display the DellTeamMember array
	//		system.debug('#### AccountTeamMember array = ' + testATM);
	
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
//			system.debug('#### AccountShare array ' + testAS);
	
	
			insert testAS;


		// Create opportunities
		String sRecordType1 = '012300000004zf2';	// Standard Opportunity
		Date dCloseDate = Date.newInstance(2011,03,26);

		Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
		Opportunity sOpportunity2 = new Opportunity(Name='Opportunity 2', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
		Opportunity sOpportunity3 = new Opportunity(Name='Opportunity 3', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);

		insert sOpportunity1;
		insert sOpportunity2;
		insert sOpportunity3;

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
			oppTM0.TeamMemberRole = 'TSM';
	
			OpportunityTeamMember oppTM1 = new OpportunityTeamMember();
			oppTM1.OpportunityId = sOpportunity2.Id;
			oppTM1.UserId = testUser[3].Id;
			oppTM1.TeamMemberRole = 'Sales Approver';
	
			OpportunityTeamMember oppTM2 = new OpportunityTeamMember();
			oppTM2.OpportunityId = sOpportunity2.Id;
			oppTM2.UserId = testUser[4].Id;
			oppTM2.TeamMemberRole = 'TSM';

			OpportunityTeamMember oppTM3 = new OpportunityTeamMember();
			oppTM3.OpportunityId = sOpportunity3.Id;
			oppTM3.UserId = testUser[2].Id;
			oppTM3.TeamMemberRole = 'TSM';
	
			OpportunityTeamMember oppTM4 = new OpportunityTeamMember();
			oppTM4.OpportunityId = sOpportunity3.Id;
			oppTM4.UserId = testUser[3].Id;
			oppTM4.TeamMemberRole = 'Sales Approver';
	
			OpportunityTeamMember oppTM5 = new OpportunityTeamMember();
			oppTM5.OpportunityId = sOpportunity3.Id;
			oppTM5.UserId = testUser[4].Id;
			oppTM5.TeamMemberRole = 'TSM';

			testOTM.add(oppTM0);		
			testOTM.add(oppTM1);	
			testOTM.add(oppTM2);
			testOTM.add(oppTM3);		
			testOTM.add(oppTM4);	
			testOTM.add(oppTM5);


			// Display the DellTeamMember array
	//		system.debug('#### AccountTeamMember array = ' + testATM);
	
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
//			system.debug('#### AccountShare array ' + testAS);
	
	
			insert testOS;



		// Build the DellTeamMember array
		List<DellTeamMember> dtmArray = new List<DellTeamMember>();

		for (Integer g=0; g<4; g++) {
			
			DellTeamMember dtmRecord = new DellTeamMember();
			
			dtmRecord.AccountId = sAccount1.Id;
			dtmRecord.UserId = testUser[g].Id;


			if ((g == 0) || (g == 2)) {
				dtmRecord.TeamMemberRole = 'TSM';
			}
			
			else if ((g == 1) || (g == 3)) {
				dtmRecord.TeamMemberRole = 'Sales Approver';
			}
			
			else {
				dtmRecord.TeamMemberRole = 'SC';
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
			setAccountAndSalesTeams(dtmArray);
		}
		
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
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
		

	}	// End function Test28()



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
			acctTM0.TeamMemberRole = 'TSM';
	
			AccountTeamMember acctTM1 = new AccountTeamMember();
			acctTM1.AccountId = sAccount1.Id;
			acctTM1.UserId = testUser[1].Id;
			acctTM1.TeamMemberRole = 'Sales Approver';
			
			testATM.add(acctTM0);		
			testATM.add(acctTM1);	
	
			// Display the DellTeamMember array
	//		system.debug('#### AccountTeamMember array = ' + testATM);
	
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
//			system.debug('#### AccountShare array ' + testAS);
	
	
			insert testAS;


		// Create opportunities
		String sRecordType1 = '012300000004zf2';	// Standard Opportunity
		Date dCloseDate = Date.newInstance(2011,03,26);

		Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
		Opportunity sOpportunity2 = new Opportunity(Name='Opportunity 2', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Indirect', RecordTypeId=sRecordType1);
		Opportunity sOpportunity3 = new Opportunity(Name='Opportunity 3', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);

		insert sOpportunity1;
		insert sOpportunity2;
		insert sOpportunity3;

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
			oppTM0.TeamMemberRole = 'TSM';
	
			OpportunityTeamMember oppTM1 = new OpportunityTeamMember();
			oppTM1.OpportunityId = sOpportunity1.Id;
			oppTM1.UserId = testUser[3].Id;
			oppTM1.TeamMemberRole = 'Sales Approver';
	
			OpportunityTeamMember oppTM2 = new OpportunityTeamMember();
			oppTM2.OpportunityId = sOpportunity2.Id;
			oppTM2.UserId = testUser[1].Id;
			oppTM2.TeamMemberRole = 'TSM';

			OpportunityTeamMember oppTM3 = new OpportunityTeamMember();
			oppTM3.OpportunityId = sOpportunity2.Id;
			oppTM3.UserId = testUser[3].Id;
			oppTM3.TeamMemberRole = 'TSM';
	
			OpportunityTeamMember oppTM4 = new OpportunityTeamMember();
			oppTM4.OpportunityId = sOpportunity3.Id;
			oppTM4.UserId = testUser[3].Id;
			oppTM4.TeamMemberRole = 'TSM';

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
				dtmRecord.TeamMemberRole = 'TSM';
			}
			
			else if ((g == 1) || (g == 3)) {
				dtmRecord.TeamMemberRole = 'Sales Approver';
			}
			
			else {
				dtmRecord.TeamMemberRole = 'SC';
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
			setAccountAndSalesTeams(dtmArray);
		}
		
		catch (Exception e) {
			DellUtil.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
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
		

	}	// End function Test29()
*/
}	// End global class AccountTeamProcessing