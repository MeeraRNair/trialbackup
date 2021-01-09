/*
 * Author   : Ragu
 * Purpose  : Utility class to hold methods which are related to Status updation on the CampaignMember.
 *        
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR: 11555   16.07           28-May-2015     Ragu            To recalculate the CM Status on the Campaign Member based Campaign_Member_Status__c custom setting.
 * 1.1      TFS: 176168 16.07           23-Jun-2015     Ragu            During Lead Conversion, after update trigger on Lead is not updating the Campaign Member's CM Status - Technical Limitation.
 * 1.2      TFS: 199225 16.10           25-Sep-2015     Ragu            CM status not updated for converted Unqualified or Rejected lead.
 * 1.3      TFS: 205021 16.10           23-Oct-2015     Azwanti         defect #205021: added fix for CM Status History function
 * 2.0      CR 13170    FY17-DCS-0701   25-May-2016     Gan             To update the Campaign Member with lead releavant fields
 * 3.0      CR 15314    FY18-DCS-0203   06-Dec-2017     Ashok           Marketing LTO - Update campaign cancellation workflow with new status
*/

public class CampaignMember2StatusUtils {
    
    private static final String DIRECT_IDENTIFIER = 'Direct';
    private static final String CHANNEL_IDENTIFIER = 'Channel';
    private static final String DELIMITER = '_';
    
    // v1.0 - Helper method for calculating CM Status on the Campaign Member. Calls populateCampaignMember2Status() to populate CM Status.
    public static void recalculateCampaignMember2Status(map<Id, Lead> mapLeads2ForCMStatusUpdate) {
        list<CampaignMember> lstCampaignMembers = [select Id, LeadId, CampaignId, Status, CM_Status__c from CampaignMember where LeadId in :mapLeads2ForCMStatusUpdate.keySet()];
        
        if(!lstCampaignMembers.isEmpty()) {
            //defect #205021 fix : create old CM Map
            List<CampaignMember> lstCM = lstCampaignMembers.deepClone(true, true, true);
            Map<Id, CampaignMember> CMIdToOldCMStatusMap = new map<Id, CampaignMember>();
            for(CampaignMember cm: lstCM){
                CMIdToOldCMStatusMap.put(cm.Id, cm);    
            }
            populateCampaignMember2Status(lstCampaignMembers, mapLeads2ForCMStatusUpdate);
            //-end
            
            TriggerExecutionController.setSkipCampaignMemberTriggers(true);
            Database.SaveResult[] lstSaveResults = Database.update(lstCampaignMembers, false); 
            
            //defect #205021 fix : create new CM Map
            Map<Id, CampaignMember> CMIdToCMStatusMap = new map<Id, CampaignMember>();
            for(CampaignMember cm: lstCampaignMembers){
                CMIdToCMStatusMap.put(cm.Id, cm);    
            }
            CampaignMemberUtils.generateCMFieldHistory(CMIdToCMStatusMap, CMIdToOldCMStatusMap); // fix
            //-end
            
            TriggerExecutionController.setSkipCampaignMemberTriggers(false);
            
            //fix defect : track CM Status changes
            List<Id> updatedCMStatusIdList = new List<Id>();
            
            for(integer i=0; i < lstSaveResults.size(); i++) {
                Database.SaveResult savResult = lstSaveResults[i];
                if(!savResult.isSuccess()) {
                    for(Database.Error dbError : savResult.getErrors()) {
                        Lead leadIterator = mapLeads2ForCMStatusUpdate.get(lstCampaignMembers[i].LeadId);
                        leadIterator.addError(dbError.getMessage());
                        System.debug('Failure in Campaign Member CM Status update. ' + dbError);
                    }
                }
            }
            
        }
    }
    
    // v1.0 - Calculate CM Status for Campaign Member based on the configuration from Campaign_Member_Status__c custom setting
    public static void populateCampaignMember2Status(list<CampaignMember> lstCampaignMembers2, map<Id, Lead> mapRelatedLeads) {
        
        Id directLead2RTId = StaticFactory.getRecordTypeIdByNameDESC('Lead', 'Direct Lead 2.0');
        set<Id> setChannelLeadRTIds = StaticFactory.getRecordTypeIdsByNames('Lead', new set<String>{'Channel Lead 2.0', 'Channel Lead - Submission', 'Channel Lead - Cleansing & Scoring Complete', 'Channel Lead - Assignment Complete', 'Channel Lead - Conversion'});
        map<String, map<String, String>> mapCMStatusSettings = getCMStatusSettings();
        map<String, String> mapDirectCMStatusSettings = mapCMStatusSettings.get(DIRECT_IDENTIFIER);
        map<String, String> mapChannelCMStatusSettings = mapCMStatusSettings.get(CHANNEL_IDENTIFIER);
        for(CampaignMember campMember : lstCampaignMembers2) {
            Lead relatedLead = mapRelatedLeads.get(campMember.LeadId);
            if(relatedLead != null) {
                String strKey = (relatedLead.Status != null ? relatedLead.Status : '') + DELIMITER + (relatedLead.Reason__c != null ? relatedLead.Reason__c : '');
                if(relatedLead.RecordTypeId == directLead2RTId) {
                    campMember.CM_Status__c = mapDirectCMStatusSettings.get(strKey);
                }
                else if(setChannelLeadRTIds.contains(relatedLead.RecordTypeId)) {
                    campMember.CM_Status__c = mapChannelCMStatusSettings.get(strKey);
                }
            }
        }
    }
    
    // v1.1 - During Lead Conversion, after update trigger on Lead is not updating the Campaign Member's CM Status.
    // Technical Limitation => Both old and new Status of the Lead is same. New Lead Status is not reflecting the Status which is selected in the Lead Conversion screen.
    //2.0 added new input parameter
    public static void populateCampaignMember2Status(Lead leadRecord, boolean bRequiredLeadFieldsUpd) {
        if(leadRecord != null && leadRecord.Id != null) {
            //2.0 Added new fields
            map<Id, Lead> mapLeads = new map<Id, Lead>([
                                        select Id, Status, Reason__c, RecordTypeId, sales_comments__c, marketing_comments__c,
                                        questions_comments__c
                                        from Lead where Id = :leadRecord.Id]);
            
            list<CampaignMember> lstCampaignMembers = [select Id, LeadId, CampaignId, Status, CM_Status__c from CampaignMember where LeadId = :leadRecord.Id];
            if(lstCampaignMembers != null && !lstCampaignMembers.isEmpty()) {
                
                //defect #205021 fix : create old CM Map
                List<CampaignMember> lstCM = lstCampaignMembers.deepClone(true, true, true);
                Map<Id, CampaignMember> CMIdToOldCMStatusMap = new map<Id, CampaignMember>();
                for(CampaignMember cm: lstCM){
                    CMIdToOldCMStatusMap.put(cm.Id, cm);    
                }
                //-end              
                
                // v1.2 - Start
                for(Lead leadIterator : mapLeads.values()) {
                    leadIterator.Reason__c = null;
                }
                // v1.2 - End
                populateCampaignMember2Status(lstCampaignMembers, mapLeads);
                
                //2.0
                if(bRequiredLeadFieldsUpd) {
                    CampaignMember2CreationUtils.populateCampaignMemberLeadFields(lstCampaignMembers, mapLeads);    
                }
                
                TriggerExecutionController.setSkipCampaignMemberTriggers(true);
                Database.SaveResult[] lstSaveResults = Database.update(lstCampaignMembers, false); 
                //defect #205021 : create new CM Map
                Map<Id, CampaignMember> CMIdToCMStatusMap = new map<Id, CampaignMember>();
                for(CampaignMember cm: lstCampaignMembers){
                    CMIdToCMStatusMap.put(cm.Id, cm);    
                }
                CampaignMemberUtils.generateCMFieldHistory(CMIdToCMStatusMap, CMIdToOldCMStatusMap); 
                //-endfix CM Status
                
                TriggerExecutionController.setSkipCampaignMemberTriggers(false);
                
                for(integer i=0; i < lstSaveResults.size(); i++) {
                    Database.SaveResult savResult = lstSaveResults[i];
                    if(!savResult.isSuccess()) {
                        leadRecord.addError(savResult.getErrors()[0].getMessage());
                        System.debug('Failure in Campaign Member CM Status update. ' + savResult.getErrors());
                    }
                }
                //azwanti-fix CM Status History
                
            }
        }
    }
    
    // v1.0 - Returns Key-Value pair of the Campaign_Member_Status__c custom setting. Key = Lead Status + Reason; Value = CM Status.
    public static map<String, map<String, String>> getCMStatusSettings() {
        map<String, map<String, String>> mapCMStatusSettings = new map<String, map<String, String>>();
        map<String, String> mapDirectCMStatusSettings = new map<String, String>();
        map<String, String> mapChannelCMStatusSettings = new map<String, String>();
        for(Campaign_Member_Status__c cmStatus : Campaign_Member_Status__c.getAll().values()) {
            String strKey = (cmStatus.Status__c != null ? cmStatus.Status__c : '') + DELIMITER + (cmStatus.Reason__c != null ? cmStatus.Reason__c : '');
            if(cmStatus.Identifier__c.contains(DIRECT_IDENTIFIER)) {
                mapDirectCMStatusSettings.put(strKey, cmStatus.CM_Status__c); //3.0
            }
            if(cmStatus.Identifier__c.contains(CHANNEL_IDENTIFIER)) {
                mapChannelCMStatusSettings.put(strKey, cmStatus.CM_Status__c); //3.0
            }
        }
        mapCMStatusSettings.put(DIRECT_IDENTIFIER, mapDirectCMStatusSettings);
        mapCMStatusSettings.put(CHANNEL_IDENTIFIER, mapChannelCMStatusSettings);
        return mapCMStatusSettings;
    }

}