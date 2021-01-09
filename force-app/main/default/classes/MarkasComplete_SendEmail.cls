public class MarkasComplete_SendEmail {
    
    // Sending email to sponsoring disti and updating Primary and Secodnary Email fields from Sponsring Disti to PR
        Public PageReference doPageLoad(){     
             Partner_Request__c partnerRequest =[Select id,OwnerId,owner.type,Sponsoring_Distributor__c,country__c From Partner_Request__c 
                                               Where Id=:ApexPages.currentPage().getParameters().get('id') and Status__c='In Review'];
            //Getting Email Id from Parner Request record Owner
            String ownerEmail;
            if(partnerRequest.owner.type == 'Queue'){
                ownerEmail=[SELECT Email,Id FROM Group where id =: partnerRequest.OwnerId].Email;
            } else if(partnerRequest.owner.type == 'User'){
                ownerEmail=[SELECT Email,Id,LastName,Name FROM User where Id =: partnerRequest.OwnerId].Email;
            }
            system.debug('queues'+ownerEmail);
            if(partnerRequest.Sponsoring_Distributor__c!=null){
                list<Sponsoring_Distributor__c> spDistr = new list<Sponsoring_Distributor__c>();
                spDistr=[Select id,Primary_Email__c,Secondary_Email__c From Sponsoring_Distributor__c Where Name=:partnerRequest.Sponsoring_Distributor__c and country__c = :partnerRequest.country__c LIMIT 1];                                         
                try {
                    
                    String[] toAddresses = new String[]{};
                     toAddresses.add(spDistr[0].Primary_Email__c);
                     toAddresses.add(spDistr[0].Secondary_Email__c);
                    if(ownerEmail != null)
                   	 toAddresses.add(ownerEmail); // Owner Email
                    if(spDistr != null && spDistr.size() > 0 && spDistr[0].Primary_Email__c != null && spDistr[0].Secondary_Email__c!=null ){
                     List <Contact> con =  [select id from contact limit 1];
                     EmailTemplate et=[Select id from EmailTemplate where name = 'Prevetting completed 48hours' limit 1];
                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     mail.setToAddresses(toAddresses);
                     mail.setWhatId(ApexPages.currentPage().getParameters().get('id'));
                     mail.setTreatTargetObjectAsRecipient(false);
                     mail.setTargetObjectid(con[0].id);
                     mail.setTemplateId(et.id);
                     mail.setSaveAsActivity(false);
                     Messaging.sendEmail(new Messaging.SingleEmailMessage [] { mail });
                  
                        // This code is added in order to create a completed task record (dummy task) for that PR in order to 
                        // track the emails that are sent to the sponsoring distributor in the activity history for the below story
                        // PAM - Intake # 16423 : Maintain the emails in the activity history for a PR.
                       system.debug('inside the class'+partnerRequest.id);
                        Task tsk = new Task();
                        tsk.Subject= label.subject_of_48_hr_email_sent_to_sposoring_distributor ;                        
                        tsk.Priority='Normal';
                        tsk.Status='Completed';
                        tsk.WhatId=partnerRequest.id;                        
                        insert tsk;                    
                        
                    Partner_Request__c prReuqest=new Partner_Request__c();
                    prReuqest.id=partnerRequest.id;
                    prReuqest.Sponsoring_Distributor_Primary_Email__c=spDistr[0].Primary_Email__c;
                    prReuqest.Sponsoring_Distributor_Secondary_Email__c=spDistr[0].Secondary_Email__c;
                    update prReuqest;

                  }                                        
                } catch (Exception e) {
                    ApexPages.addMessages(e) ; 
                    System.debug(e.getMessage());
                }    
            }
             return PageUtils.redirect('/' + ApexPages.currentPage().getParameters().get('id'));
        }     
}