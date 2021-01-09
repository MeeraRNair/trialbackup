/*
 * Author   : Ragu
 * Purpose  : Test class for AccountPlanRejectionController.
 * REVISION HISTORY
 * ================
 * Version  Modified By     Date            Reference No    Description
 * -------  -----------     ----            ------------    -----------
 * 1.1      Jananii         06-Oct-2015     CR 11998       Modified to increase the code coverage because of implementing the code for CR 11998 in AccountPlanRejectionController.
 */
 
@isTest
public with sharing class AccountPlanRejectionControllerTest {

  static User recordCreator;
  static User salesManager;
  static User pdmManager; // V 1.1
    static Account testEUAccount;
    static SFDC_Acct_Plan__c testAccountPlan;
    static SFDC_Acct_Plan__c testPartnerAccountPlan; //V 1.1
    
    static testMethod void Test_AccountPlanRejectionController_DirectAccountPlan() {
      createTestData();
      
      // RequiredParametersMissingException
      AccountPlanRejectionController controller = new AccountPlanRejectionController(new ApexPages.StandardController(new SFDC_Acct_Plan__c()));
      
      // InsufficientPrivilegeException
      controller = new AccountPlanRejectionController(new ApexPages.StandardController(testAccountPlan));
      
      system.runAs(salesManager) {
        // InvalidStatusException
        controller = new AccountPlanRejectionController(new ApexPages.StandardController(testAccountPlan));
        controller.reject();
        
        testAccountPlan.Plan_Status__c = 'Submitted for Approval';
        update testAccountPlan;
        
        // Successful Rejection
        controller = new AccountPlanRejectionController(new ApexPages.StandardController(testAccountPlan));
        controller.accPlan.Reason_for_Rejection__c = 'Test Reject.';
        controller.getCanProceed();
        controller.reject();
      }
    }
    
    //V 1.1 - Start
    
    static testMethod void Test_AccountPlanRejectionController_PartnerAccountPlan() {
      createTestData();
      
      // RequiredParametersMissingException
      AccountPlanRejectionController controller = new AccountPlanRejectionController(new ApexPages.StandardController(new SFDC_Acct_Plan__c()));
      
      // InsufficientPrivilegeException
      controller = new AccountPlanRejectionController(new ApexPages.StandardController(testPartnerAccountPlan));
      
      system.runAs(pdmManager) {
        // InvalidStatusException
        controller = new AccountPlanRejectionController(new ApexPages.StandardController(testPartnerAccountPlan));
        controller.reject();
        
        testPartnerAccountPlan.Plan_Status__c = 'Submitted for Approval';
        update testPartnerAccountPlan;
        
        // Successful Rejection
        controller = new AccountPlanRejectionController(new ApexPages.StandardController(testPartnerAccountPlan));
        controller.accPlan.Reason_for_Rejection__c = 'Test Reject.';
        controller.getCanProceed();
        controller.reject();
      }
    }
    
    //V 1.1 - End
    
    static void createTestData() {
       Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
       
       //Create a user with Standard User profile
       recordCreator = new User(Username = 'TestValidUser1' + '@dell.com',
                               Alias = 'Test', 
                               Email = 'Test212'+'@dell.com', 
                               LastName = 'Test22',
                               Title = 'GCC Program Manager', 
                               ProfileId = profile.Id, 
                               LanguageLocaleKey = 'en_US', 
                               LocaleSidKey = 'en_US', 
                               EmailEncodingKey = 'UTF-8', 
                               TimeZoneSidKey = 'America/Los_Angeles',
                               Country = 'US',
                               Badge_Number__c = 'Tst'+System.currentTimeMillis());
        insert recordCreator;
        
        salesManager = new User(Username = 'TestValidUser2' + '@dell.com',
                               Alias = 'Test', 
                               Email = 'Test212'+'@dell.com', 
                               LastName = 'Test22',
                               Title = 'GCC Program Manager', 
                               ProfileId = profile.Id, 
                               LanguageLocaleKey = 'en_US', 
                               LocaleSidKey = 'en_US', 
                               EmailEncodingKey = 'UTF-8', 
                               TimeZoneSidKey = 'America/Los_Angeles',
                               Country = 'US',
                               Badge_Number__c = 'Tst'+System.currentTimeMillis());
        insert salesManager;
        
        //V 1.1 - Start
        pdmManager = new User(Username = 'TestValidUserPDMMgr' + '@dell.com',
                               Alias = 'TestPDM', 
                               Email = 'TestPDM_01'+'@dell.com', 
                               LastName = 'TestUSer_PDM Manager',
                               Title = 'GCC Program Manager', 
                               ProfileId = profile.Id, 
                               LanguageLocaleKey = 'en_US', 
                               LocaleSidKey = 'en_US', 
                               EmailEncodingKey = 'UTF-8', 
                               TimeZoneSidKey = 'America/Los_Angeles',
                               Country = 'US',
                               Badge_Number__c = 'PDM'+System.currentTimeMillis());
        insert pdmManager;
        
        //V 1.1 - End
        
        System.runAs(recordCreator) {
          //Create Account
          testEUAccount = new Account(Name = 'Test EU Account for Account Plan Test', Type = 'End User', Participating_in_LOB_Program__c = true, OwnerId = recordCreator.Id);
          insert testEUAccount;
          
          //Create Direct Account Plan for the Account
      testAccountPlan = new SFDC_Acct_Plan__c(Name = 'TestPlan01', Account__c = testEUAccount.Id, Sales_Manager__c = salesManager.Id, 
                          Plan_Status__c = null, Reason_for_Rejection__c = null);
          insert testAccountPlan;
          
          //V 1.1 - Start
          
          //Create Direct Account Plan for the Account
          
          testPartnerAccountPlan= new SFDC_Acct_Plan__c(Name = 'TestPartnerPlan01', Account__c = testEUAccount.Id, Manager__c = pdmManager.Id, 
                          Plan_Status__c = null, Reason_for_Rejection__c = null);
          insert testPartnerAccountPlan;
            
         //Create Strategy for Account Plan
          SFDC_Strategy__c testPartnerStrategy = new SFDC_Strategy__c(Name = 'Test Partner Strategy', SFDC_Acct_Plan__c = testPartnerAccountPlan.Id);
          insert testPartnerStrategy;
          
          //V 1.1 - End
          
          //Create Strategy for Account Plan
          SFDC_Strategy__c testStrategy = new SFDC_Strategy__c(Name = 'Test Strategy', SFDC_Acct_Plan__c = testAccountPlan.Id);
          insert testStrategy;
        }
    }

}