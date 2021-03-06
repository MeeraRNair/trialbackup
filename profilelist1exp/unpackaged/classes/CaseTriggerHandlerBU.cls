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
 * 5.0		18304		FY20-0102	27-Nov-2019		Fenny			To make CaseRecordSelector accessible by all features
 */ 
public class CaseTriggerHandlerBU implements BeforeUpdate{
    
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        System.debug('Entered Case handleBeforeUpdate');
        
        if(!Test.isRunningTest()){
            CaseManagement.validateAndPopulateFields(CaseTriggerHandler.casRecordSelector.listDellMainNewCase, (map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainOldCase, CaseTriggerHandler.casRecordSelector.mapRelatedAccounts);
         }
         CaseUtilities.assignPartnerInquiryCases((map<Id, Case>)CaseTriggerHandler.casRecordSelector.mapDellMainNewCase, CaseTriggerHandler.casRecordSelector.mapRelatedAccounts);
         
        
        //commented to include changes as part of 3.0v
        /*
        // Validate associated Account, mandate Alternate_Phone__c and populate Region__c 
        CaseManagement.validateAndPopulateFields(Trigger.new, (map<Id, Case>)Trigger.oldMap, casRecordSelector.mapRelatedAccounts);
        
        // Partner Inquiry Case Owner Assignment
        CaseUtilities.assignPartnerInquiryCases((map<Id, Case>)Trigger.newMap, casRecordSelector.mapRelatedAccounts);
        */
    }

}