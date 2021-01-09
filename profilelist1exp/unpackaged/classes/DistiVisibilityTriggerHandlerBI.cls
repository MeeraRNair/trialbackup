/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0        17774         FY20-0802       14-Jul-2019     Fenny           Trigger refactoring. Below method calls copied from legacy DistiRelationshipTriggerHandler
 *
 * NOTE: Strictly NO business logics inside this trigger.
 */

public class DistiVisibilityTriggerHandlerBI implements BeforeInsert{
    
    public void handleBeforeInsert(List<sObject> listNew){
        System.debug('Entered DistiRelationShipTrigger handle Before Insert');
		
        // Validate Duplicate Disti Accounts
        DistiRelationshipValidator.validateDistiAccount(listNew, null);
        
        //Story 3271954:Deal Reg: Distribution Strategy: Auto Populate Storage Preferred Distributor from Partner Request
        // Auto populate Storage Preferred Distributor when reseller account is selected 
        DistiRelationshipValidator.AutoPopulateDistiAccount(listNew);
        // Validate Duplicate Reseller Accounts
        //DistiRelationshipValidator.validateResellerAccount(Trigger.new, null); 
    }
    
}