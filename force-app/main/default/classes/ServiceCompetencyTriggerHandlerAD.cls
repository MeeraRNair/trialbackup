/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0
 * 2.0      17935       FY20-1002   20-Aug-2019     Fenny           Refactoring trigger framework. Below method calls copied from ServiceCompetencyTriggerHandler
 * 
 */ 
public class ServiceCompetencyTriggerHandlerAD implements AfterDelete{
     
    public void handleAfterDelete(List<sObject> listOld){
        System.debug('on After Delete');
        ServicesTriggerRelatedHelper.UpdateSCAfterDelete((List<Service_Competencies__c>)listOld);
    }
}