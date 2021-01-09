/*
 * Author   : Ragu
 * Purpose  : Test _Member2StatusUtils class
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11555       16.07           02-Jun-2015     Ragu            Added test methods to cover all v1.0 code in CampaignMember2StatusUtils.
 * 2.0      CR 13170    FY17-DCS-0701   27-May-2016     Gan             To update the Campaign Member with lead releavant fields
 * 3.0      14454       FY18-DCS-0802   19-Jul-2017     Azwanti         Separate into smaller test method to avoid hitting SOQL101 error
 */
 
@isTest(SeeAllData=false)
private class CampaignMember2StatusUtils_Test {

    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }
    
    static testMethod void testDirectLeadCMStatusUtils() {
        country__c country = new Country__c (Name = 'TestLeadConversion-Contry 101',code__c='US',region__c = 'EMEA',Is_Active_in_Affinity__c = true);
        insert country;
        // Test Data Preparation - Campaign_Member_Status__c Custom Setting
        list<Campaign_Member_Status__c> lstCMStatus = new list<Campaign_Member_Status__c>();
        
        Campaign_Member_Status__c cmStatus = new Campaign_Member_Status__c();
        cmStatus.Name = 'CM - 010001';
        //cmStatus.CM_Status__c= 'Bad Contact Data';
        cmStatus.Status__c = 'Rejected by Marketing';
        cmStatus.Reason__c = 'Bad Contact Data';
        cmStatus.Identifier__c = 'Direct';
        lstCMStatus.add(cmStatus);
        
        cmStatus = new Campaign_Member_Status__c();
        cmStatus.Name = 'CM - 010002';
        //cmStatus.CM_Status__c = 'Pass by Renewals';
        cmStatus.Status__c = 'Closed by Sales';
        cmStatus.Reason__c = 'Pass by Renewals';
        cmStatus.Identifier__c = 'Direct';
        lstCMStatus.add(cmStatus);
        
        insert lstCMStatus;
        
        // Start Test
        Test.startTest();
        
        // Direct Lead
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> lstDirectLeads = LeadTestData.lstLeads;
        
        lstDirectLeads[0].Status = 'Rejected by Marketing';
        lstDirectLeads[0].Reason__c = 'Bad Contact Data';
        
        lstDirectLeads[1].Status = 'Closed by Sales';
        lstDirectLeads[1].Reason__c = 'Pass by Renewals';
        
        update lstDirectLeads;
        /* Commented by Naga
        list<CampaignMember> lstDirectCampaignMembers = [select Id, CM_Status__c from CampaignMember where LeadId in :new set<Id>{lstDirectLeads[0].Id, lstDirectLeads[1].Id}];
        System.assertEquals(lstDirectCampaignMembers.size(), 2);
        System.assertEquals(lstDirectCampaignMembers[0].CM_Status__c, 'Bad Contact Data');
        System.assertEquals(lstDirectCampaignMembers[1].CM_Status__c, 'Pass by Renewals');
        */
        //2.0
        CampaignMember2StatusUtils.populateCampaignMember2Status(lstDirectLeads[0], true);
        
        Test.stopTest();
    }
    
    static testMethod void testChannelCMStatusUtils() {
        
        country__c country = new Country__c (Name = 'TestLeadConversion-Contry 101',code__c='UK',region__c = 'EMEA',Is_Active_in_Affinity__c = true);
        insert country;
        // Test Data Preparation - Campaign_Member_Status__c Custom Setting
        list<Campaign_Member_Status__c> lstCMStatus = new list<Campaign_Member_Status__c>();
        
        Campaign_Member_Status__c cmStatus = new Campaign_Member_Status__c();
        cmStatus.Name = 'CM - 010001';
        //cmStatus.CM_Status__c= 'Bad Contact Data';
        cmStatus.Status__c = 'Rejected';
        cmStatus.Reason__c = 'Bad Contact Data';
        cmStatus.Identifier__c = 'Direct, Channel';
        lstCMStatus.add(cmStatus);
        
        cmStatus = new Campaign_Member_Status__c();
        cmStatus.Name = 'CM - 010002';
        //cmStatus.CM_Status__c = 'Inaccurate Data';
        cmStatus.Status__c = 'Unqualified';
        cmStatus.Reason__c = 'Inaccurate Data';
        cmStatus.Identifier__c = 'Channel';
        lstCMStatus.add(cmStatus);
        
        insert lstCMStatus;
        
        // Start Test
        Test.startTest();
        
        // Channel Lead
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createChannelLead2();
        list<Lead> lstChannelLeads = LeadTestData.lstLeads;
        
        lstChannelLeads[0].Status = 'Rejected';
        lstChannelLeads[0].Reason__c = 'Bad Contact Data';
        
        lstChannelLeads[1].Status = 'Unqualified';
        lstChannelLeads[1].Reason__c = 'Inaccurate Data';
        
        update lstChannelLeads;
        /* Commented by Naga
        list<CampaignMember> lstChannelCampaignMembers = [select Id, CM_Status__c from CampaignMember where LeadId in :new set<Id>{lstChannelLeads[0].Id, lstChannelLeads[1].Id}];
        System.assertEquals(lstChannelCampaignMembers.size(), 2);
        System.assertEquals(lstChannelCampaignMembers[0].CM_Status__c, 'Bad Contact Data');
        System.assertEquals(lstChannelCampaignMembers[1].CM_Status__c, 'Inaccurate Data');
        */
        Test.stopTest();
    }
    
}