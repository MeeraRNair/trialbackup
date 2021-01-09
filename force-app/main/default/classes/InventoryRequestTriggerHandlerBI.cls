/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0       7501119    FY20101         10/7/2019        Sunil H        Update BOS Email Field in Inventory Request based on account
 * 																		country code/ and ISG record types
**/
public class InventoryRequestTriggerHandlerBI implements BeforeInsert{
    public void handleBeforeInsert(List<sObject> listNew){
    	InventoryRequestHelper.beforeInsert(listNew);
    }
}