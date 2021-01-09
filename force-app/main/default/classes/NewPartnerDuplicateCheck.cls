/* 
Author: Devika Pujari

History: Class called from PartnerRequestTrigger to get the duplicate PRs and send emails to Onboarding Team.
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
*/

public class NewPartnerDuplicateCheck{
    
    public void checkForDuplicateMethod(List<Partner_Request__c> partnerRequestList){
        
        Id NEW_PARTNER_REQUEST = [SELECT Id FROM RecordType WHERE SobjectType = 'Partner_Request__c' AND DeveloperName = 'New_Partner'].Id;    
        List<Id> newPartnerIds = new List<Id>();
        List<Partner_Request__c> updatePartnerList = new List<Partner_Request__c>();
        Map<String,Partner_Request__c> newPartnerRequestMap = new Map<String,Partner_Request__c>();
        Map<String,List<Partner_Request__c>> existingPartnerRequestMap = new Map<String,List<Partner_Request__c>>();
        
        try{
            for(Partner_Request__c newParnterRequest: partnerRequestList){
                newPartnerRequestMap.put(newParnterRequest.Company__c,newParnterRequest);
                newPartnerIds.add(newParnterRequest.Id);
            }
            
            List<Partner_Request__c> existingList = [Select Id,Name,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                                     City__c,Company__c,Country__c,Country__r.Code__c,Email__c,Postal_Code__c,Reseller_Tax_ID__c,State__c,Website__c
                                                     From Partner_Request__c where Company__c IN: newPartnerRequestMap.KeySet()
                                                     AND ID NOT IN: newPartnerIds AND RecordTypeId =: NEW_PARTNER_REQUEST];
            
            if(!existingList.isEmpty()){
                for(Partner_Request__c partnerRequest : existingList){
                    if(!existingPartnerRequestMap.containsKey(partnerRequest.Company__c)){
                        existingPartnerRequestMap.put(partnerRequest.Company__c, new List<Partner_Request__c>());
                    }
                    List<Partner_Request__c> existingPartnerRequestList = existingPartnerRequestMap.get(partnerRequest.Company__c);
                    existingPartnerRequestList.add(partnerRequest );
                    existingPartnerRequestMap.put(partnerRequest.Company__c,existingPartnerRequestList);
                }    
                
                for(String Company :newPartnerRequestMap.keySet()){      
                    Partner_Request__c newPartnerRequest = newPartnerRequestMap.get(Company);
                    String emailDomainList = newPartnerRequest.Email__c.split('@')[1];
                    List<String> duplicateExistingPartnerRequests = new List<String>();
                    for(Partner_Request__c existingPartnerRequest : existingPartnerRequestMap.get(Company)){
                        if(newPartnerRequest.Address_Line_1__c == existingPartnerRequest.Address_Line_1__c &&
                           newPartnerRequest.Address_Line_2__c == existingPartnerRequest.Address_Line_2__c && 
                           newPartnerRequest.Address_Line_3__c == existingPartnerRequest.Address_Line_3__c &&
                           newPartnerRequest.City__c == existingPartnerRequest.City__c &&
                           newPartnerRequest.State__c == existingPartnerRequest.State__c &&
                           newPartnerRequest.Country__c == existingPartnerRequest.Country__c &&
                           newPartnerRequest.Email__c.toUpperCase().split('@')[1] == existingPartnerRequest.Email__c.toUpperCase().split('@')[1] &&
                           newPartnerRequest.Postal_Code__c == existingPartnerRequest.Postal_Code__c &&
                           newPartnerRequest.Reseller_Tax_ID__c == existingPartnerRequest.Reseller_Tax_ID__c &&
                           newPartnerRequest.Website__c == existingPartnerRequest.Website__c 
                          ){
                              duplicateExistingPartnerRequests.add(existingPartnerRequest.Name); 
                          }         
                    }
                    if(!duplicateExistingPartnerRequests.isEmpty()){        
                        newPartnerRequest.Duplicate_PRs__c = String.Join(duplicateExistingPartnerRequests,',');
                    }
                }
            }  
        }catch(exception e){
            system.debug('****************Error:'+e.getMessage()); 
        }    
    }
    
    public void sendEmail(List<Id> duplicatePartnerIds){
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
        Map<String,Partner_Onboarding_Mailboxes__c> country2MailboxMap = Partner_Onboarding_Mailboxes__c.getAll();    
        try{
            system.debug('******'+country2MailboxMap);
            Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Duplicate_Partner_Requests'].Id;
            Contact dummyContact = [SELECT Id,Email FROM Contact WHERE Email != '' AND AccountId != '' AND Phone != '' 
                                    AND MobilePhone != '' AND Eloqua_ID__c != '' LIMIT 1]; 
            List < OrgWideEmailAddress > orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox'];
            
            List<Partner_Request__c> duplicatePartnerRequests = [Select Id,Country__r.Region__c,Country__r.Code__c 
                                                                 From Partner_Request__c where Id IN: duplicatePartnerIds];
            for(Partner_Request__c newPartnerRequest : duplicatePartnerRequests){   
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                List<String> toAdd = new List<String>();    
                String Key ='';
                mail.setSaveAsActivity(false);
                mail.setTemplateId(emailTemplateId);
                mail.setWhatId(newPartnerRequest.Id);
                mail.setTargetObjectId(dummyContact.Id);
                
                //NA + LATAM + EMEA + EC-EMEA  
                system.debug('******'+newPartnerRequest.Country__r.Region__c);
                
                if(country2MailboxMap.containsKey(newPartnerRequest.Country__r.Region__c.toUpperCase())){
                    Key = newPartnerRequest.Country__r.Region__c;
                }
                else if(country2MailboxMap.containsKey(newPartnerRequest.Country__r.Region__c.toUpperCase()+'-'+newPartnerRequest.Country__r.Code__c.toUpperCase())){
                    Key = newPartnerRequest.Country__r.Region__c+'-'+newPartnerRequest.Country__r.Code__c;
                }   
                else{          
                    Key = 'NA';
                }
                
                if(Key != null){
                    if(!(country2MailboxMap.get(Key).Mailbox__c.contains(';'))){ 
                        toAdd.add(country2MailboxMap.get(Key).Mailbox__c);
                    }
                    else{
                        List<String> mailboxList= country2MailboxMap.get(Key).Mailbox__c.split(';');
                        toAdd.addAll(mailboxList);             
                    }              
                } 
                //toAdd.add(UserInfo.getUserEmail());
                mail.setToAddresses(toAdd);
                mails.add(mail); 
            }  
            if (!mails.isEmpty()) {
                Savepoint sp = Database.setSavepoint();
                Messaging.sendEmail(mails);
                Database.rollback(sp);
            }        
            /********** To exclude Dummy Contact Id ******************************/
            List < Messaging.SingleEmailMessage > lstMsgsToSend = new List < Messaging.SingleEmailMessage > ();
            for (Messaging.SingleEmailMessage email: mails) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                
                Set<String> toAdd = new Set<String>();          
                toAdd.AddAll(email.getToAddresses());
                toAdd.remove(dummyContact.Email);
                List<String> toAddList = new List<String>();
                toAddList.addAll(toAdd);
                
                emailToSend.setToAddresses(email.getToAddresses());
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                emailToSend.setSaveAsActivity(false);
                if (!orgWideAddress.isEmpty()) {
                    emailToSend.setOrgWideEmailAddressId(orgWideAddress[0].Id);
                }
                lstMsgsToSend.add(emailToSend);
            }
            if (!lstMsgsToSend.isEmpty()) {
                Messaging.sendEmail(lstMsgsToSend);
            } 
        }catch(exception e){
            system.debug('************Error:'+e);
        }
    }
}