/*
 * Revision   CR Number     Release No    Date          Created By      Description
 * --------   -----------   ----------    -----         ------------    -----------
 * 1.0        17773         FY20-0802     14-Jul-2019   Fenny           Trigger refactoring. Method call below copied from legacy EmailMessageTriggerHandler
 *
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class OrderSuppEmailMessageTriggerHandlerAU implements AfterUpdate {
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id,sObject> mapOld){
        system.debug('Entered OrderSuppEmailMessage handleAfterUpdate');
		
        List<EmailMessage> listMessages = (List<EmailMessage>) listNew;
        
        emailMessageUtilities.UncheckNewEmailflag(listMessages); 
    }
    
}