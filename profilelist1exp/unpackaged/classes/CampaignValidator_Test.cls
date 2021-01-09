/*
 * Author   : Niveda
 * Purpose  : Test class for CampaignValidator. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 12500    16.12       30-Dec-2015     Niveda          Created.
 */
 
@isTest
private class CampaignValidator_Test {
     
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }
    
    static testMethod void test_validateLeadCloseDate() {
        // Start: Test data preparation
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.bCreate = false;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Close_Date_for_Leads__c = System.today()-1;
        Database.insert(lstCampaigns, false);
        lstCampaigns[0].Close_Date_for_Leads__c = System.today();
        Database.insert(lstCampaigns, false);
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<lead> lstLeads = LeadTestData.lstLeads;
        lstLeads[0].Campaign__c=lstCampaigns[0].id;
        Database.update(lstLeads, false);
   }
        
}