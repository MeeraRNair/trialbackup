/*
 * Revision   CR Number     Release No    Date          Created By      Description
 * --------   -----------   ----------    -----         ------------    -----------
 * 1.0        17773         FY20-0802     14-Jul-2019   Fenny           Trigger refactoring. Method call below copied from legacy EmailMessageTriggerHandler
 *
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class OrderSuppEmailMessageTriggerHandlerAI implements AfterInsert {
    
    public void handleAfterInsert(List<sObject> listNew){
        system.debug('Entered OrderSuppEmailMessage handleAfterInsert');
		
        List<EmailMessage> listMessages = (List<EmailMessage>) listNew;
        
        emailMessageUtilities.updateEmailflag(listMessages); 
    }
    
}