/*
 * Revision  CR Number   Release No      Date            Modified By     Description
*  1.0       7501119     FY20101         10/7/2019       Sunil H         Update BOS Email Field in Inventory Request based on account
* 																	     country code/ and ISG record types
*/
public class InventoryRequestTriggerHandlerBU implements BeforeUpdate{
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld) {
        InventoryRequestHelper.beforeUpdateBosEmail(Trigger.new, (map<Id, Dell_Sales_FIM__Inventory_Request__c>)Trigger.oldMap);
    }
}