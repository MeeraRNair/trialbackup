/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0                                 
*/    

public class OrderSupportEmailNotifications{
    
    public static boolean isTest = false;
    
    @InvocableMethod(label='Order Support Email Notifications' 
                     description='')
    public static void CaseCreatedNotification(List<Id> CaseIds){
        System.debug('generateNotification Start');
        System.debug('CaseIds : '+caseIds);
        Map<String, Mailing_Country__c> mailBoxes = Mailing_Country__c.getAll();
        String mailbox = '';
       
            List<Case> caseObjs = [Select Country_Order_Support__c,id,contact.id, RecordType.name, status,Unauthenticated_Case__c from Case where id in :CaseIds];             
            EmailTemplate templateId = [Select id from EmailTemplate where name = :Label.Order_Support_Country_Mailbox_Template];
            System.debug('caseObjs : '+caseObjs);
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            List<OrgWideEmailAddress> emailList= [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address =: label.Order_Support_NoReply_EmailId];
            String orgWideEmailId = null;
            if(emailList.size() > 0) {
                orgWideEmailId = emailList.get(0).id;
            }
            for(Case obj : caseObjs) {
                If(Test.isRunningTest()){
                    mailbox = UserInfo.getUserEmail();
                }
                else{
                    if(obj.Unauthenticated_Case__c!= true){
                        if( mailBoxes.get(obj.Country_Order_Support__c.toLowerCase()) != null){
                        mailbox = mailBoxes.get(obj.Country_Order_Support__c.toLowerCase()).Generic_Mailbox__c;
                        } 
                    }      
                }   
                System.debug('mailbox : '+mailbox);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(orgWideEmailId != null)
                    mail.setOrgWideEmailAddressId(orgWideEmailId );
               
                mail.setTemplateID(templateId.Id); 
                mail.setTargetObjectId(obj.Contact.id);
                mail.setWhatId(obj.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new String[] {mailbox});
                allmsg.add(mail);
        }
                System.debug('all msg : '+allmsg);              
                Messaging.sendEmail(allmsg,false);
                System.debug('generateNotification End');
 
       
    }      
}