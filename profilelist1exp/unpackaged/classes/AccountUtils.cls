/*
REVISION HISTORY
================
Version     Author          Date            Release#    CR#     Description
-------     ------          ----            --------    ---     -----------
1.0         Sandhya         26-Aug-2012     13.7        7109    Defect fix - Find a Partner - US Auto Approve Email incorrect
2.0         Fenny           23-Oct-2012     13.10       -       Developer script exception from Dell Inc. : accountTrigger : accountTrigger: execution of AfterUpdate caused by: System.NullPointerException: Attempt to de-reference a null object Class.AccountUtils.SendEmailToPartnerAdmin: line 75, column 1 Trigger
3.0         Krishnamoorthi  30-Nov-2012     13.10       7594    Allow for Data Loading on Primary Contact -- Bug fix
4.0         Krishnamoorthi  09-Jan-2013     14.2        7678    PRM - Website auto-populated from Partner Request to Account
5.0         Dipin Raju      17-Dec-2015     16.12       12487   FAP Dell Competency Email to Partner Admins
6.0         Devika          18-Mar-2016     DCS0401     12695   Call "SendEmailToPartnerAdmin" from Process Builder
7.0         Naga            06-Sep-2017  FY18-DCS-1001  14884   Commented line number 121 to 215 (MethodName - SendCompetencyEmailToPartnerAdmin) to stop triggering email when competencies updated.
8.0         Abhinav         18-May-2018  FY19-DCE-0602  15931   Created utility method and moved email logic to SendEmailToPartnerAdminUtils
*/
public class AccountUtils{
    
    public static Boolean ACCOUNT_TRIGGER_CONTEXT = false;
    
    /**** v6.0  ****/
    @InvocableMethod(label='Send FAP Emails' description='Send an email to all Partner Admins once Account is approved for FAP')
    public static void SendEmailToPartnerAdmin(List<Id> accPartnerFinderList) {

        //V8.0 BOF
        SendEmailToPartnerAdminUtils('AccountUtils', 'FAP_approved_notification_email_', 'en_US', accPartnerFinderList, new List<User>(), new PartnerRegistrationDomainDuplicateCheck.PartnerInfo());
    }
    
   //V3.0 changes start
   //To update Account Primary contact field -- this method is called from afterInsertUpdateContactTrigger
    public static void accountUpdate(Set<Id> processedAccountIds, Map<Id, Id> accountToPrimaryContactIdMap, Map<Id, Set<Id>> mapOfAccIdToNonPrimaryContIdSet) {
        
        Set<Id> unknownPrimaryContactAccountIdSet =  new Set<Id>();
        Map<Id, Account> accUpdateMap = new  Map<Id, Account>(); 
        
        if(processedAccountIds.size() > 0){
            for (Account acc : [Select Id, Primary_Contact__c, Primary_Contact__r.Primary_Contact__c FROM Account 
                            WHERE Id IN:processedAccountIds]){
                if(accountToPrimaryContactIdMap.keySet().contains(acc.Id)){
                    if(accountToPrimaryContactIdMap.get(acc.Id) !=acc.Primary_Contact__c){
                        acc.Primary_Contact__c = accountToPrimaryContactIdMap.get(acc.Id);
                        accUpdateMap.put(acc.id, acc);
                    }
                }
                else if(mapOfAccIdToNonPrimaryContIdSet.keySet().contains(acc.Id)){  
                        if(mapOfAccIdToNonPrimaryContIdSet.get(acc.Id).contains(acc.Primary_Contact__c))  {
                            acc.Primary_Contact__c = null;
                            accUpdateMap.put(acc.id, acc);
                        }
                        else{
                            if(acc.Primary_Contact__c!=null && acc.Primary_Contact__r.Primary_Contact__c ==false){
                                acc.Primary_Contact__c = null;
                                accUpdateMap.put(acc.id, acc);
                                unknownPrimaryContactAccountIdSet.add(acc.Id);
                            }
                        }       
            }
        }
        
        if(unknownPrimaryContactAccountIdSet.size() > 0 ){
        processedAccountIds.clear();//reusing existing variable
        for(Contact con : [Select ID, AccountId, Primary_Contact__c FROM Contact 
                           WHERE AccountId IN :unknownPrimaryContactAccountIdSet 
                           AND Primary_Contact__c = True]){         
            if(!processedAccountIds.contains(con.AccountId)){
                accUpdateMap.get(con.AccountId).Primary_Contact__c = con.Id;
                processedAccountIds.add(con.AccountId);
            }
        }
    }
        if(accUpdateMap.size() >0){
            try{
                database.update(accUpdateMap.values(), false);
            }catch(Exception e){
                e.getMessage();
            }
        
        }
    }
    
    }
    
    //To update Contact -- this method is called from accountTrigger
    public static void contactUpdate(Set<Id> primaryContIds, Set<Id> processedAcctIds) {
        
        List<Contact> updContactList = new List<Contact>();
        
        for(Contact c: [select Id, Primary_Contact__c, AccountId from Contact where
                                    AccountId IN: processedAcctIds AND ((Id IN:primaryContIds AND Primary_Contact__c=false) OR (Primary_Contact__c=true AND Id NOT IN:primaryContIds))]){   
                                                                
            if(primaryContIds.contains(c.Id)){
                c.Primary_Contact__c = true;
            } else {
                c.Primary_Contact__c = false;   
            }   
            updContactList.add(c);
                                
        }
        
        if(updContactList.size() > 0){
            try{
                database.update(updContactList, false);
            }
            catch(Exception e){
                e.getMessage();
            }
        }
    
    }//V3.0 changes End
    
    //V4.0 changes Starts
    //To update Account's Website field -- this method is called from afterInsertUpdateLeadTrigger
    
       
    public static void updateAccntWebsite(Set<Id> accntIds, Map<Id, string> accntWebsiteMap){
        
        List<Account> updAccountList = new List<Account>();
        
        for(Account a : [select Id, Website from Account where Id IN: accntIds AND Website = null]) {
            
                a.Website = accntWebsiteMap.get(a.Id);
                updAccountList.add(a);
            
        }
        
                
        if(updAccountList.size() > 0) {
            try{
                GlobalVariables.BYPASS_FUTURE_CALLS = true;
                
                database.update(updAccountList, false);
                
                GlobalVariables.BYPASS_FUTURE_CALLS = false;
            }
            catch(Exception e){
                e.getMessage();
            }
        }
    }//V4.0 changes End
    
    //Subramanyam M, CR11393
    public static void updateAccnttrac(Set<Id> accntIds, Map<Id, Lead> accnttracMap){
        
        List<Account> updAccountList = new List<Account>();
        
        for(Account a : [select Id, Trac_Number__c,Risk_Level__c,TRAC_Date__c from Account where Id IN: accntIds]) {
            
                a.TRAC_Number__c = (accnttracMap.get(a.Id)).TRAC_Number__c;
                a.TRAC_Date__c = (accnttracMap.get(a.Id)).TRAC_Date__c ;
                a.Risk_Level__c = (accnttracMap.get(a.Id)).Risk_Level__c;
                updAccountList.add(a);
            
        }
        
        
          if(updAccountList.size() > 0) {
            try{
                GlobalVariables.BYPASS_FUTURE_CALLS = true;
                
                database.update(updAccountList, false);
                
                GlobalVariables.BYPASS_FUTURE_CALLS = false;
            }
            catch(Exception e){
                e.getMessage();
            }
        }
    }
    
    //V8.0 BOF - Utility method to send email to partner admin
    public static Boolean SendEmailToPartnerAdminUtils(String clsName, String tplPrefix, String langCode, List<Id> accPartnerFinderList, List<User> admins, PartnerRegistrationDomainDuplicateCheck.PartnerInfo info) {
        Boolean hasError = false;
        if(admins == null) {
            admins = new List<User>();
        }
        
        if(clsName == 'PartnerRegistrationDomainDuplicateCheck') {
        } else {
            List<Id> contactList = new List<Id>();
            for(Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accPartnerFinderList]){
                contactList.add(con.Id);
            }
            admins = [SELECT Email, LanguageLocaleKey, ContactId FROM User WHERE ContactId IN :contactList AND Enable_Partner_Admin__c = TRUE];
        }

        if(admins.size() > 0) {
            Messaging.SingleEmailMessage mail = null;
            List<Messaging.SingleEmailMessage> mailList = null;
            EmailTemplate et = null;
            string templateName = null;
            string htmlBody = null;
            string plainTextBody = null;
            string emailTemplateNamePrefix = tplPrefix;
            string defaultEmailLanguageCode = langCode;
            Set<String> relatedEmailTemplate = new Set<String>();
            Map<String, EmailTemplate> emailTemplateMap= new Map<String, EmailTemplate>();
            
            for(User admin : admins){
                    relatedEmailTemplate.add((emailTemplateNamePrefix + admin.LanguageLocaleKey));
            }
            
            LIST<EmailTemplate> emailTemplateList = [SELECT DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate 
                                                        WHERE DeveloperName IN :relatedEmailTemplate
                                                        OR DeveloperName = :(emailTemplateNamePrefix + defaultEmailLanguageCode)];
                                                        
            if(emailTemplateList.isEmpty()){
                throw new dellUtil.DellException('Email template for specific language not found.');
            }

            for(EmailTemplate email : emailTemplateList){
                emailTemplateMap.put(email.DeveloperName, email);
            }
            
            List<OrgWideEmailAddress> addresses = [SELECT ID, DisplayName FROM OrgWideEmailAddress WHERE Address =: 'no_reply@dell.com'];
            if((addresses != null) && (addresses.size() > 0)){
                OrgWideEmailAddress fromEmail = addresses[0];

                for(User admin : admins) {
                    if(emailTemplateMap.get((emailTemplateNamePrefix + admin.LanguageLocaleKey)) != null) {            
                        et = emailTemplateMap.get((emailTemplateNamePrefix + admin.LanguageLocaleKey));
                    } else {
                        et = emailTemplateMap.get((emailTemplateNamePrefix + defaultEmailLanguageCode));
                    }
                    htmlBody = et.HtmlValue;
                    plainTextBody = et.Body;

                    mail = new Messaging.SingleEmailMessage();
                    // Ver 1.0
                    mail.setOrgWideEmailAddressId(fromEmail.Id);

                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(admin.Id);
                    
                    if(clsName == 'BatchFAPAnualReminder2PartnerAdmins') {
                        mail.setSubject(et.Subject);
                        mail.setPlainTextBody(plainTextBody);
                        mail.setHtmlBody(htmlBody);
                    } else if(clsName == 'PartnerRegistrationDomainDuplicateCheck') {
                        //mail.setSenderDisplayName('Partner Direct Admin');
                        mail.setSubject(et.Subject);
                        htmlBody = htmlBody.replace('#FIRSTNAME#', (info.Firstname == null ? '' : info.Firstname));
                        htmlBody = htmlBody.replace('#LASTNAME#', (info.Lastname == null ? '' : info.Lastname));
                        htmlBody = htmlBody.replace('#PHONE_NUMBER#', (info.PhoneNumber == null ? '' : info.PhoneNumber));
                        htmlBody = htmlBody.replace('#MOBILE_PHONE#', (info.MobilePhone == null ? '' : info.MobilePhone));
                        htmlBody = htmlBody.replace('#EMAIL#', (info.Email == null ? '' : info.Email));
                        htmlBody = htmlBody.replace('#REGISTERING_COUNTRY#', (info.RegisteringCountry == null ? '' : info.RegisteringCountry));
                        htmlBody = htmlBody.replace('#COMMENT#', (info.Comment == null ? '' : info.Comment.replace('\n', '<br/>')));
                        htmlBody = htmlBody.replace('#PARTNER_TRACK#', (info.partnerTrack == null ? '' : info.partnerTrack));
                        
                        plainTextBody = plainTextBody.replace('#FIRSTNAME#', (info.Firstname == null ? '' : info.Firstname));
                        plainTextBody = plainTextBody.replace('#LASTNAME#', (info.Lastname == null ? '' : info.Lastname));
                        plainTextBody = plainTextBody.replace('#PHONE_NUMBER#', (info.PhoneNumber == null ? '' : info.PhoneNumber));
                        plainTextBody = plainTextBody.replace('#MOBILE_PHONE#', (info.MobilePhone == null ? '' : info.MobilePhone));
                        plainTextBody = plainTextBody.replace('#EMAIL#', (info.Email == null ? '' : info.Email));
                        plainTextBody = plainTextBody.replace('#REGISTERING_COUNTRY#', (info.RegisteringCountry == null ? '' : info.RegisteringCountry));
                        plainTextBody = plainTextBody.replace('#COMMENT#', (info.Comment == null ? '' : info.Comment));
                        plainTextBody = plainTextBody.replace('#PARTNER_TRACK#', (info.partnerTrack == null ? '' : info.partnerTrack));

                        mail.setHtmlBody(htmlBody);
                        mail.setPlainTextBody(plainTextBody);
                    } else {
                        mail.setTemplateId(et.id);
                    }

                    if(mailList == null) {
                        mailList = new List<Messaging.SingleEmailMessage>();
                    }
                    mailList.add(mail);
                }
               
                List<Messaging.SendEmailResult> sendResult = Messaging.sendEmail(mailList, false);
                if ((sendResult != null) && (sendResult.size() > 0)) {
                    string errorMsg = '';
                    for(Messaging.SendEmailResult result : sendResult) {
                        if(!result.isSuccess()){
                            hasError = true;
                            List<Messaging.SendEmailError> errors = result.getErrors();
                            if((errors != null) && (errors.size() > 0)){
                                for (Messaging.SendEmailError error : errors){
                                    errorMsg = errorMsg + '[' + error.getStatusCode() + ' - ' + error.getMessage() + '] ';
                                }
                            }
                        }
                    }
                    if(hasError) {
                        /********** Pending for business feedback
                        Exception__c erec = new Exception__c();
                        erec.Object_type__c = 'Partner User';
                        erec.Operation__c = 'SendEmailToPartnerAdminUtils';
                        erec.Process_Name__c = 'SendEmailToPartnerAdminUtils';
                        erec.Error_Codes__c = 'Send Email Failed';
                        erec.Email__c = 'no_reply@dell.com';
                        erec.Error_Messages__c = errorMsg;
                        //insert erec;
                        **********/
                        system.debug('## SendEmailError - ' + errorMsg + ' [Code: AccountUtils | Method: SendEmailToPartnerAdminUtils]');
                    }
                }
            }
        }
        return hasError;
    }
    //V8.0 EOF - Utility method to send email to partner admin
}