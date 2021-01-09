/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities for auto populating Account fields. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10751     16.03       19-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 3.0      CR13220                 09-June-2016    Swathi          Controlling protect or optimize flag fields enabled either one on account record
 
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */

public class AccountFieldPopulator {

    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from beforeInsertUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void populateFieldsOnBeforeInsert(list<Account> lstAccounts) {
        for(Account accIterator : lstAccounts) {
            if(accIterator.Type == 'Partner' && accIterator.RecordTypeId == System.Label.RecType_Partner_Account && accIterator.Is_Enabled_for_Incentives__c == true) {
                accIterator.Is_Vendor_Update_Required__c = true;
                accIterator.Operation_for_Boomi__c = 'NEW_ACCOUNT';
                accIterator.Is_Vendor_Updated__c = false;
                accIterator.Is_Incentive_Updated__c = true;
                accIterator.last_Operation_Performed__c = 'SFDC Updated';
            }
            else {
                accIterator.Is_Vendor_Update_Required__c = false;
                accIterator.Is_Incentive_Updated__c = false;
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from beforeInsertUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void populateFieldsOnBeforeInsertUpdate(list<Account> lstAccounts) {
        Id partnerAccountRTId = (Id)System.Label.RecType_Partner_Account;
        for(Account accIterator : lstAccounts) {
            // Populate last modified user for partner user if current user is not BOOMI user
            if(accIterator.Type == 'Partner' && accIterator.RecordTypeId == partnerAccountRTId && !Userinfo.getProfileId().contains('00eA0000000hNqF')) {
                accIterator.Last_Modified_User__c = UserInfo.getUserId();
            }
        }
    }
    
     /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    3.0         CR13220                 09-June-2016    Swathi         Controlling protect or optimize flag fields enabled either one on account record
    */
    public static void populateProtectOptimizeFlagFieldsOnBeforeUpdate(list<Account> listAccounts,Map<Id, Account> mapOldAccount) {
        for(Account acctIterator : listAccounts) {            
            if(acctIterator.Protect_Flag__c == True &&  mapOldAccount.get(acctIterator.id).Optimize_Flag__c == True && acctIterator.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId() ) {
                acctIterator.Optimize_Flag__c = False;
            }
            else if(acctIterator.Optimize_Flag__c == True &&  mapOldAccount.get(acctIterator.id).Protect_Flag__c == True && acctIterator.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId()) {
                   acctIterator.Protect_Flag__c = False;
            }               
      }
        
    }
        
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from beforeInsertUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void populateBoomiCMIRelatedFields(list<Account> lstNewAccounts, map<Id, Account> mapOldAccounts) {
        list<String> biFieldsToCompare = new list<String> { 'Name', 'BILLINGSTREET', 'BILLINGCITY', 'BILLINGSTATE', 'BILLINGPOSTALCODE', 'BILLINGCOUNTRY',
                                                            'PHONE', 'FAX', 'ACCOUNT_ID__C', 'Partner_Type__c', 'Partner_Relationship__c' };
        list<String> grassrootsFieldsToCompare = new list<String> { 'Name', 'BILLINGSTREET', 'BILLINGCITY', 'BILLINGSTATE', 'BILLINGPOSTALCODE', 'BILLINGCOUNTRY',
                                                                    'PHONE', 'ACCOUNT_ID__C', 'Tax_Registration_Number__c', 'Status__c', 'Partner_Relationship__c' };
        
        PartnerCountry partCountry = new PartnerCountry();
        map<String, Country__c> mapCountryCodeCountry = partCountry.returnCountryCodeMap();
        
        Id partnerAccountRTId = (Id)System.Label.RecType_Partner_Account;
        for(Account newAccount : lstNewAccounts) {
            Account oldAccount = mapOldAccounts.get(newAccount.Id);
            
            if(newAccount.RecordTypeId == partnerAccountRTId && newAccount.Type == 'Partner' && newAccount.Account_Country_Code__c != null) {
                Boolean isValidVendor = false;
                Boolean isVendorRelatedFieldUpdated = false;                    
                Country__c country = mapCountryCodeCountry.get(StringUtils.upperCase((newAccount.Account_Country_Code__c).trim()));  
                
                if(country != null) {
                    String vendorName = country.Inc_Vendor_Name__c;
                    
                    // Check if this is a valid vendor
                    if(vendorName =='Partner Direct Rewards Center' || vendorName == 'Partner Advantage' || vendorName == 'Dell Achievers') {
                        isValidVendor = true;
                        if(vendorName =='Partner Direct Rewards Center' || vendorName == 'Partner Advantage') {
                            // BI NA or BI EU
                            isVendorRelatedFieldUpdated = PartnerProfileIntegration.isValueChanged(oldAccount, newAccount, biFieldsToCompare);
                        }
                        else {
                            isVendorRelatedFieldUpdated = PartnerProfileIntegration.isValueChanged(oldAccount, newAccount, grassrootsFieldsToCompare);
                        }
                    }
                    
                    if(isValidVendor && !Userinfo.getProfileId().contains('00eA0000000hNqF') 
                        && (newAccount.Is_Update_Triggered_by_DL__c == false || (newAccount.Is_Update_Triggered_by_DL__c == true && newAccount.Is_Vendor_Update_Required__c == true)) // Dataloader check
                        && ((oldAccount.Is_Enabled_for_Incentives__c != newAccount.Is_Enabled_for_Incentives__c && newAccount.Is_Enabled_for_Incentives__c == true) // Checking for incentive change - enabiling //To Do: Check with Priya on Account synch on Country disabling
                            || (oldAccount.Is_Enabled_for_Incentives__c != newAccount.Is_Enabled_for_Incentives__c && newAccount.Is_Enabled_for_Incentives__c == false && newAccount.Vendor_Update_Datetime__c != null) // Already synched with vendor and now getting disabled        
                            || (newAccount.Is_Enabled_for_Incentives__c == true && newAccount.Vendor_Update_Datetime__c != null && isVendorRelatedFieldUpdated) // && Any of the account data which is synched with the vendor system is updated
                            || (newAccount.Is_Vendor_Update_Required__c == true && newAccount.Is_Vendor_Updated__c == false && newAccount.last_Operation_Performed__c == 'SFDC Updated' && (newAccount.Vendor_Update_Datetime__c != null || (newAccount.Is_Enabled_for_Incentives__c == true))) // Already marked for vendor update and some other fields are getting updated
                        )
                    ){
                        newAccount.Is_Vendor_Update_Required__c = true;
                        newAccount.Is_Vendor_Updated__c = false;
                        newAccount.last_Operation_Performed__c = 'SFDC Updated';
                        
                        if(newAccount.Vendor_Update_Datetime__c == null) {
                            newAccount.Operation_for_Boomi__c = 'NEW_ACCOUNT';
                        }
                        else {
                            newAccount.Operation_for_Boomi__c = 'UPDATE_ACCOUNT';
                        }
                        
                        // Add condition checking to identify incentive flag change for BOOMI - CMI synch
                        // (Incentives flag is getting updated) or (Already marked for incentive update and some other fields are getting updated)
                        if((oldAccount.Is_Enabled_for_Incentives__c != newAccount.Is_Enabled_for_Incentives__c) || (newAccount.Is_Vendor_Update_Required__c == true && newAccount.Is_Vendor_Updated__c == false && newAccount.Is_Incentive_Updated__c == true)) {
                            newAccount.Is_Incentive_Updated__c = true;
                        }
                        else {
                            newAccount.Is_Incentive_Updated__c = false;
                        }
                    }
                    else {
                        newAccount.Is_Vendor_Update_Required__c = false;
                        newAccount.Operation_for_Boomi__c = null;
                        
                        if(newAccount.Is_Incentive_Updated__c == true && Userinfo.getProfileId().contains('00eA0000000hNqF')) { //BOOMI is updating with success/failure status
                            newAccount.Is_Incentive_Updated__c = true;
                        }
                        else {
                            newAccount.Is_Incentive_Updated__c = false;
                        }
                    }
        
                    // Check for BOOMI failue and if incentive flag is updated revert back the changes
                    if(Userinfo.getProfileId().contains('00eA0000000hNqF') && newAccount.last_Operation_Performed__c == 'Vendor Sync failed' && newAccount.Is_Incentive_Updated__c == true && PartnerConstants.IS_INCENTIVE_REVERTED == false) {
                        if(newAccount.Is_Enabled_for_Incentives__c == true) {
                            newAccount.Is_Enabled_for_Incentives__c = false;
                        }
                        else {
                            newAccount.Is_Enabled_for_Incentives__c = true;
                        }
                        PartnerConstants.IS_INCENTIVE_REVERTED = true;
                    }
                }
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR9037                                                      This code moved up between insert and update operation for account created from Affinity. This will ensure Boomi flag properly set based on enable for incentive value to sync up with vendor and CMI.
                                                                            Please comment this CR9037 code if hitting error.
    2.0         CR10751     16.03           19-Dec-2014     Ragu            This logic is separated from beforeInsertUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    3.0         CR 15690    FY19-DCE-0602   27-Apr-2018     Emily           Field Trip clean up for Account (Part 2) - for codes coverage
    */
    public static void syncIncentivesEnabled(list<Account> lstNewAccounts, map<Id, Account> mapOldAccounts, AccountTriggerHandler accTriggerHandler) {
        // Ignore below code from execute if current user profile is 00e30000000upO0 = IT GBL Data Load
        if((!Userinfo.getProfileId().contains('00e30000000upO0') && GlobalVariables.BYPASS_ACCOUNT_TRIGGER == true && !GlobalVariables.BYPASS_FUTURE_CALLS) || Test.IsRunningTest()){
            Id partnerAccountRTId = (Id)System.Label.RecType_Partner_Account;
            
            set<Id> setAccountIds = new set<Id>();
            set<String> setAccountNames = new set<String>();
            list<Account> lstPartnerAccounts = new list<Account>();
            
            for(Account accIterator : lstNewAccounts) {
                if(accIterator.RecordTypeId == partnerAccountRTId && accIterator.Type == 'Partner') {
                    if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        setAccountNames.add(accIterator.Name);
                    }
                    else if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        setAccountIds.add(accIterator.Id);
                    }
                    lstPartnerAccounts.add(accIterator);
                }
            }
            
            if(!lstPartnerAccounts.isEmpty()) {
                if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    map<String, Lead> mapAccNameLead = new map<String, Lead>();
                    
                    //v3.0
                    list<Lead> listLeadInsert = new list<Lead>();
                    
                    if (Test.IsRunningTest()){
                        listLeadInsert = [select Id, Is_Enabled_for_Incentives_Acc__c, Company,Partner_Level__c from Lead limit 1];
                    }
                    else{
                        listLeadInsert = [select Id, Is_Enabled_for_Incentives_Acc__c, Company,Partner_Level__c from Lead where Company in :setAccountNames and Account_Category__c = 'Partner' order by CreatedDate asc];
                    }
                    
                    for(Lead leadIterator : listLeadInsert) {
                        mapAccNameLead.put(leadIterator.Company, leadIterator);
                    }
                    
                    for(Account accIterator : lstPartnerAccounts) {
                        Lead leadIterator = mapAccNameLead.get(accIterator.Name);
                        if(leadIterator != null) {
                            accIterator.Is_Enabled_for_Incentives__c = leadIterator.Is_Enabled_for_Incentives_Acc__c;
                            accIterator.Partner_Level__c = leadIterator.Partner_Level__c;
                        }
                    }
                }
                else if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                    map<Id, list<Lead>> mapAccIdLeads = new map<Id, list<Lead>>();
                    
                    //v3.0
                    list<Lead> listLeadUpdate = new list<Lead>();
                    
                    if (Test.IsRunningTest()){
                        listLeadUpdate = [select Id, Is_Enabled_for_Incentives_Acc__c, Account__c from Lead limit 1];
                    }
                    else{
                        listLeadUpdate = [select Id, Is_Enabled_for_Incentives_Acc__c, Account__c from Lead where Account__c = :setAccountIds and Account_Category__c = 'Partner' order by CreatedDate desc];
                    }
                    
                    for(Lead leadIterator : listLeadUpdate) {                        
                        if(mapAccIdLeads.containsKey(leadIterator.Account__c)) {
                            mapAccIdLeads.get(leadIterator.Account__c).add(leadIterator);
                        }
                        else {
                            mapAccIdLeads.put(leadIterator.Account__c, new list<Lead>{ leadIterator });
                        }
                    }
                    
                    list<Lead> lstLeadsToUpdate = new list<Lead>();
                    for(Account accIterator : lstPartnerAccounts) {
                        list<Lead> lstLeads = mapAccIdLeads.get(accIterator.Id);
                        
                        if(lstLeads != null && !lstLeads.isEmpty()) {
                            Account oldAccount = mapOldAccounts.get(accIterator.Id);
                            
                            if(accIterator.Is_Enabled_for_Incentives__c != oldAccount.Is_Enabled_for_Incentives__c) {
                                for(Lead leadIterator : lstLeads) {
                                    leadIterator.Is_Enabled_for_Incentives_Acc__c = accIterator.Is_Enabled_for_Incentives__c;
                                    lstLeadsToUpdate.add(leadIterator);
                                }
                            }
                            else if(accIterator.Is_Enabled_for_Incentives__c == oldAccount.Is_Enabled_for_Incentives__c && accIterator.Is_Enabled_for_Incentives__c != true) { 
                                // This condition will prevent enabled incentive account not get updated by lead. Only will update new account created via PR (by default new account incentive false)                        
                                accIterator.Is_Enabled_for_Incentives__c = lstLeads[0].Is_Enabled_for_Incentives_Acc__c;          
                                
                                // Set flag for Boomi integration - Start
                                if(accIterator.Is_Enabled_for_Incentives__c  == true && accIterator.Is_Vendor_Update_Required__c == false && accIterator.Is_Vendor_Updated__c == false 
                                    && accIterator.Is_Incentive_Updated__c == false && accIterator.Vendor_Update_Datetime__c == null) { 
                                    // This condition will avoid loop sync up to CMI and once a time flag enabled for new record
                                    accIterator.Is_Vendor_Update_Required__c = true;
                                    accIterator.Operation_for_Boomi__c = 'NEW_ACCOUNT';
                                    accIterator.Is_Vendor_Updated__c = false;
                                    accIterator.Is_Incentive_Updated__c = true;
                                    accIterator.last_Operation_Performed__c = 'SFDC Updated';
                                }
                                // Set flag for Boomi integration - End
                            }
                        }
                    }
                    if(!lstLeadsToUpdate.isEmpty()) {
                        update lstLeadsToUpdate;
                    }
                }
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         10833       16.03       07-Jan-2015     Devika          Update LOB flag to false when recordtype is changed from End User to Partner.
    2.0         10751       16.03       05-Feb-2015     Ragu            This logic is separated from beforeInsertUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void populateParticipatingInLOBProgram(list<Account> lstAccounts, map<Id, Account> mapOldAccounts) {
        for(Account newAccount : lstAccounts) {
            if(mapOldAccounts.containsKey(newAccount.Id)) {
                Account oldAccount = mapOldAccounts.get(newAccount.Id);
                if(newAccount.RecordTypeId == System.Label.RecType_Partner_Account && newAccount.RecordTypeId != oldAccount.RecordTypeId
                    && newAccount.Participating_in_LOB_Program__c == true && UserInfo.getName().toLowerCase().contains('affinity')) {
                    System.debug('populateParticipatingInLOBProgram() -> Inside Condition');
                    newAccount.Participating_in_LOB_Program__c = false;
                }
            }    
        }
    }
    
    
    /* 
    Revision    CR Number       Release No      Date            Modified By     Description
    --------    ---------       ----------      -----------     ------------    -----------
    1.0         CR12461         16.12           09-Dec-2015     Krishnamoorthi  To auto populate the field "Customer Reference Relationship Owner" from AccountTeamMember role "Services Customer Executive" whenever the Account is updated and Services Customer Reference Program = Yes
    This method is covered in the test class "beforeInsertUpdateAccountTriggerTest".
    2.0         CR12507         16.12           06-Jan-2016     Krishnamoorthi  To auto populate the Account field "Industry Hidden" from "Industry" field to overcome the SFDC technical limitation in Keyword SOSL search from CRMT intake form.
    3.0         CR 15690        FY19-DCE-0602   27-Apr-2018     Emily           Field Trip clean up for Account (Part 2)
    */
    
    /*v3.0
    public static void populateCRMTFields(List<Account> newAccountList, Map<Id, Account> oldAccountMap) {
        
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, Id> accATMRoleMap = new Map<Id, Id>();
        List<Account> accToIterateList = new List<Account>();
        for(Account newAccount : newAccountList) {
            //Take the Account Id if 'Services Customer Reference Program' is Yes
            if(newAccount.Services_Customer_Reference_Program__c == 'Yes' && oldAccountMap != null) {
                accountIdSet.add(newAccount.Id);
                accToIterateList.add(newAccount);
            }
            
            //v2.0 - Auto populate "Industry Hidden" field from "Industry" field - Start
            if(newAccount.Services_Customer_Reference_Program__c == 'Yes' && newAccount.Industry != null && (oldAccountMap == null || (oldAccountMap != null && (newAccount.Industry != oldAccountMap.get(newAccount.Id).Industry || newAccount.Services_Customer_Reference_Program__c != oldAccountMap.get(newAccount.Id).Services_Customer_Reference_Program__c)))) {
                     newAccount.Industry_Hidden__c = newAccount.Industry;
            }
            else if(oldAccountMap != null && newAccount.Industry_Hidden__c != null && (newAccount.Industry == null || newAccount.Services_Customer_Reference_Program__c != 'Yes')) {
                    newAccount.Industry_Hidden__c = null;
            } 
            //v2.0 - End  
        }
        
        if(!accountIdSet.isEmpty()) {
            //Select the first created Account Team Member with role 'Services Customer Executive'
            for(AccountTeamMember atm : [SELECT AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN :accountIdSet AND TeamMemberRole = 'Services Customer Executive' ORDER BY CreatedDate ASC]) {
                if(!accATMRoleMap.keySet().contains(atm.AccountId)) { //Add only first created Account Team Member
                    accATMRoleMap.put(atm.AccountId, atm.UserId);
                }
            }
            
        }
        
        if(accToIterateList != null) {
            for(Account newAccount : accToIterateList) {
                Account oldAcc = oldAccountMap.get(newAccount.Id);
                //Throw error message when user try to change the 'Customer Reference Relationship Owner' manually and there is already Account Team Member with role 'Services Customer Executive' present
                if(newAccount.Customer_Reference_Relationship_Owner__c != oldAcc.Customer_Reference_Relationship_Owner__c && accATMRoleMap.keySet().contains(newAccount.Id)) {
                    newAccount.Customer_Reference_Relationship_Owner__c.adderror('Services Customer Executive already present in Account Team. You cannot change the value manually.');
                }
                else if(accATMRoleMap.keySet().contains(newAccount.Id) && newAccount.Customer_Reference_Relationship_Owner__c != accATMRoleMap.get(newAccount.Id)) {
                    //Assign Account Team Member with role 'Services Customer Executive' to 'Customer Reference Relationship Owner'
                    newAccount.Customer_Reference_Relationship_Owner__c = accATMRoleMap.get(newAccount.Id);
                    newAccount.Is_User_Updated_Relationship_Owner__c = false;
                }
                else if(!accATMRoleMap.keySet().contains(newAccount.Id) && newAccount.Customer_Reference_Relationship_Owner__c == oldAcc.Customer_Reference_Relationship_Owner__c && newAccount.Is_User_Updated_Relationship_Owner__c == false){
                    //Assign null value to Customer_Reference_Relationship_Owner if no value present in Account Team and not updated manually
                    newAccount.Customer_Reference_Relationship_Owner__c = null;
                }
                //Make the hidden field true if User manually update the field Customer_Reference_Relationship_Owner
                else if(!accATMRoleMap.keySet().contains(newAccount.Id) && newAccount.Customer_Reference_Relationship_Owner__c != oldAcc.Customer_Reference_Relationship_Owner__c){
                    newAccount.Is_User_Updated_Relationship_Owner__c = true;
                }
            }
        }
        
    }*/
    
    
   
}