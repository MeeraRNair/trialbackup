/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      
 * 2.0      17939       FY20-1002       24-Aug-2019     Fenny           Refactoring trigger framework
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class PQRelationshipsTriggerHandler extends TriggerHandler {
    public static Boolean bisFirstTime = true;
    //public static Boolean isFirstTime = true;
    /*
    public override void onAfterUpdate() {
    // After successfully updation
    System.debug('On After Update');
        ServicesTriggerRelatedHelper.updateEMCOperationPartnerQuotingRelationships((List<Partner_Quoting_Relationships__c>)trigger.new);
  
    }
    
    //public override void onBeforeUpdate() {
    //    PQR_Duplicatecheck_HelperCls.ptaDupCheck(trigger.new,(map<Id, Partner_Quoting_Relationships__c>)Trigger.oldMap); 
    //}
    
    public override void onBeforeInsert() {
        PQR_Duplicatecheck_HelperCls.pqrDupCheck((List<Partner_Quoting_Relationships__c>)trigger.new); 
    }
*/

}