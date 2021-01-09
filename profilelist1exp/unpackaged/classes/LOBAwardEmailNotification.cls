/**********************************************************************************************
Author: Devika Pujari

History:
Version Date            Modified By     Description     
-----------------------------------------------------------------------------------------------
1.0     23-Sept-2014     Devika Pujari  CR 10090 - Send Email to Internal Team and Partner User
                                                   with translations.


**********************************************************************************************/
public class LOBAwardEmailNotification {

 List < LOB_Registration__c > lobFinalList = new List < LOB_Registration__c > ();
 Map < String, String > country2EmailMap = new Map < String, String > ();
 Map < Id, User > partnerRep2User = new Map < Id, User > ();
 List < LOB_Registration__c > updateLOBList = new List < LOB_Registration__c > ();

 public void sendEmail(List < Id > lobList, Map < Id, List < AccountTeamMember >> acc2TMMap) {

  Map < Id, Id > lob2ContactMap = new Map < Id, Id > ();
  Map < Id, String > mail2UserMap = new Map < Id, String > ();
  List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();

  Contact dummyContact = [SELECT Id FROM Contact WHERE Email != ''
   AND AccountId != ''
   AND Phone != ''
   AND MobilePhone != ''
   AND Eloqua_ID__c != ''
   LIMIT 1
  ];
  EmailTemplate emailTemplate = [Select Id, Subject, HtmlValue, Body from EmailTemplate where name = : 'Email to GCC When LOB is Partner Approved'];
  EmailTemplate emailTemplate2 = [Select Id, Subject, HtmlValue, Body from EmailTemplate where name = : 'Email to GCC When LOB is Partner Approved Chinese']; //ANAMIKA - creat a new template for chinese
  EmailTemplate emailTemplate3 = [Select Id, Subject, HtmlValue, Body from EmailTemplate where name = : 'Email to GCC When LOB is Partner Approved KO and JA'];
  List < OrgWideEmailAddress > orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox'];

  for (LOB_Registration__c lob: [Select Id, Registered_End_User__r.Account_Country__c, Partner_Sales_Rep_Language__c, Partner_Sales_Rep_Contact__c,
    Registered_End_User__r.Owner.Email, Preferred_GTM_Partner_Account__r.Owner.Email,
    GCC_Ops_email_who_submtd_for_ptnr_aprvl__c, LOB_Name__c, Registered_End_User__r.Name,
    Preferred_GTM_Partner_Account__r.Name, Partner_Sales_Rep_Contact__r.Email
    From LOB_Registration__c where Id IN: lobList
   ]) {
   lobFinalList.add(lob);
   lob2ContactMap.put(lob.Id, lob.Partner_Sales_Rep_Contact__c);
  }

  for (LOB_Mailbox_Administration__c lobMail: [Select Id, Country__c, Country__r.Name, Support_Email__c from LOB_Mailbox_Administration__c
    where Active__c = true
   ]) {
   country2EmailMap.put(lobMail.Country__r.Name, lobMail.Support_Email__c);
  }


  

  /****************************Send Email **********************************/



  for (LOB_Registration__c lob: lobFinalList) {

   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   List < String > ToAddresses = new List < String > ();

   if (lob.GCC_Ops_email_who_submtd_for_ptnr_aprvl__c != null) {
    ToAddresses.add(lob.GCC_Ops_email_who_submtd_for_ptnr_aprvl__c);
   }

   if (lob.Registered_End_User__c != null) {
    ToAddresses.add(lob.Registered_End_User__r.Owner.Email);
   }

   if (lob.Preferred_GTM_Partner_Account__c != null) {
    ToAddresses.add(lob.Preferred_GTM_Partner_Account__r.Owner.Email);
   }

   if (lob.Partner_Sales_Rep_Contact__r.Email != null) {
    ToAddresses.add(lob.Partner_Sales_Rep_Contact__r.Email);
   }

   if (acc2TMMap.containsKey(lob.Registered_End_User__c)) {
    for (AccountTeamMember accTM: acc2TMMap.get(lob.Registered_End_User__c)) {
     if (accTM.User.Email != null && (accTM.TeamMemberRole != 'Partner Development Manager' && accTM.TeamMemberRole != 'Inside Channel Account Manager')) { //anamika-9/8/2015-CR11910-exclude PDM role from end user acc team
      ToAddresses.add(accTM.User.Email);
     }
    }
   }
   
   if (acc2TMMap.containsKey(lob.Preferred_GTM_Partner_Account__c)) {
    for (AccountTeamMember accTM: acc2TMMap.get(lob.Preferred_GTM_Partner_Account__c)) {
     if (accTM.User.Email != null) {
      ToAddresses.add(accTM.User.Email);
     }
    }
   }

   if (lob.Registered_End_User__r.Account_Country__c != null &&
    country2EmailMap.containsKey(lob.Registered_End_User__r.Account_Country__c.toUpperCase())) {
    ToAddresses.add(country2EmailMap.get(lob.Registered_End_User__r.Account_Country__c.toUpperCase()));
   }

   system.debug('***' + ToAddresses+'************'+lob.LOB_Name__c+'****************'+lob.Preferred_GTM_Partner_Account__c);

   mail.setSaveAsActivity(false);
   mail.setToAddresses(ToAddresses);
   System.debug('----------------------Partner_Sales_Rep_Language__c ' + lob.Partner_Sales_Rep_Language__c);
   if (lob.Partner_Sales_Rep_Language__c == 'ja' || lob.Partner_Sales_Rep_Language__c == 'ko') {
    mail.setTemplateId(emailTemplate3.Id);
    system.debug('inside if 1');
   }
   else if (lob.Partner_Sales_Rep_Language__c == 'zh_CN' || lob.Partner_Sales_Rep_Language__c == 'zh_TW') {
    mail.setTemplateId(emailTemplate2.Id);
    system.debug('inside if 2');
   } else {
    mail.setTemplateId(emailTemplate.Id);
    system.debug('inside else');
   }
   mail.setTargetObjectId(dummyContact.Id); //To add merge fields.
   mail.setWhatId(lob.Id);
   mailList.add(mail);
   system.debug('**mail**' + mail2UserMap);
   
  }
  try {
   if (!mailList.isEmpty()) {
    Savepoint sp = Database.setSavepoint();
    Messaging.sendEmail(mailList);
    Database.rollback(sp);
   }

   /********** To exclude Dummy Contact Id ******************************/
   List < Messaging.SingleEmailMessage > lstMsgsToSend = new List < Messaging.SingleEmailMessage > ();
   for (Messaging.SingleEmailMessage email: mailList) {
    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
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
  } catch (exception e) {
   system.debug('****' + e);
  }
 }
}