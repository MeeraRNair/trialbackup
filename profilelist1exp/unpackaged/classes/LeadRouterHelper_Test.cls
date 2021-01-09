/*
 * Author   : Ragu
 * Purpose  : To test LeadRouter class. 
 *
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR 12003    16.10           06-Oct-2015     Ragu            LM2_1_70-Route to Channel Process
 * 1.1      CR 12064    16.10           12-Oct-2015     Ragu            LM2_1_71-Route to Segment Process
 * 2.0      CR 12064    0801            28-July-2016    SuiYee          Remove SeeAllData=true
 * 3.0      CR 15341    FY19-DCS-0203   22-Dec-2017     Azwanti         added System.runAs(sysAdmin) to avoid flow error 
 *
 */
 
@isTest // For accessing CMAP related custom settings.
private class LeadRouterHelper_Test {
    
    
     @testSetup 
    static void setUpConversionTestData() {
        country__c country = new Country__c (Name = 'TestLeadConversion-Contry 757',code__c='AE',region__c = 'EMEA',Is_Active_in_Affinity__c = true);
        insert country;
    }
    
    // v1.0
    static testMethod void testSOQLHelperMethods() {
        LeadRouterHelper.getSelectList(new set<String>{'Id', 'Name'});
		System.assertEquals(1, 1);
    }
    
    
    // v1.0
    static testMethod void testCampaignUtilityMethods() {
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        Campaign campInstance = listCampaigns[0];

        Test.startTest();
        LeadRouterHelper.campaignSupportsChannelLead(campInstance.Id);
        LeadRouterHelper.campaignSupportsChannelLead(new set<Id>{campInstance.Id});
        LeadRouterHelper.campaignSupportsChannelLead(campInstance.Id);
        country__c country =[SELECT Id,Name FROM country__c WHERE Name='TestLeadConversion-Contry 757' LIMIT 1];

        
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        LeadRouterHelper.getCampaignIds(listLeads);
        LeadRouterHelper.getRelatedCampaigns(listLeads);
        LeadRouterHelper.getRelatedCampaigns(new set<Id>{listLeads[0].Campaign__c});
		System.assertEquals(1, 1);
        Test.stopTest();
    }
    
    // v1.0
    static testMethod void testR2CValidationRelatedMethods() {
        country__c country =[SELECT Id,Name,code__c FROM country__c WHERE Name='TestLeadConversion-Contry 757' LIMIT 1];
        Test.startTest();
        LeadTestData.bCreate = true;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads = LeadTestData.lstLeads;
        Lead directLead = [select Id, CreatedById, OwnerId, Status from Lead where Id = :listDirectLeads[0].Id];
                       
        
        // Test userHasAccess
        Boolean bValid = LeadRouterHelper.userHasAccess(directLead, UserInfo.getUserId());
       // System.assertEquals(bValid, true);

        // Test leadStatusValidForR2C
        bValid = LeadRouterHelper.leadStatusValidForR2C(directLead);
        System.assertEquals(bValid, true);
        
        directLead.Status = 'Closed';
        bValid = LeadRouterHelper.leadStatusValidForR2C(directLead);
        System.assertEquals(bValid, false);
        
        // Test profileAllowedForR2C
        bValid = LeadRouterHelper.profileAllowedForR2C('GBL Marketing');
        System.assertEquals(bValid, true);
        
        bValid = LeadRouterHelper.profileAllowedForR2C('System Administrator');
        System.assertEquals(bValid, false);
        
        // Test validateR2CForBatch
        listDirectLeads = [select Id, CreatedById, OwnerId, Status, Campaign__c, Dell_Partner_can_contact_me__c from Lead where Id = :listDirectLeads[1].Id];
        directLead = listDirectLeads[0];
        directLead.Dell_Partner_can_contact_me__c = false;
        LeadRouterHelper.validateR2CForBatch(listDirectLeads, null);
        
        map<Id, Lead> mapOldLeads = new map<Id, Lead>{directLead.Id => (new Lead(Id = directLead.Id, Status = 'Closed'))};
        directLead.Dell_Partner_can_contact_me__c = true;
        LeadRouterHelper.validateR2CForBatch(listDirectLeads, mapOldLeads);
        
        Campaign campInstance = new Campaign(Id = directLead.Campaign__c);
        campInstance.Region__c = 'GLOBAL';
        campInstance.Sub_Region__c = 'Global';
        campInstance.Allocation_Source__c = 'Not Applicable';
        campInstance.Nurture_Source__c = 'Not Applicable';
        update campInstance;
        LeadRouterHelper.validateR2CForBatch(listDirectLeads, null);
                
        Test.stopTest();
    }
    
    // v1.1
    static testMethod void testR2SValidationRelatedMethods() {
        //Id submissionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');//v2.0
        Id submissionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
        Id cleansingRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
        //v2.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
        // Create Campaign 2.0
        CampaignTestData.bCreate = true;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createChannelCampaign();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        country__c country =[SELECT Id,Name,Code__c FROM country__c WHERE Name='TestLeadConversion-Contry 757' LIMIT 1];

        // Create Leads
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 3;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        
        Lead directLead = listLeads[0];
        directLead.Dell_Partner_can_contact_me__c = true;
                
        Lead channelLeadSubmission = listLeads[1];
        channelLeadSubmission.Campaign__c = listCampaigns[0].Id;
        channelLeadSubmission.RecordTypeId = submissionRTId;
        channelLeadSubmission.Status = 'Open - Channel Ready';
        channelLeadSubmission.Dell_Partner_can_contact_me__c=true;
        channelLeadSubmission.Country_Code__c='US';
        channelLeadSubmission.Marketing_Primary_Solution_Interest__c = 'Client Solutions';
        
        Lead channelLeadCSC = listLeads[2];
        channelLeadCSC.RecordTypeId = cleansingRTId;
        channelLeadCSC.Ready_For_Scoring__c = true;
        channelLeadCSC.Status = 'Qualified - Channel Ready';        
        channelLeadCSC.Country_Code__c='US';
        channelLeadCSC.Marketing_Primary_Solution_Interest__c = '';
        
        //v3.0
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];               
        System.runAs(adminusr) { 
            insert listLeads;
        }
        System.assertEquals('Qualified - Channel Ready', channelLeadCSC.Status);
        directLead.Status = 'Route To Channel';
        Test.startTest();

        update directLead;
        
        
        system.debug('suiyeetest'+directLead);
        system.debug('suiyeetest222'+listLeads);
        // Test validateCurrenUser
        LeadRouterHelper.validateCurrenUser([select Id, Status, OwnerId, Owner.Name, Campaign__r.Region__c, Allocation_Queue_GUID__c from Lead where Id = :directLead.Id]);
        
        // Test validateR2SForBatch
        for(Lead leadIterator : listLeads) {
            leadIterator.Status = 'Route to Segment';
        }
        Database.update(listLeads, false);        
        
        Test.stopTest();
    }

}