/*
 * Author   : Ragu
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on CampaignMember.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      11555       16.07       29-May-2015     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      11922       16.10       07-Sept-2015    Azwanti         Added function to track history on updated CM Status field
 * 2.1      11978       16.10       27-Oct-2015     Shangeetha      Defect 205223, Commented 'CampaignMember2StatusUtils.populateCampaignMember2Status' to skip the logic for “Add to Campaign” scenario.
 * 3.0		13624		0103		17-Oct-2016		Azwanti		    Track CM status creation history changes in Campaign Member 2.0
 * 4.0      17736       FY20-0802   07-Jul-2019     Fenny           Refactor trigger
 */

public class CampaignMemberTriggerHandler extends TriggerHandler {

    public CampaignMemberRecordSelector cmRecordSelector; 
    public override void getRecordSelector() {
        cmRecordSelector = new CampaignMemberRecordSelector(Trigger.new, Trigger.oldMap, this);
    }
    
    /*public override void onBeforeInsert() {
        if(!cmRecordSelector.lstCampaignMembers2.isEmpty()) {
            // Populate CampaignMember fields by copying values from related Lead / Campaign
            CampaignMember2CreationUtils.populateCampaignMemberFields(cmRecordSelector.lstCampaignMembers2, cmRecordSelector.mapCampaigns, cmRecordSelector.mapLeads);
            
            // v2.1: Start
            // Populate CM Status for the newly created Campaign Members
            //CampaignMember2StatusUtils.populateCampaignMember2Status(cmRecordSelector.lstCampaignMembers2, cmRecordSelector.mapLeads);
            // v2.1: End
        }
    }
    
    public override void onBeforeUpdate() {
        
    }
    
    public override void onAfterInsert() {
        //v3.0
        system.debug('wanti in CM insert trigger');
    	CampaignMemberUtils.generateCMFieldHistory(Trigger.newMap); 
    }
    
    public override void onAfterUpdate() {
        // v2.0 - Track history on Status
        // system.debug('wanti in CM onAfterUpdate trigger');
        CampaignMemberUtils.generateCMFieldHistory(Trigger.newMap); 
    }*/

}