/*
* Author   : Ranjith Mergu
* Purpose  : Gives abstract view of all the business logics / functionality implemented on Opportunity related to CPSD Integration.
*          Calls business logics by passing trigger context variables or corresponding results from CPSDOpportunityUtilities class.
* 
*/ 
public class CPSDOpportunityTriggerHandlerBU implements BeforeUpdate{
    //OpportunityTriggerHandler oppTrigHandler = new OpportunityTriggerHandler();
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld) {
        CPSDOpportunityUtilities.updateCPSDIntegrationStatusToWaitingSync(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
    }   
}