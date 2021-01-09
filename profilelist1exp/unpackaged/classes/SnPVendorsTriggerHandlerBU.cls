/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0		17878       FY20-1002		06-Aug-2019		Fenny			Trigger refactoring - new framework. Below method calls copied from legacy SnPVendorsTriggerHandler class
**/

public class SnPVendorsTriggerHandlerBU implements BeforeUpdate{
     
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        System.debug('Entered S_P_Vendors__c handleBeforeUpdate');

        SnPVendorsUtilities.resetExtendRegistrationFlag(listNew);
        /*  consolidted triggers logic start  */
        SnPVendorsUtilities.updateSendNotification(Trigger.old, listNew);
        SnPVendorsUtilities.checkValidation(listNew);
        SnPVendorsUtilities.beforeInsertUpdate(listNew);
        }
}