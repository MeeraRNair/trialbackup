/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to Account object. 
 *          Please create separate classes and use it for complex logics.
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10751     16.03       04-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR18310     FY20-DCS-0102 20-Nov-2019   Naga            Adding code to fire PB on Account Partner Track when Sales Channel has changed
 * 2.1      CR18310     FY20-DCS-0102 20-Nov-2019   Naga            Reverting 2.0 changes and moving them to new class.
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */

public class AccountUtilities {
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR10751     16.03       04-Dec-2014     Ragu            This logic is separated from afterUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void disableIncentivesInRelatedContacts(set<Id> setAccountIds) {
        list<Contact> lstContactsToUpdate = new list<Contact>();
        for(Contact contactIterator : [select Id, Name, Is_Enabled_for_Incentives__c from Contact where AccountId in :setAccountIds and Is_Enabled_for_Incentives__c = true]) {
            contactIterator.Is_Enabled_for_Incentives__c = false;
            lstContactsToUpdate.add(contactIterator);
        }
        if(!lstContactsToUpdate.isEmpty()) {
            update lstContactsToUpdate;
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR 6162                 18-Oct-2011     Shivam          Update the Email field on LOB Registration object based on the account country from LOB MailBox Administration.
    2.0         CR 10751    16.03       04-Dec-2014     Ragu            This logic is separated from updateLOBRegCntry trigger and rewritten as part of trigger redesign.
    */
    public static void updateLOBRegistrationEmails(map<Id, String> mapCountryUpdatedAccounts) {
        // Pass the Country collection to get the Country/Mailbox mapping from LOB Mailbox Registration Object.
        map<String, String> mapCountryEmail = new map<String, String>();
        for(LOB_MailBox_Administration__c lobMailBox : [select Id, Country__r.Name, Support_Email__c from LOB_MailBox_Administration__c where Country__r.Name in :mapCountryUpdatedAccounts.values() and Active__c = true]) {
            mapCountryEmail.put(lobMailBox.Country__r.Name, lobMailBox.Support_Email__c);
        }
        
        // Collect all the LOB Registration records on which the mailbox needs to be updated.
        list<LOB_Registration__c> lstLOBRegistrations = new list<LOB_Registration__c>();
        for(LOB_Registration__c lobIterator : [select Id, Registered_End_User__c, Email__c from LOB_Registration__c where Registered_End_User__c in :mapCountryUpdatedAccounts.keySet()]) {
            String strCountry = mapCountryUpdatedAccounts.get(lobIterator.Registered_End_User__c);
            String strEmail = mapCountryEmail.get(strCountry);
            
            if(!String.isBlank(strCountry) && !String.isBlank(strEmail)) { lobIterator.Email__c = strEmail;
            }
            else {
                // Logic to be performed if Account Country / Email is null
                if(Environment.isProduction()) {  lobIterator.Email__c = System.Label.CR6162_LOB_Default_Country_Email_Address;
                }
                else {
                    lobIterator.Email__c = System.Label.CR6162_LOB_Default_Country_Email_Address + '.dit';
                }
            }
            lstLOBRegistrations.add(lobIterator);
        }
        if(!lstLOBRegistrations.isEmpty()) {
            try { update lstLOBRegistrations;
            }
            catch(Exception ex) {
                System.Debug('Error :' + ex.getMessage());
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR1081                  14-Apr-2009     Men Mee         Converted the Account team deletion to @future 
    3.0                                 15-Mar-2010     Krishna         Added a Global variable checking to avoid nested future calls
    4.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from accountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void deleteAccountTeamMembersHelper(set<Id> setInactiveAccountIds) {
        if(!GlobalVariables.BYPASS_FUTURE_CALLS) {
            try {
                // @future call
                AccountTeamDeletion.deleteAccountTeamMembers(Utility.getList(setInactiveAccountIds));
            }
            catch(Exception e) {      emailUtils.sendSupportEmail('from Account Trigger : ' + e.getMessage(), DellConfig.errorEmail);
           
                System.debug('Caught APEX Exception in deleteAccountTeamMembersHelper(): ' + e.getMessage());
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0                                 06-Jun-2008     CCWS            Added in the update of AccountShares to Read/Write
    3.0         CR2742                  24-May-2010     Hanan           When the owner of any non-partner account is changed insert/update its Account_Owner_Transition record.
    4.0         CR4117                  12-Oct-2010     Azwanti         Create WorkItem record for account transition
    5.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from accountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void handleAccountOwnerChange(map<Id, Account> mapNewAccounts, map<Id, Account> mapOldAccounts) {
        list<Account> lstOwnerChangedAccounts = new list<Account>();        
        set<Id> setAccountIds = new set<Id>();    
        map<Id, Id> mapAccountOldOwner = new map<Id, Id>();
        map<Id, Id> mapAccountNewOwner = new map<Id, Id>();        
        for(Account newAccount : mapNewAccounts.values()) {
            Account oldAccount = mapOldAccounts.get(newAccount.Id);            
            if(newAccount.Calculated_Status__c != 'Inactive' && oldAccount.OwnerId != newAccount.OwnerId) {
                mapAccountOldOwner.put(oldAccount.Id, oldAccount.OwnerId);
                mapAccountNewOwner.put(newAccount.Id, newAccount.OwnerId); setAccountIds.add(newAccount.Id);               
                if(oldAccount.ownerId != DellConfig.glblDataAdminGUID) { lstOwnerChangedAccounts.add(oldAccount);
                }
            }
        }        
        // v3.0, v4.0
        if(!setAccountIds.isEmpty()) {
            try { AccountOwnerTransitionUtils.createAccWorkItem(setAccountIds, mapAccountOldOwner, mapAccountNewOwner);
            }
            catch(Exception e) {         emailUtils.sendSupportEmail('from Account Trigger: ' + e.getMessage(), DellConfig.errorEmail);
       
                System.debug('Caught APEX Exception in handleAccountOwnerChange(): ' + e.getMessage());
            }
        }
        
        // v2.0
        if(!lstOwnerChangedAccounts.isEmpty()) {
            try { DellUtil.setAccountShare(lstOwnerChangedAccounts);
            }
            catch(Exception e) {         emailUtils.sendSupportEmail('from Account Trigger: ' + e.getMessage(), DellConfig.errorEmail);
        
                System.debug('Caught APEX Exception in handleAccountOwnerChange(): ' + e.getMessage());
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from accountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void updateAccountPartnerRequestsHelper(map<Id, Account> mapNewAccounts, map<Id, Account> mapOldAccounts) {
        String partnerRequestObjPrefix = Partner_Request__c.sObjectType.getDescribe().getKeyPrefix();
        list<String> lstPartnerRequestIds = new list<String>();
        
        for(Account newAccount : mapNewAccounts.values()) {
            Account oldAccount = mapOldAccounts.get(newAccount.Id);
            
            if(oldAccount.Legacy_ID__c != newAccount.Legacy_ID__c) {
                String strLegacyId = StringUtils.defaultString(newAccount.Legacy_ID__c);
                
                if(strLegacyId.startsWith('SFDC_')) {
                    String strExtractedGUId = IdLookupUtils.getIdFromAccountLegacyId(strLegacyId);
                    if(strExtractedGUId.startswith(partnerRequestObjPrefix)) {  lstPartnerRequestIds.add(strExtractedGUId);
                    }
                }
            }
        }

        if(!lstPartnerRequestIds.isEmpty()) {
            try {         AccountSuggestion.updateAccountPartnerRequests(lstPartnerRequestIds);
        
                System.debug('Number of Partner Request for which the status needs to be changed :'+ lstPartnerRequestIds.size());                    
            }
            catch(Exception e) {
                System.debug('Caught APEX Exception in updateAccountPartnerRequestsHelper(): ' + e.getMessage());
            }        
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR737                   11-Nov-2008     KP/MN           Added new functionality to associate a Sales Channel Group record to Account
    3.0                                 15-Mar-2010     Krishna         Added a Global variable checking to avoid nested future calls
    4.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from accountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void associateAccount_SalesChannelGroupHelper(map<Id, String> mapAccIdSalesChannelId) {
        if(!GlobalVariables.BYPASS_FUTURE_CALLS) {
            try {
                // @future call
                updateSalesChannel.associateAccount_SalesChannelGroup(mapAccIdSalesChannelId);
            }
            catch(Exception e) {       EmailUtils.sendSupportEmail('From Account Trigger : ' + e.getMessage(), DellConfig.errorEmail);       
         
                System.debug('Caught APEX Exception in updateAccountPartnerRequestsHelper(): ' + e.getMessage());
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR6029                  11-Apr-2012     Manju           Allow for Data Loading on Primary Contact
    2.0         CR7594      R13.10      30-Nov-2012     Krishnamoorthi  Allow for Data Loading on Primary Contact - Bug fix
    3.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from accountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void contactUpdateHelper(set<Id> setPrimaryContactUpdatedConIds, set<Id> setPrimaryContactUpdatedAccIds) {
        AccountUtils.ACCOUNT_TRIGGER_CONTEXT = true;
        AccountUtils.contactUpdate(setPrimaryContactUpdatedConIds, setPrimaryContactUpdatedAccIds);
        AccountUtils.ACCOUNT_TRIGGER_CONTEXT = false;
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CRQ0869     15.03       11-Nov-2008     Meera           Store old value of partner relationship when it is getting updated.
    2.0         CR10751     16.03       20-Dec-2014     Ragu            This logic is separated from beforeInsertUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void checkInconsistencyInLMData(map<Id, Account> mapNewAccounts, map<Id, Account> mapOldAccounts) {
        Id partnerAccountRTId = (Id)System.Label.RecType_Partner_Account;
        
        set<Id> setPAUpdatedAccIds = new set<Id>();
        set<String> setPAUpdatedCountryCodes = new set<String>();
        
        set<Id> setInconsistentAccIds = new set<Id>();
        set<String> setInconsistentCountryCods = new set<String>();
        
        for(Account newAccount : mapNewAccounts.values()) {
            Account oldAccount = mapOldAccounts.get(newAccount.Id);
            
            if(newAccount.RecordTypeId == partnerAccountRTId && newAccount.Type == 'Partner') {
                if(newAccount.Partner_Relationship__c != oldAccount.Partner_Relationship__c) {
                    newAccount.Partner_Relationship_OldValue__c = oldAccount.Partner_Relationship__c;                    
                    setPAUpdatedAccIds.add(newAccount.Id);  setPAUpdatedCountryCodes.add(newAccount.Account_Country_Code__c);
                }
                
                // Chek for changes of Inconsistency in Lead Management data? from true to false
                if(newAccount.Inconsistency_in_Lead_Management_data__c != oldAccount.Inconsistency_in_Lead_Management_data__c && newAccount.Inconsistency_in_Lead_Management_data__c == false) {
                    setInconsistentAccIds.add(newAccount.Id);         setInconsistentCountryCods.add(newAccount.Account_Country_Code__c);
                }    
            }                             
        }
        
        if(!setPAUpdatedAccIds.isEmpty()) { doOnAccountIds('PAUpdated', setPAUpdatedAccIds, setPAUpdatedCountryCodes, mapNewAccounts);
        }
        
        if(!setInconsistentAccIds.isEmpty()) {  doOnAccountIds('Inconsistent', setInconsistentAccIds, setInconsistentCountryCods, mapNewAccounts);
        }
    }

    public static void doOnAccountIds(String funType, Set<Id> setAccIds, Set<String> setCountryCods, map<Id, Account> mapNewAccounts) {
        // If there exists partner relationship changes accounts, fetch country details
        // Check if while disabiling  if the partner relationship is a valid one, if so skip that one from being errored out
        map<String, Country__c> mapCountryCodeCountry = new map<String, Country__c>();
        for(Country__c countryIterator : ([select Id, Code__c, Lead_Management_Enabled__c, Lead_Management_Enabled_for_OEM__c, Partner_Relationship_for_OEM__c, Partner_Relationship__c from Country__c where Code__c IN :setCountryCods])) {
            mapCountryCodeCountry.put(countryIterator.Code__c, countryIterator);
        }
        
        // Check for accounts if the new value is also satisfies LM condition
        for(Account accIterator : [select Id, Sales_Channel__c, Sales_Channel__r.Name, Partner_Relationship__c from Account where Id in :setAccIds]) {
            Account newAccount = mapNewAccounts.get(accIterator.Id);
            String strPartnerRelationship = newAccount.Partner_Relationship__c;
            String strPartnerRelationshipTemp = '';
            if(funType == 'PAUpdated') { strPartnerRelationshipTemp = newAccount.Partner_Relationship__c;
            } else if(funType == 'Inconsistent') { strPartnerRelationshipTemp = accIterator.Partner_Relationship__c;
            }
            
            Country__c country = mapCountryCodeCountry.get(newAccount.Account_Country_Code__c);
            
            if(country != null && strPartnerRelationship != null && ((accIterator.Sales_Channel__r.Name.contains('OEM') && country.Lead_Management_Enabled_for_OEM__c == 'Yes' && (country.Partner_Relationship_for_OEM__c.contains(strPartnerRelationshipTemp) || country.Partner_Relationship_for_OEM__c.contains('All'))) 
                                    || (!accIterator.Sales_Channel__r.Name.contains('OEM') && country.Lead_Management_Enabled__c == 'Yes' && (country.Partner_Relationship__c.contains(strPartnerRelationship) || country.Partner_Relationship__c.contains('All'))))) {
                // Satisfies the condition - so remove from set
                setAccIds.remove(accIterator.Id);
                if(funType == 'PAUpdated') {   newAccount.Inconsistency_in_Lead_Management_data__c = false;
                }
            }
        }

        // If there exists accounts which does not satisfy LM condition, check for enabled users
        if(!setAccIds.isEmpty() ) {
            setAccIds.remove(null);
            AggregateResult[] groupedResults = [select Contact.AccountId AccountId, count(Id) rowCount from User 
                                                where Contact.AccountId in :setAccIds and Enable_Partner_Lead_Management__c = true and IsActive = true group by Contact.AccountId];
            for(AggregateResult aggrResult : groupedResults) {
                Integer iRowCount = (Integer)aggrResult.get('rowCount');
                if(iRowCount > 0) {
                    String accountId = (String)aggrResult.get('AccountId');
                    if(funType == 'PAUpdated') {
                        mapNewAccounts.get(accountId).Inconsistency_in_Lead_Management_data__c = true;
                    } else if(funType == 'Inconsistent') {
                        mapNewAccounts.get(accountId).addError('There are existing users with Lead Management enabled. Please disable Lead Management access for these users to proceed.');
                    }
                }
            }
        }
    }
    
    public static void sendEmailOnFieldChange(Map<Id,sObject> mapOldUpdate,List<SObject> listAccUpdate){
    
            List<Account> listAcc =  (List<Account>) listAccUpdate;
            Map<Id,Account> mapOld = (Map<Id,Account>) mapOldUpdate;

                    
            List<String> listStrFieldNames = New List<String>();
            listStrFieldNames.add('LOBi_Preferred_Partner_of_Record__c');
            listStrFieldNames.add('LOBi_Preferred_Partner_of_Record_Network__c');
            listStrFieldNames.add('LOBi_Preferred_Partner_of_Record_Storage__c');
            listStrFieldNames.add('LOBi_Preferred_Partner_of_Record_Server__c');
            
            Map<Id,Id> mapAccModifiedList= new Map<Id,Id>();
            Map<String,String>  mapPORName = new Map<String,String>();
            mapPORName.put('LOBi_Preferred_Partner_of_Record__c','Client');
            mapPORName.put('LOBi_Preferred_Partner_of_Record_Network__c','Network');
            mapPORName.put('LOBi_Preferred_Partner_of_Record_Storage__c','Storage');
            mapPORName.put('LOBi_Preferred_Partner_of_Record_Server__c','Server');
            
            Map<String,String>  mapPORFrom = new Map<String,String>();
            Map<String,String>  mapPORTo = new Map<String,String>();
            Map<String,String>  mapPORChange = new Map<String,String>();
            Map<String,String>  mapPORLastModified = new Map<String,String>();
            
            Map<id,List<String>>  mapEmailIds = new Map<id,List<String>>();
            
            list<Messaging.SingleEmailMessage> listEmailLst = new list<Messaging.SingleEmailMessage>();

            OrgWideEmailAddress replyEmail = [SELECT ID, DisplayName FROM OrgWideEmailAddress WHERE Address =: 'no_reply@dell.com'];       
          
           for(Account objAcc: listAcc){           
            //Case 1   - POR Removed
                for(String str : listStrFieldNames){
                    if(Trigger.oldMap.get(objAcc.id).get(str) != null && Trigger.newMap.get(objAcc.id).get(str) == null) {                        
                        mapAccModifiedList.put(Id.valueOf(string.valueOf(Trigger.oldMap.get(objAcc.id).get(str))),objAcc.Id); 
                        mapPORFrom.put(str,string.valueOf(Trigger.oldMap.get(objAcc.id).get(str)));
                        mapPORTo.put(str,'');
                        mapPORChange.put(str,'Removed');
                        mapPORLastModified.put(str,string.valueOf(System.now()));                        
                }        
                //Case 2   - POR Modified
                if(Trigger.oldMap.get(objAcc.id).get(str) != null && Trigger.newMap.get(objAcc.id).get(str) != null && Trigger.oldMap.get(objAcc.id).get(str) != Trigger.newMap.get(objAcc.id).get(str) ) {
                        mapAccModifiedList.put(Id.valueOf(string.valueOf(Trigger.oldMap.get(objAcc.id).get(str))),objAcc.Id);
                        mapAccModifiedList.put(Id.valueOf(string.valueOf(Trigger.newMap.get(objAcc.id).get(str))),objAcc.Id);    
                        mapPORFrom.put(str,string.valueOf(Trigger.oldMap.get(objAcc.id).get(str)));
                        mapPORTo.put(str,string.valueOf(Trigger.newMap.get(objAcc.id).get(str)));
                        mapPORChange.put(str,'Modified');
                        mapPORLastModified.put(str,string.valueOf(System.now()));
                
                }
                //Case 3   - POR Added
                if(Trigger.oldMap.get(objAcc.id).get(str) == null && Trigger.newMap.get(objAcc.id).get(str) != null) {
                    mapAccModifiedList.put(Id.valueOf(string.valueOf(Trigger.newMap.get(objAcc.id).get(str))),objAcc.Id); 
                        mapPORFrom.put(str,'');
                        mapPORTo.put(str,string.valueOf(Trigger.newMap.get(objAcc.id).get(str)));
                        mapPORChange.put(str,'Addition');
                        mapPORLastModified.put(str,string.valueOf(System.now()));   
                  } 
                }
            }
            Map<Id,Account> mapAccName = new Map<Id,Account>(); 
            List<String> listoppTeamMbrs = System.Label.POR_Enduser_Account_Team_Roles.split(',');
            // Get End User Account team members with specific roles. 
            for(Account acc:[Select id,Name,Owner.Email,(SELECT Id,TeamMemberRole,User.name,user.email FROM AccountTeamMembers where TeamMemberRole IN :listoppTeamMbrs)
                from Account where ID IN: listAcc]){
                
                list<string> listPartnerAccEmailIds = new list<string>();
                
                listPartnerAccEmailIds.add(acc.Owner.Email);
                //listPartnerAccEmailIds.add('pavankumar_kammara@dell.com');
                
                for(AccountTeamMember objAcMember : acc.AccountTeamMembers){            
                   listPartnerAccEmailIds.add(objAcMember.User.Email);                  
                }    
                                
                if(mapEmailIds.get(acc.id) != null) {   
                     listPartnerAccEmailIds.addAll(mapEmailIds.get(acc.Id));  
                     mapEmailIds.put(acc.id,listPartnerAccEmailIds); 
                  }
                else {  
                        mapEmailIds.put(acc.id,listPartnerAccEmailIds); }  
              } 
                        
            //get Partner Account team members with certain roles.
            for(Account acc:[Select id,Name,Owner.Email,(SELECT Id,TeamMemberRole,User.name,user.email FROM AccountTeamMembers where
                                                 TeamMemberRole = 'Inside Channel Account Manager' OR TeamMemberRole = 'Partner Development Manager' OR TeamMemberRole = 'Channel National Account Manager')
                                                 from Account where ID IN:mapAccModifiedList.keyset()]){
                         
               List<String> listTempPartner = new List<String>();
               listTempPartner.add(acc.Owner.Email);
               mapAccName.put(acc.id,acc);  
                
            for(AccountTeamMember objAcMember : acc.AccountTeamMembers){            
                listTempPartner.add(objAcMember.User.Email);
            }   
               if(mapEmailIds.get(mapAccModifiedList.get(acc.id)) != null) {                      
                     listTempPartner.addAll(mapEmailIds.get(mapAccModifiedList.get(acc.id)));  
                     mapEmailIds.put(mapAccModifiedList.get(acc.id),listTempPartner); 
                  }
                else {  
                       mapEmailIds.put(mapAccModifiedList.get(acc.id),listTempPartner);     }  
                                      
         }
  
         for(account objAcc : listAcc){
           string strHtmlUpdatedBody = '';
           strHtmlUpdatedBody = 'Team,<br/><br/> Please be informed that on Account Name: <b>'+ objAcc.Name +',</b> the "Partner of Record" for ' ; 
             
           for(string streachPORItem : mapPORName.keyset()){
              if(mapPORChange.get(streachPORItem) != null){
                 strHtmlUpdatedBody += mapPORName.get(streachPORItem) + ',' ; 
              }
           }
              strHtmlUpdatedBody = strHtmlUpdatedBody.removeEnd(',');
               if(mapPORChange != null && mapPORChange.size() > 1) {
                 strHtmlUpdatedBody += ' LOBs has now been changed.<br/>';  }
               else {
                 strHtmlUpdatedBody += ' LOB has now been changed.<br/>'; }
                
                strHtmlUpdatedBody += ' The corresponding changes can be found within the Route to Market Guidance section of your account page.<br/><br/><br/>';
                String strhyplnk1 = URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ObjAcc.Id;

                strHtmlUpdatedBody += '<table style="border:2px solid black;border-collapse: collapse;">' ; 
                strHtmlUpdatedBody += '<thead><tr>';
                strHtmlUpdatedBody +=  '<th style="border:2px solid black;">LOB</th>';
                strHtmlUpdatedBody +=  '<th style="border:2px solid black;">Partner Of Record from</th>';
                strHtmlUpdatedBody +=  '<th style="border:2px solid black;">Partner Of Record to</th>';
                strHtmlUpdatedBody +=  '<th style="border:2px solid black;">Change made</th>';
                strHtmlUpdatedBody +=  '<th style="border:2px solid black;">Last Modified DateTime</th>';
                strHtmlUpdatedBody +=  '</tr></thead>';

             for(string streachPORItem : mapPORName.keyset())  {
                
                if(mapPORChange.get(streachPORItem) != null) {
                 strHtmlUpdatedBody += '<tr>';     
                 strHtmlUpdatedBody += '<td style="border:2px solid black;">' + mapPORName.get(streachPORItem) + '</td>';
                
                if(string.valueOf(mapPORFrom.get(streachPORItem)) != '' && string.valueOf(mapPORFrom.get(streachPORItem)) != null) {
                  strHtmlUpdatedBody += '<td style="border:2px solid black;">' + mapAccName.get(Id.valueOf(string.valueOf(mapPORFrom.get(streachPORItem)))).Name + '</td>'; }
                else {
                  strHtmlUpdatedBody += '<td style="border:2px solid black;">' + '' + '</td>'; }
                  
                if(string.valueOf(mapPORTo.get(streachPORItem)) != ''  && string.valueOf(mapPORFrom.get(streachPORItem)) != null ) {
                   strHtmlUpdatedBody += '<td style="border:2px solid black;">' + mapAccName.get(Id.valueOf(string.valueOf(mapPORTo.get(streachPORItem)))).Name  + '</td>'; }
                else {
                   strHtmlUpdatedBody += '<td style="border:2px solid black;">' + '' + '</td>'; }

                if(mapPORChange.get(streachPORItem) != null) {
                  strHtmlUpdatedBody += '<td style="border:2px solid black;">' + mapPORChange.get(streachPORItem) + '</td>'; }
                else {
                  strHtmlUpdatedBody += '<td style="border:2px solid black;">' + '' + '</td>'; }
                  
                if(mapPORLastModified.get(streachPORItem) != null) {
                  strHtmlUpdatedBody += '<td style="border:2px solid black;">' + mapPORLastModified.get(streachPORItem) + '</td>'; }
                else {
                  strHtmlUpdatedBody += '<td style="border:2px solid black;">' + '' + '</td>'; }
                   
                  strHtmlUpdatedBody += '</tr>';   
                }  
              }  
                strHtmlUpdatedBody += ' </table><br/>Link to Account: <a href='+strhyplnk1+'>' + URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ObjAcc.Id + '</a>';
                strHtmlUpdatedBody += '<br/><br/>Thanks,<br/>';          

                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage(); 
                mail1.setHtmlBody(strHtmlUpdatedBody);
                mail1.setToAddresses(mapEmailIds.get(objAcc.id));
                mail1.setSubject('Partner of Record Change(s) Notification for Account Name:'+objAcc.Name+'');
                mail1.setTargetObjectId(objAcc.ownerID);
                mail1.setWhatId(objAcc.id);
                mail1.saveAsActivity = false;
                mail1.setReplyTo('donotreply@dell.com');
                mail1.setOrgWideEmailAddressId(replyEmail.Id);
                listEmailLst.add(mail1);
                system.debug('@@@@@@@@@@' +listEmailLst);
         }
        
         Messaging.SendEmailResult [] listresult = Messaging.sendEmail(listEmailLst);
         system.debug('**result **' +listresult );
     }
 
  public static void updateFields(List<sObject> lstAccUpdate)
    {
        List<Account> lstAcc1  = (List<Account>)  lstAccUpdate;
        for(Account a:lstAcc1)
        {
            if(a.Storage__c == TRUE){   a.Storage_Timestamp__c = system.today();             
            }
            if(a.Server__c == TRUE){  a.Server_Timestamp__c = system.today();
            }
            if(a.Networking__c == TRUE){  a.Networking_Timestamp__c = system.today();
            }
            if(a.CSG__c == TRUE){  a.CSG_Timestamp__c = system.today();
            }
        }
        
    }
}