/*
 * Author   : Syidah
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Lead 2.0.
 *       
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      11842       16.10       19-Aug-2015     Syidah          Populate latest reassignment date when lead owner got change.
 * 1.1      11874       16.10       25-Aug-2015     Azwanti         Populate Lead Owner's Manager for Direct Lead 2.0 and Channel Lead 2.0.
 * 1.2      11925       16.10       03-Sep-2015     Ragu            Auto populate Lead fields - Logics moved from CMAP_BeforeInsertUpdateLeadTrigger and included Lead 2.0 as necessary.
 * 1.3      11962       16.10       14-Sep-2015     Dipin Raju      Populate Lead's Next Steps and Supporting Info fields with values from Campaign
 * 1.4      12038       16.10       06-Oct-2015     Ananth          Allow User to Update “Channel_Lead_Capture_date_c” field for MLUR
 * 2.0      12336       16.12       13-Nov-2015     Ragu            LM2_1_76-Enhance related account change in Direct Lead 2.0
 * 2.1      12369       16.12       01-Dec-2015     Ragu            LM2_1_104-Add RAD account field into Direct Lead 2.0 page
 * 2.2      12470       CSM0104     14-Dec-2015     Azwanti         populate fields for Channel 2.0 created from FAP
 * 2.3      12494       16.12       30-Dec-2015     Nagendra Singh  LM2_17_8-Enhance in direct Lead 2.0 the field Lead owner's role
 * 2.4      12505       16.12       5-Jan-2015      Nagendra Singh  Story 213992:LM2_12_3- Add option to use only follow up role and skip default assignment
 * 3.0      13002   FY17-DCS-0502   30-Mar-2016     Azwanti         Story 1195440 : LM2_17-Add Lead velocity fields and calculation in Direct Lead 2.0
 * 4.0      13156   FY17-DCS-0701   24-May-2016     Azwanti         Story LM2_17-Rework to optimize code - Add Lead velocity fields and calculation in Direct Lead 2.0 + INC000022651975            
 * 4.1      13156   FY17-DCS-0701   24-May-2016     Gan             Lead velocity Field calculation done with days in decimal point  
 * 5.0      13336   FY17-DCS-0801   19-July-2016    SuiYee          Change RAD_Code__c from text field to formula field  
 * 6.0      13386   FY17-DCS-1002   08-Aug-2016     Azwanti         LM2_17- Ensure lead owner manager is in synch with user card changes
 * 7.0      13693   FY17-DCS-0103   01-Nov-2016     Sajith          LM2 New calculation for number days sales to follow up
 * 8.0      14998   FY18-DCS-1101   10-OCT-2017     Ashok           Lead Owner Role population when Assignment logic triggred
 * 9.0      15395   FY19-DCS-0203   08-Jan-2018     Sajith          Update 'Accepted Date' based on new lead status
 * 9.1      15396   FY19-DCS-0203   08-Jan-2018     Sajith          Update Sales Follow Up days based on New lead status values
 *10.0      15977   FY19-DCS-0703   21-June-2018    Yamini          Populated Lead.Primary_campaign_Id__c
 *11.0      16404   FY19-DCS-1002   29- Aug-2018    Yamini          Reverting back FY19-DCS-0703 code changes
 *12.0      16874   FY20-DCS-0202   29-Nov-2018     Sajith          Populate Zift Leads with Partner Account and Partner user
 *13.0      17022   FY20-DCS-0202   11-Jan-2018     Yamini          Populate sales Call to Action field 
 *14.0      6342705 FY20-DCS-0402   15-mar-2018     Ankur           Defect 6342705: PAM-E2E Testing; FAP Partner User failed to create a Contact using contact us button
 *15.0      18002   FY20-DCS-1002   19-Aug-2019     Sonali          Included logic to auto-populate Lead's Account field from the Selected Contact
 *16.0      18166   FY20-DCS-1101   30-Sep-2019     Kokila          To handle Lead Owner's Role calculation during Insert of Leads
 *17.0      18290   FY20-DCS-0102   24-Oct-2019     Sonali          Logic to link Leads to Opportunities by utilizing the Deal ID fields on Lead
 *17.1      18306   FY20-DCE-0102   16-Nov-2019     Fenny           Make LeadRecordSelector accessible as static variable from LeadTriggerHandler
*/

public class LeadFieldPopulator {
 
    // v1.2 - Populate Lead fields for Direct Lead 2.0 & all Channel Leads.
    public static void populateLead2Fields(list<Lead> lstAllLeads2, map<Id, Lead> mapOldLeads, LeadTriggerHandler leadTrigHandler) {
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        Id channelLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
        Id clSubmissionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');
        Id clCleansingRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
        set<Id> setLead2RTIds = new set<Id>{directLead2RTId, channelLead2RTId};
        set<Id> setChannelBaseRTIds = new set<Id>{clSubmissionRTId, clCleansingRTId, channelLead2RTId};
        map<Id, RecordType> mapRecordTypes = StaticFactory.getRecordTypes('Lead');
        DateTime dtCurrentTime = System.now();        
        
        
        //v2.2
        List <Lead> fapLeadList = new List<Lead>();
        
        for(Lead newLead : lstAllLeads2) {
            Lead oldLead = null;
            if(mapOldLeads != null) {
                oldLead = mapOldLeads.get(newLead.Id);
            }
            
            if(leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {                
                
                if(setLead2RTIds.contains(newLead.RecordTypeId)) {
                    newLead.Origin__c = mapRecordTypes.get(newLead.RecordTypeId).Name;
                   /*11.0 Starts
                    //V10.0 populated campaign id in Lead.Primary_campaign_Id__c field
                    newLead.Primary_campaign_Id__c=newLead.Campaign__c;
                    11.0 Ends*/
                    
                    // v1.3: CR 11962 - Begin
                    Campaign parentCamp = LeadTriggerHandler.leadRecSelector.mapRelatedCampaigns.get(newLead.Campaign__c);
                    if(parentCamp != null) {
                        newLead.Campaign_Next_Steps__c = parentCamp.Next_Steps__c;
                        newLead.Campaign_Support_Info__c = parentCamp.Supporting_Information__c;
                        //v13.0 
                        //newLead.Sales_Call_to_Action__c = parentCamp.Sales_Call_to_Action__c;
                    }
                    // v1.3: CR 11962 - End
                }
                
                if(newLead.RecordTypeId == directLead2RTId && newLead.Status == 'Working') {  // v9.0
                //v9.0 if(newLead.RecordTypeId == directLead2RTId && newLead.Status == 'Accepted') {  
                    newLead.Lead_Accepted_Date__c = dtCurrentTime;
                }
                if(newLead.RecordTypeId == channelLead2RTId) {
                    newLead.Solution_Provider_can_contact_me__c = newLead.Dell_Partner_can_contact_me__c;
                }
                // v1.4: CR 12038- Begin
                if(setChannelBaseRTIds.contains(newLead.RecordTypeId) && newLead.Channel_Lead_Capture_Date__c == null) {
                    newLead.Channel_Lead_Capture_Date__c = dtCurrentTime.dateGMT();
                }
                // v1.4: CR 12038- End
                if(newLead.Campaign__c != null && setChannelBaseRTIds.contains(newLead.RecordTypeId) && (newLead.Source_Campaign_Id__c == null || newLead.Source_Campaign_Name__c == null)) {
                    Campaign campRecord = LeadTriggerHandler.leadRecSelector.mapRelatedCampaigns.get(newLead.Campaign__c);
                    if(campRecord != null){
                        newLead.Source_Campaign_Id__c = campRecord.Id;
                        newLead.Source_Campaign_Name__c = campRecord.Name;
                    }
                }
                
            }
            else if(leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                if(newLead.RecordTypeId == directLead2RTId && newLead.Status == 'Working' && oldLead.Status != 'Working') {
                //9.0 if(newLead.RecordTypeId == directLead2RTId && newLead.Status == 'Accepted' && oldLead.Status != 'Accepted') {
                    newLead.Lead_Accepted_Date__c = dtCurrentTime;
                }                
            }
        }        
        
    }
    
    // v1.0 populate latest reassignment date upon lead creation
    public static void populateLastOwnerReassignmentDate(list<Lead> lstDirectLeads2) {
        for(Lead newLead : lstDirectLeads2) {
            newLead.Last_Owner_Reassignment_Date__c = System.now();   
        }
    }
    
    // v1.0 populate latest reassignment date when lead owner get change
    public static void populateLastOwnerReassignmentDate(list<Lead> lstDirectLeads2, map<Id, Lead> mapOldLeads){
        for(Lead newLead : lstDirectLeads2) {
            Lead oldLead = mapOldLeads.get(newLead.Id);
            if(newLead.OwnerId != oldLead.OwnerId) {
                newLead.Last_Owner_Reassignment_Date__c = System.now();
            }
        }
    }    
    
    // v1.2 - Calls populateLeadOwnerDetails(list<Lead> lstLeads) to populate Lead fields based on the Lead Owner
    public static void populateLeadOwnerDetails(list<Lead> lstNewLeads, map<Id, Lead> mapOldLeads) {
        list<Lead> lstLeadsToProcess = new list<Lead>();
        

        for(Lead newLead : lstNewLeads) {
            Lead oldLead = mapOldLeads.get(newLead.Id);
            if(newLead.OwnerId != oldLead.OwnerId) {
                lstLeadsToProcess.add(newLead);
            }
        }
        if(!lstLeadsToProcess.isEmpty()) {
            populateLeadOwnerDetails(lstLeadsToProcess);
        }
    }
    
    // v1.2 - Auto populate Lead fields based on the Lead Owner
    public static void populateLeadOwnerDetails(list<Lead> lstLeads) {
        set<Id> setUserOwnerIds = new set<Id>();
        set<Id> setQueueOwnerIds = new set<Id>();
        for(Lead leadIterator : lstLeads) {
            system.debug('############# wanti in populateLeadOwnerDetails #####################');
            String strOwnerId = leadIterator.OwnerId;
            if(strOwnerId.startsWith('005')) {
                setUserOwnerIds.add(leadIterator.OwnerId);
            }
            else if(strOwnerId.startsWith('00G')) {
                setQueueOwnerIds.add(leadIterator.OwnerId);
            }
        }
        
        map<Id, User> mapUsers = new map<Id, User>();
        if(!setUserOwnerIds.isEmpty()) {
            mapUsers = new map<Id, User>([select Id, Name, ManagerId from User where Id in :setUserOwnerIds]);
        }
        map<Id, Group> mapQueues = new map<Id, Group>();
        if(!setQueueOwnerIds.isEmpty()) {
            mapQueues = new map<Id, Group>([select Id, Name from Group where Id in :setQueueOwnerIds]);
        }
        
        for(Lead leadIterator : lstLeads) {
            system.debug('wanti leadIterator.OwnerId: '+leadIterator.OwnerId);
            String strOwnerId = leadIterator.OwnerId;
            system.debug('wanti strOwnerId: '+strOwnerId);
            if(strOwnerId.startsWith('005')) {
                User userIterator = mapUsers.get(leadIterator.OwnerId);
               
                leadIterator.Lead_Owner_Name__c = userIterator.Name;
                
             //v6.0 - Lead_Owner_s_Manager__c now populated from new cross reference to ManagerId field in User object.     
             //   leadIterator.Lead_Owner_s_Manager__c = userIterator.ManagerId; 
            }
            else if(strOwnerId.startsWith('00G')) {
                Group groupIterator = mapQueues.get(leadIterator.OwnerId);
                
                leadIterator.Lead_Owner_Name__c = groupIterator.Name;
              //v6.0 - Lead_Owner_s_Manager__c now populated from new cross reference to ManagerId field in User object.  
             //   leadIterator.Lead_Owner_s_Manager__c = null; 
                 
            }
        }
    }
    
    // v2.0 - Clear Contact__c or Related_Contact__c whenever Account is removed or changed and Contact is not belongs to that Account.
    public static void clearRelatedContactOnAccountChange(list<Lead> lstNewLeads, map<Id, Lead> mapOldLeads, map<Id, Contact> mapContacts) {
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        Id channelLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
        for(Lead newLead : lstNewLeads) {
            Lead oldLead = mapOldLeads.get(newLead.Id);
            Contact contactIterator = null;
            if(newLead.Account__c != oldLead.Account__c && newLead.Contact__c == oldLead.Contact__c) {
                if(newLead.RecordTypeId == directLead2RTId && newLead.Contact__c != null) {
                    contactIterator = mapContacts.get(newLead.Contact__c);
                    if(newLead.Account__c == null || newLead.Account__c != contactIterator.AccountId) {
                        newLead.Contact__c = null;
                    }
                }
                else if(newLead.RecordTypeId == channelLead2RTId && newLead.Related_Contact__c != null) {
                    contactIterator = mapContacts.get(newLead.Related_Contact__c);
                    if(newLead.Account__c == null || newLead.Account__c != contactIterator.AccountId) {
                        newLead.Related_Contact__c = null;
                    }
                }
            }
        }
    }
    // v15.0 - start Populate Account for Direct Lead 2.0 when related contact has master account associated.
   // v1.2 - Populate Account for Direct Lead 2.0.
    public static void populateAccountForDirectLeads2(list<Lead> lstDLsToPopulateAccount, map<Id, Contact> mapContacts) {
        for(Lead leadIterator : lstDLsToPopulateAccount) {
            Contact contactIterator = mapContacts.get(leadIterator.Contact__c);
            leadIterator.Account__c = null;
            if(contactIterator != null && contactIterator.Account.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account').getRecordTypeId()) {
                leadIterator.Account__c = contactIterator.AccountId;
            }
            else if(contactIterator != null && contactIterator.Account.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account').getRecordTypeId()){
               leadIterator.Account__c = contactIterator.Preferred_Track__r.Primary_SMAffinity_Account__c;
            }
        }
    }
    //v15.0 - end
    // v1.2 - Populate Account and Account Owner for Channel Leads.
    // This logic is moved from CMAP_BeforeInsertUpdateLeadTrigger and included Channel Lead 2.0 in the field population
    public static void populateAccountForChannelLeads(list<Lead> lstCLsToPopulateAccount, map<Id, Contact> mapContacts) {
        for(Lead leadIterator : lstCLsToPopulateAccount) {
            Contact contactIterator = mapContacts.get(leadIterator.Related_Contact__c);
            leadIterator.Account__c = null;
            leadIterator.Account_Owner__c = null;
            if(contactIterator != null) {
                leadIterator.Account__c = contactIterator.AccountId;
                leadIterator.Account_Owner__c = contactIterator.Account.OwnerId;
            }
        }
    }
    
    //v12.0 Populate Zift Leads with Partner Account and Partner User
    public static void populatePartnerAccountAndUserForZiftLeads(list<Lead> listZiftCLs, Set<String> setZiftAffinityIds, Set<String> setZiftSalesRepEmailIds,Set<String> setZiftCampaignNames) {
        set<Id> setExistingPCMAccountIds = new set<Id>();
        set<Partner_Campaign_Management__c> setNewPCM2Insert = new set<Partner_Campaign_Management__c>();
        list<User> listZiftUser=[Select Id,email from User where email in :setZiftSalesRepEmailIds AND Enable_Partner_Lead_Management__c=true AND IsPortalEnabled=true AND UserType ='PowerPartner' AND isActive=true order by CreatedDate];
        map<String,Id> mapZiftPartnerUser=new map<String,Id>();
        for ( User userZift :  listZiftUser){
            mapZiftPartnerUser.put(userZift.email, userZift.Id);
        }
        
        list<Account> listZiftAccount=[Select Id, Account_Id__c from Account where Account_Id__c in :setZiftAffinityIds];
        list<Partner_Campaign_Management__c> listExistingPCM = [SELECT Id,Partner_Account__c FROM Partner_Campaign_Management__c where Campaign__c in :setZiftCampaignNames and Affinity_Account_ID__c in :setZiftAffinityIds];
        system.debug(Logginglevel.INFO,'@@@ List of PCM to be inserted  :' +  listExistingPCM);
        for(Partner_Campaign_Management__c existingPCM : listExistingPCM){
            setExistingPCMAccountIds.add(existingPCM.Partner_Account__c);
        }
        map<String,Id> mapZiftAccount=new map<String,Id>();
        for ( Account  accountZift:  listZiftAccount){
            mapZiftAccount.put(accountZift.Account_Id__c, accountZift.Id);
        }
        
        /*
        //Below code segmaent can be used if Zift send the Campaign Name instead of Campaign Id
        list<Campaign> listZiftCampaign=[Select Id, Name from Campaign where Name in :setZiftCampaignNames];
        map<String,Id> mapZiftCampaign=new map<String,Id>();
        for ( Campaign  campaignZift:  listZiftCampaign){
            mapZiftAccount.put(campaignZift.Name, campaignZift.Id);
        }*/
        
        for(Lead leadIterator : listZiftCLs) {
            system.debug('@@@@ Lead Field Populator : Ready for Scoring ' +  leadIterator.Ready_for_Scoring__c);
            leadIterator.Ready_for_Scoring__c=true;
            leadIterator.Called_Customer__c = 'Yes';
            leadIterator.Sales_Qualified__c = 'Qualified';
            //leadIterator.Campaign__c = mapZiftCampaign.get(leadIterator.Campaign__c);
            leadIterator.Partner_Account__c = mapZiftAccount.get(leadIterator.Zift_Lead_Partner__c);
            leadIterator.Partner_User__c = mapZiftPartnerUser.get(leadIterator.Zift_Sales_Rep_Email__c);
            //Code to add Partner Campaign Member record for the account, if its not existing
            if(leadIterator.Partner_Account__c!=null && !setExistingPCMAccountIds.contains(leadIterator.Partner_Account__c)){
                Partner_Campaign_Management__c objNewPCM = new Partner_Campaign_Management__c();
                objNewPCM.Campaign__c=leadIterator.Campaign__c;
                objNewPCM.Partner_Account__c=leadIterator.Partner_Account__c;
                //objNewPCM.Affinity_Account_ID__c=leadIterator.Zift_Lead_Partner__c;  
                setNewPCM2Insert.add(ObjNewPCM);
            }
        }
        //Insert PCM records
        if(setNewPCM2Insert.size()>0){
            list<Partner_Campaign_Management__c> listNewPCM2Insert = new list<Partner_Campaign_Management__c>(setNewPCM2Insert);
            system.debug(Logginglevel.INFO,'@@@ List of PCM to be inserted  :' +  listNewPCM2Insert);
            insert listNewPCM2Insert;
        }
      }
    
    // v1.2 - Populate Partner Account: This function is not used as on Release 16.10 but can be used when implementing CBO architecture for Lead object
    public static void populatePartnerAccount(list<Lead> lstLeads, set<Id> setUserIds) {
        map<Id, User> mapUsers = new map<Id, User>([select Id, AccountId, Contact.Account.OwnerId from User where Id in :setUserIds]);
        for(Lead leadIterator : lstLeads) {
            User userIterator = mapUsers.get(leadIterator.Partner_User__c);
            if(userIterator != null) {
                leadIterator.Partner_Account__c = userIterator.AccountId;
                leadIterator.Partner_Account_Owner_ApiOnly__c = userIterator.Contact.Account.OwnerId;
            }
        }
    }
    
    //v17.0 - Start
    public static void populateRelatedOpportunity(list<Lead> listLeads, set<String> setDealIds){
    
    System.debug('Before Insert Inside LeadfieldPopulator***************');
        
    Map<String,Opportunity> mapDealToOpp= new  Map<String,Opportunity>();
    Map<Id,User> mapUserObj= new  Map<Id,User>();
    Map<Id,String> mapConIdsToSM= new  Map<Id,String>();
    List<opportunity> listOpp = new List<Opportunity>();
    Set<Id> setUser = new Set<Id>();
    Set<Id> setContact = new Set<Id>();
        
    CMAP_Queue_Settings__c queueNAId = CMAP_Queue_Settings__c.getValues('NA_LM');
    CMAP_Queue_Settings__c queueLATAMId = CMAP_Queue_Settings__c.getValues('LATAM_LM');
    CMAP_Queue_Settings__c queueAPJId = CMAP_Queue_Settings__c.getValues('APJ_LM');
    CMAP_Queue_Settings__c queueEMEAId = CMAP_Queue_Settings__c.getValues('EMEA_LM');
    
    
    for(Opportunity objOpp: [select Id, Deal_ID__c,CampaignId,Deal_Registration_Status__c from Opportunity where Deal_ID__c  in :setDealIds]){
       mapDealToOpp.put(objOpp.Deal_ID__c, objOpp);
    }
    System.debug('mapDealToOpp*******************'+mapDealToOpp);
    
    for(Lead objLead: listLeads){
    
    if((objLead.Deal_1_ID__c != null && mapDealToOpp.get(objLead.Deal_1_ID__c).Deal_Registration_Status__c != 'Approved')|| 
       (objLead.Deal_2_ID__c != null && mapDealToOpp.get(objLead.Deal_2_ID__c).Deal_Registration_Status__c != 'Approved')||
       (objLead.Deal_3_ID__c != null && mapDealToOpp.get(objLead.Deal_3_ID__c).Deal_Registration_Status__c != 'Approved')||
       (objLead.Deal_4_ID__c != null && mapDealToOpp.get(objLead.Deal_4_ID__c).Deal_Registration_Status__c != 'Approved')||
       (objLead.Deal_5_ID__c != null && mapDealToOpp.get(objLead.Deal_5_ID__c).Deal_Registration_Status__c != 'Approved')||
       (objLead.Deal_6_ID__c != null && mapDealToOpp.get(objLead.Deal_6_ID__c).Deal_Registration_Status__c != 'Approved'))
     {
        objLead.addError('Lead can be associated only to approved opportunities'); 
     }
     else{
        if(objLead.Deal_1_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_1_ID__c)){
        System.debug('Inside Deal 1 population*******************'+mapDealToOpp.get(objLead.Deal_1_ID__c));
          objLead.Related_Opportunity_1__c= mapDealToOpp.get(objLead.Deal_1_ID__c).Id;
          objLead.Related_Opportunity__c= mapDealToOpp.get(objLead.Deal_1_ID__c).Id;
          
        }
        if(objLead.Deal_2_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_2_ID__c)){
          objLead.Related_Opportunity_2__c= mapDealToOpp.get(objLead.Deal_2_ID__c).Id;
           if(objLead.Related_Opportunity__c == null){
              objLead.Related_Opportunity__c= mapDealToOpp.get(objLead.Deal_2_ID__c).Id;
          }
        }
        if(objLead.Deal_3_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_3_ID__c)){
          objLead.Related_Opportunity_3__c= mapDealToOpp.get(objLead.Deal_3_ID__c).Id;
          if(objLead.Related_Opportunity__c == null){
              objLead.Related_Opportunity__c= mapDealToOpp.get(objLead.Deal_3_ID__c).Id;
          }
        }
        if(objLead.Deal_4_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_4_ID__c)){
          objLead.Related_Opportunity_4__c= mapDealToOpp.get(objLead.Deal_4_ID__c).Id;
          if(objLead.Related_Opportunity__c == null){
              objLead.Related_Opportunity__c= mapDealToOpp.get(objLead.Deal_4_ID__c).Id;
          }
        }
        if(objLead.Deal_5_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_5_ID__c)){
          objLead.Related_Opportunity_5__c= mapDealToOpp.get(objLead.Deal_5_ID__c).Id;
          if(objLead.Related_Opportunity__c == null){
              objLead.Related_Opportunity__c= mapDealToOpp.get(objLead.Deal_5_ID__c).Id;
          }
        }
        if(objLead.Deal_6_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_6_ID__c)){
          objLead.Related_Opportunity_6__c= mapDealToOpp.get(objLead.Deal_6_ID__c).Id;
          if(objLead.Related_Opportunity__c == null){
              objLead.Related_Opportunity__c= mapDealToOpp.get(objLead.Deal_6_ID__c).Id;
          }
        }
     }
        objLead.RecordTypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Conversion','Lead',true);
        objLead.Status = 'Converted to Deal Reg';
        objLead.Partner_Lead_Status__c = 'Deal Registered';
        objLead.Called_Customer__c = 'Yes';
        objLead.Sales_Qualified__c = 'Qualified';
        
        if(objLead.Partner_User__c != NULL)
        {
            setUser.add(objLead.Partner_User__c);
        }
        if(objLead.Partner_Admin__c != NULL)
        {
            setUser.add(objLead.Partner_Admin__c);
        }
        
        System.debug('User Set*******************'+setUser);
        //setContact.add(objLead.Contact__c);
        
    } 
   
    for(User u: [SELECT id,Name,Enable_Partner_Lead_Management__c,ContactId,Contact.Preferred_Track__r.Primary_SMAffinity_Account__c from User where Id IN : setUser]){
        mapUserObj.put(u.Id,u);
    }
         System.debug('User map*******************'+mapUserObj);
    
    //Lead Owner Population
    for(Lead objLead: listLeads){
        If(objLead.Partner_User__c != NULL && mapUserObj.containskey(objLead.Partner_User__c) && mapUserObj.get(objLead.Partner_User__c).Enable_Partner_Lead_Management__c == TRUE){
        System.debug('Inside Lead owner population 1*******************');
            objLead.OwnerId =objLead.Partner_User__c;
            objLead.Lead_Owner_Name__c = mapUserObj.get(objLead.Partner_User__c).Name;
            System.debug('Inside Lead owner population 1 objLead.Partner_User__c*******************'+objLead.Partner_User__c);
        }
        else if(objLead.Partner_Admin__c != NULL && mapUserObj.containskey(objLead.Partner_Admin__c) && mapUserObj.get(objLead.Partner_Admin__c).Enable_Partner_Lead_Management__c == TRUE){
            System.debug('Inside Lead owner population 2*******************');
            objLead.OwnerId =objLead.Partner_Admin__c;
            objLead.Lead_Owner_Name__c = mapUserObj.get(objLead.Partner_Admin__c).Name;
            System.debug('Inside Lead owner population 2 objLead.Partner_User__c*******************'+objLead.Partner_User__c);
        }
       else if(objLead.Region__c != NULL){
           System.debug('Inside Lead owner population 3*******************');
            if(objLead.Region__c.contains('NA')){
                System.debug('Inside Lead owner population 4*******************');
                    objLead.OwnerId = queueNAId.Queue_Id__c;
                    objLead.Lead_Owner_Name__c=queueNAId.Name;
                 System.debug('Inside Lead owner population 4 objLead.OwnerId *******************'+objLead.OwnerId );
                }
               else if(objLead.Region__c.contains('LATAM')){
                    objLead.OwnerId = queueLATAMId.Queue_Id__c;
                    objLead.Lead_Owner_Name__c=queueLATAMId.Name;
                }
                else if(objLead.Region__c.contains('APJ')){
                    objLead.OwnerId = queueAPJId.Queue_Id__c;
                    objLead.Lead_Owner_Name__c=queueAPJId.Name;
                }
                else if(objLead.Region__c.contains('EMEA')){
                    objLead.OwnerId = queueEMEAId.Queue_Id__c;
                    objLead.Lead_Owner_Name__c=queueEMEAId.Name;
                } 
        }
        
        //Lead Partner Account Population
        System.debug('Before Partner Account update*******************'+objLead.Partner_Account__c);
        If(mapUserObj != NULL && mapUserObj.containsKey(objLead.Partner_User__c) && mapUserObj.get(objLead.Partner_User__c).ContactId != NULL){
        objLead.Partner_Account__c = mapUserObj.get(objLead.Partner_User__c).Contact.Preferred_Track__r.Primary_SMAffinity_Account__c;
        System.debug('Partner Account updated*******************'+objLead.Partner_Account__c);
        }
    }
    }
    public static Opportunity populateOpptyFields(Lead objLead, Opportunity objOpp){
    System.debug('Inside oppty field population*******************'+objLead);
        System.debug('Inside oppty field population*******************'+objOpp);
        System.debug('Campaign NULL check*******************'+objOpp.CampaignId);
        if(objOpp.CampaignId == NULL){
            System.debug('Inside Campaign NULL block*******************'+objOpp.CampaignId);
            objOpp.CampaignId = objLead.Campaign__c;
            objOpp.Channel_Lead_Id__c = objLead.Id;
            objOpp.Channel_Lead_ID_2__c = objLead.Id;
            objOpp.Primary_Campaign_ID__c = objLead.Campaign__c  ;
        }
        return objOpp;
    }
    public static void linkChannelLeadToOpportunity (list<Lead> listLeads, set<String> setDealIds){
    
    System.debug('After Insert Inside LeadfieldPopulator***************');
    
    Map<String,Opportunity> mapDealToOpp= new  Map<String,Opportunity>();
    List<Opportunity> listOpp= new List<opportunity>();
        for(Opportunity objOpp: [select Id, Deal_ID__c,campaignId from Opportunity where Deal_ID__c  in :setDealIds]){
           mapDealToOpp.put(objOpp.Deal_ID__c, objOpp);
        }
        System.debug('mapDealToOpp*******************'+mapDealToOpp);
    
        for(Lead objLead: listLeads){
            if(objLead.Deal_1_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_1_ID__c)){
                System.debug('Inside Deal 1 population*******************'+mapDealToOpp.get(objLead.Deal_1_ID__c));
                System.debug('Inside Deal 1 population*******************'+objLead);
                listOpp.add(populateOpptyFields(objLead,mapDealToOpp.get(objLead.Deal_1_ID__c)));
            }
            if(objLead.Deal_2_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_2_ID__c)){
                listOpp.add(populateOpptyFields(objLead,mapDealToOpp.get(objLead.Deal_2_ID__c)));
            }
            if(objLead.Deal_3_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_3_ID__c)){
                listOpp.add(populateOpptyFields(objLead,mapDealToOpp.get(objLead.Deal_3_ID__c)));
            }
            if(objLead.Deal_4_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_4_ID__c)){
                listOpp.add(populateOpptyFields(objLead,mapDealToOpp.get(objLead.Deal_4_ID__c)));
            }
            if(objLead.Deal_5_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_5_ID__c)){
                listOpp.add(populateOpptyFields(objLead,mapDealToOpp.get(objLead.Deal_5_ID__c)));
            }
            if(objLead.Deal_6_ID__c != null && mapDealToOpp.containsKey(objLead.Deal_6_ID__c)){
                listOpp.add(populateOpptyFields(objLead,mapDealToOpp.get(objLead.Deal_6_ID__c)));
            }
              
        } 
        
        if(!listOpp.isEmpty()){
            TriggerExecutionController.setSkipOpportunityTriggers(True);
            try {
                // Perform the update
                Database.SaveResult[] listResults = Database.update(listOpp, false);
                System.debug('After Update*******************'+listOpp);
                system.debug('updResults size**************'+listResults.size());
                system.debug('updResults**************'+listResults[0]);   
                        
                for (Database.SaveResult cList: listResults) {
                    if (!cList.isSuccess()) {
                        for(Database.Error err : clist.getErrors()) {
                        System.debug('Error in Oppty update*******************'+listOpp);
                            System.debug('Error in Oppty update*******************'+err.getMessage());
                        listLeads[0].addError(err.getMessage());
                        
                        }
                    }
                    else{
                        System.debug('Update Successful');
                    }
                }   // End if (insResults[i].isSuccess() == false)  
                        }catch (Exception e) {
                        System.debug('Error Occured !!!!!!!!!');
                }            
                
            TriggerExecutionController.setSkipOpportunityTriggers(False);   
        }  
    
    }
    //v17.0 - end
    
    public static void populateFAPLeadData(List<Lead> lstLeads){
        Id channelLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
       List<Lead> lstLeadData = new List<Lead>();
       List<String> mapLeadData = new List<String>();
       List<Id> accountList = new List<Id>();
       Id superUser;
       Id partnerUserAdmin;
       
       for(Lead obj: lstLeads){
           if(obj.FAP_Originated_Lead__c == 'Yes'){
               lstLeadData.add(obj);
               mapLeadData.add(obj.Country.toUpperCase()); 
               accountList.add(obj.Partner_Account__c);
           }
       }
       System.Debug('mapLeadData##'+mapLeadData);
       System.Debug('accountList##'+accountList);
       list<Id> listUserId = new List<id>();
       Set<Id> setaccids= new Set<Id>();
       setaccids.addAll(accountList);
       system.debug('@@@@@@@@@@@@accountList'+accountList);
       // 14.0 Defect 6342705
       list<Account> listAccount = [select id,name ,Primary_Contact__c,Primary_Contact__r.Partner_User__c from account where id IN : setaccids];
       for(Account Acc : listAccount)
       {
           if(Acc.Primary_Contact__r.Partner_User__c != null)
           {
              listUserId.add(Acc.Primary_Contact__r.Partner_User__c);
           }
       }
       system.debug('@@@@@@@@@@@@listUserId'+listUserId);
     
       
       Map<String, String> countryToFAPRegionMap = new Map<String, String>();
       for(Country__c fapRegion: [Select FAP_Country_Value__c,Region__c From Country__c Where FAP_Country_Value__c IN :mapLeadData and Enable_for_FAP__c = true]){
            //map Country to Region
            countryToFAPRegionMap.put(fapRegion.FAP_Country_Value__c.toUpperCase(), fapRegion.Region__c);
       }
       System.Debug('countryToFAPRegionMap##'+countryToFAPRegionMap);       
       DateTime SuperUser_lastlogindate;
       DateTime partnerAdmin_lastlogindate;
      
       for(User obj:[select Id,Enable_As_Partner_Lead_Super_User__c, Enable_Partner_Admin__c,lastlogindate from User where Id in: listUserId and IsActive = true and (Enable_As_Partner_Lead_Super_User__c = true or Enable_Partner_Admin__c = true)]){
       system.debug('@@@@@@@@@@@@obj'+obj);
            if(superUser == null){
               if(obj.Enable_As_Partner_Lead_Super_User__c){
                  superUser = obj.Id; 
                  SuperUser_lastlogindate = obj.lastlogindate;                
               }
           }
           if(partnerUserAdmin == null){
               if(obj.Enable_Partner_Admin__c != null){
                   partnerUserAdmin = obj.Id;
                   partnerAdmin_lastlogindate = obj.lastlogindate;
               }
           }
           if(superUser != null){
               if(obj.lastlogindate > SuperUser_lastlogindate){
                   superUser = obj.Id;
                   SuperUser_lastlogindate = obj.lastlogindate;
               }
           }
           if(partnerUserAdmin != null){
               if(obj.lastlogindate > partnerAdmin_lastlogindate){
                   partnerUserAdmin = obj.Id;
                   partnerAdmin_lastlogindate = obj.lastlogindate;
               }
           }   
       }
       System.Debug('superUser##'+superUser);
       System.Debug('partnerUserAdmin##'+partnerUserAdmin); 
       
       if(lstLeadData.size() >0){
           for(Lead obj: lstLeadData){
               if(countryToFAPRegionMap.containsKey(obj.Country.toUpperCase()) && !TestUtils.isTest){ //v3.0 added isTest to fix error INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY due to Campaign not available
                    obj.Region__c = countryToFAPRegionMap.get(obj.Country.toUpperCase());
                    System.Debug('**obj.Region__c1'+obj.Region__c);
                    if(obj.Region__c.contains('NA')){
                        obj.Campaign__c = system.label.ABU_Find_a_Partner_Channel;
                    }
                    else if(obj.Region__c.contains('LATAM')){
                        obj.Campaign__c = system.label.LATAM_Find_a_Partner_CHN;
                    }
                    else if(obj.Region__c.contains('APJ')){
                        obj.Campaign__c = system.label.APJ_Find_a_Partner_CHN;
                    }
                    else if(obj.Region__c.contains('EMEA')||obj.Region__c.contains('EC-EMEA')){
                        obj.Campaign__c = system.label.EMEA_Find_a_Partner_CHN;
                    }                   
               }
               System.Debug('**obj.Campaign__c'+obj.Campaign__c);
               
               if(superUser != null){
                   obj.OwnerId = superUser;
                   obj.Partner_User__c = superUser;
               }
               else if(partnerUserAdmin != null){
                   obj.OwnerId = partnerUserAdmin;
                   obj.Partner_User__c = partnerUserAdmin;
               }
               obj.Lead_Type__c = 'Inbound';
               obj.Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)';
               obj.Dell_Partner_can_contact_me__c = true;
               obj.Sales_Comments__c = 'Find a Partner Lead: An email confirming the customer enquiry has been sent to ' + obj.FAP_Point_of_Contact_Email__c + ' on '+ System.Today();                
               obj.RecordTypeId = channelLead2RTId ;
           }
       }
       System.Debug('lstLeadData##'+lstLeadData);
    }
    //Start V2.3
    public static void populateLeadOwnerRole(list<Lead> lstDirectLeads2, map<Id, Lead> mapOldLeads){
        set<Id> setAccountIds = new set<Id>();
        set<Id> setOwnerIds = new Set<Id>(); //8.0
        list<Lead> processTheseLead = new list<Lead>();
        
        for(Lead newLead : lstDirectLeads2) {
          if(mapOldLeads == null){ //v16.0 - Added If Block to handle Lead Insert
              setAccountIds.add(newLead.Account__c);
              setOwnerIds.add(newLead.OwnerId); 
              processTheseLead.add(newLead);
          }else{
              Lead oldLead = mapOldLeads.get(newLead.Id);
              if(newLead.OwnerId != oldLead.OwnerId) {
                  setAccountIds.add(newLead.Account__c);
                  setOwnerIds.add(newLead.OwnerId); //8.0
                  processTheseLead.add(newLead);
              }
          }
            
        } 
           
        setAccountIds.remove(null);
               
        //Get owners User Role Name
        map<Id, User> mapUsers = new map<Id,User>([Select id,Resource_Manager_Role__c from user where id in :setOwnerIds and IsActive = TRUE]); //8.0             
        // Get Account Team Members
        map<Id, map<Id, String>> mapAccountIdUserTeamMember = new map<Id, map<Id, String>>();
        map<Id,Id> mapAccountOwnerId = new Map<Id,Id>();
        
        for(Account acc : [select id,name,OwnerId,(select Id, AccountId, TeamMemberRole, UserId,Account.OwnerId from AccountTeamMembers where User.IsActive = true order by AccountId, User.Badge_Number__c asc) from Account where Id in :setAccountIds]) {
           
           for(AccountTeamMember accTeamMember: acc.AccountTeamMembers){
                if(mapAccountIdUserTeamMember.get(accTeamMember.AccountId) == null) {
                    mapAccountIdUserTeamMember.put(accTeamMember.AccountId, new map<Id, String>{accTeamMember.UserId => accTeamMember.TeamMemberRole});
                }
                else {              
                    mapAccountIdUserTeamMember.get(accTeamMember.AccountId).put(accTeamMember.UserId, accTeamMember.TeamMemberRole);
                }
           }
            mapAccountOwnerId.put(acc.Id,acc.OwnerId);
            
        }       
        for(Lead newLead : processTheseLead) {
            //below line added for V2.4
            newLead.Lead_Found_Designated_Follow_Up_Role__c = false;
            map<Id, String> mapOwnerToRole = new map<Id, String>();
                if(mapAccountIdUserTeamMember !=null && !mapAccountIdUserTeamMember.isEmpty() && mapAccountIdUserTeamMember.containsKey(newLead.Account__c)){
                  mapOwnerToRole = mapAccountIdUserTeamMember.get(newLead.Account__c);
               }            
                if(mapOwnerToRole !=null && !mapOwnerToRole.isEmpty() && mapOwnerToRole.containskey(newLead.OwnerId)){
                    newLead.Lead_Owner_Role__c = mapOwnerToRole.get(newLead.OwnerId);
                }
                
                //if Lead Owner is not in Account Team Members then next priority to search for Owners Resource Manager Role
                
                else if(!mapUsers.isEmpty() && mapUsers.containsKey(newLead.OwnerId) && mapUsers.get(newLead.OwnerId).Resource_Manager_Role__c != null){
                    newLead.Lead_Owner_Role__c = mapUsers.get(newLead.OwnerId).Resource_Manager_Role__c;
                }//if Resource manager Role is blank - check if account Owner and Lead Owner are same?
                else if(!mapAccountOwnerId.IsEmpty() && mapAccountOwnerId.containskey(newLead.Account__c) && newLead.OwnerId == mapAccountOwnerId.get(newLead.Account__c)){
                    newLead.Lead_Owner_Role__c = 'Account Owner';
                }else{
                    newLead.Lead_Owner_Role__c = 'N/A'; //5.0
                }
                 system.debug('#############populateLeadownerRole#####################'+newLead.Lead_Owner_Role__c);    
             }
            
    }
    //End V2.3
    //7.0 Method to populate Sales Assigned Date during update
    public static void populateSalesAssignedDate(list<Lead> listDirectLeads2,map<Id, Lead> mapOldLeads){
        List<Lead> listLeadsToProcess = new List<Lead>();
        set<Id>  setLeadowners = new set<Id>();
        //Below code block collects the leads and users which need to be further processed for owner profile verification
        //Code block to handle lead updates
        if(mapOldLeads!=null){
            for(Lead newLead : listDirectLeads2) {
                Lead oldLead = mapOldLeads.get(newLead.Id);
                System.debug('New Lead Owner :' + newLead.OwnerId  + '   Old Lead Owner :' + oldLead.OwnerId);
                if(newLead.OwnerId != oldLead.OwnerId){
                    setLeadowners.add(newLead.OwnerId);
                    listLeadsToProcess.add(newLead);
                }
            }
        }
        //Code block to handle lead insert, Collecting all leads irrespective of owner change
        else{
            for(Lead newLead : listDirectLeads2) {
                setLeadowners.add(newLead.OwnerId);
                listLeadsToProcess.add(newLead);
            }
        }   
        //Collect all the sales/service users from the above lead owner collection
        if(setLeadOwners.size()>0){
            map<id,User> mapSalesUser=new map<id,User>([SELECT id,Profile_Name__c from USER where Id IN :setLeadowners AND (Profile_Name__c LIKE '%Sales%' OR Profile_Name__c LIKE '%Services%')]);
            //Loop through the leads which has an owner change
            for(Lead newLead : listLeadsToProcess) {
                if(mapSalesUser.containsKey(newLead.OwnerId)){
                    //Update First time assigned to Sales date&time if it is not populated yet
                    if(newLead.First_time_assigned_to_Sales__c==Null)
                    {
                        newLead.First_time_assigned_to_Sales__c=system.now();
                    }
                }                  
            }
        }
    }
    //7.0 New logic to calculate Sales Followup Days
    public static void populateSalesFollowUpDays(list<Lead> listDirectLeads2,map<Id, Lead> mapOldLeads){
        Decimal dcmDays;
        
        //count SalesFollowUpDays for Sales user only
        List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id =:userinfo.getProfileId() LIMIT 1];
        String currentUserProfileName = lstProfile[0].Name;
    
        if(currentUserProfileName.contains('Sales')){
            for(Lead newLead : listDirectLeads2) {
                Lead oldLead = mapOldLeads.get(newLead.Id);
                if(oldLead.Status != newLead.Status && 
                   newLead.Sales_Follow_up_days__c == null &&
                   newLead.First_time_assigned_to_Sales__c !=null &&
                   newLead.Assigned_to_Sales__c &&
                   newLead.Status!= 'New'
                   ){ // &&  v9.1
                 //v9.1  newLead.Status!= 'Working') {
                    newLead.Sales_Follow_up_days__c=calcSalesFollowUpDays(newLead.First_time_assigned_to_Sales__c);
                }
            }
        }
    } 
    //This method performes the calculation, conversion to decimal and roundup of salesfollowup days
    public static decimal calcSalesFollowUpDays(DateTime dtassigned_date_time){
        Decimal dcmDays=0;                
        dcmDays=system.now().gettime()- dtassigned_date_time.gettime();
        dcmDays = dcmDays / (1000*60*60*24);
        return dcmDays.setscale(1, System.RoundingMode.HALF_UP);
    } 
}