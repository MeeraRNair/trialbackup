/*
Description: Utility class to allow for emails to be sent.

Version: 2.0

Author: Caleb Sidel/Christophe Pebre/Albert Lou/Krishnaprasad P

History:
1.0 - 20-Aug-2008: Creation, to be released in 9.9. This code is being refactored from the dellUtil class.
2.0 - 09-Sep-2008: Added method for sending Mass Email
3.0 - 2-Mar-2015: Added code to avoid hitting Email Invocations limit 10

*/

public class emailUtils {
    
    public static void sendSupportEmail(String s, String recipient) { 
        // Create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        
        if(!(Environment.isSandbox() && recipient.contains('sfdc_integration'))){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Strings to hold the email addresses to which you are sending the email.
            String[] toAddresses = new String[] {recipient};
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
            // Specify the address used when the recipients reply to the email.
            mail.setReplyTo(recipient);
            // Specify the name used as the display name.
            mail.setSenderDisplayName('Salesforce Support');
            // Specify the subject line for your email address.
            mail.setSubject('Apex issue');
            // Set to True if you want to BCC yourself on the email.
            mail.setBccSender(false);
            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);
            // Specify the text content of the email.
            mail.setPlainTextBody('Problem: ' + s);
            // Specify the html version of the content as well.
            mail.setHtmlBody('Problem: ' + s);
            // Send the email you have created.
            if(Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){ // 3.0
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
        
    }
    
    //CR 3301
    public static void sendSupportEmail(String s) {                         
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Strings to hold the email addresses to which you are sending the email.
        String recipient='';
        s= 'User :'+ UserInfo.getUserName()+ '('+UserInfo.getUserId() +') \n' + s;
        if(UserInfo.getUserId() == '005A0000000ac3yIAA'){
            recipient = System.Label.Informatica_Integration_Error_mailbox;         
        } 
        if(!StringUtils.defaultString(recipient).contains('@dell.com')){
            recipient = Dellconfig.errorEmail;
        }
        
        String[] toAddresses = new String[] {recipient};
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        
        String[] ccAddresses;
        String cc = System.Label.Error_mailbox_for_Debugging;
        if(StringUtils.defaultString(cc).contains('@dell.com')){
            ccAddresses = new String[] {cc};
            mail.setCcAddresses(ccAddresses);
        }      
        
        // Specify the address used when the recipients reply to the email.
        mail.setReplyTo(recipient);
        // Specify the name used as the display name.
        mail.setSenderDisplayName('Salesforce Support');
        // Specify the subject line for your email address.
        mail.setSubject('Apex issue - Org Id: ' +Userinfo.getOrganizationId());
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        // Specify the text content of the email.
        mail.setPlainTextBody(''+s);
        // Specify the html version of the content as well.
        mail.setHtmlBody(''+ s);
        // Send the email you have created.
        if(Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){ // 3.0
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public static void sendSupportEmails(String s, String[] recipients) { 
        // Create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = recipients;
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        // Specify the address used when the recipients reply to the email.
        mail.setReplyTo(recipients[0]);
        // Specify the name used as the display name.
        mail.setSenderDisplayName('Salesforce Support');
        // Specify the subject line for your email address.
        mail.setSubject('Apex issue');
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        // Specify the text content of the email.
        mail.setPlainTextBody('Problem: ' + s);
        // Specify the html version of the content as well.
        mail.setHtmlBody('Problem: ' + s);
        // Send the email you have created.
        if(Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){ // 3.0
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public static void sendTextEmail(List<String> recipients,String emailSubject,String textBody) { 
        // Create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
        //the email is not saved as an activity.
        mail.setSaveAsActivity(false);
        // Assign the addresses for the To lists to the mail object.
        mail.setToAddresses(recipients);          
        // Specify the subject line for your email address.
        mail.setSubject(emailSubject);
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        // Specify the text content of the email.
        mail.setPlainTextBody(textBody);  
        // Send the email you have created.
        if(Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){ // 3.0
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
}