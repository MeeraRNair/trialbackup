@isTest
private class UserUtilsTest {

    
    static testMethod void updateUserCurrencyTest() {
        
        List<String> listuserIds = new List<String>();
        listuserIds.add(UserInfo.getUserId());
        
        system.debug('########UserInfo.getUserId() ' + UserInfo.getUserId());
        
        Test.startTest();
        UserUtils.updateUserCurrency(listuserIds, 'USD');
        Test.stopTest();
        
        List<User> listusers = [select OSPCurrency__c from User where Id =: UserInfo.getUserId()];
        String strospcurrency = listusers[0].OSPCurrency__c;
        
        system.debug('########listusers[0].OSPCurrency__c ' + listusers[0].OSPCurrency__c);
        system.debug('########strospcurrency ' + strospcurrency);
        
        System.assertEquals('USD',strospcurrency);
    }
    
    static testMethod void updateUserCurrencyTestWithNullCurrency() {
        
        List<String> listuserIds = new List<String>();
        listuserIds.add(UserInfo.getUserId());
        
        system.debug('########UserInfo.getUserId() ' + UserInfo.getUserId());
        
        Test.startTest();
        UserUtils.updateUserCurrency(listuserIds, null);
        Test.stopTest();
        
        List<User> listusers = [select OSPCurrency__c from User where Id =: UserInfo.getUserId()];
        String strospcurrency = listusers[0].OSPCurrency__c;
        
        system.debug('########listusers[0].OSPCurrency__c ' + listusers[0].OSPCurrency__c);
        system.debug('########strospcurrency ' + strospcurrency);
        
        System.assertEquals(null,strospcurrency);
    }
    
    static testMethod void updateUserCurrencyTestWith2UserIds() {
        
        List<User> listusers = [select Id from User LIMIT 2 offset 2];
        List<String> listuserIds = new List<String>();
        listuserIds.add(listusers[0].Id);
        listuserIds.add(listusers[1].Id);
        
        system.debug('########listuserIds ' + listuserIds);
        
        Test.startTest();
        UserUtils.updateUserCurrency(listuserIds, 'MYD');
        Test.stopTest();
        
        List<User> listusersC = [select OSPCurrency__c from User where Id =: listuserIds];
        String strospcurrency0 = listusersC[0].OSPCurrency__c;
        String strospcurrency1 = listusersC[1].OSPCurrency__c;
        
        system.debug('########listusersC ' + listusersC);
        system.debug('########strospcurrency0 ' + strospcurrency0);
        system.debug('########strospcurrency1 ' + strospcurrency1);
        
        System.assertEquals('MYD',strospcurrency0);
        System.assertEquals('MYD',strospcurrency1);
    }
    
    static testMethod void createPortalUser(){
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
                }
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        acc.OwnerId = adminusr.Id;
        insert acc;
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj1;
        
        Account salesAcc = new Account();
        salesAcc.Name = 'testSalesmotionAccount';
        salesAcc.NPS_Qualified_Contacts__c = 1;
        salesAcc.Partner_Track__c = testPartnerTrackObj.id;
        salesAcc.Master_Group_Id__c = acc.id;
        insert salesAcc; 
        
        List<Contact> listContact = new List<Contact>();
        Contact con1 = new Contact(AccountId = acc.Id,Email='userUtils'+'@DELLTEAM.com',FirstName = 'John', 
                                   LastName = 'Test User Utils',Status__c = 'Customer',phone = '6739',
                                   EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';' );
        
        listContact.add(con1);
        
        Contact con2 = new Contact(AccountId = acc.Id,Email='userUtils1@DELLTEAM.com',FirstName = 'John', 
                                   LastName = 'Test User Utils2',Status__c = 'Customer',phone = '6739',
                                   EligibleTracks__c = testPartnerTrackObj.id);
        
        listContact.add(con2);
        system.assertEquals(testPartnerTrackObj.Master_Group_Id__c, acc.Id);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(false);
        insert listContact;
        
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        List<User> listusr = new List<User>();
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'bilo'+intuserNumber+'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber)+string.valueof(Math.abs(Crypto.getRandomInteger()));
        User newUser1 = new User(profileId = listp[1].id,username = strnewusername,email = 'pb@ff.com',Badge_Number__c=null, PortalRole = 'Manager',
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',
                                 lastname='lastname user utils',contactId = listContact[0].id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listusr.add(newUser1);
        
        Integer intuserNumber1 = Math.abs(Crypto.getRandomInteger());
        String strnewusername1 = 'bilo'+intuserNumber1+'_mishra'+'@DELLTEAM.com'; 
        User newUser2 = new User(profileId = listp[1].id,username = strnewusername1,email = 'pb@ff.com',Badge_Number__c=null, PortalRole = 'Manager',
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',
                                 lastname='lastname user utils',contactId = listContact[1].id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listusr.add(newUser2);
        insert listusr;
        Test.stopTest();
    }
    
    static testMethod void grantAccessToRevoke(){
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        Id partnerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        TriggerExecutionController.setSkipAccountTriggers(true);
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
                }
        Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        acc.Website = 'www.dell.com';
        acc.OwnerId = adminusr.Id;
        insert acc;
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj1;
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj2;
        
        
        List<Account> listAcc = new List<Account>();
        Account acc1 = new Account();
        acc1.Name = 'test Sales Motion 1';
        acc1.NPS_Qualified_Contacts__c = 1;
        acc1.RecordTypeId = partnerAccountRecordTypeId;
        acc1.Account_ID__c='SMAff1211'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        acc1.Partner_Track__c = testPartnerTrackObj2.id;
        listAcc .add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'test Sales Motion 2';
        acc2.NPS_Qualified_Contacts__c = 1;
        acc2.RecordTypeId = partnerAccountRecordTypeId;
        acc2.Account_ID__c='SMAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        acc2.Master_Group_Id__c = acc.id;
        acc2.Partner_Track__c = testPartnerTrackObj.id;
        listAcc .add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'test Sales Motion 3';
        acc3.NPS_Qualified_Contacts__c = 1;
        acc3.RecordTypeId = partnerAccountRecordTypeId;
        acc3.Account_ID__c='SMAff1213'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        acc3.Master_Group_Id__c = acc.id;
        acc3.Partner_Track__c = testPartnerTrackObj1.id;
        listAcc .add(acc3);
        
        Account acc4 = new Account();
        acc4.Name = 'test Sales Motion 4';
        acc4.NPS_Qualified_Contacts__c = 1;
        acc4.RecordTypeId = partnerAccountRecordTypeId;
        acc4.Account_ID__c='SMAff1214'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        acc4.Master_Group_Id__c = acc.id;
        acc4.Partner_Track__c = testPartnerTrackObj.id;
        listAcc .add(acc4);
        
        
        Account salesAcc = new Account();
        salesAcc.Name = 'testSalesmotionAccount 5';
        salesAcc.NPS_Qualified_Contacts__c = 1;
        salesAcc.Partner_Track__c = testPartnerTrackObj.id;
        salesAcc.Master_Group_Id__c = acc.id;
        listAcc .add(salesAcc);
        
        Account salesAcc2 = new Account();
        salesAcc2.Name = 'testSalesmotionAccount 6';
        salesAcc2.NPS_Qualified_Contacts__c = 1;
        salesAcc2.Partner_Track__c = testPartnerTrackObj2.id;
        salesAcc2.Master_Group_Id__c = acc.id;
        listAcc .add(salesAcc2);
        
        insert listAcc ;
        
        List<Contact> listContact = new List<Contact>();
        
        Contact con1 = new Contact(AccountId = acc.Id,Email='userUtils'+'@DELLTEAM.com',FirstName = 'John', 
                                   LastName = 'Test User Utils',Status__c = 'Customer',phone = '6739',
                                   EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';' );
        
        listContact .add(con1);
        
        Contact con2 = new Contact(AccountId = acc.Id,Email='userUtils1@DELLTEAM.com',FirstName = 'John', 
                                   LastName = 'Test User Utils2',Status__c = 'Customer',phone = '6739',
                                   EligibleTracks__c = testPartnerTrackObj.id);
        
        listContact .add(con2);
        
        system.assertEquals(testPartnerTrackObj.Master_Group_Id__c, acc.Id);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(True);
        insert listContact;
        
        
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        List<User> listusr = new List<User>();
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'bilo'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        User newUser1 = new User(profileId = listp [1].id,username = strnewusername ,email = 'pb@ff.com',Badge_Number__c=null, PortalRole = 'Manager',
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',
                                 lastname='lastname user utils',contactId = listContact [0].id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listusr .add(newUser1);
        
        Integer intuserNumber1 = Math.abs(Crypto.getRandomInteger());
        String strnewusername1 = 'bilo'+intuserNumber1 +'_mishra'+'@DELLTEAM.com'; 
        User newUser2 = new User(profileId = listp [1].id,username = strnewusername1 ,email = 'pb@ff.com',Badge_Number__c=null, PortalRole = 'Manager',
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',
                                 lastname='lastname user utils',contactId = listContact [1].id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listusr.add(newUser2);
        insert listusr ;
        List<AccountShare> listtestAS = new List<AccountShare>();
        
        // Build the account share
        AccountShare acctS = new AccountShare();
        acctS.AccountId = listAcc[0].Id;
        acctS.UserOrGroupId = listusr[0].Id;
        acctS.AccountAccessLevel = 'Read';
        acctS.OpportunityAccessLevel = 'None';
        //acctS.RowCause='Manual';
        listtestAS.add(acctS);
        
        AccountShare acctS2 = new AccountShare();
        acctS2.AccountId = listAcc[1].Id;
        acctS2.UserOrGroupId = listusr[0].Id;
        acctS2.AccountAccessLevel = 'Read';
        acctS2.OpportunityAccessLevel = 'None';
        //acctS.RowCause='Manual';
        
        listtestAS.add(acctS2);
        insert listtestAS;
        system.debug('listtestAS!!!'+listtestAS);
        
        //Map<Id, User> mapOldUsr = new Map<Id, User>();
        Map<Id, User> mapNewUsr = new Map<Id, User>();
        mapNewUsr.put(listusr[0].Id, listusr[0]);
        mapNewUsr.put(listusr[1].Id, listusr[1]);
        UserUtilities.grantRevokeAccess(mapNewUsr,null);
        
        Group grp = [SELECT Id, Name FROM Group where Name = 'Viper Marketing profiles Public Grp' limit 1];
        Map<Id, User> mapOfUser = new Map<Id, User>();
        mapOfUser.put(newUser2.Id, newUser2);
        Map<String, Id> mapOfGroup = new Map<String, Id>();
        mapOfGroup.put(grp.Name, newUser2.Id);
        UserUtilities.CMAPLeadSuperUserPermission(mapOfUser, mapOfGroup, TriggerHandler.TriggerEvent.ISInsert);
        Test.stopTest();
        
    }
}