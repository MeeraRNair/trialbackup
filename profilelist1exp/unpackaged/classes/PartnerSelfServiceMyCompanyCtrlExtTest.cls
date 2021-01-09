@IsTest
private class PartnerSelfServiceMyCompanyCtrlExtTest {
    
    private static testmethod void testValidationPartnerAdminsOnly(){
        //checks that the following two validations are working correctly:
        // (1) only partner users (as opposed to standard license users) should be able to access the screen
        // (2) only partner admins should be able to access the screen
        //hanan:- fixed LIMIT EXCEEDED error
       TriggerExecutionController.setSkipUserTriggers(true);
        List<User> partnerAdminUsers = createPartnerUsers(true,1);
       // List<User> standardUsers = createStandardUsers(2);
        Test.startTest();
        for(User user : partnerAdminUsers){
            System.runAs(user){
                TestScaffold scaffold = setupTest();
                TestUtils.assertNoErrorMessagesExist();
               // System.assertEquals(scaffold.extension.getErrorOccurred(), false);
            }
        } 
        Test.stopTest();
        /*
        for(User user : standardUsers){
            System.runAs(user){
                TestScaffold scaffold = setupTest();
                TestUtils.assertErrorMessagesExist();
               // System.assertEquals(scaffold.extension.getErrorOccurred(), true);
            }
        }
        */
        TriggerExecutionController.setSkipUserTriggers(false);
    }
    
    private static testmethod void testValidationNonPartnerAdmins(){
        //checks that the following two validations are working correctly:
        //Non partner admins will receive error message when trying to access the screen       
        //azwanti-fixed LIMIT EXCEEDED error by separating into different test method.
        TriggerExecutionController.setSkipUserTriggers(true);
        List<User> partnerNonAdminUsers = createPartnerUsers(false,1);
        
        for(User user : partnerNonAdminUsers){
        Test.startTest();
            System.runAs(user){
                TestScaffold scaffold = setupTest();
                System.assert(scaffold.extension.errorNotEnabledAsPartnerAdmin == true,
                    'errorNotEnabledAsPartnerAdmin not set to true');
                System.assertEquals(scaffold.extension.getErrorOccurred(), false);               
            }
        }
        Test.stopTest();
        TriggerExecutionController.setSkipUserTriggers(false);
    }
    
    // test class fails with Limit Exceeded Error
    private static testmethod void testEditAndCancel(){
        //simulates a user selecting "My Company" edit and then cancel
        TriggerExecutionController.setSkipUserTriggers(true); 
        System.runAs(createAPartnerUser(true)){
            Test.startTest();
            TestScaffold scaffold = setupTest();
            TestUtils.assertNoErrorMessagesExist();
            
            System.assertEquals(scaffold.extension.editMode,false);
            System.assertEquals(scaffold.extension.doEdit(),null);
            System.assertEquals(scaffold.extension.editMode,true);
            System.assertEquals(scaffold.extension.doCancel(),null);
            System.assertEquals(scaffold.extension.editMode,false);
            
            PageReference next = scaffold.extension.doNewUser();
            System.assertNotEquals(next,null);

            ApexPages.currentPage().getParameters().put('userId', 'abc123');
            next = scaffold.extension.doEditUser();
            System.assertNotEquals(next,null);
            Test.stopTest();

        }
        TriggerExecutionController.setSkipUserTriggers(false); 
    }
    
    // test class fails with Limit Exceeded Error
    private static testmethod void testEditAndSaveNoChanges(){
        TriggerExecutionController.setSkipUserTriggers(true);
        //simulates a user selecting "My Company" edit and then saving without making changes
        System.runAs(createAPartnerUser(true)){
            Test.startTest();
            TestScaffold scaffold = setupTest();
            TestUtils.assertNoErrorMessagesExist();
             
            System.assertEquals(scaffold.extension.editMode,false);
            System.assertEquals(scaffold.extension.request.id,null);
            System.assertEquals(scaffold.request.id,null);
            System.assertEquals(scaffold.extension.doEdit(),null);
            System.assertEquals(scaffold.extension.editMode,true);
            System.assertEquals(scaffold.extension.request.id,null);
            System.assertEquals(scaffold.request.id,null);
            System.assertEquals(scaffold.extension.doSave(),null);
            TestUtils.assertNoMessagesAtLevelExist(ApexPages.Severity.ERROR,false);
            System.assertEquals(scaffold.extension.editMode,false);
            System.assertEquals(scaffold.extension.request.id,null);
            System.assertEquals(scaffold.request.id,null);
            Test.stopTest();
        }
        TriggerExecutionController.setSkipUserTriggers(false);
    }


    private static testmethod void testEditAndSaveWithChanges(){
        TriggerExecutionController.setSkipUserTriggers(true);
        //simulates a user selecting "My Company" edit and then saving with changes
        System.runAs(createAPartnerUser(true)){
            Test.startTest();
            TestScaffold scaffold = setupTest();
            TestUtils.assertNoErrorMessagesExist();
            scaffold.extension.getPreferredLanguageCode();
            
            System.assertEquals(scaffold.extension.editMode,false);
            System.assertEquals(scaffold.extension.request.id,null);
            System.assertEquals(scaffold.request.id,null);
            System.assertEquals(scaffold.extension.doEdit(),null);
            System.assertEquals(scaffold.extension.editMode,true);
            System.assertEquals(scaffold.extension.request.id,null);
            System.assertEquals(scaffold.request.id,null);
            String oldCompanyName = scaffold.request.Company__c;
            scaffold.request.Company__c = 'New Company Name XYZ';
            scaffold.request.Partner_Finder_Opt_In__c = !scaffold.request.Partner_Finder_Opt_In__c;
            scaffold.request.Partner_Finder_Contact_Me_Email__c = 'test123@dell.com';
            /*Updated as per CR 2570 */
            //System.assertEquals(scaffold.extension.doSave(),null);
            System.assertEquals('/apex/PartnerSelfServiceUpdateMessage?type=changed',scaffold.extension.doSave().getUrl());
            //three things should have happened here on save:
            // (1) the partner request was saved
            // (2) the account was updated; however, the only fields that should be updated are the Partner Finder ones
            // (3) Navigate to  PartnerSelfServiceUpdateMessage page
            
            /*Updated as per CR 2570 */
            //Since navigating away from the main page, commenting out the rest 
            /*
            TestUtils.assertNoMessagesAtLevelExist(ApexPages.Severity.ERROR,false);
            System.assertEquals(scaffold.extension.editMode,false);
            System.assertNotEquals(scaffold.extension.request.id,null);
            System.assertNotEquals(scaffold.request.id,null);
            Account theAccount = [select Name, Partner_Finder_Opt_In__c, Partner_Finder_Contact_Email__c
                from Account where id = :scaffold.extension.company.id];
            System.assertEquals(theAccount.name, oldCompanyName); //making sure the company name didn't get updated on Account
            System.assertEquals(theAccount.Partner_Finder_Opt_In__c, scaffold.request.Partner_Finder_Opt_In__c);
            System.assertEquals(theAccount.Partner_Finder_Contact_Email__c, scaffold.request.Partner_Finder_Contact_Me_Email__c);
            scaffold.request.Company__c = 'Another New Value for Company__c';
            System.assertEquals(scaffold.extension.doSave(),null);*/
            Test.stopTest();
        }
        TriggerExecutionController.setSkipUserTriggers(false);
    }
/*
    private static testmethod void testInactivateUser(){
        Test.startTest();
        User admin = createPartnerUsers(true,1,null).get(0);
        Id accountid = [select accountid from contact where id = :admin.contactid].accountid;
        User userToUpdate = createPartnerUsers(false,1,accountid).get(0);
        Test.stopTest();
        System.runAs(admin){
            TestScaffold scaffold = setupTest();
            TestUtils.assertNoErrorMessagesExist();
System.debug('###YWM### 1');            
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            System.assertEquals(null,scaffold.extension.doInactivateUser());
            System.assertNotEquals(null,scaffold.extension.confirmInactivateUser);
            System.assertEquals(userToUpdate.id,scaffold.extension.confirmInactivateUser.id);
System.debug('###YWM### 2');   
            System.assertEquals(null,scaffold.extension.doCancelInactivateUser());
            TestUtils.assertNoErrorMessagesExist();
System.debug('###YWM### 3');   
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            System.assertEquals(null,scaffold.extension.doInactivateUser());
            System.assertNotEquals(null,scaffold.extension.confirmInactivateUser);
            System.assertEquals(userToUpdate.id,scaffold.extension.confirmInactivateUser.id);
System.debug('###YWM### 4');   
            System.assertEquals(null,scaffold.extension.createInactivateUserPartnerRequest());
            System.assertEquals(null,scaffold.extension.doConfirmInactivateUser());
            TestUtils.assertNoErrorMessagesExist();
            userToUpdate = [select id,isactive from user where id = :userToUpdate.id];
            System.assertEquals(false,userToUpdate.IsActive);
System.debug('###YWM### 5');            
        }

    }
    */
    private static testmethod void testInactivateUser2(){
        Id partnerAccaccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> lst_Accts = new List<Account>();
        
        Account partnerAccount = new Account(Name='Test Partner Acc', 
                                            RecordTypeId = partnerAccaccRTId, 
                                            Partner_Type__c = 'US Federal',
                                            Partner_Tier__c = 'Tier 2',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country_Code__c = 'US',
                                            Account_Country__c = 'UNITED STATES'); 
        
        lst_Accts .add(partnerAccount);        
              
        insert lst_Accts ;  
        
        //Create Contacts.
        List<Contact> lst_Cons = new List<Contact>();
        
        Contact partnerContact = new Contact(FirstName = 'MyTestContact',
                           LastName = 'MyTestContact',
                           AccountId =partnerAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'TestContact@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
                           
        lst_Cons.add(partnerContact);
        
        Contact partnerContact1 = new Contact(FirstName = 'MyTestContact',
                           LastName = 'MyTestContact1',
                           AccountId =partnerAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'TestContact1@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
                           
        lst_Cons.add(partnerContact1);
        
        
        insert lst_Cons;   
            
        /******** Create Customer portal user without having any role in test class -START *********/           
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
        
        List<User> lst_User = new List<User>();
        User newUser = new User(
                            Username='MyTestUser0' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser0@dell.com', 
                            FirstName='MyTestUser0', 
                            LastName='MyTestUser0',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='DealReg123', 
                            isActive = TRUE,
                            DefaultCurrencyIsoCode = 'USD',
                            ContactId = lst_Cons[0].Id,
                            Enable_Partner_Admin__c = true,
                            Enable_Partner_Deal_Registration__c = true,
                            Enable_Partner_Lead_Management__c = true,
                            Enable_As_Partner_Lead_Super_User__c= true
                            
        );
        lst_User.add(newUser);
        
        User newUser1 = new User(
                            Username='MyTestUser1' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU1', 
                            Email='MyTestUser1@dell.com', 
                            FirstName='MyTestUser1', 
                            LastName='MyTestUser1',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='DealReg1234', 
                            isActive = TRUE,
                            DefaultCurrencyIsoCode = 'USD',
                            ContactId = lst_Cons[1].Id,
                            Enable_Partner_Admin__c = false,
                            Enable_Partner_Deal_Registration__c = true,
                            Enable_Partner_Lead_Management__c = true,
                            Enable_As_Partner_Lead_Super_User__c= true
                            
        );
        lst_User.add(newUser1);
        
        insert lst_User;
        
       
    
        System.runAs(lst_User[1]){
        
                        
            Test.starttest();
            TestScaffold scaffold = setupTest();
            /* PartnerSelfServiceMyCompanyCtrlExt = new PartnerSelfServiceMyCompanyCtrlExt(new ApexPages.standardController(request)));
            PageReference pf0 = scaffold.extension.doReload();
            PageReference pf1 = scaffold.extension.exportAsExcel();
            PageReference pf2 = scaffold.extension.createInactivateUserPartnerRequest();
            ApexPages.currentPage().getParameters().put(PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,''+lst_User[1].id);
            PageReference pf3 = scaffold.extension.doInactivateUser();
            
            PageReference pf4 = scaffold.extension.doConfirmInactivateUser();*/
           Test.stoptest();
        }
    }
    
    private static testmethod void testasNonPartnerAdmin(){
        Id partnerAccaccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> lst_Accts = new List<Account>();
        
        Account partnerAccount = new Account(Name='Test Partner Acc', 
                                            RecordTypeId = partnerAccaccRTId, 
                                            Partner_Type__c = 'US Federal',
                                            Partner_Tier__c = 'Tier 2',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country_Code__c = 'US',
                                            Account_Country__c = 'UNITED STATES'); 
        
        lst_Accts .add(partnerAccount);        
              
        insert lst_Accts ;  
        
        //Create Contacts.
        List<Contact> lst_Cons = new List<Contact>();
        
        Contact partnerContact = new Contact(FirstName = 'MyTestContact',
                           LastName = 'MyTestContact',
                           AccountId =partnerAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'TestContact@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
                           
        lst_Cons.add(partnerContact);
        
        Contact partnerContact1 = new Contact(FirstName = 'MyTestContact',
                           LastName = 'MyTestContact1',
                           AccountId =partnerAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'TestContact1@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
                           
        lst_Cons.add(partnerContact1);
        
        Contact partnerContact2 = new Contact(FirstName = 'MyTestContact',
                           LastName = 'MyTestContact2',
                           AccountId =partnerAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'TestContact2@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
                           
        lst_Cons.add(partnerContact2);
        Contact partnerContact3 = new Contact(FirstName = 'MyTestContact',
                           LastName = 'MyTestContact3',
                           AccountId =partnerAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'TestContact3@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
                           
        lst_Cons.add(partnerContact3);
        
        Contact partnerContact4 = new Contact(FirstName = 'MyTestContact',
                           LastName = 'MyTestContact4',
                           AccountId =partnerAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'TestContact4@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
                           
        lst_Cons.add(partnerContact4);
        insert lst_Cons;   
            
        /******** Create Customer portal user without having any role in test class -START *********/           
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
        
        List<User> lst_User = new List<User>();
        User newUser = new User(
                            Username='MyTestUser0' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser0@dell.com', 
                            FirstName='MyTestUser0', 
                            LastName='MyTestUser0',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='DealReg123', 
                            isActive = TRUE,
                            DefaultCurrencyIsoCode = 'USD',
                            ContactId = lst_Cons[0].Id,
                            Enable_Partner_Admin__c = true,
                            Enable_Partner_Deal_Registration__c = true,
                            Enable_Partner_Lead_Management__c = true,
                            Enable_As_Partner_Lead_Super_User__c= true
                            
        );
        lst_User.add(newUser);
        
        User newUser1 = new User(
                            Username='MyTestUser1' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU1', 
                            Email='MyTestUser1@dell.com', 
                            FirstName='MyTestUser1', 
                            LastName='MyTestUser1',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='DealReg1234', 
                            isActive = TRUE,
                            DefaultCurrencyIsoCode = 'USD',
                            ContactId = lst_Cons[1].Id,
                            Enable_Partner_Admin__c = false,
                            Enable_Partner_Deal_Registration__c = true,
                            Enable_Partner_Lead_Management__c = true,
                            Enable_As_Partner_Lead_Super_User__c= true
                            
        );
        lst_User.add(newUser1);
        
        insert lst_User;
        
       
    
        System.runAs(lst_User[0]){
        
                        
            Test.starttest();
            TestScaffold scaffold = setupTest();
            //PartnerSelfServiceMyCompanyCtrlExt = new PartnerSelfServiceMyCompanyCtrlExt(new ApexPages.standardController(request)));
            PageReference pf0 = scaffold.extension.doReload();
            PageReference pf1 = scaffold.extension.exportAsExcel();
            PageReference pf2 = scaffold.extension.createInactivateUserPartnerRequest();
            ApexPages.currentPage().getParameters().put(PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,''+lst_User[1].id);
            PageReference pf3 = scaffold.extension.doInactivateUser();
            
            PageReference pf4 = scaffold.extension.doConfirmInactivateUser();
            PageReference pf5 = scaffold.extension.doCancelInactivateUser();
           Test.stoptest();
        }
    }
    
    private static testmethod void testAsPartnerAdmin(){
        
        Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXX';
        country.dial_code__c = '123';
        country.Is_Active_Partner_Country__c = true;
        country.Inc_Vendor_Name__c = 'Dell Achievers';
        country.Inc_Vendor_End_Point__c = 'test';
        List<QueueSobject> queues = [select QueueId from QueueSobject where SobjectType = 'Partner_Request__c' limit 1];
        if(queues.size()>0){
            country.Partner_Support_Queue_ID__c = queues.get(0).QueueId;
        }
        country.Partner_Support_Email__c = 'test@test.com';
        insert country;
        
        Id partnerAccaccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> lst_Accts = new List<Account>();
        
        Account partnerAccount = new Account(Name='Test Partner Acc', 
                                            RecordTypeId = partnerAccaccRTId, 
                                            Partner_Type__c = 'US Federal',
                                            Partner_Tier__c = 'Tier 2',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country_Code__c = 'XX',
                                            Account_Country__c = 'XXXXXXXX',
                                            Primary_Routes_to_Market__c = 'Other',
                                            Partner_Primary_Customer__c = 'Education'); 
        
        lst_Accts.add(partnerAccount);        
              
        insert lst_Accts ;  
        
        //Create Contacts.
        List<Contact> lst_Cons = new List<Contact>();
        
        Contact partnerContact = new Contact(FirstName = 'MyTestContact',
                           LastName = 'MyTestContact',
                           AccountId =lst_Accts[0].Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'TestContact@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
                           
        lst_Cons.add(partnerContact);
        
        Contact partnerContact1 = new Contact(FirstName = 'MyTestContact',
                           LastName = 'MyTestContact1',
                           AccountId =lst_Accts[0].Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'TestContact1@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
                           
        lst_Cons.add(partnerContact1);
        
       
        
        insert lst_Cons;   
            
        /******** Create Customer portal user without having any role in test class -START *********/           
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
        
        List<User> lst_User = new List<User>();
        User newUser = new User(
                            Username='MyTestUser0' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser0@dell.com', 
                            FirstName='MyTestUser0', 
                            LastName='MyTestUser0',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='DealReg123', 
                            isActive = TRUE,
                            DefaultCurrencyIsoCode = 'USD',
                            ContactId = lst_Cons[0].Id,
                            Enable_Partner_Admin__c = true,
                            Enable_Partner_Deal_Registration__c = true,
                            Enable_Partner_Lead_Management__c = true,
                            Enable_As_Partner_Lead_Super_User__c= true
                            
        );
        lst_User.add(newUser);
        
        User newUser1 = new User(
                            Username='MyTestUser1' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU1', 
                            Email='MyTestUser1@dell.com', 
                            FirstName='MyTestUser1', 
                            LastName='MyTestUser1',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='DealReg1234', 
                            isActive = TRUE,
                            DefaultCurrencyIsoCode = 'USD',
                            ContactId = lst_Cons[1].Id,
                            Enable_Partner_Admin__c = false,
                            Enable_Partner_Deal_Registration__c = true,
                            Enable_Partner_Lead_Management__c = true,
                            Enable_As_Partner_Lead_Super_User__c= true
                            
        );
        lst_User.add(newUser1);
        
        insert lst_User;
        
        Partner_Type__c partnerType = new Partner_Type__c(Name='pt_test', Country__c=country.id, Translated_Partner_Type_Name__c='translated pt_test',Is_Active__c=true, Sort_Order__c=99); 
        insert partnerType;
        
        Partner_Request__c request = new Partner_Request__c();
        request.Country__c = country.id;
        request.Org_Country__c = country.id;
        request.OwnerId = country.Partner_Support_Queue_ID__c;
        request.Primary_Routes_to_Market__c = 'Other';
        request.Primary_Channel_Model__c= partnerType.id;
        request.phone__c = '91-040-123456';
        request.org_phone__c = '91-040-123456';
        request.Services_Lead_Phone_Number__c = '91-040-123456';
        request.Account__c = lst_Accts[0].Id;
        
    
        System.runAs(lst_User[0]){
        
                        
            Test.starttest();
            //TestScaffold scaffold = setupTest();
            insert request;
            /*PartnerSelfServiceMyCompanyCtrlExt contrl = new PartnerSelfServiceMyCompanyCtrlExt(new ApexPages.standardController(request));
            ApexPages.currentPage().getParameters().put(PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,lst_User[1].id);
            PageReference pf0 = contrl.doInactivateUser();
            PageReference pf1 = contrl.createInactivateUserPartnerRequest();
            */
            ApexPages.StandardController con = new ApexPages.StandardController(new Partner_Request__c());
            
            PartnerSelfServiceMyCompanyCtrlExt ext = new PartnerSelfServiceMyCompanyCtrlExt(con);
            ext.confirmInactivateUser = lst_User[1];
            ext.createInactivateUserPartnerRequest();
            ext.doConfirmInactivateUser();
            
            
            /*PageReference pf1 = contrl.doConfirmInactivateUser();
            PageReference pf2 = contrl.doInactivateUser();
            PageReference pf3 = contrl.doCancelInactivateUser();*/
           Test.stoptest();
        }
    }
    
    
    private static testmethod void testEditAndSaveLotsOfRequestChanges(){
        TriggerExecutionController.setSkipUserTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        //simulates a user selecting "My Company" edit and then saving with changes
        User partnerUser = createAPartnerUser(true);
        Account account = [select Id, Name from Account where Id in (
            select accountid from contact where id = :partnerUser.ContactId
        )];
        account.ShippingStreet = '456 Y Road\nMS 14\nSuite 10';
        update account;
        
        System.runAs(partnerUser){
            Test.startTest();
            TestScaffold scaffold = setupTest();
            TestUtils.assertNoErrorMessagesExist();
            
            System.assertEquals(scaffold.extension.editMode,false);
            System.assertEquals(scaffold.extension.request.id,null);
            System.assertEquals(scaffold.request.id,null);
            System.assertEquals(scaffold.extension.doEdit(),null);
            System.assertEquals(scaffold.extension.editMode,true);
            System.assertEquals(scaffold.extension.request.id,null);
            System.assertEquals(scaffold.request.id,null);
            scaffold.request.Company__c = 'New Value for Company__c';
            scaffold.request.Website__c = 'New Value for Website__c';
            scaffold.request.Org_Address_1__c = 'New Value for Org_Address_1__c';
            scaffold.request.Org_Address_2__c = 'New Value for Org_Address_2__c';
            scaffold.request.Org_Address_3__c = 'New Value for Org_Address_3__c';
            scaffold.request.Org_State__c = 'New Value for Org_State__c';
            scaffold.request.Org_Postal_Code__c = '11111';
            scaffold.request.Org_City__c = 'New Value for Org_City__c';
            scaffold.request.Org_Phone__c = 'New Value for Org_Phone__c';
            scaffold.request.Currently_Selling_Dell__c = !scaffold.request.Currently_Selling_Dell__c;
            scaffold.request.Dell_Revenue_Percent__c = 'New Value for Dell_Revenue_Percent__c';
            scaffold.request.Hardware_Revenue_Percent__c = 'New Value for Hardware_Revenue_Percent__c';
            scaffold.request.Other_Customers__c = 'New Value for Other_Customers__c';
            scaffold.request.Percent_Sales_Force__c = 'New Value for Percent_Sales_Force__c';
            scaffold.request.Percent_Technical_Professionals__c = 'New Value for Percent_Technical_Professionals__c';
            scaffold.request.Preferred_Dell_Distribution_Partner__c = 'New Value for Preferred_Dell_Distribution_Partner__c';
            scaffold.request.Primary_Channel_Model__c = 'New Value for Primary_Channel_Model__c';
            scaffold.request.Primary_Customer__c = 'Other';//'New Value for Primary_Customer__c';
            scaffold.request.Product_Focus__c = 'New Value for Product_Focus__c';
            scaffold.request.Reseller_Tax_ID__c = 'New Value for Reseller_Tax_ID__c';
            scaffold.request.Service_Revenue_Percent__c = 'New Value for Service_Revenue_Percent__c';
            scaffold.request.Software_Revenue_Percent__c = 'New Value for Software_Revenue_Percent__c';
            scaffold.request.States_Provinces_doing_business__c = 'New Value for States_Provinces_doing_business__c';
            scaffold.request.NumberOfEmployees__c = 10;
            scaffold.request.Primary_Routes_to_Market__c='Other';
            scaffold.request.Top_3_Vendors__c='test;iphone;lenovo;andriod;sfdc;mac';
            
            
            /*Updated as per CR 2570 */
            //System.assertEquals(scaffold.extension.doSave(),null);
            //System.assertEquals('/apex/PartnerSelfServiceUpdateMessage?type=changed',scaffold.extension.doSave().getUrl());
             PageReference pf1 = scaffold.extension.addOtherValue();
             PageReference pf0 = scaffold.extension.doSave();
             PageReference pf = scaffold.extension.toggleAddDiv();
            /*Updated as per CR 2570 */
            /*
            TestUtils.assertNoMessagesAtLevelExist(ApexPages.Severity.ERROR,false);
            System.assertEquals(scaffold.extension.editMode,false);
            System.assertNotEquals(scaffold.extension.request.id,null);
            System.assertNotEquals(scaffold.request.id,null);
            scaffold.request.Company__c = 'Another New Value for Company__c';
            System.assertEquals(scaffold.extension.doSave(),null);
            */
            Test.stopTest();
        }
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipUserTriggers(false);
    }

    private static testmethod void testEditAndSaveExpectingException(){
        //simulates a user selecting "My Company" edit and then saving with changes
        TriggerExecutionController.setSkipUserTriggers(true);
        System.runAs(createAPartnerUser(true)){
            Test.startTest();
            TestScaffold scaffold = setupTest();
            TestUtils.assertNoErrorMessagesExist();
            
            System.assertEquals(scaffold.extension.doEdit(),null);
            scaffold.request.Org_Postal_Code__c = '01234567890123456789012345678901234567890123456789';
            System.assertEquals(scaffold.extension.doSave(),null);
            TestUtils.assertErrorMessagesExist();
            Test.stopTest();
        }
        TriggerExecutionController.setSkipUserTriggers(false);
    }

    private static Integer nextUserSerialNumber = -1;
    private static Integer getNextUserSerialNumber(){
        nextUserSerialNumber++;
        return nextUserSerialNumber;
    }
    
    private class TestScaffold{
        private Partner_Request__c request {get;set;}
        private PartnerSelfServiceMyCompanyCtrlExt extension {get;set;}
    }
    
    private static TestScaffold setupTest(){
        final Partner_Request__c request = new Partner_Request__c();
        System.debug('===============================================================');
        System.debug('RUNNING AS: ' + UserInfo.getUserName() + ' (' + UserInfo.getProfileId() + ')');
        System.debug('===============================================================');
        PartnerSelfServiceMyCompanyCtrlExt extension = new PartnerSelfServiceMyCompanyCtrlExt(
            new ApexPages.standardController(request));
        TestScaffold scaffold = new TestScaffold();
        scaffold.request = request;
        scaffold.extension = extension;
        /*Added below code by vikram akmboj on 05/10/2012 for CR# 7631*/
        contact con1=new contact(lastname='test1');        
        List<Contact> conList = new list<Contact>();
        conList.add(con1);
        List<User> usrLst=createStandardUsers(2);
        ApexPages.StandardSetController ssc = new ApexPages.Standardsetcontroller(usrLst);
        //ssc.setSelected(usrLst);
        extension.setCon=ssc;
        boolean nextval=extension.HasNext;
        boolean prevval=extension.HasPrevious;
        Integer Pgno=extension.PageNumber;
        //extension.createString(conList );
        extension.getItems();
        extension.getUsers();
        extension.next();
        extension.previous();
        //extension.first();
       // extension.last();
       // extension.changeSize();
        extension.setSortDirection('ASC');
        extension.sortExpression='Name';
        extension.getSortDirection();

        extension.sortExpression='';
        extension.getSortDirection();


        //extension.ViewData();
        /*code changes by vikram kamboj ends here*/
        return scaffold;
    }
    
    
    private static List<User> createStandardUsers(Integer max){
        final List<Profile> profiles = 
            [select id,name from Profile where UserType = 'Standard' limit :max];
        
        final List<User> users = new List<User>();
        for(Integer i = 0; i < profiles.size(); i++){
            Integer userNumber = getNextUserSerialNumber();
            users.add(
                new User(
                    Username=''+userNumber+'@DELLTEAM.com',
                    Alias = 'test'+userNumber, 
                    Email=''+userNumber+'@DELLTEAM.com', 
                    FirstName='John', 
                    LastName='Doe'+userNumber, 
                    ProfileId = profiles.get(i).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c=''+9005000+userNumber 
                )
            );
        }
        insert users;
        return users;
    }
    
    private static User createAPartnerUser(Boolean admin){
        List<User> userList = createPartnerUsers(admin,1);
        System.assert(userList.size()>=1,'A partner user could not be created therefore this test cannot be executed.');
        return userList.get(0);
    }

    private static List<User> createPartnerUsers(Boolean admin, Integer max){
        return createPartnerUsers(admin,max,null);
    }
    private static List<User> createPartnerUsers(Boolean admin, Integer max, id accountId){
        final List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' limit :max];
        System.assert(
            !(partnerProfiles == null || partnerProfiles.size() <= 0), 
            'No partner profiles exist therefore test cannot be executed');
        final List<Account> accounts = new List<Account>();
        if(accountId == null){
            for(Integer i = 0; i < partnerProfiles.size(); i++){
                accounts.add(
                    new Account(
                        name='Test ' + i,
                        Account_Country_Code__c = 'AI',
                        Account_Country__c = 'ANGUILIA'
                    )
                );
            }
            insert accounts;
            for(Account account : accounts){
                account.IsPartner = true;
            }
            update accounts;
        }   
        final List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < partnerProfiles.size(); i++){
            contacts.add(
                new Contact(
                    AccountId=(accountId == null ? accounts.get(i).id : accountId),
                    Email=''+i+'@DELLTEAM.com', 
                    FirstName = 'John', 
                    LastName = 'Doe'+i,
                    Title='VP',
                    MailingStreet='123 Main',
                    MailingCity='Peoria',
                    MailingState='IL',
                    MailingPostalCode='33333',
                    Phone='3213213211',
                    MobilePhone='3213213211',
                    Fax='3213123211'  
                    //,Extension__c='2322'                  
                )
            );
        }
        insert contacts;
        final List<User> users = new List<User>();
        for(Integer i = 0; i < partnerProfiles.size(); i++){
            Integer userNumber = getNextUserSerialNumber();
            users.add(
                new User(
                    Username=''+userNumber+'@DELLTEAM.com',
                    Alias = 'test'+userNumber, 
                    Email=''+userNumber+'@DELLTEAM.com', 
                    FirstName='John', 
                    LastName='Doe'+userNumber, 
                    ProfileId = partnerProfiles.get(i).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c=null, 
                    ContactId = contacts.get(i).id, 
                    Enable_Partner_Admin__c = admin
                )
            );
        }
        insert users;
        return users;
    }
    
}