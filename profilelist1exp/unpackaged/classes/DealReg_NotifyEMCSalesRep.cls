/***************************************************************************************************************************************************************
* 
* Name          : DealReg_NotifyEMCSalesRep
  Description   : Called from casetriggerhandler(after update)
* ---------------------------------------------------------------------------------------
* Revision  Name            Date                 CR#                          Description
* 1.0       Yeswanth      01.12.2016           13759              Implemented logic to trigger emails to EMC Sales Rep populated on case record      
***************************************************************************************************************************************************************/

public class DealReg_NotifyEMCSalesRep {
    
   Public Static Void sendEmailToEMCSalesRepOnUpdate(list<Case> listNewCases, map<Id, Case> mapOldCases){
        Id emcRtId = StaticFactory.getRecordTypeIdByName('Case', 'EMC DR');
        List<Messaging.SingleEmailMessage> listmails =  new List<Messaging.SingleEmailMessage>();
        set<id> setUserIds = new set<id>();
     //   Map<id,list<id>> caseIdToUserIdstoAddMap = new map<id,list<id>>();
        List<String> listtoAddresses = new List<String>();
        For(case newCase:listNewCases){
          if(newCase.recordtypeid == emcRtId){
                case oldCase = mapOldCases.get(newCase.id);   
                
                if(oldCase.Enterprise_Sales_Approver_1__c != newCase.Enterprise_Sales_Approver_1__c && 
                   newCase.Enterprise_Sales_Approver_1__c != null){
                    listtoAddresses.add(newCase.Enterprise_Sales_Approver_1__c);
                }
                if(oldCase.Enterprise_Sales_Approver_2__c != newCase.Enterprise_Sales_Approver_2__c && 
                   newCase.Enterprise_Sales_Approver_2__c != null){
                    listtoAddresses.add(newCase.Enterprise_Sales_Approver_2__c);
                }
                if(oldCase.Enterprise_Sales_Approver_3__c != newCase.Enterprise_Sales_Approver_3__c && 
                   newCase.Enterprise_Sales_Approver_3__c != null){
                    listtoAddresses.add(newCase.Enterprise_Sales_Approver_3__c);
                }
                if(oldCase.Enterprise_Sales_Approver_4__c != newCase.Enterprise_Sales_Approver_4__c && 
                   newCase.Enterprise_Sales_Approver_4__c != null){
                    listtoAddresses.add(newCase.Enterprise_Sales_Approver_4_IT_field__c);
                     system.debug('----------38---'+newCase.Enterprise_Sales_Approver_4__r.email);
                //    setUserIds.add(newCase.Enterprise_Sales_Approver_4__c);
                }
                if(oldCase.Enterprise_Sales_Approver_5__c != newCase.Enterprise_Sales_Approver_5__c && 
                   newCase.Enterprise_Sales_Approver_5__c != null){
                    listtoAddresses.add(newCase.Enterprise_Sales_Approver_5_IT_field__c);
                //    setUserIds.add(newCase.Enterprise_Sales_Approver_5__c);
                }
                if(oldCase.Enterprise_Sales_Approver_6__c != newCase.Enterprise_Sales_Approver_6__c && 
                   newCase.Enterprise_Sales_Approver_6__c != null){
                    listtoAddresses.add(newCase.Enterprise_Sales_Approver_6_IT_field__c);
                  //  setUserIds.add(newCase.Enterprise_Sales_Approver_6__c);
                }
                if(oldCase.Enterprise_Sales_Approver_6__c != newCase.Enterprise_Sales_Approver_6__c && 
                   newCase.Enterprise_Sales_Approver_6__c != null){
                    listtoAddresses.add(newCase.Enterprise_Sales_Approver_6_IT_field__c);
                  //  setUserIds.add(newCase.Enterprise_Sales_Approver_6__c);
                }
                if(oldCase.Enterprise_Sales_Approver_7__c!= newCase.Enterprise_Sales_Approver_7__c && 
                   newCase.Enterprise_Sales_Approver_7__c!= null){
                    listtoAddresses.add(newCase.Enterprise_Sales_Approver_7__c);
                }
                if(oldCase.Enterprise_Sales_Approver_8__c!= newCase.Enterprise_Sales_Approver_8__c && 
                   newCase.Enterprise_Sales_Approver_8__c!= null){
                   // listtoAddresses.add(newCase.Enterprise_Sales_Approver_8__c);
                    setUserIds.add(newCase.Enterprise_Sales_Approver_8__c);
                }
            }                   
         }
        
        list<user> listUser =[select id,name,email from user where id in:setUserIds];
        if(listUser.size()>0)
        {
        for(user u: listUser)
        {
        listtoAddresses.add(u.email);
        }
        }
        

         Map<String, User> mapuserMapFromEmail = new Map<String, User>();
          if(!listtoAddresses.isEmpty()){
            list<User> listuserList = [Select Id, Email, LanguageLocaleKey,HR_Location_Country_Desc__c,HR_Location_State_Desc__c from User Where Email IN: listtoAddresses];

            if(!listuserList.isEmpty()){
              for(User userObj: listuserList){
                mapuserMapFromEmail.put(userObj.Email, userObj);
              }
            }
          }      

         for(Case newCase:listNewCases){
          if(newCase.recordtypeid == emcRtId){
            if(listtoAddresses.size() > 0){
                system.debug('**toAddress**' +listtoAddresses);
                list<String> listtoEnglishAddress = new list<String>();
                list<String> listtoOtherAddress = new list<String>();
                for(String strtoAdd: listtoAddresses){
                    if(getTemplateIdsBasedOnUsersLang(mapuserMapFromEmail, strtoAdd) == Id.valueOf(System.Label.EMC_email_template_id_for_case_notifcation)){
                        listtoEnglishAddress.add(strtoAdd);
                    }else if(getTemplateIdsBasedOnUsersLang(mapuserMapFromEmail, strtoAdd) == Id.valueOf(System.Label.EMC_China_email_template_id_for_case_notifcation)){
                        listtoOtherAddress.add(strtoAdd);
                    }
                 }
                if(!listtoEnglishAddress.isEmpty()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    mail = emailMsg(listtoEnglishAddress, System.Label.EMC_email_template_id_for_case_notifcation, newCase);
                    listmails.add(mail);
                }
                if(!listtoOtherAddress.isEmpty()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    mail = emailMsg(listtoOtherAddress, System.Label.EMC_China_email_template_id_for_case_notifcation, newCase);
                    listmails.add(mail);
                }   
              }
           }
         }
       if(listmails.size() > 0){
           if (!Test.isRunningTest()){ 
               messaging.sendEmail(listmails); 
               }
       }
   }  
/* commented below as per 7101878 user story */

 /*  private static Id getTemplateIdsBasedOnUsersLang(Map<String, User> mapuserMapFromEmail, String strapproverEmail){
      if(mapuserMapFromEmail.containsKey(strapproverEmail)){
          if(mapuserMapFromEmail.get(strapproverEmail).LanguageLocaleKey=='zh_CN' || mapuserMapFromEmail.get(strapproverEmail).LanguageLocaleKey=='zh_TW')
            {
                If((mapuserMapFromEmail.get(strapproverEmail).HR_Location_Country_Desc__c=='China' && mapuserMapFromEmail.get(strapproverEmail).HR_Location_State_Desc__c=='Guangdong') || (mapuserMapFromEmail.get(strapproverEmail).HR_Location_Country_Desc__c=='Hong Kong'))
                {
                return Id.valueOf(System.Label.EMC_email_template_id_for_case_notifcation);
                }
            else {return Id.valueOf(System.Label.EMC_China_email_template_id_for_case_notifcation);}
          }else{
            return Id.valueOf(System.Label.EMC_email_template_id_for_case_notifcation);
          }
       }else{
          return Id.valueOf(System.Label.EMC_email_template_id_for_case_notifcation);
       }
   } */
   
private static Id getTemplateIdsBasedOnUsersLang(Map<String, User> mapuserMapFromEmail, String strapproverEmail){
    if(mapuserMapFromEmail.containsKey(strapproverEmail)){
   if(!String.isBlank(mapuserMapFromEmail.get(strapproverEmail).HR_Location_Country_Desc__c) )
   {
       
       If((mapuserMapFromEmail.get(strapproverEmail).HR_Location_Country_Desc__c=='China' && mapuserMapFromEmail.get(strapproverEmail).HR_Location_State_Desc__c=='Guangdong') || (mapuserMapFromEmail.get(strapproverEmail).HR_Location_Country_Desc__c=='Hong Kong') || (mapuserMapFromEmail.get(strapproverEmail).HR_Location_Country_Desc__c=='Macao'))
       {
           return Id.valueOf(System.Label.EMC_email_template_id_for_case_notifcation);
       }
       else {
           If((mapuserMapFromEmail.get(strapproverEmail).HR_Location_Country_Desc__c=='China' || mapuserMapFromEmail.get(strapproverEmail).HR_Location_Country_Desc__c=='Taiwan') && mapuserMapFromEmail.get(strapproverEmail).HR_Location_State_Desc__c !='Guangdong')
       {
       return Id.valueOf(System.Label.EMC_China_email_template_id_for_case_notifcation);
       }
        else {if(mapuserMapFromEmail.get(strapproverEmail).LanguageLocaleKey=='zh_CN' || mapuserMapFromEmail.get(strapproverEmail).LanguageLocaleKey=='zh_TW')
      {
       return Id.valueOf(System.Label.EMC_China_email_template_id_for_case_notifcation);}
   else {
       return Id.valueOf(System.Label.EMC_email_template_id_for_case_notifcation);}
   }
             
   }
   }
   else {if(mapuserMapFromEmail.get(strapproverEmail).LanguageLocaleKey=='zh_CN' || mapuserMapFromEmail.get(strapproverEmail).LanguageLocaleKey=='zh_TW')
   {
       return Id.valueOf(System.Label.EMC_China_email_template_id_for_case_notifcation);}
   else {
       return Id.valueOf(System.Label.EMC_email_template_id_for_case_notifcation);}
   }
   }
    else { 
        return Id.valueOf(System.Label.EMC_email_template_id_for_case_notifcation);}
  }
      
       
    private static Messaging.SingleEmailMessage emailMsg(List<String> listtoAddrs, String strtemplateLabel, Case newCase){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        mail.setToAddresses(listtoAddrs);
        mail.setccAddresses(new list<String>{(newCase.Case_owner_email_IT_field__c)});
        mail.setTargetObjectId(newcase.OwnerId);
        mail.setReplyTo(System.Label.Case_update_Email_Service_ID);
        mail.setWhatId(newCase.id);
        if (!Test.isRunningTest()){
            mail.setOrgWideEmailAddressId(Id.valueOf(System.Label.Dell_EMC_deal_reg_orgwideID));
            }
        
        mail.setTemplateId( Id.valueOf(strtemplateLabel) );
        mail.saveAsActivity = false;  
        mail.setTreatTargetObjectAsRecipient(false); 
        return mail;
    }
}