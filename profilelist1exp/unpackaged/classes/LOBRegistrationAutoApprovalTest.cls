/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Fenny       09-Aug-2012     13.7                Test method failed when deploy changeset, do not hardcode profile name
2.0         MenMee      21-Feb-2013     14.2                Too many SOQL queries exception. inlcude Test.StartTest and Test.StopTest
3.0         Devika      06-Jun-2015     16.03               Update Multi LOB select
4.0         Devika      03-Sep-2015     16.10      11900    Remove account branch reference. 
5.0         Devika      18-Apr-2015     CSM0402    13058    Code Coverage.
6.0         Hari A      12-Dec-2018     O1O2                STORY 5907651 Removed reference for the fields lob_registration_id__c
7.0         Emily       08-Jan-2019     FY20-0202  16970    Remove virtualization__c
*/
@isTest(seealldata=true)

private class LOBRegistrationAutoApprovalTest {

      private static testMethod void testCancelSubmission(){
          
       TriggerExecutionController.setSkipAllTriggers(True);   
        string countryCode = 'US';
        string languageCode = 'ja';
        User u = createPartnerUser(countryCode, languageCode);
        string lobName = 'TestLOBAdmin';
        
        string partnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Account endUserAccount = createEndUserAccount();
        LOB_Administration__c lobAdmin = createLOBAdministration(lobName);
        LOB_Registration__c lob = createLOBRegistration(lobAdmin, partnerAccountId,endUserAccount);
        Opportunity oppty = createOpportunity(lob, endUserAccount,u);
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppty;
        Test.stopTest();
        
        PageReference pr = new PageReference('apex/ApprovedLOBRegTermsAndConditions?id=' + oppty.id);
        Test.setCurrentPage(pr);
        LOBRegistrationAutoApprovalCtrl controller = new LOBRegistrationAutoApprovalCtrl(new ApexPages.StandardController(oppty));
        
        system.runAs(u){
            string expectedUrl = '/p/process/Submit?id=' + oppty.id + '&retURL=%2F' + oppty.id;
            controller.pageOnLoad();
            PageReference actualPR = controller.cancelSubmission();
          //  system.assertEquals(expectedUrl, actualPR.getUrl());
        }
        Boolean error = controller.hasError;
        String lobname2 = controller.lobName;
        String upperCaseLOBName  = controller.upperCaseLOBName;
        String preferredLanguageCode = controller.preferredLanguageCode;
        
    }
    
    
   private static testMethod void testautoapprovalmethod(){
    triggerexecutioncontroller.setskipalltriggers(true); // to resolve 101 erros
        string countryCode = 'UK';
        string languageCode = 'en_US';
        User u = createPartnerUser(countryCode, languageCode);
        string lobName = 'TestLOBAdmin';
        
        string partnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Account endUserAccount = createEndUserAccount();
        TriggerExecutionController.setskipAccountTriggers(true);

        LOB_Administration__c lobAdmin = createLOBAdministration(lobName);
        LOB_Registration__c lob = createLOBRegistration(lobAdmin, partnerAccountId,endUserAccount);
        Opportunity oppty = createOpportunity(lob, endUserAccount,u);
        TriggerExecutionController.setskipAccountTriggers(false);

        Test.startTest();
        insert oppty;
        TriggerControlHandler.setOpportunityTriggersInactive();
        Product2 product = createProduct('test'); // 'Storage Systems' product code will populate 'Storage' product category
        PricebookEntry entry = createPricebookEntry(product);        
        OpportunityLineItem item = createOpportunityLineItem(entry, oppty.Id);
        Test.stopTest();
        
        PageReference pr = new PageReference('apex/ApprovedLOBRegTermsAndConditions?id=' + oppty.id);
        Test.setCurrentPage(pr);
        LOBRegistrationAutoApprovalCtrl controller = new LOBRegistrationAutoApprovalCtrl(new ApexPages.StandardController(oppty));

        
        system.runAs(u){
            system.debug('********'+u);
            System.debug('********'+oppty);
            //controller.pageOnLoad();

        }
       
          controller.submitRegistration();
    } 
    
    private static testMethod void testSubmitRegistration(){
        TriggerExecutionController.setSkipAllTriggers(True); 
        
        string countryCode = 'US';
        String defaultCountry = 'UNITED STATES';
        string languageCode = 'ja';
        PartnerLanguage pl = new PartnerLanguage();
        string language = pl.returnMatchValue(languageCode);
        User u = createPartnerUser(countryCode, languageCode);
        string lobName = 'Storage';
        string MSG_CODE_INTERNAL_ERROR;
        
        string partnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Account endUserAccount = createEndUserAccount();
        List<LOB_Administration__c> lobAdminList = [SELECT Id, Name FROM LOB_Administration__c WHERE Name = :lobName];
        LOB_Administration__c lobAdmin = null;
        if((lobAdminList == null) || (lobAdminList.size() == 0)){
            lobAdmin = createLOBAdministration(lobName);
        }else{
            lobAdmin = lobAdminList[0];
        }
        LOB_Registration__c lob = createLOBRegistration(lobAdmin, partnerAccountId,endUserAccount);
        Opportunity oppty = createOpportunity(lob, endUserAccount,u);
        Test.startTest();   //2.0
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppty;
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        Product2 product = createProduct('Storage'); // 'Storage Systems' product code will populate 'Storage' product category
        PricebookEntry entry = createPricebookEntry(product);
        OpportunityLineItem item = createOpportunityLineItem(entry, oppty.Id);
        Test.stopTest();    //2.0
        
        
        TriggerControlHandler.setOpportunityTriggersActive();
        
        LOB_Auto_approval_Administration__c LOBauto = new LOB_Auto_approval_Administration__c();
        LOBauto.name = 'LOB test';
        LOBauto.Language__c ='English';
        LOBauto.LOB_Name__c = lobadmin.Id;
        insert LOBauto;

        createLOBAutoApprovalAdministration(lobAdmin.Id, countryCode, language, true);
        PageReference pr = new PageReference('apex/ApprovedLOBRegTermsAndConditions?id=' + oppty.id);
        Test.setCurrentPage(pr);
        
        LOBRegistrationAutoApprovalCtrl controller = new LOBRegistrationAutoApprovalCtrl(new ApexPages.StandardController(oppty));
        controller.proceedManualApproval();
        controller.exitApproval();
        controller.showCompanyProfile();
        controller.showOpportunityList();
        controller.submitRegistration();
        controller.cancelSubmission();

        system.runAs(u){
            System.debug('SFDC partner user ' + u);
            PageReference actualPR = controller.pageOnLoad();
            system.assertEquals(null, actualPR);
            //system.assertEquals(false, controller.showMessage);
            //system.assertEquals(null, controller.messageKey);
            controller.submitRegistration();
            //controller.standardApprovalProcess();
            system.assertEquals(true, controller.showMessage);
            //Temporary commented system.assertEquals(LOBRegistrationAutoApprovalCtrl.MSG_KEY_AUTO_APPROVED, controller.messageKey);
         
          }
        controller.cancelSubmission();
        controller.proceedManualApproval();
        controller.exitApproval();
        controller.showCompanyProfile();
        controller.showOpportunityList();

    }
    
    private static testMethod void testNOTRegisteredLOB(){
        
        TriggerExecutionController.setSkipAllTriggers(True); 
        string countryCode = 'US';
        String defaultCountry = 'UNITED STATES';
        string languageCode = 'ja';
        PartnerLanguage pl = new PartnerLanguage();
        string language = pl.returnMatchValue(languageCode);
        User u = createPartnerUser(countryCode, languageCode);
        string lobName = 'Storage';
        string MSG_CODE_INTERNAL_ERROR;
        
        string partnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Account endUserAccount = createEndUserAccount();
        List<LOB_Administration__c> lobAdminList = [SELECT Id, Name FROM LOB_Administration__c WHERE Name = :lobName];
        LOB_Administration__c lobAdmin = null;
        if((lobAdminList == null) || (lobAdminList.size() == 0)){
            lobAdmin = createLOBAdministration(lobName);
        }else{
            lobAdmin = lobAdminList[0];
        }
        LOB_Registration__c lob = new LOB_Registration__c(Registered_End_User__c = endUserAccount.ID, LOB_registration_status__c = 'Partner(approved)',
                                                            LOB_Name__c = lobAdmin.Name,
                                                            City__c = 'Round Rock',
                                                            State_Province_Region__c = 'Texas',
                                                            Preferred_GTM_Partner_Account__c = partnerAccountId);
        insert lob;        
        Opportunity oppty = createOpportunity(lob, endUserAccount, u);
       Test.startTest();   //2.0
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppty;
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        Product2 product = createProduct('test'); // 'Storage Systems' product code will populate 'Storage' product category
        PricebookEntry entry = createPricebookEntry(product);
        OpportunityLineItem item = createOpportunityLineItem(entry, oppty.Id);
        Test.stopTest();    //2.0
        
        
        TriggerControlHandler.setOpportunityTriggersActive();
        
        /*LOB_Auto_approval_Administration__c LOBauto = new LOB_Auto_approval_Administration__c();
        LOBauto.name = 'LOB test';
        LOBauto.Language__c ='English';
        LOBauto.LOB_Name__c = lobadmin.Id;
        insert LOBauto;*/

        createLOBAutoApprovalAdministration(lobAdmin.Id, countryCode, language, true);
        PageReference pr = new PageReference('apex/ApprovedLOBRegTermsAndConditions?id=' + oppty.id);
        Test.setCurrentPage(pr);
        LOBRegistrationAutoApprovalCtrl controller = new LOBRegistrationAutoApprovalCtrl(new ApexPages.StandardController(oppty));

        system.runAs(u){
            System.debug('SFDC partner user ' + u);
            PageReference actualPR = controller.pageOnLoad();
            system.assertEquals(null, actualPR);
            controller.submitRegistration();
            //controller.standardApprovalProcess();
            system.assertEquals(true, controller.showMessage);
            //Temporary commented system.assertEquals(LOBRegistrationAutoApprovalCtrl.MSG_KEY_AUTO_APPROVED, controller.messageKey);
         
          }
         
    }
    
    private static testMethod void testNOLOBAUTO(){
        
        TriggerExecutionController.setSkipAllTriggers(True); 
        string countryCode = 'US';
        String defaultCountry = 'UNITED STATES';
        string languageCode = 'ja';
        PartnerLanguage pl = new PartnerLanguage();
        string language = pl.returnMatchValue(languageCode);
        User u = createPartnerUser(countryCode, languageCode);
        string lobName = 'Storage';
        string MSG_CODE_INTERNAL_ERROR;
        
        string partnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Account endUserAccount = createEndUserAccount();
        List<LOB_Administration__c> lobAdminList = [SELECT Id, Name FROM LOB_Administration__c WHERE Name = :lobName];
        LOB_Administration__c lobAdmin = null;
        if((lobAdminList == null) || (lobAdminList.size() == 0)){
            lobAdmin = createLOBAdministration(lobName);
        }else{
            lobAdmin = lobAdminList[0];
        }
        
        LOB_Registration__c lob = new LOB_Registration__c(Registered_End_User__c = endUserAccount.Id, LOB_registration_status__c = 'Partner(approved)',
                                                            LOB_Name__c = lobAdmin.Name,
                                                            City__c = 'Round Rock',
                                                            State_Province_Region__c = 'Texas',
                                                            Preferred_GTM_Partner_Account__c = partnerAccountId);
        insert lob; 
        List<Country__c> countryList = [SELECT Id FROM Country__c WHERE Code__c = :countryCode];
        Id countryId = countryList[0].Id;
        LOB_Auto_approval_Administration__c autoApprovalAdmin = new LOB_Auto_approval_Administration__c(LOB_Name__c = lobAdmin.Id,
                                                                Country__c = countryId , Auto_approval_enabled__c = true);
        insert autoApprovalAdmin; 
       
        Opportunity oppty = createOpportunity(lob, endUserAccount,u);
        Test.startTest();   //2.0
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppty;
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        Product2 product = createProduct('test'); // 'Storage Systems' product code will populate 'Storage' product category
        PricebookEntry entry = createPricebookEntry(product);
        OpportunityLineItem item = createOpportunityLineItem(entry, oppty.Id);
        Test.stopTest();    //2.0
        
        
        TriggerControlHandler.setOpportunityTriggersActive();
        
        
        PageReference pr = new PageReference('apex/ApprovedLOBRegTermsAndConditions?id=' + oppty.id);
        Test.setCurrentPage(pr);
        LOBRegistrationAutoApprovalCtrl controller = new LOBRegistrationAutoApprovalCtrl(new ApexPages.StandardController(oppty));

        system.runAs(u){
            System.debug('SFDC partner user ' + u);
            PageReference actualPR = controller.pageOnLoad();
            system.assertEquals(null, actualPR);
            controller.submitRegistration();
            //controller.standardApprovalProcess();
            system.assertEquals(true, controller.showMessage);
            //Temporary commented system.assertEquals(LOBRegistrationAutoApprovalCtrl.MSG_KEY_AUTO_APPROVED, controller.messageKey);
         
          }
         
    }
    
    private static testMethod void testDEFAULTLOBAUTO(){
        
        TriggerExecutionController.setSkipAllTriggers(True); 
        string countryCode = 'US';
        String defaultCountry = 'UNITED STATES';
        string languageCode = 'ja';
        PartnerLanguage pl = new PartnerLanguage();
        string language = pl.returnMatchValue(languageCode);
        User u = createPartnerUser(countryCode, languageCode);
        string lobName = 'Storage';
        string MSG_CODE_INTERNAL_ERROR;
        
        string partnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Account endUserAccount = createEndUserAccount();
        List<LOB_Administration__c> lobAdminList = [SELECT Id, Name FROM LOB_Administration__c WHERE Name = :lobName];
        LOB_Administration__c lobAdmin = null;
        if((lobAdminList == null) || (lobAdminList.size() == 0)){
            lobAdmin = createLOBAdministration(lobName);
        }else{
            lobAdmin = lobAdminList[0];
        }

        LOB_Registration__c lob = new LOB_Registration__c(Registered_End_User__c = endUserAccount.ID, LOB_registration_status__c = 'Partner(approved)',
                                                            LOB_Name__c = lobAdmin.Name,
                                                            City__c = 'Round Rock',
                                                            State_Province_Region__c = 'Texas',
                                                            Preferred_GTM_Partner_Account__c = partnerAccountId);
        insert lob;        
        Opportunity oppty = createOpportunity(lob, endUserAccount,u);
        Test.startTest();   //2.0
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppty;
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        Product2 product = createProduct('test'); // 'Storage Systems' product code will populate 'Storage' product category
        PricebookEntry entry = createPricebookEntry(product);
        OpportunityLineItem item = createOpportunityLineItem(entry, oppty.Id);
        Test.stopTest();    //2.0
        
        
        TriggerControlHandler.setOpportunityTriggersActive();
        
        
        PageReference pr = new PageReference('apex/ApprovedLOBRegTermsAndConditions?id=' + oppty.id);
        Test.setCurrentPage(pr);
        LOBRegistrationAutoApprovalCtrl controller = new LOBRegistrationAutoApprovalCtrl(new ApexPages.StandardController(oppty));

        system.runAs(u){
            System.debug('SFDC partner user ' + u);
            PageReference actualPR = controller.pageOnLoad();
            system.assertEquals(null, actualPR);
            controller.submitRegistration();
            //controller.standardApprovalProcess();
            system.assertEquals(true, controller.showMessage);
            //Temporary commented system.assertEquals(LOBRegistrationAutoApprovalCtrl.MSG_KEY_AUTO_APPROVED, controller.messageKey);
         
          }
         
    }
    
    
    private static testMethod void testSubmitRegistration2(){
        
        TriggerExecutionController.setSkipAllTriggers(True); 
        string countryCode = 'Tes';
        String defaultCountry = 'UNITED STATES';
        string languageCode = 'ja';
        PartnerLanguage pl = new PartnerLanguage();
        string language = pl.returnMatchValue(languageCode);
        User u = createPartnerUser(countryCode, languageCode);
        string lobName = 'Storage';
        string MSG_CODE_INTERNAL_ERROR;
        
        string partnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Account endUserAccount = createEndUserAccount();
        List<LOB_Administration__c> lobAdminList = [SELECT Id, Name FROM LOB_Administration__c WHERE Name = :lobName];
        LOB_Administration__c lobAdmin = null;
        if((lobAdminList == null) || (lobAdminList.size() == 0)){
            lobAdmin = createLOBAdministration(lobName);
        }else{
            lobAdmin = lobAdminList[0];
        }
        LOB_Registration__c lob = createLOBRegistration(lobAdmin, partnerAccountId,endUserAccount);
        Opportunity oppty = createOpportunity(lob, endUserAccount,u);
        Test.startTest();   //2.0
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppty;
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        Product2 product = createProduct('Storage Systems'); // 'Storage Systems' product code will populate 'Storage' product category
        PricebookEntry entry = createPricebookEntry(product);
        OpportunityLineItem item = createOpportunityLineItem(entry, oppty.Id);
        Test.stopTest();    //2.0
        
        
        TriggerControlHandler.setOpportunityTriggersActive();
        
        LOB_Auto_approval_Administration__c LOBauto = new LOB_Auto_approval_Administration__c();
        LOBauto.name = 'LOB test';
        LOBauto.Language__c ='TestLanguage';
        LOBauto.LOB_Name__c = lobadmin.Id;
        insert LOBauto;

        createLOBAutoApprovalAdministration(lobAdmin.Id, countryCode, language, true);
        PageReference pr = new PageReference('apex/ApprovedLOBRegTermsAndConditions?id=' + oppty.id);
        Test.setCurrentPage(pr);
        LOBRegistrationAutoApprovalCtrl controller = new LOBRegistrationAutoApprovalCtrl(new ApexPages.StandardController(oppty));
        controller.proceedManualApproval();
        controller.exitApproval();
        controller.showCompanyProfile();
        controller.showOpportunityList();

        controller.cancelSubmission();

          system.runAs(u){
            System.debug('SFDC partner user ' + u);
            PageReference actualPR = controller.pageOnLoad();
            system.assertEquals(null, actualPR);
            controller.submitRegistration();
            //controller.standardApprovalProcess();
            system.assertEquals(true, controller.showMessage);
            //Temporary commented system.assertEquals(LOBRegistrationAutoApprovalCtrl.MSG_KEY_AUTO_APPROVED, controller.messageKey);
         
          }
        
    }
    
    
    private static testMethod void noOLI(){
        
        TriggerExecutionController.setSkipAllTriggers(True); 
        string countryCode = 'US';
        String defaultCountry = 'UNITED STATES';
        string languageCode = 'ja';
        PartnerLanguage pl = new PartnerLanguage();
        string language = pl.returnMatchValue(languageCode);
        User u = createPartnerUser(countryCode, languageCode);
        string lobName = 'Storage';
        string MSG_CODE_INTERNAL_ERROR;
        
        string partnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Test.startTest();   //2.0
        Account endUserAccount = createEndUserAccount();
        List<LOB_Administration__c> lobAdminList = [SELECT Id, Name FROM LOB_Administration__c WHERE Name = :lobName];
        LOB_Administration__c lobAdmin = null;
        if((lobAdminList == null) || (lobAdminList.size() == 0)){
            lobAdmin = createLOBAdministration(lobName);
        }else{
            lobAdmin = lobAdminList[0];
        }
        LOB_Registration__c lob = createLOBRegistration(lobAdmin, partnerAccountId,endUserAccount);
        Opportunity oppty = createOpportunity(lob, endUserAccount,u);
        
        oppty.Distributor_Name__c = 'Distribution';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppty;
        Test.stopTest();    //2.0
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        Product2 product = createProduct('Storage Systems'); // 'Storage Systems' product code will populate 'Storage' product category
        PricebookEntry entry = createPricebookEntry(product);
        
        opportunity oppnew=new opportunity();
         
        oppnew.Name = 'oppnew';
        oppnew.Total_Expected_Dell_Revenue__c = 24500.00;
        oppnew.CloseDate = Date.today().addDays(30);
        oppnew.Justification_Statement__c = 'createOpportunity';
        oppnew.End_User_Mailing_City__c = 'City';
        oppnew.End_User_Mailing_State_Province_Region__c = 'Region';
        oppnew.End_User_First_Name__c = 'FN';
        oppnew.End_User_Last_Name__c = 'LN';
        oppnew.Deal_Type__c = 'Fast Track';
        oppnew.End_User_Email__c = 'test@test.com';
        oppnew.End_User_Phone__c = '01-23 45678';
        oppnew.StageName = 'Plan - 1%';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppnew;
        TriggerControlHandler.setOpportunityTriggersActive();
        
        LOB_Auto_approval_Administration__c LOBauto = new LOB_Auto_approval_Administration__c();
        LOBauto.name = 'LOB test';
        LOBauto.Language__c ='English';
        LOBauto.LOB_Name__c = lobadmin.Id;
        insert LOBauto;

        createLOBAutoApprovalAdministration(lobAdmin.Id, countryCode, language, true);
        PageReference pr = new PageReference('apex/ApprovedLOBRegTermsAndConditions?id=' + oppty.id);
        Test.setCurrentPage(pr);
        LOBRegistrationAutoApprovalCtrl controller = new LOBRegistrationAutoApprovalCtrl(new ApexPages.StandardController(oppty));
        controller.proceedManualApproval();
        controller.exitApproval();
        controller.showCompanyProfile();
        controller.showOpportunityList();
        // added on 22nd March, 2016
        controller.submitRegistration();

        
         system.runAs(u){
            System.debug('SFDC partner user ' + u);
            PageReference actualPR = controller.pageOnLoad();
            controller.isRegisteredLOBProduct();
            controller.standardApprovalProcess();
          }

    
    }
    
    private static testMethod void testResellerContactValidation(){
        
        TriggerExecutionController.setSkipAllTriggers(True); 
        string countryCode = 'US';
        string languageCode = 'ja';
        User u = createPartnerUser(countryCode, languageCode);
        string lobName = 'TestLOBAdmin';
        
        string partnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Account endUserAccount = createEndUserAccount();
        LOB_Administration__c lobAdmin = createLOBAdministration(lobName);
        LOB_Registration__c lob = createLOBRegistration(lobAdmin, partnerAccountId,endUserAccount);
        Opportunity oppty = createOpportunity(lob, endUserAccount,u);
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account acc1 = new Account(Name = 'Test Account1',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = 'IN',                                          
                      type='Partner');
        insert acc1;
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        oppty.Distributor_Reseller_Name__c = acc1.id;
        insert oppty;
        Test.stopTest();
        
        PageReference pr = new PageReference('apex/ApprovedLOBRegTermsAndConditions?id=' + oppty.id);
        Test.setCurrentPage(pr);
        LOBRegistrationAutoApprovalCtrl controller = new LOBRegistrationAutoApprovalCtrl(new ApexPages.StandardController(oppty));
        
        system.runAs(u){
            string expectedUrl = '/p/process/Submit?id=' + oppty.id + '&retURL=%2F' + oppty.id;
            try{
                controller.pageOnLoad();
            }catch(Exception e){
                System.debug(e);
                System.assert(e.getMessage().contains('add a required Reseller Contact'));
            }
            
            
        }
    }
    
    private static Account createEndUserAccount(){
        
        TriggerExecutionController.setSkipAllTriggers(True); 
        Account endUserAccount = new Account(Name = 'createAccount', Account_Country_Code__c = 'US', Participating_in_LOB_Program__c = true);
        insert endUserAccount;
        return endUserAccount;      
    }
    
    
    
    private static LOB_Administration__c createLOBAdministration(string lobName){
        LOB_Administration__c lobAdmin = new LOB_Administration__c(Name = lobName);
        insert lobAdmin;
        return lobAdmin;
    }
    
    private static LOB_Registration__c createLOBRegistration(LOB_Administration__c lobAdmin, string partnerAccountId,Account endUserAccount){
        TriggerExecutionController.setSkipAllTriggers(True); 
    //CRQ0241 reminder : uncomment after type change       
        LOB_Registration__c lob = new LOB_Registration__c(Registered_End_User__c = endUserAccount.Id, LOB_registration_status__c = 'Partner(approved)',
                                                            LOB_Name__c = lobAdmin.Name,
                                                            City__c = 'Round Rock',
                                                            State_Province_Region__c = 'Texas',
                                                            Preferred_GTM_Partner_Account__c = partnerAccountId);
        insert lob;
        return lob;
    }
    
    private static Opportunity createOpportunity(LOB_Registration__c lob, Account endUserAccount,User u){
       
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Create New Deal From LOB'];
        Opportunity oppty = new Opportunity(Name = getUniqueString(), Total_Expected_Dell_Revenue__c = 24500.00, CloseDate = Date.today().addDays(30),
                                            Engagement_Type__c = getFirstPicklistValue(Opportunity.Engagement_Type__c.getDescribe()), 
                                            OS_Type__c = getFirstPicklistValue(Opportunity.OS_Type__c.getDescribe()), Justification_Statement__c = 'createOpportunity',
                                            Solution_Scope__c = getFirstPicklistValue(Opportunity.Solution_Scope__c.getDescribe()), 
                                            //7.0 Virtualization__c = getFirstPicklistValue(Opportunity.Virtualization__c.getDescribe()),
                                            End_User_Account_Name__c = endUserAccount.Name,
                                            Total_of_End_of_User_Employees__c = getFirstPicklistValue(Opportunity.Total_of_End_of_User_Employees__c.getDescribe()),
                                            End_User_Mailing_City__c = 'City', End_User_Mailing_State_Province_Region__c = 'Region',
                                            End_User_Mailing_Country__c = getFirstPicklistValue(Opportunity.End_User_Mailing_Country__c.getDescribe()),
                                            End_User_First_Name__c = 'FN', End_User_Last_Name__c = 'LN', End_User_Email__c = 'test@test.com',
                                            End_User_Phone__c = '01-23 45678', End_User_Segment__c = getFirstPicklistValue(Opportunity.End_User_Segment__c.getDescribe()),
                                            Is_the_Customer_Part_of_a_Larger_Group__c = getFirstPicklistValue(Opportunity.Is_the_Customer_Part_of_a_Larger_Group__c.getDescribe()),
                                            StageName = getFirstPicklistValue(Opportunity.StageName.getDescribe()), RecordTypeId = rt.Id, OwnerId = u.Id);


        return oppty;
    }
    
    private static void createLOBAutoApprovalAdministration(Id lobAdminId, string countryCode, string language, boolean enabled){
       
        Id countryId = null;
        List<Country__c> countryList = [SELECT Id FROM Country__c WHERE Code__c = :countryCode];
        if((countryList != null) && (countryList.size() > 0)){
            countryId = countryList[0].Id;
        }else{
            countryId = [SELECT Id FROM Country__c LIMIT 1][0].Id;
        }
        //CRQ0241 reminder : uncomment after type change       
        LOB_Auto_approval_Administration__c autoApprovalAdmin = new LOB_Auto_approval_Administration__c(LOB_Name__c = lobAdminId, Language__c = language,
                                                                Country__c = countryId, Auto_approval_enabled__c = enabled);
        insert autoApprovalAdmin; 
    }
    
    private static Product2 createProduct(string code){
        Product2 product = new Product2(Name = 'Test Product', ProductCode = code,Product_ID__c='123456');
        insert product;
        return product;
    }
    
    private static PricebookEntry createPricebookEntry(Product2 product){
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry entry = new PricebookEntry(UnitPrice = 0.00, Product2Id = product.Id, Pricebook2Id = pricebookId, UseStandardPrice = false, IsActive = true);
        insert entry;
        return entry;
    }

    private static OpportunityLineItem createOpportunityLineItem(PricebookEntry entry, string opptyId){
        OpportunityLineItem item = new OpportunityLineItem(Quantity = 123.0, PricebookEntryId = entry.Id, TotalPrice = 12345.00, OpportunityId = opptyId);
        insert item;
        return item;
    }
    
    private static User createPartnerUser(string accountCountryCode, string userLanguageCode){
                // Create this user with PowerPartner profile,
 
  string accountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Partner Account'][0].Id;
        Account acc = new Account(Name = 'Partner Account', Account_Country_Code__c = accountCountryCode,BillingState='TX', Is_GTM_Partner__c = true, RecordTypeId = accountRTId,Partner_Type__c = 'Distributor (GCC)');//,
                                    //OwnerId = '00530000000n5szAAA'); // TODO: OwnerId
        insert acc;
        acc.IsPartner = true;
        update acc;
 
        // so that the AccountId will be populated as same as the associated Contact's AccountId
         Contact con = new Contact(AccountId = acc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT');
        insert con;

 

     /*   Profile p = [SELECT Id FROM Profile WHERE UserType = 'Greater China PRM Portal User (MOSS)' LIMIT 1];
        //string proid = [SELECT Id FROM Profile WHERE Name = 'R13.1 EMEA PRM Portal User (MOSS)'][0].Id; // TODO: proid // Ver 1.0
        string proid = [SELECT id from profile WHERE Name LIKE '%Greater China PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = userLanguageCode,
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = proid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        return u; */
      
       
        // Create this user with PowerPartner profile,
        // so that the AccountId will be populated as same as the associated Contact's AccountId
     Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        //string proid = [SELECT Id FROM Profile WHERE Name = 'R13.1 EMEA PRM Portal User (MOSS)'][0].Id; // TODO: proid // Ver 1.0
        string proid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = userLanguageCode,
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = proid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        return u; 
    }
    
    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
    
    private static string getFirstPicklistValue(Schema.DescribeFieldResult field){
        string value = null;
        List<Schema.Picklistentry> picklist = field.getPicklistValues();
        for(Schema.Picklistentry pickListValue : picklist){
            value = pickListValue.getValue();
            break; 
        }
        return value;
    } 
}//End of class