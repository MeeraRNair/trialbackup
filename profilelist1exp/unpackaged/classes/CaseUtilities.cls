/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to Case object. 
 *          Please create separate classes and use it for complex logics.
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 10751    16.03       30-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */

public class CaseUtilities {  

    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.1                                                 Rakesh Muppiri  Added new if condition RecordType.Name != 'NPS Cases'
    1.2                                 08-Oct-2014     Rakesh Muppiri  Added this line of code - Defect #121322 for CMAP 15.10 Email is not triggering
    2.0         CR 10751    16.03       30-Dec-2014     Ragu            This logic is separated from AfterInsertUpdateCaseTrigger trigger and rewritten as part of trigger redesign.
    3.0         CR XXXX                 18-Nov-2018     Akshita         Changes as part of case RT lift-n-shift
    */
    public static void reassignNonNPSCases(map<Id, Case> mapCases) {
        list<Case> lstCases = new list<Case>();
        // v1.1 - Added RecordType.Name != 'NPS Cases' in the below SOQL query
        for(Case caseIterator : [select Id from Case where Id in :mapCases.keySet() and (RecordType.Name != 'NPS Cases' AND recordtype.name != 'order support' AND recordtype.name != 'Deal Registration' AND recordtype.name != 'Deal Registration - Internal only case types' AND recordtype.name != 'On Boarding' AND recordtype.name != 'On Boarding Internal' AND recordtype.name != 'Distribution' AND recordtype.name != 'Application Support' AND recordtype.name != 'Application Support - Internal only case types' AND recordtype.name != 'Partner Program')]) {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            dmo.EmailHeader.TriggerUserEmail = true; // v1.2
            caseIterator.setOptions(dmo);
            lstCases.add(caseIterator);
        }
        if(!lstCases.isEmpty()) {
            update lstCases;
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR 9847     15.10       21-Aug-2014     Rakesh Muppiri  CMAP Phase 2.2, Partner Inquiry Case Owner Assigment
    2.0         CR 10751    16.03       30-Dec-2014     Ragu            This logic is separated from AfterInsertUpdateCaseTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void assignPartnerInquiryCases(map<Id, Case> mapNewCases, map<Id, Account> mapRelatedAccounts) {
        Id partnerInquiryRTId = StaticFactory.getRecordTypeIdByName('Case', 'Partner Inquiries');
        
        set<Id> campaignIds = new set<Id>();
        for(Case newCase : mapNewCases.values()) {
            if(newCase.RecordTypeId == partnerInquiryRTId) {
                campaignIds.add(newCase.Campaign_Name__c);
            }
        }
        map<Id, Campaign> mapCampaigns = new map<Id, Campaign>([select Id, Partner_Inquiry_Case_Owner__c from Campaign where Id in :campaignIds]); 
        if(mapCampaigns != null && !mapCampaigns.isEmpty()) {
            map<Id, Id> mapCaseIdAccIdForAE = new map<Id, Id>();
            for(Case newCase : mapNewCases.values()) {
                if(newCase.Campaign_Name__c != null && newCase.RecordTypeId == partnerInquiryRTId) {
                    Campaign campaignInstance = mapCampaigns.get(newCase.Campaign_Name__c);
                    if(campaignInstance != null && newCase.AccountId != null) {
                        if(campaignInstance.Partner_Inquiry_Case_Owner__c == 'Account Owner') {
                            newCase.OwnerId = mapRelatedAccounts.get(newCase.AccountId).OwnerId;
                        }
                        else if(campaignInstance.Partner_Inquiry_Case_Owner__c == 'Account Executive') {
                            mapCaseIdAccIdForAE.put(newCase.Id, newCase.AccountId);                                                                                                           
                        }
                    }
                }
            }
    
            if(!mapCaseIdAccIdForAE.isEmpty()) {
                map<Id, Id> mapAccIdTeamUserId = new map<Id, Id>();
                for(AccountTeamMember accTeamMember : [select Id, AccountId, TeamMemberRole, UserId from AccountTeamMember where TeamMemberRole = 'Account Executive' and AccountId in :mapCaseIdAccIdForAE.values() order by AccountId, CreatedDate desc]) {
                    if(mapAccIdTeamUserId.get(accTeamMember.AccountId) == null) {
                        mapAccIdTeamUserId.put(accTeamMember.AccountId, accTeamMember.UserId);
                    }
                }
                
                for(String caseId : mapCaseIdAccIdForAE.keySet()) {
                    Case newCase = mapNewCases.get(caseId);
                    Id accTeamUserId = mapAccIdTeamUserId.get(newCase.AccountId);
                    if(accTeamUserId != null) {
                        newCase.OwnerId = accTeamUserId;
                    }
                }
            }
        }
    }

    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    3.0         CR XXXX                 18-Nov-2018     Akshita         Changes as part of case RT lift-n-shift
	4.0			18304		FY20-0102	27-Nov-2019		Fenny			To make CaseRecordSelector accessible by all features
    */
     /*-----3.0-----*/ /* -- 4.0: This method moved to CaseRecordSelector -- */
    /*public static List<Case> CaseRTMigrateCheckRTList(List<Case> lstNewCases, String CaseRTMigrate_strRTIds){
        
        //String CaseRTMigrate_strRTIds = CaseManagement.CaseRTMigrate_getRTIDs();
        
        List<Case> listCases = new List<Case>();
        
        for(Case newCase : lstNewCases) {
            if(!CaseRTMigrate_strRTIds.contains(newCase.RecordTypeId)) {
                listCases.add(newCase);
            }
        }
        return listCases;
    }*/

    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    3.0         CR XXXX                 18-Nov-2018     Akshita         Changes as part of case RT lift-n-shift
	4.0			18304		FY20-0102	27-Nov-2019		Fenny			To make CaseRecordSelector accessible by all features
    */
     /*-----3.0-----*/ /* -- 4.0: This method moved to CaseRecordSelector -- */
    /*public static Map<Id, sObject> CaseRTMigrateCheckRTMap(Map<Id, sObject> mapNewCases, String CaseRTMigrate_strRTIds){
        
        Map<Id, Case> tempMap = new Map<Id, Case>();
        
        if(mapNewCases != null)
            tempMap = (Map<Id, Case>) mapNewCases;
        
        Map<Id, Case> mapCases = new Map <Id, Case>();
        
        //String CaseRTMigrate_strRTIds = CaseManagement.CaseRTMigrate_getRTIDs();
        
        List<Case> listCases = new List<Case>();
        
            for(Id newCase : tempMap.keySet()) {
                if(!CaseRTMigrate_strRTIds.contains(tempMap.get(newCase).RecordTypeId)) {
                    mapCases.put(newCase, tempMap.get(newCase));
                }
            } 
        return mapCases;
        
    }*/
}