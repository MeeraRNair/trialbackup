/*
* Author  : Ershad
* Purpose : CPSD trigger to change Flag for CPSD integration status to waiting Sync after ACT Product.
* Objects : Account, Opportunity, OpportunityLineItem.
*/
public class CPSDOpportunityLineItemTriggerHandlerAI implements AfterInsert {
    //OpportunityLineItemTriggerHandler triggerHandler = new OpportunityLineItemTriggerHandler();
    public void handleAfterInsert(List<sObject> listNew){
        // Added by Ershad to update CPSD integration status flag on Account, Opportunity & OpportunityLineItem
        System.debug('***************** CPSD Item AFTER INSERT');
        CPSDUpdateOpportunityLineItemstatusAI.cpsdopportunityFlagUpdate(Trigger.new);
        
        //STORY 7189250 -- Idea Intake 08137 - Deal Identifier or Specialty / BU Products field
        //CPSDOpportunityLineItemUtilities.updateSpecialityBUProductField(Trigger.New);
        SpecialtyBUProducts.rollupsummarySpecialityBUProducts(Trigger.new);
    }
}