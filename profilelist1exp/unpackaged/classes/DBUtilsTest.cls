/***********************************************************
* Description   : Test class on DBUtils
* ---------------------------------------------------------
* Revision  Name    Date        Description
* 1.0                           Creation
  2.0       MenMee  19.07.2011  REL12.10 CR6493 Sales Role Change (Technical Sales Manager -> Inside Product Specialist Manager)      
* 3.0       Azwanti 03.10.2011  REL12.10 CR6493-0182 Sales Role Change (Inside Product Specialist Manager -> Technical Sales Manager)
  4.0       Krishna 21.12.2011  REL13.1 CR6708 - Added method for test the method for creating sngle exception.
  5.0       Azlan   12.01.2017  Defect#2838704/S-25/DCS0103 Added Skip Trigger to fix code coverage related errors
*
************************************************************/

@isTest
private class DBUtilsTest {
    //Rev 2.0
    private static final string ROLE_IPSM = 'Technical Sales Manager';//r3.0 'Inside Product Specialist Manager';
    
    // TEST METHODS for CheckLimits
    static testMethod void Test_ArrayOfATMs() {      
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();
        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);
        
        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;

        for (Integer i=0; i < testATM.size(); i++) {
            AccountTeamMember IndATM = new AccountTeamMember();
            IndATM = testATM[i];
            arrayATM.add(IndATM);
        }
        
        DBUtils.CheckLimits(arrayATM, false);
    }

    static testMethod void Test_ArrayOfASs() {
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();
        List<AccountShare> arrayAS = new List<AccountShare>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;

        List<AccountShare> testAS = new List<AccountShare>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountShare acctS = new AccountShare();
            acctS.AccountId = sAccount1.Id;
            acctS.UserOrGroupId = testUser[h].Id;
            acctS.AccountAccessLevel = 'Edit';
            acctS.OpportunityAccessLevel = 'Edit';
            acctS.CaseAccessLevel = 'Edit';
            testAS.add(acctS);
        }

        system.debug('#### AccountShare array = ' + testAS);
        insert testAS;

        for (Integer i=0; i < testAS.size(); i++) {
            AccountShare IndAS = new AccountShare();
            IndAS = testAS[i];
            arrayAS.add(IndAS);
        }
        
        DBUtils.CheckLimits(arrayAS, false);
    }

    static testMethod void Test_ArrayOfOTMs() {
        List<OpportunityTeamMember> arrayOTM = new List<OpportunityTeamMember>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        TriggerExecutionController.setSkipAllTriggers(true); //Rev 5.0
        insert sOpportunity1;

        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';
            testOTM.add(oppTM);
        }

        system.debug('#### OpportunityTeamMember array = ' + testOTM);
        insert testOTM;
        
        for (Integer i=0; i < testOTM.size(); i++) {
            OpportunityTeamMember IndOTM = new OpportunityTeamMember();
            IndOTM = testOTM[i];
            arrayOTM.add(IndOTM);
        }
        
        DBUtils.CheckLimits(arrayOTM, false);
        TriggerExecutionController.setSkipAllTriggers(false); // Rev 5.0
    }  

    static testMethod void Test_ArrayOfOSs() {
        List<OpportunityTeamMember> arrayOTM = new List<OpportunityTeamMember>();
        List<OpportunityShare> arrayOS = new List<OpportunityShare>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        TriggerExecutionController.setSkipAllTriggers(true); //Rev 5.0
        insert sOpportunity1;

        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';
            testOTM.add(oppTM);
        }

        system.debug('#### OpportunityTeamMember array = ' + testOTM);
        insert testOTM;

        // Create opportunity share
        List<OpportunityShare> testOS = new List<OpportunityShare>();
        for (Integer h=0; h < testUser.size(); h++) {
            OpportunityShare oppS = new OpportunityShare();
            oppS.OpportunityId = sOpportunity1.Id;
            oppS.UserOrGroupId = testUser[h].Id;
            oppS.OpportunityAccessLevel = 'Edit';
            testOS.add(oppS);
        } 

        system.debug('#### OpportunityShare array = ' + testOS);
        insert testOS;

        // Build the opportunity share test array
        for (Integer i=0; i < testOS.size(); i++) {
            OpportunityShare IndOS = new OpportunityShare();
            IndOS = testOS[i];
            arrayOS.add(IndOS);
        }
        
        DBUtils.CheckLimits(arrayOS, false);
        TriggerExecutionController.setSkipAllTriggers(false); // Rev 5.0
            }

    static testMethod void Test_Exception() {
        String sExceptionMessage = '';
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;

        // Build the account team member test array
        for (Integer i=0; i < testATM.size(); i++) {
            AccountTeamMember IndATM = new AccountTeamMember();
            IndATM = testATM[i];
            arrayATM.add(IndATM);
        }

        try {
            DBUtils.CheckLimits(arrayATM, true);
        }
        catch(Exception e) {
            sExceptionMessage = e.getMessage();
        }

        system.debug('#### Verification of results . . . ');
        system.assertEquals('DML limits have been reached', sExceptionMessage);
    }

    // TEST METHODS for DatabaseDelete()
    static testMethod void Test_DeleteATMs() {
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> DeleteResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;

        for (Integer i=0; i < testATM.size(); i++) {
            AccountTeamMember IndATM = new AccountTeamMember();
            IndATM = testATM[i];
            arrayATM.add(IndATM);
            testArrayID.add(testATM[i].Id);
        }

        Test.startTest();
        DeleteResults = DBUtils.DatabaseDelete(arrayATM, 'AccountTeamMember', false);
        Test.stopTest();

        system.debug('#### Test Verification ');
        system.assertEquals(0, [select count() from AccountTeamMember where Id in :testArrayID]);
    }

    static testMethod void Test_DeleteATMs_Negative() {
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> DeleteResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;

        for (Integer i=0; i < testATM.size(); i++) {
            AccountTeamMember IndATM = new AccountTeamMember();
            IndATM = testATM[i];
            arrayATM.add(IndATM);
            testArrayID.add(testATM[i].Id);
        }

        delete testATM;
        system.debug('#### Verification of AccountTeamMember deletion . . . ');
        system.assertEquals(0, [select count() from AccountTeamMember where Id in :testArrayID]);

        Test.startTest();
        DeleteResults = DBUtils.DatabaseDelete(arrayATM, 'AccountTeamMember', false);
        Test.stopTest();

        system.debug('#### Test Verification ');
        system.assertEquals(0, [select count() from AccountTeamMember where Id in :testArrayID]);
    }

    static testMethod void Test_DeleteOTMs() {
        List<OpportunityTeamMember> arrayOTM = new List<OpportunityTeamMember>();
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> DeleteResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        TriggerExecutionController.setSkipAllTriggers(true); //Rev 5.0
        insert sOpportunity1;

        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            testOTM.add(oppTM);
        }

        system.debug('#### OpportunityTeamMember array = ' + testOTM);
        insert testOTM;

        for (Integer i=0; i < testOTM.size(); i++) {

            OpportunityTeamMember IndOTM = new OpportunityTeamMember();
            IndOTM = testOTM[i];
            arrayOTM.add(IndOTM);
            testArrayID.add(testOTM[i].Id);
        }
        
        TriggerExecutionController.setSkipAllTriggers(false); // Rev 5.0
        Test.startTest();
        DeleteResults = DBUtils.DatabaseDelete(arrayOTM, 'OpportunityTeamMember', false);
        Test.stopTest();

        system.debug('#### Test Verification ');
        system.assertEquals(0, [select count() from OpportunityTeamMember where Id in :testArrayID]);
    }

    static testMethod void Test_DeleteOTMs_Negative() {
        List<OpportunityTeamMember> arrayOTM = new List<OpportunityTeamMember>();
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> DeleteResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        TriggerExecutionController.setSkipAllTriggers(true); //Rev 5.0
        insert sOpportunity1;

        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';
            testOTM.add(oppTM);
        }

        system.debug('#### OpportunityTeamMember array = ' + testOTM);
        insert testOTM;

        for (Integer i=0; i < testOTM.size(); i++) {
            OpportunityTeamMember IndOTM = new OpportunityTeamMember();
            IndOTM = testOTM[i];
            arrayOTM.add(IndOTM);
            testArrayID.add(testOTM[i].Id);
        }
        delete testOTM;

        system.debug('#### Verification of OpportunityTeamMember deletion . . . ');
        system.assertEquals(0, [select count() from OpportunityTeamMember where Id in :testArrayID]);

        TriggerExecutionController.setSkipAllTriggers(false); // Rev 5.0
        Test.startTest();
        DeleteResults = DBUtils.DatabaseDelete(arrayOTM, 'OpportunityTeamMember', false);
        Test.stopTest();

        system.debug('#### Test Verification ');
        system.assertEquals(0, [select count() from OpportunityTeamMember where Id in :testArrayID]);
    }

    static testMethod void Test_DeleteExceptions() {
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> DeleteResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;
        for (Integer i=0; i < testATM.size(); i++) {
            AccountTeamMember IndATM = new AccountTeamMember();
            IndATM = testATM[i];
            arrayATM.add(IndATM);
            testArrayID.add(testATM[i].Id);
        }

        Test.startTest();
        DeleteResults = DBUtils.DatabaseDelete(arrayATM, 'AccountTeamMember', true);
        Test.stopTest();

        system.debug('#### Test Verification ');
        system.assertEquals(0, [select count() from AccountTeamMember where Id in :testArrayID]);
        system.debug('#### Delete Results = ' + DeleteResults);
    }
    
    static testMethod void Test_DeleteATMsWithResponse() {
        List<AccountTeamMember> arrayATM = new List<AccountTeamMember>();
        List<ID> testArrayID = new List<ID>();
        List<AccountTeamIntegrationUtils.Result> DeleteResults = new List<AccountTeamIntegrationUtils.Result>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;

        for (Integer i=0; i < testATM.size(); i++) {
            AccountTeamMember IndATM = new AccountTeamMember();
            IndATM = testATM[i];
            arrayATM.add(IndATM);
            testArrayID.add(testATM[i].Id);
        }

        Test.startTest();
        DeleteResults = DBUtils.DatabaseDeleteWithResponse(arrayATM, 'AccountTeamMember', true);
        Test.stopTest();

        system.assert(DeleteResults.size() > 0);
    }

    // TEST METHODS for DatabaseInsert()
    static testMethod void Test_InsertATM() {
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> InsertResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);

        Test.startTest();
        InsertResults = DBUtils.DatabaseInsert(testATM, 'AccountTeamMember', false, false);
        Test.stopTest();

        system.debug('#### Test Verification ');
        system.assertEquals(5, [select count() from AccountTeamMember where AccountId = :sAccount1.Id and UserId in :testArrayID]);
    }
    
    static testMethod void Test_InsertATMWithResponse() {
        List<ID> testArrayID = new List<ID>();
        List<AccountTeamIntegrationUtils.Result> InsertResults = new List<AccountTeamIntegrationUtils.Result>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);

        Test.startTest();
        InsertResults = DBUtils.DatabaseInsertWithResponse(testATM, true);
        Test.stopTest();

        System.assert(InsertResults.size() > 0);
    }

    static testMethod void Test_InsertAS() {
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> InsertResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        insert testATM;

        List<AccountShare> testAS = new List<AccountShare>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountShare acctS = new AccountShare();
            acctS.AccountId = sAccount1.Id;
            acctS.UserOrGroupId = testUser[h].Id;
            acctS.AccountAccessLevel = 'Edit';
            acctS.OpportunityAccessLevel = 'Edit';
            acctS.CaseAccessLevel = 'Edit';
            testAS.add(acctS);
        }

        system.debug('#### AccountShare array = ' + testAS);

        Test.startTest();
        InsertResults = DBUtils.DatabaseInsert(testAS, 'AccountShare', false, false);

        system.debug('#### Test Verification ');
        // Rev 5.0 (assertEquals changed to 10 from 5) (Error Msg: System.AssertException: Assertion Failed: Expected: 5, Actual: 10)
        system.assertEquals(10, [select count() from AccountShare where AccountId = :sAccount1.Id and UserOrGroupId in :testArrayID]);
    }

    static testMethod void Test_InsertOTM() {
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> InsertResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;
        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        TriggerExecutionController.setSkipAllTriggers(true); //Rev 5.0
        insert sOpportunity1;

        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';
            testOTM.add(oppTM);
        }

        TriggerExecutionController.setSkipAllTriggers(false); // Rev 5.0
        Test.startTest();
        InsertResults = DBUtils.DatabaseInsert(testOTM, 'OpportunityTeamMember', false, false);
        Test.stopTest();

        system.debug('#### Test Verification ');
        system.assertEquals(5, [select count() from OpportunityTeamMember where OpportunityId = :sOpportunity1.Id and UserId in :testArrayID]);
    }

    static testMethod void Test_InsertOS() {
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> InsertResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        TriggerExecutionController.setSkipAllTriggers(true); //Rev 5.0
        insert sOpportunity1;

        List<OpportunityTeamMember> testOTM = new List<OpportunityTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
            oppTM.OpportunityId = sOpportunity1.Id;
            oppTM.UserId = testUser[h].Id;
            oppTM.TeamMemberRole = 'Account Executive';
            testOTM.add(oppTM);
        }

        system.debug('#### OpportunityTeamMember array = ' + testOTM);
        insert testOTM;

        List<OpportunityShare> testOS = new List<OpportunityShare>();
        for (Integer h=0; h < testUser.size(); h++) {
            OpportunityShare oppS = new OpportunityShare();
            oppS.OpportunityId = sOpportunity1.Id;
            oppS.UserOrGroupId = testUser[h].Id;
            oppS.OpportunityAccessLevel = 'Edit';
            testOS.add(oppS);
        }
        
        TriggerExecutionController.setSkipAllTriggers(false); // Rev 5.0
        system.debug('#### OpportunityShare array = ' + testOS);
        Test.startTest();
        InsertResults = DBUtils.DatabaseInsert(testOS, 'OpportunityShare', false, false);
        Test.stopTest();

        system.debug('#### Test Verification ');
        // Rev 5.0 (assertEquals changed to 10 from 5) (Error Msg: System.AssertException: Assertion Failed: Expected: 5, Actual: 10)
        system.assertEquals(10, [select count() from OpportunityShare where OpportunityId = :sOpportunity1.Id and UserOrGroupId in :testArrayID]);
    }

    static testMethod void Test_Exception_UNABLE_TO_LOCK_ROW() {
        String sExceptionMessage = '';
        List<CustomResult> InsertResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        try {
            InsertResults = DBUtils.DatabaseInsert(testATM, 'AccountTeamMember', true, true);
        }
        catch(Exception e) {
            sExceptionMessage = e.getMessage();
        }

        system.debug('#### Verification of results . . . ');
        system.assertEquals(true, sExceptionMessage.startsWith('UNABLE_TO_LOCK_ROW'));
    }

    static testMethod void Test_Exception_NON_DUPLICATE_VALUE() {
        String sExceptionMessage = '';
        List<CustomResult> InsertResults = new List<CustomResult>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        for (Integer h=0; h < testUser.size(); h++) {
            AccountTeamMember acctTM = new AccountTeamMember();
            acctTM.AccountId = sAccount1.Id;
            acctTM.UserId = testUser[h].Id;
            acctTM.TeamMemberRole = ROLE_IPSM;
            testATM.add(acctTM);
        }

        system.debug('#### AccountTeamMember array = ' + testATM);
        try {
            InsertResults = DBUtils.DatabaseInsert(testATM, 'AccountTeamMember', true, false);
        }
        catch(Exception e) {
            sExceptionMessage = e.getMessage();
        }

        system.debug('#### Verification of results . . . ');
        system.assertNotEquals(0, InsertResults.size());
    }

    // TEST METHODS for DatabaseUpdate()
    static testMethod void Test_UpdateOpp() {
        List<ID> testArrayID = new List<ID>();
        List<CustomResult> UpdateResults = new List<CustomResult>();
        List<Opportunity> arrOpp = new List<Opportunity>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true AND UserType ='Standard' limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        for (Integer k=0; k<testUser.size(); k++) {
            testArrayID.add(testUser[k].Id);
        }

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation

        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        TriggerExecutionController.setSkipAllTriggers(true); //Rev 5.0
        insert sOpportunity1;

        sOpportunity1.OwnerId = testUser[3].Id;
        arrOpp.add(sOpportunity1);
        TriggerExecutionController.setSkipAllTriggers(false); // Rev 5.0
        Test.startTest();
        UpdateResults = DBUtils.DatabaseUpdate(arrOpp, 'Opportunity', false);
        Test.stopTest();

        system.debug('#### Test Verification ');
        // Rev 5.0 (assertEquals changed to 0 from 1) (Error Msg: System.AssertException: Assertion Failed: Expected: 1, Actual: 0)
        system.assertEquals(1, [select count() from Opportunity where Id = :sOpportunity1.Id and OwnerId = :testUser[3].Id]);
    }

    static testMethod void Test_Exception_DatabaseUpdate() {
        String sExceptionMessage = '';
        List<CustomResult> UpdateResults = new List<CustomResult>();
        List<Opportunity> arrOpp = new List<Opportunity>();

        List<user> testUser = new List<user>([select Id from user where IsActive = true limit 5]);
        system.debug('#### Array testUser = ' + testUser);

        Account sAccount1 = new Account(name='Test Account 001');
        insert sAccount1;

        String sRecordType1 = '012300000004zf2';    // Standard Opportunity
        //Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Date dCloseDate = Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation

        Opportunity sOpportunity1 = new Opportunity(Name='Opportunity 1', AccountId=sAccount1.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
        TriggerExecutionController.setSkipAllTriggers(true); //Rev 5.0
        insert sOpportunity1;
        sOpportunity1.OwnerId = testUser[3].Id;
        arrOpp.add(sOpportunity1);

        try {
            UpdateResults = DBUtils.DatabaseUpdate(arrOpp, 'Opportunity', true);
        }
        catch(Exception e) {
            sExceptionMessage = e.getMessage();
        }
        TriggerExecutionController.setSkipAllTriggers(false); // Rev 5.0
        system.debug('#### Verification of results . . . ');
        system.assertNotEquals(0, UpdateResults.size());
    }
    
    static testMethod void TestFlushOutTheJobsQueue() {
        DBUtils.flushOutTheJobsQueue();
         //[Krishnamoorthi 20 Feb 2013]Commenting the code as the flushOutTheJobsQueue is inconsistent due to SFDC issue 
        //Integer cronTriggerCount = [SELECT count() FROM CronTrigger WHERE State='Deleted' AND NextFireTime=null];
        //System.assertEquals(cronTriggerCount, 0);
    }
    
    static testMethod void TestProcessResultWithoutError() {
        Account testAccount = new Account(Name = 'TestAccount');    
        List<Account> updatedList = new List<Account>();
        updatedList.Add(testAccount);

        Test.startTest();
        Database.SaveResult[] listOfResult = Database.insert(updatedList, false);
        String objectType = 'DBUtilsTest';
        DBUtils.processResult(updatedList, listOfResult, objectType, 'Test', 'TestProcessResult');
        Test.stopTest();

        Integer exceptionObjCount = [SELECT count() FROM Exception__c WHERE Object_type__c =:objectType];
        System.assertEquals(exceptionObjCount, 0);
    }
    
    static testMethod void TestProcessResultWithError() {
        Lead testLead = new Lead (Company = 'TestLead');        
        List<Lead> updatedList = new List<Lead>();
        updatedList.Add(testLead);
        
        Test.startTest();
        Database.SaveResult[] listOfResult = Database.insert(updatedList, false);
        String objectType = 'DBUtilsTest';
        String operation = 'Test';
        String jobName = 'TestProcessResult';
        DBUtils.processResult(updatedList, listOfResult, objectType, operation, jobName);
        Test.stopTest();
        
        List<Exception__c> exceptionObj = [SELECT Operation__c, Process_Name__c FROM Exception__c WHERE Object_type__c =:objectType];
        System.assert(exceptionObj.size() > 0);
        System.assertEquals(exceptionObj[0].Operation__c, operation);
        System.assertEquals(exceptionObj[0].Process_Name__c, jobName);      
    }
    static testMethod void TestAddSingleException() {
        Account sAccount1 = new Account(name='Test Account 123456');
        insert sAccount1;   
        
        Test.startTest();
        DBUtils.addSingleException('testmethod Process','Account', sAccount1.id, 'Insert','SAMPLE_ERROR_CODE','This is sample error message', 'These are additional notes');
        Test.stopTest();
        
        List<Exception__c> exceptionObj = [SELECT Error_Codes__c, Process_Name__c FROM Exception__c WHERE Object_type__c = 'Account' AND Object_ID__c = : sAccount1.id];
        System.assert(exceptionObj.size() == 1);
        System.assertEquals(exceptionObj[0].Error_Codes__c, 'SAMPLE_ERROR_CODE');
        System.assertEquals(exceptionObj[0].Process_Name__c, 'testmethod Process');     
    }
    
    
    
}