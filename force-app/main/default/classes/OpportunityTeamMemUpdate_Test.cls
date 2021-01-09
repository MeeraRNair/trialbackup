/*
* Revision CR Number   Release No  Date            Created/Modified By         Description
* -------- ---------   ----------  -----------     ------------                -----------
* 1.0     CR#14962     FY18-1101  19-Apr-2017     Venkateswarlu Chirala       Test class to cover all methods in OpportunityTeamMemUpdate
*   
*/
/* 
* Revision CR Number   Release No        Date            Modified By               Description
* -------- ---------   ----------     -----------       ------------               -----------
*                                       26-Sep-2019      Venugopalachary k         Implement Test Data Factory                                   
*/ 
@isTest(seeAllData = false)
private class OpportunityTeamMemUpdate_Test {
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    @testSetup static void setup() {
        OWD__c owdSetting  = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(3, 'Partner Account');
        insert listAccfromFactory;
        List<Opportunity> listOppFromFactory=TestDataFactory.createNOpportunities(1, 'Channel Opportunity');
        insert listOppFromFactory;
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }   
    @isTest static void opportunityTeamMemUpdateTestMethod() {
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c testCountryObject = new Country__c(name = 'Jedi Country', Dell_Online_Country_Code__c = 'JC', Code__c = 'JC', Enabled_Auto_Renewal__c = True, Last_Operation_Performed__c = 'Test Data');
        insert testCountryObject;
        listAcc=[select id from account];
        for(Account acc : listAcc){
            acc.Account_Country_Code__c='JC';
            acc.Account_Country__c = 'Jedi Country';
            acc.Approved_for_Partner_Finder__c = false;
        }
        update listAcc;
        System.assertEquals('Jedi Country',listAcc[0].Account_Country__c );
        Profile testProfile = [select id, name from profile where name like '%Sales%' order by name limit 1 ];
        System.assert(testProfile != null);
        User testUser1 = new User(FirstName = 'Test 1', LastName = 'BatchDeleteACT Test', Title = 'OEM_SR', UserName = 'TestU1' + System.currentTimeMillis() + '@test.com', Email = 'TestU1@dell.com', Alias = 'test01', CommunityNickName = 'Test01', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest111');
        User testUser2 = new User(FirstName = 'Test 2', LastName = 'BatchDeleteACT Test', Title = 'OEM_SR', UserName = 'TestU2' + System.currentTimeMillis() + '@test.com', Email = 'TestU2@dell.com', Alias = 'test02', CommunityNickName = 'Test02', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest222');
        User testUser3 = new User(FirstName = 'Test 3', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU3' + System.currentTimeMillis() + '@test.com', Email = 'TestU3@dell.com', Alias = 'test03', CommunityNickName = 'Test03', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest333');
        User testUser4 = new User(FirstName = 'Test 4', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU4' + System.currentTimeMillis() + '@test.com', Email = 'TestU4@dell.com', Alias = 'test04', CommunityNickName = 'Test04', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest444');
        User testUser5 = new User(FirstName = 'Test 5', LastName = 'BatchDeleteACT Test', Title = 'MSG_SR', UserName = 'TestU5' + System.currentTimeMillis() + '@test.com', Email = 'TestU5@dell.com', Alias = 'test05', CommunityNickName = 'Test05', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest1115');
        User testUser6 = new User(FirstName = 'Test 6', LastName = 'BatchDeleteACT Test', Title = 'MSG_SR', UserName = 'TestU6' + System.currentTimeMillis() + '@test.com', Email = 'TestU6@dell.com', Alias = 'test06', CommunityNickName = 'Test06', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest2226');
        User testUser7 = new User(FirstName = 'Test 7', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU7' + System.currentTimeMillis() + '@test.com', Email = 'TestU7@dell.com', Alias = 'test07', CommunityNickName = 'Test07', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest3337');
        User testUser8 = new User(FirstName = 'Test 8', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU8' + System.currentTimeMillis() + '@test.com', Email = 'TestU8@dell.com', Alias = 'test08', CommunityNickName = 'Test08', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest4448');
        List < User > listtestUser = new List < User > ();
        listtestUser.add(testUser1);
        listtestUser.add(testUser2);
        listtestUser.add(testUser3);
        listtestUser.add(testUser4);
        listtestUser.add(testUser5);
        listtestUser.add(testUser6);
        listtestUser.add(testUser7);
        listtestUser.add(testUser8);
        insert listtestUser;
        AccountTeamMember testACT1 = new AccountTeamMember(UserId = testUser1.Id, TeamMemberRole = 'OEM SR', AccountId = listAcc[0].Id);
        AccountTeamMember testACT2 = new AccountTeamMember(UserId = testUser2.Id, TeamMemberRole = 'QQQ SR', AccountId = listAcc[0].Id);
        AccountTeamMember testACT3 = new AccountTeamMember(UserId = testUser3.Id, TeamMemberRole = 'OEM SR', AccountId = listAcc[0].Id);
        AccountTeamMember testACT4 = new AccountTeamMember(UserId = testUser4.Id, TeamMemberRole = 'QQQ SR', AccountId = listAcc[0].Id);
        AccountTeamMember testACT5 = new AccountTeamMember(UserId = testUser5.Id, TeamMemberRole = 'MSG SR', AccountId = listAcc[1].Id);
        AccountTeamMember testACT6 = new AccountTeamMember(UserId = testUser6.Id, TeamMemberRole = 'QQQ SR', AccountId = listAcc[1].Id);
        AccountTeamMember testACT7 = new AccountTeamMember(UserId = testUser7.Id, TeamMemberRole = 'MSG SR', AccountId = listAcc[1].Id);
        AccountTeamMember testACT8 = new AccountTeamMember(UserId = testUser8.Id, TeamMemberRole = 'QQQ SR', AccountId = listAcc[1].Id);
        List < AccountTeamMember > listtestACT = new List < AccountTeamMember > ();
        listtestACT.add(testACT1);
        listtestACT.add(testACT2);
        listtestACT.add(testACT3);
        listtestACT.add(testACT4);
        listtestACT.add(testACT5);
        listtestACT.add(testACT6);
        listtestACT.add(testACT7);
        listtestACT.add(testACT8);
        insert listtestACT;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountID=listAcc[0].id;
        listOpp[0].Deal_Registration_Status__c = 'Recalled';
        listOpp[0].Deal_Created_Date_Time__c = System.Now();
        listOpp[0].Deal_Expiration_Timeframe__c='60';
        listOpp[0].Deal_Expiration_Date__c=System.Now().Date().addDays(4);
        listOpp[0].Request_Status__c='New';
        update listOpp;
        Map < ID, Opportunity > mapold = new Map < ID, opportunity > {listOpp[0].ID => listOpp[0]};
            Map < ID, opportunity > mapnew = new Map < ID, opportunity > ();
        opportunity tempOpp = new opportunity(ID = listOpp[0].ID, AccountID = listAcc[1].ID, Deal_Registration_Status__c = 'Approved', Deal_Created_Date_Time__c = system.today());
        update tempOpp;
        Opportunity newOppt = [select id, Name, AccountID, StageName, Deal_Registration_Status__c, Deal_Created_Date_Time__c, Deal_Reg_Oppty__c from Opportunity where ID =: tempOpp.ID];
        mapnew.put(newOppt.ID, newOppt);
        List < OpportunityTeamMember > listinsertOppMem = new List < OpportunityTeamMember > ();
        listinsertOppMem.add(new OpportunityTeamMember(OpportunityID = listOpp[0].ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'Inside Sales Rep', UserID = testUser1.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        listinsertOppMem.add(new OpportunityTeamMember(OpportunityID = listOpp[0].ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'Inside Sales Rep', UserID = testUser2.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        insert listinsertOppMem;
        OpportunityTeamMemUpdate.updateOppTeamMemWhenEndAccChange(mapold, mapnew);
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();
    }
}