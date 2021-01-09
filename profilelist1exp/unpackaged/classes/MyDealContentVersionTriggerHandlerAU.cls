/*
 * Revision CR Number   Release No    Date            Modified By     Description
 * -------- ---------   ----------    -----------     ------------    -----------
 * 2.0      17739       FY20-0802       08-Jul-2019     Fenny           Trigger refactoring. Below methods calls copied from legacy ContentVersionTriggerHandler
 * 
 */
public class MyDealContentVersionTriggerHandlerAU implements AfterUpdate{
    //ContentVersionTriggerHandler triggerHandler = new ContentVersionTriggerHandler();
    public void handleAfterUpdate(List<sObject> listNew,Map<Id, sObject> mapOld){
        system.debug('Entered MyDeal ContentVersionTrigger handleAfterUpdate');
		//triggerHandler.run();
        MyDealFileIntegration.processContentVersions(listNew,(map<Id, ContentVersion>)mapOld);
    }
    
}