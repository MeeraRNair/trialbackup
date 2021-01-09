/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0		17878       FY20-1002		06-Aug-2019		Fenny			Trigger refactoring - new framework. Below method calls copied from legacy SnPVendorsTriggerHandler class
**/

public class SnPVendorsTriggerHandlerBI implements BeforeInsert {
   
    public void handleBeforeInsert(List<sObject> listNew){
        System.debug('Entered S_P_Vendors__c handleBeforeInsert');
        
        SnPVendorsUtilities.updateSendNotification(Trigger.old, listNew);
        SnPVendorsUtilities.beforeInsertUpdate(listNew);
    
    }
}