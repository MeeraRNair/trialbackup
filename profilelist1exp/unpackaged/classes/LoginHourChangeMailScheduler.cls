/*
 * Author : Devika Pujari 
 * Date   : 30/05/2016
 * Purpose: Scheduler Class to send emails to Sys Admin/L3 Support team everytime the login hours of a profile is changed by any user.
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 *
*/ 
global class LoginHourChangeMailScheduler implements Schedulable{

    global static void execute(SchedulableContext sc){
        try{
            if([Select Count() From SetupAuditTrail Where CreatedDate = YESTERDAY AND
                                             Action LIKE '%profileLoginHoursChanged%'] > 0){
                sendReportingEmail();
            }
        }
        catch(exception e){
            system.debug('************* Exception: '+e);
        }
    }
    
    public static void sendReportingEmail() {    
        sendTextEmail(System.Label.LoginHoursEmailTemplateId);        
    }
    
    private static List<String> getEmailRecipient(){
  
      String recipient = System.Label.LoginHourReporterRecepients;      
      //String recipient ='devika_pujari@dell.com,bikram_dutta@dell.com,mohammad_ghouse@dell.com';
      String[] recipientList = recipient.split(',');      
      System.debug('###Recipient: ' + recipientList);      
      return recipientList ;
      
    }
    public static void sendTextEmail(String templateId) { 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setTemplateId(templateId); 
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setToAddresses(getEmailRecipient());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}