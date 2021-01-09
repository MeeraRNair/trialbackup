/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0        17737       FY20-0802   07-Jul-2019       Fenny          Trigger refactoring. Below methods calls are copied from legacy CaseHistTriggerHandler
 * 
 */ 

public class CaseHistTriggerHandlerAU implements AfterUpdate {
    //CaseHistTriggerHandler triggerHandler = new CaseHistTriggerHandler();
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        system.debug('Entered CaseHistory handleAfterUpdate');
        //triggerHandler.run();
        CaseSLAUtilities.updateAggrValToCase(listNew, (map<Id, Case_Status_History__c>)mapOld);
    }
    
}