/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      
 * 2.0      17939       FY20-1002       24-Aug-2019     Fenny           Refactoring trigger framework. Below method calls copied from PQRelationshipsTriggerHandler
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class PQRelationshipsTriggerHandlerBI implements BeforeInsert {
    
     public void handleBeforeInsert(List<sObject> listNew){
        system.debug('Entered PQRelationshipsTrigger handleBeforeInsert');
        
        PQR_Duplicatecheck_HelperCls.pqrDupCheck((List<Partner_Quoting_Relationships__c>)listNew); 
   }
}