/*
 * Author   : Ragu
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Case.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 10751    16.03       30-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR 12450    16.12       10-Dec-2015     Ragu            LM2_16_1- Sharing new cases with requestor before changing case owner
 * 3.0      CR XXXX                 18-Nov-2018     Akshita         Changes as part of case RT lift-n-shift 
 * 4.0      CR 17547    FY20-0702   24-May-2019     Fenny           CaseTriggerHandler obsolete. Above histories and below methods calls are copied from CaseTriggerHandler
 * 5.0      CR 17605    FY20 0702   04-Jun-2019     Kokila          Case submitter is added to the case team automatically when he/she create case via web to case form and is a SFDC user
 * 6.0		18304		FY20-0102	27-Nov-2019		Fenny			To make CaseRecordSelector accessible by all features
 */ 
public class CaseTriggerHandlerAU implements AfterUpdate{
    
     public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        System.debug('Entered Case handleAfterUpdate');
        
        CaseShareUtilities.shareWithCaseCreator(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase);

        DealReg_NotifyEMCSalesRep.sendEmailToEMCSalesRepOnUpdate(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase);
        
        if(!Test.isRunningTest()){
            Case_AccountTeamNotifications.SendNotifications(CaseTriggerHandler.casRecordSelector.listDellMainNewCase,'AfterUpdate',(map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase);
        }
        
        CaseTeamUtilities.addWebToCaseRequestorToCaseTeam(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase, 'AfterUpdate'); //v5.0
        
        CaseTeamUtilities.addAccountTeamMembersToCase(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase, 'AfterUpdate');
        
        CaseTeamUtilities.addRecipientUsersToCaseTeam(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase);
        
        if(!Test.isRunningTest()){
            CaseTeamUtilities.removeCaseCreatorAccessAfterOwnerChange(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase);
        }
        
        CaseSLAUtilities.updateCaseHistory(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase);
        CaseSLAUtilities.deleteCaseHistory(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase); 
       
        CaseFieldPopulator.replytoPartnersWhenCaseisCompleted(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase);
        
        //commented to include changes as part of 3.0v
        /*
        // Share the Case with Creator if Ownership is getting changed from them
        CaseShareUtilities.shareWithCaseCreator(Trigger.new, (map<Id, Case>)Trigger.oldMap);

        DealReg_NotifyEMCSalesRep.sendEmailToEMCSalesRepOnUpdate(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        
        if(!Test.isRunningTest()){
        //This method to send notifications to account team members code added by Naresh Bijjam on 24th Aug 2017.
            Case_AccountTeamNotifications.SendNotifications(Trigger.new,'AfterUpdate',(map<Id, Case>)Trigger.oldMap);  // New method paramenter  added by Uday Dt. 27-02-18 Story Story 4687556: (Item 3)
      
        }
        
        //for unauthanticated web form
       CaseTeamUtilities.addAccountTeamMembersToCase(Trigger.new, (map<Id, Case>)Trigger.oldMap, 'AfterUpdate');
        
        
        // Adding Additional Recipient Users to Case Team for Order support and Deal registration.  
        CaseTeamUtilities.addRecipientUsersToCaseTeam(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        
        // Remove Access to Case creators when ownership changes  
        CaseTeamUtilities.removeCaseCreatorAccessAfterOwnerChange(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        
        CaseSLAUtilities.updateCaseHistory(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        CaseSLAUtilities.deleteCaseHistory(Trigger.new, (map<Id, Case>)Trigger.oldMap); 
        //Case Order Support Chatter Notifications
       // CaseChatterNotifications.followCase(Trigger.new, (map<Id, Case>)Trigger.oldMap, false);
       
        CaseFieldPopulator.replytoPartnersWhenCaseisCompleted(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        */
    }

}