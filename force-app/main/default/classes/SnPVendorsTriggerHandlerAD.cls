/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0		17878       FY20-1002		06-Aug-2019		Fenny			Trigger refactoring - new framework. Below method calls copied from legacy SnPVendorsTriggerHandler class
**/

public class SnPVendorsTriggerHandlerAD implements AfterDelete{
     
    public void handleAfterDelete(List<sObject> listOld){
        System.debug('Entered S_P_Vendors__c handleAfterDelete');
        SnPVendorsUtilities.updateRollUpSummaryInOpportunity(Trigger.oldMap, Trigger.newMap);
    }
}