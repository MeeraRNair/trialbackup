/*
 * Author   : Ragu
 * Purpose  : Utility class to hold methods to automatically create and populate values for CampaignMember.
 *        
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11555       16.07           28-May-2015     Ragu            To automatically create and populate values for CampaignMember.
 * 2.0      11978       16.10           27-Oct-2015     Shangeetha      Defect 205223,Add 'CampaignMember2StatusUtils.populateCampaignMember2Status' to skip the logic for “Add to Campaign” scenario.
 * 3.0      12500       16.12           30-Dec-2015     Niveda          Skip validation on Lead Close date for channel leads
 * 3.1      TFS 222349  16.12           23-Jan-2016     Niveda          Updated code to process Campaign Members for Channel Lead 2.0 as well.
 * 4.0      CR 13170    FY17-DCS-0701   25-May-2016     Gan             To update the Campaign Member with lead releavant fields
 * 4.1      CR 13180    FY17-DCS-0701   01-Jun-2016     Gan             Populate the lead id back to the custom lead field to used by report
 * 5.0      CR 14847    FY18-DCS-1001   28-AUG-2017     Ashok           Campaign Member Creation Code Fix  
 * 6.0      CR 15114    FY18-DCS-1102   13-Nov-2017     Ashok           User is not able to create direct lead with related contact that is also linked with another lead under same campaign  
 
*/
 
public class CampaignMember2CreationUtils {
    
    // v1.0 - Return fields which are necessary from Campaign object for auto populating CampaignMember fields
    public static set<String> getCampaignFields(map<String, Campaign_Member_Field_Mapping__c> mapCMFieldMappings) {
        set<String> setCampaignFields = new set<String>();
        for(String strCMField : mapCMFieldMappings.keySet()) {
            String strSourceField = mapCMFieldMappings.get(strCMField).Source_Field__c;
            
            if(strSourceField.startsWith('Campaign.')) { 
                setCampaignFields.add(strSourceField.replace('Campaign.', ''));
            }
        }
        return setCampaignFields;
    }
    
    // v1.0 - Return fields which are necessary from Lead object for auto populating CampaignMember fields
    public static set<String> getLeadFields(map<String, Campaign_Member_Field_Mapping__c> mapCMFieldMappings) {
        set<String> setLeadFields = new set<String>();
        for(String strCMField : mapCMFieldMappings.keySet()) {
            String strSourceField = mapCMFieldMappings.get(strCMField).Source_Field__c;
            
            if(strSourceField.startsWith('Lead.')) { 
                setLeadFields.add(strSourceField.replace('Lead.', ''));
            }
        }
        return setLeadFields;
    }
    
    // v1.0 - Creates CampaignMembers for the Leads 2.0
    public static void createCampaignMembers(map<Id, Lead> mapLeads2) {
        list<CampaignMember> lstDLCampaignMembers = new list<CampaignMember>();
        list<CampaignMember> lstCLCampaignMembers = new list<CampaignMember>();
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        try {
            for(Lead leadIterator : mapLeads2.values()) {
                CampaignMember campMember = new CampaignMember();
                campMember.LeadId = leadIterator.Id;
                campMember.CampaignId = leadIterator.Campaign__c;
                // v3.0 - Start
                if(leadIterator.RecordTypeId == directLead2RTId) {
                    lstDLCampaignMembers.add(campMember);
                }
                else {
                    lstCLCampaignMembers.add(campMember);
                }
                // v3.0 - End
            }
            
            // v3.0 - Start
            if(!lstDLCampaignMembers.isEmpty()) {
                // v2.0: Start
                CampaignMember2StatusUtils.populateCampaignMember2Status(lstDLCampaignMembers, mapLeads2);
                // v2.0: End
                
                Database.SaveResult[] lstSaveResults = Database.insert(lstDLCampaignMembers, false);
                if(!lstSaveResults.isEmpty()) {
                    handleExceptions(lstSaveResults, lstDLCampaignMembers, mapLeads2); //5.0
                }
            }
            
            if(!lstCLCampaignMembers.isEmpty()) {
                CampaignMember2StatusUtils.populateCampaignMember2Status(lstCLCampaignMembers, mapLeads2);
                
                TriggerExecutionController.setSkipCampaignValidator(true);
                Database.SaveResult[] lstSaveResults = Database.insert(lstCLCampaignMembers, false);   
                TriggerExecutionController.setSkipCampaignValidator(false);
                
                if(!lstSaveResults.isEmpty()) {
                    handleExceptions(lstSaveResults, lstCLCampaignMembers, mapLeads2);
                }
            }
            // v3.0 - End
        }
        catch(Exception ex) {
            System.debug('Exception occured while creating Campaign Members. Exception : ' + ex);
            EmailUtils.sendSupportEmail('Exception in CampaignMember2CreationUtils.createCampaignMembers() : ' + ex.getMessage(), DellConfig.errorEmail);
            //throw ex;
        }
    }
    
    private static void handleExceptions(Database.SaveResult[] lstSaveResults, list<CampaignMember> lstCampaignMembers, map<Id, Lead> mapLeads) {
        for(integer i=0; i < lstSaveResults.size(); i++) {
            Database.SaveResult savResult = lstSaveResults[i];
            if(!savResult.isSuccess()) {
                for(Database.Error dbError : savResult.getErrors()) {
                    Lead leadIterator = mapLeads.get(lstCampaignMembers[i].LeadId);
                    //v6.0
                    string errMsg = dbError.getMessage().toUpperCase();
                    string[] SErrList = System.Label.Skip_CM_Standard_Errors.split(';');
                    boolean sErrChek = false;
                    for(string sErr: SErrList){
                       if(errMsg.contains(sErr))
                       sErrChek = TRUE;
                    }
                     if(!sErrChek) 
                     leadIterator.addError(dbError.getMessage());
                    //v6.0 End 
                     
                    System.debug('Failure in Campaign Member creation. ' + dbError);
                }
            }
            
        }     
    }
    
    // v1.0 - Populates CampaignMember fields by copying values from related Lead / Campaign.
    public static void populateCampaignMemberFields(list<CampaignMember> lstCampaignMembers2, map<Id, Campaign> mapRelatedCampaigns, map<Id, Lead> mapRelatedLeads) {
        map<String, Campaign_Member_Field_Mapping__c> mapCMFieldMappings = Campaign_Member_Field_Mapping__c.getAll();
        for(CampaignMember campMember : lstCampaignMembers2) {
            Lead relatedLead = mapRelatedLeads.get(campMember.LeadId);
            Campaign relatedCampaign = mapRelatedCampaigns.get(campMember.CampaignId);
            
            // Copy all field values from Lead / Campaign to the Campaign Member based on the configuration from Campaign_Member_Field_Mapping__c custom setting.
            for(String strCMField : mapCMFieldMappings.keySet()) {
                String strSourceField = mapCMFieldMappings.get(strCMField).Source_Field__c;
                
                if(relatedLead != null && strSourceField.startsWith('Lead.')) { 
                    // Copy value from related Lead object
                    campMember.put(strCMField, relatedLead.get(strSourceField.replace('Lead.', '')));
                }
                else if(relatedCampaign != null && strSourceField.startsWith('Campaign.')) { 
                    // Copy value from related Campaign object
                    campMember.put(strCMField, relatedCampaign.get(strSourceField.replace('Campaign.', '')));
                }
                else if(strSourceField.startsWith('"')) { 
                    // This is string literals
                    campMember.put(strCMField, strSourceField);
                }
            }
        }
    }

    // v4.0 - Populates CampaignMember leads fields by copying values from related Lead
    public static void populateCampaignMemberLeadFields(list<CampaignMember> lstCampaignMembers2, map<Id, Lead> mapRelatedLeads) {
        for(CampaignMember campMember : lstCampaignMembers2) {
            Lead relatedLead = mapRelatedLeads.get(campMember.LeadId);
            campMember.Questions_Comments__c = relatedLead.Questions_Comments__c;
            campMember.Marketing_Comments__c = relatedLead.Marketing_Comments__c;
            campMember.Sales_Comments__c = relatedLead.Sales_Comments__c;
            //campMember.Form_URL__c = relatedLead.Form_URL__c;
            //campMember.Form_Referrer__c = relatedLead.Form_Referrer__c;
            //campMember.Lead_Capture_DateTime__c = relatedLead.Lead_Capture_DateTime__c;
            //campMember.Overall_Lead_Score__c = relatedLead.Overall_Lead_Score__c;
            //v4.1
            campMember.Custom_Lead__c = relatedLead.Id;
        }
    }
}