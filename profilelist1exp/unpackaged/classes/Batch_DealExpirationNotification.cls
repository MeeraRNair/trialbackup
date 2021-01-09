/*********************************************************
Description: This is a Batch class used to send Deal Expiration Notifications to Team members.
S.No  Date            Name                                Desc                    
1.0   2016-10-13      Ujwala Jupuru                       Created  

**********************************************************/
global class Batch_DealExpirationNotification implements Database.Batchable<sObject>{
     List<Id> Opplist = new List<Id>();
     transient List<Messaging.SingleEmailMessage> mails;
     List<String> delldirect = new List<String>{'Dell DIRECT FIELD','Dell DIRECT INSIDE','Dell OEM','DELL QUEUE'};
     EmailTemplate temp;
     List<String> stageValues = new List<String>{'Qualify - 30%','Propose - 60%','Commit - 90%'};
     List<String> oppTeamMbrs = System.Label.Opportunity_Team_Members.split(',');
     String sts = 'Approved';
     Date dt = system.toDay().addDays(10);
     
    global Batch_DealExpirationNotification (){ 
        temp = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'PRM Deal Expiry Reminder VF']; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //return Database.getQueryLocator('select Id, Deal_Registration_Status__c FROM Opportunity where Deal_Registration_Status__c =:sts AND Deal_Expiration_Date__c =:dt AND StageName IN :stageValues'); 
        String oppTeamQueryStr = 'SELECT Id,Userid,User.Email,Partner_Account_Member__c,End_User_Acct_Member__c,OpportunityId FROM OpportunityTeamMember WHERE ' + 
                                 'TeamMemberRole Not IN :oppTeamMbrs AND (Partner_Account_Member__c = true OR IsUploadedfromCSV__c = true ' +
                                 ' OR(Partner_Account_Member__c = false AND IsUploadedfromCSV__c = false AND End_User_Acct_Member__c = false ) ' +
                                 ' OR (End_User_Acct_Member__c = true AND Opportunity.Account.GTM_MOdel__c  IN :delldirect) ) ' + 
                                 ' AND Opportunity.Deal_Registration_Status__c = ' + '\'' + 'Approved' + '\'' + ' AND Opportunity.Deal_Expiration_Date__c =:dt AND Opportunity.StageName IN :stageValues ';
                                 system.debug('@oppTeamQueryStr '+oppTeamQueryStr);
        return Database.getQueryLocator(oppTeamQueryStr);
        
    }
    
    // test
    
    global void execute(Database.BatchableContext BC, List<OpportunityTeamMember> oppTeamList){
    
    system.debug('@oppTeamList '+oppTeamList);
        mails = new List<Messaging.SingleEmailMessage>();
        try{
           /* List<OpportunityTeamMember> optyMbrList = new List<OpportunityTeamMember>();
            optyMbrList = [SELECT Id,Userid,User.Email,Partner_Account_Member__c,End_User_Acct_Member__c,OpportunityId FROM OpportunityTeamMember WHERE 
                           TeamMemberRole!= 'SonicWALL Sales Specialist' AND (Partner_Account_Member__c = true OR IsUploadedfromCSV__c = true 
                           OR(Partner_Account_Member__c = false AND IsUploadedfromCSV__c = false AND End_User_Acct_Member__c = false )
                           OR (End_User_Acct_Member__c = true AND Opportunity.Account.GTM_MOdel__c  IN :delldirect) ) 
                           AND Opportunity.Deal_Registration_Status__c = 'Approved' AND Opportunity.Deal_Expiration_Date__c =: system.toDay().addDays(10) ]; */
            
            //Dummy Email Alert
         //   Contact dummyContact = [SELECT Id FROM Contact WHERE Email != '' AND AccountId != '' AND Phone != '' 
                             //       AND MobilePhone != '' AND Eloqua_ID__c != '' LIMIT 1]; 

             if(!oppTeamList.Isempty()){                        
                for(OpportunityTeamMember opptyteam : oppTeamList){
                 System.debug('Iteration optteam Loop @@');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                    
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(opptyteam.user.Id);                     
                    mail.setWhatId(opptyteam.Opportunityid);
                    List<String> toAdd = new List<String>();
                    toAdd.add(opptyteam.User.Email);                     
                //  mail.setToAddresses(toAdd);                    
                    mail.setTemplateId(temp.id);                    
                    mails.add(mail);                     
                }                          
            }
            //Dummy Email Alert            
            if(!mails.isEmpty()){
            System.debug('Entered for email sending @@');
             //   Savepoint sp = Database.setSavepoint();
    System.debug(  'Email Statues is @@ '+  Messaging.sendEmail(mails)); 
              //  Database.rollback(sp); 
            }
            
           /* List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();            
            for (Messaging.SingleEmailMessage email : mails) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(email.getToAddresses());
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());                 
                emailToSend.setSubject(email.getSubject());
                emailToSend.setSaveAsActivity(false);                
                lstMsgsToSend.add(emailToSend);
              }
              if(!lstMsgsToSend.isEmpty()){
                Messaging.sendEmail(lstMsgsToSend);
              }*/  
        }catch(Exception ex){
           
        }   
    }
    global void finish(Database.BatchableContext BC){
    
    }
 }