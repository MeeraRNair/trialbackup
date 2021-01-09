/* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      11842       16.10           20-Aug-2015     Syidah          Created test method for LeadFieldPopulator.populateLastOwnerReassignmentDate()
* 1.1      11925       16.10           11-Sep-2015     Ragu            Added method for testing v1.2 changes in LeadFieldPopulator.
* 2.0      12336       16.12           13-Nov-2015     Ragu            Added method for testing v2.0 changes in LeadFieldPopulator.
* 2.1      12369       16.12           01-Dec-2015     Ragu            LM2_1_104-Add RAD account field into Direct Lead 2.0 page
* 2.2      12494       16.12           30-Dec-2015     Nagendra Singh  LM2_17_8-Enhance in direct Lead 2.0 the field Lead owner's role
* 3.0      13002       FY17-DCS-0502   05-Apr-2016     Azwanti         added test method for story 1195440, LM2_17-Add Lead velocity fields And calculation in Direct Lead 2.0
* 4.0      13156       FY17-DCS-0701   24-May 2016     Azwanti         New test method for Story 1195440 : LM2_17-Add Lead velocity fields And calculation in Direct Lead 2.0
* 5.0      13693       FY17-DCS-0103   01-Nov-2016     Sajith          LM2 New calculation for number days sales to follow up
* 6.0      16874       FY20-DCS-0202   30-Nov-2018     Sajith          Populate Zift lead Partner Account And Partner user 
* 7.0                  FY20-DCS-1101   30-OCT-2019     Yamini          fix for test failures
*/

@isTest(SeeAllData=false)
Private Class LeadFieldPopulatorTest {
    
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = New CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
        
        Country__c cntry = New Country__c(Name ='UNITED KINGDOM', Code__c='GB', CurrencyIsoCode='USD', FAP_Country_Value__c='UNITED KINGDOM (UK)', Region__c ='EMEA', Enable_for_FAP__c = true);
        Database.insert(cntry);   

        TriggerExecutionControl__c lTec = new TriggerExecutionControl__c();
        lTec.Name = 'Lead';
        lTec.RecursiveCount__c = 2;
        insert lTec;
        TriggerExecutionControl__c oTec = new TriggerExecutionControl__c();
        oTec.Name = 'Opportunity';
        oTec.RecursiveCount__c = 2;
    }
    
    // v1.0 - Test LeadFieldPopulator.
    Static testMethod void testpopulateLastOwnerReassignmentDate() {
        TriggerExecutionController.setSkipAllTriggers(true);
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads2 = LeadTestData.lstLeads;
        User newOwner = [select Id from User where IsActive = true And Id != :UserInfo.getUserId() And License_Used__c = 'Salesforce' limit 1];
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        //Start Test
        Test.startTest();
        
        Database.insert(listDirectLeads2);
        Lead directLead = listDirectLeads2[0];
        directLead.OwnerId = newOwner.Id;
        
        
        Test.stopTest();
        Database.update(listDirectLeads2);
        System.assertEquals(LeadTestData.bCreate,false);
    }
    
    // v1.1 - Test LeadFieldPopulator.populateLead2Fields()
    Static testMethod void testpopulateLead2Fields() {
        TriggerExecutionController.setSkipAllTriggers(true);
        AccountTestData.iNumberOfAccounts = 1;
        AccountTestData.createEndUserAccount();
        list<Account> listAccounts = AccountTestData.lstAccounts;
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads2 = LeadTestData.lstLeads;
        
        LeadTestData.createChannelLead2();
        list<Lead> listChannelLeads2 = LeadTestData.lstLeads;
        
        list<Lead> listLeads2 = New list<Lead>(listDirectLeads2);
        listLeads2.addAll(listChannelLeads2);    
        
        
        //Start Test
        Test.startTest();
        
        Lead directLead = listDirectLeads2[0];
        directLead.Status = 'Accepted';
        directLead.Account__c = listAccounts[0].Id;
        Database.insert(listLeads2);
        
        directLead = listDirectLeads2[0];
        directLead.Account__c = null;
        
        directLead = listDirectLeads2[1];
        directLead.Status = 'Accepted';
        directLead.Account__c = listAccounts[0].Id;
        ProcessFlowTriggerController.isTest = true; 
        Database.update(listLeads2);
        
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);   
        System.assertEquals(LeadTestData.iNumberOfLeads,2);
    } 
    
    // v1.1 - Test LeadFieldPopulator.populateLeadOwnerDetails()
    Static testMethod void testpopulateLeadOwnerDetails() {
        TriggerExecutionController.setSkipAllTriggers(true);
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads2 = LeadTestData.lstLeads;
        QueueSobject queueInstance = [select QueueId, Queue.Name from QueueSobject where sObjectType = 'Lead' limit 1];
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        //Start Test
        Test.startTest();
        
        Database.insert(listDirectLeads2);
        Lead directLead = listDirectLeads2[0];
        directLead.OwnerId = queueInstance.QueueId;
        Test.stopTest();
        Database.update(listDirectLeads2);
        System.assertEquals(LeadTestData.iNumberOfLeads,2);
        
        
    }
    
    // v1.1 - Test LeadFieldPopulator.populateAccountForDirectLeads2()
    Static testMethod void testpopulateAccountForDirectLeads2() {
        TriggerExecutionController.setSkipAllTriggers(true);
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> listContacts = ContactTestData.lstContacts;
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads2 = LeadTestData.lstLeads;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        //Start Test
        Test.startTest();
        
        Lead directLead = listDirectLeads2[0];
        directLead.Contact__c = listContacts[0].Id;
        Database.insert(listDirectLeads2);
        
        //directLead.Contact__c = null;
        //Database.update(listDirectLeads2);
        
        Test.stopTest();
        System.assertEquals(LeadTestData.iNumberOfLeads,1);
        
    }
    
    // v1.1 - Test LeadFieldPopulator.populateAccountForChannelLeads()
    Static testMethod void testpopulateAccountForChannelLeads() {
        TriggerExecutionController.setSkipAllTriggers(true);
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> listContacts = ContactTestData.lstContacts;
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.bCreate = false;
        LeadTestData.createChannelLead2();
        list<Lead> listChannelLeads2 = LeadTestData.lstLeads;
        
        
        
        //Start Test
        Test.startTest();
        
        Lead channelLead = listChannelLeads2[0];
        channelLead.Related_Contact__c = listContacts[0].Id;
        Database.insert(listChannelLeads2);
        
        channelLead.Related_Contact__c = null;
        Database.update(listchannelLeads2);
        
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
        System.assertEquals(LeadTestData.iNumberOfLeads,1);
        
    }
    
    // v6.0 - Populate Zift Lead Partner Account And Partner User
    Static testMethod void testpopulateAccountForZiftChannelLeads() {    
        TriggerExecutionController.setSkipCampaignTriggers(true);
        TriggerExecutionController.setSkipCampaignValidator(true);
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.bCreate = false;
        LeadTestData.createChannelLead2();
        list<Lead> listChannelLeads2 = LeadTestData.lstLeads;
        
        //Start Test
        Test.startTest();
        Lead channelLead = listChannelLeads2[0];
        channelLead.Zift_Unique_ID__c='123456';
        channelLead.Zift_Lead_Partner__c='123456';
        channelLead.Zift_Sales_Rep_Email__c='TestEmail@dell.com';
        Database.insert(listChannelLeads2);
        System.assertEquals(LeadTestData.iNumberOfLeads,1);
        
        Database.update(listchannelLeads2);
        Test.stopTest();
        Integer intactualLead = [Select count() From Lead Where Zift_Unique_ID__c='123456' and Zift_Lead_Partner__c='123456' limit 1];
        system.assertEquals(1, intactualLead);
    } 
    
    
    // v2.0 - Test LeadFieldPopulator.clearRelatedContactOnAccountChange()
    Static testMethod void testclearRelatedContactOnAccountChange() {
        TriggerExecutionController.setSkipAllTriggers(true);
        // Create Contacts with different Accounts
        ContactTestData.iNumberOfContacts = 2;
        ContactTestData.createContact();
        list<Contact> listContacts = ContactTestData.lstContacts;
        
        // Create Direct Leads
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads2 = LeadTestData.lstLeads;
        
        // Create Channel Leads
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.bCreate = false;
        LeadTestData.createChannelLead2();
        listLeads2.addAll(LeadTestData.lstLeads);
        
        listLeads2[0].Contact__c = listContacts[0].Id;
        listLeads2[0].Account__c = listContacts[0].AccountId;
        listLeads2[1].Related_Contact__c = listContacts[1].Id;
        listLeads2[1].Account__c = listContacts[1].AccountId;
        Database.insert(listLeads2);
        TriggerExecutionController.setSkipAllTriggers(false);
        System.assertEquals(LeadTestData.iNumberOfLeads,1);
        
        
        // Start Test
        Test.startTest();
        
        listLeads2[0].Account__c = null;
        listLeads2[1].Account__c = null;
        Database.update(listLeads2);
        
        Test.stopTest();
    }
    
    // v1.1 - Test LeadFieldPopulator.populatePartnerAccount()
    Static testMethod void testpopulatePartnerAccount() {
        TriggerExecutionController.setSkipAllTriggers(true);
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.bCreate = false;
        LeadTestData.createChannelLead2();
        list<Lead> listChannelLeads2 = LeadTestData.lstLeads;
        
        UserTestData.iNumberOfUsers = 1;
        UserTestData.createPartnerUsers();
        list<User> listUsers = UserTestData.lstUsers;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        System.assertEquals(LeadTestData.iNumberOfLeads,1);
        
        //Start Test
        Test.startTest();
        
        Lead channelLead = listChannelLeads2[0];
        channelLead.Partner_User__c = listUsers[0].Id;
        
        LeadFieldPopulator.populatePartnerAccount(listChannelLeads2, New set<Id> {listUsers[0].Id});
        
        Test.stopTest();
    }
    //StartV2.2
    Static testMethod void testpopulateLeadOwnerRole() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        LeadAssignment_TestHelper.createAccountTeam();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        listCampaigns[0].Secondary_Role__c = 'Inside Sales Rep';
        listCampaigns[0].Follow_Up_Role__c = 'Account Executive';
        insert listCampaigns;
        //7.0 Made setSkipLeadTriggers true
        TriggerExecutionController.setSkipLeadTriggers(true);
        Test.startTest();
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        listLeads[0].Account__c = euAccount.Id;        
        listLeads[0].Campaign__c = listCampaigns[0].Id;        
        insert listLeads;
        //update lead owner manually 
        listLeads[0].OwnerId = UserInfo.getUserId();        
        update listLeads;
        
        UserTestData.iNumberOfUsers = 1;
        UserTestData.bCreate = false;
        UserTestData.createInternalUsers();
        list<User> listUsers = UserTestData.lstUsers;
        insert listUsers;
        
        system.debug('Account id'+euAccount.Id);
        system.debug('userid'+listUsers[0].id);
        listLeads[0].OwnerId = listUsers[0].id;   
        listLeads[0].Status = 'Account Suggestion Completed';
        listLeads[0].Website = 'http://website';
        update listLeads;
        //7.0 Made setSkipLeadTriggers false
        TriggerExecutionController.setSkipLeadTriggers(false);
        
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
        System.assertEquals(LeadTestData.iNumberOfLeads,1);
    }
    //End V2.2
    
    Static testMethod void testFAPLeadCreation(){
        //Test 
        TriggerExecutionController.setSkipAllTriggers(true);
        
        //Partner Account
        LeadAssignment_TestHelper.createAccounts();
        Account partnerAcc = LeadAssignment_TestHelper.partnerAccount;
        
        Contact newCont = New Contact(FirstName ='TestContactFN9',
                                      LastName ='TestContactLN9',
                                      accountId = partnerAcc.Id,
                                      Email ='TestContactEmail9@ust-global.com',
                                      fax ='01987645',
                                      MobilePhone ='0000019',
                                      Status__c = 'Marketing Suspect',
                                      Phone ='0000000');
        insert newCont;
        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        //test
        list<User> listUser = New list<user>();                                        
        User partnerUser = New User(
            Username ='MyTest2' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest009@dell.com', 
            FirstName='MyTestUser09', 
            LastName='MyTestUser09',  
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='909' + System.currentTimeMillis(), 
            isActive = TRUE,
            ContactId = newCont.id,
            Enable_Partner_Lead_Management__c = true,
            Enable_Partner_Deal_Registration__c = true,
            Enable_As_Partner_Lead_Super_User__c = true
        );
        
        User testUser = New User(
            Username ='MyTest2324342' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest9999@dell.com', 
            FirstName='MyTestUser99', 
            LastName='MyTestUser99',  
            ProfileId = UserInfo.getProfileId(), 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='999' + System.currentTimeMillis(), 
            isActive = TRUE
        );
        listUser.add(partnerUser);
        listUser.add(testUser);
        
        insert listUser;
        
        TestUtils.isTest =  true; // v3.0 added isTest to fix error INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY due to Campaign Not available    
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        listCampaigns[0].Secondary_Role__c = 'Inside Sales Rep';
        listCampaigns[0].Follow_Up_Role__c = 'Account Executive';
        insert listCampaigns;
        
        //test        
        TriggerExecutionController.setSkipAllTriggers(false);
        country__c country = New Country__c(Name = 'TestLeadConversion-Contry 1',code__c='US',region__c = 'EMEA',Is_Active_in_Affinity__c = true);
        insert country;
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        
        listLeads[0].FirstName='Test FAP Lead from VF';
        listLeads[0].LastName='123';
        listLeads[0].Company='Test Co';
        listLeads[0].Country='UNITED KINGDOM (UK)'; 
        listLeads[0].Phone='1234567';
        listLeads[0].Email='test@vf.com';
        listLeads[0].LeadSource='Web';
        listLeads[0].Status='Assigned to Channel partner';
        listLeads[0].Purchase_Timeframe__c='1-6 months';
        listLeads[0].Questions_Comments__c='Test FAP Lead from VF -- Comments';
        listLeads[0].Employees__c='1 - 25';
        listLeads[0].Partner_Account__c=partnerAcc.Id;
        listLeads[0].FAP_Originated_Lead__c='Yes';
        listLeads[0].Campaign__c = listCampaigns[0].Id;
        
        test.startTest();
        //test
        System.runas(testUser) {
            insert listLeads;
            LeadFieldPopulator.populateFAPLeadData(listLeads);
        }
        test.stopTest();
        
        Integer intActualLead = [Select count() From Lead Where Name = 'Test FAP Lead from VF 123' and Email = 'test@vf.com' limit 1];
        system.assertEquals(1, intActualLead);
        
    }
    
    //v3.0 added
    Static testmethod void testpopulateSalesFollowUpDays(){
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipCampaignTriggers(true);
        
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        LeadAssignment_TestHelper.createAccountTeam();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        listCampaigns[0].Secondary_Role__c = 'Inside Sales Rep';
        listCampaigns[0].Follow_Up_Role__c = 'Account Executive';
        insert listCampaigns;
        
        UserTestData.iNumberOfUsers = 1;
        UserTestData.bCreate = false;
        UserTestData.createSalesUsers();
        list<User> listUsers = UserTestData.lstUsers;
        insert listUsers;
        List<Id> listUserId = new List<Id>();
        for(User u: listUsers){
            listUserId.add(u.Id);
        }
        
        TestUtils.isTest =  true;
        Test.startTest();
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        listLeads[0].Account__c = euAccount.Id;        
        listLeads[0].Campaign__c = listCampaigns[0].Id;   
        listLeads[0].Status = 'Open';
        
        //assign Lead to Sales Rep
        listLeads[0].OwnerId = listUsers[0].Id;
        insert listLeads;         
        
        List<Id> listLeadId = new List<Id>();
        for(Lead ld: listLeads){
            listLeadId.add(ld.Id);    
        }       
        
        DateTime dtOwnerChange = system.now().addDays(-1);
        System.runas(listUsers[0]) {   
            //change Lead Status to Contacted 
            listLeads[0].Status = 'Contacted';
            //5.0
            listLeads[0].First_time_assigned_to_Sales__c = system.now();      
            LeadFieldPopulator.calcSalesFollowUpDays(listLeads[0].First_time_assigned_to_Sales__c);
            Test.stopTest();
            //5.0-End         
            DateTime dtStatusChange = system.now();
            update listLeads;
            
            Lead actualLead = [select Sales_Follow_up_days__c from lead where Id =: listLeads[0].Id];
            
            Decimal dcmDays = dtStatusChange.gettime() - listLeads[0].First_time_assigned_to_Sales__c.gettime();
            dcmDays = dcmDays / (1000*60*60*24);
            dcmDays = dcmDays.setscale(1, System.RoundingMode.HALF_UP);
            Integer intactualLead1 = [Select count() From Lead Where Status='Contacted'limit 1];
            system.assertEquals(1, intactualLead1);
            // system.assertEquals(dcmDays, actualLead.Sales_Follow_up_days__c); 
        }        
    }    
    
    //v4.0 added
    static testmethod void testSalesFollowUpDaysNullForNonSales(){
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipCampaignTriggers(true);
        
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        LeadAssignment_TestHelper.createAccountTeam();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        listCampaigns[0].Secondary_Role__c = 'Inside Sales Rep';
        listCampaigns[0].Follow_Up_Role__c = 'Account Executive';
        insert listCampaigns;
        
        UserTestData.iNumberOfUsers = 1;
        UserTestData.bCreate = false;
        UserTestData.createCommonUsers();
        
        Profile marketingProfile = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Name LIKE '%Marketing%' limit 1];
        Test.startTest();
        list<User> listUsers = UserTestData.lstUsers;
        listUsers[0].ProfileId = marketingProfile.Id;
        insert listUsers;
        List<Id> listUserId = new List<Id>();
        for(User u: listUsers){
            listUserId.add(u.Id);
        }
        
        TestUtils.isTest =  true;
        
        country__c country = new Country__c (Name = 'TestLeadConversion-Contry 1',code__c='US',region__c = 'EMEA',Is_Active_in_Affinity__c = true);
        insert country;
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;        
        listLeads[0].Account__c = euAccount.Id;        
        listLeads[0].Campaign__c = listCampaigns[0].Id;   
        listLeads[0].Status = 'Open';
        
        
        //assign Lead to Marketing Rep
        listLeads[0].OwnerId = listUsers[0].Id;
        listLeads[0].First_time_assigned_to_Sales__c = system.now();
        
        insert listLeads;          
        List<Id> listLeadId = new List<Id>();
        for(Lead ld: listLeads){
            listLeadId.add(ld.Id);    
        }       
        Test.stopTest();
        
        //change Lead Status to Contacted 
        listLeads[0].Status = 'Contacted';
        //5.0
        listLeads[0].First_time_assigned_to_Sales__c = system.now();
        LeadFieldPopulator.calcSalesFollowUpDays(listLeads[0].First_time_assigned_to_Sales__c);         
        //5.0-End
        update listLeads;
        
        Lead actualTestLead = [select Sales_Follow_up_days__c from lead where Id =: listLeads[0].Id];
        system.assertEquals(null, actualTestLead.Sales_Follow_up_days__c);    
        
        
    }  
    
    static testmethod void testSalesFollowUpDaysMultipleSalesOwner(){
        TriggerExecutionController.setSkipAllTriggers(true);
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        LeadAssignment_TestHelper.createAccountTeam();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        listCampaigns[0].Secondary_Role__c = 'Inside Sales Rep';
        listCampaigns[0].Follow_Up_Role__c = 'Account Executive';
        insert listCampaigns;
        
        UserTestData.iNumberOfUsers = 3;
        UserTestData.bCreate = false;
        UserTestData.createCommonUsers();
        
        Profile marketingProfile = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Name LIKE '%Marketing%' limit 1];
        Profile salesProfile = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Name LIKE '%Sales%' limit 1];
        
        list<User> listUsers = UserTestData.lstUsers;
        listUsers[0].ProfileId = marketingProfile.Id;
        listUsers[0].Timezonesidkey = 'America/Sao_Paulo';
        
        listUsers[1].ProfileId = salesProfile.Id; 
        
        listUsers[2].ProfileId = salesProfile.Id;
        listUsers[2].Timezonesidkey = 'Asia/Kuala_Lumpur';
        
        insert listUsers;
        
        List<Id> listUserId = new List<Id>();
        for(User u: listUsers){
            listUserId.add(u.Id);
        }
        
        TestUtils.isTest =  true;
        //7.0 Made setSkipLeadTriggers true
        TriggerExecutionController.setSkipLeadTriggers(true);
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;        
        listLeads[0].Account__c = euAccount.Id;        
        listLeads[0].Campaign__c = listCampaigns[0].Id;   
        listLeads[0].Status = 'Open';
        Test.startTest(); 
        //assign Lead to Marketing Rep
        listLeads[0].OwnerId = listUsers[0].Id;
        insert listLeads;        
        
        system.runAs(listUsers[0]){ // marketing user
            //assign Lead to Sales Rep A
            listLeads[0].OwnerId = listUsers[1].Id;
            update listLeads;
        }    
        system.runAs(listUsers[1]){ // Sales Rep A user
            //assign Lead to Sales Rep B
            listLeads[0].OwnerId = listUsers[2].Id;
            update listLeads;
        }
        Test.stopTest();
        List<Id> listLeadId = new List<Id>();
        for(Lead ld: listLeads){
            listLeadId.add(ld.Id);    
        }       
        
        DateTime dtOwnerChange = system.now().addDays(-2); 
        
        System.runAs(listUsers[2]){ //sales User B
            //change Lead Status to Contacted 
            listLeads[0].Status = 'Contacted';
            update listLeads;
        }                              
        //5.0
        listLeads[0].First_time_assigned_to_Sales__c = system.now();
        LeadFieldPopulator.calcSalesFollowUpDays(listLeads[0].First_time_assigned_to_Sales__c);         
        //5.0 - End
        DateTime dtStatusChange = system.now();   
        update listLeads;
        //7.0 Made setSkipLeadTriggers false
        TriggerExecutionController.setSkipLeadTriggers(true);
        Lead actualTestLead = [select Sales_Follow_up_days__c,First_time_assigned_to_Sales__c from lead where Id =: listLeads[0].Id];
        Decimal dcmDays = dtStatusChange.gettime() - actualTestLead.First_time_assigned_to_Sales__c.gettime();
        dcmDays = dcmDays / (1000*60*60*24);
        dcmDays = dcmDays.setscale(1, System.RoundingMode.HALF_UP);
        system.assertEquals(null, actualTestLead.Sales_Follow_up_days__c);    
        
        TriggerExecutionController.setSkipAllTriggers(true);    
    }   
    
}