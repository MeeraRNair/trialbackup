/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0        17737       FY20-0802   07-Jul-2019       Fenny          Trigger refactoring. Below methods calls are copied from legacy CaseHistTriggerHandler
 * 
 */ 

public class CaseHistTriggerHandlerAI implements AfterInsert{
	//CaseHistTriggerHandler triggerHandler = new CaseHistTriggerHandler();
    
    public void handleAfterInsert(List<sObject> listNew){
        system.debug('Entered CaseHistory handleAfterInsert');
        //triggerHandler.run();
        CaseSLAUtilities.updtSlaValsInCase(listNew);
    }
    
}