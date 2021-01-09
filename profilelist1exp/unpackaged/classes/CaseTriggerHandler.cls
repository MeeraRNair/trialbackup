/*
 * Author   : Ragu
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Case.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 10751    16.03       30-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR 12450    16.12       10-Dec-2015     Ragu            LM2_16_1- Sharing new cases with requestor before changing case owner
 * 3.0      CR XXXX                 18-Nov-2018     Akshita         Changes as part of case RT lift-n-shift 
 * 4.0      CR 17547    FY20-0702   24-May-2019     Fenny           CaseTriggerHandler obsolete
 * 5.0		18304		FY20-0102	27-Nov-2019		Fenny			To make CaseRecordSelector accessible by all features
 */ 

public class CaseTriggerHandler extends TriggerHandler { 
    public static CaseRecordSelector casRecordSelector;
    //public List<Case> newCaseList; // 3.0
    //public Map<Id, sObject> newCaseMap; // 3.0
    //public Map<Id, sObject> newCaseMapNew; // 3.0
    
    public CaseTriggerHandler(){
        
		// 5.0 Move this logic to CaseRecordSelector constructor
        //String CaseRTMigrate_strRTIds = CaseManagement.CaseRTMigrate_getRTIDs();
        //newCaseList = CaseUtilities.CaseRTMigrateCheckRTList(Trigger.new, CaseRTMigrate_strRTIds); // 3.0
        //newCaseMap = CaseUtilities.CaseRTMigrateCheckRTMap(Trigger.oldMap, CaseRTMigrate_strRTIds);  // 3.0
        //newCaseMapNew = CaseUtilities.CaseRTMigrateCheckRTMap(Trigger.newMap, CaseRTMigrate_strRTIds);  // 3.0
    }
    
    public override void getRecordSelector() { 
        //casRecordSelector = new CaseRecordSelector(newCaseList, (map<Id, Case>)newCaseMap, this); // 3.0 // 5.0 Commented
        casRecordSelector = new CaseRecordSelector(Trigger.new, Trigger.oldMap, this); // 3.0 // 5.0 Uncomment
    }
    
/*
    public override void onBeforeInsert() {
        
        CaseManagement.validateAndPopulateFields(newCaseList, null, casRecordSelector.mapRelatedAccounts);
        CaseFieldPopulator.populateFieldsOnBeforeInsert(newCaseList);
        
        //commented to include changes as part of 3.0v
        
        // Validate associated Account, mandate Alternate_Phone__c and populate Region__c
        //CaseManagement.validateAndPopulateFields(Trigger.new, null, casRecordSelector.mapRelatedAccounts);
        
        // Populate Queue_Name__c, Account and Account Tier details based on Affinity Id
        //CaseFieldPopulator.populateFieldsOnBeforeInsert(Trigger.new);
        
    }
    
    public override void onBeforeUpdate() {
        
        if(!Test.isRunningTest()){
        CaseManagement.validateAndPopulateFields(newCaseList, (map<Id, Case>)newCaseMap, casRecordSelector.mapRelatedAccounts);
         }
         CaseUtilities.assignPartnerInquiryCases((map<Id, Case>)newCaseMapNew, casRecordSelector.mapRelatedAccounts);
         
        
        //commented to include changes as part of 3.0v
        
        // Validate associated Account, mandate Alternate_Phone__c and populate Region__c 
        //CaseManagement.validateAndPopulateFields(Trigger.new, (map<Id, Case>)Trigger.oldMap, casRecordSelector.mapRelatedAccounts);
        
        // Partner Inquiry Case Owner Assignment
        //CaseUtilities.assignPartnerInquiryCases((map<Id, Case>)Trigger.newMap, casRecordSelector.mapRelatedAccounts);
        
    }
    
    public override void onAfterInsert() {
        
        CaseUtilities.reassignNonNPSCases((map<Id, Case>)newCaseMapNew);

        NPSCaseUtilities.createTaskForNPSCases(newCaseList);
        
        CaseTeamUtilities.addAccountTeamMembersToCase(newCaseList,(map<Id, Case>)newCaseMap, 'AfterInsert');
        
        NPSCaseUtilities.copyAccountTeamToCase(newCaseList);
        
        if(!casRecordSelector.lstGLMICases.isEmpty()) {
            CaseTeamUtilities.addCaseRequestorToCaseTeam(casRecordSelector.lstGLMICases);
        }
        Case_AccountTeamNotifications.SendNotifications(newCaseList,'AfterInsert',null); 
        
       // IMPORTANT: Do not add any method calls below this line, add all your statements above this line.
        // Populate Owner Id for the NPS Cases - KEEP THIS AS THE LAST STATEMENT IN onAfterInsert() AS THIS HAS SELF UPDATE
        NPSCaseUtilities.populateOwnerIdForNPSCases(newCaseList);        
        CaseSLAUtilities.insertFrstRecInCaseHist(newCaseList); 
        
        
        //commented to include changes as part of 3.0v
       
        // Trigger the assignment rule for non NPS Cases
        //CaseUtilities.reassignNonNPSCases((map<Id, Case>)Trigger.newMap);

        // Create Task for NPS Cases based on NSS Category
        //NPSCaseUtilities.createTaskForNPSCases(Trigger.new);
        
        // Adding AccountTeamMembers to Case Team for Order support and Deal registration.
        //CaseTeamUtilities.addAccountTeamMembersToCase(Trigger.new,(map<Id, Case>)Trigger.oldMap, 'AfterInsert');
        
        // Copy Account Team Members from Account to its Cases
        //NPSCaseUtilities.copyAccountTeamToCase(Trigger.new);
        
        // v2.0 - Start
        //if(!casRecordSelector.lstGLMICases.isEmpty()) {
            // To add the Case Creator to the Case Team with the role Case Requestor
           // CaseTeamUtilities.addCaseRequestorToCaseTeam(casRecordSelector.lstGLMICases);
        //}
        // v2.0 - End
        
        // Case Order Support Partner Admin Access
     //   CaseTeamUtilities.addPartnerAdminsToCaseTeam(Trigger.new);
        
        //Case Order Support Chatter Notifications
      //  CaseChatterNotifications.followCase(Trigger.new, (map<Id, Case>)Trigger.oldMap, true);
      
        //This method to send notifications to account team members code added by Naresh Bijjam on 24th Aug 2017.
        //Case_AccountTeamNotifications.SendNotifications(Trigger.new,'AfterInsert',null); // New method paramenter  added by Uday Dt. 27-02-18 Story Story 4687556: (Item 3)
     
       
       // IMPORTANT: Do not add any method calls below this line, add all your statements above this line.
        // Populate Owner Id for the NPS Cases - KEEP THIS AS THE LAST STATEMENT IN onAfterInsert() AS THIS HAS SELF UPDATE
        //NPSCaseUtilities.populateOwnerIdForNPSCases(Trigger.new);        
        //CaseSLAUtilities.insertFrstRecInCaseHist(Trigger.new); 
       
    }
    
    public override void onAfterUpdate() {
        CaseShareUtilities.shareWithCaseCreator(newCaseList, (map<Id, Case>)newCaseMap);

        DealReg_NotifyEMCSalesRep.sendEmailToEMCSalesRepOnUpdate(newCaseList, (map<Id, Case>)newCaseMap);
        
        if(!Test.isRunningTest()){
            Case_AccountTeamNotifications.SendNotifications(newCaseList,'AfterUpdate',(map<Id, Case>)newCaseMap);
        }
        
        CaseTeamUtilities.addAccountTeamMembersToCase(newCaseList, (map<Id, Case>)newCaseMap, 'AfterUpdate');
        
        CaseTeamUtilities.addRecipientUsersToCaseTeam(newCaseList, (map<Id, Case>)newCaseMap);
        
        if(!Test.isRunningTest()){
        CaseTeamUtilities.removeCaseCreatorAccessAfterOwnerChange(newCaseList, (map<Id, Case>)newCaseMap);
        }
        
        CaseSLAUtilities.updateCaseHistory(newCaseList, (map<Id, Case>)newCaseMap);
        CaseSLAUtilities.deleteCaseHistory(newCaseList, (map<Id, Case>)newCaseMap); 
       
        CaseFieldPopulator.replytoPartnersWhenCaseisCompleted(newCaseList, (map<Id, Case>)newCaseMap);
        
        //commented to include changes as part of 3.0v
        
        // Share the Case with Creator if Ownership is getting changed from them
        //CaseShareUtilities.shareWithCaseCreator(Trigger.new, (map<Id, Case>)Trigger.oldMap);

        //DealReg_NotifyEMCSalesRep.sendEmailToEMCSalesRepOnUpdate(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        
        //if(!Test.isRunningTest()){
        //This method to send notifications to account team members code added by Naresh Bijjam on 24th Aug 2017.
        //    Case_AccountTeamNotifications.SendNotifications(Trigger.new,'AfterUpdate',(map<Id, Case>)Trigger.oldMap);  // New method paramenter  added by Uday Dt. 27-02-18 Story Story 4687556: (Item 3)
      
        //}
        
        //for unauthanticated web form
       //CaseTeamUtilities.addAccountTeamMembersToCase(Trigger.new, (map<Id, Case>)Trigger.oldMap, 'AfterUpdate');
        
        
        // Adding Additional Recipient Users to Case Team for Order support and Deal registration.  
        //CaseTeamUtilities.addRecipientUsersToCaseTeam(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        
        // Remove Access to Case creators when ownership changes  
        //CaseTeamUtilities.removeCaseCreatorAccessAfterOwnerChange(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        
        //CaseSLAUtilities.updateCaseHistory(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        //CaseSLAUtilities.deleteCaseHistory(Trigger.new, (map<Id, Case>)Trigger.oldMap); 
        //Case Order Support Chatter Notifications
       // CaseChatterNotifications.followCase(Trigger.new, (map<Id, Case>)Trigger.oldMap, false);
       
        //CaseFieldPopulator.replytoPartnersWhenCaseisCompleted(Trigger.new, (map<Id, Case>)Trigger.oldMap);
        
    }
*/
}