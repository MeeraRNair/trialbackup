@isTest
public class PTRHandler_Test {
private static testmethod void testonboardNewSM(){
        
        List<Account> listAcc = new List<Account>();
        
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        Id partnerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        TriggerExecutionController.setSkipAccountTriggers(true);
        
        Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        acc.Master_Group_Affinity_ID__c='MGAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        //acc.Master_Group_Affinity_ID__c = '1212';
        listAcc.add(acc);
        
        Account acc1 = new Account();
        acc1.Name = 'test Sales Motion';
        acc1.NPS_Qualified_Contacts__c = 1;
        acc1.RecordTypeId = partnerAccountRecordTypeId;
        acc1.Account_ID__c='SMAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        listAcc.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'test Sales Motion2';
        acc2.NPS_Qualified_Contacts__c = 1;
        acc2.RecordTypeId = partnerAccountRecordTypeId;
        acc2.Account_ID__c='SMAff1343'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        listAcc.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'test Sales Motion3';
        acc3.NPS_Qualified_Contacts__c = 1;
        acc3.RecordTypeId = partnerAccountRecordTypeId;
        acc3.Account_ID__c='SMAff1333'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        listAcc.add(acc3);
        
        Account acc13 = new Account();
        acc13.Name = 'test Sales Motion3';
        acc13.NPS_Qualified_Contacts__c = 1;
        acc13.RecordTypeId = partnerAccountRecordTypeId;
        acc13.Account_ID__c='SMAff1313'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        listAcc.add(acc13);
        
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAcc;
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        //Partner Request insertion
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj.partner_Track_affinityId__c = '1232'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj.Partner_Registration_Number__c = '';
        testPartnerTrackObj.Primary_SMAffinity_Account__c = listAcc[1].Id;
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj1.partner_Track_affinityId__c = '1252'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj1.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj1.Primary_SMAffinity_Account__c = listAcc[1].Id;
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testPartnerTrackObj1;
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data2';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj2.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj2.partner_Track_affinityId__c = '1242'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj2.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj2.Primary_SMAffinity_Account__c = listAcc[1].Id;
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testPartnerTrackObj2;
        
        System.debug('Contact'+listAcc[0].Master_Group_Affinity_ID__c);
        List<Account> listAccToUpdate = new List<Account>();
        
        Account acc4 = listAcc.get(0);
        Account acc5 = listAcc.get(1);
        Account acc6 = listAcc.get(2);
        Account acc7 = listAcc.get(3);
        Account acc8 = listAcc.get(4);
        
        acc5.Master_Group_Id__c = listAcc[0].id;
        acc5.IsPartner = true;
        acc5.Partner_Track__c  = testPartnerTrackObj.id;
        listAccToUpdate.add(acc5);
        
        acc6.Master_Group_Id__c = listAcc[0].id;
        acc6.Partner_Track__c  = testPartnerTrackObj1.id;
        acc6.IsPartner = true;
        listAccToUpdate.add(acc6);
        
        acc7.Master_Group_Id__c = listAcc[0].id;
        acc7.Partner_Track__c  = testPartnerTrackObj2.id;
        acc7.IsPartner = true;
        listAccToUpdate.add(acc7);
        
        acc8.Master_Group_Id__c = listAcc[0].id;
        acc8.IsPartner = true;
        acc8.Partner_Track__c  = testPartnerTrackObj2.id;
        listAccToUpdate.add(acc8);
        update listAccToUpdate;
        
        /*listAcc[1].Master_Group_Id__c = listAcc[0].id;
        listAcc[1].Partner_Track__c  = testPartnerTrackObj2.id;
        update listAcc;*/
        final List<Contact> activeContacts = new List<Contact>();
        
        Contact con1 = new Contact(AccountId = listAcc[0].Id,Email='testPTRHanlder@DELLTEAM.com',
                                   FirstName = 'John PTR',LastName = 'Test'+string.valueof(Math.abs(Crypto.getRandomInteger())),
                                   Status__c = 'Customer',phone = '6739',EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj2.id + ';'+testPartnerTrackObj1+';'
                                  );

        TriggerExecutionController.setSkipAllTriggers(true);
        insert con1;
        /*
         Contact con2 = new Contact(AccountId = listAcc[0].Id,Email='testPTRHanlder2@DELLTEAM.com', 
                                   FirstName = 'John PTR2',LastName = 'Test'+string.valueof(Math.abs(Crypto.getRandomInteger())),
                                   Status__c = 'Customer',phone = '6739',EligibleTracks__c = testPartnerTrackObj.id
                                  );
        insert con2;
        */
        system.assert(con1 != null);
        // insert activeContacts;
        System.debug('con1'+listAcc[0]);
        System.debug('con1'+con1);
        System.debug('con1'+con1.Account.Master_Group_Affinity_ID__c);
        System.debug('con1'+listAcc[0].Master_Group_Affinity_ID__c);
       /*
        String strMGAId = listAcc[0].Master_Group_Affinity_ID__c;
        con1.Account.Master_Group_Affinity_ID__c = strMGAId;
        update con1;
        */
        system.assert(listAcc[0].Master_Group_Affinity_ID__c != null);
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        List<User> listusr = new List<User>();
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'bilo'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        User newUser1 = new User(profileId = listp [1].id,username = strnewusername ,email = 'pb@ff.com',Badge_Number__c=null, PortalRole = 'Manager',
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',
                                 lastname='lastname user utils',contactId = con1.id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listusr.add(newUser1);
        /*
        Integer intuserNumber2 = Math.abs(Crypto.getRandomInteger());
        String strnewusername2 = 'bilo12'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        User newUser2 = new User(profileId = listp [1].id,username = strnewusername2 ,email = 'pb@ff.com',Badge_Number__c=null, PortalRole = 'Manager',
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',
                                 lastname='lastname userrt utils',contactId = con2.id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listusr.add(newUser2);
        
       */
        
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listusr ;
        List<AccountShare> listTestAS = new List<AccountShare>();
        
        // Build the account share
        AccountShare acctS = new AccountShare();
        acctS.AccountId = listAcc[2].Id;
        acctS.UserOrGroupId = listusr[0].Id;
        acctS.AccountAccessLevel = 'Read';
        acctS.OpportunityAccessLevel = 'None';
        acctS.RowCause='Manual';
        listTestAS.add(acctS);
        
        AccountShare acctS1 = new AccountShare();
        acctS1.AccountId = listAcc[1].Id;
        acctS1.UserOrGroupId = listusr[0].Id;
        acctS1.AccountAccessLevel = 'Read';
        acctS1.OpportunityAccessLevel = 'None';
        acctS1.RowCause='Manual';
        listTestAS.add(acctS1);
        
        AccountShare acctS2 = new AccountShare();
        acctS2.AccountId = listAcc[3].Id;
        acctS2.UserOrGroupId = listusr[0].Id;
        acctS2.AccountAccessLevel = 'Read';
        acctS2.OpportunityAccessLevel = 'None';
        acctS2.RowCause='Manual';
        listTestAS.add(acctS2);
        
        insert listTestAS;
        system.debug('listTestAS!!!'+listTestAS); 
        
        List<Partner_Track_Relationship__c> listPTR = new List<Partner_Track_Relationship__c>();
        Partner_Track_Relationship__c pr=new Partner_Track_Relationship__c();
        pr.Master_Group_AffinityId__c = listAcc[0].Master_Group_Affinity_ID__c;
        pr.Sales_Motion_Account_AffinityId__c=listAcc[1].Account_ID__c;
        pr.Partner_Track_AffinityId__c=testPartnerTrackObj.partner_Track_affinityId__c;
        pr.PTR_AffinityId__c = '1212';
        pr.Is_Processed__c = true;
        listPTR.add(pr);
        
        Partner_Track_Relationship__c pr2=new Partner_Track_Relationship__c();
        pr2.Master_Group_AffinityId__c = listAcc[0].Master_Group_Affinity_ID__c;
        pr2.Sales_Motion_Account_AffinityId__c=listAcc[2].Account_ID__c;
        pr2.Partner_Track_AffinityId__c=testPartnerTrackObj1.partner_Track_affinityId__c;
        pr2.PTR_AffinityId__c = '1313';
        pr2.Is_Processed__c = true;
        listPTR.add(pr2);
        
        Partner_Track_Relationship__c pr3=new Partner_Track_Relationship__c();
        pr3.Master_Group_AffinityId__c = listAcc[0].Master_Group_Affinity_ID__c;
        pr3.Sales_Motion_Account_AffinityId__c=listAcc[3].Account_ID__c;
        pr3.Partner_Track_AffinityId__c=testPartnerTrackObj2.partner_Track_affinityId__c;
        pr3.PTR_AffinityId__c = '1414';
        pr3.Is_Processed__c = true;
        listPTR.add(pr3);
        
        test.startTest();
    
        
        Partner_Track_Relationship__c pr4=new Partner_Track_Relationship__c();
        pr4.Master_Group_AffinityId__c = listAcc[0].Master_Group_Affinity_ID__c;
        pr4.Sales_Motion_Account_AffinityId__c=listAcc[4].Account_ID__c;
        pr4.Partner_Track_AffinityId__c=testPartnerTrackObj2.partner_Track_affinityId__c;
        pr4.PTR_AffinityId__c = '1424';
        pr4.Is_Processed__c = true;
    
        //insert pr4;
        listPTR.add(pr4);
        
        insert listPTR;
        System.debug('listPTR:'+listPTR);
        
        Map<Id,Partner_Track_Relationship__c> mapNewPTR = new Map<Id,Partner_Track_Relationship__c>(listPTR);
        new PTRHandler().onBoardNewSM(mapNewPTR);
        
        listPTR[1].Partner_Track_AffinityId__c =testPartnerTrackObj.partner_Track_affinityId__c; 
        update listPTR;
        
        Map<Id,Partner_Track_Relationship__c> mapPTR = new Map<Id,Partner_Track_Relationship__c>(listPTR);
     List<Partner_Request__c> listTestPartnerRequest=new List<Partner_Request__c>();
        Map<String,Partner_Request__c> mapPartner = new Map<String,Partner_Request__c>();
        Partner_Request__c testPartnerRequest1=new Partner_Request__c(First_Name__c='testPartnerRequest1',Last_Name__c='testAccount1',Email__c='abc@test.com',
                Job_Title__c='Engineer',State__c='New',Status__c = 'Account Suggestion Submitted');
        Partner_Request__c testPartnerRequest2=new Partner_Request__c(First_Name__c='testPartnerRequest2',Last_Name__c='testAccount2',Email__c='abc@test.com',
                Job_Title__c='Engineer',State__c='New',Status__c ='Incomplete');
        
           
        listTestPartnerRequest.add(testPartnerRequest1);
        listTestPartnerRequest.add(testPartnerRequest2);
        insert listTestPartnerRequest;
        
        new PTRHandler().updateAccessUponSMChange(mapPTR ,mapNewPTR);
        test.stopTest();    
        system.assertEquals(1,[Select count() from Contact where Email='testPTRHanlder@DELLTEAM.com']);
    } 
    public static testmethod void testAccessToSM(){
        List<Account> listAccSM = new List<Account>();
        List<Account> listAccMG = new List<Account>();
        String strAccessType = System.Label.Grant_Access_Type;
        List<Partner_Track__c > listptr = new List<Partner_Track__c >();
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        Id partnerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        acc.Master_Group_Affinity_ID__c='MGAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        listAccMG.add(acc);
        
        insert listAccMG;
        
        
         Account acc1 = new Account();
        acc1.Name = 'test Sales Motion';
        acc1.NPS_Qualified_Contacts__c = 1;
        acc1.RecordTypeId = partnerAccountRecordTypeId;
        acc1.Account_ID__c='SMAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        listAccSM.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'test Sales Motion2';
        acc2.NPS_Qualified_Contacts__c = 1;
        acc2.RecordTypeId = partnerAccountRecordTypeId;
        acc2.Account_ID__c='SMAff1343'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        listAccSM.add(acc2);
        insert listAccSM;
        
         Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
         Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
       testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAccMG[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAccMG[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj.partner_Track_affinityId__c = '1232'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c=listAccSM[1].Account_ID__c;
        testPartnerTrackObj.Partner_Registration_Number__c = '';
        testPartnerTrackObj.Primary_SMAffinity_Account__c = listAccSM[1].Id;
        TriggerExecutionController.setSkipAllTriggers(true);
      //  insert testPartnerTrackObj;
        listptr.add(testPartnerTrackObj);
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
       testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAccMG[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAccMG[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj1.partner_Track_affinityId__c = '1252'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj1.Primary_Sales_Motion_Affinity_ID__c=listAccSM[1].Account_ID__c;
        testPartnerTrackObj1.Primary_SMAffinity_Account__c = listAccSM[1].Id;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        listptr.add(testPartnerTrackObj1);
        insert listptr;
        
        List<string> listAccMG1 = new List<string>{acc.Master_Group_Affinity_ID__c};
        
        List<string> listptr1 = new List<string>{listptr[0].partner_Track_affinityId__c,listptr[1].partner_Track_affinityId__c};
             
                
        Contact con1 = new Contact(AccountId = listAccMG[0].Id,Email='testPTRHanlder@DELLTEAM.com',
                                   FirstName = 'John PTR',LastName = 'Test'+string.valueof(Math.abs(Crypto.getRandomInteger())),
                                   Status__c = 'Customer',phone = '6739',EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1+';'
                                  );

        TriggerExecutionController.setSkipAllTriggers(true);
        insert con1;
        
        List<Account> listAccToUpdate = new List<Account>();
        
        Account acc4 = listAccSM.get(0);
        Account acc5 = listAccSM.get(1);
        
        
        acc5.Master_Group_Id__c = listAccMG[0].id;
        acc5.IsPartner = true;
        acc5.Partner_Track__c  = testPartnerTrackObj.id;
        listAccToUpdate.add(acc5);
        
        acc4.Master_Group_Id__c = listAccMG[0].id;
        acc4.Partner_Track__c  = testPartnerTrackObj1.id;
        acc4.IsPartner = true;
        listAccToUpdate.add(acc4);
        
        update listAccToUpdate;
        
        List<string> listAccSM1 = new List<string>{listAccToUpdate[0].Account_Id__c,listAccToUpdate[1].Account_Id__c};
        
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        List<User> listusr = new List<User>();
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'bilo'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        User newUser1 = new User(profileId = listp [1].id,username = strnewusername ,email = 'pb@ff.com',Badge_Number__c=null, PortalRole = 'Manager',
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',
                                 lastname='lastname user utils',contactId = con1.id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listusr.add(newUser1);
        
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listusr ;
        List<AccountShare> listTestAS = new List<AccountShare>();
        
        // Build the account share
        AccountShare acctS = new AccountShare();
        acctS.AccountId = listAccSM[0].Id;
        acctS.UserOrGroupId = listusr[0].Id;
        acctS.AccountAccessLevel = 'Read';
        acctS.OpportunityAccessLevel = 'None';
        acctS.RowCause='Manual';
        listTestAS.add(acctS);
        
        AccountShare acctS1 = new AccountShare();
        acctS1.AccountId = listAccSM[1].Id;
        acctS1.UserOrGroupId = listusr[0].Id;
        acctS1.AccountAccessLevel = 'Read';
        acctS1.OpportunityAccessLevel = 'None';
        acctS1.RowCause='Manual';
        listTestAS.add(acctS1);
        
             
        insert listTestAS;
        system.debug('listTestAS!!!'+listTestAS); 
        
        PTRHandler.grantRevokeAccessToSM(listAccSM1, listAccMG1,listptr1, strAccessType);     
        
         system.assertEquals(1,[Select count() from Contact where Email='testPTRHanlder@DELLTEAM.com']);
     
    }
    public static testmethod void testsendingMail(){
         
        List<Account> listAcc = new List<Account>();
          Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        Id partnerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        TriggerExecutionController.setSkipAccountTriggers(true);
        Set<String> setPT = new Set<String>();
        Set<String> setMG = new Set<String>();
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        List<User> listusr = new List<User>();
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'bilo'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
         Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        acc.Master_Group_Affinity_ID__c='MGAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        //acc.Master_Group_Affinity_ID__c = '1212';
        listAcc.add(acc);
        
        Account acc1 = new Account();
        acc1.Name = 'test Sales Motion';
        acc1.NPS_Qualified_Contacts__c = 1;
        acc1.RecordTypeId = partnerAccountRecordTypeId;
        acc1.Account_ID__c='SMAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        listAcc.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'test Sales Motion2';
        acc2.NPS_Qualified_Contacts__c = 1;
        acc2.RecordTypeId = partnerAccountRecordTypeId;
        acc2.Account_ID__c='SMAff1343'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        listAcc.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'test Sales Motion3';
        acc3.NPS_Qualified_Contacts__c = 1;
        acc3.RecordTypeId = partnerAccountRecordTypeId;
        acc3.Account_ID__c='SMAff1333'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        listAcc.add(acc3);
        insert listAcc;
        
        Contact con1 = new Contact(AccountId = listAcc[0].Id,Email='testPTRHanlder@DELLTEAM.com',
                                   FirstName = 'John PTR',LastName = 'Test'+string.valueof(Math.abs(Crypto.getRandomInteger())),
                                   Status__c = 'Customer',phone = '6739');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert con1;
        User newUser1 = new User(profileId = listp [1].id,username = strnewusername ,email = 'pb@ff.com',Badge_Number__c=null, PortalRole = 'Manager',
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',
                                 lastname='lastname user utils',contactId = con1.id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listusr.add(newUser1);
        
       
        insert listusr ;
        
        con1.Partner_User__c=listusr[0].id;
        update con1;
        
        system.debug('>>>>con1'+con1);
         system.debug('>>>>con1'+con1.Enable_as_Partner_Group_Administrator__c);
        List<Contact> listCon = new List<Contact>();
        listCon.add(con1);
        
        List<Account> listAllSM = new List<Account>();
        listAllSM.add(acc1);
        listAllSM.add(acc2);
        listAllSM.add(acc3);
        
        List<string> listPRNumber = new List<String>();
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
                Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj.partner_Track_affinityId__c = '1232'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj.Partner_Registration_Number__c = '';
        testPartnerTrackObj.Primary_SMAffinity_Account__c = listAcc[1].Id;
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj1.partner_Track_affinityId__c = '1252'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj1.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj1.Primary_SMAffinity_Account__c = listAcc[1].Id;
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testPartnerTrackObj1;
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data2';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj2.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj2.partner_Track_affinityId__c = '1242'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj2.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj2.Primary_SMAffinity_Account__c = listAcc[1].Id;
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testPartnerTrackObj2;

        list<Partner_Track__c> listPt = new list<Partner_Track__c>();
        listPt.add(testPartnerTrackObj1);
        listPt.add(testPartnerTrackObj2);
        update listPt;
        
         List<Partner_Track_Relationship__c> listPTR = new List<Partner_Track_Relationship__c>();
        Partner_Track_Relationship__c pr=new Partner_Track_Relationship__c();
        pr.Master_Group_AffinityId__c = listAcc[0].Master_Group_Affinity_ID__c;
        pr.Sales_Motion_Account_AffinityId__c=listAcc[1].Account_ID__c;
        pr.Partner_Track_AffinityId__c=testPartnerTrackObj.partner_Track_affinityId__c;
        pr.PTR_AffinityId__c = '1212';
        pr.Is_Processed__c = true;
        listPTR.add(pr);

        
      /*  Partner_Track_Relationship__c pr2=new Partner_Track_Relationship__c();
        pr2.Master_Group_AffinityId__c = listAcc[0].Master_Group_Affinity_ID__c;
        pr2.Sales_Motion_Account_AffinityId__c=listAcc[2].Account_ID__c;
        pr2.Partner_Track_AffinityId__c=testPartnerTrackObj2.partner_Track_affinityId__c;
        pr2.PTR_AffinityId__c = '1313';
        pr2.Is_Processed__c = true;
        listPTR.add(pr2);*/
        
        list<Partner_Track_Relationship__c> listPTRForNewPT= new list<Partner_Track_Relationship__c>();
        Partner_Track_Relationship__c pr3=new Partner_Track_Relationship__c();
        pr3.Master_Group_AffinityId__c = listAcc[0].Master_Group_Affinity_ID__c;
        pr3.Sales_Motion_Account_AffinityId__c=listAcc[2].Account_ID__c;
        pr3.Partner_Track_AffinityId__c = '83646';
        pr3.PTR_AffinityId__c = '1313';
        pr3.Is_Processed__c = true;
        listPTRForNewPT.add(pr3);
        

        test.startTest();
        insert listPTRForNewPT;
        insert listPTR;
        map<id,Partner_Track_Relationship__c> mapPTR = new map<id,Partner_Track_Relationship__c>();
        mapPTR.put(listPTR[0].id,pr);
        
        List<String> listAllMG = new List<String>();
        listAllMG.add(listPTR[0].Master_Group_AffinityId__c);
        //listAllMG.add(listPTR[1].Master_Group_AffinityId__c);

        
        List<String> listAllPT = new List<String>();
        listAllPT.add(listPTR[0].partner_Track_affinityId__c);
       // listAllPT.add(listPTR[1].partner_Track_affinityId__c);

        
        List<String> listAllSMA = new List<String>();
        listAllSMA.add(listPTR[0].Sales_Motion_Account_AffinityId__c);
       // listAllSMA.add(listPTR[1].Sales_Motion_Account_AffinityId__c);
        
      List<contact> listConAsGroupAdmin = new List<contact>();
      listConAsGroupAdmin.add(con1);
        

        
        string strAccessType = System.Label.Grant_Access_Type;
            PTRHandler.grantRevokeAccessToSM(listAllSMA,listAllMG,listAllPT,strAccessType);

        
        Partner_Request__c request = new Partner_Request__c();
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
         insert request;        
        map<string,Partner_Request__c> mapPR = new map<string,Partner_Request__c>();
        mapPR.put('Test Company',request);

        
       Map<String,List<Partner_Track__c>> mapMGToPT = new Map<String, List<Partner_Track__c>>();
        mapMGToPT.put(listPt[0].Partner_Track_Name__c,listPt);
        
       new PTRHandler().mailToMasterGroupAdmin(listPTR,mapPTR);
       test.stopTest();
        
      system.assertEquals(1,[Select count() from Contact where Email='testPTRHanlder@DELLTEAM.com']);  
    }  
}