public class VerifyEmailMessage_Ctrl {
    Boolean hasUnreadEmail;
    Id currentEmailId;
    string parent_id;
    List<EmailMessage> emailsRelated;
    
    public VerifyEmailMessage_Ctrl(ApexPages.StandardController ctrl){
        hasUnreadEmail = false;
        emailsRelated = new List<EmailMessage>();
        currentEmailId = ApexPages.currentPage().getParameters().get('id');
         System.debug('newEmail '+currentEmailId);
       
        parent_id = [select parentid from EmailMessage where id=:currentEmailId].parentid;
        
        List<EmailMEssage> caseEmails = [Select Id, status, ParentId from EmailMessage Where ParentId =:parent_id];
        
        System.debug('Total emails of the Case :'+caseEmails.size());
        
        Integer newEmailCount = 0;
            
        for(EmailMessage em : caseEmails){
            if(em.Status == '0'){
                newEmailCount++;
                System.debug('New Emails count :'+newEmailCount);
            }        
        }
        //system.assert(false,newEmailCount);
        if( newEmailCount > 0){
            hasUnreadEmail = true;
        }
    }
 
    public void updateNewEmailField(){
        
        if( ! hasUnreadEmail ){
            System.debug('Has unread email :'+hasUnreadEmail);
            List<Case> dbCase = [Select Id,New_Email_Flag__c from Case Where Id =:parent_id];
            if( dbCase.size() > 0){
                dbCase[0].New_Email_Flag__c = false;
                update dbCase[0];
            }
        }
    }
}