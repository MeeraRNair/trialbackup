/*
Description: Utility module for functions affecting Sales Team Members
- method setDefaultSalesTeam: creates a SalesTeamMember for each AccountTeamMember

Version: 1.0

Author: Caleb Sidel/Christophe Pebre/Albert Lou

History:
1.0 - 20-Aug-2008: Creation, to be released in 9.9
                 : CP - Add setSalesTeam and setOpportunityShare functions for Account Sweeper (Account Team/Sales Team sync)
2.0 - 28-Dec-2010: CR5472 (REL12.1)              
*/

/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13274       Sprint 11       22-June-2016    Afiq            To separate test method in a test class from SalesTeamUtil main class and change logic of the OpportunityShare to OpportunityTeamMember for OpportunityAccess
*/   

public class SalesTeamUtil {

    public static Boolean forceTest = false;
    
    //Rev 2.0   
    public static void setDefaultSalesTeam(List<Opportunity> opps) {        
        try {
            setDefaultSalesTeam(opps, false);
        }
        catch(Exception e) {
            emailUtils.sendSupportEmail('Caught exception from OpportunityTrigger: ' + e.getMessage(), dellConfig.errorEmail);
        }
    }
    //Rev 2.0-end
    
    // Copy the Sales Team to be the same as the related Account's team members
    //Rev 2.0
    public static void setDefaultSalesTeam(List<Opportunity> opps, boolean isPartnerSalesTeam) {    
    
        system.debug('##CP: in setSalesTeam:' + opps.size());
                
        Integer almostDMLRows;
        
        List<OpportunityTeamMember> oppTeamMemberToSaveArray = new List<OpportunityTeamMember>();
        
        // AL - Define array for update of OpportunityShare
        List<OpportunityShare> oppTeamMemberShareToSaveArray = new List<OpportunityShare>();
        
        Set<Id> acc = new Set<Id>();
        List<Opportunity> syncOpps = new List<Opportunity>();
        Map<Id, List<AccountTeamMember>> accountTeamMap = new Map<Id, List<AccountTeamMember>>();
    
        // Cycle through opportunities
        for (Opportunity opp : opps) {

            // If opportunity qualifies, capture the opportunity IDs, and account IDs
            if (opp.Direct_Team_Sync__c == 'True') {

                acc.add(opp.AccountId);
                syncOpps.add(opp);
                accountTeamMap.put(opp.AccountId, null);

            }
            else if (isPartnerSalesTeam) {
                acc.add(opp.PartnerAccountId);
                syncOpps.add(opp);
                accountTeamMap.put(opp.PartnerAccountId, null);
            }

        }   // End for (Opportunity opp : opps)
        


        // Build the allAccTeamMembers array
        // Query for all of the Account Team Members for those Accounts related to the Opportunity list.
        // Loop Query (SOQL for loop), should process 200 records per iteration
        for (List<AccountTeamMember> accTeamMembers : [select accountid, userid, teamMemberRole from AccountTeamMember where user.isActive = true and accountid in :acc]) {
        
            for (AccountTeamMember atm : accTeamMembers) {

                system.debug('##CP: Team member:' + atm.userid);

                List<AccountTeamMember> lstAcctTeam = new List<AccountTeamMember>();
                lstAcctTeam = accountTeamMap.get(atm.accountid);

                if (lstAcctTeam == null) {
                    lstAcctTeam = new List<AccountTeamMember>();
                }

                lstAcctTeam.add(atm);
                accountTeamMap.put(atm.accountid, lstAcctTeam);

            }   // End for (AccountTeamMember atm : accTeamMembers)
        
        }   // End for (List<AccountTeamMember> accTeamMembers : [SOQL])


    
        // Now, parse the Opportunity array to build the sales team
        for (Opportunity opp : syncOpps) {

            // Get the account team members
            List<AccountTeamMember> lstOppAcctTeam = new List<AccountTeamMember>();
            //Rev 2.0
            if (isPartnerSalesTeam) {
                lstOppAcctTeam = accountTeamMap.get(opp.PartnerAccountId);
            }
            else {
                lstOppAcctTeam = accountTeamMap.get(opp.accountid);
            }
            //Rev 2.0-end
            if (lstOppAcctTeam != null) {


                // Search for all account team members where account is related to the oppty
                for (AccountTeamMember atm : lstOppAcctTeam) {
            
                    system.debug('##CP: New Sale Team member:' + atm.userid);
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.opportunityId = opp.id;
                    otm.userId = atm.userID;
                    otm.teamMemberRole = atm.teamMemberRole;
                    
                    //1.0 Start
                    //                   if (atm.userId != opp.OwnerId) {
                        otm.OpportunityAccessLevel = 'Edit';
                    //}
                    //1.0 End
                    oppTeamMemberToSaveArray.add(otm);
            
    
                    // AL - If the Account Team Member is not the owner of
                    // the opportunity, add the member to the OpportunityShare
                    // update array
                    
                    // 1.0 Start
                    /*
                    if (atm.userId != opp.OwnerId) {
    
                        OpportunityShare oppShare = new OpportunityShare();
    
                        oppShare.OpportunityId = opp.Id;
                        oppShare.UserOrGroupId = atm.UserId;
                        oppShare.OpportunityAccessLevel = 'Edit';
    
                        oppTeamMemberShareToSaveArray.add(oppShare);
    
                    }   // AL - End*/
                    //1.0 End
    
        
        
                    // AL: If OTM update array contains 200 records, execute the update
                    if ( oppTeamMemberToSaveArray.size() == 200 || forceTest == true) {
    
                        try {
                            LimitSafeDMLOperations.insertOpportunityTeamMembers(oppTeamMemberToSaveArray);
                        }
                            
                        catch (Exception e) {
                            throw new dellUtil.DellException(e.getMessage());
                        }
    
                        oppTeamMemberToSaveArray.clear();
    
                    }
        
        
                    // AL: If OS update array contains 200 records, execute the update
                    if ( oppTeamMemberShareToSaveArray.size() == 200 || forceTest == true) {
    
                        try {
                            LimitSafeDMLOperations.insertOpportunityShares(oppTeamMemberShareToSaveArray);
                        }
                            
                        catch (Exception e) {
                            throw new dellUtil.DellException(e.getMessage());
                        }
    
                        oppTeamMemberShareToSaveArray.clear();
    
                    }
        
        
                }   // End for (AccountTeamMember atm : lstOppAcctTeam)

            }   // End if (lstOppAcctTeam != null)

        }   // End for (Opportunity opp : syncOpps)
        
    
    
        // AL: Update remaining OTM update records
        if (oppTeamMemberToSaveArray.size() > 0) {

            try {
                LimitSafeDMLOperations.insertOpportunityTeamMembers(oppTeamMemberToSaveArray);
            }
            
            catch (Exception e) {
                throw new dellUtil.DellException(e.getMessage());
            }

            oppTeamMemberToSaveArray.clear();

        }
    
        
        // AL: Update remaining OS update records
        if (oppTeamMemberShareToSaveArray.size() > 0) {

            try {
                LimitSafeDMLOperations.insertOpportunityShares(oppTeamMemberShareToSaveArray);
            }
            
            catch (Exception e) {
                throw new dellUtil.DellException(e.getMessage());
            }

            oppTeamMemberShareToSaveArray.clear();

        }


        // Clear objects
        acc.clear();
        syncOpps.clear();
        accountTeamMap.clear();
    }   // End function setDefaultSalesTeam()

    // Test case 8: [setSalesTeam] Test account with 0 team member
    // Design Document Test Case 1
    /*static testMethod void Test8() {
    
        system.debug('## Start the test 8');
        
        // Test data creation
        Account testAcc;
        List<user> test_user = new List<user>([select id from user where contactId = null and isActive = true limit 11]);
        
        testAcc = new account(name='Test Case 8 - Dell Util');
        testAcc.ownerid = test_user[0].id;
        
        insert testAcc;
        
        // Assertion
        // System.assertEquals(1, [select count() from account where name LIKE 'Test case 8%']);
        
        // Create a new opportunity related to the test account
        Opportunity testOpp;
        testOpp = new opportunity(name='Test Case 8 - Dell Opp');
        testOpp.ownerid = test_user[0].id;
        testOpp.accountId = testAcc.Id;
        testOpp.StageName = 'Discover - 10%';
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
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);


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
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        
        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();

        //force a "high volume" using forceTest
        forceTest = true;
        insert sOpportunity1;
        forceTest = false;

        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
// ALou - 2008/10/16 - Commented out for deployment 
        //List<Opportunity> oppty = new List<Opportunity>([select Direct_Team_Sync__c from Opportunity where Id = :sOpportunity1.id]);
        //System.assertEquals('True',oppty[0].Direct_Team_Sync__c);



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

    }   // End Test Case 9b

    // Test case 10: [setSalesTeam]
    // Exception handling testing: Limit on DML rows
    // Create 1 opportunity related to account with 101 team members,
    // no Default Sales Team for the user

    static testMethod void Test10() {
    
        system.debug('## Start the test 10');
    
    
        // Get 102 users
        List<user> test_user = new List<user>([select id from user where isActive = true limit 102]);
    
    
        // Create the account
        Account testAcc;
        testAcc = new account(name='Test Account 50');  
    
        insert testAcc;
    
        
        // Create the account team members and account shares
        List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
        List<AccountShare> testAcctShs = new List<AccountShare>();
        
        for(Integer j=0; j< 101; j++) { 
    
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
//        System.assertEquals(101, [select count() from AccountTeamMember where Account.Name LIKE 'Test Account 50%']);
    
        
        // Assertion
//        System.assertEquals(101, [select count() from AccountShare where Account.Name LIKE 'Test Account 50%' and rowcause = 'Team']);
    

        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);


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
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);


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
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Indirect', RecordTypeId=sRecordType1);


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
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
    
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


        // Assertion
//        System.assertEquals(1, [select count() from Account where Name LIKE 'Test Account 50%']);
//        System.assertEquals(1, [select count() from Account where Name LIKE 'Test Account 51%']);
        
        
        // Assertion
//        System.assertEquals(10, [select count() from AccountTeamMember where Account.Name LIKE 'Test Account 50%']);
//        System.assertEquals(10, [select count() from AccountTeamMember where Account.Name LIKE 'Test Account 51%']);
    
        
        // Assertion
//        System.assertEquals(10, [select count() from AccountShare where Account.Name LIKE 'Test Account 50%' and rowcause = 'Team']);
//        System.assertEquals(10, [select count() from AccountShare where Account.Name LIKE 'Test Account 51%' and rowcause = 'Team']);


        
        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
    
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=testAcc.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        Opportunity sOpportunity2 = new Opportunity(Name='Opportunity 1', AccountId=testAcc2.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);

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

    }   // End Test Case 14*/
     
}