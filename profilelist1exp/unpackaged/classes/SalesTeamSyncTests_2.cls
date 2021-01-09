@isTest
Global Class SalesTeamSyncTests_2 {

/*
This Class of test cases contains test methods that test Each 
Function of() the account team And sales team synchronization
individually.



Revision History

Revision    Date            Modified By         Description
---------   ---------       -----------         -----------------------
1.0         12/16/2008      Albert Lou          Initial Creation
2.0         19.07.2011      MenMee              Rev 2.0 REL12.10 CR6493 Sales Role Change (Technical Sales Manager -> Inside Product Specialist Manager, System Consultant -> Cross Domain Sales Engineer)
3.0         29.09.2011      Azwanti             REL12.10 CR6493-0182 Sales Role Change (Inside Product Specialist Manager -> Technical Sales Manager)
*/
/**
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 4.0      13477       FY17-DCS-1002   07-Sep-2016     Fenny           Summer '16 seasonal release that has been causing Account team owner and members to have Ready only access to their Accounts and Related objects.
 * 5.0      18167       FY20-DCS-0102(STORY 7381183)    Shubham Bhatt             Territory Assignments- Change in Opportunity Owner - Prod Fix
**/

    //Rev 2.0
    Private Static final String ROLE_IPSM = 'Technical Sales Manager';//r3.0 'Inside Product Specialist Manager';

    //Added custom settings to populate StageName values.
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = New OWD__c();
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
    
    // Test function deleteATM()
    Static testMethod void Test_deleteATM() {

        System.debug('#### In test method Test_deleteATM() now . . . ');

        // Declare variables
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();
        List<ID> testArrayID = new List<ID>();
        

        // Get Users
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Create account
        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;


        // Create account team
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
			acctTM.OpportunityAccessLevel = 'Edit';						
            
            // Add individual ATMs to array of ATMs
            testATM.add(acctTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display And create the AccountTeamMember array
        System.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;
    
    
        // Build the account team member test array
        For (Integer i= 0; i < testATM.size(); i++) {

            AccountTeamMember IndATM = New AccountTeamMember();
            IndATM = testATM[i];
            arrayATM.add(IndATM);

            testArrayID.add(testATM[i].Id);

        }   // End for (var i=0; i <= testATM.size(); i++)


        // Test the deleteATM function
        Test.startTest();
        AccountTeamUtil.deleteATM(arrayATM);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(0, [select count() from AccountTeamMember where Id in :testArrayID]);


    }   // End Test_deleteATM()



    Static testMethod void Test_deleteOTM() {
        TriggerExecutionController.setSkipAllTriggers(True);

        System.debug('#### In test method Test_deleteOTM() now . . . ');
        
        
        // Declare variables
        List<OpportunityTeamMember> arrayOTM = new List<OpportunityTeamMember>();
        List<ID> testArrayID = new List<ID>();


        // Get Users
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Create account
        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(2011,03,26);
        
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1',Primary_Competitor_Product_Type__c= 'CI', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        insert sOpportunity1;


        // Create opportunity team
        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';


            // Add individual ATMs to array of ATMs
            testOTM.add(oppTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        System.debug('#### OpportunityTeamMember array = ' + testOTM);
        insert testOTM;


        // Build the opportunity team member test array
        For (Integer i= 0; i < testOTM.size(); i++) {

            OpportunityTeamMember IndOTM = New OpportunityTeamMember();
            IndOTM = testOTM[i];
            arrayOTM.add(IndOTM);

            testArrayID.add(testOTM[i].Id);

        }   // End for (var i=0; i <= testOTM.size(); i++)


        // Test the deleteOTM function
        Test.startTest();
        AccountTeamUtilHelper.deleteOTM(arrayOTM);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(0, [select count() from OpportunityTeamMember where Id in :testArrayID]);


    }   // End Test_deleteOTM()



    Static testMethod void Test_updateATM() {

        System.debug('#### In test method Test_updateATM() now . . . ');

        // Declare variables
        List<ID> testArrayID = new List<ID>();
        

        // Get Users 
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);
        
        
        
        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }
        

        // Create account
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Create account team
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;          
            acctTM.CaseAccesslevel = 'Edit';          
            acctTM.opportunityAccesslevel = 'Edit';       
            
            // Add individual ATMs to array of ATMs
            testATM.add(acctTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display And create the AccountTeamMember array
        System.debug('#### AccountTeamMember array = ' + testATM);



        // Test the updateATM function
        Test.startTest();
        AccountTeamUtil.updateATM(testATM);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(5, [select count() from AccountTeamMember where AccountId = :sAccount1.Id And UserId in :testArrayID]);

    }   // Test_updateATM()


    /* 2.0 Commented
                    Static testMethod void Test_updateAS() {

        System.debug('#### In test method Test_updateAS() now . . . ');

        // Declare variables
        List<ID> testArrayID = new List<ID>();
        

        // Get Users 
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);
        
        
        
        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }
        
        

        // Create account
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Create account team
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;          
            
            // Add individual ATMs to array of ATMs
            testATM.add(acctTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display And create the AccountTeamMember array
        System.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;



        // Create the account share
        List<AccountShare> testAS = new List<AccountShare>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            AccountShare acctS = new AccountShare();
            acctS.AccountId = sAccount1.Id;
            acctS.UserOrGroupId = testUser[h].Id;
            acctS.AccountAccessLevel = 'Edit';
            acctS.OpportunityAccessLevel = 'Edit';
            acctS.CaseAccessLevel = 'Edit';

            // Add individual ATMs to array of ATMs
            testAS.add(acctS);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display And create the AccountShare array
        System.debug('#### AccountShare array = ' + testAS); 


        // Test the updateAS function
        Test.startTest();
        AccountTeamUtil.updateAS(testAS);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(5, [select count() from AccountShare where AccountId = :sAccount1.Id And UserOrGroupId in :testArrayID]);

    }   // Test_updateAS() */


    Static testMethod void Test_updateOTM() {
        TriggerExecutionController.setSkipAllTriggers(True);

        System.debug('#### In test method Test_updateOTM() now . . . ');
        
        // Declare variables
        List<ID> testArrayID = new List<ID>();


        // Get Users
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }


        // Create account
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(2011, 3, 26);
        
        Opportunity sOpportunity1 = New Opportunity(Name ='Opportunity 1',Primary_Competitor_Product_Type__c ='CI', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        insert sOpportunity1;


        // Create opportunity team
        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';


            // Add individual ATMs to array of ATMs
            testOTM.add(oppTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        System.debug('#### OpportunityTeamMember array = ' + testOTM);


        // Test the updateOTM function
        Test.startTest();
        AccountTeamUtil.updateOTM(testOTM);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(5, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id And UserId in :testArrayID]);


    }   // Test_updateOTM()


    /* 2.0 Commented
                    Static testMethod void Test_updateOS() {
        TriggerExecutionController.setSkipAllTriggers(True);

        System.debug('#### In test method Test_updateOS() now . . . ');

        // Declare variables
        List<ID> testArrayID = new List<ID>();
        

        // Get Users
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }


        // Create account
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(2011, 3, 26);
        
        Opportunity sOpportunity1 = New Opportunity(Name ='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        insert sOpportunity1;


        // Create opportunity team
        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';

            
            // Add individual ATMs to array of ATMs
            testOTM.add(oppTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        System.debug('#### OpportunityTeamMember array = ' + testOTM);
        insert testOTM;


        // Create opportunity share
        List<OpportunityShare> testOS = new List<OpportunityShare>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            OpportunityShare oppS = new OpportunityShare();
            oppS.OpportunityId = sOpportunity1.Id;
            oppS.UserOrGroupId = testUser[h].Id;
            oppS.OpportunityAccessLevel = 'Edit';


            // Add individual ATMs to array of ATMs
            testOS.add(oppS);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        System.debug('#### OpportunityShare array = ' + testOS);


        // Test the updateOS function
        Test.startTest();
        AccountTeamUtil.updateOS(testOS);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(5, [select count() from OpportunityShare where OpportunityId = :sOpportunity1.Id And UserOrGroupId in :testArrayID]);

    }   // Test_updateOS() */


    Static testMethod void Test_updateOpp() {
        TriggerExecutionController.setSkipAllTriggers(True);

        System.debug('#### In test method Test_updateOpp() now . . . ');

        // Declare variables
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> UpdateResults = new List<CustomResult>();
        List<Opportunity> arrOpp = new List<Opportunity>();
        

        // Get Users 
        List<user> testUser = new List<user>([select Id from user where IsActive = true AND UserType ='Standard' limit 5]);
        system.debug('#### Array testUser = ' + testUser);
        

        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }
        

        // Create account
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(2011, 3, 26);
        
        Opportunity sOpportunity1 = New Opportunity(Name ='Opportunity 1',Primary_Competitor_Product_Type__c = 'CI', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        insert sOpportunity1;


        // Update the opportunity
        sOpportunity1.OwnerId = testUser[3].Id;
        arrOpp.add(sOpportunity1);
        

        // Test the updateOpp function
        Test.startTest();
        AccountTeamUtil.updateOpp(arrOpp);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(1, [select count() from Opportunity where Id = :sOpportunity1.Id And OwnerId = : testUser[3].Id]);


    }   // Test_updateOpp()



    Static testMethod void Test_assembleATMDelArray() {

        System.debug('#### In test method Test_assembleATMDelArray() now . . . ');

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
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Create account team
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;   
			acctTM.OpportunityAccessLevel = 'Edit';			
            
            // Add individual ATMs to array of ATMs
            testATM.add(acctTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display And create the AccountTeamMember array
        System.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;
    
    
        // Assert that the account team members where created
        System.assertEquals(100, [select count() from AccountTeamMember where AccountId = : sAccount1.Id And UserId in :testArrayID]);



        // Create the DellTeamMember deletion array
        For (Integer h= 0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = New DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            
            // Add individual DTMs to array of DTMs
            arrayDTM.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Test the assemblyDTMDelArray function
        Test.startTest();
        AccountTeamUtil.assembleATMDelArray(arrayDTM);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(0, [select count() from AccountTeamMember where AccountId = :sAccount1.Id And UserId in :testArrayID]);


    }   // End Test_assembleATMDelArray()



    Static testMethod void Test_assembleOTMDelArray() {
        TriggerExecutionController.setSkipAllTriggers(True);

        System.debug('#### In test method Test_assembleOTMDelArray() now . . . ');

        // Declare variables
        List<OpportunityTeamMember> arrayOTM = new List<OpportunityTeamMember>();
        List<ID> testArrayID = new List<ID>();


        // Get Users
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }


        // Create account
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        Date dCloseDate = Date.newInstance(2011, 3, 26);
        
        Opportunity sOpportunity1 = New Opportunity(Name ='Opportunity 1',Primary_Competitor_Product_Type__c = 'CI', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        insert sOpportunity1;


        // Create opportunity team
        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';


            // Add individual ATMs to array of ATMs
            testOTM.add(oppTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        System.debug('#### OpportunityTeamMember array = ' + testOTM);
        insert testOTM;


        // Assert that the opportunity team members were created
        System.debug('#### Verifying that opportunity team members were created');
        System.assertEquals(5, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id And UserId in :testArrayID]);


        // Test the assembleOTMDelArray function
        Test.startTest();
        AccountTeamUtilHelper.assembleOTMDelArray(testOTM);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id And UserId in :testArrayID]);

    }   // End Test_assembleOTMDelArray()


    Static testMethod void Test_deleteAccountTeamMembers() {

        System.debug('#### In test method Test_deleteAccountTeamMembers() now . . . ');

        // Declare variables
        List<DellTeamMember> arrayDTM = new List<DellTeamMember>();
        List<ID> testArrayID = new List<ID>();
        

        // Get Users
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }


        // Create account
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Create account team
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;    
			acctTM.OpportunityAccessLevel = 'Edit';						
            
            // Add individual ATMs to array of ATMs
            testATM.add(acctTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display And create the AccountTeamMember array
        System.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;
    
    
        // Assert that the account team members where created
        System.assertEquals(5, [select count() from AccountTeamMember where AccountId = : sAccount1.Id And UserId in :testArrayID]);


        // Create the DellTeamMember deletion array
        For (Integer h= 0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = New DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            
            // Add individual DTMs to array of DTMs
            arrayDTM.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Test the deleteAccountTeamMembers function
        Test.startTest();
        AccountTeamUtil.deleteAccountTeamMembers(arrayDTM);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        System.assertEquals(0, [select count() from AccountTeamMember where AccountId = :sAccount1.Id And UserId in :testArrayID]);


    }   // End Test_deleteAccountTeamMembers()


    Static testMethod void Test_deleteSalesTeamMembers() {
        TriggerExecutionController.setSkipAllTriggers(True);

        System.debug('#### In test method Test_deleteSalesTeamMembers() now . . . ');

        // Declare variables
        List<DellTeamMember> arrayDTM = new List<DellTeamMember>();
        List<OpportunityTeamMember> arrayOTM = new List<OpportunityTeamMember>();
        List<ID> testArrayID = new List<ID>();
        Set<ID> DTMAcctIDs = new Set<ID>();
        Set<ID> DTMUserIDs = new Set<ID>();


        // Get Users
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {

            testArrayID.add(testUser[k].Id);

            // Add to set array
            DTMUserIDs.add(testUser[k].Id);
        }


        // Create account
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Add account to set array
        DTMAcctIDs.add(sAccount1.Id);


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        // Date dCloseDate = Date.newInstance(2011, 3, 26); // Fenny commented [18-July-2014]: To fulfill New VR OpptyBookDateValidation
        Date dCloseDate = Date.Today(); // Fenny added [18-July-2014]:  To fulfill New VR OpptyBookDateValidation
        
        Opportunity sOpportunity1 = New Opportunity(Name ='Opportunity 1',ownerid = testUser[0].id, AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        insert sOpportunity1;


        // Create opportunity team
        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();

        for (Integer h=0; h <testUser.size(); h++) {
        
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';


            // Add individual ATMs to array of ATMs
            testOTM.add(oppTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        System.debug('#### OpportunityTeamMember array = ' + testOTM);
        insert testOTM;


        // Assert that the opportunity team members were created
        System.debug('#### Verifying that opportunity team members were created');
        System.assertEquals(5, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id And UserId in :testArrayID]);


        // Create the DellTeamMember deletion array
        For (Integer h= 0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = New DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            
            // Add individual DTMs to array of DTMs
            arrayDTM.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Test the assembleOTMDelArray function
        Test.startTest();
        AccountTeamUtil.deleteSalesTeamMembers(arrayDTM, DTMAcctIDs, DTMUserIDs);
        Test.stopTest();


        // Verify the results
        System.debug('#### Test Verification ');
        // System.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id And UserId in :testArrayID]);

    }   // End Test_deleteSalesTeamMembers()


    Static testMethod void Test_updateAccountTeamAndShare() {

        System.debug('#### In test method Test_updateAccountTeamAndShare() now . . . ');

        // Declare variables
        Set<Id> DTMUserIDs = New Set<Id>();
        Set<Id> DTMAcctIDs = New Set<Id>();
        List<DellTeamMember> DTMUpdateArray = new List<DellTeamMember>();
        Map<Id, User> mapActiveUsers = new Map<Id, User>();


        // Get Users 
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);
        

        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {

            // Create an array of user IDs
            DTMUserIDs.add(testUser[k].Id);
            
            // Create the map array
            mapActiveUsers.put(testUser[k].Id, testUser[k]);
        }
        

        // Create account
        Account sAccount1 = New Account(name ='Test Account 001');
        insert sAccount1;


        // Create an array of account IDs
        DTMAcctIDs.add(sAccount1.Id);


        // Create the DellTeamMember array
        For (Integer h= 0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = new DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            indDTM.AccountAccessLevel = 'Edit';
            indDTM.OpportunityAccessLevel = 'Edit';
            indDTM.CaseAccessLevel = 'Edit';


            // Add individual DTMs to array of DTMs
            DTMUpdateArray.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display and create the DellTeamMember array
        system.debug('#### DellTeamMember array = ' + DTMUpdateArray);


        // Test the updateAccountTeamAndShare() function
        Test.startTest();
        AccountTeamUtil.updateAccountTeamAndShare(DTMUpdateArray, DTMAcctIDs, DTMUserIDs, mapActiveUsers);
        Test.stopTest();


        // Verify the results
        system.debug('#### Test Verification ');
        system.assertEquals(5, [select count() from AccountTeamMember where AccountId = :sAccount1.Id and UserId in :DTMUserIDs]);
        system.assertEquals(5, [select count() from AccountShare where AccountId = :sAccount1.Id and UserOrGroupId in :DTMUserIDs]);


    }   // End Test_updateAccountTeamAndShare()



    static testMethod void Test_TPsetAccountAndSalesTeamsSub() {

        system.debug('#### In test method Test_TPsetAccountAndSalesTeamsSub() now . . . ');

        // Declare variables
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();
        List<DellTeamMember> dellTeamMembers = new List<DellTeamMember>();
        List<ID> lstActiveUsers = new List<ID>();
        List<ID> lstInActiveUsers = new List<ID>();


        // Get Users 
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Create account
        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;


        // Create the DellTeamMember array
        for (Integer h=0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = new DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            indDTM.AccountAccessLevel = 'Edit';
            indDTM.OpportunityAccessLevel = 'Edit';
            indDTM.CaseAccessLevel = 'Edit';

            if (h == 0 || h == 1) {
                indDTM.Status = 'A';
                
                lstActiveUsers.add(testUser[h].Id);
            }

            else if (h == 2 || h == 3) {
                indDTM.Status = 'I';

                lstInActiveUsers.add(testUser[h].Id);
            }
            
            else {
                indDTM.Status = '';
            }


            // Add individual DTMs to array of DTMs
            dellTeamMembers.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Create the AccountTeamMember array for users that will be deleted
        for (Integer h=2; h <= 3; h++) {
        
            AccountTeamMember indATM = new AccountTeamMember();
            indATM.accountId = sAccount1.Id;
            indATM.userId = testUser[h].Id;
            indATM.TeamMemberRole = ROLE_IPSM;
			indATM.OpportunityAccessLevel = 'Edit';


            arrayATM.add(indATM);

        }

        insert arrayATM;



        // Display and create the DellTeamMember array
        system.debug('#### DellTeamMember array = ' + dellTeamMembers);


        // Test the setAccountAndSalesTeamsSub() function
        Test.startTest();
        TeamProcessing.setAccountAndSalesTeamsSub(dellTeamMembers);
        Test.stopTest();


        // Verify the results
        system.debug('#### Test Verification ');
        system.assertEquals(2, [select count() from AccountTeamMember where AccountId = :sAccount1.Id and UserId in :lstActiveUsers]);
        system.assertEquals(2, [select count() from AccountShare where AccountId = :sAccount1.Id and UserOrGroupId in :lstActiveUsers]);

        system.assertEquals(0, [select count() from AccountTeamMember where AccountId = :sAccount1.Id and UserId in :lstInActiveUsers]);
        system.assertEquals(0, [select count() from AccountShare where AccountId = :sAccount1.Id and UserOrGroupId in :lstInActiveUsers]);



    }   // End Test_TPsetAccountAndSalesTeamsSub()



    static testMethod void Test_TPsetAccountAndSalesTeams() {

        system.debug('#### In test method Test_TPsetAccountAndSalesTeams() now . . . ');

        // Declare variables
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();
        List<DellTeamMember> dellTeamMembers = new List<DellTeamMember>();
        List<ID> lstActiveUsers = new List<ID>();
        List<ID> lstInActiveUsers = new List<ID>();


        // Get Users 
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Create account
        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;


        // Create the DellTeamMember array
        for (Integer h=0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = new DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            indDTM.AccountAccessLevel = 'Edit';
            indDTM.OpportunityAccessLevel = 'Edit';
            indDTM.CaseAccessLevel = 'Edit';

            if (h == 0 || h == 1) {
                indDTM.Status = 'A';
                
                lstActiveUsers.add(testUser[h].Id);
            }

            else if (h == 2 || h == 3) {
                indDTM.Status = 'I';

                lstInActiveUsers.add(testUser[h].Id);
            }
            
            else {
                indDTM.Status = '';
            }


            // Add individual DTMs to array of DTMs
            dellTeamMembers.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Create the AccountTeamMember array for users that will be deleted
        for (Integer h=2; h <= 3; h++) {
        
            AccountTeamMember indATM = new AccountTeamMember();
            indATM.accountId = sAccount1.Id;
            indATM.userId = testUser[h].Id;
            indATM.TeamMemberRole = ROLE_IPSM;
			indATM.OpportunityAccessLevel = 'Edit';


            arrayATM.add(indATM);

        }

        insert arrayATM;



        // Display and create the DellTeamMember array
        system.debug('#### DellTeamMember array = ' + dellTeamMembers);


        // Test the setAccountAndSalesTeamsSub() function
        Test.startTest();
        TeamProcessing.setAccountAndSalesTeams(dellTeamMembers);
        Test.stopTest();


        // Verify the results
        system.debug('#### Test Verification ');
        system.assertEquals(2, [select count() from AccountTeamMember where AccountId = :sAccount1.Id and UserId in :lstActiveUsers]);
        system.assertEquals(2, [select count() from AccountShare where AccountId = :sAccount1.Id and UserOrGroupId in :lstActiveUsers]);

        system.assertEquals(0, [select count() from AccountTeamMember where AccountId = :sAccount1.Id and UserId in :lstInActiveUsers]);
        system.assertEquals(0, [select count() from AccountShare where AccountId = :sAccount1.Id and UserOrGroupId in :lstInActiveUsers]);


    }   // End Test_TPsetAccountAndSalesTeams()


    static testMethod void Test_updateSalesTeamsAndShares() {
        TriggerExecutionController.setSkipAllTriggers(true);

        system.debug('#### In test method Test_updateSalesTeamsAndShare() now . . . ');

        // Declare variables
        Set<Id> DTMUserIDs = new Set<Id>();
        Set<Id> DTMAcctIDs = new Set<Id>();
        List<DellTeamMember> DTMUpdateArray = new List<DellTeamMember>();
        Map<Id, User> mapActiveUsers = new Map<Id, User>();


        // Get Users 
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);
        

        // Put ID of users into an array of IDs
        for (Integer k=0; k<testUser.size(); k++) {

            // Create an array of user IDs
            DTMUserIDs.add(testUser[k].Id);
            
            // Create the map array
            mapActiveUsers.put(testUser[k].Id, testUser[k]);
        }
        

        // Create account
        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;


        // Create an array of account IDs
        DTMAcctIDs.add(sAccount1.Id);


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: To accommondate new VR = OpptyBookDateValidation
        Date dCloseDate = Date.TODAY();  // Fenny added [18-July-2014]: To accommondate new VR = OpptyBookDateValidation
        
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        insert sOpportunity1;


        // Create the DellTeamMember array
        for (Integer h=0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = new DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            indDTM.AccountAccessLevel = 'Edit';
            indDTM.OpportunityAccessLevel = 'Edit';
            indDTM.CaseAccessLevel = 'Edit';


            // Add individual DTMs to array of DTMs
            DTMUpdateArray.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display and create the DellTeamMember array
        system.debug('#### DellTeamMember array = ' + DTMUpdateArray);



        // Test the updateAccountTeamAndShare() function
        Test.startTest();
        AccountTeamUtil.updateSalesTeamsAndShares(DTMUpdateArray, DTMAcctIDs, DTMUserIDs, mapActiveUsers);
        Test.stopTest();


        // Verify the results
        system.debug('#### Test Verification ');
        system.assertEquals(5, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id and UserId in :DTMUserIDs]);
        system.assertEquals(5, [select count() from OpportunityShare where OpportunityId = :sOpportunity1.Id and UserOrGroupId in :DTMUserIDs]);


    }   // End Test_updateSalesTeamsAndShares()


    static testMethod void Test_STPsetAccountAndSalesTeamsSub() {
        TriggerExecutionController.setSkipAllTriggers(true);

        system.debug('#### In test method Test_STPsetAccountAndSalesTeamsSub() now . . . ');

        // Declare variables
        List<OpportunityTeamMember> arrayOTM = new List<OpportunityTeamMember>();
        List<DellTeamMember> dellTeamMembers = new List<DellTeamMember>();
        List<ID> lstActiveUsers = new List<ID>();
        List<ID> lstInActiveUsers = new List<ID>();
        List<String> strDellTeamMembers = new List<String>();


        // Get Users 
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Create account
        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        insert sOpportunity1;


        // Create the DellTeamMember array
        for (Integer h=0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = new DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            indDTM.AccountAccessLevel = 'Edit';
            indDTM.OpportunityAccessLevel = 'Edit';
            indDTM.CaseAccessLevel = 'Edit';

            if (h == 0 || h == 1) {
                indDTM.Status = 'A';
                
                lstActiveUsers.add(testUser[h].Id);
            }

            else if (h == 2 || h == 3) {
                indDTM.Status = 'I';

                lstInActiveUsers.add(testUser[h].Id);
            }
            
            else {
                indDTM.Status = '';
            }


            // Add individual DTMs to array of DTMs
            dellTeamMembers.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array = ' + dellTeamMembers);


        // Create the OpportunityTeamMember array for users that will be deleted
        for (Integer h=2; h <= 3; h++) {
        
            OpportunityTeamMember indOTM = new OpportunityTeamMember();
            indOTM.opportunityId = sOpportunity1.Id;
            indOTM.userId = testUser[h].Id;
            indOTM.TeamMemberRole = ROLE_IPSM;


            arrayOTM.add(indOTM);

        }

        insert arrayOTM;



        // Convert the DellTeamMember array into a string array for the @future function
        strDellTeamMembers = SalesTeamProcessing.conv_dellTeamMembersToStrings(dellTeamMembers);



        // Test the setAccountAndSalesTeamsSub() function
        Test.startTest();
        SalesTeamProcessing.setAccountAndSalesTeamsSub(strDellTeamMembers);
        Test.stopTest();


        // Verify the results
        system.debug('#### Test Verification ');
        system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id and UserId in :lstActiveUsers]);
        system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunity1.Id and UserOrGroupId in :lstActiveUsers]);

        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id and UserId in :lstInActiveUsers]);
        system.assertEquals(0, [select count() from OpportunityShare where OpportunityId = :sOpportunity1.Id and UserOrGroupId in :lstInActiveUsers]);


    }   // End Test_STPsetAccountAndSalesTeamsSub()


    static testMethod void Test_STPsetAccountAndSalesTeams() {
        TriggerExecutionController.setSkipAllTriggers(true);

        system.debug('#### In test method Test_STPsetAccountAndSalesTeams() now . . . ');

        // Declare variables
        List<OpportunityTeamMember> arrayOTM = new List<OpportunityTeamMember>();
        List<DellTeamMember> dellTeamMembers = new List<DellTeamMember>();
        List<ID> lstActiveUsers = new List<ID>();
        List<ID> lstInActiveUsers = new List<ID>();


        // Get Users 
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);


        // Create account
        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;


        // Create the opportunity
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation
        
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        insert sOpportunity1;


        // Create the DellTeamMember array
        for (Integer h=0; h < testUser.size(); h++) {
        
            DellTeamMember indDTM = new DellTeamMember();
            indDTM.accountId = sAccount1.Id;
            indDTM.userId = testUser[h].Id;
            indDTM.TeamMemberRole = ROLE_IPSM;          
            indDTM.AccountAccessLevel = 'Edit';
            indDTM.OpportunityAccessLevel = 'Edit';
            indDTM.CaseAccessLevel = 'Edit';

            if (h == 0 || h == 1) {
                indDTM.Status = 'A';
                
                lstActiveUsers.add(testUser[h].Id);
            }

            else if (h == 2 || h == 3) {
                indDTM.Status = 'I';

                lstInActiveUsers.add(testUser[h].Id);
            }
            
            else {
                indDTM.Status = '';
            }


            // Add individual DTMs to array of DTMs
            dellTeamMembers.add(indDTM);

        }   // End for (Integer h=0; h <= testUser.size(); h++)


        // Display the DellTeamMember array
        system.debug('#### DellTeamMember array = ' + dellTeamMembers);


        // Create the OpportunityTeamMember array for users that will be deleted
        for (Integer h=2; h <= 3; h++) {
        
            OpportunityTeamMember indOTM = new OpportunityTeamMember();
            indOTM.opportunityId = sOpportunity1.Id;
            indOTM.userId = testUser[h].Id;
            indOTM.TeamMemberRole = ROLE_IPSM;


            arrayOTM.add(indOTM);

        }

        insert arrayOTM;


        // Test the setAccountAndSalesTeamsSub() function
        Test.startTest();
        SalesTeamProcessing.setAccountAndSalesTeams(dellTeamMembers);
        Test.stopTest();


        // Verify the results
        system.debug('#### Test Verification ');
        system.assertEquals(2, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id and UserId in :lstActiveUsers]);
        system.assertEquals(2, [select count() from OpportunityShare where OpportunityId = :sOpportunity1.Id and UserOrGroupId in :lstActiveUsers]);

        system.assertEquals(0, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id and UserId in :lstInActiveUsers]);
        system.assertEquals(0, [select count() from OpportunityShare where OpportunityId = :sOpportunity1.Id and UserOrGroupId in :lstInActiveUsers]);


    }   // End Test_STPsetAccountAndSalesTeams()

}   // Global Class SalesTeamSyncTests_2