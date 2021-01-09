/* Author   : Mounika
 *
 * Purpose  : This is to update the EMC Operation field. 
 *            
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0
 * 2.0      17935       FY20-1002       20-Aug-2019     Fenny           Refactoring trigger framework
 * 
 */ 


public class ServiceCompetencyTriggerHandler extends TriggerHandler {
    /*
    public override void onAfterUpdate() {
    // After successfully updation
    System.debug('On After Update');
        ServicesTriggerRelatedHelper.updateEMCOperationServiceCompetencies((List<Service_Competencies__c>)trigger.new);
       // ServicesTriggerRelatedHelper.UpdateSCAfterUpdate((List<Service_Competencies__c>)trigger.new,(Map<id,Service_Competencies__c>)trigger.oldMap);
        ServicesTriggerRelatedHelper.UpdateSCAfterUpdate((List<Service_Competencies__c>)trigger.new);
    }
    
    public override void onAfterInsert(){
    //After successful Insertion
    System.debug('on After Insert');
     ServicesTriggerRelatedHelper.UpdateSCAfterInsert((List<Service_Competencies__c>)trigger.new);
    }
    
    public override void onAfterDelete(){
        System.debug('on After Delete');
        ServicesTriggerRelatedHelper.UpdateSCAfterDelete((List<Service_Competencies__c>)trigger.old);
    }*/
}