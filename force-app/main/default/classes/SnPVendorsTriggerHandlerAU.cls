/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0		17878       FY20-1002		06-Aug-2019		Fenny			Trigger refactoring - new framework. Below method calls copied from legacy SnPVendorsTriggerHandler class
**/

public class SnPVendorsTriggerHandlerAU implements AfterUpdate{
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        System.debug('Entered S_P_Vendors__c handleAfterUpdate');

        //v2.0 - start
        SnPVendorsUtilities.updateLeadOnServicesOfOppProduct (listNew);
         /*  consolidted triggers logic start  */
        SnPVendorsUtilities.validationCheck(listNew);
        // END
        //v2.0 - end
    }
}