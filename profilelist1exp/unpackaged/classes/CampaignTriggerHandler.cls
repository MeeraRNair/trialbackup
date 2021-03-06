/*
 * Author   : Ragu
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Campaign.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11480       16.07           15-May-2015     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      11931       16.10           07-Sep-2015     Dipin Raju      Modified to invoke the method to Cancel leads when its Campaign 2.0 is Aborted
 * 2.1      11962       16.10           17-Sep-2015     Dipin Raju      Modified to invoke the method to populate campaign's Next Steps and Support Information to all of its leads
 * 3.0      12491       16.12           23-Dec-2015     Ragu            LM3_13_4- Fix SOQL error in campaign update
 * 4.0      12500       16.12           30-Dec-2015     Niveda          Included validation to avoid direct lead being associated to a campaign with Close Date set in the past
 * 5.0      12693       FY17-DCS-0303   02-Mar-2016     Gan             Used batch to process the lead update when changes in campaign field next_step__c or Supporting_Information__c
 * 6.0      14545       FY18-DCS-0702   14-Jun-2017     Sajith          PCM Insert/Update for Campaign from Vistex with a partner related   
 * 7.0      17546       FY20-0702       24-May-2019     Fenny           CampaignTriggerHandler obsolete
*/

public class CampaignTriggerHandler extends TriggerHandler {

    public CampaignRecordSelector campaignRecordSelector;
    public override void getRecordSelector() {
        campaignRecordSelector = new CampaignRecordSelector(Trigger.new, Trigger.oldMap, this);
    }
    /*
    public override void onBeforeInsert() {
        // Populate Campaign fields on before insert and update
        CampaignFieldPopulator.populateCampaignFieldsOnInsertUpdate(Trigger.new, null, this.trigEvent);
        
        
        // v4.0 - Included validation to avoid direct lead being associated to a campaign with Close Date set in the past
        if(!TriggerExecutionController.skipCampaignValidator()) {
            CampaignValidator.validateLeadCloseDate(Trigger.new);
        }
        
    }
    
    public override void onBeforeUpdate() {
        // Populate Campaign fields on before insert and update
        CampaignFieldPopulator.populateCampaignFieldsOnInsertUpdate(Trigger.new, (map<Id, Campaign>)Trigger.oldMap, this.trigEvent);
        
        
        // v4.0 - Included validation to avoid direct lead being associated to a campaign with Close Date set in the past
        if(!TriggerExecutionController.skipCampaignValidator()) {
            CampaignValidator.validateLeadCloseDate(Trigger.new);
        }
        
    }
    
    public override void onAfterInsert() {
        
        
        // Campaign Field History Tracking - PLEASE KEEP THIS AS LAST LINE INSIDE THIS FUNCTION
        CampaignUtilities.fieldHistoryTrackingHelper(trigger.new, (map<Id, Campaign>)Trigger.oldMap, this.trigEvent);
        //6.0 Start
        system.debug(Logginglevel.INFO,'@@@ PCM Processing initiates  :'); //Sajith
        CampaignUtilities.mapPartnerCampaignManagement(trigger.new);//Sajith
        //6.0 End
    }
    
    public override void onAfterUpdate() {
        
        // v3.0 - Start
        // Update Leads based on the Campaign updates : Commented individual methods for updating related Leads
        // 5.0 new parameters
        if(!campaignRecordSelector.setAbortedCampaignIds.isEmpty() || !campaignRecordSelector.setNSUpdatedCampaignIds.isEmpty() 
                || !campaignRecordSelector.setActivatedCampaignIds.isEmpty() || !campaignRecordSelector.setDeactivatedCampaignIds.isEmpty()) {
            
            CampaignToLeadUpdater.updateLeadRecords(campaignRecordSelector.setAbortedCampaignIds, campaignRecordSelector.setNSUpdatedCampaignIds, campaignRecordSelector.setActivatedCampaignIds, 
                campaignRecordSelector.setDeactivatedCampaignIds, (map<Id, Campaign>)Trigger.newMap);
        }
        
        //CampaignUtilities.AbortedCampaign(trigger.new, (map<Id, Campaign>)Trigger.oldMap, this.trigEvent);
        //CampaignUtilities.populateCampFields(trigger.new, (map<Id, Campaign>)Trigger.oldMap, this.trigEvent);
        //CampaignUtilities.updateLeadStatus(trigger.new, (map<Id, Campaign>)Trigger.oldMap, this.trigEvent);
        
        // v3.0 - End
        //6.0 Start
        system.debug(Logginglevel.INFO,'@@@ PCM Update Processing initiates  :'); //Sajith
        CampaignUtilities.mapPartnerCampaignManagement(trigger.new,(map<Id, Campaign>)Trigger.oldMap);//Sajith
        //6.0 End
        
        // Campaign Field History Tracking - PLEASE KEEP THIS AS LAST LINE INSIDE THIS FUNCTION
        CampaignUtilities.fieldHistoryTrackingHelper(trigger.new, (map<Id, Campaign>)Trigger.oldMap, this.trigEvent);
    }
*/
}