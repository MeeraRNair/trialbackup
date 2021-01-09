/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 8586                 18-Aug-2013     Sandhya         Partner receives a daily summary email once lead assigned to Partner - same day, 2day and 5 day   
 * 2.0                              27-Sep-2013     Annie           SIT Defect 81473/81515
 * 3.0                              09-Oct-2013     Meera           UAT Defect 82995
 * 4.0      CR 10789,10801,10803    15-Dec-2014     Anu             DSG CMAP Change - Editing to send separate notifications of DSG Leads   
 * 4.1      CR 10742    16.03       02-Jan-2015     Anamika/Ragu    Allow the partner admin or partner company to indicate who receives the notices for “Leads are ready” and who doesn't.
 * 5.0      Sprint 17               13-Sep-2016     Shivam          Made changes to code since it was sending multiple email to CMAP Users.
 * 6.0      CR 15057                21-Nov-2017     Ismail          User Story 3963561: Fix "Enable notifications about Channel Leads" feature for Partner users
 * 7.0      CR 16091                26-June-2018    Pallavi         Removed comments and other commented method as part of code Reduce for the story 5101935
 * 8.0      CR 17112                20-Mar-2019     Shue            Defect 6370550: SDET - Wunderkind:: CAMP:: FY20-0402:: Regression:: Partner user is not receiving 2 Day and 5 Day mail notifications
 */
 
global class CMAP_PartnerDailySummaryBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query,type;
    public static boolean isApexTest = false;
    
    // To avoid sending duplicate emails to the users because of the batch splits
    global set<Id> setProcessedCMAPUserIds;
   
    
    public CMAP_PartnerDailySummaryBatch() {
        setProcessedCMAPUserIds = new set<Id>();
     
    }
    
    global database.queryLocator start(Database.BatchableContext BC) {
        if(type == null) {
            type = 'today';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        try { 
                                    
            set<Id> setCMAPUserIds = new set<Id>(); // v4.0
            Set<Id> setCMAPUserIdSet = new Set<Id>(); // v6.0
          
            
            Id dsgLeadRTId = StaticFactory.getRecordTypeIdByName('Lead', 'DSG Partner');
            
            for(Lead leadIterator : (list<Lead>)scope) {
               
                // v4.0 Sending separate emails for DSG starts
                if(leadIterator.Partner_User__c != null && leadIterator.Partner_User__r.Enable_notifications_about_Channel_Leads__c == true) {
                
                        setCMAPUserIdSet.add(leadIterator.Partner_User__c); // v6.0
                        
                }
                // v4.0 Sending separate emails for DSG ends
            }
            // v6.0 Start
            Map<Id, User> userMap = new   Map<Id, User>([SELECT Id FROM User WHERE  Id IN :setCMAPUserIdSet AND Enable_notifications_about_Channel_Leads__c = true]);
            setCMAPUserIds = type == 'today' ? setCMAPUserIdSet : userMap.keySet();
            // v6.0 End
                
            list<Messaging.SingleEmailMessage> lstSingleEmails = new list<Messaging.SingleEmailMessage>();
            
            // Process CMAP Users
            setCMAPUserIds.removeAll(setProcessedCMAPUserIds);
          
            if(!setCMAPUserIds.isEmpty()) {
                // v4.1 - Start
                
                if(type == 'today') {
                    set<Id> setAccountIds = new set<Id>();
                    for(User userIterator : [select Contact.AccountId from User where Id in :setCMAPUserIds and Contact.AccountId != null]) {
                        setAccountIds.add(userIterator.Contact.AccountId);
                    }
                    // Defect 155364: Start
                    
                    for(User userIterator : [select Id from User where Enable_notifications_about_Channel_Leads__c = true and Contact.AccountId in :setAccountIds and Id in :setCMAPUserIds and IsActive = true]) {
                    // Defecr 155364: End
                    
                        if(!setProcessedCMAPUserIds.contains(userIterator.Id)) {
                            setCMAPUserIds.add(userIterator.Id);
                        }
                    }
                 
                    setCMAPUserIds.removeAll(setProcessedCMAPUserIds);
                }
                // v4.1 - End
                
                list<Messaging.SingleEmailMessage> lstEmails = prepareDailySummaryMail(type, setCMAPUserIds, false);
                
                if(lstEmails != null && !lstEmails.isEmpty()) {
                    lstSingleEmails.addAll(lstEmails);
                    setProcessedCMAPUserIds.addAll(setCMAPUserIds);
                }
            }
                
            // Send today, 2day, 5day emails
            if(!lstSingleEmails.isEmpty()) {
                Messaging.sendEmail(lstSingleEmails);
            }   
        }
        catch(Exception e) {
            System.debug('Exception occured in CMAP_PartnerDailySummaryBatch: ' + e);
        }
    }
    
    // v4.0 adding one more parameter(isDSG) to identify CMAP & DSG and updating the set Id
    public list<Messaging.SingleEmailMessage> prepareDailySummaryMail(String strType, set<Id> setUserIds, boolean isDSG) {

        list<OrgWideEmailAddress> lstOrgWideAddresses = [select Id, DisplayName from OrgWideEmailAddress where Address = 'no_reply@dell.com'];        
        if(lstOrgWideAddresses != null && !lstOrgWideAddresses.isEmpty()) {
            OrgWideEmailAddress orgWideAddress = lstOrgWideAddresses[0];
            
            list<EmailTemplate> lstEmailTemplates = new list<EmailTemplate>();
            
                // Select email template for notifying CMAP Users
                if(strType == 'today') {
                    lstEmailTemplates = [select Id, Name, Body, Subject,Markup,HtmlValue from EmailTemplate where Name = 'CMAP Lead Acceptance Notification SameDay'];            
                }
                else if(strType == 'twoDay') {
                    lstEmailTemplates = [select Id, Name, Subject, Body,Markup,HtmlValue from EmailTemplate where Name = 'CMAP_Lead Acceptance Notification_TwoDays'];            
                }
                else if(strType == 'fiveDay') {
                    lstEmailTemplates = [select Id, Name, Subject, Body,Markup,HtmlValue from EmailTemplate where Name = 'CMAP_Lead Acceptance Notification_FiveDays'];            
                }
           
            if(lstEmailTemplates != null && !lstEmailTemplates.isEmpty()) {
                EmailTemplate mailTemplate = lstEmailTemplates[0];
                // v2.0 - Start
                
                list<Messaging.SingleEmailMessage> lstEmails = new list<Messaging.SingleEmailMessage>();
                // v2.0 - End
                for(Id userId : setUserIds) { // v4
                   
                        // v5.0 starts
                                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setOrgWideEmailAddressId(orgWideAddress.Id);
                            mail.setTemplateId(mailTemplate.Id);
                            mail.setSaveAsActivity(false);                    
                            
                            mail.setTargetObjectId(userId);
                            lstEmails.add(mail);
                       
                       // v5.0 ends
                           
                }
               
                return lstEmails;
            }
        }
       
        return null;
    }
    
    global void finish(Database.BatchableContext BC) {
        Integer scheduleTime = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_Time);
        Integer hourRange = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_HourRange);
               
        if(type == 'today' || type == 'twoDay') {
            Date currentDate;
            CMAP_PartnerDailySummaryBatch reassignDailySummaryBatch = new CMAP_PartnerDailySummaryBatch();
            
            if(type == 'today') {
                currentDate = System.today().addDays(-2);
                reassignDailySummaryBatch.type = 'twoDay';
            }
            else if(type == 'twoDay') {
                currentDate = System.today().addDays(-5);
                reassignDailySummaryBatch.type = 'fiveDay';
            }
            
            Integer queryTime = scheduleTime - 8;
            DateTime cdtTime10 = Datetime.newInstance(currentDate, Time.newInstance(queryTime, 0, 0, 0)); // 10PM CDT
            String cdtTime10_formatedDt = cdtTime10.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            
            Datetime cdtMinus24 = cdtTime10.addHours(-hourRange);
            String cdtMinus24_formatedDt = cdtMinus24.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            
            // v4.1 - Start
            // Please use v8.0
            //reassignDailySummaryBatch.query = 'Select Id, RecordTypeId, Lead_Assigned_Date__c, Partner_User__c From Lead Where Status = \'Assigned to Channel partner\' and Lead_Assigned_Date__c >= ' + cdtMinus24_formatedDt + ' and Lead_Assigned_Date__c <= ' + cdtTime10_formatedDt + ' order by Partner_User__c';
            //8.0 Start
            reassignDailySummaryBatch.query = 'Select Id, RecordTypeId, Lead_Assigned_Date__c, Partner_User__c, Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' and Lead_Assigned_Date__c >= ' + cdtMinus24_formatedDt + ' and Lead_Assigned_Date__c <= ' + cdtTime10_formatedDt + ' order by Partner_User__c';
            //8.0 End
            // v4.1 - End
            if(!Test.isRunningTest()) {
                Id batchProcessId = Database.executeBatch(reassignDailySummaryBatch);
            }
   
        }
        else if(type == 'fiveDay') {
            // v3.0 Start
            DateTime currentTime = System.now();
            DateTime nextDay = currentTime.addDays(1); // Uncomment after testing
            String dayOfMonth = string.valueOf(nextDay.day());
            String month  =  string.valueOf(nextDay.month());
            String year = string.valueOf(nextDay.year());  
            String schTime = '0 0 ' + scheduleTime + ' ' + dayOfMonth + ' ' + month + ' ? ' + year;
            
            // v3.0 End
            if(!Test.isRunningTest()) {
                System.schedule('CMAP_PartnerDailySummaryBatch ' + String.valueOf(DateTime.now()), schTime, new CMAP_PartnerDailySummaryScheduler());
            }
        }   
    }   
}