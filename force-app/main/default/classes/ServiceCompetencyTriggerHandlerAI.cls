/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0
 * 2.0      17935       FY20-1002   20-Aug-2019     Fenny           Refactoring trigger framework. Below method calls copied from ServiceCompetencyTriggerHandler
 * 
 */ 
public class ServiceCompetencyTriggerHandlerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){

        System.debug('on After Insert');
        ServicesTriggerRelatedHelper.UpdateSCAfterInsert((List<Service_Competencies__c>)listNew);
    }
}