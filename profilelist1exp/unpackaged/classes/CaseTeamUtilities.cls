/*sit4
 * Author   : Ragu.
 * Purpose  : To handle all Case Team related utility methods.
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12450    16.12       10-Dec-2015     Ragu            LM2_16_1- Sharing new cases with requestor before changing case owner
 * 2.0                  0802        06/07/2017      Srikanth        Adding AccountTeamMembers to Case Team.
 * 3.0                  1001        22/08/2017      Srikanth        Adding Additional Recipient Users to Case Team for Order support and Deal registration.
 * 4.0      CR 17605    FY20 0702   04-Jun-2019     Kokila          Case submitter is added to the case team automatically when he/she create case via web to case form and is a SFDC user
 * 5.0      Spring'20   FY20-0202   21-Jan-2020     Shue            Defect 7890995: SDET-Wunderkind::GLMI-FY21-0202- Unable to submit Case on GLMI Site. Avoid Guest User License to be added as Case Team Member due to Spring20 security enhancement
 */

    public class CaseTeamUtilities { 

    // v1.0 - Method to add the Case Creator to the Case Team with the role Case Requestor
    public static void addCaseRequestorToCaseTeam(list<Case> listCases) {
        list<CaseTeamRole> listCaseTeamRoles = [select Id from CaseTeamRole where Name = 'Case Requestor' limit 1];
        if(listCaseTeamRoles != null && !listCaseTeamRoles.isEmpty()) {
            Id caseRequesterRoleId = listCaseTeamRoles[0].Id;
            list<CaseTeamMember> listCaseTeamMembers = new list<CaseTeamMember>();
            
            //5.0 Start
            Map<Id, Id> mapCaseToOwnerId = new Map<Id, Id>();
            Set<Id> setGuestUsers = new Set<Id>();

            for(Case c: listCases){
                mapCaseToOwnerId.put(c.id, c.CreatedById);
            }
            
            for(User u: [SELECT id, profile.name, Profile.UserLicense.Name FROM user WHERE id in :mapCaseToOwnerId.values()]){
                if(u.Profile.UserLicense.Name == 'Guest User License'){
                    setGuestUsers.add(u.id);
                }
            }
            //5.0 End
            System.debug('CaseTeamUtilities: addCaseRequestorToCaseTeam setGuestUsers--- '+setGuestUsers);
            for(Case caseIterator : listCases) {
                if(setGuestUsers.isEmpty() || !setGuestUsers.contains(caseIterator.CreatedById)){ //5.0 Avoid Guest User License to be added as Case Team Member due to Spring20 security enhancement
                    listCaseTeamMembers.add(new CaseTeamMember(ParentId = caseIterator.Id, MemberId = caseIterator.CreatedById, TeamRoleId = caseRequesterRoleId));
                }
            }
            
            System.debug('CaseTeamUtilities: addCaseRequestorToCaseTeam listCaseTeamMembers---- '+listCaseTeamMembers);
            if(!listCaseTeamMembers.isEmpty()) {
                TriggerExecutionController.setSkipCaseTriggers(true);
                insert listCaseTeamMembers;
                TriggerExecutionController.setSkipCaseTriggers(false);
            }
        }
    }
    
    //v4.0 - Start
    public static void addWebToCaseRequestorToCaseTeam(list<Case> listCases,map<Id, Case> mapOldCases, string stringDMLOperator) {
        Id glmiRTId = StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake'); 
        set<String> setEmailIds = new set<String>();
        set<Id> setExistingCTMIds = new set<Id>();
        map<String, Id> mapEmailUserId = new map<String, Id>();
        list<CaseTeamMember> listCaseTeamMembers = new list<CaseTeamMember>();
                
        for(Case newCase : listCases) {
           if(stringDMLOperator == 'AfterInsert' && newCase.RecordTypeId == glmiRTId && newCase.Origin == 'Web' && newCase.SuppliedEmail != null){
                setEmailIds.add(newCase.SuppliedEmail);
           }                
           else if (stringDMLOperator == 'AfterUpdate' && newCase.RecordTypeId == glmiRTId && newCase.Origin == 'Web' && newCase.SuppliedEmail != null && mapOldCases.get(newCase.Id).SuppliedEmail != newCase.SuppliedEmail){
                setEmailIds.add(newCase.SuppliedEmail);   
           }                
        }
             
        if(!setEmailIds.isEmpty()) {
            for(User user : [select Id, Email from User where Email in :setEmailIds AND User.IsActive = TRUE]) {
               if(mapEmailUserId.get(user.Email) == null){ 
                    mapEmailUserId.put(user.Email, user.Id);
               }
            }
            
            //Get all current team members in the Case Team
            for(CaseTeamMember ctm: [select Id, MemberId, ParentId from CaseTeamMember where ParentId in :listCases]) {
                setExistingCTMIds.add(ctm.MemberId);
            }
            
            CaseTeamRole caseRequestorCaseTeamRole = [select Id from CaseTeamRole where Name = 'Case Requestor'];
                       
            for(Case newCase : listCases) {
                if(newCase.RecordTypeId == glmiRTId && newCase.Origin == 'Web' && newCase.SuppliedEmail != null) {
                    Id userId = mapEmailUserId.get(newCase.SuppliedEmail);
                    if(userId != null && !setExistingCTMIds.contains(userId)) {
                        CaseTeamMember caseTeamMember = new CaseTeamMember();
                        caseTeamMember.ParentId = newCase.Id;
                        caseTeamMember.MemberId = userId;
                        caseTeamMember.TeamRoleId = caseRequestorCaseTeamRole.Id;
                        listCaseTeamMembers.add(caseTeamMember);
                    }
                }
            }
        }
        
        if(listCaseTeamMembers.size()>0){
            try{
                Database.insert(listCaseTeamMembers,false);
            }catch (System.DmlException e){
                ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, e.getDmlMessage(0)));
            } 
        }
   } //v4.0 - End
    
  // 2.0 Adding AccountTeamMembers to Case Team.
    public static void addAccountTeamMembersToCase(list < Case > listCases, map<Id, Case> mapOldCases, string strDmlOperator) {
     Id ordSupportRTId = StaticFactory.getRecordTypeIdByName('Case', 'Order Support');
     Id dealRegistrationRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration'); 
     Id onBoardingRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');
     Id onBoardingInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding Internal');  
     Id dealRegistrationInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration - Internal only case types');
     Id distiRTId = StaticFactory.getRecordTypeIdByName('Case', 'Distribution');
     Id applicationSupportRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support');
     Id asInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support - Internal only case types');
     Id prtnrPgmRTId = StaticFactory.getRecordTypeIdByName('Case', 'Partner Program');
     List<CaseTeamRole> listCaseTeamRole = new List<CaseTeamRole>();
     List <String> listATMRoles = new List <String> (system.label.OrderSupportATMRoles.split(','));
     List <Id> listAccountIds = new List <Id> ();
     list<string> listCaseIds=new List<string>();
     user loggedInUser = new user();
     system.debug('>>>UserInfo.getUserId()'+UserInfo.getUserId());
     if(UserInfo.getUserId() !=null && Userinfo.getName()!='Automated Process' ){
      loggedInUser = [select Id,Profile.name,contactid,Enable_Partner_Admin__c from user where id = : UserInfo.getUserId() ]; }
     listCaseTeamRole = [select Id from CaseTeamRole where Name = 'Account Team Member' limit 1];
     
     for (case newCase: listCases) {
      if (((newCase.RecordTypeId == onBoardingInternalRTId || newCase.RecordTypeId == dealRegistrationInternalRTId || newCase.RecordTypeId == onBoardingRTId || newCase.RecordTypeId == distiRTId || newCase.RecordTypeId == prtnrPgmRTId ||newCase.RecordTypeId == ordSupportRTId || newCase.RecordTypeId == dealRegistrationRTId || newCase.RecordTypeId == applicationSupportRTId || newCase.RecordTypeId == asInternalRTId) && (newCase.AccountId != null || newCase.AccountId != '')) || (strDmlOperator == 'AfterUpdate' && newcase.Unauthenticated_Case__c==true && (mapOldCases.get(newCase.Id).accountid==null && newCase.accountid!=null))) {
     // System.debug('>>>record type: '+ newCase.RecordTypeId);
        listAccountIds.add(newCase.AccountId); 
        if(newcase.Unauthenticated_Case__c ==true && strDmlOperator == 'AfterUpdate'){
        if(newcase.accountid!=null && mapOldCases.get(newCase.Id).accountid!=null && newcase.accountid!=mapOldCases.get(newCase.Id).accountid){
            listCaseIds.add(newcase.id);
        }
        }   
      }

      if ( strDmlOperator == 'AfterUpdate' && (newCase.RecordTypeId == onBoardingInternalRTId || newCase.RecordTypeId == dealRegistrationInternalRTId || newCase.RecordTypeId == onBoardingRTId || newCase.RecordTypeId == distiRTId || newCase.RecordTypeId == prtnrPgmRTId ||newCase.RecordTypeId == ordSupportRTId || newCase.RecordTypeId == dealRegistrationRTId || newCase.RecordTypeId == applicationSupportRTId || newCase.RecordTypeId == asInternalRTId) && (newCase.AccountId == null && mapOldCases.get(newCase.Id).accountid != null) ) {
          listCaseIds.add(newcase.id);
      }
     }
     /*Deleting case team for unauthenticated cases when case manager updating account second time */
     list<CaseTeamMember> listMemList=[select id from CaseTeamMember where parentid in:listCaseIds and parentid !=null AND TeamRoleId =: listCaseTeamRole[0].Id ];
     if(!listMemList.IsEmpty()){
         Delete listMemList;
     }
     
     //Deleting case share for unauthenticated cases when case manager updating account second time 
     list<CaseShare> listShareList=[Select Id, CaseId from CaseShare Where CaseId in:listCaseIds AND RowCause = 'Manual' ];
     if(!listShareList.IsEmpty()){
         Delete listShareList;
     }
     
     map <Id, Set<Id>> mapAccTeamMembers = new map <Id, Set<Id >>();
     for (AccountTeamMember accTeamMember: [SELECT Id, UserId, AccountId FROM AccountTeamMember where AccountId IN: listAccountIds AND TeamMemberRole IN: listATMRoles]) {
      If(mapAccTeamMembers.get(accTeamMember.AccountId) == null) {
       mapAccTeamMembers.put(accTeamMember.AccountId, new Set <Id> {accTeamMember.UserId});
      } else {
       mapAccTeamMembers.get(accTeamMember.AccountId).add(accTeamMember.UserId);
      }
     }
     List <CaseTeamMember> listCaseTeamList = new List <CaseTeamMember> ();
     
     set <Id> setUsers = new set <Id> ();
     for (Case newCase: listCases) {
      if ((newCase.RecordTypeId == dealRegistrationInternalRTId || newCase.RecordTypeId == onBoardingInternalRTId || newCase.RecordTypeId == onBoardingRTId || newCase.RecordTypeId == distiRTId || newCase.RecordTypeId == prtnrPgmRTId || newCase.RecordTypeId == ordSupportRTId || newCase.RecordTypeId == dealRegistrationRTId || newCase.RecordTypeId == applicationSupportRTId || newCase.RecordTypeId == asInternalRTId) && (newCase.AccountId != null || newCase.AccountId != '')) {
      if(mapAccTeamMembers.size()>0){    
      for (Id usrId: mapAccTeamMembers.get(newCase.AccountId)) {
       CaseTeamMember ctm = new CaseTeamMember();
       ctm.ParentId = newCase.Id;
       if(listCaseTeamRole != null && listCaseTeamRole.size() > 0) {
           ctm.TeamRoleId = listCaseTeamRole[0].Id;
       }
       ctm.MemberId = usrId;
       listCaseTeamList.add(ctm);
       }
      }
     if(loggedInUser !=null && strDmlOperator == 'AfterInsert' && newcase.Unauthenticated_Case__c == false && (loggedInUser.Profile.name).contains('Portal') == false ){
       CaseTeamMember ctm = new CaseTeamMember();
       ctm.ParentId = newCase.Id;
       ctm.TeamRoleId = listCaseTeamRole[0].Id;
       if(listCaseTeamRole != null && listCaseTeamRole.size() > 0) {   
       ctm.MemberId = newCase.CreatedById;
       }
       listCaseTeamList.add(ctm); 
          }    
          
     }
    }
     if(listCaseTeamList.size()>0){
      try{
       Database.insert(listCaseTeamList,false);
       }catch (System.DmlException e){
       ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, e.getDmlMessage(0)));
      } 
       
    }
  }
  
        
 //3.0 Adding Additional Recipient Users to Case Team for Order support, Deal registration and Distribution. 
    public static void addRecipientUsersToCaseTeam(list < Case > listCases, map<Id, Case> mapOldCases) {
        
        boolean bIsValid = false;
        list<Case> listValidCases = new list<Case>();
        list<Case> listUpdatedCases = new list<Case>();
        Id ordSupportRTId = StaticFactory.getRecordTypeIdByName('Case', 'Order Support');
        Id dealRegistrationRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration');
        Id onBoardingRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');
        Id onBoardingInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding Internal');
        Id dealRegistrationInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration - Internal only case types');   
        Id distiRTId = StaticFactory.getRecordTypeIdByName('Case', 'Distribution');
        Id applicationSupportRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support');
        Id asInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support - Internal only case types');
        Id prtnrPgmRTId = StaticFactory.getRecordTypeIdByName('Case', 'Partner Program');
         
        for(Case newCase: listCases){
        
            if((mapOldCases.get(newCase.Id).status != newCase.status || mapOldCases.get(newCase.Id).OwnerId != newCase.OwnerId ) || (newcase.Unauthenticated_Case__c==true && (mapOldCases.get(newCase.Id).accountid==null && newCase.accountid!=null))){ 
                listValidCases.add(newCase);
                bIsValid = true;
            }
            
            if( mapOldCases.get(newCase.Id).AccountId != null && newCase.AccountId != null && mapOldCases.get(newCase.Id).AccountId != newCase.AccountId  || test.isRunningTest()){
                listUpdatedCases.add(newCase);
            }
        }
        system.debug('check addRecipientUsersToCaseTeam'+bIsValid);
        if( bIsValid == true ){
         
            
         set <string> setAdditionalEmails = new set <string> ();
         set <Id> setContactIds = new set <Id> ();
         Map <string, Id> mapEmailsToUsers = new Map <string, Id> ();
         Map <Id, set <Id>> mapcaseToUsers = new Map <Id, set <Id>> ();
         List <CaseTeamMember> listCaseTeamList = new List <CaseTeamMember> ();
         List<CaseShare> listcaseSharelist = new List<CaseShare>();
         set<CaseTeamMember> setRemoveDuplicateUsers1 = new set<CaseTeamMember>();
         set<CaseShare> setRemoveDuplicateUsers = new set<CaseShare>();
         Map <Id, Id> mapCaseAccIds = new Map <Id, Id> ();   
         Map < Id, List < Id >> mapPartnerAdmUsers = new Map < Id, List < Id >> ();
         Id accountId;
            
         for (case newCase: listValidCases) {
         if(newcase.accountid!=null){
          if (newCase.RecordTypeId == dealRegistrationInternalRTId || newCase.RecordTypeId == onBoardingInternalRTId || newCase.RecordTypeId == onBoardingRTId || newCase.RecordTypeId == ordSupportRTId || newCase.RecordTypeId == dealRegistrationRTId || newCase.RecordTypeId == distiRTId || newCase.RecordTypeId == prtnrPgmRTId || newCase.RecordTypeId == applicationSupportRTId || newCase.RecordTypeId == asInternalRTId && (newCase.AccountId != null || newCase.AccountId != '') 
                                                                                                     /*&& newCase.Case_Category__c == 'Partner'*/) {
           setAdditionalEmails.add(newCase.Additional_Recipient_1__c);
           setAdditionalEmails.add(newCase.Additional_Recipient_2__c);
           setAdditionalEmails.add(newCase.Additional_Recipient_3__c);
           setAdditionalEmails.add(newCase.Additional_Recipient_4__c);
           setAdditionalEmails.add(newCase.Additional_Recipient_5__c);
          if((newCase.RecordTypeId != onBoardingInternalRTId && newCase.RecordTypeId != dealRegistrationInternalRTId && newCase.RecordTypeId != asInternalRTId)){                                                                                               
           mapCaseAccIds.put(newCase.id, newCase.AccountId); 
           setContactIds.add(newCase.contactId);   
          }
          }
         }
         }
     /*** Start : Modified By Prasanthi M on 20/12/2018 ***/
         //Fetching Contacts who were matched to above case related contact ids
         List<Contact> listconList = [select id,AccountId,Selected_Track__c from Contact where id in:setContactIds];
         system.debug('Case Related Contacts'+listconList);
         Set<Id> setacctIds = new Set<Id>();
         for(Contact c:listconList){
              setacctIds.add(c.accountId);  
         } 
         system.debug('Case contact related accounts'+setacctIds);   
            
       //Fetch the users whose contact account ids are in above account ids
        // Added by Sneha
       
       List<User> listuserList = new List<User>();
        if(setContactIds.size() > 0){
            listuserList = [select id,ContactId,Contact.AccountId,Contact.EligibleTracks__c 
                                    from User 
                                    where Contact.AccountId IN : setacctIds
                                    AND IsActive = true 
                                    AND Enable_Partner_Admin__c = true];
            
        }
         
         system.debug('User matched with above case contact related accounts'+listuserList.size());

          List<Case> listValidCases1 = new List<Case>();
          listValidCases1 = [SELECT Id,AccountId,Account.Master_Group_Id__c,ContactId,Contact.Selected_Track__c
                           FROM Case
                           WHERE Id IN :mapCaseAccIds.keySet()]; 
          for(Case newCase : listValidCases1){
             
             for(User newUsr:listuserList){
                 // To hold the contact's Eligible Track
                 List<String> listContactEligibleTracks = new List<String>();
                 if(String.isNotBlank(newUsr.contact.EligibleTracks__c) &&  newUsr.contact.EligibleTracks__c.trim().split(';').contains(newCase.Contact.Selected_Track__c) &&
                      newCase.Account.Master_Group_Id__c == newUsr.Contact.AccountId){
                      CaseShare adminCaseShare = new CaseShare();
                      adminCaseShare.CaseId = newCase.Id;
                      adminCaseShare.CaseAccessLevel = 'Edit';
                      adminCaseShare.UserOrGroupId = newUsr.Id;
                      setRemoveDuplicateUsers.add(adminCaseShare);
                 }  
                     
                    
             }
           }
       
        // updated code ends.
          /*
          Commented by Sneha
         
         List<Id> listeligibleUsersIdList = new List<Id>();    
          for(Contact c:listconList){
             for(User u:listuserList){
                 //Get List of Ids from User's eligible tracks , If case contact selected track is matched with any
                 //one of the id in this eligible tracks ids , add that user to one list
                 if(u.contact.EligibleTracks__c != NULL){
                      List<Id> listeligibleTrackIdList = (u.contact.EligibleTracks__c).split(';');
                     if(listeligibleTrackIdList.contains(c.Selected_Track__c)){
                         listeligibleUsersIdList.add(u.id);
                     }  
                 }
             }    
         }
        system.debug('***EligibleUserIds'+listeligibleUsersIdList);*/ 
       /*** End : Modified By Prasanthi M on 20/12/2018 ***/     
       If(mapCaseAccIds.size() > 0){
          
          if (setRemoveDuplicateUsers.size() > 0) {
          try{
           listcaseSharelist.addAll(setRemoveDuplicateUsers);  
           system.debug('Case Share List:'+listcaseSharelist);
           Database.insert(listcaseSharelist,false);
           system.debug('Insert Case Share Member :'+listcaseSharelist);
          }catch (System.DmlException e){
           ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, e.getDmlMessage(0)));
          }
        }          
                
   /*       
        If(mapCaseAccIds.size() > 0){
         for (User eachPartnerAdm: [Select Id, Contact.AccountId, ContactId from User
                                    Where Enable_Partner_Admin__c = true and Contact.AccountId IN: mapCaseAccIds.values() AND IsActive = true]) {
                                    system.debug('Partner Admin :'+eachPartnerAdm);
          if (!mapPartnerAdmUsers.containsKey(eachPartnerAdm.Contact.AccountId)) {
           mapPartnerAdmUsers.put(eachPartnerAdm.Contact.AccountId, new List < Id > {});
          }
          mapPartnerAdmUsers.get(eachPartnerAdm.Contact.AccountId).add(eachPartnerAdm.id);
         }   

         CaseShare adminCaseShare;
         for (Id eachCaseId: mapCaseAccIds.keySet()) {
          accountId = mapCaseAccIds.get(eachCaseId);
          if (mapPartnerAdmUsers.get(accountId) != null) {
           for (Id eachPartnerAdmin: mapPartnerAdmUsers.get(accountId)) {
               
            /*adminCaseMemberShip = new CaseTeamMember();     
            adminCaseMemberShip.ParentId = eachCaseId;
            adminCaseMemberShip.MemberId = eachPartnerAdmin;        
            if(listCaseTeamRoles != null && listCaseTeamRoles.size() > 0) {
            adminCaseMemberShip.TeamRoleId = listCaseTeamRoles[0].id;
            }
           setRemoveDuplicateUsers1.add(adminCaseMemberShip);
           
           adminCaseShare = new CaseShare();
           adminCaseShare.CaseId = eachCaseId;
           adminCaseShare.CaseAccessLevel = 'Edit';
           adminCaseShare.UserOrGroupId = eachPartnerAdmin;
           setRemoveDuplicateUsers.add(adminCaseShare);
           system.debug('Partner Admin :'+eachPartnerAdmin);
           }
          }
         }
*/

 }   
   //*******************************************************************************************************************         
         if (setAdditionalEmails.size() > 0) {
          //'Additional Recipient User'
         List <CaseTeamRole> listCaseTeamRole = new List <CaseTeamRole> ([select Id from CaseTeamRole where Name = :system.Label.AdditionalResp_role limit 1]);   
          for (User u: [Select id, email from user where email IN: setAdditionalEmails]) {
           mapEmailsToUsers.put(u.email, u.Id);
          }
          
          system.debug('check mapEmailsToUsers'+mapEmailsToUsers);
        
          for (case newCase: listValidCases) {
           If(mapcaseToUsers.get(newCase.Id) == null) {
            set <Id> setValidUserIds = new set <Id> ();
            if (mapEmailsToUsers.containsKey(newCase.Additional_Recipient_1__c)) {
             setValidUserIds.add(mapEmailsToUsers.get(newCase.Additional_Recipient_1__c));
            }
            if (mapEmailsToUsers.containsKey(newCase.Additional_Recipient_2__c)) {
             setValidUserIds.add(mapEmailsToUsers.get(newCase.Additional_Recipient_2__c));
            }  
            if (mapEmailsToUsers.containsKey(newCase.Additional_Recipient_3__c)) {
             setValidUserIds.add(mapEmailsToUsers.get(newCase.Additional_Recipient_3__c));
            }
            if (mapEmailsToUsers.containsKey(newCase.Additional_Recipient_4__c)) {
             setValidUserIds.add(mapEmailsToUsers.get(newCase.Additional_Recipient_4__c));
            } 
            if (mapEmailsToUsers.containsKey(newCase.Additional_Recipient_5__c)) {
             setValidUserIds.add(mapEmailsToUsers.get(newCase.Additional_Recipient_5__c));
            }
            mapcaseToUsers.put(newCase.Id, setValidUserIds);
           }
        
           for (Id usrId: mapcaseToUsers.get(newCase.Id)) {
            CaseTeamMember ctm = new CaseTeamMember();
            ctm.ParentId = newCase.Id;
            if (listCaseTeamRole != null && listCaseTeamRole.size() > 0) {
             ctm.TeamRoleId = listCaseTeamRole[0].Id;
            }
            ctm.MemberId = usrId;
            setRemoveDuplicateUsers1.add(ctm);
            
          /*  CaseShare additionalCaseshare = new CaseShare();
            additionalCaseshare.CaseId = newCase.Id;
            additionalCaseshare.CaseAccessLevel = 'Edit';
            additionalCaseshare.UserOrGroupId = usrId;
            setRemoveDuplicateUsers.add(additionalCaseshare); */
            
           }
           //system.debug('UserList :'+setRemoveDuplicateUsers);
          }
         }   

            
    
            
          if (setRemoveDuplicateUsers1.size() > 0) {
          try{
           listCaseTeamList.addAll(setRemoveDuplicateUsers1);  
           system.debug('Case Team List:'+listCaseTeamList);
           Database.insert(listCaseTeamList,false);
           system.debug('Insert Case Team Member :'+listCaseTeamList);
          }catch (System.DmlException e){
           ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, e.getDmlMessage(0)));
          }
        }
    }
    
    if(listUpdatedCases.size() > 0) {
        Map <Id, Id> mapCaseAccIds = new Map <Id, Id> ();
        for (case newCase: listUpdatedCases) {
            if (newCase.RecordTypeId == onBoardingRTId || newCase.RecordTypeId == ordSupportRTId || newCase.RecordTypeId == dealRegistrationRTId || newCase.RecordTypeId == distiRTId || newCase.RecordTypeId == prtnrPgmRTId || newCase.RecordTypeId == applicationSupportRTId ) {
                mapCaseAccIds.put(newCase.id, newCase.AccountId);
            }
        }
        
        If(mapCaseAccIds.size() > 0){
            Map < Id, List < Id >> mapPartnerAdmUsers = new Map < Id, List < Id >> ();
            for (User eachPartnerAdm: [Select Id, Contact.AccountId, ContactId from User
                                    Where Enable_Partner_Admin__c = true and Contact.AccountId IN: mapCaseAccIds.values() AND IsActive = true]) {
                if (!mapPartnerAdmUsers.containsKey(eachPartnerAdm.Contact.AccountId)) {
                    mapPartnerAdmUsers.put(eachPartnerAdm.Contact.AccountId, new List < Id > {});
                }
                mapPartnerAdmUsers.get(eachPartnerAdm.Contact.AccountId).add(eachPartnerAdm.id);
            }
            
            CaseShare adminCaseShare;
            set<CaseShare> setRemoveDupUsers = new set<CaseShare>();
            for (Id eachCaseId: mapCaseAccIds.keySet()) {
            //  accountId = mapCaseAccIds.get(eachCaseId);
                if (mapPartnerAdmUsers.get(mapCaseAccIds.get(eachCaseId)) != null) {
                    for (Id eachPartnerAdmin: mapPartnerAdmUsers.get(mapCaseAccIds.get(eachCaseId))) {
                       adminCaseShare = new CaseShare();
                       adminCaseShare.CaseId = eachCaseId;
                       adminCaseShare.CaseAccessLevel = 'Edit';
                       adminCaseShare.UserOrGroupId = eachPartnerAdmin;
                       setRemoveDupUsers.add(adminCaseShare);
                    }
                }
            }
            
            if (setRemoveDupUsers.size() > 0) {
                try{
                    list<CaseShare> listcaseSharelist = new list<CaseShare>();
                    listcaseSharelist.addAll(setRemoveDupUsers);  
                    Database.insert(listcaseSharelist,false);
                }catch (System.DmlException e){
                    ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, e.getDmlMessage(0)));
                }
            }
        }
    }
  }
    
    // Remove Access to Case creators when ownership changes
    public static void removeCaseCreatorAccessAfterOwnerChange(list < Case > listCases, map<Id, Case> mapOldCases) {
        
         Id ordSupportRTId = StaticFactory.getRecordTypeIdByName('Case', 'Order Support');
         Id dealRegistrationRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration'); 
         Id onBoardingRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');
         Id onBoardingInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding Internal');  
         Id dealRegistrationInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration - Internal only case types');
         Id distiRTId = StaticFactory.getRecordTypeIdByName('Case', 'Distribution');
         Id applicationSupportRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support');
         Id asInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support - Internal only case types');
         Id prtnrPgmRTId = StaticFactory.getRecordTypeIdByName('Case', 'Partner Program');
        
        set<Id> setCaseContactIds = new set<Id>();
        set<Id> setCaseAccountIds = new set<Id>();
        set<Id> setCaseOwnerIds = new set<Id>();
        set<Id> setCaseIds = new set<Id>();
        
        System.debug('Inside After Update Remove Access');
        for (case newCase: listCases) {
            if ((newCase.RecordTypeId == onBoardingInternalRTId || newCase.RecordTypeId == dealRegistrationInternalRTId || newCase.RecordTypeId == onBoardingRTId || newCase.RecordTypeId == distiRTId || newCase.RecordTypeId == prtnrPgmRTId ||newCase.RecordTypeId == ordSupportRTId || newCase.RecordTypeId == dealRegistrationRTId || newCase.RecordTypeId == applicationSupportRTId || newCase.RecordTypeId == asInternalRTId) 
                 && mapOldCases.get(newCase.Id).contactId != newCase.contactId && newCase.Unauthenticated_Case__c == false  || test.isRunningTest() ) {
                setCaseContactIds.add(mapOldCases.get(newCase.Id).ContactId);
            }
            
            if( (newCase.RecordTypeId == onBoardingInternalRTId || newCase.RecordTypeId == dealRegistrationInternalRTId || newCase.RecordTypeId == onBoardingRTId || newCase.RecordTypeId == distiRTId || newCase.RecordTypeId == prtnrPgmRTId ||newCase.RecordTypeId == ordSupportRTId || newCase.RecordTypeId == dealRegistrationRTId || newCase.RecordTypeId == applicationSupportRTId || newCase.RecordTypeId == asInternalRTId) 
                && mapOldCases.get(newCase.Id).AccountId != null && newCase.AccountId != null && mapOldCases.get(newCase.Id).AccountId != newCase.AccountId   || test.isRunningTest()){
                setCaseAccountIds.add(mapOldCases.get(newCase.Id).AccountId);
                setCaseIds.add(newCase.Id);
            }
        }
        System.debug('Case Owner: '+ setCaseContactIds);
        
        
        if(setCaseContactIds.size() > 0){          
            set<Id> setfinalCaseOwnerIds = new set<Id>();      
            list<User> listCaseOwners = new list<User>();
            listCaseOwners = [Select Id, Contact.AccountId, ContactId from User
                                    Where Enable_Partner_Admin__c = false AND ContactId IN: setCaseContactIds AND IsActive = true];
            
            for (User ownr: listCaseOwners) {
                setfinalCaseOwnerIds.add(ownr.Id);
            }    

            System.debug('Final Case Owner: '+ setfinalCaseOwnerIds);
            if(setfinalCaseOwnerIds.size() > 0){
                list<CaseShare> listcaseSharelist = new list<CaseShare>();
                listcaseSharelist = [Select Id, UserOrGroupId from CaseShare Where UserOrGroupId IN: setfinalCaseOwnerIds AND RowCause = 'Manual' ];
                if(listcaseSharelist.size() > 0){
                    delete listcaseSharelist;
                }
            }           
        }
        
        if( setCaseAccountIds.size() > 0){
            list<Contact> listContactList = new list<Contact>();
            listContactList = [Select Id, AccountId from Contact Where AccountId IN: setCaseAccountIds AND Partner_User_Partner_Admin__c = true];
            
            if(listContactList.size() > 0){
                set<Id> setContactIds = new set<Id>();
                
                for(Contact cont: listContactList){
                    setContactIds.add(cont.Id);
                }
                
                list<User> listCaseOwners = new list<User>();
                listCaseOwners = [Select Id, Contact.AccountId, ContactId from User
                                    Where ContactId IN: setContactIds AND IsActive = true];
                
                set<Id> setfinalCaseOwnerIds = new set<Id>();              
                for (User ownr: listCaseOwners) {
                    setfinalCaseOwnerIds.add(ownr.Id);
                }

                System.debug('Final Case Owner: '+ setfinalCaseOwnerIds);
                if(setfinalCaseOwnerIds.size() > 0){
                    list<CaseShare> listcaseSharelist = new list<CaseShare>();
                    listcaseSharelist = [Select Id, UserOrGroupId from CaseShare Where UserOrGroupId IN: setfinalCaseOwnerIds AND RowCause = 'Manual' AND CaseId IN: setCaseIds ];
                    if(listcaseSharelist.size() > 0){
                        delete listcaseSharelist;
                    }
                }               
            }
        }
    }
}