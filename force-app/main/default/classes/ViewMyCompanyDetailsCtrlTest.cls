@IsTest
private class ViewMyCompanyDetailsCtrlTest {
    /*
    Private static testmethod void testWithValidation(){
        TriggerExecutionController.setSkipUserTriggers(true);
        User partnerAdminUser = createPartnerUsers(false,2,null).get(0);
        Test.startTest();
        System.runAs(partnerAdminUser){
            ViewMyCompanyDetailsCtrl extension = new ViewMyCompanyDetailsCtrl(new ApexPages.standardController(new Partner_Request__c()));            
            System.assertEquals(partnerAdminUser.UserRole,null);
            System.assertEquals(StringUtils.isBlank(partnerAdminUser.UserRole.Name),true); 
            System.assertEquals(partnerAdminUser.Contact.Id,null); 
            System.assertEquals(partnerAdminUser.Contact.AccountId,null);            
        }
        Test.stopTest();
        TriggerExecutionController.setSkipUserTriggers(false);
    }   
    */
   private static testmethod void testStdUserValidationError(){        
        System.runAs(createStandardUsers(1).get(0)){
            //ViewMyCompanyDetailsCtrl extension1 = new ViewMyCompanyDetailsCtrl();
            ViewMyCompanyDetailsCtrl extension = new ViewMyCompanyDetailsCtrl(new ApexPages.standardController(new Partner_Request__c()));            
            System.assertEquals(false,extension.bisPortalUser);     
        }      
    } 
    
   /* Private static testmethod void testWithNoValidation(){        
        User partnerAdminUser = createPartnerUsers(true,2,null).get(0);
        System.runAs(partnerAdminUser){
            ViewMyCompanyDetailsCtrl extension = new ViewMyCompanyDetailsCtrl(new ApexPages.standardController(new Partner_Request__c()));            
            System.assertEquals(true,extension.isPortalUser); 
        }
    } */
    
    public static testmethod void testcompanyDataOnLoad(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        User admin = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND Id <> :UserInfo.getUserId()][0];
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =: 'PowerPartner' limit 2]);
        
        Account acc = new Account (Name = 'newAcc1',Account_Country_Code__c = 'AA',Account_Country__c = 'TEST COUNTRY Sandbox',Website='https://www.testPA.com',
                                  Does_Business_As__c='DSA',Phone='1234567890',BillingStreet='BS',BillingCity='BCITY',BillingState='BSTATE',
                        BillingPostalCode='BPS',BillingCountry='BCNTY',Form_of_Organization__c='FC',Number_of_years_in_business__c='NYB',Principle_Name1__c='PN',Principle_Title1__c='PT',
                        Capability__c='CPTY');
        Test.startTest();
        insert acc;
        
        acc.IsPartner = true;
        update acc;
        
        Track__c trackObj = new Track__c(Name= 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c='OEM');
        insert trackObj;
        system.debug('trackObj*****'+trackObj);
        
        Track__c trackObj2 = new Track__c(Name= 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c='Solution Provider');
        insert trackObj2;
        system.debug('trackObj*****'+trackObj2);
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.Id;
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c = acc.Account_Id__c;
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold1';
        testPartnerTrackObj.Primary_SMAffinity_Account__c = acc.Id;
        testPartnerTrackObj.Countries_doing_business_in__c = 'PT-Country';
        testPartnerTrackObj.Sponsoring_Distributor_OEM__c = 'PT-OEM';
        testPartnerTrackObj.Sponsoring_Distributor_Solution_Provid__c = 'PT-SP';
        testPartnerTrackObj.Services_Competencies__c = 'Centera Support';
        testPartnerTrackObj.Purchase_Path__c='PP';
        testPartnerTrackObj.Dell_Certification_Areas__c='Networking';
        testPartnerTrackObj.Product_Focus__c='Desktops';
        testPartnerTrackObj.Preferred_Distributor__c='PD';
        testPartnerTrackObj.Speciality_Product_Purchase_Path__c='SPP';
        testPartnerTrackObj.Partner_Registration_Number__c='PRN';
        testPartnerTrackObj.Diverse_Owned_Business__c=true;
        testPartnerTrackObj.Diversity_Certification__c='DC';
        testPartnerTrackObj.Diversity_Certification_Other__c = 'DC-1';
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj2.id;
        testPartnerTrackObj1.Master_Group_Id__c = acc.Id;
        insert testPartnerTrackObj1;
        system.debug('partnertrack'+testPartnerTrackObj1);
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data 22';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = acc.Id;
        insert testPartnerTrackObj2;
       
        List<Contact> listcon = new List<contact>();
        Contact con = new Contact (AccountId = acc.id,LastName = 'portalTestUser',Email='testingdit5@gshaj.com',
                                   Selected_Track__c = testPartnerTrackObj.id,
                                   EligibleTracks__c = testPartnerTrackObj1.id+';'+testPartnerTrackObj2.Id);
        listcon.add(con);
        
        Contact con1 = new Contact (Salutation='Mrs',AccountId = acc.id,FirstName='Testing', LastName = 'portalTestUser2',Email='tuitingdit5@gshaj.com',
                                   Other_Job_Function_Category__c ='others',Phone='12345',Allow_Partner_Central_User__c=false,
                                   Allow_Program_Tracker__c = false, Is_MDF_User__c = false, Is_Rebate_User__c = false, Premier_Partner__c = false,
                                   Allow_RFP_and_Proposal_Express_Tool__c = false,
                                   Selected_Track__c = testPartnerTrackObj1.id,
                                   EligibleTracks__c = testPartnerTrackObj1.id+';'+testPartnerTrackObj2.Id);
        listcon.add(con1);
        
        insert listcon;
        
        
        Integer intuserNumber  = getNextUserSerialNumber();
        String strnewusername  = 'bilot'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber  = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomLong()));
                
        List<User> listusr = new List<User>();
        
        User newUser = new User(profileId = listp[1].id,username = strnewusername ,email = 'vmcd@ff.com',Badge_Number__c= strbadgeNumber.substring(0, 10),
                                emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                timezonesidkey = 'America/Los_Angeles',alias='nuservmc',lastname='lastname vmc',contactId = listcon[0].id,
                                Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        
        listusr.add(newUser);
        
        Integer intuserNumber1 = getNextUserSerialNumber();
        String strnewusername1 = 'biulom'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber1 = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomLong()));
        
        User newUser2 = new User(profileId = listp[1].id,username = strnewusername1,email = 'vmcd@ff.com',Badge_Number__c=strbadgeNumber1.substring(0,10),
                                 emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                 timezonesidkey = 'America/Los_Angeles',alias='useruivm',firstName='yui vmc',lastname='lastnameklu',contactId = listcon[1].id,
                                 Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true,
                                 Enable_Partner_Deal_Registration__c = true, Enable_Partner_Lead_Management__c = true,Enable_As_Partner_Lead_Super_User__c = true);
        
        listusr.add(newUser2);
        
        insert listusr;
        
        Service_Information__c si = new Service_Information__c(Services_Performance_Deploy__c='SPD',Services_Performance_Support__c='SPS',Partner_Track__c=testPartnerTrackObj.id);
        insert si;
        
        System.runAs(listusr[0]){
          Partner_Request__c request = new Partner_Request__c();
          ViewMyCompanyDetailsCtrl extension = new ViewMyCompanyDetailsCtrl(new ApexPages.standardController(request));  
          PageReference pf = extension.doEditJob(); 
          System.assertEquals(true,extension.bisEditMode); 
             
          PageReference pf1 = extension.doCancelJob();
          System.assertEquals(false,extension.bisEditMode);
          
          request.Org_Phone__c = '1231231230';
          request.Partner_Track_Account_Local_Name__c = 'PTAC';
          insert request;
        
          extension.request = request;        
          PageReference pf2 = extension.doSaveJob();
          
       }
        
    }
    
   private static Integer intnextUserSerialNumber = -1;
   private static Integer getNextUserSerialNumber(){
        intnextUserSerialNumber++;
        return intnextUserSerialNumber;
    }
    
    private static List<User> createStandardUsers(Integer intmax){
        final List<Profile> profiles = [select id,name from Profile where UserType = 'Standard' and Profile.name = 'System Administrator'  limit :intmax];        
        final List<User> users = new List<User>();
        
        for(Integer inti = 0; inti < profiles.size(); inti++){
            Integer intuserNumber = getNextUserSerialNumber();
            users.add(
                new User(
                    Username=''+intuserNumber+'@DELLTEAM.com',
                    Alias = 'test'+intuserNumber, 
                    Email=''+intuserNumber+'@DELLTEAM.com', 
                    FirstName='John', 
                    LastName='Doe'+intuserNumber, 
                    ProfileId = profiles.get(inti).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c=''+9005000+intuserNumber 
                )
            );
        }
        insert users;
        return users;
    }
    /*
    private static List<User> createPartnerUsers(Boolean admin, Integer intmax, id accountId){
        TriggerExecutionController.setSkipAllTriggers(true);
        final List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' limit :intmax];
        //System.assert(!(partnerProfiles == null || partnerProfiles.size() <= 0), 'No partner profiles exist therefore test cannot be executed');
        System.debug('partnerProfiles::'+partnerProfiles);
        final List<Account> accounts = new List<Account>();        
            if(accountId == null){
            for(Integer inti = 0; inti < partnerProfiles.size(); inti++){
                accounts.add(
                    new Account(
                        name='AccTest ' + inti,
                        Account_Country_Code__c = 'AI',
                        Account_Country__c = 'ANGUILIA'
                    )
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
        if(admin){
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
                    Status__c = 'Marketing Suspect'
                  
                )
            );
        }
        insert contacts;
        }
        else{
            for(Integer inti = 0; inti < partnerProfiles.size(); inti++){
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
                    Status__c = 'Marketing Suspect'             
                )
            );
            }
            insert contacts;            
        }
        
        System.debug('contacts::'+contacts+'::Size:'+contacts.size());
        final List<User> users = new List<User>();
        String usrname ='testclassUser'+string.valueof(Math.abs(Crypto.getRandomInteger()))+'@dell.com';
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0,10);
        system.debug('Random Number-' + randomNumber);
         Profile p = [select id from profile where name='System Administrator' LIMIT 1];
         User u = new User( alias = 'standt', email='testproUser@dell.com', 
                            emailencodingkey='UTF-8', lastname='Testing', 
                            languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p.Id,
                            timezonesidkey='America/Los_Angeles',Badge_Number__c=randomNumber, 
                            username=usrname); 
        UserRole ur = new UserRole(Name = 'CEO',Id='00EA0000001037nMAA');
        //insert ur;
        
        System.runAs(u) {
        for(Integer inti = 0; inti < partnerProfiles.size(); inti++){
            Integer intuserNumber =getNextUserSerialNumber();
            users.add(
                new User(
                    Username='testing'+intuserNumber+'@DELLTEAM.com',
                    Alias = 'test'+intuserNumber, 
                    Email=''+intuserNumber+'@DELLTEAM.com', 
                    FirstName='Jhon', 
                    LastName='Test'+intuserNumber, 
                    ProfileId = partnerProfiles[1].Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='ISO-8859-1', 
                    TimeZoneSidKey='America/New_York',
                    Badge_Number__c=null, 
                    ContactId = contacts[inti].id,
                    UserRoleId = ur.Id,
                    Enable_Partner_Admin__c = admin,
                    Enable_as_Partner_Group_Administrator__c = admin,
                    isActive = TRUE
                )
            );
        }
        
        insert users;
        }
        System.debug('users'+users);
        return users;        
    }
    */
}