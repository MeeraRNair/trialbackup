/***********************************************************
    * Name          : VFcntrl_DnBLookUpPageTest
    * Description   : Test class for VFcntrl_DnBLookUpPage 
    * ---------------------------------------------------------
    * Revision  Name               Date             Description
    * 1.0       Yeswanth        19.Sep.2016    Test Class for VFcntrl_DnBLookUpPage class

************************************************************/


@isTest
public class VFcntrl_DnBLookUpPageTest {

   // Method to cover Success scenario
 static testmethod void testMethod1() {

  TriggerExecutionController.setSkipAllTriggers(true);

  profile partnerProfile = [select id, name from profile where name like '%EMEA PRM Portal User%' order by name desc Limit 1];

  Id accRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);

  // Creating partner account
  Account partnerAccount = new Account(name = 'PartnerAccount',
                                       Account_Country_Code__c = 'US',
                                       Type = 'Partner',
                                       Account_Country__c = 'UNITED STATES',
                                       RecordTypeId = accRTId);
     insert partnerAccount;

  // Creating partner contact
  Contact partnerContact = new Contact(FirstName = 'Partner',
                                       LastName = 'Contact',
                                       AccountId = partnerAccount.Id,
                                       Status__c = 'Marketing Suspect',
                                       Email = 'MyLastNae@dell.com',
                                       Fax = '1234567',
                                       MobilePhone = '0987654',
                                       Last_Operation_Performed__c = 'testing',
                                       Phone = '1234500');
  insert partnerContact;

  // Creating Partner User
  User partnerUser = new User(Username = 'partnerUser' + System.currentTimeMillis() + '@dell.com',
                           Alias = 'PU',
                           Email = 'MyLastName@dell.com',
                           FirstName = 'Partner',
                           LastName = 'User',
                           ProfileId = partnerProfile.Id,
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           TimeZoneSidKey = 'America/Los_Angeles',
                           Badge_Number__c = 'Test1234',
                           Enable_Partner_Admin__c = true,
                           isActive = true,
                           Enable_Partner_Deal_Registration__c = true,
                           ContactId = partnerContact.Id);
  insert partnerUser;

  // Creating Country record
  Country__c country = new Country__c(Name = 'UNITED STATES', Code__c = 'US', DnB_Supported_Country__c=true,DNB_COUNTRY_CODE__c = '805', DNB_ISO_country_code__c = 'US', DNB_Region__c = 'AMER');
  insert country;

  // Creating end customer
  End_customer__C endCustomer = new End_customer__C(name = 'endcustomer',
                                                   Partner_Account__c = partnerAccount.id,
                                                   Mailing_city__c = 'Austin',
                                                   Mailing_State__c = 'Texas',
                                                   Mailing_country__c = 'UNITED STATES');
  insert endCustomer;

  Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);

  // Creating Opporutniy
  Opportunity testOppty = new Opportunity(Name = 'Test Oppty',
                                           Deal_Registration_Status__c = 'New',
                                           Total_Expected_Dell_Revenue__c = 1919191,
                                           RecordTypeID = DealRTId,
                                           Engagement_Type__c = 'Public Tender',
                                           Justification_Statement__c = 'Statement1',
                                           end_customer__C = endCustomer.id,
                                           End_User_Account_Name__c = 'Test Account',
                                           End_User_Mailing_City__c = 'City',
                                           End_User_Mailing_State_Province_Region__c = 'State 1',
                                           End_User_Mailing_Country__c = 'UNITED STATES',
                                           Save_End_Customer_to_my_list__c = 'No',
                                           End_User_First_Name__c = 'First Name',
                                           End_User_Last_Name__c = 'Last Name',
                                           End_User_Email__c = 'user@dell.coin',
                                           CloseDate = System.Today() + 30,
                                           Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                           Forecast_Category_Override__c='Omitted',
                                           StageName = 'Plan - 1%');
          system.runas(partnerUser){
          insert testOppty;
          }
     
            PageReference pageRef = Page.DnBLookUpPage;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testOppty);
            ApexPages.currentPage().getParameters().put('Id',testOppty.id);
     
            VFcntrl_DnBLookUpPage DnBLookUpController = new VFcntrl_DnBLookUpPage(sc);
            DnBLookUpController.searchDnB();

          test.startTest();           
            StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
            mockResponse.setStaticResource('DnB_response_body_staticresource');
            mockResponse.setStatusCode(200);
            mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');           
            Test.setMock(HttpCalloutMock.class, mockResponse);
            DnBLookUpController.searchDnB();
            DnBLookUpController.addCustomerToDeal();
          //  DnBLookUpController.getcountries();
            System.currentPagereference().getParameters().put('selectedDUnsId',DnBLookUpController.finalList[0].DunsId);
            DnBLookUpController.addCustomerToDeal();
          test.stopTest();
 }
        
  // Method to cover CIL related Exceptions   
 static testmethod void testMethod2() {

  TriggerExecutionController.setSkipAllTriggers(true);

  profile partnerProfile = [select id, name from profile where name like '%EMEA PRM Portal User%' order by name desc Limit 1];

  Id accRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);

  // Creating partner account
  Account partnerAccount = new Account(name = 'PartnerAccount',
                                       Account_Country_Code__c = 'US',
                                       Type = 'Partner',
                                       Account_Country__c = 'UNITED STATES',
                                       RecordTypeId = accRTId);
     insert partnerAccount;

  // Creating partner contact
  Contact partnerContact = new Contact(FirstName = 'Partner',
                                       LastName = 'Contact',
                                       AccountId = partnerAccount.Id,
                                       Status__c = 'Marketing Suspect',
                                       Email = 'MyLastNae@dell.com',
                                       Fax = '1234567',
                                       MobilePhone = '0987654',
                                       Last_Operation_Performed__c = 'testing',
                                       Phone = '1234500');
  insert partnerContact;

  // Creating Partner User
  User partnerUser = new User(Username = 'partnerUser' + System.currentTimeMillis() + '@dell.com',
                           Alias = 'PU',
                           Email = 'MyLastName@dell.com',
                           FirstName = 'Partner',
                           LastName = 'User',
                           ProfileId = partnerProfile.Id,
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           TimeZoneSidKey = 'America/Los_Angeles',
                           Badge_Number__c = 'Test1234',
                           Enable_Partner_Admin__c = true,
                           isActive = true,
                           Enable_Partner_Deal_Registration__c = true,
                           ContactId = partnerContact.Id);
  insert partnerUser;

  // Creating Country record
  Country__c country = new Country__c(Name = 'UNITED STATES', Code__c = 'US', DNB_COUNTRY_CODE__c = '805',DnB_Supported_Country__c=true, DNB_ISO_country_code__c = 'US', DNB_Region__c = 'AMER');
  insert country;

  // Creating end customer
  End_customer__C endCustomer = new End_customer__C(name = 'endCustomer',
                                                   Partner_Account__c = partnerAccount.id,
                                                   Mailing_city__c = 'Austin',
                                                   Mailing_State__c = 'Texas',
                                                   Mailing_country__c = 'UNITED STATES');
  insert endCustomer;

  Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);

  // Creating Opporutniy
  Opportunity testOppty = new Opportunity(Name = 'Test Oppty',
                                           Deal_Registration_Status__c = 'New',
                                           Total_Expected_Dell_Revenue__c = 1919191,
                                           RecordTypeID = DealRTId,
                                           Engagement_Type__c = 'Public Tender',
                                           Justification_Statement__c = 'Statement1',
                                           end_customer__C = endCustomer.id,
                                           End_User_Account_Name__c = 'Test Account',
                                           End_User_Mailing_City__c = 'City',
                                           End_User_Mailing_State_Province_Region__c = 'State 1',
                                           End_User_Mailing_Country__c = 'UNITED STATES',
                                           Save_End_Customer_to_my_list__c = 'No',
                                           End_User_First_Name__c = 'First Name',
                                           End_User_Last_Name__c = 'Last Name',
                                           End_User_Email__c = 'user@dell.coin',
                                           CloseDate = System.Today() + 30,
                                           Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                            Forecast_Category_Override__c='Omitted',
                                           StageName = 'Plan - 1%');
          system.runas(partnerUser){
          insert testOppty;
          }
     
            PageReference pageRef = Page.DnBLookUpPage;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testOppty);
            ApexPages.currentPage().getParameters().put('Id',testOppty.id);
     
            VFcntrl_DnBLookUpPage DnBLookUpController = new VFcntrl_DnBLookUpPage(sc);

          test.startTest();           
            StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
            mockResponse.setStaticResource('DnB_response_body_staticresource_Sce1');
            mockResponse.setStatusCode(200);
            mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');           
            Test.setMock(HttpCalloutMock.class, mockResponse);
            DnBLookUpController.searchDnB();
          test.stopTest();

 }
    
 // Method to cover DP related Exceptions
 static testmethod void testMethod3() {

  TriggerExecutionController.setSkipAllTriggers(true);

  profile partnerProfile = [select id, name from profile where name like '%EMEA PRM Portal User%' order by name desc Limit 1];

  Id accRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);

  // Creating partner account
  Account partnerAccount = new Account(name = 'PartnerAccount',
                                       Account_Country_Code__c = 'US',
                                       Type = 'Partner',
                                       Account_Country__c = 'UNITED STATES',
                                       RecordTypeId = accRTId);
     insert partnerAccount;

  // Creating partner contact
  Contact partnerContact = new Contact(FirstName = 'Partner',
                                       LastName = 'Contact',
                                       AccountId = partnerAccount.Id,
                                       Status__c = 'Marketing Suspect',
                                       Email = 'MyLastNae@dell.com',
                                       Fax = '1234567',
                                       MobilePhone = '0987654',
                                       Last_Operation_Performed__c = 'testing',
                                       Phone = '1234500');
  insert partnerContact;

  // Creating Partner User
  User partnerUser = new User(Username = 'partnerUser' + System.currentTimeMillis() + '@dell.com',
                           Alias = 'PU',
                           Email = 'MyLastName@dell.com',
                           FirstName = 'Partner',
                           LastName = 'User',
                           ProfileId = partnerProfile.Id,
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           TimeZoneSidKey = 'America/Los_Angeles',
                           Badge_Number__c = 'Test1234',
                           Enable_Partner_Admin__c = true,
                           isActive = true,
                           Enable_Partner_Deal_Registration__c = true,
                           ContactId = partnerContact.Id);
  insert partnerUser;

  // Creating Country record
  Country__c country = new Country__c(Name = 'UNITED STATES', Code__c = 'US', DNB_COUNTRY_CODE__c = '805',DnB_Supported_Country__c=true, DNB_ISO_country_code__c = 'US', DNB_Region__c = 'AMER');
  insert country;

  // Creating end customer
  End_customer__C endCustomer = new End_customer__C(name = 'endCustomer',
                                                   Partner_Account__c = partnerAccount.id,
                                                   Mailing_city__c = 'Austin',
                                                   Mailing_State__c = 'Texas',
                                                   Mailing_country__c = 'UNITED STATES');
  insert endCustomer;

  Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);

  // Creating Opporutniy
  Opportunity testOppty = new Opportunity(Name = 'Test Oppty',
                                           Deal_Registration_Status__c = 'New',
                                           Total_Expected_Dell_Revenue__c = 1919191,
                                           RecordTypeID = DealRTId,
                                           Engagement_Type__c = 'Public Tender',
                                           Justification_Statement__c = 'Statement1',
                                           end_customer__C = endCustomer.id,
                                           End_User_Account_Name__c = 'Test Account',
                                           End_User_Mailing_City__c = 'City',
                                           End_User_Mailing_State_Province_Region__c = 'State 1',
                                           End_User_Mailing_Country__c = 'UNITED STATES',
                                           Save_End_Customer_to_my_list__c = 'No',
                                           End_User_First_Name__c = 'First Name',
                                           End_User_Last_Name__c = 'Last Name',
                                           End_User_Email__c = 'user@dell.coin',
                                           CloseDate = System.Today() + 30,
                                           Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                           Forecast_Category_Override__c='Omitted',
                                           StageName = 'Plan - 1%');
          system.runas(partnerUser){
          insert testOppty;
          }
     
            PageReference pageRef = Page.DnBLookUpPage;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testOppty);
            ApexPages.currentPage().getParameters().put('Id',testOppty.id);
     
            VFcntrl_DnBLookUpPage DnBLookUpController = new VFcntrl_DnBLookUpPage(sc);

          test.startTest();           
            StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
            mockResponse.setStaticResource('DnB_response_body_staticresource_Sce2');
            mockResponse.setStatusCode(200);
            mockresponse.setStatus('Unauthorized');
            mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');           
            Test.setMock(HttpCalloutMock.class, mockResponse);
            DnBLookUpController.searchDnB();
          test.stopTest();

 }
 
 // Method to cover invalid DnB countries scenario
 static testmethod void testMethod4() {

  TriggerExecutionController.setSkipAllTriggers(true);

  profile partnerProfile = [select id, name from profile where name like '%EMEA PRM Portal User%' order by name desc Limit 1];

  Id accRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);

  // Creating partner account
  Account partnerAccount = new Account(name = 'PartnerAccount',
                                       Account_Country_Code__c = 'US',
                                       Type = 'Partner',
                                       Account_Country__c = 'UNITED STATES',
                                       RecordTypeId = accRTId);
     insert partnerAccount;

  // Creating partner contact
  Contact partnerContact = new Contact(FirstName = 'Partner',
                                       LastName = 'Contact',
                                       AccountId = partnerAccount.Id,
                                       Status__c = 'Marketing Suspect',
                                       Email = 'MyLastNae@dell.com',
                                       Fax = '1234567',
                                       MobilePhone = '0987654',
                                       Last_Operation_Performed__c = 'testing',
                                       Phone = '1234500');
  insert partnerContact;

  // Creating Partner User
  User partnerUser = new User(Username = 'partnerUser' + System.currentTimeMillis() + '@dell.com',
                           Alias = 'PU',
                           Email = 'MyLastName@dell.com',
                           FirstName = 'Partner',
                           LastName = 'User',
                           ProfileId = partnerProfile.Id,
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           TimeZoneSidKey = 'America/Los_Angeles',
                           Badge_Number__c = 'Test1234',
                           Enable_Partner_Admin__c = true,
                           isActive = true,
                           Enable_Partner_Deal_Registration__c = true,
                           ContactId = partnerContact.Id);
  insert partnerUser;

  // Creating Country record
  Country__c country = new Country__c(Name = 'UNITED STATES', Code__c = 'US');
  insert country;

  // Creating end customer
  End_customer__C endCustomer = new End_customer__C(name = 'endCustomer',
                                                   Partner_Account__c = partnerAccount.id,
                                                   Mailing_city__c = 'Austin',
                                                   Mailing_State__c = 'Texas',
                                                   Mailing_country__c = 'UNITED STATES');
  insert endCustomer;

  Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);

  // Creating Opporutniy
  Opportunity testOppty = new Opportunity(Name = 'Test Oppty',
                                           Deal_Registration_Status__c = 'New',
                                           Total_Expected_Dell_Revenue__c = 1919191,
                                           RecordTypeID = DealRTId,
                                           Engagement_Type__c = 'Public Tender',
                                           Justification_Statement__c = 'Statement1',
                                           end_customer__C = endCustomer.id,
                                           End_User_Account_Name__c = 'Test Account',
                                           End_User_Mailing_City__c = 'City',
                                           End_User_Mailing_State_Province_Region__c = 'State 1',
                                           End_User_Mailing_Country__c = 'UNITED STATES',
                                           Save_End_Customer_to_my_list__c = 'No',
                                           End_User_First_Name__c = 'First Name',
                                           End_User_Last_Name__c = 'Last Name',
                                           End_User_Email__c = 'user@dell.coin',
                                           CloseDate = System.Today() + 30,
                                           Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                           Forecast_Category_Override__c='Omitted',
                                           StageName = 'Plan - 1%');
          system.runas(partnerUser){
          insert testOppty;
          }
     
            PageReference pageRef = Page.DnBLookUpPage;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testOppty);
            ApexPages.currentPage().getParameters().put('Id',testOppty.id);
     
            VFcntrl_DnBLookUpPage DnBLookUpController = new VFcntrl_DnBLookUpPage(sc);
            DnBLookUpController.searchDnB();
 }
    
}