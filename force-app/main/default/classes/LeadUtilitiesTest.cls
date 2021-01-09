/* 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 10747    16.03           25-Feb-2015     Ragu            Created test method for LeadUtilities.updateLeadStatusForPartnerMLURs()
 * 2.0      CR 13068    FY17-DCS-0602   04-May-2016     Gan             Set the seeAllData to false in the Test class, random catch
 */
 
@isTest(SeeAllData=false)
private class LeadUtilitiesTest {
    
    //2.0
     @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    
        Country__c cntry = new Country__c(Name ='UNITED KINGDOM', Code__c='GB', CurrencyIsoCode='USD', FAP_Country_Value__c='UNITED KINGDOM (UK)', Region__c ='EMEA', Enable_for_FAP__c = true);
        Database.insert(cntry);   
    }
    
    static testMethod void test_updateLeadStatusForPartnerMLURs() {
        // Skip all the triggers to avoid Too Many SOQL Query issue
        TriggerExecutionController.setSkipAllTriggers(true);
        
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getAccount(true);
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getCampaign(true);
        CMAP_Helper.skipInsert = true;
        System.debug('XXXX:+tesst');
        
        Mass_Upload_Lead_Request__c mulrObj = new Mass_Upload_Lead_Request__c(Campaign__c = testData.campObj.Id,
            Partner_User__c = testData.partnerUser.Id,
            Partner_Email_ID__c = testData.partnerUser.Email,
            Partner_Account__c = testData.accountObj.Id,
            Status__c = 'New');
        insert mulrObj;
        
        // Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Id leadRTId = StaticFactory.getRecordTypeIdByName('Lead','Channel Lead - Cleansing & Scoring Complete');
        
        // Start Testing
        Test.startTest();
        
        list<Lead> lstLeads = new list<Lead>();
        Lead leadObj = new Lead(LastName = 'Test Lead 1',
            Email = 'testcmap@cmaptest.com',
            Status = 'Open - Channel Lead',
            Phone = '88967544',
            RecordTypeId = leadRTId,
            Country = 'US',
            Partner_Account__c = testdata.accountObj.Id,
            Campaign__c  = testdata.campObj.Id,
            Company = 'Test Company',
            Partner_User__c = testdata.PartnerUser.Id,
            Ready_For_Scoring__c = false,
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)',
            Are_you_a_Dell_Partner__c = 'Yes',
            Mass_Lead_Upload_Request_ID__c = mulrObj.Id);
        lstLeads.add(leadObj);
        
        Lead leadObjAlt = new Lead(LastName = 'Test Lead 2',
            Email = 'testcmap@cmaptest.com',
            Status = 'Open - Channel Lead',
            Phone = '88967544',
            RecordTypeId = leadRTId,
            Country = 'US',
            Partner_Account__c = testdata.accountObj.Id,
            Campaign__c  = testdata.campObj.Id,
            Company = 'Test Company',
            Partner_Admin__c = userinfo.getuserID(),//testdata.PartnerUser.Id,
            Ready_For_Scoring__c = false,
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)',
            Are_you_a_Dell_Partner__c = 'Yes',
            Mass_Lead_Upload_Request_ID__c = mulrObj.Id);
        lstLeads.add(leadObjAlt);
        
        try{
              insert lstLeads;
                    System.debug('Shue lstLeads----'+lstLeads);
        }catch(Exception ex){
            system.debug('$$$$$$$ This insertion failed '+ex.getMessage());
        }
        
        map<id,Lead> Mapoldleads = new map<id,Lead>();
      
        
        for(Lead newLead: [select id,Ready_For_Scoring__c from Lead where id in :lstLeads]){
        Mapoldleads.put(newLead.id,newLead);
        }
        
        for(Lead newLead1:lstLeads){
              newLead1.Ready_For_Scoring__c=true;
                     
        }
        update lstLeads;
             
        system.debug('$$$$ lstleads'+lstleads);
        LeadUtilities.updateLeadStatusForPartnerMLURs(lstLeads,Mapoldleads);
        
               
        Test.stopTest();
        // End Testing
    }
    
    static testMethod void test_rollupLeadsAndContactsForCampaign() {
        LeadTestData.iNumberOfLeads = 5;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();
        list<Lead> lstDirectLeads2 = LeadTestData.lstLeads;
        
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        
        Test.startTest();
        
        Database.insert(lstDirectLeads2);
        
        lstDirectLeads2[4].Campaign__c = lstCampaigns[0].Id;
        Database.update(lstDirectLeads2);
        
        Database.delete(lstDirectLeads2[4]);
        
        Test.stopTest();
    }
     //StartV2.2
 /*static testMethod void test_populateLeadOwnerRole() {
 
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipCampaignTriggers(true);
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        LeadAssignment_TestHelper.createAccountTeam();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Secondary_Role__c = 'Inside Sales Rep';
        lstCampaigns[0].Follow_Up_Role__c = 'Account Executive';
        insert lstCampaigns;
        
        Test.startTest();
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        lstLeads[0].Account__c = euAccount.Id;        
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;        
        insert lstLeads;
        //update lead owner manually 
        lstLeads[0].OwnerId = UserInfo.getUserId();        
        update lstLeads;
        
        UserTestData.iNumberOfUsers = 1;
        UserTestData.bCreate = false;
        UserTestData.createInternalUsers();
        list<User> lstUsers = UserTestData.lstUsers;
       // insert lstUsers;
     
        system.debug('Account id'+euAccount.Id);
        system.debug('userid'+lstUsers[0].id);
        lstLeads[0].OwnerId = lstUsers[0].id;   
        lstLeads[0].Status = 'Account Suggestion Completed';
        lstLeads[0].Website = 'http://website';
     //   update lstLeads;
        
        
    
        Test.stopTest();
    } */
    
    
  
}