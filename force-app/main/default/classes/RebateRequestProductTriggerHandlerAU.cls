/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      
 * 2.0      17934       FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. Below methods calls copied from RebateRequestProductTriggerHandler
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class RebateRequestProductTriggerHandlerAU implements AfterUpdate{
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){

        RebaterequestproducttriggerCls.updatePopualateTotalIntelDiscountRequested (listNew, (Map<id,Rebate_Request_Product__c>) mapOld);
		 
        RebaterequestproducttriggerCls.updateAllianceStatusToExpired (listNew, (Map<id,Rebate_Request_Product__c>) mapOld);
    }
}