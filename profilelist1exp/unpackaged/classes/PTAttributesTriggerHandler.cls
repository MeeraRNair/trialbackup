/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      
 * 2.0      17940       FY20-1002       23-Aug-2019     Fenny           Refactoring trigger framework. Below methods calls copied from PTAttributesTriggerHandler
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class PTAttributesTriggerHandler extends TriggerHandler {
    
    
    public static Boolean bisFirstTime = true;
    /*
    public override void onAfterUpdate() {
    // After successfully updation
    System.debug('On After Update');
        ServicesTriggerRelatedHelper.updateEMCOperationPartnerTypeAttributes((List<Partner_Type_Attribute__c>)trigger.new);
  
    }
    
    public override void onBeforeUpdate() {
        PTA_Duplicatecheck_HelperCls.ptaDupCheck(trigger.new,(map<Id, Partner_Type_Attribute__c>)Trigger.oldMap); 
    }
    
    public override void onBeforeInsert() {
     PTA_Duplicatecheck_HelperCls.ptaDupCheck((List<Partner_Type_Attribute__c>)trigger.new); 
    }*/
}