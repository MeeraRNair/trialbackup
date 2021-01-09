/*
 * Author   : Ragu
 * Purpose  : Centralize the record selection process for Account.
 *          Defines the methods which iterate and segregate the Account records for further use.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR10751     16.03           04-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR 12487    16.12           17-Dec-2015     Dipin Raju      FAP Dell Competency Email to Partner Admins 
 * 3.0      CR 13627    FY17-DCS-0103   18-Oct-2016     Gan             to activate account in affinity for account that meets the criteria.
 * 4.0      CR 17778    FY20-DCS-0703   15-July-2019    Harshit         Sales Channel Future Method Fix for execution
 */

public class AccountRecordSelector extends RecordSelector {
    
    private TriggerHandler accTriggerHandler;
    
    // Used in AccountBranchUtils.deleteAllAccBrAndLOBs();
    public set<Id> setLOBAccountIds = new set<Id>();
    
    // Used in PartnerEndUserDataCaptureUtils.deActivateCustomers();
    public set<Id> setInactivePartnerAccountIds = new set<Id>();
    
    // Used in AccountUtilities.disableIncentivesInRelatedContacts();
    public set<Id> setAccountIdsToDisableIncentives = new set<Id>();
    
    // Used in AccountUtilities.contactUpdateHelper();
    public set<Id> setPrimaryContactUpdatedConIds = new set<Id>();
    
    // Used in AccountUtilities.contactUpdateHelper();
    public set<Id> setPrimaryContactUpdatedAccIds = new set<Id>();
    
    // Used in AccountUtilities.deleteAccountTeamMembersHelper();
    public set<Id> setInactiveAccountIds = new set<Id>();
    
    // Used in AccountUtils.SendEmailToPartnerAdmin();
    public set<Id> setAccountIdsForPartnerFinder = new set<Id>();
    
//v2.0: Start
    // Used in AccountUtils.SendCompetencyEmailToPartnerAdmin();
    public set<Id> setAccountIdsForCompetencyEmail = new set<Id>();
//v2.0: End
    
    // 3.0
    public set<Id> setAccountIdsStatusU = new set<Id>();
    
    // Used in AccountValidator.validateProdRepEmail();
    public set<String> setProdRepEmails = new set<String>();
    public list<Account> lstAccountsForEmailValidation = new list<Account>();
    
    // Used in AccountUtilities.associateAccount_SalesChannelGroupHelper();
    public map<Id, String> mapAccIdSalesChannelId = new map<Id, String>();
    
    // Used in AccountUtilities.updateLOBRegistrationEmails();
    public map<Id, String> mapCountryUpdatedAccounts = new map<Id, String>();
    
    // Used in AccountCertificationTracker.updateCertificationTrackerDetails() & AccountEmailUtilities.sendEmailToPartnerAdminUsers();
    public map<Id, Account> mapAccountsForCertificationProcess = new map<Id, Account>();
    
    // Used in AccountCertificationTracker.createCertificationTrackers() & AccountCertificationTracker.checkAndCreateCertificationTrackers();
    public map<Id, Account> mapAccountsForCertificationTracker = new map<Id, Account>();
    
    // Used in AccountIntegrationUtilities.integratePartnerAccounts();
    public map<Id, Account> mapAccountsForIntegration = new map<Id, Account>();
    
    //Account Type Modified by Affinity from Partner To EndUser
    //Added By Uday on 11-16-16
    //commented on 11-21-16
   // public List<Account> AccountTypeChangedfromPAtoEA = new List<Account>();
    
    //Account Type Modified by Affinity from  EndUser to Partner
    //Added By Uday on 11-16-16
    //commented on 11-21-16
   // public List<Account> AccountTypeChangedfromEAtoPA = new List<Account>();
    
    public AccountRecordSelector(list<sObject> lstAccounts, map<Id, sObject> mapOldAccounts, TriggerHandler accTriggerHandler) {
        this.accTriggerHandler = accTriggerHandler;
        
        this.getRecords(lstAccounts, mapOldAccounts);
        
        removeNulls();
    }
    
    protected override void getRecords(list<sObject> lstAccounts, map<Id, sObject> mapOldAccounts) {
        if(lstAccounts != null) {
            Id partnerAccountRTId = (Id)System.Label.RecType_Partner_Account;
            
            //3.0
            Id idEndUserRT = StaticFactory.getRecordTypeIdByName('Account', 'End-User Account');
            
            for(Account newAccount : (list<Account>)lstAccounts) {
                Account oldAccount;
                if(mapOldAccounts != null && !mapOldAccounts.isEmpty()) {
                    oldAccount = (Account)mapOldAccounts.get(newAccount.Id);
                }
                
                // Trigger Context Specific
                if(accTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    if(newAccount.RecordTypeId == partnerAccountRTId) {
                        setProdRepEmails.add(newAccount.PRD_Rep_Email__c);
                        lstAccountsForEmailValidation.add(newAccount);
                    }
                    
                    //Added By Uday
                    //Logic Start
                    //Commented on 11-21-16
                    /*
                    if(newAccount.Type != oldAccount.Type){
                        //check the changes value
                        if(newAccount.Type == 'End User'){
                        //Account type changed from Partner to End User
                        AccountTypeChangedfromPAtoEA.add(newAccount);
                        }
                        if(newAccount.Type == 'Partner'){
                        AccountTypeChangedfromEAtoPA.add(newAccount);
                        }
                    
                    }
                    */
                    //Logic End
                }
                else if(accTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(newAccount.Sales_Channel_ID__c != null) {
                            mapAccIdSalesChannelId.put(newAccount.Id, newAccount.Sales_Channel_ID__c);
                        }
                        
                        if(newAccount.RecordTypeId == partnerAccountRTId && newAccount.Type == 'Partner') {
                            mapAccountsForCertificationTracker.put(newAccount.Id, newAccount);
                        }
                    }
                    else if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(newAccount.Participating_in_LOB_Program__c == false) {
                            setLOBAccountIds.add(newAccount.Id);
                        }
                        
                        if(newAccount.recordTypeId == partnerAccountRTId) {
                            if(oldAccount.Status__c != 'Inactive' && newAccount.Status__c == 'Inactive') {
                                setInactivePartnerAccountIds.add(newAccount.Id);
                            }
                            
                            if(oldAccount.Type != newAccount.Type && newAccount.Type == 'Partner') {
                                mapAccountsForCertificationTracker.put(newAccount.Id, newAccount);
                            }
                        }
                        
                        if(oldAccount.Is_Enabled_for_Incentives__c == true && newAccount.Is_Enabled_for_Incentives__c == false) {
                           setAccountIdsToDisableIncentives.add(newAccount.Id);
                        }
                        
            //v2.0: Start
                        if(newAccount.Ispartner == True && newAccount.Approved_for_Partner_Finder__c == True && (oldAccount.Dell_Certification_Areas__c != newAccount.Dell_Certification_Areas__c)) {
                           setAccountIdsForCompetencyEmail.add(newAccount.Id);
                        }               
            //v2.0: End 
                        
                        if(newAccount.Account_Country__c != oldAccount.Account_Country__c) {
                            mapCountryUpdatedAccounts.put(newAccount.Id, newAccount.Account_Country__c);
                        }
                        
                     //  if(newAccount.Partner_Relationship__c != oldAccount.Partner_Relationship__c  && (newAccount.Partner_Relationship__c == 'Premier' || newAccount.Partner_Relationship__c == 'Preferred' || newAccount.Partner_Relationship__c == 'Registered')) {
                        //new Centralized Logic
                   
                      if(newAccount.Partner_Relationship__c != oldAccount.Partner_Relationship__c  && (PartnerStatusUtilityClass.PremierTypeContains(newAccount.Partner_Relationship__c) || PartnerStatusUtilityClass.PreferredTypeContains(newAccount.Partner_Relationship__c) || PartnerStatusUtilityClass.RegisteredTypeContains(newAccount.Partner_Relationship__c))) {

                      
                            mapAccountsForCertificationProcess.put(newAccount.Id, newAccount);
                        }
                        
                        if(newAccount.Primary_Contact__c != oldAccount.Primary_Contact__c) {
                            if(newAccount.Primary_Contact__c != null) {
                                setPrimaryContactUpdatedConIds.add(newAccount.Primary_Contact__c);
                            }
                            setPrimaryContactUpdatedAccIds.add(newAccount.Id);
                        }
                        
                        if(newAccount.Calculated_Status__c == 'Inactive') {
                            setInactiveAccountIds.add(newAccount.Id);
                        }
                        else if(newAccount.Approved_for_Partner_Finder__c == true && oldAccount.Approved_for_Partner_Finder__c != newAccount.Approved_for_Partner_Finder__c) {
                            setAccountIdsForPartnerFinder.add(newAccount.Id);
                        }
                       // user story : 6994123 Sales Channel Future Method Fix for execution -- Dell Main
                       // Can't read parent field using field referecne from trigger context so need to change below condition 
                     // if((newAccount.Sales_Channel_ID__c != oldAccount.Sales_Channel__r.Group_ID__c) || (newAccount.Sales_Channel_ID__c != null && newAccount.Sales_Channel__c == null)) { 
                      if((newAccount.Sales_Channel_ID__c != oldAccount.Sales_Channel_ID__c ) || (newAccount.Sales_Channel__c != oldAccount.Sales_Channel__c ) || (newAccount.Sales_Channel_ID__c != oldAccount.Sales_Channel_Group_Id__c) || (newAccount.Sales_Channel_ID__c != null && newAccount.Sales_Channel__c == null)) {  
                            mapAccIdSalesChannelId.put(newAccount.Id, newAccount.Sales_Channel_ID__c);

                        
                     //   if((newAccount.Sales_Channel_ID__c != oldAccount.Sales_Channel_ID__c) || (newAccount.Sales_Channel_ID__c != null && newAccount.Sales_Channel__c == null)) { 
                      //      mapAccIdSalesChannelId.put(newAccount.Id, newAccount.Sales_Channel_ID__c);
                        }
                        
                        //3.0 excluding GDA as it always assigned with this user for the first time and is with an invalid badge number that will fail the activation
                        system.debug('ZY : newAccount.recordTypeId: ' + newAccount.recordTypeId + ', oldAccount.Status__c: ' + oldAccount.Status__c + ', newAccount.Status__c : ' + newAccount.Status__c + ', newAccount.Activate_Suggestion_Id__c: ' + newAccount.Activate_Suggestion_Id__c);
                        if(newAccount.recordTypeId == idEndUserRT && newAccount.Status__c == 'U' && newAccount.Suggestion_ID__c != null && newAccount.Account_ID__c != null 
                           && newAccount.Activate_Suggestion_Id__c == null && newAccount.OwnerId != System.Label.Global_Data_Admin_User_Id) {
                            setAccountIdsStatusU.add(newAccount.Id);
                            system.debug('ZY : Adding account ' + newAccount.id + ' into setAccountIdsStatusU');
                        }
                    }
                    system.debug('suiyeepartnertest: '+ newAccount.RecordTypeId + '  test2: ' +partnerAccountRTId);
                    if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(newAccount.RecordTypeId == partnerAccountRTId) {
                            if(newAccount.IsPartner == true) {
                            if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ){
                                mapAccountsForIntegration.put(newAccount.Id, newAccount);
                              }
                              //based on the Account Value changes like Account name, Country etc 
                              else   if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && PartnerProfilingAccountSynctoDp.checkforChanges(oldAccount,newAccount)){
                                     System.debug('>>> trigger isUpdate :'+PartnerProfilingAccountSynctoDp.checkforChanges(oldAccount,newAccount));
                                      mapAccountsForIntegration.put(newAccount.Id, newAccount);
                                
                              }
                               
                            }
                        }
                    } system.debug('suiyeemaptest: '+ mapAccountsForIntegration );
                }
            }
        }
        else if(mapOldAccounts != null) { // Handling delete events
            for(Account accIterator : (list<Account>)mapOldAccounts.values()) {
                
            }
        }
    }
    
    protected override void getRelatedRecords(list<sObject> lstAccounts) {
        
    }
    
    // Remove nulls from the Set / List / Map.
    private void removeNulls() {
        setProdRepEmails.remove(null);
    }

}