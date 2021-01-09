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
public class PQRelationshipsTriggerHandlerAU implements AfterUpdate {
    
     public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        system.debug('Entered PQRelationshipsTrigger handleafterupdate');
    
        System.debug('On After Update');
        ServicesTriggerRelatedHelper.updateEMCOperationPartnerQuotingRelationships((List<Partner_Quoting_Relationships__c>)listNew);
   }
}