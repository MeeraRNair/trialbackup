/*
 * Author   : Jay
 * Purpose  : Gives abstract view of business logics / functionality implemented on Email Message.
 * 
 * Revision     CR Number       Release No       Date            Created By     Description
 * --------             -----------              ----------      -----------         ------------            -----------
 * 1.0                        14603            -----            11th Jul '17         Jay            Created for implementing "Centralized by Org" trigger architecture - Best practices 
 * 2.0        17773         FY20-0802     14-Jul-2019   Fenny           Trigger refactoring
 *                                                                                                                 
 */
public class EmailMessageTriggerHandler extends TriggerHandler{
    /*
    public override void onAfterInsert() {
        
        List<EmailMessage> messages = (List<EmailMessage>) Trigger.new;
        
        emailMessageUtilities.updateEmailflag(messages); 
        
    }

    public override void onAfterUpdate() {
        
        List<EmailMessage> messages1 = (List<EmailMessage>) Trigger.new;
        
        emailMessageUtilities.UncheckNewEmailflag(messages1); 
        
    }*/
}