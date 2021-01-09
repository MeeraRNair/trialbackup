/*
 * Author   : Ragu
 * Purpose  : To help all Lead routing logics for Lead 2.0.
 *        
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      12003       16.10           05-Oct-2015     Ragu            LM2_1_70-Route to Channel Process
 * 1.1      12064       16.10           12-Oct-2015     Ragu            LM2_1_71-Route to Segment Process
 * 2.0      15341       FY19-DCS-0203   22-Dec-2017     Azwanti         Marketing LTO - Update precondition for Route to channel Lead 2.0
 */
 
public class LeadRouterHelper {
    
    public static final String NO_PERMISSION = 'You do not have permission to route this Lead to Channel. Please contact Lead Owner to route it to Channel';
    public static final String DELL_PARTNER_MANDATORY = '\'Dell Partner can contact me?\' checkbox must be checked in order to route Direct lead 2.0 to Channel Lead';
    public static final String INVALID_DL2_STATUS = 'Lead should be in New, Working or Pre-Qualified Status in order to route it to Channel. Please update the Status accordingly and try again';  //v2.0
    public static final String INVALID_CAMPAIGN = 'Campaign does not support Channel process. Please contact campaign owner to update Allocation Source and Nurture Source in the campaign before routing lead to channel';
    // v1.1 Start
    public static final String INVALID_ORIGIN = 'Channel Leads which were routed from Segment can only be routed back to Segment';
    public static final String INVALID_C2S_CRITERIA = '\'Channel to Segment Criteria\' is mandatory in order to route Channel Lead to Segment';
    public static final String INVALID_CHANNEL_RT = 'Channel Leads should be in either Channel Lead - Cleansing & Scoring Complete or Channel Lead - Assignment Complete stage in order to route it to Segment';
    public static final String R2S_BUTTON_AVAILABILITY = 'This button is intended for Regional Allocation Queue Members. Please contact your Channel Marketing manager for assistance. Thank you';
    // v1.1 End
    
    // Code Block Start: SOQL Helper Methods
    private static final String SOQLFIELDDELIMITER = ', ';
    public static String getSelectList(set<String> setFields) {
        String strSelect = '';
        for(String strField : setFields) {
            strSelect += strField + SOQLFIELDDELIMITER;
        }
        return (strSelect.removeEnd(SOQLFIELDDELIMITER));
    }
    // Code Block Start: SOQL Helper Methods
    
    
    // Code Block Start: Campaign Related Utility Methods
    public static Boolean campaignSupportsChannelLead(Id campaignId) {
        Campaign campaignRecord = [select Id, Name, Region__c, Sub_Region__c, Allocation_Source__c, Nurture_Source__c from Campaign where Id = :campaignId limit 1];
        return campaignSupportsChannelLead(campaignRecord);
    }
    
    public static map<Id, Boolean> campaignSupportsChannelLead(set<Id> setCampaignIds) {
        map<Id, Boolean> mapCampaignIdResults = new map<Id, Boolean>();
        for(Campaign campIterator : [select Id, Name, Region__c, Sub_Region__c, Allocation_Source__c, Nurture_Source__c from Campaign where Id in :setCampaignIds]) {
            mapCampaignIdResults.put(campIterator.Id, campaignSupportsChannelLead(campIterator));
        }
        return mapCampaignIdResults;
    }

    private static final String UNSUPPORTEDVALUE = 'Not Applicable';
    public static Boolean campaignSupportsChannelLead(Campaign campaignRecord) {
        Boolean bSupportChannelLead = false;
        if(campaignRecord.Allocation_Source__c != null && campaignRecord.Allocation_Source__c != UNSUPPORTEDVALUE 
            && campaignRecord.Nurture_Source__c != null && campaignRecord.Nurture_Source__c != UNSUPPORTEDVALUE) {
            bSupportChannelLead = true;
        }
        return bSupportChannelLead;
    }

    public static set<Id> getCampaignIds(list<Lead> lstLeads) {
        set<Id> setCampaignIds = new set<Id>();
        for(Lead leadIterator : lstLeads) {
            if(leadIterator.Campaign__c != null) {
                setCampaignIds.add(leadIterator.Campaign__c);
            }
        }
        return setCampaignIds;
    }

    public static map<Id, Campaign> getRelatedCampaigns(list<Lead> lstLeads) {
        set<Id> setCampaignIds = new set<Id>();
        for(Lead leadIterator : lstLeads) {
            setCampaignIds.add(leadIterator.Campaign__c);
        }
        setCampaignIds.remove(null);
        return getRelatedCampaigns(setCampaignIds);
    }
    
    public static map<Id, Campaign> getRelatedCampaigns(set<Id> setCampaignIds) {
        map<Id, Campaign> mapCampaigns = new map<Id, Campaign>([select Id, Name, Region__c, Sub_Region__c, Allocation_Source__c, Nurture_Source__c from Campaign where Id in :setCampaignIds]);
        return mapCampaigns;
    }
    // Code Block End: Campaign Related Utility Methods
    
    
    // Code Block Start: General Validation Related Methods for R2C
    // v1.0 - Validate whether Direct Leads which are routed to Channel via batch upload are valid.
    public static void validateR2CForBatch(list<Lead> lstDirectLeads, map<Id, Lead> mapOldLeads) {
        map<Id, Boolean> mapCampaignIdValidity = campaignSupportsChannelLead(getCampaignIds(lstDirectLeads));
        for(Lead leadIterator : lstDirectLeads) {
            if(leadIterator.Dell_Partner_can_contact_me__c == false) {
                leadIterator.addError(DELL_PARTNER_MANDATORY);
            }
            else if(mapOldLeads != null && mapOldLeads.containsKey(leadIterator.Id) && leadStatusValidForR2C(mapOldLeads.get(leadIterator.Id)) == false) {
                leadIterator.addError(INVALID_DL2_STATUS);
            }
            else if(mapCampaignIdValidity.get(leadIterator.Campaign__c) == false) {
                leadIterator.addError(INVALID_CAMPAIGN);
            }
        }
    }
    
    public static Boolean checkUserAccess(Lead leadInstance, Id userId) {
        Boolean bHasAccess = false;
        User userToCheck = StaticFactory.getUserDetails(userId);
        
        list<UserRecordAccess> lstUserAccess = [select RecordId, HasEditAccess from UserRecordAccess where UserId = :userId and RecordId = :leadInstance.Id];
        if(lstUserAccess != null && !lstUserAccess.isEmpty()) {
            if(lstUserAccess[0].HasEditAccess) {
                    bHasAccess = true;   
               }
            }
        return bHasAccess;
    }
    
    public static Boolean userHasAccess(Lead leadInstance, Id userId) {
        Boolean bHasAccess = false;
        User userToCheck = StaticFactory.getUserDetails(userId);
        
        list<UserRecordAccess> lstUserAccess = [select RecordId, HasEditAccess from UserRecordAccess where UserId = :userId and RecordId = :leadInstance.Id];
        if(lstUserAccess != null && !lstUserAccess.isEmpty()) {
            if(lstUserAccess[0].HasEditAccess) {
                if(userToCheck.Id == leadInstance.CreatedById || userToCheck.Id == leadInstance.OwnerId || profileAllowedForR2C(userToCheck.Profile.Name)) {
                    bHasAccess = true;
                }
            }
        }
        return bHasAccess;
    }

    public static Boolean leadStatusValidForR2C(Lead directLead2) {
        Boolean bValid = false;
        set<String> setStatuses = new set<String>{'New', 'Working', 'Pre-Qualified'}; //v2.0
        if(setStatuses.contains(directLead2.Status)) {
            bValid = true;
        }
        return bValid;
    }
    
    public static Boolean profileAllowedForR2C(String strProfileToCheck) {
        Boolean bAllowed = false;
        set<String> setProfiles = new set<String>{'GBL Marketing', 'Marketing User', 'Channel Marketing', 'Lead Assignment'};
        for(String strProfile : setProfiles) {
            if(strProfileToCheck.contains(strProfile)) {
                bAllowed = true;
                break;
            }
        }
        return bAllowed;
    }
    // Code Block End: General Validation Related Methods for R2C
    
    // Code Block Start: General Validation Related Methods for R2S
    // v1.1 - Validate whether Channel Leads which are routed to Segment via batch upload are valid.
    public static void validateR2SForBatch(list<Lead> lstChannelLeads, map<Id, Lead> mapOldLeads) {
        set<String> setValidOrigins = new set<String>{'Direct Lead 2.0'};
        set<Id> setValidRTIds = StaticFactory.getRecordTypeIdsByNames('Lead', new set<String>{'Channel Lead - Cleansing & Scoring Complete', 'Channel Lead - Assignment Complete'});
        for(Lead leadIterator : lstChannelLeads) {
            Lead oldLead = mapOldLeads.get(leadIterator.Id);
            
            if(!setValidRTIds.contains(oldLead.RecordTypeId)) {
                leadIterator.addError(INVALID_CHANNEL_RT);
            }
            else if(!setValidOrigins.contains(leadIterator.Origin__c)) {
                leadIterator.addError(INVALID_ORIGIN);
            }
            else if(String.isEmpty(leadIterator.Channel_to_Segment_Criteria__c)) {
                leadIterator.addError(INVALID_C2S_CRITERIA);
            }
        }
    }
    
    public static Boolean validateCurrenUser(Lead channelLead) {
        Boolean bValid = false;
        Id allocationQueueId;
        String strOwner = channelLead.OwnerId;
        if(strOwner.startsWith('00G') && (channelLead.Owner.Name.Contains('Allocation') || (channelLead.Owner.Name.Contains('Nurturing') && channelLead.Campaign__r.Region__c == 'NA'))) {
            allocationQueueId = channelLead.OwnerId;
        }
        else if(channelLead.Status == 'Assigned to Channel Partner') {
            allocationQueueId = channelLead.Allocation_Queue_GUID__c;
        }
        if(allocationQueueId != null) {
            list<GroupMember> lstGroupMembers = [select Id, UserOrGroupId from GroupMember where GroupId = :allocationQueueId and UserOrGroupId = :UserInfo.getUserId()];
            if(!lstGroupMembers.isEmpty()) {
                bValid = true;
            }
        }
        return bValid;
    }
    // Code Block End: General Validation Related Methods for R2S
    
}