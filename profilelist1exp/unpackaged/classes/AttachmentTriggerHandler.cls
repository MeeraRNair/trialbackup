/*
 * Author   : Nagaraju
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Attachment.
 *          Calls business logics by passing trigger context variables or corresponding results from TP_DeleteOldAttachments class.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 *1.0       15065                       30-October-2017 Nagaraju
 *2.0       CR17722     FY20-0802       4-Jul-2019      Fenny           Trigger refactoring
*/    
 
public class AttachmentTriggerHandler extends TriggerHandler {
     /*public override void onAfterInsert() {
     //Deletes the Old Attachments from Territory Plan Object 
     DeleteOldAttachments.tp_deleteOldAttachment(Trigger.new);
         PopulateCaseFeed.PopulateAttachmentInsertedStausonCase(Trigger.new);
 
     }*/
}