/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0
 * 2.0      17935       FY20-1002   20-Aug-2019     Fenny           Refactoring trigger framework. Below method calls copied from ServiceCompetencyTriggerHandler
 * 
 */ 
public class ServiceCompetencyTriggerHandlerAU implements AfterUpdate{
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){

        System.debug('On After Update');
        ServicesTriggerRelatedHelper.updateEMCOperationServiceCompetencies((List<Service_Competencies__c>)listNew);
       // ServicesTriggerRelatedHelper.UpdateSCAfterUpdate((List<Service_Competencies__c>)trigger.new,(Map<id,Service_Competencies__c>)trigger.oldMap);
        ServicesTriggerRelatedHelper.UpdateSCAfterUpdate((List<Service_Competencies__c>)listNew);
    }
}