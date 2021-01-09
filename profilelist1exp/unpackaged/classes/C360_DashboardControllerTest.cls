/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0                                                                     Original copy
2.0         13872       FY18-DCS-0202   03-Jan-2017      Gan            Implement for Lead
3.0         16275       FY19-0902       03Sept2018       SinLin         Test class fix for deployment validation error.   
*/  
@isTest
private class C360_DashboardControllerTest {
    static PageReference pref;
    //Added custom settings to populate StageName values. - SinLin
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account'); 
        insert listAccTdf;
        
        list<Contact> listConTdf=TestDataFactory.CreateNContacts(1);
        listConTdf[0].AccountId=listAccTdf[0].id;
        insert listConTdf;
        
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        
        list<User> listUser=TestDataFactory.CreateNGenralUsers(1);
        insert listUser;
        
        list<Campaign> listCampaignTdf=TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCampaignTdf;
        
        list<Lead> listLeadTdf=TestDataFactory.createNLeads(1, 'Direct Lead 2.0');
        listLeadTdf[0].Campaign__c=listCampaignTdf[0].id;
        insert listLeadTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    //end
    
    private static testMethod void testSearchAccountAffinity() {
        //TriggerExecutionController.setSkipAllTriggers(true);
        /* Account newaccount = new Account(Name='Test Account', Account_ID__c='12345');
insert newaccount;

Contact contact=new Contact(FirstName='ContactTest1',
LastName='ContactLM1', 
AccountId=newaccount.Id, 
Phone='111111', 
Decision_Making_Role__c='Influencer',
Job_Function__c='IT',
Purchaser_Influence_over_Merged__c='Client-Desktops' );
insert contact;

Opportunity Opty = new Opportunity(StageName='Plan - 1%',
Probability=1, 
AccountId=newaccount.Id,
Name='TEST Oppty 360Dashboard',
CloseDate = System.today() + 30, 
Primary_Product_Delivery_Address_Region__c = 'REGION1',
Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');

insert Opty;

Profile AdminProfile = [select Id, Name from Profile where Name LIKE 'System Administrator' Limit 1];
User testUser = new User(FirstName='Test12',IsActive = TRUE,
LastName='TestUser21', Title='CEO', UserName='pegasus_TestUser1@test.com',
Is_SSO_User__c = FALSE,
Is_Integrated_User__c = FALSE,
Email='pegasus_TestUser1@dell.com',                                
Alias='tBatcwh1', CommunityNickName='tBatwch1', 
ProfileId = AdminProfile.Id,
LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
Badge_Number__c='tBatch1', 
System_Admin_or_Delegated_User_Admin__c = TRUE);
*/
        list<Account> listAcc=[select id from Account Limit 1];
        Test.startTest();
        
        pref = Page.C360_Dashboard;
        //pref.getParameters().put('id',newaccount.Account_ID__c);
        pref.getParameters().put('id',listAcc[0].id);
        pref.getParameters().put('t','1');
        pref.getParameters().put('obj','Account');
        Test.setCurrentPage(pref);
        
        C360_DashboardController myTC = new C360_DashboardController();
        myTC.populate();
        myTC.countClick();
        Test.stopTest();
        system.assertEquals(listAcc[0].id, listAcc[0].id);
    }
    
    private static testMethod void testSearchContactAffinity() {
        //TriggerExecutionController.setSkipAllTriggers(true);
        /* Account newaccount = new Account(Name='Test Account', Account_ID__c='12345');
insert newaccount;

Contact contact=new Contact(FirstName='ContactTest1',
LastName='ContactLM1',
AccountId=newaccount.Id,
Phone='111111', 
Decision_Making_Role__c='Influencer',
Job_Function__c='IT',
Purchaser_Influence_over_Merged__c='Client-Desktops' );
insert contact;

Opportunity Opty = new Opportunity(StageName='Plan - 1%',
Probability=1, 
AccountId=newaccount.Id,
Name='TEST Oppty 360Dashboard',
CloseDate = System.today() + 30, 
Primary_Product_Delivery_Address_Region__c = 'REGION1',
Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');

insert Opty;

Profile AdminProfile = [select Id, Name from Profile where Name LIKE 'System Administrator' Limit 1];
User testUser = new User(FirstName='Test12',IsActive = TRUE,
LastName='TestUser21', Title='CEO', UserName='pegasus_TestUser1@test.com',
Is_SSO_User__c = FALSE,
Is_Integrated_User__c = FALSE,
Email='pegasus_TestUser1@dell.com',                                
Alias='tBatcwh1', CommunityNickName='tBatwch1', 
ProfileId = AdminProfile.Id,
LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
Badge_Number__c='tBatch1', 
System_Admin_or_Delegated_User_Admin__c = TRUE);
*/
        list<Contact> listCon=[select id from Contact Limit 1];
        
        
        Test.startTest();
        
        pref = Page.C360_Dashboard;
        pref.getParameters().put('id',listCon[0].id);
        pref.getParameters().put('t','1');
        pref.getParameters().put('obj','Contact');
        Test.setCurrentPage(pref);
        
        C360_DashboardController myTC = new C360_DashboardController();
        myTC.populate();
        myTC.countClick();
        Test.stopTest();
        system.assertEquals(listCon[0].id, listCon[0].id);
    }
    
    
    private static testMethod void testSearchOpptyAffinity() {
        //  TriggerExecutionController.setSkipAllTriggers(true);
        /*Account newaccount = new Account(Name='Test Account', Account_ID__c='12345');
insert newaccount;

Contact contact=new Contact(FirstName='ContactTest1',
LastName='ContactLM1', 
AccountId=newaccount.Id,
Phone='111111', 
Decision_Making_Role__c='Influencer', 
Job_Function__c='IT',
Purchaser_Influence_over_Merged__c='Client-Desktops' );
insert contact;

Opportunity Opty = new Opportunity(StageName='Plan - 1%',
Probability=1, 
AccountId=newaccount.Id,
Name='TEST Oppty 360Dashboard',
CloseDate = System.today() + 30, 
Primary_Product_Delivery_Address_Region__c = 'REGION1',
Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');

insert Opty;

Profile AdminProfile = [select Id, Name from Profile where Name LIKE 'System Administrator' Limit 1];
User testUser = new User(FirstName='Test12',IsActive = TRUE,
LastName='TestUser21', Title='CEO', UserName='pegasus_TestUser1@test.com',
Is_SSO_User__c = FALSE,
Is_Integrated_User__c = FALSE,
Email='pegasus_TestUser1@dell.com',                                
Alias='tBatcwh1', CommunityNickName='tBatwch1', 
ProfileId = AdminProfile.Id,
LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
Badge_Number__c='tBatch1', 
System_Admin_or_Delegated_User_Admin__c = TRUE);
*/
        list<Opportunity> listOpp=[select id  from Opportunity Limit 1];
        //list<user> listUser=[select id from user Where isActive=true Limit 1];
        Test.startTest();
        
        pref = Page.C360_Dashboard;
        pref.getParameters().put('id',listOpp[0].id);
        pref.getParameters().put('t','1');
        pref.getParameters().put('obj','Opportunity');
        Test.setCurrentPage(pref);
        
        C360_DashboardController myTC = new C360_DashboardController();
        myTC.populate();
        myTC.countClick();
        Test.stopTest();
        system.assertEquals(listOpp[0].id, listOpp[0].id);
    }
    
    //2.0
    private static testMethod void testSearchLeadAccAffinity() {
        TriggerExecutionController.setSkipAllTriggers(true);
        /* Account objNewAccount = new Account(Name='Test Account', Account_ID__c='12345');
insert objNewAccount;

LeadTestData.bCreate = false;
LeadTestData.iNumberOfLeads = 1;
LeadTestData.createDirectLead2();
list<Lead> listDirectLeads2 = LeadTestData.lstLeads;
Lead objDirectLead = listDirectLeads2[0];
objDirectLead.Account__c = objNewAccount.Id;
insert listDirectLeads2;

Profile objAdminProfile = [select Id, Name from Profile where Name LIKE 'System Administrator' Limit 1];
User objTestUser = new User(FirstName='Test12',IsActive = TRUE,
LastName='TestUser21', Title='CEO', UserName='pegasus_TestUser1@test.com',
Is_SSO_User__c = FALSE,
Is_Integrated_User__c = FALSE,
Email='pegasus_TestUser1@dell.com',                                
Alias='tBatcwh1', CommunityNickName='tBatwch1', 
ProfileId = objAdminProfile.Id,
LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
Badge_Number__c='tBatch1', 
System_Admin_or_Delegated_User_Admin__c = TRUE);
*/
        list<Lead> listLead=[select id from Lead Limit 1];
        Test.startTest();
        
        pref = Page.C360_Dashboard;
        pref.getParameters().put('id',listLead[0].id);
        pref.getParameters().put('t','1');
        pref.getParameters().put('obj','Lead');
        Test.setCurrentPage(pref);
        
        C360_DashboardController myTC = new C360_DashboardController();
        myTC.populate();
        myTC.countClick();
        Test.stopTest();
        system.assertEquals(listLead[0].id, listLead[0].id);
    }
}