/*
* Author   : Haribabu Adra
* Purpose  : To handle CSH Case Team related utility methods.
*        
* Revision Ref Number  Release No  Date            Modified By     Description
* -------- ----------  ----------  -----------     ------------    -----------
* 1.0                  FY20 1002   06-Aug-2019     Hari A          Case creator is added to the case team automatically when create case as sfdc user
* 2.0                  FY20 1002   19-Aug-2019     Subhasini      Send email to Case Team and Additional recepients
* 3.0                  Fy20 0102   03-Oct-2019     Hari/Meenu      Notify Case is created in Open/InProgress status  
* 4.0                  Fy20 0102   08-Oct-2019     Anuj/Subha      Adding cc emails to Case team 
* 5.0                  FY20 1101   10-Oct-2019     Anuj           Added few email fields in emailNotification
*/

public class CSHCaseTeamUtilities {
    
    // v1.0 -- Start
    public static Boolean bIsRecursive = false;
    public static void addCaseObserverToCaseTeam(List<Case> listCases) {
        list<CaseTeamRole> listCaseTeamRoles = [select Id from CaseTeamRole where Name = 'Observer' limit 1];
        if(listCaseTeamRoles != null && !listCaseTeamRoles.isEmpty()) {
            Id idCaseCreatorId = listCaseTeamRoles[0].Id;
            list<CaseTeamMember> listCaseTeamMembers = new list<CaseTeamMember>();
            for(Case caseIterator : listCases) {
                listCaseTeamMembers.add(new CaseTeamMember(ParentId = caseIterator.Id, MemberId = caseIterator.CreatedById, TeamRoleId = idCaseCreatorId));
            }
            
            if(!listCaseTeamMembers.isEmpty()) {
                TriggerExecutionController.setSkipCaseTriggers(true);
                insert listCaseTeamMembers;
                TriggerExecutionController.setSkipCaseTriggers(false);
            }
        }
    } // v1.0 -- End
    public static void sendEmailToCaseTeam(List<Case> listCases) {
         system.debug('@@@creator22'+listCases[0].createdByID);
        List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
        
        listEmail = emailNotification(listCases);
        
        if(!listEmail.IsEmpty()){
            if(!bIsRecursive){
                Messaging.sendEmail(listEmail);
                bIsRecursive = true;
            }
        }
    }
    public static list<Messaging.SingleEmailMessage> emailNotification(list<Case> listCase) {
        system.debug('@@@creator2233'+listCase[0].createdByID);
        OrgWideEmailAddress[] listOwea = [select Id from OrgWideEmailAddress where DisplayName = 'Channel Services Helpdesk' LIMIT 1];
        
        list<EmailTemplate> listEmailTemplate = [SELECT id,DeveloperName  FROM EmailTemplate WHERE DeveloperName = 'CSH_Case_in_Status_Resolved' or DeveloperName = 'CSH_Case_created_in_Status_Open' or DeveloperName = 'CSH_Case_in_Status_In_Progress'];
        map<String,String> mapStatusEmailTemplate = new map<String,String> ();
        for(EmailTemplate objTemplate : listEmailTemplate )
        {
            mapStatusEmailTemplate.put(objTemplate.DeveloperName.contains('Open') ? 'Open' : objTemplate.DeveloperName.contains('Progress') ? 'In Progress' : 'Resolved' , objTemplate.id);
        }
        
       
        
        List<Messaging.SingleEmailMessage> listEmailToSend = new List<Messaging.SingleEmailMessage>(); 
        Set<Id> setContId = new Set<Id>();
        Set<Id> setOwnerId = new Set<Id>();
      
        Map<id,Set<String>> mapCaseToEmails = new Map<id,Set<String>>();
        
        for(CaseTeamMember objCaseTeam: [Select Id,parentID,memberid,member.email from CaseTeamMember where parentid IN :listCase and parent.status = 'Resolved' //and  memberid not in :setOwnerId
                                        ]) { 
                                            
                                            if(String.valueOf(objCaseTeam.memberid).StartsWith('003')) { 
                                                setContId.add(objCaseTeam.memberid);
                                            }
                                            if(!mapCaseToEmails.containsKey(objCaseTeam.parentID)) {                
                                                mapCaseToEmails.put(objCaseTeam.parentID,new Set<String>{objCaseTeam.memberId+'_objCaseEmail_'+objCaseTeam.member.email});
                                            }
                                            else {                
                                                mapCaseToEmails.get(objCaseTeam.parentID).add(objCaseTeam.memberId+'_objCaseEmail_'+objCaseTeam.member.email);
                                            }
                                        }
        Map<Id,Contact> mapContEmail = new Map<Id,Contact>();
        if(setContId.size() > 0) {
            mapContEmail = new Map<Id,Contact>([Select Id,Email from Contact where id in :setContId]);
        }
        string strConId = '';
        List<contact> listCon=[select id,name,email from contact limit 1];
        if(!listCon.IsEmpty()){
            listCon[0].email='dummyemail@gmail3.com';
            strConId = listCon[0].id;
        }
        

        for(Case objCase: [Select Status,origin,createdByid,createdBy.email,SuppliedEmail,CaseRTMigrate__Contact_Name_User__r.Email,Additional_Recipient_1__c,Additional_Recipient_2__c,Additional_Recipient_3__c,
                           Additional_Recipient_4__c,Additional_Recipient_5__c, Unauthenticated_Contact_Email__c,Creator_Email__c, Unauthenticated_Case__c  from Case where id in :listCase]) {
                               system.debug('@@@cretatet'+objCase.CreatedById);
                               Set<String> setAdditionalEmails = new Set<String> ();
                               Set<String> setEmail = new Set<String>();
                               if(objCase.origin == 'Partner Portal') {
                                    setAdditionalEmails.add(objCase.createdBy.email);
                               }
                               system.debug('@@@@if'+ObjCase.createdBy.email);
                               system.debug('@@@@if232'+ObjCase.SuppliedEmail);
                               if((objCase.Status =='Open' || objCase.Status =='In Progress') && (objCase.SuppliedEmail==null || objCase.SuppliedEmail =='') && objCase.Unauthenticated_Case__c == false){
                                   system.debug('@@@@if');
                                   setAdditionalEmails.add(ObjCase.createdBy.email);
                               }
                               setAdditionalEmails.add(ObjCase.CaseRTMigrate__Contact_Name_User__r.Email);
                               setAdditionalEmails.add(objCase.Additional_Recipient_1__c);
                               setAdditionalEmails.add(objCase.Additional_Recipient_2__c);
                               setAdditionalEmails.add(objCase.Additional_Recipient_3__c);
                               setAdditionalEmails.add(objCase.Additional_Recipient_4__c);
                               setAdditionalEmails.add(objCase.SuppliedEmail);
                               setAdditionalEmails.add(objCase.Additional_Recipient_5__c);
                               setAdditionalEmails.add(objCase.Unauthenticated_Contact_Email__c);
                               setAdditionalEmails.add(objCase.Creator_Email__c);
                               setAdditionalEmails.remove(null);
                               List<String> listEm = new List<String>(); 
                               Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                               email.setWhatId(objCase.Id);
                               if(mapCaseToEmails.get(objCase.Id) != null && !mapCaseToEmails.isEmpty()){
                               for(String strMemberEmail : mapCaseToEmails.get(objCase.Id))
                               {   
                                   
                                   if(strMemberEmail.split('_objCaseEmail_')[0].StartsWith('003') && mapContEmail != null
                                      && mapContEmail.get(strMemberEmail.split('_objCaseEmail_')[0]).Email != null ) {                      
                                          
                                          listEm.add((mapContEmail.get(strMemberEmail.split('_objCaseEmail_')[0])).Email);
                                      }
                                   
                                   if(strMemberEmail.split('_objCaseEmail_')[0].StartsWith('005') &&
                                      strMemberEmail.split('_objCaseEmail_')[1] != null ) {
                                          listEm.add(strMemberEmail.split('_objCaseEmail_')[1]);
                                          
                                      }
                               }
                                setEmail.addAll(listEm);
                               }
                               
                               setEmail.addAll(setAdditionalEmails);
                               List<String> listAllEmails = new List<String>();
                               listAllEmails.addAll(setEmail);
                               email.setTargetObjectId(strConId);
                               email.setToAddresses(listAllEmails); 
                               
                               if(listOwea.size() > 0) {
                                   email.setOrgWideEmailAddressId(listOwea.get(0).Id);
                               }
                               
                               email.setTemplateId(mapStatusEmailTemplate.get(objcase.Status));
                               email.SaveAsActivity = false;
                               email.treattargetobjectasrecipient = false;
                             
                                   listEmailToSend.add(email);
                              
                           }
        
        
        List<Messaging.SingleEmailMessage> listFinaleMail = new List<Messaging.SingleEmailMessage>();
        if(listEmailToSend.size()>0) {
            listFinaleMail.addAll(listEmailToSend);
        }
        
        return listFinaleMail;
    }
    
    public static void addToCaseTeam(EmailMessage listEmailMessages)
    { 
        Id idCase = listEmailMessages.ParentId;
        String strEmailIds = '';
        if(listEmailMessages.CcAddress!=null){            
            strEmailIds = listEmailMessages.CcAddress; 
        }
        if(String.isBlank(strEmailIds))
        {
            strEmailIds = listEmailMessages.FromAddress;
        }
        else
        {
            strEmailIds = strEmailIds + ';'+listEmailMessages.FromAddress;
        }
        Set<String> setAddressToAdd = new Set<String>();
        Set<String> setAddressToAddCC = new Set<String>();
        List<CaseTeamMember> listCaseTeamMemberUser = new List<CaseTeamMember>();
        list<CaseTeamRole> listCaseTeamRoles = [select Id from CaseTeamRole where Name = 'Observer' limit 1];
        Map<String,User> mapEmailUser = new Map<String,User>();
        if(!String.isBlank(strEmailIds)){
            for(String strEmail: strEmailIds.split(';')){
                setAddressToAddCC.add(strEmail.toLowerCase().trim()); 
                setAddressToAdd.add(strEmail.toLowerCase().trim()); 
            
            if((strEmail.containsIgnoreCase('emc') || strEmail.containsIgnoreCase('dell') )
               && ((strEmail).substring(0,(strEmail).indexOf('@'))).contains('.')) {
                   setAddressToAdd.addAll(CaseCSHEmailPopulator.checkEmailFormat(strEmail.toLowerCase().trim()));
               }
            }
        }
        for(User userLoop : [select id,isActive, Email from User where Email like :setAddressToAdd  AND isActive=true and IsPortalEnabled = false])
        {
            mapEmailUser.put(userLoop.Email,userLoop);
        }
        Case caseLoop = [Select Id,SuppliedEmail FROM Case where Id = :idCase];
        for(String strEmailAdd : setAddressToAddCC)
        {
            Set<String> setEmailToFind = CaseCSHEmailPopulator.checkEmailFormat(strEmailAdd);
            for(String strEmail : setEmailToFind ) 
            {
                System.debug('@@@Test user strEmail '+strEmail);
                if(mapEmailUser.containsKey(strEmail)) 
                {
                    CaseTeamMember objCTM = new CaseTeamMember();
                    objCTM.ParentId = caseLoop.Id;
                    objCTM.MemberId = mapEmailUser.get(strEmail).Id;
                    objCTM.TeamRoleId = listCaseTeamRoles[0].Id;
                    listCaseTeamMemberUser.add(objCTM);
                }
            }
        }
         System.debug('@@@Test user '+listCaseTeamMemberUser);
        if(!listCaseTeamMemberUser.isEmpty())
        {
            insert listCaseTeamMemberUser;
        }
    }

}