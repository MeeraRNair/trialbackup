/********************************************************************
* Name          : VFCntrlr_SelectAccountPrimaryContactTest 
* Description   : Test class for VFCntrlr_SelectAccountPrimaryContact
* -------------------------------------------------------------------
* Revision      Name    Date            Description
* 1.0           JP   04.01.2011      Test class for VFCntrlr_SelectAccountPrimaryContact 
************************************************************/
@isTest
private class VFCntrlr_SelectAccountPrimaryContactTest {
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Master Account');
        insert listAccTdf;
        list<Account> listAccTdf1=TestDataFactory.createNAccount(4, 'Partner Account');
        insert listAccTdf1;
        list<Account> listAccTdf2=TestDataFactory.createNAccount(4, 'End-User Account');
        insert listAccTdf2;
    }
    static Account testAccountObj;
    static Account testAcc;
    static Account testAcc2;
    static Contact testNoPrimary;
    static Contact testHasPrimary;
    static Contact testContact1;
    static Contact testContact;
    static Contact testContact2;
    static Contact testContact3;
    public static testMethod void testPrimaryContactCreation(){
        System.debug('testPrimaryContactCreation');
        TriggerExecutionController.setSkipAccountTriggers(true);
        list<Account> listAcc1=[SELECT ID,Master_Group_Affinity_Id__c FROM Account WHERE Recordtype.name='Master Account' LIMIT 1];
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc1[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc1[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc1[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc1[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj1;
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = listAcc1[0].id;
        testPartnerTrackObj2.Master_Group_Affinity_Id__c = listAcc1[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj2;
        list<Account> listAcc=[SELECT ID FROM Account WHERE Recordtype.name='Partner Account' LIMIT 4];
        listAcc[0].Partner_Track__c = testPartnerTrackObj2.id;
        listAcc[1].Master_Group_Id__c = listAcc1[0].id;
        listAcc[1].Partner_Track__c = testPartnerTrackObj.id;
        listAcc[2].Master_Group_Id__c = listAcc1[0].id;
        listAcc[2].Partner_Track__c = testPartnerTrackObj1.id;
        listAcc[3].Master_Group_Id__c = listAcc1[0].id;
        listAcc[3].Partner_Track__c = testPartnerTrackObj.id;
        update listAcc;
        List<Contact> listContact = new List<Contact>();
        Contact con1 = new Contact(AccountId = listAcc1[0].Id,Email='userUtils'+'@DELLTEAM.com',FirstName = 'John', 
                                   LastName = 'Test User Utils',Status__c = 'Customer',phone = '6739',
                                   EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';' +testPartnerTrackObj2.id);
        
        listContact.add(con1);
        Contact con2 = new Contact(AccountId = listAcc1[0].Id,Email='userUtils1@DELLTEAM.com',FirstName = 'John', 
                                   LastName = 'Test User Utils2',Status__c = 'Customer',phone = '6739',
                                   EligibleTracks__c = testPartnerTrackObj.id);
        
        
        listContact.add(con2);
        system.assertEquals(testPartnerTrackObj.Master_Group_Id__c,listAcc1[0].id);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(True);
        insert listContact;
        listAcc[2].Primary_Contact__c = listContact[0].Id;
        listAcc[3].Primary_Contact__c = listContact[1].Id;
        listAcc[1].Primary_Contact__c = listContact[0].Id;
        update listAcc;
        list<user> listUser=TestDataFactory.createNPortalUser(2);
        insert listUser;
        listContact[0].Partner_User__c = listUser[0].Id;
        listContact[1].Partner_User__c = listUser[1].Id;
        update listContact;
        PageReference pageRef = page.AccountPrimaryContact;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('retUrl', 'http://wwww.google.com'); 
        ApexPages.StandardController acct = new ApexPages.StandardController(listAcc[2]);       
        VFCntrlr_SelectAccountPrimaryContact controller = new VFCntrlr_SelectAccountPrimaryContact(acct);
        VFCntrlr_SelectAccountPrimaryContact.cContact con = new VFCntrlr_SelectAccountPrimaryContact.cContact(listContact[0]);
        controller.doSave();
        controller.doCancel();
        ApexPages.StandardController acct2 = new ApexPages.StandardController(listAcc[3]);       
        VFCntrlr_SelectAccountPrimaryContact controller2 = new VFCntrlr_SelectAccountPrimaryContact(acct2);
        VFCntrlr_SelectAccountPrimaryContact.cContact cn = new VFCntrlr_SelectAccountPrimaryContact.cContact(listContact[0], True);
        controller2.doSave();
        controller2.doCancel();
        ApexPages.currentPage().getParameters().put('selConId', listContact[0].Id);
        ApexPages.StandardController acct3 = new ApexPages.StandardController(listAcc[1]);       
        VFCntrlr_SelectAccountPrimaryContact controller3 = new VFCntrlr_SelectAccountPrimaryContact(acct3);
        VFCntrlr_SelectAccountPrimaryContact.cContact cn2 = new VFCntrlr_SelectAccountPrimaryContact.cContact(listContact[1], True);
        controller2.doSave();
        controller2.doCancel();
        Test.stopTest();
    }
    public static testMethod void testPrimaryContactCreationforEndUserAccount(){
        System.debug('testPrimaryContactCreationforEndUserAccount');
        TriggerExecutionController.setSkipAccountTriggers(true);
        list<Account> listAcc=[SELECT ID FROM Account WHERE RecordType.Name='End-User Account' LIMIT 4];
        List<Contact> listContact = new List<Contact>();
        Contact con1 = new Contact(AccountId = listAcc[0].Id,Email='userUtils'+'@DELLTEAM.com',FirstName = 'John', 
                                   LastName = 'Test User Utils',Status__c = 'Customer',phone = '6739'
                                  );
        listContact.add(con1);
        Contact con2 = new Contact(AccountId = listAcc[1].Id,Email='userUtils1@DELLTEAM.com',FirstName = 'John', 
                                   LastName = 'Test User Utils2',Status__c = 'Customer',phone = '6739'
                                  );
        listContact.add(con2);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(True);
        insert listContact;
        listAcc[2].Primary_Contact__c = listContact[0].Id;
        listAcc[3].Primary_Contact__c = listContact[1].Id;
        listAcc[1].Primary_Contact__c = listContact[0].Id;
        update listAcc;
        list<user> listUser=TestDataFactory.createNPortalUser(2);
        insert listUser;
        listContact[0].Partner_User__c = listUser[0].Id;
        listContact[1].Partner_User__c = listUser[1].Id;
        update listContact;
        system.assertEquals(listUser[0].Id, listContact[0].Partner_User__c);
        PageReference pageRef = page.AccountPrimaryContact;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('retUrl', 'http://wwww.google.com'); 
        ApexPages.StandardController acct = new ApexPages.StandardController(listAcc[2]);       
        VFCntrlr_SelectAccountPrimaryContact controller = new VFCntrlr_SelectAccountPrimaryContact(acct);
        VFCntrlr_SelectAccountPrimaryContact.cContact con = new VFCntrlr_SelectAccountPrimaryContact.cContact(listContact[0]);
        controller.doSave();
        controller.doCancel();
        ApexPages.StandardController acct2 = new ApexPages.StandardController(listAcc[3]);       
        VFCntrlr_SelectAccountPrimaryContact controller2 = new VFCntrlr_SelectAccountPrimaryContact(acct2);
        VFCntrlr_SelectAccountPrimaryContact.cContact cn = new VFCntrlr_SelectAccountPrimaryContact.cContact(listContact[0], True);
        controller2.doSave();
        controller2.doCancel();
        ApexPages.currentPage().getParameters().put('selConId', listContact[0].Id);
        ApexPages.StandardController acct3 = new ApexPages.StandardController(listAcc[1]);       
        VFCntrlr_SelectAccountPrimaryContact controller3 = new VFCntrlr_SelectAccountPrimaryContact(acct3);
        VFCntrlr_SelectAccountPrimaryContact.cContact cn2 = new VFCntrlr_SelectAccountPrimaryContact.cContact(listContact[1], True);
        controller2.doSave();
        controller2.doCancel();
        Test.stopTest();
    }
}