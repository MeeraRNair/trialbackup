@isTest
private class dellUtilTest {
    
    private static Map<String, String> sParams;
    
    // Test Condition: LimitSafeDMLOperations.forceDMLException = true 
    static testMethod void updateAccountShares_TestForceDMLException() {
        System.debug('##### Start updateAccountShares_TestForceDMLException #####');
        
        AccountShare emptyAccountShare = new AccountShare();
        List<AccountShare> emptyAccountShares = new List<AccountShare>();
        emptyAccountShares.add(emptyAccountShare);
        
        Boolean exceptionThrown = false;
        
        LimitSafeDMLOperations.forceDMLException = true;
        Test.startTest();
        try {
            dellUtil.updateAccountShares(emptyAccountShares);
        } catch(Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        LimitSafeDMLOperations.forceDMLException = false;
        System.assertEquals(true,exceptionThrown);
        
        System.debug('##### End updateAccountShares_TestForceDMLException #####');
    }
    
    // Test Condition: LimitSafeDMLOperations.forceTest = true
    static testMethod void updateAccountShares_TestForceTest() {        
        System.debug('##### Start updateAccountShares_TestForceTest #####');
        
        AccountShare emptyAccountShare = new AccountShare();
        List<AccountShare> emptyAccountShares = new List<AccountShare>();
        emptyAccountShares.add(emptyAccountShare);
        
        Boolean exceptionThrown = false;
        
        LimitSafeDMLOperations.forceTest = true;
        Test.startTest();
        try {
            dellUtil.updateAccountShares(emptyAccountShares);
        } catch(Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        LimitSafeDMLOperations.forceTest = false;
        System.assertEquals(true,exceptionThrown);
        
        System.debug('##### Start updateAccountShares_TestForceTest #####');
    }
    
    // Test Condtion
    // 1 Acc, 1 User, update AccessLevel=Edit
    static testMethod void updateAccountShares_UpdateAccessLevelEdit() {
        System.debug('##### Start updateAccountShares_UpdateAccessLevelEdit #####');
        
        Boolean exceptionThrown = false;
        
        //Create test data      
        AccountShare testAccShare = (AccountShare) TestDataGenerator.getObject(new AccountShare(), 1)[0];
        List<AccountShare> testAccShareList = new List<AccountShare>();
        testAccShareList.add(testAccShare);
            
        Test.startTest();
        try {
            dellUtil.updateAccountShares(testAccShareList);
        } catch(Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assertEquals(false, exceptionThrown);
        List<AccountShare> acctShareResults = new List<AccountShare>([SELECT AccountAccessLevel FROM AccountShare WHERE AccountId = :testAccShare.AccountId AND UserOrGroupId = :testAccShare.UserOrGroupId]);
        System.assertEquals(1, acctShareResults.size());
        System.assertEquals('Edit',acctShareResults[0].AccountAccessLevel); 
        
        System.debug('##### End updateAccountShares_UpdateAccessLevelEdit #####');          
    }
        
    // Test Condition:
    // 1 Acc, 1 User, dellUtil.forceTest=True
    static testMethod void updateAccountShares_TestDellUtilForceTest() {
        System.debug('##### Start updateAccountShares_TestDellUtilForceTest #####');
        
        Boolean exceptionThrown = false;
        
        //Create test data      
        AccountShare testAccShare = (AccountShare) TestDataGenerator.getObject(new AccountShare(), 1)[0];
        List<AccountShare> testAccShareList = new List<AccountShare>();
        testAccShareList.add(testAccShare);
        
        dellUtil.forceTest = true;
        Test.startTest();
        try {           
            dellUtil.updateAccountShares(testAccShareList);         
        } catch(Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        dellUtil.forceTest = false;
        
        System.assertEquals(false, exceptionThrown);
        List<AccountShare> acctShareResults = new List<AccountShare>([SELECT AccountAccessLevel FROM AccountShare WHERE AccountId = :testAccShare.AccountId AND UserOrGroupId = :testAccShare.UserOrGroupId]);
        System.assertEquals(1, acctShareResults.size());
        System.assertEquals('Edit',acctShareResults[0].AccountAccessLevel);
        
        System.debug('##### End updateAccountShares_TestDellUtilForceTest #####');
    }
    
    // Test Condition:
    // Test case to test only [setAccountShare], not any triggers...
    static testMethod void setAccountShare_NoAccountTrigger() {
        System.debug('##### Start setAccountShare_NoAccountTrigger #####');
        
        // Test data creation
        sParams = new Map<String, String>(); 
        User testUser = (User) TestDataGenerator.getObject(new User(), 1)[0];

        sParams.put('str_OwnerId', testUser.Id);
        sParams.put('str_Name', 'Test Case SAS - Dell Util');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();
        
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_TeamMemberRole', 'Test');
        AccountTeamMember testAccTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10, sParams)[0];
        sParams.clear(); 
        
        System.assertEquals(1, [SELECT count() FROM Account WHERE name LIKE 'Test Case SAS%']);
        System.assertEquals(10, [SELECT count() FROM AccountShare WHERE account.name LIKE 'Test Case SAS%' AND rowcause = 'Team']);
        
        // Test the method
        List<Account> accList = new List<Account>();        
        testAcc.ownerid = testAccTM.UserId;
        accList.add(testAcc);    
        
        //Start the test, this changes governor limit context to that of trigger rather than test       
        Test.startTest();    
        
        dellUtil.forceTest = true;
        dellUtil.setAccountShare(accList);    
        dellUtil.forceTest = false;
        
        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();    


        //Raymond 20090506: Initially, this query selects account LIKE 'Test Case 1%', which returns nothing 
        //Raymond 20090506: Added condition  AND UserOrGroupId <> :testAccTM.UserId. Without this, share of owner will be retrieved, with Edit access level
        for (AccountShare accShare : [SELECT id, opportunityaccesslevel FROM AccountShare WHERE account.name LIKE 'Test Case SAS%' AND rowcause='Team' AND UserOrGroupId != :testAccTM.UserId]){        
            
            System.assertEquals('None', accShare.opportunityaccesslevel);           
            
            //System.assertEquals(lastMod.get(accShare.Id).lastmodifieddate, accShare.lastmodifieddate);
        }   
        
        System.debug('##### End setAccountShare_NoAccountTrigger #####');
    }
        
    // Test Condition:
    // Fire Accout Trigger, DMU__c=false, Account_Type_Integration__c=SubAccount
    static testMethod void setAccountShare_AccountTrigger_DMUFalse_AccTypeIntegrationSubAccount() { 
        System.debug('##### Start setAccountShare_AccountTrigger_DMUFalse_AccTypeIntegrationSubAccount #####');
    
        // Create test data
        sParams = new Map<String, String>();
        User testUser = (User) TestDataGenerator.getObject(new User(), 1)[0];
        
        sParams.put('str_name', 'Test Case 1 - Dell Util');
        sParams.put('str_OwnerId', testUser.Id);
        sParams.put('bln_DMU__c', 'false');
        sParams.put('str_Account_Type_Integration__c', 'sub account');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();
        
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_TeamMemberRole', 'Test');
        AccountTeamMember testAccTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10, sParams)[1];
        
        System.assertEquals(1, [SELECT count() FROM account WHERE name LIKE 'Test case 1%']);
        System.assertEquals(10, [SELECT count() FROM accountshare WHERE account.name LIKE 'Test case 1%' AND rowcause = 'Team']);
        
        //Map<Id, AccountShare> lastMod = new Map<Id, AccountShare>([select id, lastmodifieddate from AccountShare where account.name LIKE 'Test case 1%' and rowcause='Team']);
        
        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();
        
        // Test the trigger by changing the owner
        testAcc.ownerId = testAccTM.UserId;
        update testAcc;
        
        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
        
        for (AccountShare accShare : [SELECT id, opportunityaccesslevel FROM AccountShare WHERE account.name LIKE 'Test case 1%' AND rowcause='Team']){         
            System.assertEquals('None', accShare.opportunityaccesslevel);
        }
        
        System.debug('##### End setAccountShare_AccountTrigger_DMUFalse_AccTypeIntegrationSubAccount #####');
    }
        
    // Test Condition   
    // Fire Accout Trigger, Status = 'I' 
    static testMethod void setAccountShare_AccountTrigger_StatusI() {
        System.debug('##### Start setAccountShare_AccountTrigger_StatusI #####');
        
        //Create test data
        sParams = new Map<String, String>();
        User testUser = (User) TestDataGenerator.getObject(new User(), 1)[0];
        
        sParams.put('str_name', 'Test Case 2 - Dell Util');
        sParams.put('str_OwnerId', testUser.Id);
        sParams.put('str_Status__c', 'I');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();
        
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_TeamMemberRole', 'Test');
        AccountTeamMember testAccTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10, sParams)[1];
        
        System.assertEquals(1, [SELECT count() FROM account WHERE name LIKE 'Test case 2%']);
        
        // ##CCWS Added Assert
        // Removed as busines rule in Inacive account 
        // System.assertEquals(10, [select count() from accountshare where account.name LIKE 'Test case 2%' and rowcause = 'Team']);
        
        //Map<Id, AccountShare> lastMod = new Map<Id, AccountShare>([select id, lastmodifieddate from AccountShare where account.name LIKE 'Test case 2%' and rowcause='Team']);
        
        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();
        
        // Test the trigger by changing the owner
        testAcc.ownerId = testAccTM.UserId;
        update testAcc;
                        
        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
        
        for (AccountShare accShare : [SELECT id, opportunityaccesslevel FROM AccountShare WHERE account.name LIKE 'Test case 2%' AND rowcause='Team']){
            System.assertEquals('None', accShare.opportunityaccesslevel);
            //System.assertEquals(lastMod.get(accShare.Id).lastmodifieddate, accShare.lastmodifieddate);
        }
                
        System.debug('##### End setAccountShare_AccountTrigger_StatusI #####');
    } 
    
    // Test Condition
    // Fire Accout Trigger, Ownership unchanged
    static testMethod void setAccountShare_AccountTrigger_OwnerUnchanged() {
        System.debug('##### Start setAccountShare_AccountTrigger_OwnerUnchanged #####');
        
        //Create test data
        sParams = new Map<String, String>();
        User testUser = (User) TestDataGenerator.getObject(new User(), 1)[0];
        
        sParams.put('str_name', 'Test Case 3 - Dell Util');
        sParams.put('str_OwnerId', testUser.Id);
        sParams.put('str_Status__c', 'I');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();
        
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_TeamMemberRole', 'Test');
        AccountTeamMember testAccTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10, sParams)[1];
        
        System.assertEquals(1, [SELECT count() FROM account WHERE name LIKE 'Test case 3%']);
        System.assertEquals(10, [SELECT count() FROM accountshare WHERE account.name LIKE 'Test case 3%' AND rowcause = 'Team']);
        
        //Map<Id, AccountShare> lastMod = new Map<Id, AccountShare>([select id, lastmodifieddate from AccountShare where account.name LIKE 'Test case 3%' and rowcause='Team']);
        
        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();
        
        // Test the trigger by changing the owner
        testAcc.ownerId = testUser.Id;
        update testAcc;
        
        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
        
        for (AccountShare accShare : [SELECT id, opportunityaccesslevel FROM AccountShare WHERE account.name LIKE 'Test case 3%' AND rowcause='Team']){
            System.assertEquals('None', accShare.opportunityaccesslevel);
            //System.assertEquals(lastMod.get(accShare.Id).lastmodifieddate, accShare.lastmodifieddate);
        }
        
        System.debug('##### eND setAccountShare_AccountTrigger_OwnerUnchanged #####');  
    } 
        
    // Test Condition
    // Fire Account Trigger, No account team member
    static testMethod void setAccountShare_AccountTrigger_NoAccTM() {
    
        System.debug('##### Start setAccountShare_AccountTrigger_NoAccTM #####');
        
        //Create test data
        sParams = new Map<String, String>();
        List<SObject> testUserList = TestDataGenerator.getObject(new User(), 2);
        
        sParams.put('str_name', 'Test Case 4 - Dell Util');
        sParams.put('str_OwnerId', string.valueOf(testUserList[0].get('Id')));
        sParams.put('str_Status__c', 'I');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();
        
        System.assertEquals(1, [SELECT count() FROM account WHERE name LIKE 'Test case 4%']);       
        System.assertEquals(0, [SELECT count() FROM accountshare WHERE account.name LIKE 'Test case 4%' AND rowcause = 'Team']);
        
        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();
        
        // Test the trigger by changing the owner
        testAcc.ownerId = string.valueOf(testUserList[1].get('Id'));
        update testAcc;
        
        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
        
        //TODO: assert
        
        System.debug('##### End setAccountShare_AccountTrigger_NoAccTM #####');
    } 
    
    // Test Condition:
    // Fire Account Trigger
    static testMethod void setAccountShare_AccountTrigger() {
    
        System.debug('##### Start setAccountShare_AccountTrigger #####');
        
        //Create test data
        sParams = new Map<String, String>();
        User testUser = (User) TestDataGenerator.getObject(new User(), 1)[0];
        
        sParams.put('str_name', 'Test Case 5 - Dell Util');
        sParams.put('str_OwnerId', testUser.Id);
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();
        
        sParams.put('str_AccountId', testAcc.Id);       
        sParams.put('str_TeamMemberRole', 'Test');
        AccountTeamMember testAccTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10, sParams)[1];
        
        System.assertEquals(1, [SELECT count() FROM account WHERE name LIKE 'Test case 5%']);
        System.assertEquals(10, [SELECT count() FROM accountshare WHERE account.name LIKE 'Test case 5%' AND rowcause = 'Team']);
        
        Map<Id, AccountShare> lastMod = new Map<Id, AccountShare>();
        
        for(AccountShare accShare : [SELECT userorgroupid, lastmodifieddate FROM AccountShare WHERE account.name LIKE 'Test case 5%' AND rowcause='Team']) {
            lastMod.put(accShare.userorgroupid, accShare);
        }
        
        //Start the test, this changes governor limit context to that of trigger rather than test
        Test.startTest();
        
        // Test the trigger by changing the owner
        testAcc.ownerId = testAccTM.UserId;     
        update testAcc;     
        
        //stop the test, this changes limit context back to test from trigger.
        Test.stopTest();
                
        Integer i = 0;
        for (AccountShare accShare : [SELECT userorgroupid, opportunityaccesslevel, lastmodifieddate FROM AccountShare WHERE account.name LIKE 'Test case 5%' AND rowcause='Team' AND userorgroupid =:testAccTM.UserId]){
            i++;
            system.debug('##CP: test 5 '+ i);
            //System.assertNotEquals(lastMod.get(accShare.userorgroupid).lastmodifieddate, accShare.lastmodifieddate);
			//1.1 Modified from Edit to None
            System.assertEquals('None' + i, accShare.opportunityaccesslevel + i);
        }
        
        System.debug('##### End setAccountShare_AccountTrigger #####');     
    } 
    
    // Test Condition
    // sendSupportEmail
    static testMethod void sendSupportEmail_SingleRecipientTextMail() {         
        System.debug('##### Start sendSupportEmail_SingleRecipientTextMail #####'); 
            
        boolean isExceptionThrow = false;
        try {       
            dellUtil.sendSupportEmail('Test method', 'alou@salesforce.com');
        }
        catch (Exception e) {
            isExceptionThrow = true;
        }
        System.assertEquals(false, isExceptionThrow);
        System.debug('##### End sendSupportEmail_SingleRecipientTextMail #####');   
    }
}