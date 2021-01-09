/*
* Author   : Ragu
* Purpose  : Centralize the record selection process for Lead.
*          Defines the methods which iterate and segregate the Lead records for further use.
* 
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      11555       16.07           28-May-2015     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
* 2.0      LM2-GENERAL 16.10           21-Aug-2015     Ragu            Added code for segregating Direct Lead 2.0 and Channel Lead 2.0
* 2.1      LM2-GENERAL 16.10           01-Sep-2015     Ragu            Added code for segregating Channel Leads
* 2.2      LM2-GENERAL 16.10           01-Sep-2015     Ragu            Added code for retrieving related records (Accounts, Contacts, Campaigns and Users)
* 2.3      11925       16.10           04-Sep-2015     Ragu            Implement the identified field population Lead trigger functionalities for Lead 2.0
* 2.4      11962       16.10           14-Sep-2015     Dipin Raju      Updated the query on Campaign to fetch additional fields - Next_Steps__c, Supporting_Information__c
* 2.5      TFS: 196117 16.10           17-Sep-2015     Ragu            Defect 196117: LM2_1_01_18_02: Campaign Member status does not reflect status of other channel lead record types but Channel Lead 2.0
* 2.6      12064       16.10           12-Oct-2015     Ragu            LM2_1_71-Route to Segment Process
* 3.0      12336       16.12           13-Nov-2015     Ragu            Do not automatically populate Account if current user belongs to Sales profile.
* 3.1      12405       CSM0104         09-Dec-2015     Azwanti         161357 - added logic to populate record type for Channel 2.0 created from FAP
* 4.0      13244       FY17-DCS-0703   13-Jun-2016     Jessie          Convert some validation rules to trigger (to reduce the lead limit issues)
* 5.0      16874       FY20-DCS-0202   29-Nov-2018     Sajith          Select Zift Lead Records for populating Partner Account and Partner User
* 6.0      17022       FY20-DCS-0202   11-Jan-2018     Yamini          Updated the query on Campaign to fetch additional field Sales_Call_to_Action__c
            TFS:5805764   FY20-DCS-0202   29-Jan-2019     Kavitha         Added group_id__c to the user SOQL
* 7.0      17117       FY20-DCS-0402   8-Feb-2019      Naresh          Updated mapRelatedAccounts quesiry with partner_track__c field and MapRelatedUsers query with Eligible_track__c field
* 8.0      18002       FY20-DCS-1002   19-Aug-2019     Sonali          Updated mapRelatedContacts query with Account RecordType and partner_track__c field.
* 9.0      18290       FY20-DCS-0102   24-Oct-2019     Sonali          Logic to link Leads to Opportunities by utilizing the Deal ID fields on Lead.
*/

public class LeadRecordSelector extends RecordSelector {
    
    private TriggerHandler leadTrigHandler;
    
    // v1.0 - Variable for holding Leads 2.0 for creating Campaign Member
    public map<Id, Lead> mapLeads2AfterInsert = new map<Id, Lead>();
    
    // v1.0 - Variable for holding Leads 2.0 for updating CM Status
    public map<Id, Lead> mapLeads2ForCMStatusUpdate = new map<Id, Lead>();
    
    // v2.0 - Variables for holding Lead 2.0
    public list<Lead> lstDirectLeads2 = new list<Lead>();
    public list<Lead> lstChannelLeads2 = new list<Lead>();
    public list<Lead> lstLeads2 = new list<Lead>();
    public list<Lead> lstAllLeads2 = new list<Lead>();
    // v4.0 - Variables for holding AccountSuggetion & AccountSuggestionLocked Leads
    public list<Lead> lstAcctSuggestLeads2 = new list<Lead>();
    public list<Lead> lstacctSuggestLockedLeads2 = new list<Lead>();
    
    // v2.1 - Variables for holding Channel Leads
    public list<Lead> lstChannelLeads = new list<Lead>();
    
    // v2.2 - Variable for storing related Accounts, Contacts, Campaigns and Users detail for querying related records
    public set<Id> setRelatedAccountIds = new set<Id>();
    public map<Id, Account> mapRelatedAccounts = new map<Id, Account>();
    public set<Id> setRelatedContactIds = new set<Id>();
    public map<Id, Contact> mapRelatedContacts = new map<Id, Contact>();
    public set<Id> setRelatedCampaignIds = new set<Id>();
    public map<Id, Campaign> mapRelatedCampaigns = new map<Id, Campaign>();
    public set<Id> setRelatedUserIds = new set<Id>();
    public map<Id, User> mapRelatedUsers = new map<Id, User>();
    
    // v2.3 - Variable for holding Channel Leads for populating Account
    public list<Lead> lstCLsToPopulateAccount = new list<Lead>();
    
    // v2.3 - Variable for holding Direct Lead 2.0 for populating Account
    public list<Lead> lstDLsToPopulateAccount = new list<Lead>();
    
    // v2.3 - Variable for holding Channel Leads for populating Partner Account
    public list<Lead> lstCLsToPopulatePartnerAccount = new list<Lead>();
    
    // v5.0 - Variables for holding Zift leads and aupporting information to populate Partner Account and Partner User
    public set<String> setZiftAffinityIds = new set<String>();
    public set<String> setZiftSalesRepEmailIds = new set<String>();
    public set<String> setZiftCampaignNames = new set<String>();
    public list<Lead> listZiftCLs = new list<Lead>(); 
    
    // v2.6 - Variable for holding Routed Channel Leads
    public list<Lead> lstUIRoutedCLs = new list<Lead>(); 
    public list<Lead> lstBatchRoutedCLs = new list<Lead>();
    
    //v4.0 - start - Variable for holding leads' Account Owner
    public set<Id> setRelatedAccountOwners = new set<Id>();
    public map<Id, User> mapRelatedAccountOwners = new map<Id, User>();
    public set<Id> setRelatedCountries = new set<Id>();
    public map<Id, Country__c> mapRelatedCountries = new map<Id, Country__c>();
    //v4.0 - end 
    
    // v9.0 - start
    public list<Lead> listChannelLeadtoDeal = new list<Lead>();
    public Set<String> setChannelDealIds = new set<String>();
    //v9.0 - end
    
    public LeadRecordSelector(list<sObject> lstLeads, map<Id, sObject> mapOldLeads, TriggerHandler leadTrigHandler) {
        this.leadTrigHandler = leadTrigHandler;
        
        this.getRecords(lstLeads, mapOldLeads);
        
        removeNulls();
        
        if(lstLeads != null) {
            this.getRelatedRecords(lstLeads);
        }
        else if(mapOldLeads != null) {
            this.getRelatedRecords(mapOldLeads.values());
        }
    }
    
    protected override void getRecords(list<sObject> lstLeads, map<Id, sObject> mapOldLeads) {
        // Channel Lead - future use
        Id clSubmissionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');
        Id clClensingScoringRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
        Id clAssignmentRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
        Id clConversionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Conversion');
        
        // Lead 2.0
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        Id channelLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
        
        set<Id> setChannelLeadRTIds = new set<Id>{clSubmissionRTId, clClensingScoringRTId, clAssignmentRTId, clConversionRTId, channelLead2RTId};
            set<Id> setLead2RTIds = new set<Id>{directLead2RTId, channelLead2RTId};
                set<Id> setAllLead2RTIds = new set<Id>{clSubmissionRTId, clClensingScoringRTId, clAssignmentRTId, clConversionRTId, directLead2RTId, channelLead2RTId};
                    
                    //v4.0 - start
                    Id dsgPartnerRTId = StaticFactory.getRecordTypeIdByName('Lead', 'DSG Partner');
        //v4.0 - end 
        
        // v3.0
        User currentUser = StaticFactory.getCurrentUserDetails();
        
        if(lstLeads != null) { // Handles insert or update events
            for(Lead newLead : (list<Lead>)lstLeads) {
                Lead oldLead;
                if(mapOldLeads != null && !mapOldLeads.isEmpty()) {
                    oldLead = (Lead)mapOldLeads.get(newLead.Id);
                }
                
                //v3.1
                system.debug('################# 12405 FAP_Originated_Lead__c: '+newLead.FAP_Originated_Lead__c);
                //if(newLead.FAP_Originated_Lead__c=='Yes'){
                //newLead.RecordTypeId = channelLead2RTId;
                //}
                //v3.1
                // v2.0 Start: Segregate Direct Lead 2.0 and Channel Lead 2.0
                if(newLead.RecordTypeId == directLead2RTId) {
                    lstDirectLeads2.add(newLead);
                    lstLeads2.add(newLead);
                    lstAllLeads2.add(newLead);
                }
                else if(setChannelLeadRTIds.contains(newLead.RecordTypeId)) {
                    // v2.1 Start: Segregate Channel Leads
                    lstChannelLeads.add(newLead);
                    lstAllLeads2.add(newLead);
                    // v2.1 End: Segregate Channel Leads
                    if(newLead.RecordTypeId == channelLead2RTId) {
                        lstChannelLeads2.add(newLead);
                        lstLeads2.add(newLead);
                    }
                }
                // v2.0 End: Segregate Direct Lead 2.0 and Channel Lead 2.0
                
                // v2.2 Start: Parent record Ids to query related records
                setRelatedCampaignIds.add(newLead.Campaign__c);
                
                setRelatedAccountIds.add(newLead.Account__c);
                setRelatedAccountIds.add(newLead.Partner_Account__c);
                
                setRelatedContactIds.add(newLead.Contact__c);
                setRelatedContactIds.add(newLead.Related_Contact__c);
                // v2.2 End: Parent record Ids to query related records
                
                //v4.0 - start
                setRelatedAccountOwners.add(newLead.Account_Owner__c);
                setRelatedCountries.add(newLead.Postal_Country__c);
                setRelatedCountries.add(newLead.Physical_Country__c);
                //v4.0 - end
                
                //v4.0 - start
                if(setChannelLeadRTIds.contains(newLead.RecordTypeId) || newLead.RecordTypeId == dsgPartnerRTId ){
                    setRelatedUserIds.add(newLead.Partner_User__c);
                }    
                //v4.0 - end 
                
                // Trigger context based filtering - Add your selection logics here, if it needs to be tightly coupled with trigger contex
                
                if(leadTrigHandler != null) {
                    if(leadTrigHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                        if(leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                            if(newLead.RecordTypeId == directLead2RTId) {
                                // v2.3 Start
                                if(newLead.Contact__c != null) {
                                    lstDLsToPopulateAccount.add(newLead);
                                }
                                // v2.3 End
                            }
                            
                            if(setChannelLeadRTIds.contains(newLead.RecordTypeId)) {
                                // v2.3 Start
                                if(newLead.Partner_User__c != null) {
                                    setRelatedUserIds.add(newLead.Partner_User__c);
                                    lstCLsToPopulatePartnerAccount.add(newLead);
                                }
                                if(newLead.Related_Contact__c != null) {
                                    lstCLsToPopulateAccount.add(newLead);
                                }
                                // v2.3 End
                                // v5.0 Start
                                if(newLead.Zift_Unique_ID__c != null && newLead.Zift_Lead_Partner__c !=null &&
                                        newLead.Zift_Sales_Rep_Email__c !=null &&
                                        newLead.Partner_User__c == null && 
                                        newLead.Partner_Account__c == null){
                                    setZiftAffinityIds.add(newLead.Zift_Lead_Partner__c);
                                    setZiftSalesRepEmailIds.add(newLead.Zift_Sales_Rep_Email__c);
                                    setZiftCampaignNames.add(newLead.Campaign__c);
                                    //setRelatedUserIds.add(newLead.Partner_User__c); //Sajith
                                    listZiftCLs.add(newLead);   
                                }
                                // v5.0 End
                                
                                 //v9.0
                                 system.debug('Calling LeadRecordSelector ***********');
                                if(newLead.Channel_Lead_to_Deal__c == True && (newLead.Deal_1_ID__c != null || 
                                   newLead.Deal_2_ID__c!= null ||newLead.Deal_3_ID__c!= null ||
                                   newLead.Deal_4_ID__c!= null || newLead.Deal_5_ID__c!= null || 
                                   newLead.Deal_6_ID__c!= null)){                                  
                                   listChannelLeadtoDeal.add(newLead);
                                   system.debug('listChannelLeadtoDeal inside LeadRecordSelector ***********'+listChannelLeadtoDeal);
                                   if(newLead.Deal_1_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_1_ID__c);
                                   }
                                   if(newLead.Deal_2_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_2_ID__c);
                                   }
                                   if(newLead.Deal_3_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_3_ID__c);
                                   }
                                   if(newLead.Deal_4_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_4_ID__c);
                                   }
                                   if(newLead.Deal_5_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_5_ID__c);
                                   }
                                   if(newLead.Deal_6_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_6_ID__c);
                                   }
                                   system.debug('setChannelDealIds inside LeadRecordSelector ***********'+setChannelDealIds);
                                }
                                //v9.0 End
                                
                            }
                            
                        }
                        else if(leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                            if(newLead.RecordTypeId == directLead2RTId) {
                                // v2.3 Start
                                if(newLead.Contact__c != null && newLead.Contact__c != oldLead.Contact__c && newLead.Account__c == null) {
                                    // v3.0 Start - Updated below if condition to include "Sales profile related checks"
                                    if(currentUser.Profile.Name.containsIgnoreCase('Sales') && newLead.Lead_Type__c != 'Outbound') {
                                        lstDLsToPopulateAccount.add(newLead);
                                    }
                                    else if(!currentUser.Profile.Name.containsIgnoreCase('Sales')) {
                                        lstDLsToPopulateAccount.add(newLead);
                                    }
                                    // v3.0 End
                                }
                                // v2.3 End
                            }
                            
                            // v2.6 Start
                            if(setChannelLeadRTIds.contains(oldLead.RecordTypeId)) {
                                if(newLead.Status.toUpperCase() == 'Route To Segment'.toUpperCase()) {
                                    lstBatchRoutedCLs.add(newLead);
                                }
                                if(newLead.RecordTypeId == directLead2RTId) {
                                    lstUIRoutedCLs.add(newLead);
                                }
                            }
                            // v2.6 Start
                            
                            if(setChannelLeadRTIds.contains(newLead.RecordTypeId)) {
                                // v2.3 Start
                                if(newLead.Partner_User__c != oldLead.Partner_User__c || (newLead.Partner_User__c != null && newLead.Partner_Account__c == null)) {
                                    setRelatedUserIds.add(newLead.Partner_User__c);
                                    lstCLsToPopulatePartnerAccount.add(newLead);
                                }
                                if(newLead.Related_Contact__c != oldLead.Related_Contact__c || (newLead.Related_Contact__c != null && newLead.Account__c == null)) {
                                    // v3.0 - Start: Updated below if condition to include "Sales profile related checks"
                                    if(newLead.RecordTypeId == channelLead2RTId) {
                                        if(newLead.Account__c == null) {
                                            if(currentUser.Profile.Name.containsIgnoreCase('Sales') && newLead.Lead_Type__c != 'Outbound') {
                                                lstCLsToPopulateAccount.add(newLead);
                                            }
                                            else if(!currentUser.Profile.Name.containsIgnoreCase('Sales')) {
                                                lstCLsToPopulateAccount.add(newLead);
                                            }
                                        }
                                    }
                                    else {
                                        lstCLsToPopulateAccount.add(newLead);
                                    }
                                    // v3.0 - End
                                }
                                // v2.3 End
                            }
                        }
                    }
                    
                    if(leadTrigHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                        if(leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                            if(setLead2RTIds.contains(newLead.RecordTypeId)) {
                                // v1.0 Start
                                mapLeads2AfterInsert.put(newLead.Id, newLead);
                                // v1.0 End
                            }
                            
                            //v9.0
                                 system.debug('Calling LeadRecordSelector ***********');
                                if(newLead.Channel_Lead_to_Deal__c == True && (newLead.Deal_1_ID__c != null || 
                                   newLead.Deal_2_ID__c!= null ||newLead.Deal_3_ID__c!= null ||
                                   newLead.Deal_4_ID__c!= null || newLead.Deal_5_ID__c!= null || 
                                   newLead.Deal_6_ID__c!= null)){                                  
                                   listChannelLeadtoDeal.add(newLead);
                                   system.debug('listChannelLeadtoDeal inside LeadRecordSelector ***********'+listChannelLeadtoDeal);
                                   if(newLead.Deal_1_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_1_ID__c);
                                   }
                                   if(newLead.Deal_2_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_2_ID__c);
                                   }
                                   if(newLead.Deal_3_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_3_ID__c);
                                   }
                                   if(newLead.Deal_4_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_4_ID__c);
                                   }
                                   if(newLead.Deal_5_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_5_ID__c);
                                   }
                                   if(newLead.Deal_6_ID__c != null){
                                    setChannelDealIds.add(newLead.Deal_6_ID__c);
                                   }
                                   system.debug('setChannelDealIds inside LeadRecordSelector ***********'+setChannelDealIds);
                                }
                                //v9.0 End
                        }
                        else if(leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                            // v2.5 - Updated below if condition to check setAllLead2RTIds instead of setLead2RTIds
                            if(setAllLead2RTIds.contains(newLead.RecordTypeId)) {
                                // v1.0 Start
                                if(newLead.Status != oldLead.Status || newLead.Reason__c != oldLead.Reason__c || newLead.RecordTypeId != oldLead.RecordTypeId) {
                                    mapLeads2ForCMStatusUpdate.put(newLead.Id, newLead);
                                }
                                // v1.0 End
                            }
                        }
                    }
                    
                    if(leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        // v2.2 Start: Old parent record Ids to query related records
                        setRelatedCampaignIds.add(oldLead.Campaign__c);
                        
                        setRelatedAccountIds.add(oldLead.Account__c);
                        setRelatedAccountIds.add(oldLead.Partner_Account__c);
                        
                        setRelatedContactIds.add(oldLead.Contact__c);
                        setRelatedContactIds.add(oldLead.Related_Contact__c);
                        // v2.2 End: Old parent record Ids to query related records
                    }
                }
            }
        }
        else if(mapOldLeads != null) { // Handles delete event
            for(Lead leadIterator : (list<Lead>)mapOldLeads.values()) {
                // v2.0 Start: Segregate Direct Lead 2.0 and Channel Lead 2.0
                if(leadIterator.RecordTypeId == directLead2RTId) {
                    lstDirectLeads2.add(leadIterator);
                    lstLeads2.add(leadIterator);
                    lstAllLeads2.add(leadIterator);
                }
                else if(setChannelLeadRTIds.contains(leadIterator.RecordTypeId)) {
                    // v2.1 Start: Segregate Channel Leads
                    lstChannelLeads.add(leadIterator);
                    lstAllLeads2.add(leadIterator);
                    // v2.1 End: Segregate Channel Leads
                    if(leadIterator.RecordTypeId == channelLead2RTId) {
                        lstChannelLeads2.add(leadIterator);
                        lstLeads2.add(leadIterator);
                    }
                }
                // v2.0 End: Segregate Direct Lead 2.0 and Channel Lead 2.0
                
                // v2.2 Start: Parent record Ids to query related records
                setRelatedCampaignIds.add(leadIterator.Campaign__c);
                
                setRelatedAccountIds.add(leadIterator.Account__c);
                setRelatedAccountIds.add(leadIterator.Partner_Account__c);
                
                setRelatedContactIds.add(leadIterator.Contact__c);
                setRelatedContactIds.add(leadIterator.Related_Contact__c);
                // v2.2 End: Parent record Ids to query related records
            }
        }
    }
    
    protected override void getRelatedRecords(list<sObject> lstLeads) {
        // v2.2 Start
        // v2.4: Added Next_Steps__c & Supporting_Information__c fields in the mapRelatedCampaigns SOQL query.
        // v6.0
        if(!setRelatedCampaignIds.isEmpty()) {
            mapRelatedCampaigns = new map<Id, Campaign>([select Id, Name, Follow_Up_Role__c, Secondary_Role__c, Next_Steps__c, Supporting_Information__c,Force_Follow_Up_Rule_for_Outbound_Leads__c
                                                         from Campaign where Id in :setRelatedCampaignIds]);
        }
        //5.0  Start
        if(!setZiftAffinityIds.isEmpty()){
            set<Account> setRelatedZiftAccountIds = new set<Account>([select id from Account where Account_Id__c in :setZiftAffinityIds]);
            if(!setRelatedZiftAccountIds.isEmpty()){
                for(Account accountZift :setRelatedZiftAccountIds){
                    setRelatedAccountIds.add(accountZift.id);
                }
            }          
        }
        if(!setZiftSalesRepEmailIds.isEmpty()){
            set<User> setRelatedZiftUserIds = new set<User>([Select id from User where email in :setZiftSalesRepEmailIds AND Enable_Partner_Lead_Management__c=true AND IsPortalEnabled=true AND UserType ='PowerPartner' AND isActive = true ]);            
            if(!setRelatedZiftUserIds.isEmpty()){
                for(User userZift :setRelatedZiftUserIds){
                    setRelatedUserIds.add(userZift.id);
                }
            }     
        }
        //5.0  End
        //v4.0 - start
        if(!setRelatedAccountIds.isEmpty()) {
        //V 7.0 Start
            mapRelatedAccounts = new map<Id, Account>([select Id, Name, Type, RecordType.Name, partner_track__c
                                                       from Account where Id in :setRelatedAccountIds]);
        //V 7.0 End
        }
        
        //V 8.0 - start
        if(!setRelatedContactIds.isEmpty()) {
            mapRelatedContacts = new map<Id, Contact>([select Id, Name, AccountId, Account.RecordTypeId,Account.OwnerId, Account.Owner.Name, Account.Calculated_Status__c,Preferred_Track__r.Primary_SMAffinity_Account__c 
                                                       from Contact where Id in :setRelatedContactIds]);
        }
        //V 8.0 - end
        //v4.0 - end 
        
        if(!setRelatedUserIds.isEmpty()) {
        //V 7.0 Start
            mapRelatedUsers = new map<Id, User>([select Id, Name, AccountId, Contact.AccountId,Contact.EligibleTracks__c, UserType
                                                 from User where Id in :setRelatedUserIds]);
        //V 7.0 End
        }
        // v2.2 End
        
        //v4.0 - start
         //TFS:5805764 - Added Group_Id__c
        if(!setRelatedAccountOwners.isEmpty()) {
            mapRelatedAccountOwners = new map<Id, User>([select Id, UserRole.Name, title, Badge_Number__c,Group_Id__c From User where Id in :setRelatedAccountOwners]);
        }
        
        if(!setRelatedCountries.isEmpty()) {
            mapRelatedCountries = new map<Id, Country__c>([select Id, Name From Country__c where Id in :setRelatedCountries]);
        }
        
        //v4.0 - end 
        
    }
    
    // Remove nulls from the Set / List / Map.
    private void removeNulls() {
        // v2.2 Start
        setRelatedCampaignIds.remove(null);
        setRelatedAccountIds.remove(null);
        setRelatedContactIds.remove(null);
        setRelatedUserIds.remove(null);
        // v2.2 End
        
        //v4.0 - start
        setRelatedAccountOwners.remove(null);
        setRelatedCountries.remove(null);
        //v4.0 - end
        
    }
    
}