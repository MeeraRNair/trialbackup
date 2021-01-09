/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to Lead object. 
 *          Please create separate classes and use it for complex logics.
 *        
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR: 10747   16.03           22-Dec-2014     Ragu            Populate Lead Status as "Accepted by Channel Partner" for all partner submitted MLUR's.
 * 1.1      CR: 10747   16.03           11-Feb-2015     Jiji            Defect fix for #154510
 * 2.0      CR: 11925   16.10           03-Aug-2015     Ragu            LM2_1_01_18_Implement the identified Lead trigger functionalities for Lead 2.0.
 * 2.1      TFS: 201756 16.10           08-Oct-2015     Ragu            Getting Apex Trigger error while creating lead 2.0 record for a Campaign which has past due date
 * 3.0      CR 12500    16.12           30-Dec-2015     Niveda          Invoke Campaign Lead close date Validation in lead update
 * 4.0      CR 14043    DCS-0403        22-Mar-2017     Azlan           Adding condition for new value (BANT Qualified) in Lead Status & Partner Lead Status
 * 5.0      CR 15686    DCS-0602        26-Apr-2018     Shue            Story 4144896: Channel: Remove BANT Qualified leads process (Code)
 */

public class LeadUtilities {
    
    // v1.0
    public static void updateLeadStatusForPartnerMLURs(list<Lead> lstNewLeads, map<Id, Lead> mapOldLeads) {
        set<Id> setUserIds = new set<Id>();
        list<Lead> lstLeads = new list<Lead>();
        
        Id leadAssignmentRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        
        // v1.1 - Added 'Channel Lead - Cleansing & Scoring Complete' in the below setCLRTIds.
        // v2.0 - Added "Channel Lead 2.0" in the below setCLRTIds.
        set<Id> setCLRTIds = StaticFactory.getRecordTypeIdsByNames('Lead', new set<String>{'Channel Lead - Submission', 'Channel Lead - Cleansing & Scoring Complete', 'Channel Lead 2.0'});
        
        for(Lead newLead : lstNewLeads) {
            System.debug('RT---'+setCLRTIds.contains(newLead.RecordTypeId));
            System.debug('newLead.Are_you_a_Dell_Partner__c--'+newLead.Are_you_a_Dell_Partner__c);
            System.debug('newLead.Ready_for_Scoring__c--'+newLead.Ready_for_Scoring__c);
            System.debug('newLead.Partner_User__c--'+newLead.Partner_User__c);
            System.debug('mapOldLeads--'+mapOldLeads);
            System.debug('mapOldLeads.get(newLead.Id)--'+mapOldLeads.get(newLead.Id));
            System.debug('mapOldLeads.get(newLead.Id).Ready_for_Scoring__c--'+mapOldLeads.get(newLead.Id).Ready_for_Scoring__c);
            if(setCLRTIds.contains(newLead.RecordTypeId) && newLead.Are_you_a_Dell_Partner__c == 'Yes' && newLead.Ready_for_Scoring__c == true && (newLead.Partner_User__c != null || newLead.Partner_Admin__c != null)
                && (mapOldLeads == null || (mapOldLeads != null && mapOldLeads.get(newLead.Id) != null && mapOldLeads.get(newLead.Id).Ready_for_Scoring__c == false))) {
                setUserIds.add(newLead.Partner_User__c);
                setUserIds.add(newLead.Partner_Admin__c);
                lstLeads.add(newLead);
            }
        }
        
        if(!lstLeads.isEmpty()) {
            map<Id, String> mapUserIdLanguageKey = new map<Id, String>();
            setUserIds.remove(null);
            if(!setUserIds.isEmpty()) {
                for(User userIterator : [select Id, LanguageLocaleKey from User where Id in :setUserIds and IsActive = true]) {
                    mapUserIdLanguageKey.put(userIterator.Id, userIterator.LanguageLocaleKey);
                }
            }
                        for(Lead newLead : lstLeads) {

                if(mapUserIdLanguageKey.get(newLead.Partner_User__c) != null || mapUserIdLanguageKey.get(newLead.Partner_Admin__c) != null) {
                    if(newLead.Partner_User__c != null) {
                        newLead.OwnerId = newLead.Partner_User__c;
                        newLead.Owner_Language_Code__c = mapUserIdLanguageKey.get(newLead.Partner_User__c);
                    }
                    else if(newLead.Partner_Admin__c != null) {
                        newLead.OwnerId = newLead.Partner_Admin__c;
                        newLead.Owner_Language_Code__c = mapUserIdLanguageKey.get(newLead.Partner_Admin__c);
                    }
                    /*
                    newLead.RecordTypeId = leadAssignmentRTId;
                    newLead.Status = 'Accepted by Channel Partner';
                    newLead.Send_email_for_Accepted_Status__c = true;
                    newLead.Partner_Lead_Status__c = 'Accepted';
                    newLead.Accept_Reject_Reassign_Status__c = 'Accepted by Channel';
                    */
                    //v4.0
                    
                    //5.0 Take out BANT_Qualified__c
                    /*
                    if(newLead.BANT_Qualified__c == true){
                        newLead.Status = 'BANT Qualified';
                        newLead.Partner_Lead_Status__c = 'BANT Qualified';
                        newLead.Send_email_for_Accepted_Status__c = true;
                        newLead.Accept_Reject_Reassign_Status__c = 'Accepted by Channel';
                        newLead.RecordTypeId = leadAssignmentRTId;
                    }
                    */
                    
                    //5.0 Take out BANT_Qualified__c
                    //if(newLead.BANT_Qualified__c == false && newLead.Partner_Event_or_Campaign__c == 'Yes'){
                    if(newLead.Partner_Event_or_Campaign__c == 'Yes'){
                      newLead.Status = 'Accepted by Channel Partner';
                      newLead.Partner_Lead_Status__c = 'Accepted';
                      newLead.Send_email_for_Accepted_Status__c = true;
                      newLead.Accept_Reject_Reassign_Status__c = 'Accepted by Channel';
                      newLead.RecordTypeId = leadAssignmentRTId;
                    }
                    
                    //5.0 Take out BANT_Qualified__c
                    //if(newLead.Partner_Event_or_Campaign__c == 'No' && newLead.BANT_Qualified__c == false){
                    if(newLead.Partner_Event_or_Campaign__c == 'No'){
                        newLead.Status = 'Assigned to Channel Partner';
                        newLead.Partner_Lead_Status__c = 'New'; 
                        newLead.RecordTypeId = leadAssignmentRTId;                           
                    }    
                    
                        
                }
            }
        }
    }
    
    // v2.0 - Populate Total Leads and Total Contacts for a Campaign.
    public static void rollupLeadsAndContactsForCampaign(list<Lead> lstAllLeads2, map<Id, Lead> mapOldLeads, LeadTriggerHandler leadTrigHandler) {
        set<Id> setCampaignIds = new set<Id>();
        map<id,Campaign> mapValidateCampaign = new map<id,Campaign>();
        Map<Id,Id> mapLeadCampaign = new map<id,id>();
        set<Id> validateCampaignIds = new set<Id>();
        list<lead> validateLeads = new list<lead>();
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');

        for(Lead newLead : lstAllLeads2) {
            Lead oldLead = null;
            if(leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                oldLead = mapOldLeads.get(newLead.Id);
            }
            
            if(leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE || leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUNDELETE 
                || (leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && (newLead.Campaign__c != oldLead.Campaign__c || newLead.Related_Contact__c != oldLead.Related_Contact__c || newLead.Contact__c != oldLead.Contact__c))) {
                setCampaignIds.add(newLead.Campaign__c);
                
                if(oldLead != null) {
                    setCampaignIds.add(oldLead.Campaign__c);
                }
            }
            
            if(newLead.recordTypeId == directLead2RTId && ((leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && newLead.Campaign__c != null) || (leadTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && (newLead.Campaign__c != oldLead.Campaign__c))) ){
              validateCampaignIds.add(newLead.Campaign__c);
              validateLeads.add(newLead);
              mapLeadCampaign.put(newLead.id,newLead.Campaign__c);
              
            }
        }
        setCampaignIds.remove(null);
        validateCampaignIds.remove(null);
       
       Map<ID,Campaign> mapCampaignList = new Map<ID, Campaign>( [select id,Close_Date_for_Leads__c  from campaign where id in: validateCampaignIds]);
       for(id i : mapLeadCampaign.keyset()){
         mapValidateCampaign.put(i, mapCampaignList.get(mapLeadCampaign.get(i)));
       }
       system.debug('wanti in LeadUtilities>> size: '+validateLeads.size());
       if(validateLeads.size()>0){
        CampaignValidator.validateLeadCloseDate(validateLeads, mapValidateCampaign);
       } 
        map<Id, AggregateResult> mapCampIdAggregates = new map<Id, AggregateResult>();
        for(AggregateResult aggregate : [select Campaign__c, COUNT(Id) Leads, COUNT_DISTINCT(Related_Contact__c) RelatedContacts, COUNT_DISTINCT(Contact__c) Contacts from Lead where Campaign__c in :setCampaignIds group by Campaign__c]) {
            mapCampIdAggregates.put((String)aggregate.get('Campaign__c'), aggregate);
        }
       
        list<Campaign> lstCampaigns = new list<Campaign>();
        for(Id campaignId : setCampaignIds) {
            AggregateResult aggregate = mapCampIdAggregates.get(campaignId);
            if(aggregate != null) {
                Double dTotalContacts = (Double)aggregate.get('RelatedContacts') + (Double)aggregate.get('Contacts');
                lstCampaigns.add(new Campaign(Id = campaignId, Total_Leads__c = (Double)aggregate.get('Leads'), Total_Contacts__c = dTotalContacts));
            }
            else {
                lstCampaigns.add(new Campaign(Id = campaignId, Total_Leads__c = 0, Total_Contacts__c = 0));
            }
        }
        
        if(!lstCampaigns.isEmpty()) {
            TriggerExecutionController.setSkipCampaignTriggers(true);
            Database.SaveResult[] lstSaveResults = Database.update(lstCampaigns, false);
            TriggerExecutionController.setSkipCampaignTriggers(false);
            // v2.1: Start
            for(integer i=0; i < lstSaveResults.size(); i++) {
                Database.SaveResult savResult = lstSaveResults[i];
                if(!savResult.isSuccess()) {
                    for(Database.Error dbError : savResult.getErrors()) {
                        for(Lead leadIterator : lstAllLeads2) {
                            if(leadIterator.Campaign__c == lstCampaigns[i].Id) {
                                leadIterator.addError(dbError.getMessage());
                            }
                        }
                        System.debug('Failure in Campaign Member creation. ' + dbError);
                    }
                }
            }
            // v2.1: End
        }
    }

}