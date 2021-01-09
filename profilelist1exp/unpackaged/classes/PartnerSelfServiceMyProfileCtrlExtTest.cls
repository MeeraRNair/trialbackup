/* 
    Bikram   14-02013       Removed Field Is Country Enabled for Incentives R14.2 SSO
    Ariff    14 Jan 2013    Update testEnableForEnable() to include update country vendor name
    
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
3.0         Fenny       24-Oct-2014     R15.10              VR Validate_Other_Phone_format require OtherPhone fields of Contact object to be filled
3.1       Jatin Puri 6-June-2018:   FY19-DCS-0802  16018     Decommisioned netexam and Feature_Request_Training__c as part of story# 4988542
    
*/
@IsTest
private class PartnerSelfServiceMyProfileCtrlExtTest {

    private static testmethod void testStdUserValidationError(){
        
        System.runAs(createStandardUsers(1).get(0)){
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(new Partner_Request__c()));
            
            System.assertEquals(extension.ACCESS_DENIED_STANDARD_LICENSE_USER,extension.errorCode);         
        }      
    } 
    
    private static testmethod void testAdminCreateNewUser(){        
        User user = createPartnerUsers(true,1,null).get(0);
        System.runAs(user){

            //create controller extension
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_CANCELURL,'/123');
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_NEWFLAG,'true');
            
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(true,extension.isCurrentUserPartnerAdmin);          
            System.assertEquals(true,extension.isNewUser);          
            System.assertEquals(true,extension.editMode);
            System.assertEquals(false,extension.isConfirmEmailChange);
            System.assertEquals(IdLookupUtils.getRecordTypeId(
                    PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER, 'Partner_Request__c', true),
                    request.RecordTypeId);
                        
            System.assertEquals('/123',extension.doCancel().getUrl());
            
            request.First_Name__c = 'John';
            request.Last_Name__c = 'Doe';
            request.Job_Title__c = 'VP';
            request.Address_Line_1__c = '123 Main';
            request.City__c = 'Peoria';
            request.State__c = 'IL';
            request.Postal_Code__c = '22222';
            request.Phone__c = '3213213211';
            request.Email__c = 'test@test.com';

            //extension.isTest = true; //raymond CR2421
            //CR2087
            //System.assertEquals(null,extension.doSave());
            String actualURL = extension.doSave().getURL();
            System.assertEquals('/apex/PartnerRegistrationProvisionUser?id='+request.id,actualURL);
            
            TestUtils.assertNoErrorMessagesExist();

            //extension.synchronizeToCMIandNetExamForTest();    

        }
    }

    private static testmethod void testAdminCreateNewUserNoChangesErrorValidation(){
        User user = createPartnerUsers(true,1,null).get(0);
        System.runAs(user){
            
            //create controller extension
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_NEWFLAG,'true');
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(true,extension.isCurrentUserPartnerAdmin);          
            System.assertEquals(true,extension.isNewUser);          
            System.assertEquals(true,extension.editMode);
            System.assertEquals(IdLookupUtils.getRecordTypeId(
                    PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER, 'Partner_Request__c', true),
                    request.RecordTypeId);
                    
            System.assertEquals(Page.PartnerSelfServiceMyProfile.getUrl(),extension.doCancel().getUrl());
                        
            //CR2087
            //System.assertEquals(null,extension.doSave());
            String actualURL = extension.doSave().getURL();
            System.assertEquals('/apex/PartnerRegistrationProvisionUser?id='+request.id,actualURL); 
            //TestUtils.assertErrorMessagesExist();
            
            
            //Modified by Bahar, Ariff (20121204)
            //to test enable for incentives field. Will return false because when account is created, both Is_Enabled_for_Incentives__c and Is_Country_Enabled__c is false. 
            System.assertEquals(false, extension.visible_Incentive);
            
        }
    }
    
    
    //Modified by Bahar, Ariff (20121204)
    private static testMethod void testEnableForIncentiveEnable(){
        User testUser = createPartnerUsers(true,1,null).get(0);
        
        //Update Is_Enabled_for_Incentives__c and Is_Country_Enabled__c and set it to true
        
        Country__c testCountryObject = new Country__c(name='ANGUILIA', Dell_Online_Country_Code__c='AA',Code__c='AA',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold');
        insert testCountryObject; 
        
        Id accountid = [select accountid from contact where id = :testUser.contactid].accountid;
        account accountObject = [select Is_Enabled_for_Incentives__c, Account_Country_Code__c from account where id = :accountid];
        accountObject.Is_Enabled_for_Incentives__c=true;
        accountObject.Vendor_Update_Datetime__c = system.today();
        update accountObject;
        
        PartnerCountry pc = new PartnerCountry();
        Map<string, Country__c> countryMap = pc.returnCountryCodeMap();
        //Country__c countryObject = countryMap.get(StringUtils.uppercase((accountObject.Account_Country_Code__c).trim()));
        Country__c countryObject = [Select Inc_Vendor_Name__c,Inc_Vendor_End_Point__c from Country__c where code__c='AA'];
        countryObject.Inc_Vendor_Name__c = 'Partner Advantage';
        countryObject.Inc_Vendor_End_Point__c = 'Service End Point BI EU';
       
        update countryObject;
        
        System.runAs(testUser){
            //create controller extension
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_NEWFLAG,'true');
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
           
            //System.assertEquals(true, extension.visible_Incentive);
        }
    }
    
    
    private static testmethod void testNonAdminCreateNewUserErrorValidation(){
        User user = createPartnerUsers(false,1,null).get(0);
        System.runAs(user){
            
            //create controller extension
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_NEWFLAG,'true');
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            System.assertEquals(extension.ACCESS_DENIED_PARTNER_USER_NOT_ADMIN,extension.errorCode);  
            System.assertNotEquals(null,extension.partnerAdminsForAccount);         
        }
    }
    
    private static testmethod void testAdminUpdateAnotherUserWithMultilineAddress(){
        TriggerExecutionController.setSkipAllTriggers(true);
        User admin = createPartnerUsers(false,1,null).get(0);
        Id accountid = [select accountid from contact where id = :admin.contactid].accountid;
        User userToUpdate = createPartnerUsers(true,1,accountid).get(0);
        Contact contact = [select MailingStreet,Id from contact where id = :userToUpdate.ContactId];
        contact.MailingStreet = '123 main\npo box a\nsuite123';
        Test.StartTest();
        update contact;
        
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
            //System.assertEquals(true,extension.isCurrentUserPartnerAdmin);          
            System.assertEquals(false,extension.isNewUser);         
            //System.assertEquals(IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER, 'Partner_Request__c', true),request.RecordTypeId);
       
            request.Salutation__c = request.Salutation__c + 'abc';
            request.First_Name__c = request.First_Name__c + 'abc';
            request.Last_Name__c = request.Last_Name__c + 'abc';
            request.Job_Title__c = request.Job_Title__c + 'abc';
            request.Address_Line_1__c = request.Address_Line_1__c + 'abc';
            request.City__c = request.City__c + 'abc';
            request.State__c = request.State__c + 'abc';
            request.Postal_Code__c = request.Postal_Code__c + 'abc';
            //request.Phone__c = request.Phone__c + 'abc'; // 3.0
            request.Phone__c = request.Phone__c + '123'; // 3.0
            request.Mobile__c = request.Mobile__c + 'abc';
            request.Fax__c = request.Fax__c + 'abc';
            //request.Email__c = request.Email__c + 'abc';
            //System.assertEquals(null,extension.doSave());
            System.assertNotEquals(true,extension.isConfirmEmailChange);
            extension.doCancelNewUser();
            extension.getRequestId();
            //extension.doPermissionSetAssignment();
            //extension.synchronizeNetExam();
            //extension.setIncompletForRequestWithReason(request);
            
            TestUtils.assertNoErrorMessagesExist();
            
            System.assertEquals(Page.PartnerSelfServiceMyProfile.getUrl(),extension.doOK().getUrl());
            
        }
        Test.stopTest();  
        TriggerExecutionController.setSkipAllTriggers(false);

    }
    
    private static testmethod void testAdminUpdateAnotherUserNullContactAddress(){
        User admin = createPartnerUsers(true,1,null).get(0);
        Id accountid = [select accountid from contact where id = :admin.contactid].accountid;
        User userToUpdate = createPartnerUsers(false,1,accountid).get(0);
        Contact contact = [select MailingStreet,Id from contact where id = :userToUpdate.ContactId];
        contact.MailingStreet = null;
        Test.StartTest();
        update contact;
        System.debug('after updating contact');
        
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(true,extension.isCurrentUserPartnerAdmin);          
            System.assertEquals(false,extension.isNewUser); 
            System.debug('isnewuser executing');        
            System.assertEquals(IdLookupUtils.getRecordTypeId(
                    PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER, 'Partner_Request__c', true),
                    request.RecordTypeId);
                    
            request.Salutation__c = request.Salutation__c + 'abc';
            request.First_Name__c = request.First_Name__c + 'abc';
            request.Last_Name__c = request.Last_Name__c + 'abc';
            request.Job_Title__c = request.Job_Title__c + 'abc';
            request.Address_Line_1__c = request.Address_Line_1__c + 'abc';
            request.City__c = request.City__c + 'abc';
            request.State__c = request.State__c + 'abc';
            request.Postal_Code__c = request.Postal_Code__c + 'abc';
            //request.Phone__c = request.Phone__c + 'abc'; // 3.0
            request.Phone__c = request.Phone__c + '123'; // 3.0
            request.Mobile__c = request.Mobile__c + 'abc';
            request.Fax__c = request.Fax__c + 'abc';
            request.Newsletter_Opt_In__c = !request.Newsletter_Opt_In__c;
            request.Enable_As_Partner_Admin__c = !request.Enable_As_Partner_Admin__c;
            request.Enable_for_Bid_Builder__c = !request.Enable_for_Bid_Builder__c;
            //request.Email__c = 'test@mail.com';
            System.assertEquals(null,extension.doSave());

            System.debug('after dosave()');
            //TestUtils.assertNoErrorMessagesExist();
            
            System.assertEquals(Page.PartnerSelfServiceMyProfile.getUrl(),extension.doOK().getUrl());
            
            request.Feature_Request_Lead_Management__c = false;
            
            
        }
        Test.stopTest();       
    }
    
    private static testmethod void testAdminUpdateAnotherUserNotInSameAccount(){
        // Skip all the triggers to avoid Too Many SOQL Query issue
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Test.startTest();
        User admin = createPartnerUsers(true,1,null).get(0);
        User userToUpdate = createPartnerUsers(false,1,null).get(0);
        
        // Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);

        
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            TestUtils.assertErrorMessagesExist();
        }       
        Test.stopTest();
    }
    
    private static testmethod void testNonAdminUpdateAnotherUserErrorValidation(){
        User admin = createPartnerUsers(true,1,null).get(0);
        Id accountid = [select accountid from contact where id = :admin.contactid].accountid;
        User userToUpdate = createPartnerUsers(false,1,accountid).get(0);
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            //System.assertEquals(extension.ACCESS_DENIED_PARTNER_USER_NOT_ADMIN,extension.errorCode);            
            //System.assertNotEquals(null,extension.partnerAdminsForAccount);         
        }       
    }
    
    private static testmethod void testAdminUpdateAnotherUserWhichDoesntExist(){
        User admin = createPartnerUsers(true,1,null).get(0);
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,'0123456789012345');
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            TestUtils.assertErrorMessagesExist();
        }       
    }
    
    private static testmethod void testNonAdminUpdateProfile(){
        User user = createPartnerUsers(false,1,null).get(0);
        
        //raymond: added is_Rebate_user__c
        Contact contact = [select id,Salutation,FirstName,LastName,Title,MailingStreet,
            MailingCity,MailingState,MailingPostalCode,Phone,MobilePhone,Fax,Email,
            Email_Opt_in__c, Is_Rebate_User__c from Contact where id = :user.ContactId];
        System.runAs(user){
            
            Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'US23U', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
                                                insert testCountry;
            Test.startTest();
            //create controller extension
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            extension.countryObj = testCountry;
            TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(false,extension.isCurrentUserPartnerAdmin);         
            System.assertEquals(false,extension.isNewUser);         
            System.assertEquals(false,extension.editMode);
            extension.getPreferredLanguageCode();

            System.assertEquals(null,extension.doEdit());
            System.assertEquals(true,extension.editMode);

            System.assertEquals(contact.Salutation,request.Salutation__c);
            System.assertEquals(contact.FirstName,request.First_Name__c);
            System.assertEquals(contact.LastName,request.Last_Name__c);
            System.assertEquals(contact.Title,request.Job_Title__c);
            System.assertEquals(contact.MailingCity,request.City__c);
            System.assertEquals(contact.MailingState,request.State__c);
            System.assertEquals(contact.MailingPostalCode,request.Postal_Code__c);
            System.assertEquals(contact.Phone,request.Phone__c);
            System.assertEquals(contact.MobilePhone,request.Mobile__c);
            System.assertEquals(contact.Fax,request.Fax__c);
            System.assertEquals(contact.Email,request.Email__c);
            System.assertEquals(user.Enable_Partner_Admin__c,request.Enable_As_Partner_Admin__c);
            
            //raymond: added for Rebate CR1773
            System.assertEquals(contact.Is_Rebate_User__c, request.Feature_Request_Rebates__c);

            //make some changes
            request.Salutation__c = request.Salutation__c + 'abc';
            request.First_Name__c = request.First_Name__c + 'abc';
            request.Last_Name__c = request.Last_Name__c + 'abc';
            request.Job_Title__c = request.Job_Title__c + 'abc';
            request.Address_Line_1__c = request.Address_Line_1__c + 'abc';
            request.Address_Line_2__c = request.Address_Line_2__c + 'abc';
            request.Address_Line_3__c = request.Address_Line_3__c + 'abc';
            request.City__c = request.City__c + 'abc';
            request.State__c = request.State__c + 'abc';
            request.Postal_Code__c = request.Postal_Code__c + 'abc';
            //request.Phone__c = request.Phone__c + 'abc'; // 3.0
            request.Phone__c = request.Phone__c + '123'; // 3.0
            request.Mobile__c = request.Mobile__c + 'abc';
            request.Fax__c = request.Fax__c + 'abc';
            //request.Email__c =  'test@mail.com' + request.Email__c;
            
            
            //save changes
            System.assertEquals(false,extension.isSaved);           
            System.assertEquals(null,extension.doSave());
            TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(null,extension.errorCode);          
            //System.assertEquals(true,extension.isSaved);          
            System.assertNotEquals(null,request.id);            
            Test.stopTest();
        }
    }

    private static Integer nextUserSerialNumber = -1;
    private static Integer getNextUserSerialNumber(){
        nextUserSerialNumber++;
        return nextUserSerialNumber;
    }
    
    private static List<User> createStandardUsers(Integer max){
        final List<Profile> profiles = 
            [select id,name from Profile where UserType = 'Standard' and Profile.name = 'System Administrator'  limit :max];
        
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
    
    private static List<User> createPartnerUsers(Boolean admin, Integer max, id accountId){
        TriggerExecutionController.setSkipAllTriggers(true);
        final List<Profile> partnerProfiles = 
            [select id,name from Profile where UserType = 'PowerPartner' limit :max];
        System.assert(
            !(partnerProfiles == null || partnerProfiles.size() <= 0), 
            'No partner profiles exist therefore test cannot be executed');
        final List<Account> accounts = new List<Account>();        
        if(accountId == null){
            for(Integer i = 0; i < partnerProfiles.size(); i++){
                accounts.add(
                    new Account(
                        name='Test ' + i,
                        Account_Country_Code__c = 'AA'+i,
                        Account_Country__c = 'ANGUILIA'+i
                    )
                );
            }
            insert accounts;
            for(Account account : accounts){
                account.IsPartner = true;                                  
            }
            update accounts;
        }
        final List<Country__c> testCountry = new List<Country__c>();
        if(admin){
        for(Integer i=0; i < partnerProfiles.size(); i++){
            testCountry.add(
                new country__c(
                    name = 'TEST COUNTRY'+i, Code__c = 'TY01', Region__c = 'APJ',
                    Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',
                    Inc_Vendor_Name__c='Not Applicable/On Hold',Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',
                    Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All'));
            }            
            insert testCountry;
            for(country__c country : testCountry){
                country.Training_Enabled__c = 'No';
            }
            update testCountry;
        }
        else{
            for(Integer i=0; i < partnerProfiles.size(); i++){
            testCountry.add(
                new country__c(
                    name = 'TEST COUNTRY'+i, Code__c = 'USR0', Region__c = 'APJ',
                    Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',
                    Inc_Vendor_Name__c='Not Applicable/On Hold',Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',
                    Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All'));
            }            
            insert testCountry;
            for(country__c country : testCountry){
                country.Training_Enabled__c = 'No';
            }
            update testCountry;
        }
         
        
        final List<Contact> contacts = new List<Contact>();
        if(admin){
        for(Integer i = 0; i < partnerProfiles.size(); i++){
            contacts.add(
                new Contact(
                    AccountId=(accountId == null ? accounts.get(i).id : accountId),
                    Email=''+i+'@DELLTEAM.com', 
                    FirstName = 'John'+i, 
                    LastName = 'Doe'+i,
                    Title='VP',
                    MailingStreet='123 Main',
                    MailingCity='Peoria',
                    MailingState='IL',
                    MailingPostalCode='33333'+i,
                    Phone='3213213211'+i,
                    OtherPhone='3213213211'+i, // 3.0
                    MobilePhone='3213213211'+i,
                    Fax='3213123211'+i,
                    Status__c = 'Marketing Suspect'
                  
                )
            );
        }
        insert contacts;
        }
        else{
            for(Integer i = 0; i < partnerProfiles.size(); i++){
            contacts.add(
                new Contact(
                    AccountId=(accountId == null ? accounts.get(i).id : accountId),
                    Email='aol'+i+'@DELLTEAM.com', 
                    FirstName = 'John1'+i, 
                    LastName = 'Doe1'+i,
                    Title='VP',
                    MailingStreet='123 Main',
                    MailingCity='Peoria',
                    MailingState='IL',
                    MailingPostalCode='333334'+i,
                    Phone='32132132114'+i,
                    OtherPhone='32132132114'+i, // 3.0
                    MobilePhone='32132132114'+i,
                    Fax='32131232114'+i,
                    Status__c = 'Marketing Suspect'             
                )
            );
            }
            insert contacts;            
        }
        final List<User> users = new List<User>();
        if(admin){      
            Profile p = [select id from profile where name='System Administrator' LIMIT 1];
            User u = new User(alias = 'standt', email='testproUser@dell.com', 
                emailencodingkey='UTF-8', lastname='Testing', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles',Badge_Number__c='001294', 
                username='callfortest@dell.com');           
            System.runAs(u) {
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
                        Badge_Number__c='000823'+i, 
                        ContactId = contacts.get(i).id, 
                        Enable_Partner_Admin__c = admin
                    )
                );
            }
            insert users; 
            for(user user : users){
                Integer userNumber = getNextUserSerialNumber();
                user.username = '1'+userNumber+'@DELLTEAM.com';
            }
            update users; 
            }   
        }
        else{
            Profile p = [select id from profile where name='System Administrator' LIMIT 1];
            User u = new User(alias = 'standt', email='callfortest11@dell.com', 
                emailencodingkey='UTF-8', lastname='Testing', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles',Badge_Number__c='00129412', 
                username='callfortest11@dell.com');         
            System.runAs(u) {
            for(Integer i = 0; i < partnerProfiles.size(); i++){
                Integer userNumber = getNextUserSerialNumber();
                users.add(
                    new User(
                        Username='22'+userNumber+'@DELLTEAM.com',
                        Alias = 'test'+userNumber, 
                        Email='22'+userNumber+'@DELLTEAM.com', 
                        FirstName='John', 
                        LastName='Doe'+userNumber, 
                        ProfileId = partnerProfiles.get(i).Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='0008223'+i, 
                        ContactId = contacts.get(i).id, 
                        Enable_Partner_Admin__c = admin
                    )
                );
            }
            insert users; 
            for(user user : users){
                Integer userNumber = getNextUserSerialNumber();
                user.username = '1'+userNumber+'@DELLTEAM.com';
            }
            update users; 
            }   

        }   
        TriggerExecutionController.setSkipAllTriggers(false);       
        return users;
        
    }

    
 /*   private static testmethod void testAdminUpdateAnotherUserWithoutEmailChange(){
                TriggerExecutionController.setSkipAllTriggers(true);       

        User admin = createPartnerUsers(true,1,null).get(0);
        Id accountid = [select accountid from contact where id = :admin.contactid].accountid;
        User userToUpdate = createPartnerUsers(false,1,accountid).get(0);
        Contact contact = [select MailingStreet,Id from contact where id = :userToUpdate.ContactId];
        contact.MailingStreet = '123 main\npo box a\nsuite123';
        
        update contact;
        
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_USERID,''+userToUpdate.id);
                        Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'PY3R', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
                                                insert testCountry;
            Test.StartTest();
            //create controller extension
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
            extension.countryObj = testCountry;
            //TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(true,extension.isCurrentUserPartnerAdmin);          
            System.assertEquals(false,extension.isNewUser);         
            System.assertEquals(IdLookupUtils.getRecordTypeId(
                    PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER, 'Partner_Request__c', true),
                    request.RecordTypeId);
                    
            request.Salutation__c = request.Salutation__c + 'abc';
            request.First_Name__c = request.First_Name__c + 'abc';
            request.Last_Name__c = request.Last_Name__c + 'abc';
            request.Job_Title__c = request.Job_Title__c + 'abc';
            request.Address_Line_1__c = request.Address_Line_1__c + 'abc';
            request.City__c = request.City__c + 'abc';
            request.State__c = request.State__c + 'abc';
            request.Postal_Code__c = request.Postal_Code__c + 'abc';
            request.Phone__c = request.Phone__c + 'abc';
            request.Mobile__c = request.Mobile__c + 'abc';
            request.Fax__c = request.Fax__c + 'abc';
            //request.Email__c = request.Email__c + 'test@mail.com';
            System.assertEquals(null,extension.doSave());
            //TestUtils.assertNoErrorMessagesExist();
            
            System.assertEquals(Page.PartnerSelfServiceMyProfile.getUrl(),extension.doOK().getUrl());
            
        }
        Test.stopTest();    
              //  TriggerExecutionController.setSkipAllTriggers(false);       

    } */
  
    // [Fenny 10-Jan-2013] - CR7944
    static testmethod void test_doPermissionSetAssignment(){
        TriggerExecutionController.setSkipAllTriggers(true);
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Partner_Opportunity_Access'];
        User sa = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND Id <> :UserInfo.getUserId()][0];
        Account acc = [SELECT Id FROM Account WHERE Type = 'Partner' AND RecordTypeId = :System.Label.RecType_Partner_Account LIMIT 1];
        Contact con = new Contact(AccountId = acc.id,Email = '1_2@dell.com',FirstName = 'fn' ,LastName = 'ln' ,Title = 'King',MailingStreet = '123Main',MailingCity = 'Peoria',
                            MailingState = 'IL',MailingPostalCode = '33333',Phone = '3213213211',MobilePhone = '3213213211',Fax = '3213123211');
        insert con;

        Profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1]; 

        String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit.user';
                               
       User usr = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profileRec.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    Enable_Partner_Admin__c = true,
                                    ContactId = con.Id);
        
        insert usr;
        
        Test.startTest();
        PageReference pageRef = Page.PartnerSelfServiceMyProfile;
        //ApexPages.currentPage().getParameters().put('Id', con.Id);
        Test.setCurrentPage(pageRef);
        
        Partner_Request__c pr = new Partner_Request__c();
        ApexPages.Standardcontroller stdCtl = new ApexPages.Standardcontroller(pr);
        PartnerSelfServiceMyProfileCtrlExt controller = null;
        system.runAs(sa){
            controller = new PartnerSelfServiceMyProfileCtrlExt(stdCtl);
            pr.Feature_Request_Deal_Registration__c = true;
            controller.isNewUser = false;
            controller.editMode = true;
            //kishore
            controller.doPermissionSetAssignment();
        }
        
        system.runAs(sa){
            controller.doSave();
            controller.doPermissionSetAssignment();
            
            List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usr.Id and PermissionSetId = :permSet.Id];
            
            //system.assertEquals(true, ((assignments != null) && (assignments.size() > 0)));
            //system.assertEquals(true, (assignments.size() == 1));
        }
        
        Partner_Request__c pr2 = new Partner_Request__c();
        ApexPages.Standardcontroller stdCtl2 = new ApexPages.Standardcontroller(pr2);
        PartnerSelfServiceMyProfileCtrlExt controller2 = null;
        system.runAs(sa){
            usr.Enable_Partner_Deal_Registration__c = true;
            update usr;
            
            controller2 = new PartnerSelfServiceMyProfileCtrlExt(stdCtl2);
            pr2.Feature_Request_Deal_Registration__c = false;
            controller2.isNewUser = false;
            controller2.editMode = true;
        }
        
        system.runAs(sa){
            controller2.doSave();
            controller2.doPermissionSetAssignment();
            
            List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usr.Id and PermissionSetId = :permSet.Id];
            TriggerExecutionController.setSkipAllTriggers(false);
            //system.assertEquals(true, ((assignments == null) || (assignments.size() == 0)));
        }
        Test.stopTest();
    }
    
    private static testmethod void testAdminCreateNewUser_withLM_nonOEM(){
        Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        
  
              
        insert testCountry;
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
        testAcc.IsPartner = true;
        update testAcc;
        
        Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',Email='kishore@dell.com', Partner_My_Account_GUID__c='validuser'
                                           
                                             );
    insert testContact; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
    Test.startTest();
                              
       User user = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    Enable_Partner_Admin__c = true,
                                    ContactId = testContact.Id);
        insert user;
               
        System.runAs(user){

            //create controller extension
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_CANCELURL,'/123');
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_NEWFLAG,'true');
            
            Partner_Request__c request = new Partner_Request__c();
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
             System.assertEquals(true, extension.isalowedLeadMAnagement);
            Test.stopTest();
               

        }
    }
    private static testmethod void testAdminCreateNewUser_withLM_OEM(){
        Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        
  
        
        
        insert testCountry;
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test OEM Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
        testAcc.IsPartner = true;
        update testAcc;
        
        Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer',Email='kishore@dell.com',
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
    insert testContact; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
    Test.startTest();
                              
       User user = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    Enable_Partner_Admin__c = true,
                                    ContactId = testContact.Id);
        insert user;
               
        System.runAs(user){

            //create controller extension
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_CANCELURL,'/123');
            ApexPages.currentPage().getParameters().put(
                PartnerSelfServiceMyProfileCtrlExt.HTTP_PARAMETER_NEWFLAG,'true');
            
            Partner_Request__c request = new Partner_Request__c();
            request.Feature_Request_Deal_Registration__c = false;
            request.Feature_Request_Lead_Management__c = false;
            //System.assertEquals(true, extension.isalowedLeadMAnagement);
            PartnerSelfServiceMyProfileCtrlExt extension = new PartnerSelfServiceMyProfileCtrlExt(
                new ApexPages.standardController(request));
             System.assertEquals(true, extension.isalowedLeadMAnagement);
             extension.showorHideLeadDetails();
            Test.stopTest();
               

        }
    }
}