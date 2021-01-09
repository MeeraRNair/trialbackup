/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      
 * 2.0      CR17929     FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. Below method calls copied from AllianceRebateRequestTriggerHandler
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class AllianceRebateRequestTriggerHandlerAU implements AfterUpdate{
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){

        allianceRebateRequestFieldPopulater.updatingingOpportunityTeamrolesIntoRebaterequestTeam(listNew,(map<id,Alliance_Rebate_Request__c>)mapOld);

        allianceRebateRequestFieldPopulater.reAssignApproversBasedOnRegion((map<id,Alliance_Rebate_Request__c>)Trigger.newmap, (map<id,Alliance_Rebate_Request__c>)mapOld);
        
        // Send EMail notification to Opp Sales team when rebate request is Submitted
        allianceRebateRequestFieldPopulater.sendSubmittedNotificationsToOppTeamMembers(listNew, (map<id,Alliance_Rebate_Request__c>)mapOld);
         //EmailToCustomField.sendNotificationToRecepient(Trigger.new, (map<id,Alliance_Rebate_Request__c>)Trigger.oldmap);
         
        // Assign Submitted Request to Global leads for Approval
        allianceRebateRequestFieldPopulater.assignSubmittedToGlobalLeads((map<id,Alliance_Rebate_Request__c>)Trigger.newmap, (map<id,Alliance_Rebate_Request__c>)mapOld);
        
       // allianceRebateRequestFieldPopulater.sendStatusNotificationsToApprovers(Trigger.new, (map<id,Alliance_Rebate_Request__c>)Trigger.oldmap);
        if(AllianceRebateRequestTriggerHandler.runOnce){
            AllianceRebateRequestTriggerHandler.runOnce = false;
            ApprovalProcess.processint(listNew);
        } 
    }
}