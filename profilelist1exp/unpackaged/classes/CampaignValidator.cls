/*
 * Author   : Niveda
 * Purpose  : Utility class to hold simple and reusable functionalities for validating Leads.
 *        
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 12500    16.12           22-Dec-2015     Niveda          Leads or contacts cannot be associated to a campaign with a “Close Date for Direct Leads” set in the past.
 * 2.0      CR 13288    FY17-DCS-0801   29-July-2016    Azwanti         added boolean bSkipCampaignValidator where BatchUpdateLeadStatusUponEndDate will set this to TRUE to bypass the validation on Close Date.
 * 3.0      CR 13780    FY17-DCS-0103   13-Oct-2016     SuiYee          campaign validation rules impacting Mascot integration
 * 4.0      CR 14960    FY18-DCS-1101   29-Sept-2017    Sazleen         campaign validation rules impacting Boomi FBE Integration
 */

public class CampaignValidator {
    public static boolean bSkipCampaignValidator=false;
    
    public static void validateLeadCloseDate(list < Campaign > lstCampaigns) {
        //v2.0 - skip this validation for BatchUpdateLeadStatusUponEndDate batch job
        system.debug('wanti Campaign bSkipCampaignValidator: '+bSkipCampaignValidator);
        //v3.0 Aprimo is mascot
        //v4.0 Add Boomi profile for Federal FBE Integration
        String strCurrentUserProfileName = StaticFactory.getCurrentUserDetails().Profile.Name;
        set<String> setAdminProfiles = new set<String>{'Aprimo Integration API','Boomi Integration API Only'};
        if(!setAdminProfiles.contains(strCurrentUserProfileName) && !bSkipCampaignValidator){
            for (Campaign newCampaign: lstCampaigns) {
                if (newCampaign.Close_Date_for_Leads__c != null && newCampaign.Close_Date_for_Leads__c < System.Today()) {
                    newCampaign.addError('Leads or contacts cannot be associated to a campaign with a “Close Date for Direct Leads” set in the past.');
                    return ;
                } 
            }
        }
    }

    public static void validateLeadCloseDate(list<lead> leadList, map<id,Campaign > mapCampaigns) {
        //v2.0 - skip this validation for BatchUpdateLeadStatusUponEndDate batch job
        system.debug('wanti Lead bSkipCampaignValidator: '+bSkipCampaignValidator);
        //v3.0 Aprimo is mascot
        //v4.0 Add Boomi profile for Federal FBE Integration 
        String strCurrentUserProfileName = StaticFactory.getCurrentUserDetails().Profile.Name;
        set<String> setAdminProfiles = new set<String>{'Aprimo Integration API','Boomi Integration API Only'};
        if(!setAdminProfiles.contains(strCurrentUserProfileName) && !bSkipCampaignValidator){
            for(Lead leadRec: leadList){
                if (mapCampaigns.get(leadRec.id).Close_Date_for_Leads__c != null && mapCampaigns.get(leadRec.id).Close_Date_for_Leads__c < System.Today()) {
                    leadRec.addError('Leads or contacts cannot be associated to a campaign with a “Close Date for Direct Leads” set in the past.');
                }
            }
        }
     }

}