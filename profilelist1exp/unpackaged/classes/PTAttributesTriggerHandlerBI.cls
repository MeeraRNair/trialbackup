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
public class PTAttributesTriggerHandlerBI implements BeforeInsert{
    
    public void handleBeforeInsert(List<sObject> listNew){

        PTA_Duplicatecheck_HelperCls.ptaDupCheck((List<Partner_Type_Attribute__c>)listNew); 
    }
}