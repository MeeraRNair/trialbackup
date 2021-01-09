/*
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities which are related to Contact object. 
*          Please create separate classes and use it for complex logics.
*        
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR10751     16.03       20-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
* 2.0      15529                   15-Mar-2018     Sakshi          Reducing Code
* -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
* Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
*/

public class ContactUtilities {
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0         CR10751     16.03       20-Dec-2014     Ragu            This logic is separated from DealSummaryContact trigger and rewritten as part of trigger redesign.
3.0         CR13024    DCS-0502    20-Apr-2016     Sazleen         Commented inaccurate NPS_Qualified_Contacts__c formula in method updateNPSQualifiedContactsOnAccount. Added NPS_Qualified_Contacts__c field update in this method line43
*/
    public static void rollupQualifiedNPSContacts(map<Id, Contact> mapNewContacts, map<Id, Contact> mapOldContacts, ContactTriggerHandler conTriggerHandler) {
        
        set<Id> setAccountIds = new set<Id>();
        
        for(Contact newContact : mapNewContacts.values()) {
            if((newContact.Status__c == 'Customer' && newContact.Decision_Making_Role__c != null && 
                newContact.Decision_Making_Role__c != 'Business User' && newContact.Decision_Making_Role__c != 'Unknown' && newContact.Email != null 
                && ((newContact.Survey__c == 'Yes') )) || conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) { 
                    setAccountIds.add(newContact.AccountId);
                }
        }
        
        if(!setAccountIds.isEmpty()) {
            list<Account> lstAccounts = [select Id, (select AccountId from Contacts where Survey__c = 'Yes' and Status__c = 'Customer' and Decision_Making_Role__c != 'Business User' and Decision_Making_Role__c != 'Unknown' and Decision_Making_Role__c != null and Email != null) from Account where Id in :setAccountIds];
            list<Account> lstAccountsToUpdate = new list<Account>();
            for(account accIterator : lstAccounts) {
                Integer iRowCount = 0;
                if(accIterator.Contacts != null) {
                    iRowCount = accIterator.Contacts.size();
                }
                lstAccountsToUpdate.add(new Account(Id = accIterator.Id, No_of_Qualified_NPS_Contacts__c = iRowCount, NPS_Qualified_Contacts__c = iRowCount));
            }
            try {
                update lstAccountsToUpdate;          
            }
            catch(DMLException e) {
                system.debug(e);
            }
        }
    }
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0         CR10751     16.03       20-Dec-2014     Ragu            This logic is separated from contactTriggerAfterUpdate trigger and rewritten as part of trigger redesign.
*/
    public static void updatePartnerRequest(map<Id, Contact> mapNewContacts, map<Id, Account> mapRelatedAccounts) {
        try {
            Id updateUserRTId = StaticFactory.getRecordTypeIdByName('Partner_Request__c', PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER);
            Id newUserRTId = StaticFactory.getRecordTypeIdByName('Partner_Request__c', PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER);
            
            // Query and get Country code map
            PartnerCountry partCountry = new PartnerCountry();
            map<String, Country__c> mapCountryCodeCountry = partCountry.returnCountryCodeMap();
            
            // Get the Partner Request Status based on Contact Id
            list<Partner_Request__c> lstPartnerRequests = new list<Partner_Request__c>();
            for(Partner_Request__c partnerRequest : [select Id, Status__c, Contact__c, RecordTypeId 
                                                     from Partner_Request__c where (Status__c = :PartnerConstants.REG_STATUS_INCOMPLETE or Status__c = :PartnerConstants.REG_STATUS_DRAFT) 
                                                     and (RecordTypeId = :updateUserRTId or RecordTypeId = :newUserRTId)
                                                     and Contact__r.Vendor_Update_Datetime__c != null and Contact__c in :mapNewContacts.KeySet()]) { 
                                                         Contact newContact = mapNewContacts.get(partnerRequest.Contact__c);
                                                         
                                                         // Get vendor name
                                                         String strVendorName;
                                                         if(mapRelatedAccounts.get(newContact.AccountId).Account_Country_Code__c != null) {
                                                             Country__c country = mapCountryCodeCountry.get(StringUtils.upperCase((mapRelatedAccounts.get(newContact.AccountId).Account_Country_Code__c).trim()));
                                                             if(country != null) {
                                                                 strVendorName = country.Inc_Vendor_Name__c;
                                                             }
                                                         }
                                                         // Do checking here
                                                         if(partnerRequest.Status__c == PartnerConstants.REG_STATUS_DRAFT && newContact.Last_Operation_Performed__c == 'Vendor Updated' && !(strVendorName == 'Dell Achievers' && partnerRequest.RecordTypeId == newUserRTId)) {
                                                             partnerRequest.Status__c = PartnerConstants.REG_STATUS_COMPLETE;
                                                             lstPartnerRequests.add(partnerRequest);
                                                         }
                                                         else if((partnerRequest.Status__c == PartnerConstants.REG_STATUS_DRAFT || partnerRequest.Status__c == PartnerConstants.REG_STATUS_INCOMPLETE) && newContact.Last_Operation_Performed__c == 'Vendor Sync failed') {
                                                             partnerRequest.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
                                                             if(String.isBlank(partnerRequest.Description__c)) 
                                                                 partnerRequest.Description__c = 'Vendor Sync failed';
                                                             else 
                                                                 partnerRequest.Description__c += '\n' + 'Vendor Sync failed';
                                                             
                                                             lstPartnerRequests.add(partnerRequest);
                                                         }
                                                     }
            if(!lstPartnerRequests.isEmpty())
                update lstPartnerRequests;
        }
        catch(Exception e) {
            System.debug('Caught APEX Exception : ' + e.getMessage());
            EmailUtils.sendSupportEmail(e.getMessage(), DellConfig.errorEmail);
        }
    }
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR 7308     13.10       26-Jul-2012     Jagadeesan      Populate Contact Id to lead when contact is created from lead
2.0         CRQ 0775    14.10       12-Sep-2013     Annie           CMAP - Convert to contact from Channel Lead -- Bug Fix
3.0         CR 10731    16.03       06-Dec-2014     Jiji            CMAP - Modify Lead Status  from 'Sent to Nurturing' to 'Sent to Nurturing - Dell'
4.0         CR 10751    16.03       20-Dec-2014     Ragu            This logic is separated from afterInsertUpdateContactTrigger trigger and rewritten as part of trigger redesign.
5.0         CR 11918    16.10       03-Sep-2015     Syidah          Changes for allowing creation of Contact from Channel Lead 2.0 page layout.
*/
    public static void associateContactToChannelLead(map<Id, Contact> mapNewContacts) {
        map<String, Contact> mapSourceIdContact = new map<String, Contact>();
        for(Contact conIterator : mapNewContacts.values()) {
            if(conIterator.Source_Id__c != null) 
                mapSourceIdContact.put(conIterator.Source_Id__c, conIterator);
        }
        // v2.0 Start
        Id leadSubmissionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');
        Id leadAssignmentRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
        Id leadcleansingRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
        Id leadConversionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Conversion');
        Id leadChannel2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0'); // v5.0
        set<Id> setChannelLeadRTIds = new set<Id>{leadSubmissionRTId, leadAssignmentRTId, leadcleansingRTId, leadConversionRTId, leadChannel2RTId};
            // v2.0 End
            list<Lead> lstLeads = new list<Lead>();
        for(Lead leadIterator : [select Id, Contact__c, Related_Contact__c, Status, RecordTypeId From Lead where Id in :mapSourceIdContact.keyset()]) {
            Contact conInstance = mapSourceIdContact.get(leadIterator.Id);
            // v2.0 Start
            // v3.0 - Updated Lead Status value from 'Sent to Nurturing' to 'Sent to Nurturing - Dell'
            if(((leadIterator.RecordTypeId == leadSubmissionRTId || leadIterator.RecordTypeId == leadChannel2RTId) && leadIterator.Status == 'Open - Channel Lead')
               || (leadIterator.RecordTypeId == leadcleansingRTId && (leadIterator.Status == 'Qualified - Channel Ready' || leadIterator.Status == 'Sent to Nurturing - Dell'))
               || (leadIterator.RecordTypeId == leadConversionRTId && leadIterator.Status == 'Won by Channel Partner')
               || (setChannelLeadRTIds.contains(leadIterator.RecordTypeId) && leadIterator.Status == 'Converted to Deal Reg')) {
                   leadIterator.Related_Contact__c = conInstance.Id;
               } // v2.0 End
            else {
                leadIterator.Contact__c = conInstance.Id;
            }
            lstLeads.add(leadIterator);
        }
        if(!lstLeads.isEmpty()) {
            try {
                update lstLeads;
            }
            catch(Exception e) {
                System.debug('Caught APEX Exception : ' + e.getMessage());
            }
        }
    }
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0                                 27-Sep-2012     Jagadeesan      TT# REQ000008013891 To change the RL to appropriate Account of Contact when Account in Contact gets updated
2.0         CR10751     16.03       20-Dec-2014     Ragu            This logic is separated from afterInsertUpdateContactTrigger trigger and rewritten as part of trigger redesign.
*/
    public static void updateAccountInRelationshipLead(map<Id, Contact> mapNewContacts, map<Id, Contact> mapOldContacts) {
        map<Id, Contact> mapAccountChangedContacts = new map<Id, Contact>();
        
        for(Contact newContact : mapNewContacts.values()) {
            if(newContact.AccountId != mapOldContacts.get(newContact.Id).AccountId) 
                mapAccountChangedContacts.put(newContact.Id, newContact);
        }
        
        if(!mapAccountChangedContacts.isEmpty()) {
            list<Relationship_lead__c> lstRelationshipLeads = [select Id, Account_Name__c, Contact__c from Relationship_Lead__c where Contact__c in :mapAccountChangedContacts.keySet()];
            for(Relationship_Lead__c relationshipLead : lstRelationshipLeads) {
                relationshipLead.Account_Name__c = mapAccountChangedContacts.get(relationshipLead.Contact__c).AccountId;
            }
            try {
                if(!lstRelationshipLeads.isEmpty())
                    update lstRelationshipLeads;
            }
            catch(Exception e) {
                System.debug('Caught APEX Exception : ' + e.getMessage());
            }
        }
    }
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR6029                  11-Apr-2012     Manju           Allow for Data Loading on Primary Contact. This trigger updates the corresponding Account with the Primary Contact of a Contact set to TRUE.
2.0         CR7594      13.10       30-Nov-2012     Krishnamoorthi  Allow for Data Loading on Primary Contact -- Bug fix
3.0         CR10751     16.03       20-Dec-2014     Ragu            This logic is separated from afterInsertUpdateContactTrigger trigger and rewritten as part of trigger redesign.
*/
    public static void checkAndUpdatePrimaryContactDetails(map<Id, Contact> mapNewContacts, map<Id, Contact> mapOldContacts) {
        set<Id> setProcessedAccIds = new set<Id>();
        map<Id, Id> mapAccountPrimaryContact = new map<Id, Id>();
        map<Id, set<Id>> mapAccountNonPrimaryContacts = new map<Id, set<Id>>();
        for(Contact newContact : mapNewContacts.values()) {
            
            if(newContact.Primary_Contact__c != mapOldContacts.get(newContact.Id).Primary_Contact__c && newContact.AccountId != null) {
                if(newContact.Primary_Contact__c == true) {
                    if(mapAccountPrimaryContact.keySet().contains(newContact.AccountId)) 
                        newContact.addError('An account cannot have more than 1 Primary Contact');
                    else 
                        mapAccountPrimaryContact.put(newContact.AccountId, newContact.Id);  
                }
                else {
                    if(mapAccountNonPrimaryContacts.keySet().contains(newContact.AccountId)) 
                        mapAccountNonPrimaryContacts.get(newContact.AccountId).add(newContact.Id); 
                    else 
                        mapAccountNonPrimaryContacts.put(newContact.AccountId, new set<Id>{newContact.Id});
                }
                setProcessedAccIds.add(newContact.AccountId);      
            }
        }
        if(!setProcessedAccIds.isEmpty()) 
            AccountUtils.accountUpdate(setProcessedAccIds, mapAccountPrimaryContact, mapAccountNonPrimaryContacts);
    }
    /* 
Revision    CR Number   Release No    Date            Modified By     Description
--------    ---------   ----------    -----------     ------------    -----------
1.0         CR 1616                   16-Jul-2009     Raymond Yip     On Update, send information to Partner Profile
2.0         CR 2568                   30-Apr-2010     
3.0         CR 10751    16.03         01-Jan-2015     Ragu            This logic is separated from afterUpdateContactTrigger trigger and rewritten as part of trigger redesign.
4.0         CR 16007    FY19-DCS-0802 6-June-2018     khanm37         Removed (Provisioned_in_Netexam_on__c) Story# 4988554
*/
    public static void integratePartnerDataHelper(map<Id, Contact> mapNewContacts, map<Id, Contact> mapOldContacts) {
        try {
            // Raymond 2421 - skip if set to by pass
            list<String> setContactIds = new list<String>();
            list<String> fieldToCompare = new list<String> {
                'AccountId', 'Is_Rebate_User__c', 'Campaign_Builder__c',
                    'Transactional_Store__c', 'Warranty_Parts_Info__c', 'Premier_Partner__c'    
                    };
                        
                        // [Krishna 8-Mar-2010] functionality for updateKey call CR2431. Involves asynchrounous call
                        set<Id> updateKeyFilterSet = PartnerProfileIntegration.processUpdateKeyRequestForAcctChange(mapNewContacts, mapOldContacts, mapNewContacts.KeySet());
            // Filtering contacts with non-partner Account
            set<Id> setContactIdsFilter1 = PartnerProfileIntegration.filterNonPartnerAccountContact(updateKeyFilterSet);
            // Filtering contacts that are not tied to user
            set<Id> setContactIdsFilter2 = PartnerProfileIntegration.filterNonPartnerUserContact(setContactIdsFilter1);
            
            // Rev 2.0 - Start
            map<Id, Contact> triggerFilteredNewMap = new map<Id, Contact>();
            map<Id, Contact> triggerFilteredOldMap = new map<Id, Contact>();
            if(!setContactIdsFilter2.isEmpty()) {
                for(Id contactId : setContactIdsFilter2) {
                    Contact newContact = mapNewContacts.get(contactId);
                    Contact oldContact = mapOldContacts.get(contactId);
                    
                    triggerFilteredNewMap.put(contactId, newContact);
                    triggerFilteredOldMap.put(contactId, oldContact);
                    
                    // 14.2SSO Changes for calling CMI on Successful Vendor update
                    if(UserInfo.getProfileId().contains('00eA0000000hNqF')
                       && newContact.Is_Incentives_Updated__c == true && oldContact.Is_Vendor_Updated__c != newContact.Is_Vendor_Updated__c
                       && newContact.Is_Vendor_Updated__c == true && newContact.Last_Operation_Performed__c == 'Vendor Updated') {
                           // Add contact id to list
                           setContactIds.add(contactId);
                       }
                }
                setContactIds.addAll(PartnerProfileIntegration.valueChangedList(triggerFilteredOldMap, triggerFilteredNewMap, fieldToCompare));
            }
            // Rev 2.0 - End
            Integer iContactsProcessed = 0;
            list<String> lstContactIds = new list<String>();
            // Rev 2.0
            for(String contactId : setContactIds) {
                lstContactIds.add(contactId);
                iContactsProcessed++;
                
                if(lstContactIds.size() == 10 || iContactsProcessed == setContactIdsFilter2.size()) {
                    System.debug('BEFORE LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
                    if(Limits.getFutureCalls() >= Limits.getLimitFutureCalls()) {
                        for(Id tempContactId : lstContactIds) 
                            mapNewContacts.get(tempContactId).addError('Updates of Partner Contacts has hit Salesforce.com FutureCall Limit.');
                    }
                    else {
                        PartnerProfileIntegration.integratePartnerData(lstContactIds);
                    }
                    System.debug('AFTER LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
                    lstContactIds.clear();
                }
            }
        }
        catch(Exception e) {
            System.debug('Caught APEX Exception in integratePartnerDataHelper(): ' + e.getMessage());
            EmailUtils.sendSupportEmail(e.getMessage(), DellConfig.errorEmail);
        }
    }
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0         CR 7875     14.2        06-Dec-2012     Meera           SSO Changes 
3.0         CRQ 0665    14.2        24-Feb-2013     Meera           SSO 
4.0         CR 10751    16.03       01-Jan-2015     Ragu            This logic is separated from afterUpdateContactTrigger trigger and rewritten as part of trigger redesign.
5.0                                 08-May-2018     Rahul           Commenting out this functionality.
*/
    /*    public static void ssoVendorAssociationHelper(map<Id, Contact> mapNewContacts, map<Id, Contact> mapOldContacts, map<Id, Account> mapRelatedAccounts) {
try {
final Integer BATCH_SIZE = 10;
PartnerCountry partCountry = new PartnerCountry();
map<String, Country__c> mapCountries = partCountry.returnCountryCodeMap();
map<String, String> mapCountryNameCode = new map<String, String>{'INDIA' => 'IND', 'CHINA' => 'CHN', 'AUSTRALIA' => 'ANZ', 'NEW ZEALAND' => 'ANZ'};

set<Id> updateKeyFilterSet = PartnerProfileIntegration.processUpdateKeyRequestForAcctChange(mapNewContacts, mapOldContacts, mapNewContacts.KeySet());
// Filtering contacts with non-partner Account
set<Id> setContactIdsFilter1 = PartnerProfileIntegration.filterNonPartnerAccountContact(updateKeyFilterSet);
// Filtering contacts that are not tied to user
set<Id> setContactIdsFilter2 = PartnerProfileIntegration.filterNonPartnerUserContact(setContactIdsFilter1);

if(setContactIdsFilter2 != null && !setContactIdsFilter2.isEmpty() && UserInfo.getProfileId().contains('00eA0000000hNqF')) { // Current user is BOOMI integration user
// Check for new user which is success in Vendor system and which is part of grassroots
map<String, String> mapGUIDAccountCode = new map<String, String>();
map<String, String> mapGUIDContactId = new map<String, String>();     

for(String contactId : setContactIdsFilter2) {
Contact newContact = mapNewContacts.get(contactId);
Contact oldContact = mapOldContacts.get(contactId);
Account relatedAccount = mapRelatedAccounts.get(newContact.AccountId);

if(relatedAccount != null && relatedAccount.Account_Country_Code__c != null) {
Country__c country = mapCountries.get(StringUtils.upperCase(relatedAccount.Account_Country_Code__c.trim()));

if(country != null) {
String strVendorName = country.Inc_Vendor_Name__c;
if(strVendorName == 'Dell Achievers' && oldContact.Vendor_Update_Datetime__c != newContact.Vendor_Update_Datetime__c && oldContact.Vendor_Update_Datetime__c == null
&& newContact.Is_Vendor_Updated__c == true && newContact.Last_Operation_Performed__c == 'Vendor Updated') {
String strAccountCode = mapCountryNameCode.get(StringUtils.upperCase(country.Name)) + relatedAccount.Account_Id__c;
mapGUIDAccountCode.put(newContact.Partner_My_Account_GUID__c, strAccountCode);
mapGUIDContactId.put(newContact.Partner_My_Account_GUID__c, contactId);
}  
}
}
}
if(!mapGUIDAccountCode.isEmpty()) {
Integer iContactsProcessed = 0;
map<String, String> mapGUIDAccountCodeTemp = new map<String, String>();

// Call association integration method after checking limit
for(String strGUID : mapGUIDAccountCode.keySet()) {
iContactsProcessed++;
mapGUIDAccountCodeTemp.put(strGUID, mapGUIDAccountCode.get(strGUID));

if(mapGUIDAccountCodeTemp.size() == BATCH_SIZE || iContactsProcessed == mapGUIDAccountCode.size()) {
System.debug('BEFORE LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
if(Limits.getFutureCalls() >= Limits.getLimitFutureCalls()) {
for(Id tempGUID : mapGUIDAccountCodeTemp.keySet()) {
mapNewContacts.get(mapGUIDContactId.get(tempGUID)).addError('Updates of Partner Contacts has hit Salesforce.com FutureCall Limit.');    
}
}
else {
SSOVendorAssociation.associateContacttoAccount(mapGUIDAccountCodeTemp);
}
System.debug('AFTER LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
mapGUIDAccountCodeTemp.clear();
}
}
}
}

// When Account id is getting updated for Contact call DELETE and PUT method for grassroots
// Filtering contacts with non-partner Account
set<Id> setConIdsFilter1 = PartnerProfileIntegration.filterNonPartnerAccountContact(mapNewContacts.keySet());
// Filtering contacts that are not tied to user
set<Id> setConIdsFilter2 = PartnerProfileIntegration.filterNonPartnerUserContact(setConIdsFilter1);

if(setConIdsFilter2 != null && !setConIdsFilter2.isEmpty()) {
map<String, String> mapNewGUIDAccCode = new map<String, String>();
map<String, String> mapOldGUIDAccCode = new map<String, String>();
map<String, String> mapGUIDContactId = new map<String, String>();

for(String contactId : setConIdsFilter2) {
Contact newContact = mapNewContacts.get(contactId);
Contact oldContact = mapOldContacts.get(contactId);

if(newContact.Vendor_Update_Datetime__c != null && oldContact.AccountId != newContact.AccountId) {
Account relatedNewAccount = mapRelatedAccounts.get(newContact.AccountId);
Account relatedOldAccount = mapRelatedAccounts.get(oldContact.AccountId);

if(relatedNewAccount.Account_Country_Code__c != null) {
Country__c newCountry = mapCountries.get(StringUtils.upperCase(relatedNewAccount.Account_Country_Code__c.trim()));
Country__c oldCountry = mapCountries.get(StringUtils.upperCase(relatedOldAccount.Account_Country_Code__c.trim()));

if(newCountry != null && oldCountry != null) {
String strVendorNameNew = newCountry.Inc_Vendor_Name__c;
String strVendorNameOld = oldCountry.Inc_Vendor_Name__c;

if(strVendorNameNew == 'Dell Achievers' && strVendorNameOld == 'Dell Achievers') {
String newAccountCode = mapCountryNameCode.get(StringUtils.upperCase(newCountry.Name)) + relatedNewAccount.Account_Id__c;
String oldAccountCode = mapCountryNameCode.get(StringUtils.upperCase(oldCountry.Name)) + relatedOldAccount.Account_Id__c;
mapNewGUIDAccCode.put(newContact.Partner_My_Account_GUID__c, newAccountCode);
mapOldGUIDAccCode.put(oldContact.Partner_My_Account_GUID__c, oldAccountCode);
mapGUIDContactId.put(newContact.Partner_My_Account_GUID__c, contactId);
}
}
}
}
}

// Call integration
if(!mapNewGUIDAccCode.isEmpty() && !mapOldGUIDAccCode.isEmpty()) {
Integer iContactsProcessed = 0;
map<String, String> mapNewGUIDAccCodeTemp = new map<String, String>();
map<String, String> mapOldGUIDAccCodeTemp = new map<String, String>();

// Call association integration method after checking limit
for(String strGUID : mapNewGUIDAccCode.keySet()) {
iContactsProcessed++;
mapNewGUIDAccCodeTemp.put(strGUID, mapNewGUIDAccCode.get(strGUID));
mapOldGUIDAccCodeTemp.put(strGUID, mapOldGUIDAccCode.get(strGUID));

// Ragu: Marker (Valid thru 16.03) - Changed batch size from 5 to 10
if(mapNewGUIDAccCodeTemp.size() == BATCH_SIZE || iContactsProcessed == mapNewGUIDAccCode.size()) {
System.debug('BEFORE LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
if(Limits.getFutureCalls() >= Limits.getLimitFutureCalls()) {
for(Id tempGUID : mapNewGUIDAccCodeTemp.keySet()) {
mapNewContacts.get(mapGUIDContactId.get(tempGUID)).addError('Updates of Partner Contacts has hit Salesforce.com FutureCall Limit.');    
}
}
else {
SSOVendorAssociation.dissassociateandassociateContacttoAccount(mapNewGUIDAccCodeTemp,mapOldGUIDAccCodeTemp);
}
System.debug('AFTER LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
mapNewGUIDAccCodeTemp.clear();
mapOldGUIDAccCodeTemp.clear();
}
}
}
}
}
catch(Exception e) {
System.debug('Caught APEX Exception in ssoVendorAssociationHelper(): ' + e.getMessage());
EmailUtils.sendSupportEmail(e.getMessage(), DellConfig.errorEmail);
}
}*/
    /*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         CR11561     16.07(MAJ-S-03) 04-Jun-2015     Krishnamoorthi  Method to populate 8 fields from Contact record to Support Request as per user story 162173 
*/
    public static void populateSolutionArchitectInformation(Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap){
        set<Id> conIdSet = new set<Id>();
        list<Support_Request__c> srToUpdateList = new list<Support_Request__c>();
        
        if(newContactMap != null && newContactMap.size() >0 && oldContactMap != null && oldContactMap.size() >0) {
            for(Contact c : newContactMap.values()) {
                if(c.FirstName != oldContactMap.get(c.Id).FirstName || c.LastName != oldContactMap.get(c.Id).LastName || c.Phone != oldContactMap.get(c.Id).Phone || c.Email != oldContactMap.get(c.Id).Email || c.MailingStreet != oldContactMap.get(c.Id).MailingStreet || c.MailingCity != oldContactMap.get(c.Id).MailingCity || c.MailingState != oldContactMap.get(c.Id).MailingState || c.MailingCountry != oldContactMap.get(c.Id).MailingCountry) {
                    conIdSet.add(c.Id);
                }
            }
            
            if(conIdSet != null) {
                // Check for associated Support Request record and populate the values
                for(Support_Request__c sr :[SELECT Customer_Contact_InformationName__c, Customer_Contact_Information_Name__c, 
                                            Customer_Contact_Information_Phone__c, Customer_Contact_Information_Email__c, 
                                            Primary_Work_Delivery_Address_1__c, Primary_Work_Delivery_City__c, Primary_Work_Delivery_State_Province__c,
                                            Primary_Work_Delivery_Country__c FROM Support_Request__c WHERE Customer_Contact_InformationName__c IN: conIdSet]) {
                                                
                                                if(newContactMap.get(sr.Customer_Contact_InformationName__c).FirstName == null) {
                                                    sr.Customer_Contact_Information_Name__c = newContactMap.get(sr.Customer_Contact_InformationName__c).LastName;
                                                } 
                                                else {
                                                    sr.Customer_Contact_Information_Name__c = newContactMap.get(sr.Customer_Contact_InformationName__c).FirstName + ' ' + newContactMap.get(sr.Customer_Contact_InformationName__c).LastName;
                                                }
                                                sr.Customer_Contact_Information_Phone__c = newContactMap.get(sr.Customer_Contact_InformationName__c).Phone;
                                                sr.Customer_Contact_Information_Email__c = newContactMap.get(sr.Customer_Contact_InformationName__c).Email;
                                                sr.Primary_Work_Delivery_Address_1__c = newContactMap.get(sr.Customer_Contact_InformationName__c).MailingStreet;
                                                sr.Primary_Work_Delivery_City__c = newContactMap.get(sr.Customer_Contact_InformationName__c).MailingCity;
                                                sr.Primary_Work_Delivery_State_Province__c = newContactMap.get(sr.Customer_Contact_InformationName__c).MailingState;
                                                sr.Primary_Work_Delivery_Country__c = newContactMap.get(sr.Customer_Contact_InformationName__c).MailingCountry;
                                                
                                                srToUpdateList.add(sr);
                                            }   
            }
            if(srToUpdateList.size() > 0) {
                SupportRequestUtil.SKIP_SUPPORT_REQUEST_TRIGGERS = true;
                update srToUpdateList;
                SupportRequestUtil.SKIP_SUPPORT_REQUEST_TRIGGERS = false;   
            }
        }   
    }
    /*
Revision    CR Number   Release No      Date            Modified By     Descriptions
--------    ---------   ----------      -----------     ------------    -----------
1.0         12106       16.10           XX-XXX-2015     Prateek         197226 & 194540 : Create Oppty and Contact from CTI Call Log 
*/
    public static void updateCTICallLog(TriggerHandler.TriggerEvent trigEvent, list<Contact> lstContacts, map<Id, sObject> mapOldContacts){
        Map<id, Contact> mapCTIIdToContact = new Map<Id, Contact>();
        
        if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
            for(Contact objCon : lstContacts){
                if(objCon.CTI_Call_Log_Id__c != null)
                    mapCTIIdToContact.put(objCon.CTI_Call_Log_Id__c, objCon);
            }
        }
        if(!mapCTIIdToContact.keySet().isEmpty()){
            Map<Id, CTI_Call_Log__c> mapCTIIdToCTI = new Map<Id, CTI_Call_Log__c>([SELECT Id, Account__c, Contact__c FROM CTI_Call_Log__c WHERE Id IN : mapCTIIdToContact.keySet()]);
            List<CTI_Call_Log__c> lstCTICallLog = new List<CTI_Call_Log__c>();
            for(Id objCTIId : mapCTIIdToCTI.keySet()){               
                if(mapCTIIdToContact.containsKey(objCTIId)){
                    mapCTIIdToCTI.get(objCTIId).Contact__c = mapCTIIdToContact.get(objCTIId).Id;
                    mapCTIIdToCTI.get(objCTIId).Account__c = mapCTIIdToContact.get(objCTIId).AccountId;
                    lstCTICallLog.add(mapCTIIdToCTI.get(objCTIId));
                }
            }
            if(!lstCTICallLog.isEmpty())
                update lstCTICallLog;
        }
    }    
    /*
     * Added on Dec 2018
     * Added by Sneha
    * This method is to give access to Sales Motion Accounts related to a track
    */
public static void grantRevokeAccess(Map<Id,Contact> mapNewContacts,Map<Id,Contact> mapOldContacts){
        System.debug('grantRevokeAccess::');
        System.debug('mapOldContacts::'+mapOldContacts+'mapNewContacts::'+mapNewContacts);
        Map<String, List<String>> mapUsrPTAdd = new Map<String, List<String>>();
        Map<String, List<String>> mapUsrPTRemove = new Map<String, List<String>>();
        //To hold all the User Ids
        Set<String> setUsrIds = new Set<String>();
        // To hold the List of Partner Tracks
        Set<String> setPTS = new Set<String>();
        // Map to hold Partner Track Vs Sales Motion Account Ids
        Map<String, List<String>> mapPTToSM = new Map<String, List<String>>();
        // Map to hold the User id Vs Sales Motion Accounts
        Map<String, List<String>> mapUsrIdToSMAdd = new Map<String, List<String>>();
        // Map to hold the User id Vs Sales Motion Accounts
        Map<String, List<String>> mapUsrIdToSMRemove = new Map<String, List<String>>();
        List<String> listoldContactEligibleTracks = new List<String>();
        List<String> listnewContactEligibleTracks = new List<String>();
        //To hold the existing Account Share records
        List<AccountShare> listAccShareExists = new List<AccountShare>();
        // To hold the Account Share to insert
        List<AccountShare> listAccShareInsert = new List<AccountShare>();
        // To hold the Account Share to delete
        List<AccountShare> listAccShareDel = new List<AccountShare>();
        // Map to hold the User id Vs Sales Motion Accounts to send to batch class
        Map<String, List<String>> mapUsrIdToSMGrant = new Map<String, List<String>>();
        // Map to hold the User id Vs Sales Motion Accounts to send to batch class
        Map<String, List<String>> mapUsrIdToSMRevoke = new Map<String, List<String>>();
       // To hold the Eligible tracks modified Contacts
        Set<Contact> setCon = new Set<Contact>();
        if(mapNewContacts!= null && mapNewContacts.size() > 0){
            for(Contact con: mapNewContacts.values()){
                if(mapNewContacts.get(con.Id).EligibleTracks__c != mapOldContacts.get(con.Id).EligibleTracks__c){
                    System.debug('mapNewContacts.get(con.Id).EligibleTracks__c' + mapNewContacts.get(con.Id).EligibleTracks__c);
                    if(mapOldContacts!= null && String.isNotBlank(mapOldContacts.get(con.Id).EligibleTracks__c)){
                        if(mapOldContacts.get(con.Id).EligibleTracks__c.contains(';')){
                            listoldContactEligibleTracks = mapOldContacts.get(con.Id).EligibleTracks__c.trim().split(';');
                        }
                        else{
                            listoldContactEligibleTracks.add(mapOldContacts.get(con.Id).EligibleTracks__c.trim());
                        }
                        
                    }
                    System.debug('New Contact -> EligibleTracks__c');
                    if(String.isNotBlank(mapNewContacts.get(con.Id).EligibleTracks__c)){
                        if(mapNewContacts.get(con.Id).EligibleTracks__c.contains(';')){
                            listnewContactEligibleTracks = mapNewContacts.get(con.Id).EligibleTracks__c.trim().split(';');
                        }
                        else{
                            listnewContactEligibleTracks.add(mapNewContacts.get(con.Id).EligibleTracks__c.trim());
                        }
                    }
                    System.debug('listoldContactEligibleTracks::'+listoldContactEligibleTracks);
                    System.debug('listnewContactEligibleTracks::'+listnewContactEligibleTracks);
                    // During Update
                    // old - 1,2,3
                    // new - 2,3,4        
                    if(listoldContactEligibleTracks.size() > 0 && listnewContactEligibleTracks.size() >0){
                        System.debug('During Updation');
                        if(listoldContactEligibleTracks.equals(listnewContactEligibleTracks)){
                            System.debug('No Change to Eligible Tracks');
                        }
                        else{
                            System.debug('Eligible Tracks Changes:');
                            for(String strEligibleTracks : listnewContactEligibleTracks){
                                System.debug('eligibleTracks'+strEligibleTracks);
                                if(listoldContactEligibleTracks.contains(strEligibleTracks)){
                                    System.debug('Operation: Add : Do nothing');
                                }
                                else{
                                    // new eligible track is added
                                    // operation - add
                                    System.debug('Operation Add Else Part'+con.Partner_User__c);
                                    setPTS.add(strEligibleTracks);
                                    setCon.add(con);
                                    if(mapUsrPTAdd.containsKey(con.Partner_User__c)){
                                        mapUsrPTAdd.get(con.Partner_User__c).add(strEligibleTracks);
                                    }
                                    else{
                                        mapUsrPTAdd.put(con.Partner_User__c, new List<String>{(strEligibleTracks)});
                                    }
                                    System.debug('mapUsrPTAdd'+mapUsrPTAdd);  
                                }
                            }
                            for(String strEligibleTracks : listoldContactEligibleTracks){
                                if(listnewContactEligibleTracks.contains(strEligibleTracks)){
                                    System.debug('Operation: Remove : Do nothing');
                                }
                                else{
                                    // new eligible track is added
                                    // operation - Remove
                                    System.debug('Operation Remove Else Part'+con.Partner_User__c);
                                    setPTS.add(strEligibleTracks);
                                    if(mapUsrPTRemove.containsKey(con.Partner_User__c)){
                                        mapUsrPTRemove.get(con.Partner_User__c).add(strEligibleTracks);
                                    }
                                    else{
                                        mapUsrPTRemove.put(con.Partner_User__c, new List<String>{(strEligibleTracks)});
                                    }
                                    System.debug('mapUsrPTRemove'+mapUsrPTRemove);
                                    System.debug('setPTS'+setPTS);
                                }
                                
                            }
                        }
                    }
                }
            }
            System.debug('mapUsrPTAdd size:'+mapUsrPTAdd.size());
            System.debug('mapUsrPTRemove size:'+mapUsrPTRemove.size());
             // To send email notifications 
            if(setCon.size() > 0){
                System.debug('setCon'+setCon.size()+'mapUsrPTAdd::'+mapUsrPTAdd.keySet());
                sendMailOnAdditionOfNewTrack(setCon, mapUsrPTAdd);  
            }
            if(setPTS.size() > 0){
                List<Account> listAcc = new List<Account>();
                listAcc = [Select Id,Name,Partner_Track__c from Account where Partner_Track__c IN : setPTS]; 
                if(listAcc.size() > 0){
                    for(Account acc : listAcc){
                        if(mapPTToSM.containsKey(acc.Partner_Track__c)){
                            mapPTToSM.get(acc.Partner_Track__c).add(acc.Id);
                        }
                        else{
                            mapPTToSM.put(acc.Partner_Track__c,new List<String>{ acc.Id}); 
                        }
                        
                    }
                    System.debug('mapPTToSM'+mapPTToSM);
                }
            }
            if(mapUsrPTAdd.size() > 0 || mapUsrPTRemove.size()> 0){
                // Check if the share record already exists
                listAccShareExists = [SELECT Id,AccountId,UserOrGroupId
                                      FROM AccountShare
                                      WHERE RowCause=:'Manual' 
                                      AND (UserOrGroupId IN: mapUsrPTAdd.keySet() OR UserOrGroupId IN: mapUsrPTRemove.keySet())
                                     ]; 
            }
            System.debug('listAccShareExists'+listAccShareExists.size());
            //map to hold the User vs AccountId's
            Map<String,List<AccountShare>> mapShareUsrToSM = new Map<String,List<AccountShare>>();
            if(listAccShareExists.size() > 0){
                for(AccountShare accSh : listAccShareExists){
                    if(mapShareUsrToSM.containsKey(accSh.UserOrGroupId)){
                        mapShareUsrToSM.get(accSh.UserOrGroupId).add(accSh);
                    }
                    else{
                        mapShareUsrToSM.put(accSh.UserOrGroupId,new List<AccountShare>{ accSh }); 
                        }
                    
                }
                System.debug('mapShareUsrToSM::'+mapShareUsrToSM);
			}
            for(Contact con: mapNewContacts.values()){
                if(mapUsrPTAdd.size() > 0 && mapPTToSM.size() > 0){
                    if(mapUsrPTAdd.containsKey(con.Partner_User__c)){
                        for(String strEligibleTrack : mapUsrPTAdd.get(con.Partner_User__c)){
                            System.debug('strEligibleTrack'+strEligibleTrack); 
                            if(mapPTToSM.containsKey(strEligibleTrack)){
                                if(mapUsrIdToSMAdd.containsKey(con.Partner_User__c)){
                                    mapUsrIdToSMAdd.get(con.Partner_User__c).addAll(mapPTToSM.get(strEligibleTrack));
                                }else{
                                    // add a new record
                                    mapUsrIdToSMAdd.put(con.Partner_User__c, new List<String>(mapPTToSM.get(strEligibleTrack)));
                                }
                            } 
                            
                        } 
                        
                    }
                }
                if(mapUsrPTRemove.size() > 0 && mapPTToSM.size() > 0){
                       if(mapUsrPTRemove.containsKey(con.Partner_User__c)){
                        for(String strEligibleTrack : mapUsrPTRemove.get(con.Partner_User__c)){
                            System.debug('strEligibleTrack'+strEligibleTrack); 
                            if(mapPTToSM.containsKey(strEligibleTrack)){
                                if(mapUsrIdToSMRemove.containsKey(con.Partner_User__c)){
                                    mapUsrIdToSMRemove.get(con.Partner_User__c).addAll(mapPTToSM.get(strEligibleTrack));
                                }else{
                                    // add a new record
                                    mapUsrIdToSMRemove.put(con.Partner_User__c, new List<String>(mapPTToSM.get(strEligibleTrack)));
                                }
                            } 
                            
                        } 
                    } 
                }
            }
			System.debug('mapUsrIdToSMAdd'+mapUsrIdToSMAdd);
            System.debug('mapUsrIdToSMRemove'+mapUsrIdToSMRemove);
            if(mapUsrIdToSMAdd.size() > 0){
                for(String strUsrId : mapUsrIdToSMAdd.keySet()){
                    if(mapUsrIdToSMAdd.get(strUsrId).size() <= Integer.valueOf(System.Label.Maximum_SM_Accounts)){
                        // Check share exists or not
                        if(mapShareUsrToSM.containsKey(strUsrId) && mapShareUsrToSM.get(strUsrId)!=null){
                           List<String> listAccountIds = new List<String>();
                           for(AccountShare accShare : mapShareUsrToSM.get(strUsrId)){
                                   listAccountIds.add(accShare.AccountId);
                           }
                           for(String strAccId : mapUsrIdToSMAdd.get(strUsrId)){
                                System.debug('strShareAcc::'+mapShareUsrToSM.get(strUsrId));
                                if(listAccountIds.contains(strAccId)){
                                    System.debug('Account Share already exists for the user '+strUsrId+' and account combination:');
                                }
                               	else{
                                        System.debug('Create Account Share for Account:'+strAccId);
                                        AccountShare accShare = new Accountshare();
                                        accShare.AccountId = strAccId;
                                        accShare.UserOrGroupId = strUsrId;
                                        accShare.AccountAccessLevel = 'Read';
                                        accShare.OpportunityAccessLevel='None';
                                        //accShare.RowCause='Manual';
                                        listAccShareInsert.add(accShare);
                                  }
                               
                                    
                                
                                
                            }
                        }
                        else{
                              for(String strAccId : mapUsrIdToSMAdd.get(strUsrId)){
                             	   System.debug('Add an account share as Accountshare list doesnt contains'+strAccId);
                                   AccountShare accShare = new Accountshare();
                                   accShare.AccountId = strAccId;
                                   accShare.UserOrGroupId = strUsrId;
                                   accShare.AccountAccessLevel = 'Read';
                                   accShare.OpportunityAccessLevel='None';
                                   //accShare.RowCause='Manual';
                                   listAccShareInsert.add(accShare);
                            }
                        }
                       
                        System.debug('listAccShareInsert'+listAccShareInsert);
                        
                      }
                    else{
                         // call the batch
                         mapUsrIdToSMGrant.put(strUsrId,new List<String>(mapUsrIdToSMAdd.get(strUsrId)));   
                        }
                }
            }
            if(mapUsrIdToSMRemove.size() > 0){
                for(String strUsrId : mapUsrIdToSMRemove.keySet()){
                    if(mapUsrIdToSMRemove.get(strUsrId).size() <= 15){
                        for(String strAccId : mapUsrIdToSMRemove.get(strUsrId)){
                          if(mapShareUsrToSM.containsKey(strUsrId) && mapShareUsrToSM.get(strUsrId)!=null){
                               for(AccountShare shareAcc : mapShareUsrToSM.get(strUsrId)){
                                   System.debug('shareAcc::'+shareAcc);
                                   if(strAccId.equals(shareAcc.AccountId)){
                                      System.debug('Account Share exists for the user '+strUsrId+' and account '+shareAcc.AccountId+' combination:');
                                   	  listAccShareDel.add(shareAcc);
                                   }
                                   
                               }
                           }  
                        }
                    }
                    else{
                        mapUsrIdToSMRemove.put(strUsrId,new List<String>(mapUsrIdToSMAdd.get(strUsrId)));
                    }
                }                
            }

            System.debug('mapUsrIdToSMGrant'+mapUsrIdToSMGrant);
            System.debug('mapUsrIdToSMRevoke'+mapUsrIdToSMRevoke);
            System.debug('listAccShareInsert'+listAccShareInsert);
            System.debug('listAccShareDel'+listAccShareDel);
        }
     	if(listAccShareInsert.size() > 0){
            Database.SaveResult[] listSR = Database.insert(listAccShareInsert,false);
            for (Database.SaveResult sr : listSR) {
                if(sr.isSuccess()){
                    System.debug('Inserted Successfully');
                }
                else {
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('The following error has occurred.');  
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                        
                        
                    }
                }
                
            }
            
            
        }
        if(listAccShareDel.size() > 0){
            Database.DeleteResult[] listSR = Database.delete(listAccShareDel,false);
            for (Database.DeleteResult sr : listSR) {
                if(sr.isSuccess()){
                    System.debug('Delete Successfully');
                }
                else {
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('The following error has occurred.');  
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                        
                        
                    }
                }
                
            }
            
        }
        if(mapUsrIdToSMGrant.size() >0){
            System.debug('About to Call Batch Class for Addition');
            ManageAccessForSalesMotion bcn = new ManageAccessForSalesMotion(mapUsrIdToSMGrant,System.Label.Grant_Access_Type) ;
            ID batchprocessid = Database.executeBatch(bcn);
            System.debug('batchprocessid to Add SM ::'+batchprocessid);
            if(mapUsrIdToSMRevoke.size() > 0){
                System.debug('About to Call Batch Class for Removal');
                ManageAccessForSalesMotion bcn2 = new ManageAccessForSalesMotion(mapUsrIdToSMRevoke,System.Label.Revoke_Access_Type) ;
                ID batchprocessid2 = Database.executeBatch(bcn2);
                System.debug('batchprocessid to Remove SM::'+batchprocessid2);
            }
        }
        else if(mapUsrIdToSMRevoke.size() > 0){
            System.debug('About to Call Batch Class for Removal');
            ManageAccessForSalesMotion bcn = new ManageAccessForSalesMotion(mapUsrIdToSMRevoke,System.Label.Revoke_Access_Type) ;
            ID batchprocessid = Database.executeBatch(bcn);
            System.debug('batchprocessid to Remove SM::'+batchprocessid);
            
        }
        
        
		} 
    /* 
     * Added on 7th Feb 2019
     * Added by Sneha
     * Story No - 5878607
	 This method is to send an email to the Partner Contact on addition of new Contact
	*/ 
    
    public static void sendMailOnAdditionOfNewTrack(Set<Contact> setContacts, Map<String,List<String>> mapUserToPT){
        System.debug('**sendMailOnAdditionOfNewTrack**');
        //System.debug('setPT'+setPT);
        EmailTemplate template = [Select Id,Developername,Name from EmailTemplate where Developername = 'OnBoard_New_Partner_Track'];
        List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
		OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address From OrgWideEmailAddress WHERE address='no_reply@dell.com'];
        for(Contact con : setContacts){
            if(mapUserToPT.size() > 0 && mapUserToPT.containsKey(con.Partner_User__c) ){
                //if(){
                  System.debug('User associated PTs'+mapUserToPT.get(con.Partner_User__c));
                  List<String> listNewTrackAdded = mapUserToPT.get(con.Partner_User__c);
                  if(listNewTrackAdded.size() > 0){
                     System.debug('Email to be sent:');
                          // Create a mail
                          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                          mail.setTargetObjectId(con.Id);
                          mail.setSaveAsActivity(false);
                          mail.setOrgWideEmailAddressId(owa.id);
                		  mail.setWhatId(con.Partner_User__c);
                		  mail.setTemplateId(template.Id);
                          listEmails.add(mail);
                      } 
                
                
            }
            
            
        }
        System.debug('No of emails to be sent::'+listEmails.size());
        if(listEmails.size() > 0){
            List<Messaging.SendEmailResult> listresults = new List<Messaging.SendEmailResult>();
            try{
              listresults= Messaging.sendEmail(listEmails);  
              System.debug('list results::'+listresults);
            }
            catch(Exception e){
                System.debug('Exception Occured'+e.getMessage());
            }
            
          
        }
    }
    }