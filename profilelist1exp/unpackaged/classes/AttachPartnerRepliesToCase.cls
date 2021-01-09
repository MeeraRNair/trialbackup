global class AttachPartnerRepliesToCase implements Messaging.InboundEmailHandler 
{   
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
    {   
        if(!String.isBlank(email.subject)){
            system.debug('email.subject '+email.subject);
            
            List<Case> caseList = [Select Id, CaseNumber,Referrence_Id__c,Ref_Id__c from Case where Ref_Id__c =: email.subject.substringBetween('[ ',' ]')Limit 1];
            // caseObj  = [Select Id, CaseNumber,Referrence_Id__c,Ref_Id__c from Case where Ref_Id__c =: email.subject.substringBetween('[ ',' ]')];
            
            if(!caseList.isEmpty()){
                EmailMessage emailMessage = new EmailMessage();
                emailMessage.FromAddress = email.fromAddress;
                emailMessage.subject = email.subject;
                emailMessage.ParentId = caseList.get(0).Id;
                emailMessage.TextBody  = email.plainTextBody;
                emailMessage.status = '0';
                emailMessage.FromName = email.FromName;
                emailMessage.Incoming = true;
                
                try{
                    insert emailMessage;
                    if(email.binaryAttachments!= null){
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Attachment attachment = new Attachment();

                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = emailMessage.Id;
                insert attachment;
            }
            }
                    
                    
                }catch(Exception ex){
                    System.debug('Exception On Email Message: '+ ex);
                }               
            }    
        }
        Messaging.InboundEmailresult result = new Messaging.InboundEmailResult();
        return result;
    }
}