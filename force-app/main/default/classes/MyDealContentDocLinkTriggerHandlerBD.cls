/*
 * Revision CR Number   Release No    Date            Modified By     Description
 * -------- ---------   ----------    -----------     ------------    -----------
 * 2.0      17739       FY20-0802       08-Jul-2019     Fenny           Trigger refactoring. Below methods calls copied from legacy ContentDocLinkTriggerHandler
 * 
 */
public class MyDealContentDocLinkTriggerHandlerBD implements BeforeDelete{
    //ContentDocLinkTriggerHandler triggerHandler = new ContentDocLinkTriggerHandler();
    public void handleBeforeDelete(List<sObject> listOld){
        system.debug('Entered MyDeal ContentDocumentLink handleBeforeDelete');
		//triggerHandler.run();
        MyDealFileIntegration.processContentDocumentLinksDelete(listOld);
    }
    
}