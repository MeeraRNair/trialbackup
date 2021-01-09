/*
 * Author   : Ragu  
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on RMAOpportunity.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR		    FY20-0702       04-Jun-2019     Harry           Created for implementing "Centralized by Org" trigger architecture - Best practices
*/
public class RMAOpportunityTriggerHandlerAU implements AfterUpdate {
    //OpportunityTriggerHandler triggerHandler = new OpportunityTriggerHandler();
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        system.debug('Entered RMAOpportunity handleAfterUpdate');
    //    triggerHandler.run();
        
        //Move assets to alternative opp when closing as a duplicate.
        DellAssetRMAUtilities.moveItemsOnDuplicateOpp(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
    }

}