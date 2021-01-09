/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0        17774         FY20-0802       14-Jul-2019     Fenny           Trigger refactoring. Below method calls copied from legacy DistiRelationshipTriggerHandler
 *
 * NOTE: Strictly NO business logics inside this trigger.
 */

public class DistiVisibilityTriggerHandlerBU implements BeforeUpdate {
    
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id,sObject> mapOld){
        System.debug('Entered DistiRelationShipTrigger handleBeforeUpdate');
		
        // Validate Duplicate Disti Accounts
        DistiRelationshipValidator.validateDistiAccount(listNew, (map<Id, Disti_Relationship__c>)mapOld);
        
        // Validate Duplicate Reseller Accounts
        //DistiRelationshipValidator.validateResellerAccount(Trigger.new, (map<Id, Disti_Relationship__c>)Trigger.oldMap);
    }
    
}