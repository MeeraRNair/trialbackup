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
public class CaseTriggerHandlerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){
        System.debug('Entered Case handleAfterInsert');
        
        CaseUtilities.reassignNonNPSCases((map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainNewCase);

        NPSCaseUtilities.createTaskForNPSCases(CaseTriggerHandler.casRecordSelector.listDellMainNewCase);
        
        CaseTeamUtilities.addAccountTeamMembersToCase(CaseTriggerHandler.casRecordSelector.listDellMainNewCase,(map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase, 'AfterInsert');
        
        NPSCaseUtilities.copyAccountTeamToCase(CaseTriggerHandler.casRecordSelector.listDellMainNewCase);
        
        if(!CaseTriggerHandler.casRecordSelector.lstGLMICases.isEmpty()) {
            CaseTeamUtilities.addCaseRequestorToCaseTeam(CaseTriggerHandler.casRecordSelector.lstGLMICases);
            CaseTeamUtilities.addWebToCaseRequestorToCaseTeam(CaseTriggerHandler.casRecordSelector.lstGLMICases, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase, 'AfterInsert'); //v5.0
        }
        Case_AccountTeamNotifications.SendNotifications(CaseTriggerHandler.casRecordSelector.listDellMainNewCase,'AfterInsert',null); 
        
       // IMPORTANT: Do not add any method calls below this line, add all your statements above this line.
        // Populate Owner Id for the NPS Cases - KEEP THIS AS THE LAST STATEMENT IN onAfterInsert() AS THIS HAS SELF UPDATE
        NPSCaseUtilities.populateOwnerIdForNPSCases(CaseTriggerHandler.casRecordSelector.listDellMainNewCase);        
        // CaseSLAUtilities.insertFrstRecInCaseHist(caseTrigHandler.newCaseList); 
        
        /*
        //commented to include changes as part of 3.0v
       
        // Trigger the assignment rule for non NPS Cases
        CaseUtilities.reassignNonNPSCases((map<Id, Case>)Trigger.newMap);

        // Create Task for NPS Cases based on NSS Category
        NPSCaseUtilities.createTaskForNPSCases(Trigger.new);
        
        // Adding AccountTeamMembers to Case Team for Order support and Deal registration.
        CaseTeamUtilities.addAccountTeamMembersToCase(Trigger.new,(map<Id, Case>)Trigger.oldMap, 'AfterInsert');
        
        // Copy Account Team Members from Account to its Cases
        NPSCaseUtilities.copyAccountTeamToCase(Trigger.new);
        
        // v2.0 - Start
        if(!casRecordSelector.lstGLMICases.isEmpty()) {
            // To add the Case Creator to the Case Team with the role Case Requestor
            CaseTeamUtilities.addCaseRequestorToCaseTeam(casRecordSelector.lstGLMICases);
        }
        // v2.0 - End
        
        // Case Order Support Partner Admin Access
     //   CaseTeamUtilities.addPartnerAdminsToCaseTeam(Trigger.new);
        
        //Case Order Support Chatter Notifications
      //  CaseChatterNotifications.followCase(Trigger.new, (map<Id, Case>)Trigger.oldMap, true);
      
        //This method to send notifications to account team members code added by Naresh Bijjam on 24th Aug 2017.
        Case_AccountTeamNotifications.SendNotifications(Trigger.new,'AfterInsert',null); // New method paramenter  added by Uday Dt. 27-02-18 Story Story 4687556: (Item 3)
     
       
       // IMPORTANT: Do not add any method calls below this line, add all your statements above this line.
        // Populate Owner Id for the NPS Cases - KEEP THIS AS THE LAST STATEMENT IN onAfterInsert() AS THIS HAS SELF UPDATE
        NPSCaseUtilities.populateOwnerIdForNPSCases(Trigger.new);        
        CaseSLAUtilities.insertFrstRecInCaseHist(Trigger.new); 
       */
    }

}