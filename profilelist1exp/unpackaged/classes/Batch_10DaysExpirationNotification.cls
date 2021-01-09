global class Batch_10DaysExpirationNotification implements Database.Batchable < sObject > {

public string strOrgAddress;

 Map < String, DealReg_DealExpiryTemplates__c > ALLDealExpiryTemplates = DealReg_DealExpiryTemplates__c.getAll();
 List < String > OppTMRoles = new List < String > (system.label.DealReg_ExpiryRecipients.split(','));
 List < String > stageValues = new List < String > {'Discover - 10%','Qualify - 30%','Propose - 60%','Commit - 90%','Order Submitted - 99%'};
 string DaysCheck = system.label.DealReg_ExpiryNotifyCheck;
 string mainQuery;
 ID templateid;
 contact con;

    public Batch_10DaysExpirationNotification(){
        con = [select id,email from contact where email <> null limit 1][0];     
    }  
    
 global Database.QueryLocator start(Database.BatchableContext BC) {
    mainQuery = 'SELECT Id,Days_Until_Deal_Expires__c,X10day_notification__c, X30day_notification__c,Account.Owner.Email, Partner_Account_Owner_Email__c, Owner.Email, Submitter_Language__c,(Select Userid, User.Email From OpportunityTeamMembers WHERE TeamMemberRole IN: OppTMRoles) FROM Opportunity WHERE (' + DaysCheck + ')  AND StageName IN: stageValues AND Deal_Reg_Oppty__c= ' + '\'' + 'Yes' + '\'' + ' AND Deal_Registration_Status__c = ' + '\'' + 'Approved' + '\'';
    //mainQuery = 'SELECT Id,Days_Until_Deal_Expires__c,X10day_notification__c, X30day_notification__c,Account.Owner.Email, Partner_Account_Owner_Email__c, Owner.Email, Submitter_Language__c,(Select Userid, User.Email From OpportunityTeamMembers WHERE TeamMemberRole IN: OppTMRoles) FROM Opportunity Limit 3';
     
     return database.getQueryLocator(mainQuery);
 }

 global void execute(Database.BatchableContext BC, List < Opportunity > oppList) {
 string strOrgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox' LIMIT 1].Id;
    List<Messaging.SingleEmailMessage> mails = new List <Messaging.SingleEmailMessage>();
     try{
          Map<id,Opportunity> mapOpp = new Map<Id,Opportunity>();
      for (Opportunity oppty: oppList) {
           mapOpp.put(oppty.Id,oppty);
           system.debug('OppList:' +oppList);
           List <String> toAddresses = new List <String>();
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           DealReg_DealExpiryTemplates__c SubmitterLanguageTemplate = ALLDealExpiryTemplates.get(oppty.Submitter_Language__c);
           if (SubmitterLanguageTemplate != NULL) {
            templateid = SubmitterLanguageTemplate.ID__c;
           } else {
            templateid = ALLDealExpiryTemplates.get('English').ID__c;
           }
           mail.setSaveAsActivity(false);
           mail.setTargetObjectId(con.id);
     //    mail.setOrgWideEmailAddressId(Id.valueOf(System.Label.No_Reply_Mailbox));
           mail.setOrgWideEmailAddressId(strOrgAddress );
           mail.setTreatTargetObjectAsRecipient(false);
           mail.setWhatId(oppty.id);
           mail.setTemplateid(templateid);
          if(oppty.Submitter_Language__c == 'English'){
           toAddresses.add(oppty.Account.Owner.Email);
          }
           toAddresses.add(oppty.owner.email);
          if(oppty.Partner_Account_Owner_Email__c != null){
           toAddresses.add(oppty.Partner_Account_Owner_Email__c);
          }
           for (OpportunityTeamMember Otm: oppty.OpportunityTeamMembers){
             toAddresses.add(otm.User.Email);
           }       
           mail.setToAddresses(toAddresses);              
           mails.add(mail);
      }
      if (!mails.isEmpty()){
                List<opportunity> newlist = new List<opportunity>();
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
                System.debug('-------------------'+results.size());
                   integer i=0;
               for(Messaging.SendEmailResult result:results){
                System.debug(result);
                   if(!result.IsSuccess()){
                    List<Messaging.SendEmailError> errorList = result.getErrors();
                    system.debug('errorList:' +errorList );
                   } else{
                       //for(opportunity temp:oppList)
                       Opportunity temp = mapOpp.get(mails.get(i).getWhatId());  
                       system.debug('**IDIII**' + mapOpp.get(mails.get(i).getWhatId()));
                       {
                           if(temp.Days_Until_Deal_Expires__c <= 30 && temp.Days_Until_Deal_Expires__c >10){
                               temp.X30day_notification__c = true;
                               system.debug(':::::::::::::temp30 list values:::'+temp.X30day_notification__c);
                           }else if(temp.Days_Until_Deal_Expires__c <= 10 && temp.Days_Until_Deal_Expires__c >0){
                               temp.X10day_notification__c = true;
                           }
                           newlist.add(temp);
                           system.debug(':::::::::::::new list values:::'+newlist);
                       }
                   } 
                  i++;             
               }
                        TriggerExecutionController.setSkipOpportunityTriggers(true);
                       database.update(newlist,false);
         }
     }catch(Exception ex){
         
       system.debug('The firing catch is : '+ex.getlinenumber()+'....'+ex);
        string ids = '';
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
         String[] toAddresses = new String[] {system.label.DealReg_10DayFailureNotification};
                     mail.setToAddresses(toAddresses) ;
                  // mail.setOrgWideEmailAddressId(Id.valueOf(System.Label.No_Reply_Mailbox));
                     mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox' LIMIT 1].Id);
                     mail.setSubject('HIGH:10 Day Expiration Notification batch failed');
                    system.debug('The firing catch is : '+ex.getlinenumber()+'....'+ex);
                     String body = '<html lang="ja"><body>'+
                                      '<br><br>'+
                                      'This email alert is to bring to your notice that 10 day expiry notification batch failed due to following error'+
                                      '</b>'+
                                      '<br><br>'+ ex.getMessage() + 
                                      '<br><br>'+ 'Failed Opportunities:'+ 
                                      '</b>'; 
                               for(opportunity temp:oppList){
                                   ids+=temp.id+',';                   
                                    body += '<br>' + temp.id + '<br>' ;
                                          }
                                     body += '</body></html>';
                     mail.setHtmlBody(body);
         if(!test.isRunningTest()){
                     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                      Exception__c exc = new Exception__c(Process_Name__c = 'Batch_10DaysExpirationNotification', Object_type__c = 'Opportunity', Error_Messages__c  = ex.getMessage(), Notes__c = ids);
             
                     insert exc; 
         }
        } 
     }

 global void finish(Database.BatchableContext BC) {
     
 }
}