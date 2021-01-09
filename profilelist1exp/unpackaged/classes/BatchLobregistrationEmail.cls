/*
 * Author : 
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR            R16.07    23-Jun-2015     Devika          Update the logic in the class to include multi LOB functionality
 * 2.0      CR 12408      R16.12    30-Nov-2015     Jiji            To change send the LOB expiration notification when ‘Days until LOB Expires’ changes to 35
 * 3.0      CR 12409      R16.12    30-Nov-2015     Jiji            To change the LOB Registration Status = Expired/Open when the ‘Days until LOB Expires’ changes to 0.
 * 4.0      CR            R16.12    02-Dec-2015     Devika          To update the LOB Reg Status from Open to Expired.
 */
global class BatchLobregistrationEmail implements Database.Batchable<sObject>,Database.Stateful{
    
    global   Map<String,Integer>  sendmaillist =new Map<String,Integer>();
    global   set<string> licenseset = new set<string>();
    global list<account> acclist; 
    global map<id,account> accmap; 
    global set<id> accids ,lobids;
    global EmailTemplate et;
    global Contact con;
    global BatchLobregistrationEmail(){   }

    global BatchLobregistrationEmail(set<id> lids,set<id> aids){
        lobids = new set<id>(lids);
        system.debug('----lobids  ----'+lobids );
        accmap = new map<id,account>();
        acclist =[SELECT Id,Name,Account_ID__c,Createddate,owner.email ,(Select user.email,AccountID From AccountTeamMembers WHERE TeamMemberRole='Account Executive' OR TeamMemberRole='Inside Sales Rep' OR TeamMemberRole='Global Account Manager' OR TeamMemberRole= 'Inside Channel Account Manager' OR TeamMemberRole= 'Partner Development Manager') FROM Account where Id IN:aids];
        system.debug('----acclist----'+acclist);
        for(account a:acclist){
            accmap.put(a.id,a);
        }
        et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Lob_Expiration_Notification'];
        con =  [select id, Email from Contact where email <> null limit 1];   
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string   query = 'SELECT id,Name,Preferred_GTM_Partner_Account__r.id,Lobregistration_Noofdays__c,Registered_End_User__r.owner.email,Partner_Sales_Rep_Contact__r.owner.email,Registered_End_User__r.Account_ID__c,LOB_Partner_Approved_Date__c, Days_Until_LOB_Expires__c FROM LOB_Registration__c  where  id in:lobids';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sobject> scope){
 
        list<LOB_Registration__c> LObList=(list<LOB_Registration__c>)scope;
        list<LOB_Registration__c> LObList1= new list<LOB_Registration__c>();
        list<LOB_Registration__c> LObList2= new list<LOB_Registration__c>();
        list<LOB_Registration__c> loblistupdate= new list<LOB_Registration__c>(); 

        for(LOB_Registration__c u:Loblist) {
            //Ver 2.0: Start
            //if( u.Lobregistration_Noofdays__c ==275)
            if( u.Days_Until_LOB_Expires__c ==35){
            //Ver 2.0: End
                LObList1.add(u);
            }
            if(u.Days_Until_LOB_Expires__c ==5){
                LObList1.add(u);
            }
            //Ver 3.0: Start
            //if(u.Days_Until_LOB_Expires__c ==365){
            if(u.Days_Until_LOB_Expires__c ==0){
            //Ver 3.0: End
                LObList2.add(u);
            }
        }
        
        for(LOB_Registration__c u:Loblist1) {
            
            list<string> toaddress = new List<string>();
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>(); 
            If(accmap.get(u.Preferred_GTM_Partner_Account__r.id) != NULL){
                toaddress.add(accmap.get(u.Preferred_GTM_Partner_Account__r.id).owner.email);
                for( AccountteamMember a:accmap.get(u.Preferred_GTM_Partner_Account__r.id).AccountTeamMembers){
                    toaddress.add(a.user.email);
                }
            }
            toaddress.add(u.Registered_End_User__r.owner.email);
            if(u.Partner_Sales_Rep_Contact__r.owner.email!= Null){
            toaddress.add(u.Partner_Sales_Rep_Contact__r.owner.email);
            }
            system.debug('Partner_Sales_Rep_Contact__r.owner.email'+ u.Partner_Sales_Rep_Contact__r.owner.email);
            system.debug('Registered_End_User__r.owner.email'+ u.Registered_End_User__r.owner.email);
            
                          
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(con.id); 
            mail.setTemplateId(et.id);
            mail.setWhatId(u.id);
            mail.setToAddresses(toaddress);
            lstMsgs.add(mail);
            
            system.debug('----mail ----'+lstMsgs);
            Savepoint sp = Database.setSavepoint();  
            Messaging.sendEmail(lstMsgs); 
            Database.rollback(sp);
           
            List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>(); 
            for (Messaging.SingleEmailMessage email : lstMsgs) { 
               Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage(); 
               emailToSend.setToAddresses(email.getToAddresses()); 
               emailToSend.setPlainTextBody(email.getPlainTextBody()); 
               emailToSend.setHTMLBody(email.getHTMLBody()); 
               emailToSend.setSubject(email.getSubject()); 
               lstMsgsToSend.add(emailToSend); 
            }  
            Messaging.sendEmail(lstMsgsToSend);
            
     }  
     for (LOB_Registration__c lob :loblist2){
        LOB_Registration__c lob12 =  new LOB_Registration__c();
        lob12.id =lob.id;
        lob12.LOB_registration_status__c = 'Expired'; //4.0'Open';
        lob12.LOB_Award_Cancellation_Date__c=date.today();
        //Ver 3.0: lob12.Preferred_GTM_Partner_Account__c =null;
        //Ver 3.0: lob12.LOB_Partner_Approved_Date__c =null;
        loblistupdate.add(lob12);
     }
     TriggerExecutionController.setskipActivateAccount(true);
     if(loblistupdate.size()>0){
        update loblistupdate;
     }
       TriggerExecutionController.setskipActivateAccount(false); 
    }
    global void finish(Database.BatchableContext BC){
         
    }
}