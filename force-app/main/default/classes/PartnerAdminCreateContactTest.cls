@IsTest
private class PartnerAdminCreateContactTest {
    @testSetup static void setup() {
        list<Account> listpartnerAccout = TestDataFactory.createNAccount(2, 'Master Account');
        insert listpartnerAccout;   
    }
    private static testmethod void testStdUserValidationError(){
        System.runAs(createStandardUsers(1).get(0)){
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(new Partner_Request__c()));
            System.assertEquals(extension.straccessdeniedstandardlicenseuser,extension.strerrorCode);         
        }      
    } 
    private static testmethod void testAdminUserValidationError(){
        User nonAdmin = createPartnerUsers(false,2,null).get(0);
        System.assertNotEquals(null,nonAdmin);
        System.runAs(nonAdmin){
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_NEWFLAG,'true');
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(new Partner_Request__c()));
        }      
    } 
    private static testmethod void testAdminCreateNewUser(){        
        User user = createPartnerUsers(true,2,null).get(0);
        System.runAs(user){
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_CANCELURL,'/123');
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_NEWFLAG,'true');
            Partner_Request__c request = new Partner_Request__c();
            request.First_Name__c = 'John';
            request.Last_Name__c = 'Doe';
            request.Job_Title__c = 'VP';
            request.Address_Line_1__c = '123 Main';
            request.City__c = 'Peoria';
            request.State__c = 'IL';
            request.Postal_Code__c = '22222';
            request.Phone__c = '3213213211';
            request.Email__c = 'test@test.com';
            Test.startTest();
            insert request;
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(true,extension.bisNewUser);          
            System.assertEquals(true,extension.beditMode);
            System.assertEquals(false,extension.bisConfirmEmailChange);
            System.assertEquals(IdLookupUtils.getRecordTypeId(
                PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER, 'Partner_Request__c', true),
                                request.RecordTypeId);
            Test.stopTest();
        }
    }
    private static testmethod void testAdminCreateNewUserNoChangesErrorValidation(){
        User user = createPartnerUsers(true,2,null).get(0);
        System.runAs(user){
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_NEWFLAG,'true');
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(true,extension.bisNewUser);          
            System.assertEquals(true,extension.beditMode);
            System.assertEquals(IdLookupUtils.getRecordTypeId(
                PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER, 'Partner_Request__c', true),
                                request.RecordTypeId);
        }
    }
    //Modified by Bahar, Ariff (20121204)
    private static testMethod void testEnableForIncentiveEnable(){
        User testUser = createPartnerUsers(true,2,null).get(0);
        System.assertNotEquals(null,testUser);
        Country__c testCountryObject = new Country__c(name='ANGUILIA', Dell_Online_Country_Code__c='AA',Code__c='AA',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold');
        insert testCountryObject; 
        Id accountid = [select accountid from contact where id = :testUser.contactid].accountid;
        PartnerCountry pc = new PartnerCountry();
        Map<string, Country__c> mapcountryMap = pc.returnCountryCodeMap();
        Country__c countryObject = [Select Inc_Vendor_Name__c,Inc_Vendor_End_Point__c from Country__c where code__c='AA'];
        System.runAs(testUser){
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_NEWFLAG,'true');
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
        }
    }
    private static testmethod void testNonAdminCreateNewUserErrorValidation(){
        User user = createPartnerUsers(false,2,null).get(0);
        System.runAs(user){
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_NEWFLAG,'true');
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            System.assertEquals(extension.straccessdeniedpartnerusernotadmin,extension.strerrorCode);  
            System.assertNotEquals(null,extension.listpartnerAdminsForAccount);         
        }
    }
    private static testmethod void testAdminUpdateAnotherUserWithMultilineAddress(){
        TriggerExecutionController.setSkipAllTriggers(true);
        User admin = createPartnerUsers(false,2,null).get(0);
        Id accountid = [select accountid from contact where id = :admin.contactid].accountid;
        User userToUpdate = createPartnerUsers(true,2,accountid).get(0);
        Contact contact = [select MailingStreet,Id from contact where id = :userToUpdate.ContactId];
        contact.MailingStreet = '123 main\npo box a\nsuite123';
        Test.StartTest();
        update contact;
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(false,extension.bisNewUser);         
            request.Salutation__c = request.Salutation__c + 'abc';
            request.First_Name__c = request.First_Name__c + 'abc';
            request.Last_Name__c = request.Last_Name__c + 'abc';
            request.Job_Title__c = request.Job_Title__c + 'abc';
            request.Address_Line_1__c = request.Address_Line_1__c + 'abc';
            request.City__c = request.City__c + 'abc';
            request.State__c = request.State__c + 'abc';
            request.Postal_Code__c = request.Postal_Code__c + 'abc';
            request.Phone__c = request.Phone__c + '123'; // 3.0
            request.Mobile__c = request.Mobile__c + 'abc';
            request.Fax__c = request.Fax__c + 'abc';
            System.assertNotEquals(true,extension.bisConfirmEmailChange);
            extension.doCancelNewUser();
        }
        Test.stopTest();  
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    private static testmethod void testAdminUpdateAnotherUserNullContactAddress(){
        User admin = createPartnerUsers(true,2,null).get(0);
        Id accountid = [select accountid from contact where id = :admin.contactid].accountid;
        User userToUpdate = createPartnerUsers(false,2,accountid).get(0);
        Contact contact = [select MailingStreet,Id,Email_Opt_In__c from contact where id = :userToUpdate.ContactId];
        contact.MailingStreet = null;
        Country__c testCountryObject = new Country__c(name='ANGUILIA', Dell_Online_Country_Code__c='AA',Code__c='AA0',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold');
        Test.StartTest();
        insert testCountryObject;
        update contact;
        System.debug('after updating contact');
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            TestUtils.assertNoErrorMessagesExist();
            System.assertEquals(false,extension.bisNewUser); 
            System.debug('bisNewUser executing');        
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
            request.Phone__c = request.Phone__c + '123'; // 3.0
            request.Mobile__c = request.Mobile__c + 'abc';
            request.Fax__c = request.Fax__c + 'abc';
            request.Newsletter_Opt_In__c = !request.Newsletter_Opt_In__c;
            request.Enable_As_Partner_Admin__c = !request.Enable_As_Partner_Admin__c;
            request.Enable_for_Bid_Builder__c = !request.Enable_for_Bid_Builder__c;
            request.country__c = testCountryObject.Id ;
            Pagereference pg = extension.doSave();
            System.debug('after dosave()');
            request.Feature_Request_Lead_Management__c = false;
        }
        Test.stopTest();       
    }
    private static testmethod void testAdminUpdateAnotherUserNotInSameAccount(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        User admin = createPartnerUsers(true,2,null).get(0);
        System.assertNotEquals(null, admin);
        User userToUpdate = createPartnerUsers(false,2,null).get(0);
        TriggerExecutionController.setSkipAllTriggers(false);
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            TestUtils.assertErrorMessagesExist();
        }       
        Test.stopTest();
    }
    private static testmethod void testNonAdminUpdateAnotherUserErrorValidation(){
        User admin = createPartnerUsers(true,2,null).get(0);
        Id accountid = [select accountid from contact where id = :admin.contactid].accountid;
        User userToUpdate = createPartnerUsers(false,2,accountid).get(0);
        System.assertNotEquals(null, userToUpdate);
        Test.startTest();
        System.runAs(admin){
            PermissionSet listpermSet = [SELECT Id FROM PermissionSet WHERE Name = 'Partner_Opportunity_Access'];
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            extension.doPermissionSetAssignment();
        }        
        Test.stopTest();
    }
    private static testmethod void testAdminUpdateAnotherUserWhichDoesntExist(){
        User admin = createPartnerUsers(true,2,null).get(0);
        System.assertNotEquals(null, admin);
        System.runAs(admin){
            ApexPages.currentPage().getParameters().put(
                PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_USERID,'0123456789012345');
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            TestUtils.assertErrorMessagesExist();
        }       
    }
    private static testmethod void testNonAdminUpdateProfile(){
        User user = createPartnerUsers(false,2,null).get(0);
        System.assertNotEquals(null, user);
        Contact contact = [select id,Salutation,FirstName,LastName,Title,MailingStreet,Account_Country_Code__c,
                           MailingCity,MailingState,MailingPostalCode,Phone,MobilePhone,Fax,Email,
                           Email_Opt_in__c, Is_Rebate_User__c from Contact where id = :user.ContactId];
        System.runAs(user){
            Test.startTest();
            Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'US23U', Region__c = 'APJ',
                                                     Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                     Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
            insert testCountry;
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(
                new ApexPages.standardController(request));
            extension.countryObj = testCountry;
            TestUtils.assertNoErrorMessagesExist();
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
            request.Phone__c = request.Phone__c + '123'; // 3.0
            request.Mobile__c = request.Mobile__c + 'abc';
            request.Fax__c = request.Fax__c + 'abc';
            Pagereference pg = extension.dosave();  
            Test.stopTest();
        }
    }
    private static Integer intnextUserSerialNumber = -1;
    private static Integer getNextUserSerialNumber(){
        intnextUserSerialNumber++;
        return intnextUserSerialNumber;
    }
    private static List<User> createStandardUsers(Integer intmax){
        final List<Profile> profiles = 
            [select id,name from Profile where UserType = 'Standard' and Profile.name = 'System Administrator'  limit :intmax];
        final List<User> users = new List<User>();
        for(Integer inti = 0; inti < profiles.size(); inti++){
            Integer intuserNumber = getNextUserSerialNumber();
            users.add(
                new User(
                    Username=''+intuserNumber +'@DELLTEAM.com',
                    Alias = 'test'+intuserNumber , 
                    Email=''+intuserNumber +'@DELLTEAM.com', 
                    FirstName='John', 
                    LastName='Doe'+intuserNumber , 
                    ProfileId = profiles.get(inti).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c=''+9005000+intuserNumber)
            );
        }
        insert users;
        return users;
    }
    private static List<User> createPartnerUsers(Boolean badmin, Integer intmax, id accountId){
        TriggerExecutionController.setSkipAllTriggers(true);
        final List<Profile> partnerProfiles = [select id,name from Profile where UserType =: 'PowerPartner' limit :intmax];
        System.assert(!(partnerProfiles == null || partnerProfiles.size() <= 0), 
                      'No partner profiles exist therefore test cannot be executed');
        System.debug('partnerProfiles::'+partnerProfiles);
        final List<Account> accounts = new List<Account>();        
        if(accountId == null){
            for(Integer inti = 0; inti < partnerProfiles.size(); inti++){
                accounts.add(
                    new Account(
                        name='AccTest ' + inti,
                        Website = 'https://www.testing'+inti+'.com',
                        Account_Country_Code__c = 'AI',
                        Account_Country__c = 'ANGUILIA')
                );
            }
            insert accounts;
            system.debug('Accounts*****'+accounts);
            for(Account account : accounts){
                account.IsPartner = true;
            }
            update accounts;
        }  
        final List<Contact> contacts = new List<Contact>();
        if(badmin){
            for(Integer inti = 0; inti < partnerProfiles.size(); inti++){
                contacts.add(
                    new Contact(
                        AccountId=(accountId == null ? accounts.get(inti).id : accountId),
                        Email=''+inti+'@DELLTEAM.com', 
                        FirstName = 'John'+inti, 
                        LastName = 'Doe'+inti,
                        Title='VP',
                        MailingStreet='123 Main',
                        MailingCity='Peoria',
                        MailingState='IL',
                        MailingPostalCode='33333'+inti,
                        Phone='3213213211'+inti,
                        OtherPhone='3213213211'+inti, // 3.0
                        MobilePhone='3213213211'+inti,
                        Fax='3213123211'+inti,
                        Status__c = 'Marketing Suspect' )
                );
            }
            insert contacts;
        }
        else{
            for(Integer inti= 0; inti< partnerProfiles.size(); inti++){
                contacts.add(
                    new Contact(
                        AccountId=(accountId == null ? accounts.get(inti).id : accountId),
                        Email='aol'+inti+'@DELLTEAM.com', 
                        FirstName = 'John1'+inti, 
                        LastName = 'Doe1'+inti,
                        Title='VP',
                        MailingStreet='123 Main',
                        MailingCity='Peoria',
                        MailingState='IL',
                        MailingPostalCode='333334'+inti,
                        Phone='32132132114'+inti,
                        OtherPhone='32132132114'+inti, // 3.0
                        MobilePhone='32132132114'+inti,
                        Fax='32131232114'+inti,
                        Status__c = 'Marketing Suspect')
                );
            }
            insert contacts;            
        }
        final List<Country__c> testCountry = new List<Country__c>();
        if(badmin){
            for(Integer inti=1; inti < partnerProfiles.size(); inti++){
                testCountry.add(
                    new country__c(
                        name = 'TEST COUNTRY'+inti, Code__c = 'TY01'+inti, Region__c = 'APJ',
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
            for(Integer inti=1; inti < partnerProfiles.size(); inti++){
                testCountry.add(
                    new country__c(
                        name = 'TEST COUNTRY'+inti, Code__c = 'USR0', Region__c = 'APJ',
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
        System.debug('contacts::'+contacts+'::Size:'+contacts.size());
        final List<User> users = new List<User>();
        String strusrname ='testclassUser'+string.valueof(Math.abs(Crypto.getRandomInteger()))+'@dell.com';
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String strrandomNumber = str.substring(0,10);
        system.debug('Random Number-' + strrandomNumber );
        Profile p = [select id from profile where name='System Administrator' LIMIT 1];
        User u = new User(alias = 'standt', email='testproUser@dell.com', 
                          emailencodingkey='UTF-8', lastname='Testing', 
                          languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles',Badge_Number__c=strrandomNumber , 
                          username=strusrname ); 
        System.runAs(u) {
            for(Integer inti = 0; inti < partnerProfiles.size(); inti++){
                Integer intuserNumber  =getNextUserSerialNumber();
                users.add(
                    new User(
                        Username='testing'+intuserNumber +'@DELLTEAM.com',
                        Alias = 'test'+intuserNumber , 
                        Email=''+intuserNumber +'@DELLTEAM.com', 
                        FirstName='Jhon', 
                        LastName='Test'+intuserNumber , 
                        ProfileId = partnerProfiles[1].Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='ISO-8859-1', 
                        TimeZoneSidKey='America/New_York',
                        Badge_Number__c=null, 
                        ContactId = contacts[inti].id, 
                        Enable_Partner_Admin__c = badmin,
                        Enable_as_Partner_Group_Administrator__c = badmin,
                        isActive = TRUE)
                );
            }
            insert users;
        }
        System.debug('users'+users);
        return users;
    }
    private static testmethod void testEligibleTrack(){
        User testUser = createPartnerUsers(true,2,null).get(0);
        Country__c testCountryObject = new Country__c(name='ANGUILIA', Dell_Online_Country_Code__c='AA',Code__c='AA0',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold');
        insert testCountryObject; 
        Contact con = [select accountid,EligibleTracks__c,Account.Account_Country_Code__c from contact where id = :testUser.contactid];
        Id accountid = con.accountid;
        Account acc = [select name,Account_Id__c from Account limit 1];
        acc.Master_Group_Id__c=accountid;
        Test.startTest();
        update acc;
        acc.IsPartner = true;
        update acc;
        Track__c trackObj = new Track__c(Name= 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = accountid;
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c = acc.Account_Id__c;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = accountid;
        insert testPartnerTrackObj1;
        System.runAs(testUser){
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_NEWFLAG,'true');
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_CANCELURL,'/123');
            TriggerExecutionController.setSkipAllTriggers(true);
            Partner_Request__c request = new Partner_Request__c();
            request.First_Name__c = 'John';
            request.Last_Name__c = 'Doe';
            request.Job_Title__c = 'VP';
            request.Address_Line_1__c = '123 Main';
            request.City__c = 'Peoria';
            request.State__c = 'IL';
            request.Postal_Code__c = '22222';
            request.Phone__c = '3213213211';
            request.Email__c = 'test@test.com';
            request.Eligible_Partner_Tracks__c = String.valueOf(testPartnerTrackObj.Id+';'+testPartnerTrackObj1.Id); //testPartnerTrackObj.Id;
            request.Country__c = testCountryObject.Id;
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(new ApexPages.standardController(request));
            extension.strlocationOfUser = testPartnerTrackObj.Id;
            extension.updateAddress();
            extension.strenteredEmail = 'test@test.com'; //request.Email__c;
            PageReference pg= extension.refreshPicklist();
            List<selectOption> listSO1= extension.getEligibleTracks();
            List<selectOption> listSO2= extension.getEligibleTracksSelected();
            extension.listleftselected.add(testPartnerTrackObj.Id);
            List<selectOption> listSO5= extension.getLocationOfTracksAvailable();
            PageReference pg4= extension.selectTrack();
            PageReference pg5= extension.unselectclick();
            extension.listleftselected.add(testPartnerTrackObj1.Id);
            List<selectOption> listSO3= extension.getEligibleTracks();
            List<selectOption> listSO4= extension.getEligibleTracksSelected();
            PageReference pg10= extension.selectTrack();
            extension.listrightselected.add(testPartnerTrackObj.Id);
            PageReference pg11= extension.unselectclick();
            extension.strlocationOfUser = testPartnerTrackObj1.Id;
            extension.updateAddress();
            PageReference pg7= extension.doCancelNewUser();
            PageReference pg8= extension.doEdit();
            PageReference actualURL = extension.doSave();
            con.EligibleTracks__c =request.Eligible_Partner_Tracks__c;
            extension.bpartnerUserEditingOwnProfile = true;
            PageReference pg6= extension.doCancel();
            system.assert(request != null);
            PartnerAdminsCreateContactCntrl.setIncompletForRequestWithReason(request,'OwnerID is Blank');
            PartnerAdminsCreateContactCntrl.synchronizeToCMIandNetExam(con.Id,request.Id);
            Test.stopTest();
        }
    }
    private static testmethod void testAdminUpdateAnotherUserWithoutEmailChange(){
        TriggerExecutionController.setSkipAllTriggers(true);       
        User admin = createPartnerUsers(true,2,null).get(0);
        Id accountid = [select accountid from contact where id = :admin.contactid].accountid;
        User userToUpdate = createPartnerUsers(false,2,accountid).get(0);
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        system.debug('trackObj*****'+trackObj);
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = accountid;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = accountid;
        insert testPartnerTrackObj1;
        system.debug('partnertrack'+testPartnerTrackObj1);
        system.assert(userToUpdate.id != null);
        System.runAs(admin ){
            Test.startTest();
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_CANCELURL,'/123');
            Partner_Request__c request = new Partner_Request__c();
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(new ApexPages.standardController(request));
            PageReference pg= extension.refreshPicklist();
            List<selectOption> listSO1= extension.getEligibleTracks();
            List<selectOption> listSO2= extension.getEligibleTracksSelected();
            PageReference pg4= extension.selectTrack();
            PageReference pg5= extension.unselectclick();
            PageReference pg6= extension.doCancel();
            PageReference pg7= extension.doCancelNewUser();
            PageReference actualURL = extension.doSave();
            test.stopTest();
        }
    }
    public static testmethod void testAdminUpdateAnotherUser(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Set<String> setcustomerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
            List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =: 'PowerPartner' limit 2]);
        Account acc = [select name,Account_Id__c from Account limit 1];
        acc.Account_Country_Code__c = 'AA';
        acc.Account_Country__c = 'ANGUILIA';
        Test.startTest();
        update acc;
        acc.IsPartner = true;
        update acc;
        country__c coun = new country__c(name = 'TEST COUNTRY', Code__c = acc.Account_Country_Code__c, Region__c = 'APJ',
                                         Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',
                                         Inc_Vendor_Name__c='Not Applicable/On Hold',Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',
                                         Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        insert coun;
        System.debug('coun'+coun.Id);
        Contact con = new Contact (AccountId = acc.id,LastName = 'portalTestUser',Email='testingdit@gshaj.com');
        insert con;
        Integer intuserNumber  = getNextUserSerialNumber();
        String strnewusername = 'bilo'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        System.debug('listp[1].id'+listp [1].Name);
        User newUser = new User(profileId = listp[1].id,username = strnewusername ,email = 'pb@ff.com',Badge_Number__c=strbadgeNumber ,
                                emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = con.id);
        insert newUser;
        User admin  = createPartnerUsers(true,2,null).get(0);
        Id accountid = [select accountid from contact where id = :admin .contactid].accountid;
        User userToUpdate = createPartnerUsers(false,2,accountid).get(0);
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        system.debug('trackObj*****'+trackObj);
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = accountid;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = accountid;
        insert testPartnerTrackObj1;
        System.runAs(admin ){
            system.assert(userToUpdate.id != null);
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_USERID,''+userToUpdate.id);
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_CANCELURL,'/123');
            Partner_Request__c request = new Partner_Request__c();
            request.First_Name__c = 'John';
            request.Last_Name__c = 'Doe';
            request.Job_Category__c = 'Facilities';
            request.Job_Title__c = 'Facilities Manager';
            request.Address_Line_1__c = '123 Main';
            request.City__c = 'Peoria';
            request.State__c = 'IL';
            request.Postal_Code__c = '22222';
            request.Phone__c = '3213213211';
            request.Email__c = 'test@gmail.com';
            request.Eligible_Partner_Tracks__c = testPartnerTrackObj.Id;
            request.Program_Tracker__c = true;
            request.Enable_Premier_Pages_access_Flag__c = true;
            request.Partner_Central__c = true;
            request.RFP_Proposal_Express_Tool__c = true;
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(new ApexPages.standardController(request));
            PageReference pg= extension.refreshPicklist();
            List<selectOption> listSO1= extension.getEligibleTracks();
            List<selectOption> listSO2= extension.getEligibleTracksSelected();
            PageReference pg4= extension.selectTrack();
            PageReference pg5= extension.unselectclick();
            PageReference pg6= extension.doCancel();
            PageReference pg7= extension.doCancelNewUser();
            PageReference actualURL = extension.doSave();
            con.EligibleTracks__c = request.Eligible_Partner_Tracks__c;
            test.stopTest();
        }
    } 
    private static testmethod void testnewPRSave(){
        TriggerExecutionController.setSkipAllTriggers(true);
        User admin = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND Id <> :UserInfo.getUserId()][0];
        Set<String> setcustomerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
            List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        Country__c testCountry = new Country__c(Name = 'TEST COUNTRY PA', Code__c = 'de', Region__c = 'APJ');
        insert testCountry;
        Account acc = [Select name,Account_Id__c,Master_Group_Affinity_Id__c from Account limit 1];
        acc.Account_Country_Code__c = 'AA';
        acc.Account_Country__c = 'ANGUILIA';
        Test.startTest();
        update acc;
        acc.IsPartner = true;
        update acc;
        Track__c trackObj = new Track__c(Name= 'testTrack',Zone__c = 'Zone 1',Country_Code__c='de');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.Id;
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c = acc.Account_Id__c;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = acc.Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = acc.Id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = acc.Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj1;
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data 2';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = acc.Id;
        testPartnerTrackObj2.Master_Group_Affinity_Id__c = acc.Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj2;
        Contact con = new Contact (AccountId = acc.id,EligibleTracks__c=testPartnerTrackObj1.Id,LastName = 'portalTestUser',Email='testingdit5@gshaj.com',Selected_Track__c=testPartnerTrackObj.Id);
        insert con;
        Integer intuserNumber  = getNextUserSerialNumber();
        String strnewusername  = 'bilo'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber  = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        User newUser = new User(profileId = listp[1].id,username = strnewusername ,email = 'pb@ff.com',Badge_Number__c=strbadgeNumber , PortalRole = 'Manager',
                                emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = con.id,
                                Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        insert newUser;
        System.runAs(newUser){
            PageReference myVfPage = Page.PartnerAdminsCreateContact;
            Test.setCurrentPage(myVfPage);
            //create controller extension
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_NEWFLAG,'true');
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_CANCELURL,'/123');
            system.assert(testPartnerTrackObj1.Id != null);
            con.EligibleTracks__c =String.valueOf(testPartnerTrackObj.Id+';'+testPartnerTrackObj1.Id);
            Partner_Request__c request = new Partner_Request__c();
            request.First_Name__c = 'John';
            request.Last_Name__c = 'Doe';
            request.Phone__c = '3213213211';
            request.Email__c = 'test@test.com';
            request.Eligible_Partner_Tracks__c = testPartnerTrackObj.Id;
            request.Location_Of_User__c = testPartnerTrackObj.Id;
            request.OwnerId = newUser.Id;
            request.Enable_Partner_Group_Admin__c  = true;
            request.Enable_as_Partner_Admin__c = true;
            request.Feature_Request_Deal_Registration__c = true;
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(new ApexPages.standardController(request));
            extension.updateAddress();
            extension.strlocationOfUser = testPartnerTrackObj.Id;
            extension.updateAddress();
            extension.strenteredEmail = request.Email__c;
            request.Job_Category__c = 'Facilities';
            PageReference pg= extension.refreshPicklist();
            request.Job_Title__c = 'Facilities Manager';
            List<selectOption> listSO1= extension.getEligibleTracks();
            List<selectOption> listSO2= extension.getEligibleTracksSelected();
            extension.listleftselected.add(testPartnerTrackObj.Id);
            List<selectOption> listSO5= extension.getLocationOfTracksAvailable();
            PageReference pg4= extension.selectTrack();
            PageReference pg5= extension.unselectclick();
            extension.listleftselected.add(testPartnerTrackObj1.Id);
            List<selectOption> listSO3= extension.getEligibleTracks();
            List<selectOption> listSO4= extension.getEligibleTracksSelected();
            extension.jobTitleChange();
            ApexPages.currentPage().getParameters().put('valueIs','Facilities');
            extension.refreshPicklistNew();
            PageReference pg10= extension.selectTrack();
            extension.listrightselected.add(testPartnerTrackObj.Id);
            PageReference pg11= extension.unselectclick();
            PageReference actualURL = extension.doSave();
            PageReference rewardAccess = extension.rewardaccess();
            ApexPages.currentPage().getParameters().put('gAdmin',String.ValueOf(request.Enable_Partner_Group_Admin__c));
            PageReference assignTracks= extension.assignAllTracksToSeleted();
            ApexPages.currentPage().getParameters().put('gAdmin',String.ValueOf(!request.Enable_Partner_Group_Admin__c));
            PageReference assignTracks1= extension.assignAllTracksToSeleted();
        }
    }
    private static testmethod void testExistingPRSave(){
        TriggerExecutionController.setSkipAllTriggers(true);
        User admin = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND Id <> :UserInfo.getUserId()][0];
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =: 'PowerPartner' limit 2]);
        Country__c count = new Country__c(Name = 'TEST COUNTRY Sandbox', Code__c = 'AA', Region__c = 'APJ',
                                          Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',
                                          Inc_Vendor_Name__c='Not Applicable/On Hold',Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',
                                          Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        insert count;
        Account acc = [Select name,Account_Id__c,Master_Group_Affinity_ID__c  from Account limit 1];
        acc.Account_Country_Code__c = 'AA';
        acc.Account_Country__c = 'ANGUILIA';
        Test.startTest();
        update acc;
        acc.IsPartner = true;
        update acc;
        Track__c trackObj = new Track__c(Name= 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.Id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = acc.Master_Group_Affinity_ID__c;
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c = acc.Account_Id__c;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = acc.Id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = acc.Master_Group_Affinity_ID__c;
        insert testPartnerTrackObj1;
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data 22';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = acc.Id;
        testPartnerTrackObj2.Master_Group_Affinity_Id__c = acc.Master_Group_Affinity_ID__c;
        insert testPartnerTrackObj2;
        List<Contact> listcon = new List<contact>();
        Contact con = new Contact (AccountId = acc.id,LastName = 'portalTestUser',Email='testingdit5@gshaj.com',EligibleTracks__c = testPartnerTrackObj2.Id+';'+testPartnerTrackObj1.Id);
        listcon.add(con);
        Contact con1 = new Contact (Salutation='Mrs',AccountId = acc.id,FirstName='Testing', LastName = 'portalTestUser2',Email='tuitingdit5@gshaj.com',
                                    Other_Job_Function_Category__c ='others',Phone='12345',Allow_Partner_Central_User__c=false,
                                    Allow_Program_Tracker__c = false, Is_MDF_User__c = false, Is_Rebate_User__c = false, Premier_Partner__c = false,
                                    Allow_RFP_and_Proposal_Express_Tool__c = false,EligibleTracks__c = testPartnerTrackObj2.Id);
        listcon.add(con1);
        insert listcon;
        Integer intuserNumber  = getNextUserSerialNumber();
        String strnewusername  = 'bilo'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber  = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomLong()));
        List<User> listusr = new List<User>();
        User newUser = new User(profileId = listp[1].id,username = strnewusername ,email = 'pb@ff.com',Badge_Number__c= strbadgeNumber.substring(0, 10),
                                emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = listcon[0].id,
                                Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listusr.add(newUser);
        Integer intuserNumber1 = getNextUserSerialNumber();
        String strnewusername1 = 'biulo'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber1 = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomLong()));
        User newUser2 = new User(profileId = listp[1].id,username = strnewusername1,email = 'pbc@ff.com',Badge_Number__c=strbadgeNumber1.substring(0,10),
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                 timezonesidkey = 'America/Los_Angeles',alias='userui',firstName='yui',lastname='lastnameklu',contactId = listcon[1].id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true,
                                 Enable_Partner_Deal_Registration__c = true, Enable_Partner_Lead_Management__c = true,Enable_As_Partner_Lead_Super_User__c = true);
        listusr.add(newUser2);
        insert listusr;
        System.runAs(listusr[0]){
            system.assert(listusr[1].id != null);
            //create controller extension
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_USERID,''+listusr[1].id);
            ApexPages.currentPage().getParameters().put(PartnerAdminsCreateContactCntrl.HTTP_PARAMETER_CANCELURL,'/123');
            Partner_Request__c request = new Partner_Request__c();
            request.Salutation__c = 'Miss';
            request.First_Name__c = request.First_Name__c + 'abc';
            request.Last_Name__c = request.Last_Name__c + 'abc';
            request.Job_Title__c = request.Job_Title__c + 'abc';
            request.Address_Line_1__c = request.Address_Line_1__c + 'abc';
            request.City__c = request.City__c + 'abc';
            request.State__c = request.State__c + 'abc';
            request.Postal_Code__c = request.Postal_Code__c + 'abc';
            request.Phone__c = request.Phone__c + '123'; // 3.0
            request.Mobile__c = request.Mobile__c + 'abc';
            request.Fax__c = request.Fax__c + 'abc';
            request.Email__c = request.Email__c + 'abc';
            request.OwnerId = listusr[0].Id;
            request.Eligible_Partner_Tracks__c = request.Eligible_Partner_Tracks__c+';'+testPartnerTrackObj.Id;//String.valueOf(testPartnerTrackObj.Id+';'+testPartnerTrackObj1.Id)
            request.Location_Of_User__c = testPartnerTrackObj.Id;
            request.Enable_Partner_Group_Admin__c  = false;
            request.Enable_as_Partner_Admin__c = false;
            request.Feature_Request_Deal_Registration__c = !request.Feature_Request_Deal_Registration__c;
            request.Partner_Central__c = !request.Partner_Central__c;
            request.Program_Tracker__c = !request.Program_Tracker__c;
            request.Enable_Premier_Pages_access_Flag__c = !request.Enable_Premier_Pages_access_Flag__c;
            request.RFP_Proposal_Express_Tool__c = !request.RFP_Proposal_Express_Tool__c;
            request.Feature_Request_Lead_Management__c = !request.Feature_Request_Lead_Management__c;
            request.Enable_as_Lead_Super_User__c = !request.Enable_as_Lead_Super_User__c;
            request.Feature_Request_Rebates__c = !request.Feature_Request_Rebates__c;
            request.Feature_Request_MDF__c = !request.Feature_Request_MDF__c;
            PartnerAdminsCreateContactCntrl extension = new PartnerAdminsCreateContactCntrl(new ApexPages.standardController(request));
            extension.strlocationOfUser = testPartnerTrackObj.Id;
            extension.updateAddress();
            extension.strenteredEmail = request.Email__c;
            request.Job_Category__c = 'Facilities';
            PageReference pg= extension.refreshPicklist();
            request.Job_Title__c = 'Facilities Manager';
            List<selectOption> listSO1= extension.getEligibleTracks();
            extension.listleftselected.add(testPartnerTrackObj.Id);
            List<selectOption> listSO2= extension.getEligibleTracksSelected();
            List<selectOption> listSO5= extension.getLocationOfTracksAvailable();
            PageReference pg4= extension.selectTrack();
            PageReference pg5= extension.unselectclick();
            extension.listleftselected.add(testPartnerTrackObj1.Id);
            List<selectOption> listSO3= extension.getEligibleTracks();
            List<selectOption> listSO4= extension.getEligibleTracksSelected();
            PageReference pg10= extension.selectTrack();
            extension.listrightselected.add(testPartnerTrackObj.Id);
            PageReference pg11= extension.unselectclick();
            extension.bisEmailChanged = true;
            PageReference actualURL = extension.doSave();
            con.EligibleTracks__c = request.Eligible_Partner_Tracks__c ;
            extension.executeUserUpdate();
        }
    }
}