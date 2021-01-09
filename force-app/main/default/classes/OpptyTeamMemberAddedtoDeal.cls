/*
* Author   : M Subramanyam
* Purpose  : Condition to send notification for opp Team Members added after a deal gets Approved/Rejected [Subramanyam M]
* Test class for code coverage : OppTeamMemberTriggerTest
*        
* Revision Ref Number  Release No  Date            Modified By     Description
* -------- ----------  ----------  -----------     ------------    -----------
*   1.0     CR 13150    DCS0602     19-05-2016      Devika           To update the logic to exclude running on this code when
*                                                                   the opp team members are added during approval proces
*  2.0     CR 13088  Deal Reg-US#1653385-Disti Visibility - Send Approval Notification for contacts added post approval                  
*/

public class  OpptyTeamMemberAddedtoDeal {

 public string strOrgAddress;
 
    
    public static void insertOpptyTeamMember(List<OpportunityTeamMember> opptyTeamMembers) {
   
        string strOrgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox' LIMIT 1].Id;
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> partnermails = new List<Messaging.SingleEmailMessage>();
        Map<String, Id> templateMap = new Map<String, Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<String> partnertemplates = new List<String>{'PRM Chinese Simplified Deal Reg Approved_VF',  'PRM Chinese Traditional Deal Reg Approved_VF',  'PRM Czech Deal Reg Approval Email VF',  'PRM Danish Deal Reg Approved VF',  'PRM Dutch Deal Reg Approved VF',  'PRM English Deal Reg Approved VF',  'PRM French Deal Reg Approved VF',  'PRM German Deal Reg Approved VF',  'PRM Italian Deal Reg Approved VF',  'PRM Japanese Deal Reg Approved_VF',  'PRM Korean Deal Reg Approved_VF',  'PRM Polish Deal Reg Approved VF',  'PRM Portuguese Deal Reg Accepted VF',  'PRM Russian DealReg Approved VF',  'PRM Spanish Deal Reg Approved VF',  'PRM Swedish Deal Reg Approved VF',  'PRM Turkish DealReg Approved VF',  'PRM Greece Deal Reg Approved VF',  'PRM Morocco Deal Reg Approved VF'};
        
        Map<String,String> languagetemplatemap = new Map<String,String>{'zh_CN'=>'PRM Chinese Simplified Deal Reg Approved_VF',
                                                                          'zh_TW'=>'PRM Chinese Traditional Deal Reg Approved_VF',
                                                                          'cs'=>'PRM Czech Deal Reg Approval Email VF',
                                                                          'da'=>'PRM Danish Deal Reg Approved VF',
                                                                          'nl_NL'=>'PRM Dutch Deal Reg Approved VF',
                                                                          'en_US'=>'PRM English Deal Reg Approved VF',
                                                                          'fr'=>'PRM French Deal Reg Approved VF',
                                                                          'de'=>'PRM German Deal Reg Approved VF',
                                                                          'it'=>'PRM Italian Deal Reg Approved VF',
                                                                          'ja'=>'PRM Japanese Deal Reg Approved_VF',
                                                                          'ko'=>'PRM Korean Deal Reg Approved_VF',
                                                                          'pl'=>'PRM Polish Deal Reg Approved VF',
                                                                          'pt_BR'=>'PRM Portuguese Deal Reg Accepted VF',
                                                                          'ru'=>'PRM Russian DealReg Approved VF',
                                                                          'es_MX'=>'PRM Spanish Deal Reg Approved VF',
                                                                          'es'=>'PRM Spanish Deal Reg Approved VF',
                                                                          'sv'=>'PRM Swedish Deal Reg Approved VF',
                                                                          'tr'=>'PRM Turkish DealReg Approved VF',
                                                                          'el'=>'PRM Greece Deal Reg Approved VF',
                                                                          'frmorocco'=>'PRM Morocco Deal Reg Approved VF'};
        
        List<OpportunityTeamMember> validOppTeam = new List<OpportunityTeamMember>();
        Set<String>  newRoles = new Set<String>{ 'Partner AE','DM Solutions Engineer', 'DM Sales Specialist', 'Enterprise Sales Specialist', 'Networking Solutions Engineer', 'Networking Sales Specialist', 'System Consultant','Distributor Contact', 'Reseller Contact'};
            
            for(EmailTemplate temp: [SELECT Id, Name FROM EmailTemplate WHERE Name = 'PRM Deal Registration Sales Team VF' OR Name = 'PRM English Deal Reg Rejected Email_VF' OR Name IN :partnertemplates]){
                templateMap.put(temp.Name, temp.Id);
            }
        
        
        
        for(OpportunityTeamMember opptyTeamMember: opptyTeamMembers) {
            if(newRoles.contains(opptyTeamMember.TeamMemberRole)){
                opportunityIds.add(opptyTeamMember.OpportunityId);
                userIds.add(opptyTeamMember.UserId);
                validOppTeam.add(opptyTeamMember);
            }
            
        }
        
       System.debug('validOppTeam:'+validOppTeam);
        
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([Select Id, Account.Sales_Channel__r.Name,
                                                                        AccountId, 
                                                                        Account.Name, 
                                                                        Account.Owner.Name, 
                                                                        Name, Tier_1_Approved_Rejected__c,
                                                                        Deal_Registration_Status__c,
                                                                        Deal_ID__c,
                                                                        Owner.Name,
                                                                        Distributor_Name__c,
                                                                        Distributor_Reseller_Name__c,
                                                                        Distributor_Reseller_Name__r.name 
                                                                        from Opportunity 
                                                                        where Id IN: opportunityIds]);
        
        Map<Id, User> userMap = new Map<Id, User>([Select Id, 
                                                   Profile.Name, 
                                                   UserRole.Name,
                                                   Name,
                                                   LanguageLocaleKey,
                                                   Email,
                                                   contactid
                                                   from User 
                                                   where Id IN: userIds]);
        System.debug('usermap:'+userMap );
        
 //       Contact dummyContact = [SELECT Id FROM Contact WHERE Email != '' AND AccountId != '' AND Phone != '' 
                        //    AND MobilePhone != '' AND Eloqua_ID__c != '' LIMIT 1];  
        
        for(OpportunityTeamMember opptyTeamMember: validOppTeam){
            
             //email for disti/reseller contacts
            if(opportunityMap.get(opptyTeamMember.OpportunityId).Deal_Registration_Status__c == 'Approved' 
            && (opptyTeamMember.TeamMemberRole == 'Distributor Contact' || opptyTeamMember.TeamMemberRole == 'Reseller Contact') 
            && userMap.get(opptyTeamMember.userid).contactid!=null){
                              
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                              
                mail.setSaveAsActivity(false);
                //mail.setTargetObjectId(userMap.get(opptyTeamMember.userid).contactid);
                mail.setTargetObjectId(opptyTeamMember.UserId);
                mail.setWhatId(opptyTeamMember.OpportunityId);
                 if (!Test.isRunningTest()){
          //    mail.setOrgWideEmailAddressId(Id.valueOf(System.Label.No_Reply_Mailbox));
                mail.setOrgWideEmailAddressId(strOrgAddress);
            }
                List<String> toAdd = new List<String>();
                toAdd.add(userMap.get(opptyTeamMember.UserId).Email);
            //  mail.setToAddresses(toAdd);
                system.debug('1:'+userMap.get(opptyTeamMember.userid));
                System.debug('2'+userMap.get(opptyTeamMember.userid).LanguageLocaleKey);
                System.debug('3:'+languagetemplatemap.get(userMap.get(opptyTeamMember.userid).LanguageLocaleKey));
                System.debug('4:'+templateMap.get(languagetemplatemap.get(userMap.get(opptyTeamMember.userid).LanguageLocaleKey)));
                if(userMap.get(opptyTeamMember.userid).Profile.Name.contains('EC-EMEA PRM') && userMap.get(opptyTeamMember.userid).LanguageLocaleKey == 'fr'){
                    mail.setTemplateId(templateMap.get(languagetemplatemap.get('frmorocco'))); 
                }
                else if(templateMap.get(languagetemplatemap.get(userMap.get(opptyTeamMember.userid).LanguageLocaleKey)) !=null){
                    mail.setTemplateId(templateMap.get(languagetemplatemap.get(userMap.get(opptyTeamMember.userid).LanguageLocaleKey))); 
                }
                else{
                    mail.setTemplateId(templateMap.get(languagetemplatemap.get('en_US'))); 
                }
                
                //partnermails.add(mail); 
                System.debug('1 mail is @@ '+mail);
                mails.add(mail);
            }
            else if((opportunityMap.get(opptyTeamMember.OpportunityId).Deal_Registration_Status__c == 'Approved' || opportunityMap.get(opptyTeamMember.OpportunityId).Deal_Registration_Status__c == 'Rejected') 
                        && opptyTeamMember.TeamMemberRole != 'Distributor Contact' && 
                        opptyTeamMember.TeamMemberRole != 'Reseller Contact'                     
                     /****v1.0 Starts +SAR 14543*******/ 
                        && opportunityMap.get(opptyTeamMember.OpportunityId).Tier_1_Approved_Rejected__c != null && (!(opportunityMap.get(opptyTeamMember.OpportunityId).Tier_1_Approved_Rejected__c.date() == System.now().date()
                        && opportunityMap.get(opptyTeamMember.OpportunityId).Tier_1_Approved_Rejected__c.hour() == System.now().hour() 
                        && opportunityMap.get(opptyTeamMember.OpportunityId).Tier_1_Approved_Rejected__c.minute() == System.now().minute())) ){
                    // if(){                   
                     /****v1.0 Starts +SAR 14543*******/ 
                
                if (newRoles.Contains(opptyTeamMember.TeamMemberRole)){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                              
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(opptyTeamMember.UserId);
                    mail.setWhatId(opptyTeamMember.OpportunityId);
                     //if (!Test.isRunningTest()){
          //  mail.setOrgWideEmailAddressId(Id.valueOf(System.Label.No_Reply_Mailbox));
           mail.setOrgWideEmailAddressId(strOrgAddress);
          //  }
                    List<String> toAdd = new List<String>();
                    toAdd.add(userMap.get(opptyTeamMember.UserId).Email);
                  //  mail.setToAddresses(toAdd);
                    
                    if(opportunityMap.get(opptyTeamMember.OpportunityId).Deal_Registration_Status__c == 'Approved'){                        
                        
                        mail.setTemplateId(templateMap.get('PRM Deal Registration Sales Team VF'));                                           
                        
                    }else If(opportunityMap.get(opptyTeamMember.OpportunityId).Deal_Registration_Status__c == 'Rejected'){
                        
                        mail.setTemplateId(templateMap.get('PRM English Deal Reg Rejected Email_VF'));                       
                        
                    }
                    mails.add(mail);
                }
          //  } 
          }                         
        }
        
        try{
          if(!mails.isEmpty()){
         //   Savepoint sp = Database.setSavepoint();
              Messaging.sendEmail(mails);
         //   Database.rollback(sp);
            }
            
           /* if(partnermails.size()>0){
                Messaging.sendEmail(partnermails);  
            }*/ 
        
         /********** To exclude Dummy Contact Id ******************************/
     /*     List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
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
        }catch(exception e){
          system.debug('****'+e);
        }        
            
    }    
}