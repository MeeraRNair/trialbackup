/* 
Author: Raymond Yip

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     26-OCT-2010     Raymond Yip     Created for CR4435
*/
@isTest
private class BatchDeleteAccountTeamMemberTest {

    static testMethod void testBatchDeleteAccountTeamMember() {
        Account testAccount1 = new Account(Name='Test Account1',Type='OEM');
        Account testAccount2 = new Account(Name='Test Account2',Type='MSG');
        
        List<Account> testAccountList = new List<Account>();
        testAccountList.add(testAccount1);
        testAccountList.add(testAccount2);
        insert testAccountList;
        
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Mgr - Non SSO' LIMIT 1];
        
        System.assert(testProfile != null);
    
        User testUser1 = new User(FirstName='Test 1', LastName='BatchDeleteACT Test', Title='OEM_SR',UserName='TestU1'+ System.currentTimeMillis() +'@test.com',Email='TestU1@dell.com',Alias='test01',CommunityNickName='Test01',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest111');
        User testUser2 = new User(FirstName='Test 2', LastName='BatchDeleteACT Test', Title='OEM_SR',UserName='TestU2'+ System.currentTimeMillis() +'@test.com',Email='TestU2@dell.com',Alias='test02',CommunityNickName='Test02',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest222');
        User testUser3 = new User(FirstName='Test 3', LastName='BatchDeleteACT Test', Title='QQQ_SR',UserName='TestU3'+ System.currentTimeMillis() +'@test.com',Email='TestU3@dell.com',Alias='test03',CommunityNickName='Test03',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest333');
        User testUser4 = new User(FirstName='Test 4', LastName='BatchDeleteACT Test', Title='QQQ_SR',UserName='TestU4'+ System.currentTimeMillis() +'@test.com',Email='TestU4@dell.com',Alias='test04',CommunityNickName='Test04',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest444');
        User testUser5 = new User(FirstName='Test 5', LastName='BatchDeleteACT Test', Title='MSG_SR',UserName='TestU5'+ System.currentTimeMillis() +'@test.com',Email='TestU5@dell.com',Alias='test05',CommunityNickName='Test05',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest1115');
        User testUser6 = new User(FirstName='Test 6', LastName='BatchDeleteACT Test', Title='MSG_SR',UserName='TestU6'+ System.currentTimeMillis() +'@test.com',Email='TestU6@dell.com',Alias='test06',CommunityNickName='Test06',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest2226');
        User testUser7 = new User(FirstName='Test 7', LastName='BatchDeleteACT Test', Title='QQQ_SR',UserName='TestU7'+ System.currentTimeMillis() +'@test.com',Email='TestU7@dell.com',Alias='test07',CommunityNickName='Test07',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest3337');
        User testUser8 = new User(FirstName='Test 8', LastName='BatchDeleteACT Test', Title='QQQ_SR',UserName='TestU8'+ System.currentTimeMillis() +'@test.com',Email='TestU8@dell.com',Alias='test08',CommunityNickName='Test08',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest4448');
        
        List<User> testUserList = new List<User>();
        
        testUserList.add(testUser1);
        testUserList.add(testUser2);
        testUserList.add(testUser3);
        testUserList.add(testUser4);
        testUserList.add(testUser5);
        testUserList.add(testUser6);
        testUserList.add(testUser7);
        testUserList.add(testUser8);
                
        insert testUserList;
        
        AccountTeamMember testACT1 = new AccountTeamMember(UserId=testUser1.Id, TeamMemberRole='OEM SR', AccountId=TestAccount1.Id);
        AccountTeamMember testACT2 = new AccountTeamMember(UserId=testUser2.Id, TeamMemberRole='QQQ SR', AccountId=TestAccount1.Id);
        AccountTeamMember testACT3 = new AccountTeamMember(UserId=testUser3.Id, TeamMemberRole='OEM SR', AccountId=TestAccount1.Id);
        AccountTeamMember testACT4 = new AccountTeamMember(UserId=testUser4.Id, TeamMemberRole='QQQ SR', AccountId=TestAccount1.Id);
        AccountTeamMember testACT5 = new AccountTeamMember(UserId=testUser5.Id, TeamMemberRole='MSG SR', AccountId=TestAccount2.Id);
        AccountTeamMember testACT6 = new AccountTeamMember(UserId=testUser6.Id, TeamMemberRole='QQQ SR', AccountId=TestAccount2.Id);
        AccountTeamMember testACT7 = new AccountTeamMember(UserId=testUser7.Id, TeamMemberRole='MSG SR', AccountId=TestAccount2.Id);
        AccountTeamMember testACT8 = new AccountTeamMember(UserId=testUser8.Id, TeamMemberRole='QQQ SR', AccountId=TestAccount2.Id);
        
        List<AccountTeamMember> testACTList = new List<AccountTeamMember>();
        
        testACTList.add(testACT1);
        testACTList.add(testACT2);
        testACTList.add(testACT3);
        testACTList.add(testACT4);
        testACTList.add(testACT5);
        testACTList.add(testACT6);
        testACTList.add(testACT7);
        testACTList.add(testACT8);
        
        insert testACTList;
        
        System.debug([SELECT Id, TeamMemberRole, User.Title FROM AccountTeamMember WHERE User.LastName = 'BatchDeleteACT Test']);
        
        Integer beforeCount = [SELECT Count() FROM AccountTeamMember WHERE User.LastName = 'BatchDeleteACT Test'];
        
        System.assertEquals(8,beforeCount);
        
        Test.startTest();
        BatchDeleteAccountTeamMemberExecute.executeBatchForTest();
        Test.stopTest();
        
        Integer afterCount = [SELECT Count() FROM AccountTeamMember WHERE User.LastName = 'BatchDeleteACT Test'];
        System.assertEquals(4,afterCount );
    }
}