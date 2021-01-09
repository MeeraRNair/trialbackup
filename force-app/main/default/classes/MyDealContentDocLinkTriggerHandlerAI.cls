/*
 * Revision CR Number   Release No    Date            Modified By     Description
 * -------- ---------   ----------    -----------     ------------    -----------
 * 2.0      17739       FY20-0802       08-Jul-2019     Fenny           Trigger refactoring. Below methods calls copied from legacy ContentDocLinkTriggerHandler
 * 
 */
public class MyDealContentDocLinkTriggerHandlerAI implements AfterInsert{
    //ContentDocLinkTriggerHandler triggerHandler = new ContentDocLinkTriggerHandler();
    public void handleAfterInsert(List<sObject> listNew){
        system.debug('Entered MyDeal ContentDocumentLink handleAfterInsert');
      	//triggerHandler.run();
        MyDealFileIntegration.processContentDocumentLinksInsert(listNew);
    }
    
}