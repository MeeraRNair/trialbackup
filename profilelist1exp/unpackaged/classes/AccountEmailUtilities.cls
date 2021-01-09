/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to sending emails based on the Account updates. 
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10751     16.03       19-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 * 
 */

public class AccountEmailUtilities {

//this class is sending emails to Partner Admins in some cases because its running in recursive mode
//to stop that Recurssion we are using this Boolean

    public Static Boolean isEmailSent = false;
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0                                                                 Send email to partner admin users whenever Partner_Relationship__c on an Account is changed to Preferred / Premier.
    2.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from afterInsertUpdatePartnerStatus trigger and optimized as part of trigger redesign.
    */
    public static void sendEmailToPartnerAdminUsers(map<Id, Account> mapAccountsForCertificationProcess, map<Id, Account> mapNewAccounts, map<Id, Account> mapOldAccounts) {
        Id partnerRTId = System.Label.RecType_Partner_Account;
        map<Id, String> mapAccountIdCountryCode = new map<Id, String>();
        for(Account accIterator : mapAccountsForCertificationProcess.values()) {
          //  if(accIterator.RecordTypeId == partnerRTId && accIterator.IsPartner == true
            //    && (accIterator.Partner_Relationship__c == 'Premier' || accIterator.Partner_Relationship__c == 'Preferred'))
               System.debug('Account Email utilities'); 
            if(accIterator.RecordTypeId == partnerRTId && accIterator.IsPartner == true  
                && (PartnerStatusUtilityClass.PremierTypeContains(accIterator.Partner_Relationship__c) || PartnerStatusUtilityClass.PreferredTypeContains(accIterator.Partner_Relationship__c)))
                  {
                  System.debug('>>>> inside if');
                mapAccountIdCountryCode.put(accIterator.Id, accIterator.Account_Country_Code__c);
            }
        }
        
        if(!mapAccountIdCountryCode.isEmpty()) {
            map<String, String> mapCountryRegion = new map<String, String>();
            for(Country__c region : [select Id, Code__c, Region__c from Country__c where Code__c in :mapAccountIdCountryCode.values()]) {
                if(region.Code__c == 'US') {
                    mapCountryRegion.put(region.Code__c, 'US');
                }
                else if(region.Code__c == 'CA') {
                    mapCountryRegion.put(region.Code__c, 'Canada');
                }
                else {
                    mapCountryRegion.put(region.Code__c, region.Region__c);    
                }
            }
            
            if(!mapCountryRegion.isEmpty()) {
            System.debug('Country Region is Not Empty');
                // ??? Below query is not used - Not sure why. Clarify whether to make use of this logic intended for?
                list<Certification_Process_Setup__c> mailProcessList = [select Id, Region__c, Send_Email_to_Partner_Admin__c from Certification_Process_Setup__c 
                                                                        where Region__c in :mapCountryRegion.values() and Send_Email_to_Partner_Admin__c = true];
                
                if(!mailProcessList.isEmpty()) {
                 System.debug('Mail process list is not Empty');
                    list<User> lstPartnerAdminUsers = [select Id, Email, LanguageLocaleKey, ContactId, Contact.AccountId from User where Contact.AccountId in :mapAccountIdCountryCode.keySet() and Enable_Partner_Admin__c = true];  
                    
                    if(lstPartnerAdminUsers != null && !lstPartnerAdminUsers.isEmpty()) {
                        String strEmailTemplatePrefix = 'NetExam_Partner_Admin_Notification_email_';
                        String strDefaultLanguageCode = 'en_US';
                        
                        set<String> setEmailTemplateNames = new set<String>{strEmailTemplatePrefix + strDefaultLanguageCode};
                        for(User userIterator : lstPartnerAdminUsers) {
                            setEmailTemplateNames.add(strEmailTemplatePrefix + userIterator.LanguageLocaleKey);
                        }
                        
                        map<String, EmailTemplate> mapEmailTemplates = new map<String, EmailTemplate>();
                        for(EmailTemplate templateIterator : [select Id, DeveloperName, Subject, Body, HTMLValue from EmailTemplate where DeveloperName in :setEmailTemplateNames]) {
                            mapEmailTemplates.put(templateIterator.DeveloperName, templateIterator);
                        }
                        
                        list<Messaging.SingleEmailMessage> lstSingleEmails = new list<Messaging.SingleEmailMessage>();
                        for(User userIterator : lstPartnerAdminUsers) {
                            EmailTemplate mailTemplate;
                            if(mapEmailTemplates.get(strEmailTemplatePrefix + userIterator.LanguageLocaleKey) != null) {
                                mailTemplate = mapEmailTemplates.get(strEmailTemplatePrefix + userIterator.LanguageLocaleKey);
                            }
                            else {
                                mailTemplate = mapEmailTemplates.get(strEmailTemplatePrefix + strDefaultLanguageCode);
                            }
                                                               
                            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                            singleEmail.setSenderDisplayName('no_reply@dell.com');
                            singleEmail.setReplyTo('no_reply@dell.com');
                            singleEmail.setSaveAsActivity(false);
                            singleEmail.setTargetObjectId(userIterator.ContactId);
                            singleEmail.setWhatId(userIterator.Contact.AccountId);
                            singleEmail.setTemplateid(mailTemplate.Id); 
                            System.debug('userIterator.ContactId '+userIterator.ContactId);
                            System.debug('is Before '+trigger.isBefore);
                            System.debug('is After '+trigger.isAfter);
                            lstSingleEmails.add(singleEmail);
                        }
                        System.debug(' lstSingleEmails' +lstSingleEmails.size());
                        System.debug('lstSingleEmails '+lstSingleEmails);
                        System.debug('isEmailSent  '+isEmailSent );
                        if(!isEmailSent ){
                        isEmailSent = true;
                       list<Messaging.SendEmailResult> sendResult = Messaging.sendEmail(lstSingleEmails, false);
                        if(sendResult != null && !sendResult.isEmpty()) {
                            Boolean bHasError = false;
                            String strErrorMessage = '';
                            for(Messaging.SendEmailResult result : sendResult) {
                                if(!result.isSuccess()) {
                                    bHasError = true;
                                    list<Messaging.SendEmailError> lstErrors = result.getErrors();
                                    if(lstErrors != null && !lstErrors.isEmpty()) {
                                        for(Messaging.SendEmailError error : lstErrors) {
                                            strErrorMessage = strErrorMessage + '[' + error.getStatusCode() + ' - ' + error.getMessage() + '] ';
                                        }
                                    }
                                }
                            }
                            if(bHasError) {
                                system.debug('## SendEmailError - ' + strErrorMessage + ' [Trigger: AccountTriggerHandler.sendEmail()]');
                            }
                        }
                        }//end of if
                    }
                }
            }
        }
    }

}