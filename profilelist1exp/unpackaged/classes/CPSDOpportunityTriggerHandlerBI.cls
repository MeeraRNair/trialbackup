/*
* Author   : Ranjith Mergu
* Purpose  : Gives abstract view of all the business logics / functionality implemented on Opportunity related to CPSD Integration.
*          Calls business logics by passing trigger context variables or corresponding results from CPSDOpportunityUtilities class.
* 
*/ 
public class CPSDOpportunityTriggerHandlerBI implements BeforeInsert{
    //OpportunityTriggerHandler oppTrigHandler = new OpportunityTriggerHandler();
    public void handleBeforeInsert(List<sObject> listNew) {
        CPSDOpportunityUtilities.cloneOppsWithoutProducts(Trigger.new);
    }
}