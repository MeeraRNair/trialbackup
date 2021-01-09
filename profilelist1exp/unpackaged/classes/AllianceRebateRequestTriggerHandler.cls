/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      
 * 2.0      CR17929     FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. 
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class AllianceRebateRequestTriggerHandler extends TriggerHandler{

    //public override void onBeforeInsert() {}       

    //public override void onBeforeUpdate() {}

    //public override void onBeforeDelete() {}
    public static Boolean runOnce = true;
    
    /*
    public override void onAfterInsert() {
        allianceRebateRequestFieldPopulater.insertingOpportunityTeamrolesIntoRebaterequestTeam(Trigger.new);
       
    }

    public override void onAfterUpdate() {
        allianceRebateRequestFieldPopulater.updatingingOpportunityTeamrolesIntoRebaterequestTeam(Trigger.new,(map<id,Alliance_Rebate_Request__c>)Trigger.oldmap);

        allianceRebateRequestFieldPopulater.reAssignApproversBasedOnRegion((map<id,Alliance_Rebate_Request__c>)Trigger.newmap, (map<id,Alliance_Rebate_Request__c>)Trigger.oldmap);
        
        // Send EMail notification to Opp Sales team when rebate request is Submitted
        allianceRebateRequestFieldPopulater.sendSubmittedNotificationsToOppTeamMembers(Trigger.new, (map<id,Alliance_Rebate_Request__c>)Trigger.oldmap);
         //EmailToCustomField.sendNotificationToRecepient(Trigger.new, (map<id,Alliance_Rebate_Request__c>)Trigger.oldmap);
         
        // Assign Submitted Request to Global leads for Approval
        allianceRebateRequestFieldPopulater.assignSubmittedToGlobalLeads((map<id,Alliance_Rebate_Request__c>)Trigger.newmap, (map<id,Alliance_Rebate_Request__c>)Trigger.oldmap);
        
       // allianceRebateRequestFieldPopulater.sendStatusNotificationsToApprovers(Trigger.new, (map<id,Alliance_Rebate_Request__c>)Trigger.oldmap);
        if(AllianceRebateRequestTriggerHandler.runOnce){
            AllianceRebateRequestTriggerHandler.runOnce = false;
            ApprovalProcess.processint(Trigger.new);
        } 
    }*/

    //public override void onAfterDelete() {}
}