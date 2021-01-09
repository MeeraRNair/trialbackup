/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      17736       FY20-0802   07-Jul-2019     Fenny           Refactor trigger. Below method calls copied from legacy CampaignMemberTriggerHandler
 */

public class CampaignMemberTriggerHandlerBI implements BeforeInsert{
    CampaignMemberTriggerHandler triggerHandler = new CampaignMemberTriggerHandler();
     
    public void handleBeforeInsert(List<sObject> listNew){
        system.debug('Entered CampaignMember handleBeforeInsert');
        triggerHandler.run();

        if(!triggerHandler.cmRecordSelector.lstCampaignMembers2.isEmpty()) {
            // Populate CampaignMember fields by copying values from related Lead / Campaign
            CampaignMember2CreationUtils.populateCampaignMemberFields(triggerHandler.cmRecordSelector.lstCampaignMembers2, triggerHandler.cmRecordSelector.mapCampaigns, triggerHandler.cmRecordSelector.mapLeads);
            
            // v2.1: Start
            // Populate CM Status for the newly created Campaign Members
            //CampaignMember2StatusUtils.populateCampaignMember2Status(cmRecordSelector.lstCampaignMembers2, cmRecordSelector.mapLeads);
            // v2.1: End
        }
    }
    
}