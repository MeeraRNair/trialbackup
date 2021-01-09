/*
 * Author   :
 * Purpose  : 
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      
 * 2.0      17937       FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. Below method call copied from SPSOTriggerHandler
 *  
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class SPSOTriggerHandlerAU implements AfterUpdate{
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){

        // After successfully updation
   		System.debug('On After Update');
        ServicesTriggerRelatedHelper.updateEMCOperationSPSO((List<Partner_Service_Enabled_Product__c >)listNew);
    }
}