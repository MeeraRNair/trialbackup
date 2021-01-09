/*
Author : mohammad
Purpose : This class is created to send approval emails based on the GTM Model in Account. If the Account is considered as Dell Assigned then email will be sent from this email else workflow will send the emails.
CR : 13566
*/

public class  NotifyPartnerandEndUseracctteams {

    public string strOrgAddress;
     public static void NotifyOpptyTeam(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities ) {
     string strOrgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox' LIMIT 1].Id;
     try{
       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
       List<Id> Opplist = new List<Id>();
        EmailTemplate temp = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'PRM Deal Registration Sales Team VF'];
        List<String> delldirect = new List<String>();
        List<String> oppTeamMbrs = System.Label.Oppty_Team_Role_for_Approval.split(',');
        delldirect.add('Dell DIRECT FIELD');
        delldirect.add('Dell DIRECT INSIDE');
        delldirect.add('Dell OEM');
        delldirect.add('DELL QUEUE');
        delldirect.add('DELL CHANNEL');
        //String s = System.Label.PRM_Deal_Sales_Team_VF;
    
        for(Opportunity obj : lstNewOpportunities){  
            Opportunity oldOpportunity = mapOldOpportunities.get(obj.id);
         if(oldOpportunity.Deal_Registration_Status__c !='Approved' && obj.Deal_Registration_Status__c =='Approved' ){            
            Opplist.add(obj.Id);            
            system.debug('Opplist'+Opplist);
        }
       }
       
       List<OpportunityTeamMember> Oppteamenduserlist = [SELECT Id,Userid,User.Email,Partner_Account_Member__c,End_User_Acct_Member__c,OpportunityId FROM OpportunityTeamMember WHERE 
       OpportunityId IN : Opplist AND TeamMemberRole Not IN :oppTeamMbrs AND (Partner_Account_Member__c = true OR IsUploadedfromCSV__c = true 
       OR(Partner_Account_Member__c = false AND IsUploadedfromCSV__c = false AND End_User_Acct_Member__c = false )
         OR (End_User_Acct_Member__c = true AND Opportunity.Account.GTM_MOdel__c  IN :delldirect))];
       // OR IsUploadedfromCSV__c = true OR (Partner_Account_Member__c = false AND IsUploadedfromCSV__c = false AND End_User_Acct_Member__c = false)
    system.debug('Team List end and partner '+Oppteamenduserlist);
     //  Contact dummyContact = [SELECT Id FROM Contact WHERE Email != '' AND AccountId != '' AND Phone != '' 
                        //    AND MobilePhone != '' AND Eloqua_ID__c != '' LIMIT 1]; 
                           IF(!Oppteamenduserlist.Isempty()){                        
                            for(OpportunityTeamMember opptyteam: Oppteamenduserlist )  {
                           // IF( opptyteam.TeamMemberRole!= 'Reseller Contact' || opptyteam.TeamMemberRole!= 'Distributor Contact'){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setSaveAsActivity(false);
                          //  mail.setTreatTargetObjectAsRecipient(false); 
                            mail.setTargetObjectId(opptyteam.User.Id);
                            mail.setWhatId(opptyteam.Opportunityid);
                          list< String> toAdd = new List<String>();
                          
                          System.debug('@@@@ Debug toAdd  size '+toAdd.size());
                            toAdd.add(opptyteam.User.Email);
                         //  mail.setToAddresses(toAdd );
                            mail.setTemplateId(temp.Id); 
                            mail.setOrgWideEmailAddressId(strOrgAddress);
                           // System.Debug('####Template Value' + s);
                            mails.add(mail);  
                     }                          
                      // } 
                           }
                        
                        if(!mails.isEmpty()){
              //  Savepoint sp = Database.setSavepoint();
                System.debug('****Users who recieve email before: ' + mails);
                Messaging.sendEmail(mails); 
             //   Database.rollback(sp); 
             //   System.debug('****Inside Send Email After: ' + mails);
                
            }
            /********** To exclude Dummy Contact Id ******************************/
            /*
                        
          List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
          for (Messaging.SingleEmailMessage email : mails) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            //String subject = EncodingUtil.urlEncode(email.getSubject(), 'UTF-8');

            System.debug(email.getSubject());
            emailToSend.setSubject(email.getSubject());
            emailToSend.setSaveAsActivity(false);                
            lstMsgsToSend.add(emailToSend);
          } 
          if(!lstMsgsToSend.isEmpty()){
            Messaging.sendEmail(lstMsgsToSend);
          }    */
              
        }catch(Exception ex){
           // Database.rollback(sp);
            System.debug('#####Generic Exception: '+ ex.getMessage());
        }    
     }
 }