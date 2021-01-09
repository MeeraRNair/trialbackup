@isTest
public class SalesmotionActiveInactiveCtrlTest {
    public static testMethod void salesMotionActiveInactiveContacts() { 
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
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
        
        Id partnerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Partner_Account).getRecordTypeId();
        
        Account salesAcc = new Account();
        salesAcc.Name = 'testSalesmotionAccount';
        salesAcc.NPS_Qualified_Contacts__c = 1;
        salesAcc.Partner_Track__c = testPartnerTrackObj.id;
        salesAcc.Master_Group_Id__c = acc.id;
        salesAcc.RecordTypeId = partnerAccId;
        insert salesAcc; 
        
        final List<Contact> activeContacts = new List<Contact>();
        for(Integer intI = 0; intI < 6; intI++){
            activeContacts.add(
                new Contact(
                    AccountId = acc.Id,
                    Email=''+intI+'@DELLTEAM.com', 
                    FirstName = 'John', 
                    LastName = 'Test'+intI,
                    Status__c = 'Customer',
                    phone = '6739',
                    EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';'
                )
            );
        }
        insert activeContacts;
        system.assertEquals(true, activeContacts.size()>0);
        
        final List<Contact> inActiveContacts = new List<Contact>();
        for(Integer intI = 0; intI < 6; intI++){
            inActiveContacts.add(
                new Contact(
                    AccountId = acc.Id,
                    Email=''+intI+'@DELLTEAMInactive.com', 
                    FirstName = 'John', 
                    LastName = 'testInactive'+intI,
                    Status__c = 'Invalid - No Longer w/ Company',
                    phone = '673911',
                    EligibleTracks__c = testPartnerTrackObj.id
                )
            );
        }
        insert inActiveContacts;
        system.assert(inActiveContacts.size() > 0);
        
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipContactTriggers(false);
        test.startTest();
        PageReference pageRef = Page.LinkedPartnerTracks;
        pageRef.getparameters().put('recordId', salesAcc.id);
        Test.setCurrentPage(pageRef);
        Apexpages.StandardController sc = new Apexpages.StandardController(salesAcc);
       // SalesmotionActiveInactiveContactsCtrl testActiveInactiveCon = new SalesmotionActiveInactiveContactsCtrl(sc);
        SalesmotionActiveInactiveContactsCtrl testActiveInactiveCon = new SalesmotionActiveInactiveContactsCtrl (sc);
        
        testActiveInactiveCon.getSalesMotionInactiveContacts();
       // testActiveCon.getNextActiveContacts();
      //  testActiveCon.getPreviousActiveContacts();
      //  testActiveCon.getprev();
       // testActiveCon.getnxt();
      //  testActiveCon.goToActiveList();
      //  testActiveCon.editContact();
        
        SalesmotionActiveContactsCtrl testInactiveCon = new SalesmotionActiveContactsCtrl(sc);
        testInactiveCon.getSalesMotionActiveContacts();
        //testInactiveCon.getNextInActiveContacts();
       // testInactiveCon.getPreviousInactiveContacts();
       // testInactiveCon.goToInActiveList();
      //  testInactiveCon.getInactPrev();
      //  testInactiveCon.getInactNxt();
        test.stopTest();
    }
}