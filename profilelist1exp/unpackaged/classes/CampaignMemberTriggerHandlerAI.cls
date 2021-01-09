/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      17736       FY20-0802   07-Jul-2019     Fenny           Refactor trigger. Below method calls copied from legacy CampaignMemberTriggerHandler
 */

public class CampaignMemberTriggerHandlerAI implements AfterInsert{
    //CampaignMemberTriggerHandler triggerHandler = new CampaignMemberTriggerHandler();
    public void handleAfterInsert(List<sObject>listNew){
        
        system.debug('Entered CampaignMember handleAfterInsert');
		//triggerHandler.run();
    	CampaignMemberUtils.generateCMFieldHistory(Trigger.newMap);
    }
}