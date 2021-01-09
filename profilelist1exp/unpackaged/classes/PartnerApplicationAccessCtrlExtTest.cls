/***********************************************************
* Name      : PartnerApplicationAccessCtrlExt 
* Description  : Test class for PartnerApplicationAccess 
* ---------------------------------------------------------
* Revision      Name    Date            CR Number   Release No      Description
* 1.0           MenMee  21.12.2009                                  Test Class for PartnerApplicationCtrlExt    
* 2.0           Ray     01-01-2010                                  Included test methods for CR2186
* 3.0           MenMee  20.01.2010                                  API name changed
* 4.0           Ray     02.02.2010                                  Modified for defect #55487s
* 5.0           Ariff   17.12.2012                                  Modified for R14.2 SSO PRojec
* 6.0           Bikram  14.01.2013                                  Removed field Is Country Enabled for Incentives R14.2 SSO 
* 7.0           Fenny   10-Jan-2013                                 CR7944 - test doPermissionSetAssignment()
* 8.0           Meera   3-March-2014                                Restructured the test data creation to avoid SOQL limit exception and updated test methods to include 15.03 CMAP lead management changes
* 9.0           Ragu    04-Mar-2015                                 Avoid test case failures due to newly introduced validation validateTrainingEnabled()
* 10.1          Michael 07-June-18       16007     FY19-DCS-0802    Decommisioned Provisioned_in_Netexam_on__c as Part of Story# 4988554 
* 10.2          Pallavi 07-June-18       16000     FY19-DCS-0802    commented netExamAccess and isTrainingEnabled variable as part of NET Exam Decommissioning 
* 11.1          Vasavi.M 19th-Apr-19     17388     FY20-DCE-0802    Coverae for ISG changes - Include 4 new attributes for quote & order creation
***************************
********************************/

@isTest
private class PartnerApplicationAccessCtrlExtTest {
  
  static final String REQUEST_RECORD_TYPE_NEW_PARTNER = 'New Partner';
  
  static Contact testContact;
  static Contact testContact2;
  static Contact testContact3;
  static Contact testContactInvalidUser;
  static User testUser;
  static Account testAcc;
  static Country__c testCountry;
  static Sales_Channel_Group__c testSalesChanGrp;

  static testMethod void doSaveTest_ManageAppAccess() {
    System.debug('***************** START doSaveTest_ManageAppAccess *****************');
    
    testDataCreation();
    
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContact.Id);
    Test.setCurrentPage(pageRef);
                     
    Test.startTest();
    //
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;
    //
    
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContact);
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);
    
    // Grant access to all apps
    testContact.Campaign_Builder__c = true;     //Rev 3.0
    testContact.Premier_Partner__c = true;
    testContact.Transactional_Store__c = true;  //Rev 3.0
    testContact.Warranty_parts_Info__c = true;  //Rev 3.0  
    testContact.Is_Rebate_User__c = true;
    //controller.netExamAccess = false; // Do not test NetExam here because Testmethods do not support webservice callouts.
    //controller.isTrainingEnabled = false; // v9.0 - To continue the save operation
    controller.userRecord.Enable_Partner_Admin__c = true;
    controller.userRecord.Enable_Partner_Deal_Registration__c = true;
    controller.userRecord.Enable_Partner_Lead_Management__c = true;

    User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
    
    System.runAs(adminusr) { 
        CMAP_Helper.skipinsert = true;      
        controller.doSave();
    }
    
    
    //Rev 3.0
    Contact actualContact = [SELECT Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, 
                  Warranty_parts_Info__c, Is_Rebate_User__c
                 FROM Contact
                 WHERE Id = :testContact.Id];  
    
    User actualUser = [SELECT Enable_Partner_Admin__c, Enable_Partner_Deal_Registration__c,Enable_Partner_Lead_Management__c
             FROM User 
             WHERE ContactId = :testContact.Id];
    
    System.assertEquals(true, actualContact.Campaign_Builder__c);
    System.assertEquals(true, actualContact.Premier_Partner__c);
    System.assertEquals(true, actualContact.Transactional_Store__c);
    System.assertEquals(true, actualContact.Warranty_parts_Info__c);
    System.assertEquals(true, actualContact.Is_Rebate_User__c);
    System.assertEquals(true, actualUser.Enable_Partner_Admin__c);
    System.assertEquals(true, actualUser.Enable_Partner_Deal_Registration__c);
    System.assertEquals(true, actualUser.Enable_Partner_Lead_Management__c);
    //System.assertEquals(true, controller.isalowedLeadMAnagement);
    
    System.debug('***************** END doSaveTest_ManageAppAccess *****************');
    Test.stopTest();
  }
    

 /*static testMethod void doSaveTest_InvokeNetExam() {
    System.debug('***************** START doSaveTest_InvokeNetExam *****************');

    string actualURL;
            
    testDataCreation();
    
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContact.Id);
    Test.setCurrentPage(pageRef);
                     
    Test.startTest();
    
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContact);
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);

   // controller.netExamAccess = true; //Commented as part of NET Exam decommissioning
    
    try {    
      actualURL = controller.doSave().getURL();  
    }
    catch (Exception e) {
      // do nothing
    }
    Test.stopTest();
    
    System.assertEquals(null, actualURL);
    
    System.debug('***************** END doSaveTest_InvokeNetExam *****************');
  }*/
  
  static testMethod void doSaveTest_TestInvalidRecordID() {
    System.debug('***************** START doSaveTest_TestInvalidRecordID *****************');

    string actualURL;
            
    testDataCreation();
    Test.startTest();
    //
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;
    //
    createtestContact3();
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContact3.Id);
    Test.setCurrentPage(pageRef);
                     
    
    
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContact3);
    delete testContact3;
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);
        
    Test.stopTest();
    
    System.assertEquals('Could not find a valid Contact record', controller.errorMessage);
    
    System.debug('***************** END doSaveTest_TestInvalidRecordID *****************');
  }
  
  static testMethod void doBackTest_BackToDetailPage() {
    System.debug('***************** START doBackTest_BackToDetailPage *****************');
    
    testDataCreation();
    
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContact.Id);
    Test.setCurrentPage(pageRef);
      
    Test.startTest();
    //
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;
    //
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContact);
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);    
    
    String actualURL = controller.doBack().getURL();
    
    Test.stopTest();
    
    System.assertEquals('/'+testContact.Id, actualURL);
    
    System.debug('*****************END doBackTest_BackToDetailPage *****************');        
  }

  static testMethod void YesOrNoTest() {
    System.debug('***************** START YesOrNoTest *****************');

    TestDataCreation();
    //
    Test.startTest();
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;
    //
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContact.Id);
    Test.setCurrentPage(pageRef);
      
    //Test.startTest();
    
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContact);
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);    
    
    List<SelectOption> actualSO = controller.YesOrNo;
    
    Test.stopTest();
  
    System.assertEquals('Yes', actualSO.get(0).getLabel());
    System.assertEquals('No', actualSO.get(1).getLabel());
    
    System.debug('***************** END YesOrNoTest *****************');      
  }
  
  static TestMethod void testContactWithNoUser() {
    System.debug('***************** START testContactWithNoUser *****************');
    
    TestDataCreation();
    Test.startTest();
    //
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;
    //
    createtestContact3();
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContact3.Id);
    Test.setCurrentPage(pageRef);
      
    
    
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContact3);
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);      
      
    Test.stopTest();
    system.debug('##DEBUG## ' + controller.errorMessage);
    System.assert(controller.errorMessage.contains('Failed to retrieve user record for this contact'));
    
    System.debug('***************** END testContactWithNoUser *****************');  
    
  }
  
  static TestMethod void testContactWithInactiveUser() {
    System.debug('***************** START testContactWithInactiveUser *****************');
    
    TestDataCreation();
    
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContact.Id);
    Test.setCurrentPage(pageRef);
      
    Test.startTest();
    //
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;
    //
    User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
    
    System.runAs(adminusr) {  
        testUser.IsActive = false;
        update testUser;
    }
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContact);
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);            
      
    Test.stopTest();
    system.debug('##DEBUG## ' + controller.errorMessage);
    System.assert(controller.errorMessage.contains('Application access data cannot be edited for inactive users'));
    
    System.debug('***************** END testContactWithInactiveUser *****************');  
    
  }
  
  static TestMethod void testContactWithDisabledUser() {
    System.debug('***************** START testContactWithDisabledUser *****************');
    
    TestDataCreation();
        
    Test.startTest();
    //
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;
    //
    //10.2 skip trigger as prod build fail
    TriggerExecutionController.setSkipContactTriggers(true);
    createtestContactInvalidUser();  
    TriggerExecutionController.setSkipContactTriggers(false);
    //createtestContact2();
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContactInvalidUser.Id);
    Test.setCurrentPage(pageRef);
    
    //system.debug('##DEBUG## ' + testContact2.Partner_My_Account_GUID__c);
    
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContactInvalidUser);
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);      
    
    User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
    system.debug(adminusr);
    System.runAs(adminusr) {    
        testUser.username = '_' + testUser.username;
        //10.2 skip trigger as prod build fail
        TriggerExecutionController.setSkipUserTriggers(true);
        update testuser;
        TriggerExecutionController.setSkipUserTriggers(false);
      
    //system.debug('##DEBUG## ' + controller.isDisabledUser);
    //system.debug('##DEBUG## ' + controller.userRecord);
    //system.debug('##DEBUG## ' + controller.errorMessage);
    //system.debug('##DEBUG## ' + controller.contactRecord);
    //system.debug('##DEBUG## ' + controller.contactrecord.Partner_My_Account_GUID__c);
    //system.debug('##DEBUG## ' + [select username from User where username like '_%testvalid%'].Id);
    System.assert(controller.isDisabledUser);
        
        controller.disablePartnerUserFromTest(testUser.Id, testContactInvalidUser.Id);
    }
    //system.assert(controller.contactrecord.Partner_My_Account_GUID__c == null);
    system.assert(controller.userRecord.Enable_Partner_Admin__c == false);
    system.assert(controller.userRecord.Enable_Partner_Deal_Registration__c == false);
    system.assert(controller.contactRecord.Campaign_Builder__c == false);
    system.assert(controller.contactRecord.Premier_Partner__c == false);
    system.assert(controller.contactRecord.Transactional_Store__c == false);
    system.assert(controller.contactRecord.Warranty_parts_Info__c == false);
    system.assert(controller.contactRecord.Is_Rebate_User__c == false);
    //system.assert(controller.contactRecord.Partner_My_Account_GUID__c == null);
    //system.assert(controller.netExamAccess == false); //Commented as part
        
    controller.syncToPartnerProfileDB();   
    Test.stopTest();
    
    
    
    System.debug('***************** END testContactWithDisabledUser *****************');  
    
  }
  
  //Added by Bahar, Ariff (20121217) 14.2 SSO Project - Start

  static TestMethod void testEnableForIncentivesDisable(){
    string actualURL;
            
    testDataCreation();
    
    Test.startTest();
    //
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;
    //
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContact.Id);
    Test.setCurrentPage(pageRef);
                   
        
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContact);
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);
    
    System.assertEquals(false,controller.visibleIncentive);
  
    Test.stopTest();
  }
  
  
  static TestMethod void testEnableForIncentivesEnable(){
            
    testDataCreation();
    
    Test.startTest();
    //
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;
    //
    Id accountid = [select accountid from contact where id = :testContact.id].accountID;
    account accountObject = [select Is_Enabled_for_Incentives__c ,Account_Country_Code__c from account where id = :accountid];
    accountObject.Is_Enabled_for_Incentives__c=true;
    accountObject.Vendor_Update_Datetime__c = system.today();
    update accountObject;
    
    PartnerCountry pc = new PartnerCountry();
    Map<string, Country__c> countryMap = pc.returnCountryCodeMap();
    Country__c countryObject = countryMap.get(StringUtils.uppercase((accountObject.Account_Country_Code__c).trim()));
       
    countryObject.Inc_Vendor_Name__c = 'Partner Advantage';
    countryObject.Inc_Vendor_End_Point__c = 'Service End Point BI EU';
       
    update countryObject;
    
    
    
    PageReference pageRef = Page.PartnerApplicationAccess;
    ApexPages.currentPage().getParameters().put('Id', testContact.Id);
    Test.setCurrentPage(pageRef);
    
    ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(testContact);
    PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);
    
    System.assertEquals(true,controller.visibleIncentive);
  
    Test.stopTest();
  }
  
  //- END
  
    
  static void TestDataCreation() {        
        
          
        testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        
  
        
        
        insert testCountry;
        testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
        testAcc.IsPartner = true;
        update testAcc;
        
        testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
    insert testContact; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    /*Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id);
        insert testUser;*/
               
        
    
    
    
  }
  
  //V11.1 Start
  static void testDataCreationPartnerAccount() {      
                  
        testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
      
        insert testCountry;
        testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp; 
        
        Id partnerRTId = StaticFactory.getRecordTypeIdByName('Account', 'Partner Account');                     
        testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c,RecordTypeId = partnerRTId, Type = 'Partner', Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
  }
  //V11.1 End
  //Fix For Validation Issue on Contact Object for Partner account record type
    static void testDataCreationMasterAccount() {      
                  
        testCountry = new Country__c (name = 'TESCOUNTRYMaster', Code__c = 'T67', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
      
        insert testCountry;
        testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp; 
        
        Id masterRTId = StaticFactory.getRecordTypeIdByName('Account', 'Master Account');                     
        testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c,RecordTypeId = masterRTId, Type = 'Master Group', Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
    }
  
  
    static void createtestContactInvalidUser() {
    
    //test contact which user has been disabled
      Account objtestAccInvalid = new Account(name = 'testAccountInvalid'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
      TriggerExecutionController.setSkipAccountTriggers(true);
      insert objtestAccInvalid;
      TriggerExecutionController.setSkipAccountTriggers(false);
      testContactInvalidUser = new Contact(Status__c='Active', AccountId=objtestAccInvalid.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                           Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                           Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact', Partner_My_Account_GUID__c='testvaliduser');
      insert testContactInvalidUser; 
    }
  //Meera: Updated method to remove too many SOQL exception
  static void createtestContact2() {
    
    //test contact which user has been disabled
        testContact2 = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact', Partner_My_Account_GUID__c='testvaliduser');
    insert testContact2; 
  }
  static void createtestContact3() {
      
      //test contact which doesn't have any matching user
      Account testAcc1;
      testAcc1 = new Account(name = 'testAccount1'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
      insert testAcc1;
      
      testContact3 = new Contact(Status__c='Active', AccountId=testAcc1.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                 Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                 Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact2', Partner_My_Account_GUID__c='Test3notexist');
      insert testContact3; 
  }
    // 7.0 - CR7944
    static testmethod void test_doPermissionSetAssignment(){
        
        //skip all triggers on creation of account and opportunity
        TriggerExecutionController.setSkipAllTriggers(true);
        
        //V11.1 test data method call
        //testDataCreationPartnerAccount();
        //Added to resolve contact validation rule name:Partner_Account_validation_Check
        testDataCreationMasterAccount();
        Id masterRTId = StaticFactory.getRecordTypeIdByName('Account', 'Master Account');                     
        list<Account> lstAccounts = [SELECT Id FROM Account WHERE Type = 'Master Group' AND RecordTypeId = :masterRTId LIMIT 1];
        //system.debug('lstAccounts-->'+lstAccounts);
        if(lstAccounts != null && !lstAccounts.isEmpty()) {
            Account acc = lstAccounts[0];
            Contact con = new Contact(AccountId = acc.id,Email = '1_2@dell.com',FirstName = 'fn' ,LastName = 'ln' ,Title = 'King',MailingStreet = '123Main',MailingCity = 'Peoria',
                                MailingState = 'IL',MailingPostalCode = '33333',Phone = '3213213211',MobilePhone = '3213213211',Fax = '3213123211');
            
            insert con;            
            
            
            Profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1]; 
    
            String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit.user';
            User  usr = new User(Username = username,Alias = 'test',Email = 'testuser@dell.com',FirstName = 'John',LastName = 'Doe',ProfileId = profileRec.Id,
                                LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',TimeZoneSidKey = 'America/Los_Angeles',
                                Badge_Number__c = null, ContactId = con.Id, Enable_Partner_Admin__c = false);
            insert usr;
                        
            Test.startTest();
            PageReference pageRef = Page.PartnerApplicationAccess;
            ApexPages.currentPage().getParameters().put('Id', con.Id);
            Test.setCurrentPage(pageRef);
                        
            ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(con);
            PartnerApplicationAccessCtrlExt controller = new PartnerApplicationAccessCtrlExt(stdCtl);     
             
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Partner_Opportunity_Access'];
            User sa = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND Id <> :UserInfo.getUserId()][0];
                        
            controller.userRecord.Enable_Partner_Deal_Registration__c = true;
           // controller.isTrainingEnabled = false; // v9.0 - To continue the save operation
            system.runAs(sa){
                controller.doPermissionSetAssignment();
                
                List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usr.Id and PermissionSetId = :permSet.Id];
                
                system.assertEquals(true, ((assignments != null) && (assignments.size() > 0)));
                system.assertEquals(true, (assignments.size() == 1));
            }
            
            controller.userRecord.Enable_Partner_Deal_Registration__c = false;
            system.runAs(sa){
                controller.doPermissionSetAssignment();
                
                List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usr.Id and PermissionSetId = :permSet.Id];
                
                system.assertEquals(true, ((assignments == null) || (assignments.size() == 0)));
            }
            Test.stopTest();
        }
    }
  
}