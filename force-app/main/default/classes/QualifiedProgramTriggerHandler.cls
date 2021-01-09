/*
 * Author   : Sneha
 * Purpose  : Handler Class for Qualified Programs which handles all the event related methods.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR# 4161253 0203        12-Dec-2017     Sneha           Created for implementing trigger architecture - Best practices
 * 
 */



public class QualifiedProgramTriggerHandler {
   
    // After Events
    public static void handleAfterInsert(List<Qualified_Program__c> lst_newRecords){
      QualifiedProgramTriggerHelper.UpdateOpportunityLineItemWithNBIRelatedInfo(lst_newRecords,'Insert');
    }
    
    public static void handleAfterDelete(List<Qualified_Program__c> lst_newRecords){
      QualifiedProgramTriggerHelper.UpdateOpportunityLineItemWithNBIRelatedInfo(lst_newRecords,'Delete');
    }

}