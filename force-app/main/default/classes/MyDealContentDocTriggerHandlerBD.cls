/*
 * Revision CR Number   Release No    Date            Modified By     Description
 * -------- ---------   ----------    -----------     ------------    -----------
 * 2.0      17739       FY20-0802       08-Jul-2019     Fenny           Trigger refactoring. Below methods calls copied from legacy ContentDocumentTriggerHandler
 * 
 */
public class MyDealContentDocTriggerHandlerBD implements BeforeDelete {
    //ContentDocumentTriggerHandler triggerHandler = new ContentDocumentTriggerHandler();
    public void handleBeforeDelete(List<sObject> listOld){
        system.debug('Entered MyDeal ContentDocumentTrigger handleBeforeDelete');
        //triggerHandler.run();
        MyDealFileIntegration.processContentDocument(listOld);
    }
    
}