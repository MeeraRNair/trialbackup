public class Case_AccountTeamNotifications{
public static Boolean isRecursive = false;
public static void SendNotifications(list<Case> CaseList,string TriggerAction,map<id,case> oldMap){

        if (isRecursive){
         return;
        }

    system.debug('Entered Case handleAfterUpdate ==== Case_AccountTeamNotifications.SendNotifications');            
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
       
        
                list<string> acc=new list<string>();
                list<string> caseid=new list<string>();
                list<string> UserId=new list<string>();
                map<string,string> Map_userid_useremail=new map<string,string>();
                    for(Case c:CaseList){
                        acc.add(c.accountid);
                        caseid.add(c.id);
                    }
                    
               
       // Map<id,case> Map_caseid_rectype=new Map<id,case>([select id,recordtype.name from case where id in:caseid]);      
                   
        map<id,account> Map_Accountid_account=new map<id,account>([select id,name,(select AccountId,Userid,user.email,user.Id,user.optout_email__c,TeamMemberRole from AccountTeamMembers) from account where id in:acc]);
        list<account> Tacc=new list<account>();
        Tacc=Map_Accountid_account.values();
        for(account a:Tacc){
         for(AccountTeamMember t:a.AccountTeamMembers){
         //UserId.add(t.userid);
         Map_userid_useremail.put(t.user.Id, t.user.email);
         }
        }
        
        system.debug('check UserId'+UserId);

        /*for (User u: [Select id, email from user where id IN: UserId]) {
           Map_userid_useremail.put(u.id, u.email);
          }*/
          
                    
            system.debug('check Map_Accountid_account'+Map_Accountid_account);
            system.debug('check Map_userid_useremail'+Map_userid_useremail);
            
            
                    for(case c:CaseList){
                    if(c.accountid!=null && c.Unauthenticated_Case__c==false){
                        //if(c.OwnerId!=null &(!String.valueOf(c.OwnerId).startsWith('00G'))) 
                        if((c.CaseRecordTypeName__c=='Deal Registration' 
                        || c.CaseRecordTypeName__c=='Order Support' 
                        || c.CaseRecordTypeName__c=='On Boarding' 
                        || c.CaseRecordTypeName__c=='On Boarding Internal'
                        || c.CaseRecordTypeName__c=='Application Support'
                        || c.CaseRecordTypeName__c=='Application Support - Internal only case types'
                        || c.CaseRecordTypeName__c=='Deal Registration - Internal only case types'
                        || c.CaseRecordTypeName__c=='Distribution'
                        || c.CaseRecordTypeName__c=='Partner Program') && ((Map_Accountid_account.get(c.accountid)).AccountTeamMembers!=null)&& Boolean.valueOf(Label.Case_Closed_Date)){                            
                          //if((Map_Accountid_account.get(c.accountid)).AccountTeamMembers!=null){  
                            //system.debug('check account team'+ (Map_Accountid_account.get(c.accountid)).AccountTeamMembers);
                               // if(((TriggerAction=='AfterInsert' && (c.status=='Open' || c.status=='Assigned')) || (TriggerAction=='AfterUpdate' && c.OwnerId!=null && (!String.valueOf(c.OwnerId).startsWith('00G')) && (c.status=='Closed (No Issue)' || c.status=='Closed (Resolved)'))) )
                                if(((TriggerAction=='AfterInsert' || c.status=='open'))  || (TriggerAction=='AfterUpdate' && c.OwnerId!=null && (!String.valueOf(c.OwnerId).startsWith('00G')) 
                                    && ( null!=oldMap && oldMap.get(c.id).status!= c.status && (c.status=='Closed (No Issue)' || c.status=='Closed (Resolved)'))))
                               {
                                    //Old and New Status check condition added by Uday Dt. 27-02-18 Story Story 4687556: (Item 3)
                                    emails=EmailNotification(c,(Map_Accountid_account.get(c.accountid)).AccountTeamMembers,Map_userid_useremail,c.CaseRecordTypeName__c);
                                }
                            //}
                            }
                        }
                        }
                        system.debug('check emails'+emails);
                    if(!emails.IsEmpty()){
                        if(!isRecursive){
                            Messaging.sendEmail(emails);
                            isRecursive = true;
                        }
                    }
            

}

public static list<Messaging.SingleEmailMessage> EmailNotification(case c,list<AccountTeamMember> TeamList,map<string,string> Map_userid_useremail,string recordtype){
    list<Messaging.SingleEmailMessage> emails=new list<Messaging.SingleEmailMessage>();
    EmailTemplate et =new EmailTemplate();
    string conid='';
    list<contact> Tcon=[select id,name,email from contact limit 1];
    if(!Tcon.IsEmpty()){
        tcon[0].email='dummyemail@gmail3.com';
        conid=Tcon[0].id;
    }
    system.debug('check conid'+conid);
    system.debug('check Contact id'+c.contactid);
    if(c.status=='Open' || c.status=='Assigned'){
    /*if(recordtype=='Deal Registration'){
    et = [SELECT id FROM EmailTemplate WHERE developername= 'Deal_Case_Submission_Account_Team_HTML_Email_Temp'];
    }else if(recordtype=='Order Support'){*/
    et = [SELECT id FROM EmailTemplate WHERE developername= 'Case_Submission_Account_Team_HTML_Email_Template'];
    //}
    }else if((c.status=='Closed (No Issue)' || c.status=='Closed (Resolved)')){
    et = [SELECT id FROM EmailTemplate WHERE developername= 'Case_Closed_AE_HTML_Email_Template'];
    }
        system.debug('check TeamList size'+TeamList.size());
        for(AccountTeamMember a:TeamList){
        system.debug('check AccountTeamMember useremail'+Map_userid_useremail.get(a.userid));
        system.debug('check AccountTeamMember template id'+et.id);
        if(Map_userid_useremail.get(a.userid)!=null){
        system.debug('check AccountTeamMember userid'+a.userid);
        system.debug('check AccountTeamMember template id'+et.id);
         
            if(a.TeamMemberRole=='Inside Sales Rep' || a.TeamMemberRole=='Account Executive' || a.TeamMemberRole=='Inside Channel Account Manager' || a.TeamMemberRole=='Partner Development Manager' || a.TeamMemberRole=='Distribution Partner Development Manager')
             {
                 if(a.user.optout_email__c==False){// if this is true, user is opted out email notification.Disabled notification.
                 Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                        email.setWhatId(c.id);
                        /*if(Recordtype!='On Boarding Internal'){
                        email.setTargetObjectId(c.contactid); // Specify who the email should be sent to.
                        }else if(Recordtype=='On Boarding Internal'){
                        email.setTargetObjectId(conid);
                        }*/
                        email.setTargetObjectId(conid);
                        list<string> emlist=new list<string>();
                        emlist.add(Map_userid_useremail.get(a.userid));
                        //System.debug('Hi Pradeep:123:==>>'+emlist);
                        email.setToAddresses(emlist);
                        email.setTemplateId(et.id);
                        email.SaveAsActivity= false;
                        email.treattargetobjectasrecipient = false;
                        //email.setPlainTextBody('Hi');
                        emails.add(email);
                    }
             
             
             }else {
             /*Messaging.SingleEmailMessage email1=new Messaging.SingleEmailMessage();
                        email1.setWhatId(c.id);
                        email1.setTargetObjectId(a.Userid); // Specify who the email should be sent to.
                        list<string> emlist=new list<string>();
                        emlist.add(a.user.email);
                        email1.setToAddresses(emlist);
                        email1.setTemplateId(et.id);
                        email1.SaveAsActivity= false;
                        
                        emails.add(email1);*/
                    }
             
             
        } 
       } 
       system.debug('check emails list value'+emails);
        // Send the emails in a transaction, then roll it back
         Savepoint sp = Database.setSavepoint();
 
         Messaging.sendEmail(emails);
 
         Database.rollback(sp);
         //OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no_reply@dell.com'];
           
        
        list<Messaging.SingleEmailMessage> Finalemails=new list<Messaging.SingleEmailMessage>(); 
        
        for(Messaging.SingleEmailMessage em:emails){
        if(em.getToAddresses()!=null && (em.getPlainTextBody()!=null || em.getHTMLBody()!=null)){
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        /*if ( owea.size() > 0 ) {
        emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
        }*/
        emailToSend.setOrgWideEmailAddressId(Id.valueOf(System.Label.No_Reply_Mailbox));
        emailToSend.setToAddresses(em.getToAddresses());
        System.debug('Hi Pradeep::==>>'+em.getToAddresses());
        emailToSend.setPlainTextBody(em.getPlainTextBody());
        emailToSend.setHTMLBody(em.getHTMLBody());
        //emailToSend.setSubject('Test naresh duplicate check');
        emailToSend.setSubject(em.getSubject());
        
        Finalemails.add(emailToSend);
        }
        }     
     system.debug('Check Final Email' +Finalemails);   
    return Finalemails;
}

}