/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 10496    14.10       19-Nov-2013     Jiji            Batch Class for sending Email for accepted partner created leads
 * 2.0      CR 10742    16.03       02-Jan-2015     Anamika/Ragu    Allow the partner admin or partner company to indicate who receives the notices for “Leads are ready” and who doesn't.
 * 3.0                  Fy-19-08-02 29-June-2018    Rahul Mishra    Code Reduce!
 */

global class Batch_CMAPSendEmailforAccepted implements Database.Batchable<sObject>, Database.Stateful {
    
    public String query; 
    private set<Id> setProcessedUserIds;
    
    public Batch_CMAPSendEmailforAccepted() {
        setProcessedUserIds = new set<Id>();
    }
    
    global database.querylocator start(Database.BatchableContext BC) {
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        try {
            set<Id> setOwnerIds = new set<Id>();
            list<Lead> lstLeadsToUpdate = new list<Lead>();

            for(Lead leadIterator : (list<Lead>)scope) {
                setOwnerIds.add(leadIterator.OwnerId);
                leadIterator.Send_email_for_Accepted_Status__c = false;
                lstLeadsToUpdate.add(leadIterator);
            }

            if(!setOwnerIds.isEmpty()) {
                // v2.0 - Start
                set<Id> setAccountIds = new set<Id>();
                for(User userIterator : [select Contact.AccountId from User where Id in :setOwnerIds and Contact.AccountId != null]) {
                    setAccountIds.add(userIterator.Contact.AccountId);
                }
                
                //Defect 155364: Start
                //for(User userIterator : [select Id from User where Enable_notifications_about_Channel_Leads__c = true and Contact.AccountId in :setAccountIds and Id not in :setOwnerIds]) {
                for(User userIterator : [select Id from User where Enable_notifications_about_Channel_Leads__c = true and Contact.AccountId in :setAccountIds and Id not in :setOwnerIds and isActive = TRUE]) {
                //Defecr 155364: End
                    if(!setProcessedUserIds.contains(userIterator.Id)) {
                        setOwnerIds.add(userIterator.Id);
                    }
                }
                // v2.0 - End

                list<OrgWideEmailAddress> lstOrgWideAddresses = [select Id, DisplayName from OrgWideEmailAddress where Address = 'no_reply@dell.com'];
                if(lstOrgWideAddresses != null && !lstOrgWideAddresses.isEmpty()) {
                    OrgWideEmailAddress orgWideAddress = lstOrgWideAddresses[0];
                    
                    list<EmailTemplate> lstEmailTemplates = [select Id, Name, Subject, Body from EmailTemplate where Name like '%Channel Email for Accepted Leads%'];
                    if(lstEmailTemplates != null && !lstEmailTemplates.isEmpty()) {
                        EmailTemplate mailTemplate = lstEmailTemplates[0];
                        
                        list<Messaging.SingleEmailMessage> lstSingleEmails = new list<Messaging.SingleEmailMessage>();
                        for(User userIterator : [select Id, Name, Email from User where Id in :setOwnerIds]) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setOrgWideEmailAddressId(orgWideAddress.Id);
                            mail.setTargetObjectId(userIterator.Id);
                            mail.setWhatId(userIterator.Id);
                            mail.setTemplateId(mailTemplate.Id);
                            mail.saveAsActivity = false;
                            
                            lstSingleEmails.add(mail);
                        }
                        
                        if(!lstSingleEmails.isEmpty()) {
                            if(Limits.getLimitEmailInvocations() > Limits.getEmailInvocations()) {
                                Messaging.sendEmail(lstSingleEmails);
                                
                                if(!lstLeadsToUpdate.isEmpty()) {
                                    update lstLeadsToUpdate;
                                }
                                
                                // v2.0 - Start (To avoid sending duplicate emails)
                                setProcessedUserIds.addAll(setOwnerIds);
                                // v2.0 - End
                            }
                        }
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug('Exception is' + e);
        }
    }
    
    global void finish(Database.BatchableContext BC) { 
        Integer hoursToBeAdded = Integer.ValueOf(System.label.CMAP_SendAcceptedemailBatch);
        DateTime currentTime = DateTime.now();
        DateTime targetTime = currentTime.addHours(hoursToBeAdded);
        
        String seconds = String.valueOf(targetTime.second());
        String minutes = String.valueOf(targetTime.minute());
        String hours = String.valueOf(targetTime.hour());
        
        String dayOfMonth = String.valueOf(targetTime.day());
        String month = String.valueOf(targetTime.month());
        String dayOfWeek = '?';
        String year = String.valueOf(targetTime.year());
        
        String schTime = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
        System.debug('schTime : ' + schTime);
        
        Batch_CMAPSendEmailforAcceptedScheduler sendEmailforAccepted = new Batch_CMAPSendEmailforAcceptedScheduler();
        System.schedule('Batch_CMAPSendEmailforAcceptedScheduler ' + String.valueof(currentTime), schTime, sendEmailforAccepted);
    }
}