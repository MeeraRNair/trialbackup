/**
REVISION HISTORY
================
Version     Author      Date              CR#       Description
-------     ------      ----            --------   -----------
1.0         Niveda  28-Mar-2019          6299183   Send FAP Welcome email with translations

**/
 
 
global class FAP_UserUtils {
    
  global static Boolean isCurrentUserSysAdmin(){
        final List<User> users = [
             select id, name 
             from User 
             where id = :UserInfo.getUserId() 
             and profile.name = 'System Administrator']; 
        return (users == null ? false : users.size() > 0);
    }

    global static Boolean isCurrentUserPortalUser(){
        return getCurrentUserPortalAccountID() != null;
    }
    
    global static ID getCurrentUserPortalAccountID(){
        User usr = 
            [select id, ContactId, Contact.AccountId, userrole.name 
            from user 
            where id = :UserInfo.getUserId()];
        return usr.Contact.AccountId;
    }
    
    // Niveda - Invoked by Process Builder - Account Partner Track - Master
    @InvocableMethod(label='Send FAP Welcome Emails' description='Send an email to all Partner Admins once Partner Track is approved for FAP')
    public static void sendEmailToPartnerAdmin(List<Id> listPartnerTrackIds) {   
        system.debug('inside invokable listPartnerTrackIds:' +listPartnerTrackIds); 
        List<User> listUser = new List<User>();
        listUser = getAdminUsersForSetOfTracks(listPartnerTrackIds);         
        
        system.debug('inside invokable listUser:' +listUser);
        if(listUser.size() >0){
            sendEmailToPartnerAdminUtils('FAP_approved_notification_email_', 'en_US', listUser);
        }
    }
    
    // Niveda -To get list of users related to Partner Track
    global static list<User> getAdminUsersForSetOfTracks(List<id> listPartnerTrackIds){
        List<User> listPartnerAdminUser= new List<User>();
        Set<Id> setMastergroupIds = new Set<id>();
        Set<Id> setAdminUsers = new Set<id>();
        List<Contact> listAdminContact = new List<Contact>();
        Map<id, list<User>> mapPartnerTrackIdToListUser = new Map<id, list<User>>();
        List<User> listUser = new List<User>();
        
        //Get all master group account of Track
        for( Partner_Track__c objPartnerTrack : [Select id, Master_Group_Id__c from Partner_Track__c where id in: listPartnerTrackIds]){
            setMastergroupIds.add(objPartnerTrack.Master_Group_Id__c);
        }
        
        //Get all active , admin Partner users related to master group
        if(!setMastergroupIds.isempty()){
            for( Contact objContact : [Select id, Partner_User__c from Contact where Partner_User_Active__c = true and Partner_User_Partner_Admin__c =true and Accountid in:setMastergroupIds]){
                setAdminUsers.add(objContact.Partner_User__c);         
            }
        }
        system.debug('**setAdminUsers:' +setAdminUsers);
        //Create a map of partner track, list of associated admin users 
        if(!setAdminUsers.isempty()){
            for(User u : [Select Id, ContactId, Contact.EligibleTracks__c, Email, LanguageLocaleKey from User where Id IN : setAdminUsers] ){
                if(u.Contact.EligibleTracks__c != null && String.isNotBlank(u.Contact.EligibleTracks__c)){
                    for (id pt: u.Contact.EligibleTracks__c.split(';')){
                        if(listPartnerTrackIds.contains(pt)){
                            listUser.add(u);
                        }
                    } 
                } 
            }
        }
        
        return listUser;
    }
    
    //Niveda - Utility method to query and send template based on user language 
    public static void sendEmailToPartnerAdminUtils(String strTemplateName, String strLanguageCode, List<User> listAdmins){
        Boolean bHasError = false;        
        Messaging.SingleEmailMessage mail = null;
        List<Messaging.SingleEmailMessage> listMail = null;
        EmailTemplate et = null;
        string strtempName = null;
        string strHtmlBody = null;
        string strPlainTextBody = null;
        string strEmailTemplateNamePrefix = strTemplateName;
        string strDefaultEmailLanguageCode = strLanguageCode;
        Set<String> setRelatedEmailTemplate = new Set<String>();
        Map<String, EmailTemplate> mapEmailTemplate= new Map<String, EmailTemplate>();
        
        for(User admin : listAdmins){
            setRelatedEmailTemplate.add((strEmailTemplateNamePrefix + admin.LanguageLocaleKey));
        }
        
        LIST<EmailTemplate> listEmailTemplate = [SELECT DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate 
                                                    WHERE DeveloperName IN :setRelatedEmailTemplate
                                                    OR DeveloperName = :(strEmailTemplateNamePrefix + strDefaultEmailLanguageCode)];
                                                    
        if(listEmailTemplate.isEmpty()) {
            throw new dellUtil.DellException('Email template for specific language not found.');
        }

        for(EmailTemplate email : listEmailTemplate){
            mapEmailTemplate.put(email.DeveloperName, email);
        }
        
        List<OrgWideEmailAddress> listAddresses = [SELECT ID, DisplayName FROM OrgWideEmailAddress WHERE Address =: 'no_reply@dell.com'];
        if((listAddresses != null) && (listAddresses.size() > 0)){  
            OrgWideEmailAddress fromEmail = listAddresses[0];

            for(User admin : listAdmins) {
                if(mapEmailTemplate.get((strEmailTemplateNamePrefix + admin.LanguageLocaleKey)) != null) {            
                    et = mapEmailTemplate.get((strEmailTemplateNamePrefix + admin.LanguageLocaleKey));
                } else {
                    et = mapEmailTemplate.get((strEmailTemplateNamePrefix + strDefaultEmailLanguageCode));
                }
                strHtmlBody = et.HtmlValue;
                strPlainTextBody = et.Body;

                mail = new Messaging.SingleEmailMessage();
                // Ver 1.0
                mail.setOrgWideEmailAddressId(fromEmail.Id);
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(admin.Id);
                mail.setTemplateId(et.id);
                if(listMail == null) {
                    listMail = new List<Messaging.SingleEmailMessage>();
                }
                listMail.add(mail);
            }  
            List<Messaging.SendEmailResult> listSendResult = Messaging.sendEmail(listMail, false);
            /********** Pending for business feedback - as per old FAP 
            if ((listSendResult != null) && (listSendResult.size() > 0)) {
                string strErrorMsg = '';
                for(Messaging.SendEmailResult result : listSendResult) {
                    if(!result.isSuccess()){
                        bHasError = true;
                        List<Messaging.SendEmailError> listErrors = result.getErrors();
                        if((listErrors != null) && (listErrors.size() > 0)){
                            for (Messaging.SendEmailError error : listErrors){
                                strErrorMsg = strErrorMsg + '[' + error.getStatusCode() + ' - ' + error.getMessage() + '] ';
                            }
                        }
                    }
                }
                if(hasError) {
                     
                        Exception__c erec = new Exception__c();
                        erec.Object_type__c = 'Partner User';
                        erec.Operation__c = 'SendEmailToPartnerAdminUtils';
                        erec.Process_Name__c = 'SendEmailToPartnerAdminUtils';
                        erec.Error_Codes__c = 'Send Email Failed';
                        erec.Email__c = 'no_reply@dell.com';
                        erec.Error_Messages__c = errorMsg;
                        insert erec;
                     
                        system.debug('## SendEmailError - ' + errorMsg + ' [Code: FAP_UserUtils | Method: sendEmailToPartnerAdminUtils]');
                    }
            }*/
        }        
        //return bHasError;
    }
 }