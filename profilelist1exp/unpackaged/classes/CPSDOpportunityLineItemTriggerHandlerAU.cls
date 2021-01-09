/*
* Author  : Ershad
* Purpose : CPSD trigger to change Flag for CPSD integration status to waiting Sync after update in CPSD OpportunitylineItem.
* Objects : Opportunity, OpportunityLineItem.
*/
public class CPSDOpportunityLineItemTriggerHandlerAU implements AfterUpdate {
//OpportunityLineItemTriggerHandler triggerHandler = new OpportunityLineItemTriggerHandler();
public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
//CPSD Integration status flag change in Opportunity and Opportunity Product
       CPSDUpdateOpportunityLineItemstatusAU.cpsdopportunityFlagAfterUpdate(Trigger.new,(map<Id, OpportunityLineItem>)Trigger.oldMap);
        
 }
}