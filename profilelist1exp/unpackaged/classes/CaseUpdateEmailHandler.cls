global class CaseUpdateEmailHandler implements Messaging.InboundEmailHandler 
{   
     global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
  {
    String subject = email.subject;
    String body = email.plainTextBody;   
    String FrommailId = email.fromAddress;
    String Approver;
    String caseDelRegistratnRT = StaticFactory.getRecordTypeIdByName('Case', 'EMC DR');
     
    system.debug('**email***' +email);

    //Getting first line of the Email body
    String[] bodyParts = email.plainTextBody.split('From:');
    String Stautsinbody = bodyParts[0];

    //Getting the Deal id and getting case status
    String[] Subjectparts = email.subject.split('Deal ID#|订单号#');
    String numericOutput;
    string[] numericOutputparts = Subjectparts[1].split(';');
    numericOutput = numericOutputparts[0];
    System.debug(numericOutput);

    List<User> usrlist = new List<User>([SELECT Name FROM User WHERE Email =: FrommailId]);
    User usr;
      if(usrlist.size() > 0)
    {
        usr = usrlist[0];
    }
     
    if(usr != null){
    Approver = usr.Name; }
    else{
    Approver = Frommailid;  
    }

    //Getting cases for email resonse
    List<Case> Cslist =([SELECT CaseNumber, Status, OwnerId, Owner.Email FROM Case WHERE Deal_Id__c =: numericOutput and RecordTypeID = :caseDelRegistratnRT ORDER BY CreatedDate desc  limit 1]);
    Case Cs;
      if(Cslist.size() > 0)
    {
        Cs = Cslist[0];
    }
    if(Cs != null)
    {
        if(Cs.status == 'Open')
        {
        if (Stautsinbody.ToUpperCase().Contains('APPROV')){        
            Cs.status = 'Approved & Closed';
            }
         else if(Stautsinbody.ToUpperCase().contains('REJECT')){
            Cs.status = 'Rejected & Closed';
            }
            Cs.Enterprise_Approver_Name__c = Approver;
            Cs.Enterprise_Approve_Rejected_Date__c = system.now();
            
            update Cs;   //updating case 

            //Sending Email to the Sales Rep
        String[] sendTo = new String[]{Cs.Owner.Email};       
        
        String Url = System.URL.getSalesforceBaseURL().toExternalForm() + '/' +Cs.id ;
 
        String newbody = 'Case Number : ' + Cs.CaseNumber;        
        newbody += '  associated to one of your deals has been updated by the Enterprise Sales Rep. \n\n' + Url;
        newbody += '\n\n Please review the deal and take appropriate action.';
        
        List<Messaging.SingleEmailMessage> newemailslist = new List<Messaging.SingleEmailMessage> ();
        Messaging.SingleEmailMessage newemail = new Messaging.SingleEmailMessage ();
        newemail.setPlainTextBody(newbody);
        newemail.setSubject('Case update Notification: Case Number# '+ Cs.CaseNumber);
        newemail.setOrgWideEmailAddressId(Id.valueOf(System.Label.No_Reply_Mailbox));
        newemail.setToAddresses(sendTo); 
        newemailslist.add(newemail);
         try{ 
                Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(newemailslist);
            }
         catch(System.EmailException emlEx) {
                System.debug('Email Failed: ' + emlEx);
            }
       }
       
    //getting the attachment and inserting with caseid
      EmailMessage[] AttachmentEmail = new EmailMessage[0];
      AttachmentEmail.add(new EmailMessage(FromAddress = FrommailId, FromName = Approver,
            Subject = subject, TextBody = Stautsinbody, ParentId = Cs.id, Status = '0')); 
      insert AttachmentEmail; 
      
    }
    Messaging.InboundEmailresult result = new Messaging.InboundEmailResult();
    return result;
  }
}