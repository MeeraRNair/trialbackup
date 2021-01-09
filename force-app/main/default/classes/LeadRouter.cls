/*
 * Author   : Ragu
 * Purpose  : To handle all Lead routing logics for Lead 2.0.
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12003    16.10       05-Oct-2015     Ragu            LM2_1_70-Route to Channel Process
 * 1.1      CR 12064    16.10       12-Oct-2015     Ragu            LM2_1_71-Route to Segment Process
 * 1.2      CR 12069    16.10       13-Oct-2015     Syidah          LM2_1_78-Add new value "Direct Lead 2.0" to existing field "R2C Source" in Channel Lead 2.0          
 * 1.3		TFS 204865	16.10       21-Oct-2015     Ragu            Assign Leads back to user who routed the Segment Lead to Channel if Account is not associated.
 * 1.4 		TFS 204902	16.10		26-Oct-2015		Ragu			LM2_1_71 - batch - cannot route to segment rejected channel lead
 * 
 */

public class LeadRouter {
    
    private static final Id CURRENT_USER_ID = UserInfo.getUserId();
    
    // v1.0 - Populate Lead fields when Direct Lead 2.0 is being routed to Channel.
    public static void routeToChannel(list<Lead> lstDirectLeads, map<Id, Lead> mapOldLeads) {
        if(mapOldLeads != null) {
            LeadRouterHelper.validateR2CForBatch(lstDirectLeads, mapOldLeads);
        }
        
        Id cleansingRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
        for(Lead leadIterator : lstDirectLeads) {
            leadIterator.RecordTypeId = cleansingRTId;
            leadIterator.Status = 'Qualified - Channel Ready';
            leadIterator.Related_Contact__c = leadIterator.Contact__c;
            leadIterator.Route_to_Channel_Date__c = System.now();
            leadIterator.Ready_For_Scoring__c = true;
            leadIterator.Channel_Lead_Capture_Date__c = (leadIterator.Lead_Capture_DateTime__c != null ? leadIterator.Lead_Capture_DateTime__c.dateGMT() : null);
            leadIterator.R2C_Source__c = 'Direct Lead 2.0'; // v1.2
            leadIterator.Lead_Routed_User__c = CURRENT_USER_ID; // v1.3
            
			// Copy Opt-In / Opt-Out fields
            leadIterator.Lead_Email_Opt_In__c = (leadIterator.Email_Opt_in__c == 'Yes' ? true : false);
            leadIterator.Lead_Fax_Opt_In__c = (leadIterator.Fax_Opt_in__c == 'Yes' ? true : false);
            leadIterator.Lead_Mail_Opt_In__c = (leadIterator.Mail_Opt_in__c == 'No' ? true : false);
            leadIterator.Lead_Phone_Opt_In__c = (leadIterator.Phone_Opt_in__c == 'No' ? true : false);
            
            resetDirectLeadFields(leadIterator);
        }
    }
    
    // v1.0 - Populate Lead fields when Direct Lead 2.0 is being routed to Channel from Salesforce UI. 
    // These fields will not be populated from UI since those are not included in the page layout.
    public static void populateFieldsForR2CFromUI(list<Lead> lstDirectLeads) {
        for(Lead leadIterator : lstDirectLeads) {
            leadIterator.Route_to_Channel_Date__c = System.now();
            leadIterator.Ready_For_Scoring__c = true;
            leadIterator.R2C_Source__c = 'Direct Lead 2.0'; // v1.2
            leadIterator.Lead_Routed_User__c = CURRENT_USER_ID; // v1.3
            
            resetDirectLeadFields(leadIterator);
        }
    }
    
    // v1.0 - Generic method to reset the Direct Lead 2.0 related fields when Direct Lead 2.0 is being routed to Channel.
    private static void resetDirectLeadFields(Lead leadIterator) {
        leadIterator.Inside_Sales_Rep_ICAM__c = null;
        leadIterator.ISM_Channel_ISM__c = null;
        leadIterator.Account_Executive_PDM__c = null;
        leadIterator.RSM__c = null;
        
        leadIterator.Lead_Owner_System_Auto_Populated__c = false;
        leadIterator.Geo_Populated__c = false;
        leadIterator.ISR_System_Auto_Populated__c = false;
        leadIterator.ISM_System_Auto_Populated__c = false;
        leadIterator.AE_System_Auto_Populated__c = false;
        leadIterator.RSM_System_Auto_Populated__c = false;
    }
    
    // v1.1 - Populate Lead fields when Channel Lead is being routed back to Direct Lead 2.0.
    public static void routeToSegment(list<Lead> lstChannelLeads, map<Id, Lead> mapOldLeads) {
        if(mapOldLeads != null) {
            LeadRouterHelper.validateR2SForBatch(lstChannelLeads, mapOldLeads);
        }
        
        Id directLeadRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        for(Lead leadIterator : lstChannelLeads) {
            leadIterator.RecordTypeId = directLeadRTId;
            leadIterator.Status = 'Open';
            leadIterator.Contact__c = leadIterator.Related_Contact__c;
            leadIterator.Trigger_Lead_Assignment__c = true;
            leadIterator.Ready_For_Scoring__c = false;
            leadIterator.R2C_Source__c = null;
            
            // v1.3: Start
            // v1.4 - Added below leadIterator.Lead_Routed_User__c != null condition
            if(leadIterator.Lead_Routed_User__c != null) {
            	leadIterator.OwnerId = leadIterator.Lead_Routed_User__c;
            }
            leadIterator.Lead_Routed_User__c = CURRENT_USER_ID;
            // v1.3: End
            
			// Copy Opt-In / Opt-Out fields
	        leadIterator.Email_Opt_in__c = (leadIterator.Lead_Email_Opt_In__c ? 'Yes' : null);
	        leadIterator.Fax_Opt_in__c = (leadIterator.Lead_Fax_Opt_In__c ? 'Yes' : null);
	        leadIterator.Mail_Opt_in__c = (leadIterator.Lead_Mail_Opt_In__c ? 'No' : null);
	        leadIterator.Phone_Opt_in__c = (leadIterator.Lead_Phone_Opt_In__c ? 'No' : null);
        }
    }
    
    // v1.1 - Calls routeToSegment() to route Channel Leads to Direct Lead 2.0 and updates leadRecSelector.lstDirectLeads2 for further processing (Lead Assignment).
    public static void routeToSegmentForBatch(LeadRecordSelector leadRecSelector, map<Id, Lead> mapOldLeads) {
        LeadRouter.routeToSegment(leadRecSelector.lstBatchRoutedCLs, mapOldLeads);
        leadRecSelector.lstDirectLeads2.addAll(leadRecSelector.lstBatchRoutedCLs);
    }
    
    // v1.1 - Populate Lead fields when Channel Lead is being routed back to Direct Lead 2.0 from Salesforce UI. 
    // These fields will not be populated from UI since those are not included in the page layout.
    public static void populateFieldsForR2SFromUI(list<Lead> lstDirectLeads) {
        for(Lead leadIterator : lstDirectLeads) {
            leadIterator.Ready_For_Scoring__c = false;
            leadIterator.R2C_Source__c = null;
            
            // v1.3: Start
            // v1.4 - Added below leadIterator.Lead_Routed_User__c != null condition
            if(leadIterator.Lead_Routed_User__c != null) {
            	leadIterator.OwnerId = leadIterator.Lead_Routed_User__c;
            }
            leadIterator.Lead_Routed_User__c = CURRENT_USER_ID;
            // v1.3: End
        }
    }
    
}