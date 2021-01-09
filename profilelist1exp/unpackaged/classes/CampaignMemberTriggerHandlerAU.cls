/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      17736       FY20-0802   07-Jul-2019     Fenny           Refactor trigger. Below method calls copied from legacy CampaignMemberTriggerHandler
 */

public class CampaignMemberTriggerHandlerAU implements AfterUpdate {
    //CampaignMemberTriggerHandler triggerHandler = new CampaignMemberTriggerHandler();
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
         // v2.0 - Track history on Status
        system.debug('Entered CampaignMember handleAfterUpdate');
        //triggerHandler.run();
        CampaignMemberUtils.generateCMFieldHistory(Trigger.newMap); 
    }
}