/*
REVISION HISTORY
================
Version        Author                Date          Release#         CR#                         Description
-------    ----------------       -----------     ------------     --------                    --------------       
1.0         Yeswanth Ravilla       01-Nov-2018     FY-19 0102       16746               Test Class for Vfcntrl_ManageMyRewardsPage
2.0			VIKAS KH			   04-Dec-2019	   0102									Implemented TDF
*/
@isTest
public class Vfcntrl_ManageMyRewardsPageTest {
    static Partner_track__c testPartnerTrackObj= new Partner_track__c ();     
    static User  partnerUser = new User();
    static User  partnerUserAdmin = new User();
    static Contact partnerContact = new COntact();
    static Contact partnerContactAdmin = new COntact();
    static List<Contact> listcon = new List<Contact>();
    static list<Account> listAcc;
    static list<user> listuser;
    @testsetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<User> listUserTDF = TestDataFactory.createNPortalUser(2);
        insert listuserTDF;
        
    }    
    static void createData(){
        profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1]; 
        listAcc = [select id,name,Account_Country_Code__c,Account_Country__c,Type, IsPartner from Account];
        listAcc[0].name='PartnerAccount';
        listAcc[0].Account_Country_Code__c='AI';
        listAcc[0].Account_Country__c = 'ANGUILLA';
        listAcc[0].Type = 'Partner'; 
        listAcc[0].IsPartner = true;
        update listAcc;
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c= 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj.MyRewards_Company_Status__c='Opted In';
        insert testPartnerTrackObj;
        partnerContact.AccountId=listAcc[0].id;
        partnerContact.Email='John.Doe@dell.com';
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title='VP';
        partnerContact.Selected_Track__c=testPartnerTrackObj.id;
        partnerContact.MailingStreet='123Main';
        partnerContact.MailingCity='Peoria';
        partnerContact.MailingState='IL';
        partnerContact.MailingPostalCode='33333';
        partnerContact.Phone='3213213211';
        partnerContact.MobilePhone='3213213211';
        partnerContact.Fax='3213123211' ;
        partnerContact.Is_Enabled_for_Incentives__c=true;
        listcon.add(partnerContact);
        partnerContactAdmin.AccountId=listAcc[0].id;
        partnerContactAdmin.Email='John.Doe@dell.com';
        partnerContactAdmin.FirstName = 'John';
        partnerContactAdmin.LastName = 'Doe';
        partnerContactAdmin.Title='VP';
        partnerContactAdmin.MailingStreet='123Main';
        partnerContactAdmin.MailingCity='Peoria';
        partnerContactAdmin.MailingState='IL';
        partnerContactAdmin.MailingPostalCode='33333';
        partnerContactAdmin.Phone='3213213211';
        partnerContactAdmin.MobilePhone='3213213211';
        partnerContactAdmin.Fax='3213123211' ;
        partnerContactAdmin.Is_Enabled_for_Incentives__c=true;
        listcon.add(partnerContactAdmin);  
        insert listcon;
        /*      List<User> listuser = new List<User>();
String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit.user';
partnerUser.Username=strusername;
partnerUser.Alias = 'test';
partnerUser.Email='testuser@dell.com';
partnerUser.FirstName='John'; 
partnerUser.LastName='Doe'; 
partnerUser.ProfileId =profileRec.Id; 
partnerUser.LanguageLocaleKey='en_US'; 
partnerUser.LocaleSidKey='en_US';
partnerUser.EmailEncodingKey='UTF-8';
partnerUser.TimeZoneSidKey='America/Los_Angeles';
partnerUser.Badge_Number__c=null;
partnerUser.ContactId=partnerContact.id;
partnerUser.Enable_Partner_Admin__c =false;
partnerUser.CommunityNickname='sri236';
listuser.add(partnerUser);
strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit.admin';
partnerUserAdmin.Username=strusername;
partnerUserAdmin.Alias = 'test';
partnerUserAdmin.Email='testuser@test.com';
partnerUserAdmin.FirstName='John'; 
partnerUserAdmin.LastName='Doe'; 
partnerUserAdmin.ProfileId =profileRec.Id; 
partnerUserAdmin.LanguageLocaleKey='en_US'; 
partnerUserAdmin.LocaleSidKey='en_US';
partnerUserAdmin.EmailEncodingKey='UTF-8';
partnerUserAdmin.TimeZoneSidKey='America/Los_Angeles';
partnerUserAdmin.Badge_Number__c=null;
partnerUserAdmin.ContactId=partnerContactAdmin.id;
partnerUserAdmin.Enable_Partner_Admin__c =true;
partnerUser.CommunityNickname='sri249';
listuser.add(partnerUserAdmin);
insert listuser;*/
        listuser = [select id from user limit 2];
    }
    static testmethod void testPartnerMethod(){
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();  
        Test.startTest();  
        system.runAs(listUser[0]){
            Vfcntrl_ManageMyRewardsPage controller;         
            controller = new Vfcntrl_ManageMyRewardsPage();
            system.assertEquals(false, controller.bisPartnerAdmin );
        }
        system.runAs(listUser[1]){
            Vfcntrl_ManageMyRewardsPage controller;         
            controller = new Vfcntrl_ManageMyRewardsPage();
            system.assertEquals(false, controller.bisPartnerAdmin);
        }
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);      
    }
    static testMethod void testPermittedUserLoggedIn() {
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();       
        List<Id> listpermittedProfileIds = new List<Id>();
        listpermittedProfileIds.add('00e30000000nJ6K'); // System Administrator
        listpermittedProfileIds.add('00e70000000wzqq'); // GBL PRM Operations
        listpermittedProfileIds.add('00e70000000x0Xj'); // GBL PRM Operations - non SSO
        listpermittedProfileIds.add('00eA0000000hOpn'); // GBL PRM Certification Admin
        listpermittedProfileIds.add('00eA0000000hOps'); // GBL PRM Certification Admin - Non SSO
        listpermittedProfileIds.add('00eA0000000hORl'); // GBL PRM Operations Admin
        listpermittedProfileIds.add('00eA0000000hORq'); // GBL PRM Operations Admin - Non SSO
        Test.startTest();
        List<User> listuserRec = new List<User>();
        string strusername = null;
        for(Integer inti = 0; inti < listpermittedProfileIds.size(); inti++){    
            strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit' + string.valueOf(inti);       
            listuserRec.add(
                new User(Username=strusername, Alias = 'test'+inti, Email='testuser'+inti+'@dell.com', FirstName='John', LastName='Doe'+inti, 
                         ProfileId =listpermittedProfileIds[inti], LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', 
                         TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='John.doe'+inti)
            );
        }
        insert listuserRec;
        listAcc = [select id,name,Account_Country_Code__c,Account_Country__c,Type, IsPartner from Account];
        Vfcntrl_ManageMyRewardsPage controller;        
        for(Integer inti = 0; inti < listpermittedProfileIds.size(); inti++){
            system.runAs(listuserRec[inti]){
                ApexPages.currentPage().getParameters().put('accountId', listAcc[0].Id); 
                controller = new Vfcntrl_ManageMyRewardsPage();
                system.assertEquals(false, controller.bisPartnerAdmin);
                system.assertEquals(true, controller.isPermittedUser);
            }
        }
        for(Integer inti = 0; inti < listpermittedProfileIds.size(); inti++){
            system.runAs(listuserRec[inti]){
                controller = new Vfcntrl_ManageMyRewardsPage();
                system.assertEquals(false, controller.bisPartnerAdmin);
                system.assertEquals(true, controller.isPermittedUser);
            }
        }
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testmethod void testonLoadMethod(){
        TriggerExecutionController.setSkipAllTriggers(true);
        profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1];
        listAcc = [select id,name,Account_Country_Code__c,Account_Country__c,Type, IsPartner from Account];
        listAcc[0].name='PartnerAccount';
        listAcc[0].Account_Country_Code__c='AI';
        listAcc[0].Account_Country__c = 'ANGUILLA';
        listAcc[0].Type = 'Partner'; 
        listAcc[0].IsPartner = true;
        update listAcc;
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c= 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj.MyRewards_Company_Status__c='Opted In';
        insert testPartnerTrackObj;
        partnerContact.AccountId=listAcc[0].id;
        partnerContact.Email='John.Doe@dell.com';
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title='VP';
        partnerContact.Selected_Track__c=testPartnerTrackObj.id;
        partnerContact.MailingStreet='123Main';
        partnerContact.MailingCity='Peoria';
        partnerContact.MailingState='IL';
        partnerContact.MailingPostalCode='33333';
        partnerContact.Phone='3213213211';
        partnerContact.MobilePhone='3213213211';
        partnerContact.Fax='3213123211' ;
        partnerContact.Is_Enabled_for_Incentives__c=true;
        listcon.add(partnerContact);
        partnerContactAdmin.AccountId=listAcc[0].id;
        partnerContactAdmin.Email='John.Doe@dell.com';
        partnerContactAdmin.FirstName = 'John';
        partnerContactAdmin.LastName = 'Doe';
        partnerContactAdmin.Title='VP';
        partnerContactAdmin.MailingStreet='123Main';
        partnerContactAdmin.MailingCity='Peoria';
        partnerContactAdmin.MailingState='IL';
        partnerContactAdmin.MailingPostalCode='33333';
        partnerContactAdmin.Phone='3213213211';
        partnerContactAdmin.MobilePhone='3213213211';
        partnerContactAdmin.Fax='3213123211' ;
        partnerContactAdmin.Is_Enabled_for_Incentives__c=true;
        listcon.add(partnerContactAdmin);  
        insert listcon;
        /*     List<User> listuser = new List<User>();
String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit.user';
partnerUser.Username=strusername;
partnerUser.Alias = 'test';
partnerUser.Email='testuser@dell.com';
partnerUser.FirstName='John'; 
partnerUser.LastName='Doe'; 
partnerUser.ProfileId =profileRec.Id; 
partnerUser.LanguageLocaleKey='en_US'; 
partnerUser.LocaleSidKey='en_US';
partnerUser.EmailEncodingKey='UTF-8';
partnerUser.TimeZoneSidKey='America/Los_Angeles';
partnerUser.Badge_Number__c=null;
partnerUser.ContactId=partnerContact.id;
partnerUser.Enable_Partner_Admin__c =false;
partnerUser.CommunityNickname='sri236';
listuser.add(partnerUser);
strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit.admin';
partnerUserAdmin.Username=strusername;
partnerUserAdmin.Alias = 'test';
partnerUserAdmin.Email='testuser@test.com';
partnerUserAdmin.FirstName='John'; 
partnerUserAdmin.LastName='Doe'; 
partnerUserAdmin.ProfileId =profileRec.Id; 
partnerUserAdmin.LanguageLocaleKey='en_US'; 
partnerUserAdmin.LocaleSidKey='en_US';
partnerUserAdmin.EmailEncodingKey='UTF-8';
partnerUserAdmin.TimeZoneSidKey='America/Los_Angeles';
partnerUserAdmin.Badge_Number__c=null;
partnerUserAdmin.ContactId=partnerContactAdmin.id;
partnerUserAdmin.Enable_Partner_Admin__c =true;
partnerUser.CommunityNickname='sri249';
listuser.add(partnerUserAdmin);
insert listuser; */
        listuser = [select id from user limit 2];
        Test.startTest();  
        system.assertEquals(testPartnerTrackObj.Master_Group_Id__c,listAcc[0].id);
        System.runAs(listUser[0]){
            Vfcntrl_ManageMyRewardsPage.OnLoadMethodCtrl(listAcc[0].Id,testPartnerTrackObj.id);
            Vfcntrl_ManageMyRewardsPage.saveContacts(listcon);
            Vfcntrl_ManageMyRewardsPage.updateCompanyStatusCtrlPT(testPartnerTrackObj.id,'Opted In');
            Vfcntrl_ManageMyRewardsPage.updateCompanyStatusCtrl(listAcc[0].Id,'Opted In');
            Vfcntrl_ManageMyRewardsPage.fetchContacts(listAcc[0].Id,null,null,null,null,'yes','yes');
        }
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);      
    }  
}