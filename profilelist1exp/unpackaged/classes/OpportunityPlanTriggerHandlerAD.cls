/*
 * Author   : Fenny
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Account.
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 
 * 2.0      17932       FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. Below method call copied from OpportunityPlanTriggerHandler
*/
public class OpportunityPlanTriggerHandlerAD implements AfterDelete{
     
    public void handleAfterDelete(List<sObject> listOld){
        
        OpportunityPlanUtilities.updateRollUpSummaryInOpportunity(Trigger.oldMap, Trigger.newMap);
    }
}