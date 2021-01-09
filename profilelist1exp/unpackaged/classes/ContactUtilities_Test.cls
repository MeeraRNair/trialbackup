/**
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      General     16.10       28-Oct-2015     Ragu            Created.
 * 2.0      General     0203        09-Jan-2018     Ravali          CR:15378:Remove the code related to NPS_Criteria_met__c field
 * 3.0      General                 16-Mar-2018     Sakshi          CR: 15529: Added assert condition.
   4.0      General     0602        08-May-2018     Rahul           Commenting out test_ssoVendorAssociationHelper menthod
   5.0      PAM Changes 0402        18-Dec-2018     Sneha           Adding new method
 */
 
@isTest(SeeAllData=false)
private class ContactUtilities_Test {

    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
        OWD__c OWDsetting = new OWD__c();
        OWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        OWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        OWDsetting.Oppty_Stage100__c = 'Win - 100%';
        OWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        OWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        OWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        OWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        OWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert OWDsetting;
    }   
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END

    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }
    
    static testMethod void test_rollupQualifiedNPSContacts() {
        ContactTestData.bCreate = false;
        ContactTestData.iNumberOfContacts = 5;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        
        for(Contact conIterator : lstContacts) {
            conIterator.Survey__c = 'Yes';
            conIterator.Email_Opt_In__c = 'Yes';
            conIterator.Status__c = 'Customer';
            conIterator.Decision_Making_Role__c = 'Influencer';
        }
        
        // Starting actual test
        Test.startTest();
        Database.insert(lstContacts);
        Database.update(lstContacts);
        Account objAccount = [Select Id, No_of_Qualified_NPS_Contacts__c, NPS_Qualified_Contacts__c from Account where Name =: 'testAccount' Limit 1];
        system.assertEquals(5, objAccount.No_of_Qualified_NPS_Contacts__c);
        system.assertEquals(5, objAccount.NPS_Qualified_Contacts__c);
        Test.stopTest();
    }
    /*
    static testMethod void test_updatePartnerRequest() {
        Country__c testCountry = new Country__c(Code__c = 'IN', Region__c = 'APJ', Inc_Vendor_Name__c = 'Partner Advantage', Inc_Vendor_End_Point__c = 'https://www.dellpartnerincentives.com/UserManagement/UserManagementService.svc/Process');
        insert testCountry;
        
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        
        Account testAccount = new Account (Name = 'Test1', Account_Country_Code__c = 'IN', Account_Country__c = 'India', Type = 'Partner', RecordTypeId = masterAccountRecordTypeId);
        insert testAccount;
      
        Contact testContact = new Contact(AccountID = testAccount.ID, Email = 'Email_1@dellTeam.Com', FirstName = 'SpongeBob', LastName = '1', Title = 'VP', MailingStreet = '123 Main',
                                           MailingCity = 'Peoria', MailingState = 'IL', MailingPostalCode = '33333', Phone = '3213213211', MobilePhone = '3213213211', Fax = '3213123211', Status__c = 'Marketing Suspect');
        insert testContact;             
                   
        Id REQUEST_RECORD_TYPE_UPDATE_USER = StaticFactory.getRecordTypeIdByName('Partner_Request__c', PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER);
        Partner_Request__c partnerRequest = new Partner_Request__c (RecordTypeID = REQUEST_RECORD_TYPE_UPDATE_USER, Account__c = testAccount.Id, Contact__c = testContact.Id, Status__c = PartnerConstants.REG_STATUS_DRAFT);
        insert partnerRequest;
        
        
        // Starting actual test
        Test.startTest();
        
        testContact.Last_Operation_Performed__c = 'Vendor Updated';
        testContact.Vendor_Update_Datetime__c = System.today();
        testContact.Is_Enabled_for_Incentives__c = true;
        testContact.Is_Vendor_Updated__c = true;
        update testContact;
        
        partnerRequest = [select Status__c from Partner_Request__c where Contact__c = :testContact.Id];
        System.assertEquals(PartnerConstants.REG_STATUS_COMPLETE, partnerRequest.Status__c);
        
        
        partnerRequest = new Partner_Request__c (RecordTypeID = REQUEST_RECORD_TYPE_UPDATE_USER, Account__c = testAccount.Id, Contact__c = testContact.Id, Status__c = PartnerConstants.REG_STATUS_DRAFT);
        insert partnerRequest;
        
        testContact.Last_Operation_Performed__c = 'Vendor Sync failed';
        testContact.Vendor_Update_Datetime__c = System.today();
        testContact.Is_Enabled_for_Incentives__c = true;
        testContact.Is_Vendor_Updated__c = true;
        update testContact;
        
        partnerRequest = [select Status__c from Partner_Request__c where (Status__c = :PartnerConstants.REG_STATUS_INCOMPLETE or Status__c = :PartnerConstants.REG_STATUS_DRAFT) and RecordTypeId = :REQUEST_RECORD_TYPE_UPDATE_USER and Contact__r.Vendor_Update_Datetime__c != null and Contact__c = :testContact.Id order by CreatedDate desc]; 
        System.assertEquals(PartnerConstants.REG_STATUS_INCOMPLETE, partnerRequest.Status__c);
        
        Test.stopTest();
    }
    */
    static testMethod void test_associateContactToChannelLead() {
       TriggerExecutionController.setSkipAllTriggers(true);
        LeadTestData.bCreate = false;

        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstDirectLeads = LeadTestData.lstLeads;
        
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createChannelLead2();
        list<Lead> lstChannelLeads = LeadTestData.lstLeads;
        
        lstChannelLeads[1].Status = 'Converted to Deal Reg';
        list<Lead> lstLeads = new list<Lead>{lstDirectLeads[0], lstChannelLeads[0], lstChannelLeads[1]};
        Database.insert(lstLeads);

        ContactTestData.bCreate = false;
        ContactTestData.iNumberOfContacts = 3;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        lstContacts[0].Source_Id__c = 'test123';
        lstContacts[1].Source_Id__c = lstLeads[1].Id;
        lstContacts[2].Source_Id__c = lstLeads[2].Id;
        
        system.assertEquals(ContactTestData.bCreate, false);
        // Starting actual test
        Test.startTest();
        Database.insert(lstContacts);
        Map<Id, Contact> mapCon = new Map<Id, Contact>();
        for (Contact con : lstContacts){
            mapCon.put(con.Id, con);
        }
        ContactUtilities.associateContactToChannelLead(mapCon);
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void test_updateAccountInRelationshipLead() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        Id campRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Campaign 2.0').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.Name = 'testMasterAccount';
        testAccount.NPS_Qualified_Contacts__c = 1;
        testAccount.RecordTypeId = masterAccountRecordTypeId;
        insert testAccount;
        
        Account testAccount2 = new Account();
        testAccount2.Name = 'testMasterAccount 2';
        testAccount2.NPS_Qualified_Contacts__c = 1;
        testAccount2.RecordTypeId = masterAccountRecordTypeId;
        insert testAccount2;
        
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.Email = 'test@test.com';
        testContact.phone = '6739';
        testContact.LastName = 'conLastName';
        testContact.FirstName = 'conFirstName';
        testContact.Status__c = 'Customer';
        testContact.Email_Opt_In__c = 'yes';
        testContact.Survey__c = 'yes';
        testContact.Decision_Making_Role__c = 'Technical Buyer';
        TriggerExecutionController.setSkipAllTriggers(false);
        system.assertEquals(testContact.AccountId,testAccount.Id);
        Test.startTest();  
        insert testContact;
        /*
        Campaign testCampaign = new Campaign(Name = 'Test RL Campaign',
                                    Campaign_Objective__c = 'LOB Conversion',
                                    Type = 'DM',
                                    Segment_Business_Unit__c = 'PUB',                                 
                                    StartDate=System.Today() - 12,
                                    EndDate=System.Today(),
                                    Description = 'This is Test RL Campaign',
                                    IsActive = true,
                                    RecordTypeId =campRecordTypeId);
    
        insert testCampaign;
        
        Id leadQualificationRT = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
        Lead testLead = new Lead(FirstName = 'Test RL',
                        LastName = 'Lead',
                        Company = 'Test Company',
                        Status = 'Open',
                        Phone = '876769',
                        Country ='Malaysia',
                        LeadSource = 'Expert',
                        Lead_Type__c ='Inbound', 
                        Campaign__c = testCampaign.Id,
                        Contact__c = testContact.Id,
                        Dell_Partner_can_contact_me__c = true,
                        RecordTypeId = leadQualificationRT);
        insert testLead;
        
        // To create an existing CM and RL record with testConList[i]
        CampaignMember testCampaignMember = new CampaignMember(CampaignId = testCampaign.Id, Campaign_Vehicle__c = testCampaign.Type, ContactId = testContact.Id, CM_Status__c = 'Requires Follow-Up');
        insert testCampaignMember;      
        
        Opportunity testOppty1 = new Opportunity(Name = 'Test Opportunity', AccountId = testAccount.Id, StageName = 'Commit - 90%', Competitor_Lost_To__c = 'Unknown',CloseDate = System.Today() + 20);
        insert testOppty1;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Relationship_Lead__c relationshipLead = new Relationship_Lead__c(Deal_Reg_Opportunity_Name__c = testOppty1.Id, Contact__c = testContact.Id,
                                                                Campaign__c = testCampaign.Id,
                                                                CM_Source__c = testLead.Id,
                                                                Status__c = 'Requires Follow-up',
                                                                Inside_Sales_Rep__c = UserInfo.getUserId());
        insert relationshipLead;
        
        */
        // Starting actual test
        
        testContact.AccountId = testAccount2.Id;
        update testContact;
        Test.stopTest();
    }
    
    static testMethod void test_checkAndUpdatePrimaryContactDetails() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        Account testAccount = new Account();
        testAccount.Name = 'testMasterAccount';
        testAccount.NPS_Qualified_Contacts__c = 1;
        testAccount.RecordTypeId = masterAccountRecordTypeId;
        insert testAccount;

        List<Contact> lst_Con = new List<Contact>();
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.Email = 'test@test22.com';
        testContact.phone = '6739';
        testContact.LastName = 'conLastName 11';
        testContact.FirstName = 'conFirstName';
        testContact.Status__c = 'Customer';
        testContact.Email_Opt_In__c = 'yes';
        testContact.Survey__c = 'yes';
        testContact.Decision_Making_Role__c = 'Technical Buyer';
        testContact.Primary_Contact__c = false;
        lst_Con.add(testContact);
        
        Contact testContact2 = new Contact();
        testContact2.AccountId = testAccount.Id;
        testContact2.Email = 'test@test22.com';
        testContact2.phone = '6739';
        testContact2.LastName = 'conLastName 22';
        testContact2.FirstName = 'conFirstName';
        testContact2.Status__c = 'Customer';
        testContact2.Email_Opt_In__c = 'yes';
        testContact2.Survey__c = 'yes';
        testContact2.Decision_Making_Role__c = 'Technical Buyer';
        testContact2.Primary_Contact__c = false;
        lst_Con.add(testContact2);
        Test.startTest();
        
        insert lst_Con;
        system.assertEquals(testContact.AccountId,testAccount.Id);
        TriggerExecutionController.setSkipAllTriggers(false); 
        
        lst_Con[0].Primary_Contact__c = true; 
        //lst_Con[1].Primary_Contact__c = true; 
        update lst_Con;
        Test.stopTest();
    }
    
    static testMethod void test_checkAndUpdatePrimaryContactDetails2() {
        TriggerExecutionController.setSkipAllTriggers(true);
         Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        Account testAccount = new Account();
        testAccount.Name = 'testMasterAccount';
        testAccount.NPS_Qualified_Contacts__c = 1;
        testAccount.RecordTypeId = masterAccountRecordTypeId;
        insert testAccount;

        List<Contact> lst_Con = new List<Contact>();
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.Email = 'test@test.com';
        testContact.phone = '6739';
        testContact.LastName = 'conLastName 1';
        testContact.FirstName = 'conFirstName';
        testContact.Status__c = 'Customer';
        testContact.Email_Opt_In__c = 'yes';
        testContact.Survey__c = 'yes';
        testContact.Decision_Making_Role__c = 'Technical Buyer';
        testContact.Primary_Contact__c = true;
        lst_Con.add(testContact);
        
        Contact testContact2 = new Contact();
        testContact2.AccountId = testAccount.Id;
        testContact2.Email = 'test@test12.com';
        testContact2.phone = '6739';
        testContact2.LastName = 'conLastName 2';
        testContact2.FirstName = 'conFirstName';
        testContact2.Status__c = 'Customer';
        testContact2.Email_Opt_In__c = 'yes';
        testContact2.Survey__c = 'yes';
        testContact2.Decision_Making_Role__c = 'Technical Buyer';
        testContact2.Primary_Contact__c = true;
        lst_Con.add(testContact2);
        system.assertEquals(testContact.AccountId,testAccount.Id);
        Test.startTest();
          
        insert lst_Con;
        
        TriggerExecutionController.setSkipAllTriggers(false); 
        
        lst_Con[0].Primary_Contact__c = false; 
        lst_Con[1].Primary_Contact__c = false; 
        update lst_Con;
        Test.stopTest();
    }
    
    static testMethod void test_updateNPSQualifiedContactsOnAccount() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.NPS_Qualified_Contacts__c = 1;
        insert testAccount;
       
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.Email = null;
        testContact.phone = '6739';
        testContact.LastName = 'conLastName';
        testContact.FirstName = 'conFirstName';
        testContact.Status__c = 'Customer';
        testContact.Email_Opt_In__c = 'yes';
        testContact.Survey__c = 'yes';
        testContact.Decision_Making_Role__c = 'Technical Buyer';
        //testContact.NPS_Criteria_Met__c = false; //v2.0
        insert testContact;
        system.assertEquals(testContact.AccountId,testAccount.Id);
        TriggerExecutionController.setSkipAllTriggers(false); 
        
        testContact.Email = 'test@test.com';
        //testContact.NPS_Criteria_Met__c = true; //v2.0
        update testContact;
          
        testContact.Email = null;
        //testContact.NPS_Criteria_Met__c = false; //v2.0
        update testContact;
    }
    
    //static testMethod void test_integratePartnerDataHelper() {
        
  // }
    
   /* static testMethod void test_ssoVendorAssociationHelper() {
        TriggerExecutionController.setSkipAllTriggers(true);
        // Create Country
        Country__c testCountry = new Country__c(Code__c = 'IN', Region__c = 'APJ', Inc_Vendor_Name__c = 'Dell Achievers', Inc_Vendor_End_Point__c = 'Test End point');
        insert testCountry;
        
        // Create Account
        Account testAcc = new Account(Name = 'Test Account',
                                      RecordTypeId = StaticFactory.getRecordTypeIdByName('Account', 'Partner Account'),
                                      Status__c = 'Active', 
                                      Partner_Relationship__c = 'Registered',
                                      Account_Country_Code__c = 'IN',
                                      Is_Enabled_for_Incentives__c = true,
                                      Type = 'Partner');
        insert testAcc;
        testAcc.IsPartner = true;
        update testAcc;
        //v2.0 
         Account testAcc2 = new Account(Name = 'Test Account2',
                                      RecordTypeId = StaticFactory.getRecordTypeIdByName('Account', 'Partner Account'),
                                      Status__c = 'Active', 
                                      Partner_Relationship__c = 'Registered',
                                      Account_Country_Code__c = 'IN',
                                      Is_Enabled_for_Incentives__c = true,
                                      Type = 'Partner');
        insert testAcc2;
        //v2.0
        
         // Create Contact
        String email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com';
        Contact testContact = new Contact(AccountId = testAcc.Id, Email = email, Lastname = 'Contact',Partner_My_Account_GUID__c = 'Test myaccount guid');
        insert testContact;
        
        // Select Profile
        //Profile prof = [select Id from Profile where Name LIKE '%PRM Portal%' LIMIT 1];
        Profile prof = [select Id from Profile where Name LIKE '%PRM Portal%' and usertype='PowerPartner' limit 1]; 
       
        
        // Create test User        
        User testUser = new User(ContactId = testContact.Id, IsActive = true, Email = email, LanguageLocaleKey = 'en_US', 
                                LastName = 'UT', Alias = 'UT', CommunityNickname = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'), 
                                TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
                                ProfileId = prof.Id, UserName = email, Badge_Number__c = String.valueOf(Datetime.now()));
        insert testUser;
        
        //Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        UserRole testUserRole = [select id, name from userrole where name = 'WW_Exec' limit 1];
        
        User adminusr = [select Id, username from User where ProfileId = '00e30000000nJ6K' AND IsActive=true][0];
        User testUser1;
        
        System.runAs(adminusr) {
            testUser1 = new User(Username = 'boomi_integuser' +'@dell.comtest',
                                    Alias = 'Test', 
                                    Email = 'Test'+'@dell.com',            
                                    LastName = 'Test',
                                    ProfileId = '00eA0000000hNqF', 
                                    LanguageLocaleKey = 'en_US', 
                                    LocaleSidKey = 'en_US', 
                                    EmailEncodingKey = 'UTF-8', 
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    Badge_Number__c = 'Test'+System.currentTimeMillis(),
                                    UserRoleId = testUserRole.Id);
            insert testUser1;
        }
        
        testAcc.OwnerId = testUser1.Id;
        update testAcc;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        // Starting actual test
        Test.startTest();
        
        System.runAs(testUser1) {
            testContact.Is_Vendor_Updated__c = true;
            testContact.Last_Operation_Performed__c = 'Vendor Updated';
            testContact.Vendor_Update_Datetime__c = System.now();
            update testContact;
        }
           
        //v2.0
        testContact.AccountId = testAcc2.Id;   
        testContact.Vendor_Update_Datetime__c = System.now();
        update testContact;
        //v2.0
        
        // Asserts that the update was a success
        testContact = [select id,AccountId from Contact where Id= :testContact.Id];
        System.assertEquals(testContact.AccountId, testAcc2.Id);   
        
        Test.stopTest();
   } */
    
    static testMethod void test_populateSolutionArchitectInformation() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Account testAccount = new Account(Name = 'testAccount');     
        insert testAccount; 
        
        Contact testContact = new Contact(AccountID = testAccount.ID, Email = 'Email_115@dellTeam.Com', FirstName = 'TestContact', LastName = '1', Title = 'VP', MailingStreet = '123 Main', MailingCity = 'Peoria', MailingState = 'IL', MailingCountry = 'US', MailingPostalCode = '33333', Phone = '3213213211', MobilePhone = '3213213211', Fax = '3213123211', Status__c = 'Marketing Suspect');      
        insert testContact;             

        Opportunity testOpp = new opportunity();
        testOpp.Name = 'Test Opportunity';
        testOpp.StageName = 'Plan - 10%';
        testOpp.Forecast_Category_Override__c = 'Pipeline';
        testOpp.CloseDate = System.today();
        insert testOpp;
        
        // Get  Request Custom Service Support Record type id
        Id RCSSRTId = StaticFactory.getRecordTypeIdByName('Support_Request__c', 'Request Custom Service Support');    

        Support_Request__c supportRequest = new Support_Request__c(RecordTypeId = RCSSRTId, Opportunity__c = testOpp.Id, Solution_Architect__c = 'Yes',
                                    Engagement_Time_Frame__c = System.today() + 10, Project_Type__c = 'CWS', Project_Duration_months__c = 2, 
                                    Decision_Date__c = System.today() + 10, Primary_Work_Delivery_Language__c = 'English', Suggested_Delivery_Method__c = 'Standard Offer', 
                                    Custom_Service_Support__c = 'Custom Service Solution', Comments__c = 'Test Comments', Deliverable_Due_Date__c = System.today() + 15, Customer_Contact_InformationName__c = testContact.Id);
        
        insert supportRequest;
        TriggerExecutionController.setSkipAllTriggers(false);

        
        // Starting actual test
        Test.startTest();

        // Update the Contact details
        testContact.Email = 'Email_225@dellTeam.Com';
        testContact.LastName = '2';
        testContact.Phone = '3213213333';
        testContact.MailingStreet = '1234 Main';
        testContact.MailingCity = 'Peoria2';
        testContact.MailingState = 'IL2';
        testContact.MailingCountry = 'US2';
        update testContact;
        
        supportRequest = [select Id, Customer_Contact_Information_Name__c, Customer_Contact_Information_Phone__c, Customer_Contact_Information_Email__c, Primary_Work_Delivery_Address_1__c, Primary_Work_Delivery_City__c, Primary_Work_Delivery_State_Province__c, Primary_Work_Delivery_Country__c from Support_Request__c where Id = :supportRequest.Id];
        testContact = [select Id, Name, Phone, Email, MailingStreet, MailingCity, MailingState, MailingCountry from Contact where Id = :testContact.Id];
        
        // Assert the new Contact field values are updated in Support Request object
        System.assertEquals(testContact.Name, supportRequest.Customer_Contact_Information_Name__c);
        System.assertEquals(testContact.Phone, supportRequest.Customer_Contact_Information_Phone__c);
        System.assertEquals(testContact.Email, supportRequest.Customer_Contact_Information_Email__c);
        System.assertEquals(testContact.MailingStreet, supportRequest.Primary_Work_Delivery_Address_1__c);
        System.assertEquals(testContact.MailingCity, supportRequest.Primary_Work_Delivery_City__c);
        System.assertEquals(testContact.MailingState, supportRequest.Primary_Work_Delivery_State_Province__c);
        System.assertEquals(testContact.MailingCountry, supportRequest.Primary_Work_Delivery_Country__c);          
        
        Test.stopTest();
    }
    
    static testMethod void test_updateCTICallLog() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Sales_Channel_Group__c objSalesChannelGrp = new Sales_Channel_Group__c();
        objSalesChannelGrp.Name = 'TestChannelGroup1';
        objSalesChannelGrp.Region_Name__c = 'REGION1';
        objSalesChannelGrp.Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE';        
        insert objSalesChannelGrp;
        
        Account objAccount = new Account();
        objAccount.Name = 'TestAccount';
        objAccount.Sales_Channel__c = objSalesChannelGrp.Id;
        insert objAccount;
        
        CTI_Call_Log__c objCTICL = new CTI_Call_Log__c();
        objCTICL.Account__c = objAccount.Id;
        insert objCTICL;
        
        Opportunity objOpp = new Opportunity();
        objOpp.RecordTypeId = '012300000004zf2';
        objOpp.Quote_Numbers__c = '123456';
        objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
        objOpp.StageName = 'Propose - 60%';
        objOpp.Probability = 60;
        objOpp.AccountId = objAccount.Id;
        objOpp.Name = 'TEST Oppty 1';
        objOpp.CloseDate = System.today() + 30;
        objOpp.Primary_Product_Delivery_Address_Region__c = 'REGION1';
        objOpp.Primary_Product_Delivery_Address_Country__c = 'COUNTRY1';
        objOpp.Region__c = 'APJ';
        objOpp.Competitor_Lost_To__c = 'Unknown';
        objOpp.CTI_Call_Log_Id__c = objCTICL.Id;
        insert objOpp;
        TriggerExecutionController.setSkipAllTriggers(false);
        system.assertEquals(objCTICL.Account__c,objAccount.Id);
        // Starting actual test
        Test.startTest();
        
        Contact objCon = new Contact();
        objCon.FirstName = 'Test FName';
        objCon.LastName = 'Test LastName';
        objCon.CTI_Call_Log_Id__c = objCTICL.Id;
        objCon.AccountId = objAccount.Id;
        objCon.Phone = '1234567890';
        insert objCon;
        
        Test.stopTest();
    }
    
    static testMethod void testgrantRevokeAccess(){
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        TriggerExecutionController.setSkipAccountTriggers(true);
        
        Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        insert acc;
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj1;
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj2;
        
        Account salesAcc = new Account();
        salesAcc.Name = 'testSalesmotionAccount';
        salesAcc.NPS_Qualified_Contacts__c = 1;
        salesAcc.Partner_Track__c = testPartnerTrackObj.id;
        salesAcc.Master_Group_Id__c = acc.id;
        insert salesAcc; 
        
        Account salesAcc2 = new Account();
        salesAcc2.Name = 'testSalesmotionAccount 2';
        salesAcc2.NPS_Qualified_Contacts__c = 1;
        salesAcc2.Partner_Track__c = testPartnerTrackObj2.id;
        salesAcc2.Master_Group_Id__c = acc.id;
        insert salesAcc2;
        
        final List<Contact> activeContacts = new List<Contact>();
        for(Integer i = 0; i < 6; i++){
            activeContacts.add(
                new Contact(
                    AccountId = acc.Id,
                    Email=''+i+'@DELLTEAM.com', 
                    FirstName = 'John', 
                    LastName = 'Test'+i,
                    Status__c = 'Customer',
                    phone = '6739',
                    EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';'
                )
            );
        }
        
        final List<Contact> inActiveContacts = new List<Contact>();
        for(Integer i = 0; i < 6; i++){
            inActiveContacts.add(
                new Contact(
                    AccountId = acc.Id,
                    Email=''+i+'@DELLTEAMInactive.com', 
                    FirstName = 'John', 
                    LastName = 'testInactive'+i,
                    Status__c = 'Invalid - No Longer w/ Company',
                    phone = '673911',
                    EligibleTracks__c = testPartnerTrackObj.id
                )
            );
        }
        system.assertEquals(testPartnerTrackObj.Master_Group_Id__c, acc.Id);
        Test.startTest();
        insert activeContacts;
        insert inActiveContacts;
        activeContacts[0].EligibleTracks__c = testPartnerTrackObj2.id;
        
        update activeContacts;
        
        Test.stopTest();
        
        
    }
    
    static testMethod void testRevokegrantRevokeAccess(){
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        TriggerExecutionController.setSkipAccountTriggers(true);
        
        Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        insert acc;
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj1;
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj2;
        
        Account salesAcc = new Account();
        salesAcc.Name = 'testSalesmotionAccount';
        salesAcc.NPS_Qualified_Contacts__c = 1;
        salesAcc.Partner_Track__c = testPartnerTrackObj.id;
        salesAcc.Master_Group_Id__c = acc.id;
        insert salesAcc; 
        
        Account salesAcc2 = new Account();
        salesAcc2.Name = 'testSalesmotionAccount 2';
        salesAcc2.NPS_Qualified_Contacts__c = 1;
        salesAcc2.Partner_Track__c = testPartnerTrackObj2.id;
        salesAcc2.Master_Group_Id__c = acc.id;
        insert salesAcc2;
        
        final List<Contact> activeContacts = new List<Contact>();
        for(Integer i = 0; i < 6; i++){
            activeContacts.add(
                new Contact(
                    AccountId = acc.Id,
                    Email=''+i+'@DELLTEAM.com', 
                    FirstName = 'John', 
                    LastName = 'Test'+i,
                    Status__c = 'Customer',
                    phone = '6739',
                    EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';'
                )
            );
        }
        
        final List<Contact> inActiveContacts = new List<Contact>();
        for(Integer i = 0; i < 6; i++){
            inActiveContacts.add(
                new Contact(
                    AccountId = acc.Id,
                    Email=''+i+'@DELLTEAMInactive.com', 
                    FirstName = 'John', 
                    LastName = 'testInactive'+i,
                    Status__c = 'Invalid - No Longer w/ Company',
                    phone = '673911',
                    EligibleTracks__c = testPartnerTrackObj.id
                )
            );
        }
        system.assertEquals(testPartnerTrackObj.Master_Group_Id__c, acc.Id);
        Test.startTest();
        insert activeContacts;
        insert inActiveContacts;
        activeContacts[0].EligibleTracks__c = '';
        update activeContacts;
        Test.stopTest();
        
        
    }
    
    
}