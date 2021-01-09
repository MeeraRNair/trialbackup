/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      
 * 2.0      17933       FY20-1002       28-Aug-2019     Fenny           Refactoring trigger framework. Below method calls copied from OpptyTeamTriggerHandler
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class OpptyTeamTriggerHandlerAD implements AfterDelete{
     
    public void handleAfterDelete(List<sObject> listOld){
        // Copy Opportunity Team Member to OTM History for reporting
        OpptyTeamMemberHistory.insertOpptyTeamMemberHistory(listOld, 'Remove');
    }
}