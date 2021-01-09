@isTest
public class ContactTableController_Test {
    
	 public static testMethod void getActiveContactAssociatedToSM_Test() { 
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
        
         TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipContactTriggers(false);
        test.startTest();
        PageReference pageRef = Page.SalesmotionActiveInactiveContacts;
        Test.setCurrentPage(pageRef);
        ContactTableController testActiveInactiveCon = new ContactTableController();
        ContactTableController.getActiveContactAssociatedToSM(10,acc.Id,testPartnerTrackObj.Id,0);
        test.stopTest();
    }
    
    public static testMethod void getInActiveContactAssociatedToSM_Test() { 
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
        
        final List<Contact> inActiveContacts = new List<Contact>();
        for(Integer intI = 0; intI < 6; intI++){
            inActiveContacts.add(
                new Contact(
                    AccountId = acc.Id,
                    Email=''+intI+'@DELLTEAM.com', 
                    FirstName = 'John', 
                    LastName = 'Test'+intI,
                    Status__c = 'Invalid - No Longer w/ Company',
                    phone = '6739',
                    EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';'
                )
            );
        }
        insert inActiveContacts;
        system.assertEquals(true, inActiveContacts.size()>0);
        
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipContactTriggers(false);
        test.startTest();
        PageReference pageRef = Page.SalesmotionActiveInactiveContacts;
        Test.setCurrentPage(pageRef);
        ContactTableController testActiveInactiveCon = new ContactTableController();
        ContactTableController.getInActiveContactAssociatedToSM(10,acc.Id,testPartnerTrackObj.Id,0);
        test.stopTest();
    }
    public static testMethod void loadContactRecords_Test() {
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
        
         TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipContactTriggers(false);
        test.startTest();
        PageReference pageRef = Page.SalesmotionActiveInactiveContacts;
        Test.setCurrentPage(pageRef);
        ContactTableController testActiveInactiveCon = new ContactTableController();
        ContactTableController.getActiveContactAssociatedToSM(10,acc.Id,testPartnerTrackObj.Id,0);
        ContactTableController.loadContactRecords('Active',acc.Id,testPartnerTrackObj.Id,10,0);
        ContactTableController.loadContactRecords('InActive',acc.Id,testPartnerTrackObj.Id,10,0);
        test.stopTest();
    }
    public static testMethod void findByName_Test() {
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
        
         TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipContactTriggers(false);
        test.startTest();
        PageReference pageRef = Page.SalesmotionActiveInactiveContacts;
        Test.setCurrentPage(pageRef);
        ContactTableController testActiveInactiveCon = new ContactTableController();
        ContactTableController.getActiveContactAssociatedToSM(10,acc.Id,testPartnerTrackObj.Id,0);
        ContactTableController.findByName('Active','test',acc.Id,testPartnerTrackObj.Id);
        ContactTableController.findByName('InActive','test',acc.Id,testPartnerTrackObj.Id);
        test.stopTest();
    }
}