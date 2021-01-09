/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      
 * 2.0      CR17929     FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. Below method calls copied from AllianceRebateRequestTriggerHandler
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class AllianceRebateRequestTriggerHandlerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){
        allianceRebateRequestFieldPopulater.insertingOpportunityTeamrolesIntoRebaterequestTeam(listNew);
    }
}