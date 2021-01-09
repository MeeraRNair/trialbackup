/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to SnP for an Opportunity.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0		CR6925      R13.4       18-May-2012     Raghavendra     Workflow SnP Deal Reg SnP Deal Renewal Instructions to not be triggered when Oppty is closed Changes
 * 2.0      CR8948                  08-Aug-2012     Patrick Redor   Update the last modified date and last modified by field in the related SV Record
 *
 */
 
public class SnPUtilities {

    // v1.0
    public static void updateSnPNotificationField(set<Id> setOpportunityIds) {
        if(setOpportunityIds != null && !setOpportunityIds.isEmpty()) {
            list<S_P_Vendors__c> lstSnPVendors = new list<S_P_Vendors__c>();
            for(S_P_Vendors__c snpVendor : [select Id, Send_Notification__c from S_P_Vendors__c where Opportunity__c in :setOpportunityIds]) {
                snpVendor.Send_Notification__c = false;
                lstSnPVendors.add(snpVendor);
            }
            update lstSnPVendors;
        }
    }
	    
    // v2.0
    public static void updateRelatedSnPVendors(set<Id> setOpportunityIds) {
        if(setOpportunityIds != null && !setOpportunityIds.isEmpty()) {
            list<S_P_Vendors__c> lstSnPVendors = [select Id, Name from S_P_Vendors__c where Opportunity__c in :setOpportunityIds];
            if(lstSnPVendors != null) {
                Database.update(lstSnPVendors);
            }
        }
    }

}