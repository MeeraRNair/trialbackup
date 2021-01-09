/***********************************************************
* Description   : 
* ---------------------------------------------------------
* Revision  Name    Date        Description
* 1.0       					Creation
  2.0       MenMee	19.07.2011  REL12.10 CR6493 Sales Role Change (Technical Sales Manager -> Inside Product Specialist Manager, System Consultant -> Cross Domain Sales Engineer)      
* 3.0		Azwanti	29.09.2011	REL12.10 CR6493-0182 Sales Role Change (Cross Domain Sales Engineer -> Customer System Engineer, Inside Product Specialist Manager -> Technical Sales Manager)
* 4.0		Azwanti	17.10.2011	REL12.10 CR6493-0182 Sales Role Change (Customer System Engineer -> System Consultant)
*
************************************************************/

global class SalesTeamProcessing {

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
            }   // End for (DellTeamMember tdtm : dtmInput)
        
        }   // End if (stCount) > 0)


        // Send the email
        dellUtil.sendSupportEmail(stTest, dellConfig.errorEmail);
        

    }   // End function emailDataInput (List<DellTeamMember> dtmDataInput)
*/   
    //converts the DellTeamMember objects list to a string list
    public static List<string> conv_dellTeamMembersToStrings(List<DellTeamMember> dellTeamMemberList){
        system.debug('#### converts the DellTeamMember objects list to a string list');
        
        List<string> ResultStringList= new List<string>();
        string DellTeamMemberInString;
        
        for(DellTeamMember DellTeamMemberItem : dellTeamMemberList){
            //joining values in object into a string. values are seperated with a semi column
            DellTeamMemberInString = DellTeamMemberItem.accountId +';'+
                                    DellTeamMemberItem.userId+';'+
                                    DellTeamMemberItem.TeamMemberRole+';'+
                                    DellTeamMemberItem.AccountAccessLevel+';'+
                                    DellTeamMemberItem.OpportunityAccessLevel+';'+
                                    DellTeamMemberItem.CaseAccessLevel+';'+
                                    DellTeamMemberItem.Status;
                                    
            system.debug('#### DellTeamMemberInString : '+ DellTeamMemberInString);     
            ResultStringList.add(DellTeamMemberInString);
        }//end for
        return ResultStringList;
    }//end  of method
    
    //converts the string list to DellTeamMember objects list
    public static List<DellTeamMember> conv_StringsTodellTeamMembers(List<string>  strDellTeamMemberList){
        system.debug('#### converts the string list to DellTeamMember objects list');
        
        List<DellTeamMember> ResultDellTeamMemberList= new List<DellTeamMember>();
        List<string> strObjectValuesList= new List<string>();
        
        
        for(string strDellTeamMItem : strDellTeamMemberList){
            //splitting values based on semi column
            strObjectValuesList = strDellTeamMItem.split(';',-2);
            
            system.debug('#### strObjectValuesList : '+ strObjectValuesList);   
            
            DellTeamMember DellTeamMemberItem= new DellTeamMember();
            
            DellTeamMemberItem.accountId = strObjectValuesList[0];
            DellTeamMemberItem.userId= strObjectValuesList[1];
            DellTeamMemberItem.TeamMemberRole= strObjectValuesList[2];
            DellTeamMemberItem.AccountAccessLevel= strObjectValuesList[3];
            DellTeamMemberItem.OpportunityAccessLevel= strObjectValuesList[4];
            DellTeamMemberItem.CaseAccessLevel= strObjectValuesList[5];
            DellTeamMemberItem.Status = strObjectValuesList[6]; 
                                                
            ResultDellTeamMemberList.add(DellTeamMemberItem);           
                        
        }//end for
        return ResultDellTeamMemberList;
    }//end of method

    //public static void setAccountAndSalesTeamsSub(List<DellTeamMember> dellTeamMembers) {
    @future    
    public static void setAccountAndSalesTeamsSub(List<string>  strDellTeamMemberList) {        
        
        // Display the function
        system.debug('#### In function setAccountAndSalesTeamsSub');
        
        //converts the string list to DellTeamMember objects list
        List<DellTeamMember> dellTeamMembers = conv_StringsTodellTeamMembers(strDellTeamMemberList);


        // Declare variables
        Set<Id> DTMAcctIDs = new Set<Id>();
        Set<Id> DTMUserIDs = new Set<Id>();
        List<DellTeamMember> DTMUpdateArray = new List<DellTeamMember>();
        Set<Id> DTMDeleteAcctIDs = new Set<Id>();
        Set<Id> DTMDeleteUserIDs = new Set<Id>();
        List<DellTeamMember> DTMDeleteArray = new List<DellTeamMember>();
        List<DellTeamMember> DTMNoStatusArray = new List<DellTeamMember>();


        // Test Code
//      emailDataInput (dellTeamMembers);
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

            }   // End if (dtm.Status == 'A')
        

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
                system.debug('#### DellTeamMember = ' + dtm);

            }   // End if dtm.Status == 'I'


            else {

                // Build the array of DellTeamMembers having no status
                DTMNoStatusArray.add(dtm);

            }   // If (dtm.Status != 'A' / 'I')
            
            
        }   // For (DellTeamMember dtm : dellTeamMembers)



        system.debug('#### Update and deletion array construction has been completed');


        // If records with no status exist, email the designated recipient
        if (DTMNoStatusArray.size() > 0) {
        
            // Email the designated recipient with the records
            dellUtil.sendSupportEmail('The following DellTeamMember records do not have a status: ' + DTMNoStatusArray + ' .  Processing of the integration payload set was not stopped.', dellConfig.errorEmail);

            // Clear the arrays
            DTMNoStatusArray.clear();

        }


        // If deletion records exist, perform the deletion from the 
        // AccountTeamMember table and OpportunityTeamMember table
        If (DTMDeleteArray.size() > 0) {

            system.debug('#### DTM deletion array size: ' + DTMDeleteArray.size());

            // Send DellTeamMember update, account ID, and user ID
            // arrays to the AccountTeamMember delete function
//          try {
//              AccountTeamUtil.deleteAccountTeamMembers(DTMDeleteArray);
//          }
//          catch (Exception e) {
//              throw new dellUtil.DellException(e.getMessage());
//          }

            // Delete inactive members from the OpportunityTeamMember table
            try {
                AccountTeamUtil.deleteSalesTeamMembers(DTMDeleteArray, DTMDeleteAcctIDs, DTMDeleteUserIDs);
            }
            catch (Exception e) {
                //throw new dellUtil.DellException(e.getMessage());
                dellUtil.sendSupportEmail('SalesTeamProcessing.AccountTeamUtil.deleteSalesTeamMembers() exception.  The following sales team members were not removed: ' + DTMDeleteArray + '  ' + e.getMessage(), dellConfig.errorEmail);
            }


            // Clear the arrays
            DTMDeleteArray.clear();
            DTMDeleteAcctIDs.clear();
            DTMDeleteUserIDs.clear();

        }   // End If (DTMDeleteArray.size() > 0)


        // if update records exist, perform the update to the account teams and sales teams
        If (DTMUpdateArray.size() > 0) {

            system.debug('#### DTM update array size: ' + DTMUpdateArray.size());


            // Create a map of the active users in the DellTeamMember set
            Map<Id, User> mapActiveUsers = new Map<Id, User>([select Id from User where Id in :DTMUserIDs and IsActive = True]);


            // Send DellTeamMember update, account ID, and user ID
            // arrays to the AccountTeamMember and AccountShare update function
//          try {
//              AccountTeamUtil.updateAccountTeamAndShare(DTMUpdateArray, DTMAcctIDs, DTMUserIDs, mapActiveUsers);
//          }
//          catch (Exception e) {
//              throw new dellUtil.DellException(e.getMessage());
//          }


            // Add Account Team members to Sales Teams
            try {
                AccountTeamUtil.updateSalesTeamsAndShares(DTMUpdateArray, DTMAcctIDs, DTMUserIDs, mapActiveUsers);
            }
            catch (Exception e) {

                //ccws
                //if (e.getMessage().contains('UNABLE_TO_LOCK_ROW')) {
                //    throw new dellUtil.DellException('SalesTeamProcessing.AccountTeamUtil.updateSalesTeamsAndShares() exception: ' + e.getMessage());
                //}
				
                //else {
                    dellUtil.sendSupportEmail('SalesTeamProcessing.AccountTeamUtil.updateSalesTeamsAndShares() exception.  The following sales team members were not added: ' + DTMUpdateArray + '  ' + e.getMessage(), dellConfig.errorEmail);
                //}

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
        return setAccountAndSalesTeamsWrapped(dellTeamMembers);

    }   // End function setAccountAndSalesTeams

	public static String setAccountAndSalesTeamsWrapped(List<DellTeamMember> dellTeamMembers) {

        // Display the function
        //system.debug('In function setAccountAndSalesTeams now . . .');


        // Declare variables
        String sReturnString = 'Completed';
        String sException = '';
        


        try {
            //converting to stringlist before passing to the future method.
            List<string> strDellTeamMemberList =  conv_dellTeamMembersToStrings(dellTeamMembers);
            setAccountAndSalesTeamsSub(strDellTeamMemberList);
        }

        catch (Exception e) {
            
            sException = e.getMessage();
            
            //ccws
            //if (sException.contains('UNABLE_TO_LOCK_ROW')) {
            //    throw new dellUtil.DellException(e);
            //}
            //
            //else {
                dellUtil.sendSupportEmail('SalesTeamProcessing.setAccountAndSalesTeamsSub() exception.  Processing of the integration payload set was stopped.  ' + e.getMessage(), dellConfig.errorEmail);
            //}

        }


        return sReturnString;

    }   // End function setAccountAndSalesTeams
 
    /* Krishna (2-Dec-2008) :   TEST METHODS ADDED */
	//Rev 2.0
	private static final string ROLE_IPSM = 'Technical Sales Manager';//r3.0'Inside Product Specialist Manager';
	private static final string ROLE_XSE = 'System Consultant';//r4.0 'Customer System Engineer';//r3.0 'Cross Domain Sales Engineer';
	private static final string ROLE_SAPPROVER = 'Sales Approver';	  
    //test method to test the method conv_dellTeamMembersToStrings
    public static testMethod void Test_conv_dellTeamMembersToStrings(){
        system.debug('##### Start Test_conv_dellTeamMembersToStrings');
        
        List<DellTeamMember> dellTeamMemberList= new List<DellTeamMember>();     
        List<string>  strDellTeamMemberList = new List<string>();
        
        //creates account with first Sales channel group reference
        Account testAccount=new Account(name='testAccount1234');            
        insert testAccount; 
        List<user> UserList = [SELECT Id, name FROM User WHERE IsActive = true LIMIT 2];    
            

        
        // Build the DellTeamMember array
        for (Integer counter=0; counter<2; counter++) {
        
            DellTeamMember DellTeamMemberItem = new DellTeamMember();
            
            DellTeamMemberItem.AccountId = testAccount.Id;
            DellTeamMemberItem.UserId = UserList[counter].Id;
            
            if (counter == 0){
                DellTeamMemberItem.TeamMemberRole = ROLE_IPSM;
            }           
            else if (counter == 1) {
                DellTeamMemberItem.TeamMemberRole = ROLE_SAPPROVER;
            }                       
            DellTeamMemberItem.AccountAccessLevel = 'Edit';
            DellTeamMemberItem.OpportunityAccessLevel = 'Edit';
            DellTeamMemberItem.CaseAccessLevel = 'Edit';
            DellTeamMemberItem.Status = 'A';
                        
            dellTeamMemberList.add(DellTeamMemberItem);     
        }   // End for 
        string testString= testAccount.Id+';'+UserList[0].Id+';'+ROLE_IPSM+';';
        
        Test.startTest();
        strDellTeamMemberList = conv_dellTeamMembersToStrings(dellTeamMemberList);
        // Stop the test
        Test.stopTest();
        
        //asserts the object is converted to a string
        system.assert(strDellTeamMemberList[0].contains(testString));
        
        system.debug('##### End Test_conv_dellTeamMembersToStrings');
        
    }//end of test method
    //test method to test the method conv_StringsTodellTeamMembers
    public static testMethod void Test_conv_StringsTodellTeamMembers(){
        system.debug('##### Start Test_conv_StringsTodellTeamMembers');
        
        List<DellTeamMember> dellTeamMemberList;     
        List<string>  strDellTeamMemberList =new List<string>{'001R000000AgBYMIA3;00570000000mguDAAQ;Sales Approver;Edit;Edit;Edit;I',
                                                              '001R000000AgBYMIA3;00570000000oOolAAE;TSM;Edit;Edit;Edit;I'};
        
        Test.startTest();
        dellTeamMemberList = conv_StringsTodellTeamMembers(strDellTeamMemberList);
        // Stop the test
        Test.stopTest();        
        
        //asserts the strings are converted to objects properly 
        
        system.assertEquals(dellTeamMemberList[0].AccountId,'001R000000AgBYMIA3');
        system.assertEquals(dellTeamMemberList[0].UserId,'00570000000mguDAAQ');
        system.assertEquals(dellTeamMemberList[0].TeamMemberRole ,ROLE_SAPPROVER);                    
        system.assertEquals(dellTeamMemberList[0].AccountAccessLevel ,'Edit');
        system.assertEquals(dellTeamMemberList[0].OpportunityAccessLevel ,'Edit');
        system.assertEquals(dellTeamMemberList[0].CaseAccessLevel ,'Edit');
        system.assertEquals(dellTeamMemberList[0].Status ,'I'); 
        
        
        system.debug('##### End Test_conv_StringsTodellTeamMembers');
        
    }//end of test method
    // This following test methods are commented out because if not,
    // the running of tests could return errors as some of these test
    // methods require the user to inactive either accounts or users.
/*
    static testMethod void Test0() {

        // Notify that the test will start
        system.debug('##### Start Test Case 0');
    
        // Ensure the correct email address is being used
        system.debug('Validation of email address');
        system.assertEquals('alou@salesforce.com', dellConfig.errorEmail);

    }   // End function Test0() 
*/
/*
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

        }   // End for (Integer g=0; g<2; g++)


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

        }   // End for (Integer g=0; g<2; g++)


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

        }   // End for (Integer g=0; g<4; g++)


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

        }   // End for (Integer g=0; g<2; g++)


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


    }   // End function Test15()
*/
} // End global class SalesTeamProcessing