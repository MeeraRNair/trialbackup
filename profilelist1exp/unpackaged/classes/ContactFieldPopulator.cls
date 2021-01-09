/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities for auto populating Contact fields. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 10751    16.03       30-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 
 * 
 */

public class ContactFieldPopulator {
 
    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0                                 09-Sep-2008     Meera / KP
    1.1         CR 2008                 06-Oct-2009     Hanan           Commented the code
    2.0                                 28-Nov-2012                     Making this trigger to active to add logic for making partner contacts ready for BOOMI operation to get the incentives info synch with Vendor systems.
    3.0                                 22-Feb-2012                     Modified this trigger to populate Last modified user when current user is not BOOMI user
    4.0         CR 10751    16.03       30-Dec-2014     Ragu            This logic is separated from beforeUpdateContactTrigger trigger and rewritten as part of the trigger redesign.
    */
    public static void populateFieldsOnBeforeUpdate(map<Id, Contact> mapNewContacts, map<Id, Contact> mapOldContacts) {
        try {
            // Filtering contacts with non-partner Account
            set<Id> setContactIdsParse1 = PartnerProfileIntegration.filterNonPartnerAccountContact(mapNewContacts.KeySet());
            // Filtering contacts that are not tied to user
            set<Id> setContactIdsParse2 = PartnerProfileIntegration.filterNonPartnerUserContact(setContactIdsParse1);
            
            // Added by Bahar, Ariff 19th Feb 2013 - need more checking - seriouslly!!!
            for(User userInstance : [select Id, ContactId, LanguageLocaleKey from User where ContactId in :setContactIdsParse2]) {
                Contact newContact = mapNewContacts.get(userInstance.ContactId);
                
                if((StringUtils.isBlank(newContact.Language__c) || newContact.Language__c <> userInstance.LanguageLocaleKey) && StringUtils.isNotBlank(userInstance.LanguageLocaleKey)) { 
                    newContact.Language__c = userInstance.LanguageLocaleKey;
                }
            }
            // End Added by Bahar, Ariff 19th Feb 2013
            
            set<Id> setAccountIds = new set<Id>();
            for(Id contactId : setContactIdsParse2) {
                setAccountIds.add(mapNewContacts.get(contactId).AccountId);
            }
            map<Id, Account> mapAccounts = new map<Id, Account>([select Id, Account_Country_Code__c from Account where Id in :setAccountIds]);
            
            PartnerCountry partCountry = new PartnerCountry();
            map<String, Country__c> mapCountryCodeCountry = partCountry.returnCountryCodeMap();
            
            list<String> bivendorFieldsToCompare = new list<String> {
                                                    'AccountId', 'SALUTATION', 'FIRSTNAME', 'LASTNAME', 'PHONE', 'FAX', 'MOBILEPHONE', 'EMAIL', 'TITLE', 
                                                    'MAILINGSTREET', 'MAILINGCITY', 'MAILINGSTATE', 'MAILINGPOSTALCODE', 'MAILINGCOUNTRY',
                                                    'EMEA_PREFERRED_CONTACT_LANGUAGE__c', 'JOB_FUNCTION__c', 'JOB_FUNCTION_ROLE__c', 'Email_Opt_In__c'                       
                                                };
            list<String> grassrootsFieldsToCompare = new list<String> {  
                                                    'FIRSTNAME', 'LASTNAME', 'PHONE', 'FAX', 'MOBILEPHONE',
                                                    'EMAIL', 'JOB_FUNCTION__c', 'JOB_FUNCTION_ROLE__c', 'Partner_My_Account_GUID__c'
                                                };
            for(Contact newContact : mapNewContacts.values()) {
                Contact oldContact = mapOldContacts.get(newContact.Id);
                
                if(setContactIdsParse2.contains(newContact.Id)) {
                    // Populate last modifed user
                    if(!Userinfo.getProfileId().contains('00eA0000000hNqF')) {
                        newContact.Last_Modified_User__c = Userinfo.getUserId();
                    }
                    
                    Boolean isValidVendor = false;
                    Boolean isVendorRelatedFieldUpdated = false;
                    String strCountryCode = mapAccounts.get(newContact.AccountId).Account_Country_Code__c;
                    if(!String.isEmpty(strCountryCode)) {
                        Country__c country = mapCountryCodeCountry.get(StringUtils.upperCase(strCountryCode.trim()));
                        
                        if(country != null) {
                            String vendorName = country.Inc_Vendor_Name__c;
                            
                            // Check if this is a valid vendor
                            if(vendorName == 'Partner Direct Rewards Center' || vendorName == 'Partner Advantage' || vendorName == 'Dell Achievers') {
                                isValidVendor = true;
                                if(vendorName =='Partner Direct Rewards Center' || vendorName == 'Partner Advantage') { // BI NA or BI EU
                                    isVendorRelatedFieldUpdated = PartnerProfileIntegration.isValueChanged(oldContact, newContact, bivendorFieldsToCompare);
                                }
                                else {
                                    isVendorRelatedFieldUpdated = PartnerProfileIntegration.isValueChanged(oldContact, newContact, grassrootsFieldsToCompare);
                                }
                            }
    
                            // Get contacts which satisfies condition for BOOMI integration              
                            if((newContact.Is_Update_Triggered_by_DL__c == false || (newContact.Is_Update_Triggered_by_DL__c == true && newContact.Is_Vendor_Update_Required__c == true) && isValidVendor && !Userinfo.getProfileId().contains('00eA0000000hNqF'))
                                && ((oldContact.Is_Enabled_for_Incentives__c != newContact.Is_Enabled_for_Incentives__c && newContact.Is_Enabled_for_Incentives__c == true)
                                    || (oldContact.Is_Enabled_for_Incentives__c != newContact.Is_Enabled_for_Incentives__c && newContact.Is_Enabled_for_Incentives__c == false && newContact.Vendor_Update_Datetime__c != null)
                                    || (newContact.Is_Vendor_Update_Required__c == true && newContact.Is_Vendor_Updated__c == false && newContact.Last_Operation_Performed__c == 'SFDC Updated' && (newContact.Vendor_Update_Datetime__c != null || newContact.Is_Enabled_for_Incentives__c == true)) // If the record is getting updated again and if BOOMI operation is not happend keep it like that
                                    || (newContact.Is_Enabled_for_Incentives__c  == true && isVendorRelatedFieldUpdated) // Any of the vendor synch fields are getting modified
                                )
                            ){
                                newContact.Is_Vendor_Update_Required__c = true;
                                newContact.Is_Vendor_Updated__c = false;
                                newContact.Last_Operation_Performed__c = 'SFDC Updated';
                                
                                if(newContact.Vendor_Update_Datetime__c != null) {
                                    /*
                                    if(oldContact.AccountId != newContact.AccountId && vendorName == 'Dell Achievers'){
                                        newContact.Operation_for_Boomi__c = 'MOVE_USER';
                                    }
                                    else{
                                    */
                                        newContact.Operation_for_Boomi__c = 'UPDATE_USER';
                                    //}
                                }
                                else if(newContact.Operation_for_Boomi__c == null) {
                                    newContact.Operation_for_Boomi__c = 'NEW_USER';
                                }
                                else {
                                    newContact.Operation_for_Boomi__c = newContact.Operation_for_Boomi__c;
                                }
                            
                                // Add condition checking to identify incentive flag change for BOOMI - CMI synch
                                if(oldContact.Is_Enabled_for_Incentives__c != newContact.Is_Enabled_for_Incentives__c || (newContact.Is_Vendor_Update_Required__c == true && newContact.Is_Vendor_Updated__c == false && newContact.Is_Incentives_Updated__c == true)) {
                                    newContact.Is_Incentives_Updated__c = true;
                                }
                                else {
                                    newContact.Is_Incentives_Updated__c = false;
                                }
                            }
                            else {
                                newContact.Is_Vendor_Update_Required__c = false;
                                newContact.Operation_for_Boomi__c = null;
                                
                                if(newContact.Is_Incentives_Updated__c == true && Userinfo.getProfileId().contains('00eA0000000hNqF')) {
                                    // If current user is BOOMI and if already marked as updated keep the value as such since CMI synch will be triggered only in after update
                                    newContact.Is_Incentives_Updated__c = true;
                                }
                                else {
                                    newContact.Is_Incentives_Updated__c = false;
                                }
                            }
    
                            // Check for BOOMI failue and if incentive flag is updated revert back the changes
                            if(newContact.Last_Operation_Performed__c == 'Vendor Sync failed' && Userinfo.getProfileId().contains('00eA0000000hNqF') && newContact.Is_Incentives_Updated__c == true) {
                                if(newContact.Is_Enabled_for_Incentives__c == true) {
                                    newContact.Is_Enabled_for_Incentives__c = false;
                                }
                                else{
                                    newContact.Is_Enabled_for_Incentives__c = true;
                                }
                            }
                        }
                    }
                }
                
                // Separated from ContactTrigger - Start
                if(newContact.External_Ref_ID__c != null || newContact.External_Ref_ID__c != '') {
                    if(newContact.OtherCity != oldContact.OtherCity 
                        || newContact.OtherCountry != oldContact.OtherCountry
                        || newContact.OtherState != oldContact.OtherState
                        || newContact.OtherStreet != oldContact.OtherStreet
                        || newContact.Other_Suburb__c != oldContact.Other_Suburb__c
                        || newContact.OtherPostalCode != oldContact.OtherPostalCode
                        || newContact.MailingCity != oldContact.MailingCity
                        || newContact.MailingCountry != oldContact.MailingCountry
                        || newContact.MailingState != oldContact.MailingState
                        || newContact.MailingStreet != oldContact.MailingStreet
                        || newContact.Mailing_Suburb__c != oldContact.Mailing_Suburb__c
                        || newContact.MailingPostalCode != oldContact.MailingPostalCode)
                    {
                        newContact.External_Ref_ID__c = '';
                    }
                }
                
                if(newContact.AccountId != oldContact.AccountId) {
                    newContact.Account_Changed__c = true;
                }
                // Separated from ContactTrigger - End
            }
        }
        catch(Exception e) {
            System.debug('Caught Exception in populateFieldsOnBeforeUpdate(): ' + e.getMessage());
            EmailUtils.sendSupportEmail(e.getMessage(), DellConfig.errorEmail);
        }
    }

    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR 10751    16.03       30-Dec-2014     Ragu            This logic is separated from contactTrigger trigger and rewritten as part of the trigger redesign.
    3.0         CR 17548    FY20-0702   24-May-2019     Fenny           as part of modulariation (DX), move addressChanged to GlobalVariables
    */
    public static void populateMailingAddressChanged(list<Contact> lstNewContacts) {
        for(Contact newContact : lstNewContacts) {
            newContact.Mailing_Address_Changed__c = true;
            // To skip recursive call
            //VFCtrl_AVSContactSuggestion.addressChanged = true;
            GlobalVariables.AVS_CONTACT_ADDRESS_CHANGED = true;
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR 10751    16.03       30-Dec-2014     Ragu            This logic is separated from contactTrigger trigger and rewritten as part of the trigger redesign.
    3.0         CR 17548    FY20-0702   24-May-2019     Fenny           as part of modulariation (DX), move addressChanged to GlobalVariables
    */
    public static void populateMailingAddressChanged(list<Contact> lstNewContacts, map<Id, Contact> mapOldContacts) {
        for(Contact newContact : lstNewContacts) {
            Contact oldContact = mapOldContacts.get(newContact.Id);
            //if(!VFCtrl_AVSContactSuggestion.addressChanged) {
            if(!GlobalVariables.AVS_CONTACT_ADDRESS_CHANGED) {
                newContact.Mailing_Address_Changed__c = false;
                
                if(newContact.MailingStreet != oldContact.MailingStreet || newContact.MailingCity != oldContact.MailingCity 
                    || newContact.MailingState != oldContact.MailingState || newContact.MailingPostalCode != oldContact.MailingPostalCode 
                    || newContact.MailingCountry != oldContact.MailingCountry) {
                    newContact.Mailing_Address_Changed__c = true;            
                }
            }
        }
    }
    
    /* 
    Revision    CR Number        Release No      Date            Modified By     Description
    --------    ---------        ----------      -----------     ------------    -----------
    5.0         CR11631/11643    16.07(MAJ-S-05) 24-June-2015    Jessie /Emily   Update 2 Lookup fields to Account according to the status of Contact record. 
    */
    public static void populateActiveInactiveLookupFieldsToAccount(list<Contact> lstNewContacts) {
    
        for(Contact newContact : lstNewContacts) {
            if(newContact.AccountId == null) {
                newContact.Account_Active_Contact__c= null;
                newContact.Account_Inactive_Contact__c= null;
            }
            else {
                if(newContact.Status__c =='Customer' || newContact.Status__c =='Active' || newContact.Status__c =='Prospect' || newContact.Status__c =='Marketing Suspect' || newContact.Status__c =='INTERNAL - Crisis Mgmt') {
                    newContact.Account_Active_Contact__c = newContact.AccountId;
                    newContact.Account_Inactive_Contact__c = null;  
                }
                else {
                    newContact.Account_Active_Contact__c= null;
                    newContact.Account_Inactive_Contact__c= newContact.AccountId;
                 }
            }    
        }
    }
    
    /* 
    Revision    CR Number        Release No      Date            Modified By     Description
    --------    ---------        ----------      -----------     ------------    -----------
    6.0         CR12724           0403            26-Mar-2016     Jessie         Modified to support the removal of 'Contact Duplication Check VF' and adoption of standard out-of-box Contact Duplication 
    */
    //populate some fields in contact with fields from Lead 
    public static void populateDataFromLead(list<Contact> lstNewContacts, Map<Id, Lead> mapRelatedLeads){
    
        Lead currentLead = null;
        
        for(Contact newContact : lstNewContacts) {
            
            currentLead = mapRelatedLeads.get(newContact.Source_Id__c);
            
            if(currentLead==null){
                continue;
            }
                
            if(currentLead.RecordType.Name == 'Lead Qualification' || currentLead.RecordType.Name == 'External Lead' || currentLead.RecordType.Name == 'Talk To Dell'){     
                                    
                if(currentLead.RecordType.Name == 'Lead Qualification' && newContact.EMEA_Preferred_Contact_Language__c==null){
                   newContact.EMEA_Preferred_Contact_Language__c=currentLead.language_code__c;
                }
                                
                else if(currentLead.RecordType.Name == 'External Lead' && newContact.fax==null){
                   newContact.fax=currentLead.Fax;
                }
                
                if(newContact.Title==null){                
                    newContact.Title=currentLead.Title;
                }
                
                if(newContact.mailingstreet==null){
                    newContact.mailingstreet=currentLead.street;
                }
                
                if(newContact.mailingcity==null){
                    newContact.mailingcity=currentLead.city;
                }
                
                if(newContact.mailingstate==null){
                    newContact.mailingstate=currentLead.state;
                }
                
                if(newContact.mailingcountry==null){
                    newContact.mailingcountry=currentLead.country;
                }
                
                if(newContact.mailingpostalcode==null){
                    newContact.mailingpostalcode=currentLead.postalcode;
                }
                
                if(newContact.Purchaser_Influence_over_Merged__c==null){
                    newContact.Purchaser_Influence_over_Merged__c=currentLead.Purchase_Influence_Over__c;
                }
                
                if(newContact.Email_Opt_in__c==null){
                    newContact.Email_Opt_in__c=currentLead.Email_Opt_in__c;
                }
                    
                if(newContact.Phone_Opt_In__c==null){
                    newContact.Phone_Opt_In__c=currentLead.Phone_Opt_In__c;
                }
                
                if(newContact.Fax_Opt_In__c==null){
                    newContact.Fax_Opt_In__c=currentLead.Fax_Opt_In__c;
                }
                
                if(newContact.Mail_Opt_In__c==null){
                    newContact.Mail_Opt_In__c=currentLead.Mail_Opt_In__c;
                }
                
                if(newContact.Contact_Source__c==null){
                    newContact.Contact_Source__c=currentLead.LeadSource;                      
                }
                                                                         
            }
            
        }
    }

}