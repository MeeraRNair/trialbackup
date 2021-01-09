/*
 * Author   : Ragu
 * Purpose  : Test CampaignMember2CreationUtils class
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      11555       16.07       02-Jun-2015     Ragu            Added test methods to cover all v1.0 code in CampaignMember2CreationUtils.
 *
 */
 
@isTest(SeeAllData=false)
private class CampaignMember2CreationUtils_Test {

    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }
    
    static testMethod void testCampaignMember2CreationUtils() {
        // Test Data Preparation - Campaign_Member_Field_Mapping__c Custom Setting
        list<Campaign_Member_Field_Mapping__c> lstCMFieldMappings = new list<Campaign_Member_Field_Mapping__c>();
        
        Campaign_Member_Field_Mapping__c cmFieldMapping = new Campaign_Member_Field_Mapping__c();
        cmFieldMapping.Name = 'Status';
        cmFieldMapping.Source_Field__c = 'Lead.Status';
        lstCMFieldMappings.add(cmFieldMapping);
        
        cmFieldMapping = new Campaign_Member_Field_Mapping__c();
        cmFieldMapping.Name = 'Campaign_Vehicle__c';
        cmFieldMapping.Source_Field__c = 'Campaign.Type';
        lstCMFieldMappings.add(cmFieldMapping);
        
        cmFieldMapping = new Campaign_Member_Field_Mapping__c();
        cmFieldMapping.Name = 'CM_Status__c';
        cmFieldMapping.Source_Field__c = '"Sent"';
        lstCMFieldMappings.add(cmFieldMapping);
        
        insert lstCMFieldMappings;
        
        // Start Test
        Test.startTest();
        
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        System.assertEquals(lstLeads.size(), 2);
        
        LeadTestData.createChannelLead2();
        lstLeads.addAll(LeadTestData.lstLeads);
        
        insert lstLeads;
        
        list<CampaignMember> lstCampaignMembers = [select Id, LeadId, CM_Status__c from CampaignMember where LeadId in :new set<Id>{lstLeads[0].Id, lstLeads[1].Id}];
        System.assertEquals(lstCampaignMembers.size(), 2);
        
        map<Id,Lead> mapRelatedLeads = new Map<Id,Lead>([Select id,Questions_Comments__c,Marketing_Comments__c,Sales_Comments__c from Lead where Id in :new set<Id>{lstLeads[0].Id, lstLeads[1].Id}]);
        
        CampaignMember2CreationUtils.populateCampaignMemberLeadFields(lstCampaignMembers,mapRelatedLeads);
        
        Test.stopTest();
    }
    
}