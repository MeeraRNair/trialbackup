@isTest
private class AccountPlanAfterInsertUpdateTest {

    static User userRecord;
    static Account testEUAccount;
    static SFDC_Acct_Plan__c testAccountPlan;
    static SFDC_Acct_Plan__c testPartnerAccountPlan;
    
    static testMethod void Test_AccountPlanCreateAndUpdate_DirectAccountPlan() {
        TriggerExecutionController.setSkipAllTriggers(true);
        //TestDataCreation();
        Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
        
        userRecord = new User(Username = 'TestValidUser1@dell.com',
                               Alias = 'Test', 
                               Email = 'Test212@dell.com', 
                               LastName = 'Test22',
                               Title = 'GCC Program Manager', 
                               ProfileId = profile.Id, 
                               LanguageLocaleKey = 'en_US', 
                               LocaleSidKey = 'en_US', 
                               EmailEncodingKey = 'UTF-8', 
                               TimeZoneSidKey = 'America/Los_Angeles',
                               Country = 'US',
                               Badge_Number__c = 'Test' + System.currentTimeMillis());
        insert userRecord;
        User salesMgr = new User(Username = 'TestValidUserAccPlan2@dell.com',
                                Alias = 'Test', 
                                Email = 'Test212@dell.com', 
                                LastName = 'Test22',
                                Title = 'GCC Program Manager', 
                                ProfileId = profile.Id, 
                                LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_US', 
                                EmailEncodingKey = 'UTF-8', 
                                TimeZoneSidKey = 'America/Los_Angeles',
                                Country = 'US',
                                Badge_Number__c = 'Test' + System.currentTimeMillis());
        insert salesMgr;
        Id partnerAccPlanRTId= IdLookupUtils.getRecordTypeId('Channel/Partner Account Plan','SFDC_Acct_Plan__c',true);
        Id directAccPlanRTId= IdLookupUtils.getRecordTypeId('Direct Relationship Account Plan','SFDC_Acct_Plan__c',true);
        
        
            //Create Account
            testEUAccount = new Account(Name = 'Test EU Account for Account Plan Test', Type = 'End User', Participating_in_LOB_Program__c = true, OwnerId = userRecord.Id);
            insert testEUAccount;
        testAccountPlan = new SFDC_Acct_Plan__c(Name = 'TestPlan01', Account__c = testEUAccount.Id, Sales_Manager__c = salesMgr.Id , Approved_by_Sales_Management__c=null,Manager__c=null,RecordTypeId=partnerAccPlanRTId);            
            
            insert testAccountPlan;        
            
            //Create Strategy for Account Plan
            SFDC_Strategy__c testStrategy = new SFDC_Strategy__c(Name = 'Test Strategy', SFDC_Acct_Plan__c = testAccountPlan.Id);
            insert testStrategy;
        
        //Update the Account plan status to Pending
        testAccountPlan.Plan_Status__c = 'Pending';    
        update testAccountPlan;
        System.debug('**Test Class Debug -- testAccountPlan.Sales_Manager__c** ::'+testAccountPlan.Sales_Manager__c);   
            System.debug('**Test Class Debug -- testAccountPlan.RecordType.Namec** ::'+testAccountPlan.RecordType.Name);
                 System.debug('**Test Class Debug -- testAccountPlan.Manager__c** ::'+testAccountPlan.Manager__c);   
       
        TriggerExecutionController.setSkipAllTriggers(false);  
        Test.startTest();
        system.debug('###Account Plan Status is :: ' + testAccountPlan.Status__c);
        AccountPlanUpdateStatusController controller = new AccountPlanUpdateStatusController(new ApexPages.StandardController(testAccountPlan));
        
        PageReference pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.updateAccountPlanStatus();
        
        system.debug('###Account Plan Status is :: ' + testAccountPlan.Status__c);
        
        pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.redirectBack();
        system.debug('###Account Plan Status is :: ' + testAccountPlan.Status__c);
        
        pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.getHasMessage();
        
        testAccountPlan.Sales_Manager__c = userRecord.Id;
        update testAccountPlan;
        pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.updateAccountPlanStatus();
        Test.stopTest();
    }
    
    //Modified - to cover for submitted fro approval 
     static testMethod void Test_AccountPlanCreateAndUpdate_DirectAccountPlanapp() {
         // Skill all trigger to avoid too many SOQL Query Issue
        TriggerExecutionController.setSkipAllTriggers(true);
        
        //TestDataCreation();
        
        Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
        
        userRecord = new User(Username = 'TestValidUser1@dell.com',
                               Alias = 'Test', 
                               Email = 'Test212@dell.com', 
                               LastName = 'Test22',
                               Title = 'GCC Program Manager', 
                               ProfileId = profile.Id, 
                               LanguageLocaleKey = 'en_US', 
                               LocaleSidKey = 'en_US', 
                               EmailEncodingKey = 'UTF-8', 
                               TimeZoneSidKey = 'America/Los_Angeles',
                               Country = 'US',
                               Badge_Number__c = 'Test' + System.currentTimeMillis());
        insert userRecord;
        User salesMgr = new User(Username = 'TestValidUserAccPlan2@dell.com',
                                Alias = 'Test', 
                                Email = 'Test212@dell.com', 
                                LastName = 'Test22',
                                Title = 'GCC Program Manager', 
                                ProfileId = profile.Id, 
                                LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_US', 
                                EmailEncodingKey = 'UTF-8', 
                                TimeZoneSidKey = 'America/Los_Angeles',
                                Country = 'US',
                                Badge_Number__c = 'Test' + System.currentTimeMillis());
        insert salesMgr;
        Id partnerAccPlanRTId= IdLookupUtils.getRecordTypeId('Channel/Partner Account Plan','SFDC_Acct_Plan__c',true);
        Id directAccPlanRTId= IdLookupUtils.getRecordTypeId('Direct Relationship Account Plan','SFDC_Acct_Plan__c',true);
        
        
            //Create Account
            testEUAccount = new Account(Name = 'Test EU Account for Account Plan Test', Type = 'End User', Participating_in_LOB_Program__c = true, OwnerId = userRecord.Id);
            insert testEUAccount;
        testAccountPlan = new SFDC_Acct_Plan__c(Name = 'TestPlan01', Account__c = testEUAccount.Id, Sales_Manager__c = salesMgr.Id , Approved_by_Sales_Management__c=null,Manager__c=null,RecordTypeId=partnerAccPlanRTId);            
            
            insert testAccountPlan;        
            
            //Create Strategy for Account Plan
            SFDC_Strategy__c testStrategy = new SFDC_Strategy__c(Name = 'Test Strategy', SFDC_Acct_Plan__c = testAccountPlan.Id);
            insert testStrategy;
 
        
        //Update the Account plan status to Pending
        testAccountPlan.Plan_Status__c = 'Pending';    
        
        
        testAccountPlan.Plan_Status__c = 'Submitted for Approval'; 
        testAccountPlan.Account_Executive__c=userRecord.Id;    
        update testAccountPlan;
        System.debug('**Test Class Debug -- testAccountPlan.Sales_Manager__c** ::'+testAccountPlan.Sales_Manager__c);   
            System.debug('**Test Class Debug -- testAccountPlan.RecordType.Namec** ::'+testAccountPlan.RecordType.Name);
                 System.debug('**Test Class Debug -- testAccountPlan.Manager__c** ::'+testAccountPlan.Manager__c);   
       
        //Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);  
        Test.startTest();
        system.debug('###Account Plan Status is :: ' + testAccountPlan.Status__c);
        AccountPlanUpdateStatusController controller = new AccountPlanUpdateStatusController(new ApexPages.StandardController(testAccountPlan));
        
        PageReference pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.updateAccountPlanStatus();
        
        system.debug('###Account Plan Status is :: ' + testAccountPlan.Status__c);
        //Test.startTest();
        pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.redirectBack();
        system.debug('###Account Plan Status is :: ' + testAccountPlan.Status__c);
        
        pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.getHasMessage();
        
        testAccountPlan.Sales_Manager__c = userRecord.Id;
        update testAccountPlan;
        pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.updateAccountPlanStatus();  
        Test.stopTest();      
    }
    
    static testMethod void Test_AccountPlanCreateAndUpdate_PartnerAccountPlan() {
        TriggerExecutionController.setSkipAllTriggers(true);
        //TestDataCreation();
        
        Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
        
        userRecord = new User(Username = 'TestValidUser1@dell.com',
                               Alias = 'Test', 
                               Email = 'Test212@dell.com', 
                               LastName = 'Test22',
                               Title = 'GCC Program Manager', 
                               ProfileId = profile.Id, 
                               LanguageLocaleKey = 'en_US', 
                               LocaleSidKey = 'en_US', 
                               EmailEncodingKey = 'UTF-8', 
                               TimeZoneSidKey = 'America/Los_Angeles',
                               Country = 'US',
                               Badge_Number__c = 'Test' + System.currentTimeMillis());
        insert userRecord;
        User salesMgr = new User(Username = 'TestValidUserAccPlan2@dell.com',
                                Alias = 'Test', 
                                Email = 'Test212@dell.com', 
                                LastName = 'Test22',
                                Title = 'GCC Program Manager', 
                                ProfileId = profile.Id, 
                                LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_US', 
                                EmailEncodingKey = 'UTF-8', 
                                TimeZoneSidKey = 'America/Los_Angeles',
                                Country = 'US',
                                Badge_Number__c = 'Test' + System.currentTimeMillis());
        insert salesMgr;
        User pdmMgr = new User(Username = 'TestPDM@dell.com',
                                Alias = 'Test', 
                                Email = 'TestPDM@dell.com', 
                                LastName = 'Testpdm22',
                                Title = 'GCC Program Manager', 
                                ProfileId = profile.Id, 
                                LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_US', 
                                EmailEncodingKey = 'UTF-8', 
                                TimeZoneSidKey = 'America/Los_Angeles',
                                Country = 'US',
                                Badge_Number__c = 'Tst' + System.currentTimeMillis());
        insert pdmMgr;
        
        Id partnerAccPlanRTId= IdLookupUtils.getRecordTypeId('Channel/Partner Account Plan','SFDC_Acct_Plan__c',true);
        Id directAccPlanRTId= IdLookupUtils.getRecordTypeId('Direct Relationship Account Plan','SFDC_Acct_Plan__c',true);
        
        
            //Create Account
            testEUAccount = new Account(Name = 'Test EU Account for Account Plan Test', Type = 'End User', Participating_in_LOB_Program__c = true, OwnerId = userRecord.Id);
            insert testEUAccount;
        testPartnerAccountPlan = new SFDC_Acct_Plan__c(Name = 'TestPlan01', Account__c = testEUAccount.Id, Sales_Manager__c = salesMgr.Id , Approved_by_Sales_Management__c=null,Manager__c=pdmMgr.Id,RecordTypeId=partnerAccPlanRTId);
            insert testPartnerAccountPlan;
            
            //Create Partner Strategy for Account Plan
            SFDC_Strategy__c testPartnerStrategy = new SFDC_Strategy__c(Name = 'Test Partner Strategy', SFDC_Acct_Plan__c = testPartnerAccountPlan.Id);
            insert testPartnerStrategy;
 
        
        //Update the Account plan status to Pending
        testPartnerAccountPlan.Plan_Status__c = 'Pending';
        update testPartnerAccountPlan;
        System.debug('**Test Class Debug -- testPartnerAccountPlan.Sales_Manager__c** ::'+testPartnerAccountPlan.Sales_Manager__c);   
            System.debug('**Test Class Debug -- testPartnerAccountPlan.RecordType.Namec** ::'+testPartnerAccountPlan.RecordType.Name);
                 System.debug('**Test Class Debug -- testPartnerAccountPlan.Manager__c** ::'+testPartnerAccountPlan.Manager__c);   
       
        TriggerExecutionController.setSkipAllTriggers(false);  
        Test.startTest();
        system.debug('###Account Plan Status is :: ' + testPartnerAccountPlan.Status__c);
        AccountPlanUpdateStatusController controller = new AccountPlanUpdateStatusController(new ApexPages.StandardController(testPartnerAccountPlan));
        
        PageReference pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testPartnerAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.updateAccountPlanStatus();
        
        system.debug('###Account Plan Status is :: ' + testPartnerAccountPlan.Status__c);
        
        pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testPartnerAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.redirectBack();
        system.debug('###Account Plan Status is :: ' + testPartnerAccountPlan.Status__c);
        
        pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testPartnerAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.getHasMessage();
        
        testPartnerAccountPlan.Manager__c = userRecord.Id;
        update testPartnerAccountPlan;
        pageRef = new PageReference('/apex/AccountPlanUpdateStatus?id=' + testPartnerAccountPlan.Id);
        Test.setCurrentPage(pageRef);
        controller.updateAccountPlanStatus();
        Test.stopTest();
    }
 }