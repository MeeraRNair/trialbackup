@isTest
public class GrantAccessToSM_Test {
    
     static testMethod void testGrantAccessSM(){
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        Id partnerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        TriggerExecutionController.setSkipAccountTriggers(true);
        
        Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        acc.Website = 'www.dell.com';
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
        listAcc.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'test Sales Motion 2';
        acc2.NPS_Qualified_Contacts__c = 1;
        acc2.RecordTypeId = partnerAccountRecordTypeId;
        acc2.Account_ID__c='SMAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        acc2.Master_Group_Id__c = acc.id;
        acc2.Partner_Track__c = testPartnerTrackObj.id;
        listAcc.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'test Sales Motion 3';
        acc3.NPS_Qualified_Contacts__c = 1;
        acc3.RecordTypeId = partnerAccountRecordTypeId;
        acc3.Account_ID__c='SMAff1213'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        acc3.Master_Group_Id__c = acc.id;
        acc3.Partner_Track__c = testPartnerTrackObj1.id;
        listAcc.add(acc3);
        
        Account acc4 = new Account();
        acc4.Name = 'test Sales Motion 4';
        acc4.NPS_Qualified_Contacts__c = 1;
        acc4.RecordTypeId = partnerAccountRecordTypeId;
        acc4.Account_ID__c='SMAff1214'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        acc4.Master_Group_Id__c = acc.id;
        acc4.Partner_Track__c = testPartnerTrackObj.id;
        listAcc.add(acc4);
        insert listAcc ;
        
        List<Contact> listContact = new List<Contact>();
       
        Contact con1 = new Contact(AccountId = acc.Id,Email='userUtils'+'@DELLTEAM.com',FirstName = 'John', 
                                    LastName = 'Test User Utils',Status__c = 'Customer',phone = '6739',
                                    EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';' +testPartnerTrackObj2.id);
        
        listContact .add(con1);
        
        Contact con2 = new Contact(AccountId = acc.Id,Email='userUtils1@DELLTEAM.com',FirstName = 'John', 
                                    LastName = 'Test User Utils2',Status__c = 'Customer',phone = '6739',
                                    EligibleTracks__c = testPartnerTrackObj.id);
        
        
        listContact .add(con2);
        
        system.assertEquals(testPartnerTrackObj.Master_Group_Id__c,acc.id);
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
        listusr .add(newUser2);
        insert listusr ;
                
        List<AccountShare> listtestAS = new List<AccountShare>();
       
         // Build the account share
        AccountShare acctS = new AccountShare();
        acctS.AccountId = listAcc[0].Id;
        acctS.UserOrGroupId = listusr[0].Id;
        acctS.AccountAccessLevel = 'Read';
        acctS.OpportunityAccessLevel = 'None';
        listtestAS.add(acctS);
        
        AccountShare acctS1 = new AccountShare();
        acctS1.AccountId = listAcc[1].Id;
        acctS1.UserOrGroupId = listusr[0].Id;
        acctS1.AccountAccessLevel = 'Read';
        acctS1.OpportunityAccessLevel = 'None';
        listtestAS.add(acctS1);
        insert listtestAS;
        
        system.debug('testAS!!!'+listtestAS);
        
        GrantAccessToSalesMotions objGrant = new GrantAccessToSalesMotions();

        Database.QueryLocator ql = objGrant.start(null);
        objGrant.execute(null,listContact);
        objGrant.Finish(null);

        
        //GrantAccessToSalesMotions objGrant = new GrantAccessToSalesMotions();
        //Database.executeBatch(objGrant);

        Test.stopTest();
        
        
    }


}