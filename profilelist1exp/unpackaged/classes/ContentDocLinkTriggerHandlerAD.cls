/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0                  FY20-1101   12-Sept-2019     Hari A        Trigger refactoring. Below methods calls are copied from legacy class
 * 
 */ 

public class ContentDocLinkTriggerHandlerAD implements AfterDelete{
    
    public void handleAfterDelete(List<sObject> listOld){
        ContentDocLinkUtilities.updateFilesAD(listOld);
    }
    
}