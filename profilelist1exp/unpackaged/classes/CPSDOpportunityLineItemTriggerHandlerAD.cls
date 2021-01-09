/*
* Author  : Ershad
* Purpose : CPSD trigger to change Flag for CPSD integration status to waiting Sync after delete from CPSD OpportunitylineItem.
* Objects : Oppty Products Deleted, OpportunityLineItem
*/
public class CPSDOpportunityLineItemTriggerHandlerAD implements AfterDelete {
//OpportunityLineItemTriggerHandler triggerHandler = new OpportunityLineItemTriggerHandler();
  
public void handleAfterDelete(List<sObject> listOld){
   
 //Added by Ershad to capture CPSD OpportunityLineItem
       system.debug('check for the test class@@@');
        CPSDUpdateOpportunityLineItemstatusAD.backupCPSDOpportunityLineItem(trigger.old);
     // Story no -7620219
        SpecialtyBUProducts.rollupsummarySpecialityBUProducts(trigger.old);
 }
}