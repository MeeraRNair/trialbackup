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
public class PTAttributesTriggerHandlerAU implements AfterUpdate{
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){

        // After successfully updation
        System.debug('On After Update');
        ServicesTriggerRelatedHelper.updateEMCOperationPartnerTypeAttributes((List<Partner_Type_Attribute__c>)listNew);
    }
}