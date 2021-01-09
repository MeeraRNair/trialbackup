/*
 * Author   : Ragu
 * Purpose  : Test class for CampaignUtilities. 
 *
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 12491    16.12           29-Dec-2015     Ragu            LM3_13_4- Fix SOQL error in campaign update
 * 1.0      #213419     16.12           28-Jan-2016     Nagendra        Defect 213419:User cannot edit campaign 2.0: "Too many DML rows" error
 * 2.0      CR 12693    FY17-DCS-0303   02-Mar-2016     Gan             Used batch to process the lead update when changes in campaign field next_step__c or Supporting_Information__c
 * 3.0      CR 16957    FY20-DCE-0202   08-Jan-2018     Kokila          Lead 2.0 - Campaign Status enhancements - "Aborted" status renamed to "Cancelled" 
 * 4.0      CR 16957    FY20-DCS-0202   19 Jan 2019     Shue            DEFECT 6086015: If "Aborted" / "Cancelled" status in Campaign is chosen, all Leads WILL NOT be cancelled
 */
 
@isTest
private class CampaignToLeadUpdaterTest {

   static testMethod void testUpdateLeadRecords() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CampaignTestData.iNumberOfCampaigns = 3;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        list<Lead> listLeads = new list<Lead>();
        
        // To test Next_Steps__c & Supporting_Information__c 
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads2 = LeadTestData.lstLeads;
        for(Lead leadIterator : listDirectLeads2) {
            leadIterator.Campaign__c = listCampaigns[0].Id;
        }
        listLeads.addAll(listDirectLeads2);
        
        // To test aborted Campaigns
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        listDirectLeads2 = LeadTestData.lstLeads;
        for(Lead leadIterator : listDirectLeads2) {
            leadIterator.Campaign__c = listCampaigns[1].Id;
        }
        listLeads.addAll(listDirectLeads2);
        
        // To test activation / deactivation of Campaigns
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        listDirectLeads2 = LeadTestData.lstLeads;
        for(Lead leadIterator : listDirectLeads2) {
            leadIterator.Campaign__c = listCampaigns[2].Id;
            //4.0 - Start
            leadIterator.Status = 'Cancelled - Campaign Inactive';
            //4.0 End
        }
        listLeads.addAll(listDirectLeads2);
        
        insert listLeads;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        Test.startTest();
        
        // Test Next_Steps__c & Supporting_Information__c 
        Campaign campaignInstance = listCampaigns[0];
        campaignInstance.Next_Steps__c = 'This is test Campaign_Next_Steps__c';
        campaignInstance.Supporting_Information__c = 'This is test Campaign_Support_Info__c';
        
        // Test aborted Campaigns
        campaignInstance = listCampaigns[1];
        //v3.0 - Start
        /*campaignInstance.Status = 'Aborted';
        campaignInstance.Proceed_with_cancellation__c = 'Yes';*/
        campaignInstance.Status = 'Cancelled';
        //v3.0 - End
        
        // Test deactivating Campaign
        campaignInstance = listCampaigns[2];
        campaignInstance.ActualCost = 10000;
        campaignInstance.IsActive = false;
        
        update listCampaigns;
        
        // Test activating Campaign
        campaignInstance = listCampaigns[2];
        campaignInstance.IsActive = true;
        update campaignInstance;
        
        Test.stopTest();
        
        System.assertEquals('Cancelled', listCampaigns[1].Status);
        System.assertEquals('New', listLeads[1].Status);
    }
    
    
    static testMethod void testBatchUpdateLeadRecords() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CampaignTestData.iNumberOfCampaigns = 3;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        list<Campaign> listCampaignsClone = new  list<Campaign>();
        listCampaignsClone = CampaignTestData.lstCampaigns.deepclone(true,true,false);
        //Map<Id, Campaign> mapOldCampaigns = new Map<Id, Campaign>(listCampaignsClone);
        list<Lead> listLeads = new list<Lead>();
        
        // To test Next_Steps__c & Supporting_Information__c 
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 5;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads2 = LeadTestData.lstLeads;
        for(Lead leadIterator : listDirectLeads2) {
            leadIterator.Campaign__c = listCampaigns[0].Id;
        }
        listLeads.addAll(listDirectLeads2);
        
        // To test aborted Campaigns
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        listDirectLeads2 = LeadTestData.lstLeads;
        for(Lead leadIterator : listDirectLeads2) {
            leadIterator.Campaign__c = listCampaigns[1].Id;
        }
        listLeads.addAll(listDirectLeads2);
        
        // To test activation / deactivation of Campaigns
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        listDirectLeads2 = LeadTestData.lstLeads;
        for(Lead leadIterator : listDirectLeads2) {
            leadIterator.Campaign__c = listCampaigns[2].Id;
            //4.0 - Start
            leadIterator.Status = 'Cancelled - Campaign Inactive';
            //4.0 End
        }
        listLeads.addAll(listDirectLeads2);
        
        insert listLeads;
        
        
        
        Test.startTest();
        
        // Test Next_Steps__c & Supporting_Information__c 
        Campaign campaignInstance = listCampaigns[0];
        campaignInstance.Next_Steps__c = 'This is test Campaign_Next_Steps__c';
        campaignInstance.Supporting_Information__c = 'This is test Campaign_Support_Info__c';
        
        // Test aborted Campaigns
        campaignInstance = listCampaigns[1];
        //v3.0 - Start
        /*campaignInstance.Status = 'Aborted';
        campaignInstance.Proceed_with_cancellation__c = 'Yes';*/
        campaignInstance.Status = 'Cancelled';
        //v3.0 - End
        
        // Test deactivating Campaign
        campaignInstance = listCampaigns[2];
        campaignInstance.ActualCost = 10000;
        campaignInstance.IsActive = false;
        
        update listCampaigns;
        System.assertEquals('Cancelled', listCampaigns[1].Status);
        System.assertEquals('New', listLeads[1].Status);

        
        Map<Id, Campaign> mapNewCampaigns = new Map<Id, Campaign>(listCampaigns);
        // Test activating Campaign
        campaignInstance = listCampaigns[2];
        campaignInstance.IsActive = true;
        update campaignInstance;
        
        //2.0
        //Batch_CampaignToLeadUpdater BC = new Batch_CampaignToLeadUpdater(mapNewCampaigns,new Map<Id, Campaign>(listCampaignsClone));
        //Database.executeBatch(BC);
        //TriggerExecutionController.setSkipAllTriggers(false); 
        Test.stopTest();
    }

}