/*
*  Revision                      Name             Date              Description
*                               venugopalachary   15-10-2019        implimented TestDataFactory
*/
@isTest
private class ViewMyPartnerAccountAdminCtrlTest {
    private static Integer intNextUserSerialNumber = -1;
    @testSetup static void setup() {
        // Create common test Account Data
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(2, 'Master Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
    }
    private static Integer getNextUserSerialNumber(){
        intNextUserSerialNumber++;
        return intNextUserSerialNumber;
    }
    private static User createAPartnerUser(Boolean bAdmin){
        List<User> listUser = createPartnerUsers(bAdmin,2);
        System.assert(listUser.size()>=1,'A partner user could not be created therefore this test cannot be executed.');
        return listUser.get(0);
    }
    
    private static List<User> createPartnerUsers(Boolean bAdmin, Integer intMax){
        return createPartnerUsers(bAdmin,intMax,null);
    }
    private static List<User> createPartnerUsers(Boolean bAdmin, Integer intMax, id accountId){
        final List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' limit :intMax];
        System.assert(
            !(partnerProfiles == null || partnerProfiles.size() <= 0), 
            'No partner profiles exist therefore test cannot be executed');
        list<account> listAcc=[select id from Account];
        for(Account acc : listAcc){
            acc.name='AccTest';
            acc.Account_Country_Code__c = 'AI';
            acc.Account_Country__c = 'ANGUILIA';
            acc.IsPartner = true;
        }
        update listAcc;
        final List<Contact> contacts = new List<Contact>();
        for(Integer intI = 0; intI < partnerProfiles.size(); intI++){
            contacts.add(
                new Contact(
                    accountId=(accountId == null ? listAcc.get(intI).id : accountId),
                    Email=''+intI+'@DELLTEAM.com', 
                    FirstName = 'John', 
                    LastName = 'Test'+intI,
                    Title='VP',
                    MailingStreet='123 Main',
                    MailingCity='Peoria',
                    MailingState='IL',
                    MailingPostalCode='33333',
                    Phone='3213213211',
                    MobilePhone='3213213211',
                    Fax='3213123211'
                )
            );
        }
        insert contacts;
        list<user> listusers=TestDataFactory.createNPortalUser(partnerProfiles.size());
        for(user us : listusers){
            for(Integer intI = 0; intI < partnerProfiles.size(); intI++){
                Integer intUserNum = getNextUserSerialNumber();
                us.Username=''+intUserNum+'@DELLTEAM.com';
                us.Alias = 'test'+intUserNum; 
                us.Email=''+intUserNum+'@DELLTEAM.com'; 
                us.FirstName='Jhon';
                us.LastName='Test'+intUserNum; 
                us.ProfileId = partnerProfiles.get(1).Id; 
                us.LanguageLocaleKey='en_US';
                us.LocaleSidKey='en_US';
                us.EmailEncodingKey='UTF-8'; 
                us.TimeZoneSidKey='America/Los_Angeles';
                us.Badge_Number__c=null;
                us.Enable_Partner_Admin__c = bAdmin;
                us.Enable_as_Partner_Group_Administrator__c = bAdmin;
            }
        }
        insert listusers;
        return listusers;
    }   
    
    private static testMethod void contactAdminWithPartnerTracks(){
        TriggerExecutionController.setSkipUserTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        User createUserPartnerAdmin = createAPartnerUser(true);
        Id accountId = [select id,accountId from contact where id=:createUserPartnerAdmin.contactid].accountId;
        system.debug('UserRec:'+createUserPartnerAdmin+'AccRec:'+accountId+'UserIsActive:'+createUserPartnerAdmin.IsActive);
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        list<Account> listAcc1=[SELECT ID,Master_Group_Affinity_Id__c FROM Account WHERE Recordtype.name='Master Account' LIMIT 1];
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
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data2';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = listAcc1[0].id;
        testPartnerTrackObj2.Master_Group_Affinity_Id__c = listAcc1[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj2;
        
        Partner_Track__c testPartnerTrackObj3 = new Partner_Track__c();
        testPartnerTrackObj3.Partner_Track_Name__c = 'Tech Data3';
        testPartnerTrackObj3.Track_Id__c = trackObj.id;
        testPartnerTrackObj3.Master_Group_Id__c = listAcc1[0].id;
        testPartnerTrackObj3.Master_Group_Affinity_Id__c = listAcc1[0].Master_Group_Affinity_Id__c;
        
        insert testPartnerTrackObj3;
        system.assertNotEquals(listAcc1[0].id, null);
        contact updateConEligibleTrack = [select id,EligibleTracks__c,Partner_User__c from contact where id=:createUserPartnerAdmin.contactid];
        updateConEligibleTrack.Partner_User__c = createUserPartnerAdmin.id;
        updateConEligibleTrack.eligibletracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';' + testPartnerTrackObj2.id + ';' + testPartnerTrackObj3.id;
        update updateConEligibleTrack;
        
        System.runAs(createUserPartnerAdmin){
            test.startTest();
            ViewMyPartnerAccountAdminCtrl testConAdmin = new ViewMyPartnerAccountAdminCtrl();
            testConAdmin.getPartnerTracks();
            system.assert(String.isEmpty(testConAdmin.strPartnerTrackId));
            ViewMyPartnerAccountAdminCtrl testConAdmin1 = new ViewMyPartnerAccountAdminCtrl();
            testConAdmin1.getPartnerTracks(); 
            testConAdmin1.strPartnerTrackId = testPartnerTrackObj1.id;
            system.assert(String.isNotEmpty(testConAdmin1.strPartnerTrackId));
            testConAdmin1.getContacts();
            ViewMyEligiblePartnerTracksCtrl ext=new ViewMyEligiblePartnerTracksCtrl();//this is for view myEligiblePartnerTracks
            test.stopTest();
        }
        TriggerExecutionController.setSkipContactTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipUserTriggers(false);
    }
}