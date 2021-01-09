/*
 * Revision   CR Number   Release No      Date            Modified By     Description
 * --------   ---------   ----------      -----------     ------------    -----------
 * 1.0        CR17722     FY20-0802       4-Jul-2019      Fenny           Trigger refactoring. Below methods calls copied from legacy AttachmentTriggerHandler.cls
*/

public class AttachmentTriggerHandlerAI implements AfterInsert {
    //AttachmentTriggerHandler trighandler = new AttachmentTriggerHandler(); // Not required, but to let test class to cover edited AttachmentTriggerHandler
    public void handleAfterInsert(List<sObject> listNew) {
        system.debug('Entered Attachment handleAfterInsert');
      	//trighandler.run();
        //Deletes the Old Attachments from Territory Plan Object 
       	DeleteOldAttachments.tp_deleteOldAttachment(listNew);
        PopulateCaseFeed.PopulateAttachmentInsertedStausonCase(listNew);
    }
    
}