/*
 * Author   : Ragu
 * Purpose  : Test Lead2ConsoleSidebarController class
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11611       16.07           12-Jun-2015     Ragu            Added test methods to cover all v1.0 code in Lead2ConsoleSidebarController.
 * 2.0      12634       FY17-DCS-0303   24-Feb-2016     Azwanti         Added system.assert to verify Lead is listed
 * 3.0      13031       FY17-DCS-0502   12-Apr-2016     Gan         
 * 4.0      13103       FY17-DCS-0602   27-Apr-2016     Azwanti         LM2_21-Adding account product maps views to Sales Console third panel        
 * 5.0      13389       FY17-DCS-0902   08-Aug-2016     Gan             LM2_New product map for Channel Greenfield
 * 6.0      13387       FY17-DCS-0902   09-Aug-2016     SuiYee          LM2_New product map for Storage Capacity % and removed (SeeAllData=false) 
 * 7.0      13406       FY17-DCS-1002   09-Aug-2016     Sajith          LM2_New product map for Market Intelligence  
 * 8.0      13731       FY17-DCS-0103   23-Nov-2016     Azwanti         LM2_Channel Greenfield product map fix
 * 9.0      13850       FY18-DCS-0202   23-Dec-2016     Sajith          LM2_New product map for eRate
 * 9.1      13854       FY18-DCS-0202   23-Dec-2016     SuiYee          LM2_Add Ship date field into Expiring tags product map
 * 10.0     14061       FY18-DCS-0403   14-Mar-2017     Ashok           LM2_New product map for open Quotes
 * 11.0     14061       FY18-DCS-0602   19-May-2017     Sajith          LM2_New product map for Marketing Maintenance
 * 12.0     14735       FY18-DCS-1001   08-Aug-2017     Ashok           Enhance Lead Opportunity Product Map

*/
 
@isTest
private class Lead2ConsoleSidebarController_Test {
    
    static testMethod void testLead2ConsoleSidebarController() {
        //5.0 hitting 101 error
        TriggerExecutionController.setSkipAllTriggers(true);
        //Create contact data
        ContactTestData.iNumberOfContacts = 2;
        ContactTestData.bCreate = true;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        System.assertEquals(lstContacts.size(), 2);
        
        //Create lead data
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        System.assertEquals(lstLeads.size(), 2);
        
        //3.0 create oppty for the account 
        /*Opportunity testOppty = new Opportunity(Name='Test Oppty', 
                                                AccountId=lstContacts[0].AccountId, 
                                                StageName='1%',
                                                Contract_Term__c=5,
                                                CloseDate = System.Today() + 10,
                                                RecordTypeId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity')); 
        TriggerExecutionController.setSkipAllTriggers(true);                                        
        insert testOppty;
        TriggerExecutionController.setSkipAllTriggers(false);
        */
        
        // 6.0
        // create partner Account
        Id idPartnerAccRT= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account objPartnerAcc = new Account(name='Test', RecordtypeId = idPartnerAccRT, Type = 'Partner');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert objPartnerAcc;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        // Create campaign data
        Id CampRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        Campaign CMAP_seg_camp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',
                RecordTypeId = CampRTId,//v3.0                       
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = FALSE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',
                Lead_Routing__c = 'Not Applicable'); // v8.0
        TriggerExecutionController.setSkipAllTriggers(true);
        insert  CMAP_seg_camp;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Id ChleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSetting_eclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSetting_eclerx;
        //Ch Lead
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Qualified - Channel Ready';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = ChleadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = CMAP_seg_camp.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.User_Access_OLD__c = 'Read';
                chleadRecs.OwnerId ='00GA0000002y6s0MAA'; 
        TriggerExecutionController.setSkipAllTriggers(true);
        insert chleadRecs;
        TriggerExecutionController.setSkipAllTriggers(false);
        
               
        for(Lead leadIterator : lstLeads) {
            leadIterator.Account__c = lstContacts[0].AccountId;
        }
        TriggerExecutionController.setSkipAllTriggers(true);
        insert lstLeads;     
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.startTest();
        Lead2ConsoleSidebarController controller = new Lead2ConsoleSidebarController(new ApexPages.StandardController(lstLeads[0]));
        controller.getContactDetails();
        controller.getLeadDetails();
        //3.0
        controller.getOpptyDetails();
        Test.stopTest();
        
    }
    
    //v8.0
    static testMethod void productMapTest(){
        //5.0 hitting 101 error
        TriggerExecutionController.setSkipAllTriggers(true);
        //Create contact data
        ContactTestData.iNumberOfContacts = 2;
        ContactTestData.bCreate = true;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        System.assertEquals(lstContacts.size(), 2);
        
        //Create lead data
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        System.assertEquals(lstLeads.size(), 2);
        
        //4.0
        Expiring_Tag__c testExpTag = new Expiring_Tag__c(Account__c = lstContacts[0].AccountId);
        insert testExpTag;
        
        eQuote__c testeQuote = new eQuote__c(Account__c = lstContacts[0].AccountId);
        insert testeQuote;
        
        Enterprise_Installed_Base__c testEntInstBase = new Enterprise_Installed_Base__c(Account__c = lstContacts[0].AccountId);
        insert testEntInstBase;
        
        Renewal_Software_Hardware__c testReSwHw = new Renewal_Software_Hardware__c(Account__c = lstContacts[0].AccountId);
        insert testReSwHw;
        
        Order_Info__c testOrderInfo = new Order_Info__c(Account__c = lstContacts[0].AccountId);
        insert testOrderInfo;
        
        Non_SFDC_Contacts__c testNonSfdcContact = new Non_SFDC_Contacts__c(Account_ID__c = lstContacts[0].AccountId);
        insert testNonSfdcContact;
        
        Premier_Pages__c testPremierPages = new Premier_Pages__c(Account__c = lstContacts[0].AccountId);
        insert testPremierPages;
        
        Generic_Product_Map__c testGeneric = new Generic_Product_Map__c(Account__c = lstContacts[0].AccountId);
        insert testGeneric;
        
        //Lead_Opportunity__c testLeadOpp = new Lead_Opportunity__c(Account__c = lstContacts[0].AccountId, CurrencyIsoCode = 'Taiwan Dollar');
        //insert testLeadOpp;
        //end 4.0
        
        // 6.0
        // create partner Account
        Id idPartnerAccRT= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account objPartnerAcc = new Account(name='Test', RecordtypeId = idPartnerAccRT, Type = 'Partner');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert objPartnerAcc;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        // Create campaign data
        Id CampRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        Campaign CMAP_seg_camp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',
                RecordTypeId = CampRTId,//v3.0                       
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = FALSE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',
                Lead_Routing__c = 'Not Applicable'); // v8.0
        TriggerExecutionController.setSkipAllTriggers(true);
        insert  CMAP_seg_camp;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Id ChleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSetting_eclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSetting_eclerx;
        
        Storage_Capacity__c objStorageCapacity = new Storage_Capacity__c(Account_ID__c = lstContacts[0].AccountId, Campaign__c = CMAP_seg_camp.id);
        insert objStorageCapacity;
        
        for(Lead leadIterator : lstLeads) {
            leadIterator.Account__c = lstContacts[0].AccountId;
        }
        TriggerExecutionController.setSkipAllTriggers(true);
        insert lstLeads;
        TriggerExecutionController.setSkipAllTriggers(false);
               
        //7.0               
        Market_Intelligence__c testMarketIntelligence = new Market_Intelligence__c(Account_ID__c = lstContacts[0].AccountId, Campaign_Name__c = CMAP_seg_camp.id);
        insert testMarketIntelligence;
        //7.0
        
        //9.0               
        eRate__c testeRate = new eRate__c(Account__c = lstContacts[0].AccountId);
        insert testeRate;
        //9.0
        
        //10.0
        Open_Quotes__c testoQUotes = new Open_Quotes__c(Account__c = lstContacts[0].AccountId);
        insert testoQUotes;
        //10.0
        
        //11.0 //12.0
        Lead_Opportunity__c testmktMain = new Lead_Opportunity__c(Account__c = lstContacts[0].AccountId);
        insert testmktMain;
        //11.0 //12.0
     

        
        // 5.0
        // v8.0 replace Channel_Lead__c with Lead__c
        Channel_Greenfield__c objChannelGreenfield = new Channel_Greenfield__C(End_user_account__c = lstContacts[0].AccountId, Lead__c = lstLeads[0].id, Partner_Account__c = objPartnerAcc.id);
        insert objChannelGreenfield;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.startTest();
        Lead2ConsoleSidebarController controller = new Lead2ConsoleSidebarController(new ApexPages.StandardController(lstLeads[0]));
        controller.getContactDetails();
        controller.getLeadDetails();
        
        //4.0
        controller.getExpiringTagDetails();
        controller.geteQuoteDetails();
        controller.getEntInstalledBaseDetails();
        controller.getRenewalSwHwDetails();
        controller.getOrderInfoDetails();
        //end 4.0
        
        //5.0
        controller.getChannelGreenfieldDetails();
        
        //6.0
        controller.getStorageCapacityDetails();
        //7.0
        controller.getMarketIntelligenceDetails();  
        //9.0
        controller.geteRateDetails();  
        //10.0
        controller.getopenQuoteDetails();
        
        //controller.getLeadOpportunityDetails();
        
        controller.getGenericProductMapDetails();
        
        controller.getNonSFDCContactsDetails();
        
        controller.getPremierPagesDetails();
        Test.stopTest();

        //v2.0
        Integer actualTestLead = [Select count() From Lead where Id in :lstLeads];
        system.assert(actualTestLead > 0);
        //v2.0
        
        //4.0
        Integer actualExpTag = [Select count() From Expiring_Tag__c where Id = :testExpTag.Id];
        system.assert(actualExpTag > 0);
        
        Integer actualeQuote = [Select count() From eQuote__c where Id = :testeQuote.Id];
        system.assert(actualeQuote > 0);
        
        Integer actualEntInstBase = [Select count() From Enterprise_Installed_Base__c where Id = :testEntInstBase.Id];
        system.assert(actualEntInstBase > 0);
        
        Integer actualReSwHw = [Select count() From Renewal_Software_Hardware__c where Id = :testReSwHw.Id];
        system.assert(actualReSwHw > 0);
        
        Integer actualOrderInfo = [Select count() From Order_Info__c where Id = :testOrderInfo.Id];
        system.assert(actualOrderInfo > 0);
        //end 4.0
        
        
        
    }
}