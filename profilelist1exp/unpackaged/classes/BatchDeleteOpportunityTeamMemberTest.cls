/* 
Author: Raymond Yip
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     26-OCT-2010     Raymond Yip     Created for CR4435
*/
@isTest
private class BatchDeleteOpportunityTeamMemberTest {
    static list<Account> listAcc;
    static testMethod void testBatchDeleteAccountTeamMember() {
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Partner Account');
        listAccTDF[0].Type='OEM';
        listAccTDF[0].Type='MSG';
        insert listAccTDF;
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(2, 'Deal Registration');
        listOppTDF[0].StageName='90% - Commit';
        listOppTDF[0].CloseDate=System.Today()+20;
        listOppTDF[1].StageName='90% - Commit';
        listOppTDF[1].CloseDate=System.Today()+20;
        insert listOppTDF;
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE id = '00eA0000000Rv5NIAS' LIMIT 1];
        System.assert(testProfile != null);
        User testUser1 = new User(FirstName='Test 1', LastName='BatchDeleteACT Test', Title='OEM_SR',UserName='TestU1'+ System.currentTimeMillis() +'@test.com',Email='TestU1@dell.com',Alias='test01',CommunityNickName='Test01',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest111');
        User testUser2 = new User(FirstName='Test 2', LastName='BatchDeleteACT Test', Title='OEM_SR',UserName='TestU2'+ System.currentTimeMillis() +'@test.com',Email='TestU2@dell.com',Alias='test02',CommunityNickName='Test02',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest222');
        User testUser3 = new User(FirstName='Test 3', LastName='BatchDeleteACT Test', Title='QQQ_SR',UserName='TestU3'+ System.currentTimeMillis() +'@test.com',Email='TestU3@dell.com',Alias='test03',CommunityNickName='Test03',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest333');
        User testUser4 = new User(FirstName='Test 4', LastName='BatchDeleteACT Test', Title='QQQ_SR',UserName='TestU4'+ System.currentTimeMillis() +'@test.com',Email='TestU4@dell.com',Alias='test04',CommunityNickName='Test04',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest444');
        User testUser5 = new User(FirstName='Test 5', LastName='BatchDeleteACT Test', Title='MSG_SR',UserName='TestU5'+ System.currentTimeMillis() +'@test.com',Email='TestU5@dell.com',Alias='test05',CommunityNickName='Test05',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest1115');
        User testUser6 = new User(FirstName='Test 6', LastName='BatchDeleteACT Test', Title='MSG_SR',UserName='TestU6'+ System.currentTimeMillis() +'@test.com',Email='TestU6@dell.com',Alias='test06',CommunityNickName='Test06',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest2226');
        User testUser7 = new User(FirstName='Test 7', LastName='BatchDeleteACT Test', Title='QQQ_SR',UserName='TestU7'+ System.currentTimeMillis() +'@test.com',Email='TestU7@dell.com',Alias='test07',CommunityNickName='Test07',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest3337');
        User testUser8 = new User(FirstName='Test 8', LastName='BatchDeleteACT Test', Title='QQQ_SR',UserName='TestU8'+ System.currentTimeMillis() +'@test.com',Email='TestU8@dell.com',Alias='test08',CommunityNickName='Test08',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest4448');
        List<User> listtestUser = new List<User>();
        listtestUser.add(testUser1);
        listtestUser.add(testUser2);
        listtestUser.add(testUser3);
        listtestUser.add(testUser4);
        listtestUser.add(testUser5);
        listtestUser.add(testUser6);
        listtestUser.add(testUser7);
        listtestUser.add(testUser8);
        insert listtestUser;
        OpportunityTeamMember testACT1 = new OpportunityTeamMember (UserId=testUser1.Id, TeamMemberRole='OEM SR', OpportunityId=listOppTDF[0].Id);
        OpportunityTeamMember testACT2 = new OpportunityTeamMember (UserId=testUser2.Id, TeamMemberRole='QQQ SR', OpportunityId=listOppTDF[0].Id);
        OpportunityTeamMember testACT3 = new OpportunityTeamMember (UserId=testUser3.Id, TeamMemberRole='OEM SR', OpportunityId=listOppTDF[0].Id);
        OpportunityTeamMember testACT4 = new OpportunityTeamMember (UserId=testUser4.Id, TeamMemberRole='QQQ SR', OpportunityId=listOppTDF[0].Id);
        OpportunityTeamMember testACT5 = new OpportunityTeamMember (UserId=testUser5.Id, TeamMemberRole='MSG SR', OpportunityId=listOppTDF[1].Id);
        OpportunityTeamMember testACT6 = new OpportunityTeamMember (UserId=testUser6.Id, TeamMemberRole='QQQ SR', OpportunityId=listOppTDF[1].Id);
        OpportunityTeamMember testACT7 = new OpportunityTeamMember (UserId=testUser7.Id, TeamMemberRole='MSG SR', OpportunityId=listOppTDF[1].Id);
        OpportunityTeamMember testACT8 = new OpportunityTeamMember (UserId=testUser8.Id, TeamMemberRole='QQQ SR', OpportunityId=listOppTDF[1].Id);
        List<OpportunityTeamMember > listtestACT = new List<OpportunityTeamMember >();
        listtestACT.add(testACT1);
        listtestACT.add(testACT2);
        listtestACT.add(testACT3);
        listtestACT.add(testACT4);
        listtestACT.add(testACT5);
        listtestACT.add(testACT6);
        listtestACT.add(testACT7);
        listtestACT.add(testACT8);
        insert listtestACT;
        System.debug([SELECT Id, TeamMemberRole, User.Title FROM OpportunityTeamMember WHERE User.LastName = 'BatchDeleteACT Test ']);
        Integer intbeforeCount = [SELECT Count() FROM OpportunityTeamMember WHERE User.LastName = 'BatchDeleteACT Test'];
        System.assertEquals(8,intbeforeCount);
        //Test.startTest();
        BatchDeleteOpportunityTeamMemberExecute.executeBatchForTest();
        Test.stopTest();
        Integer intafterCount = [SELECT Count() FROM OpportunityTeamMember WHERE User.LastName = 'BatchDeleteACT Test'];
        System.assertEquals(8,intafterCount );
                TriggerExecutionController.setSkipAllTriggers(false);

    }
}