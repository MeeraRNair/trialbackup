/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities for auto populating Campaign fields. 
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0		2371		10.10		25-Sep-2010		Krishna			Functionality to Update the Send_Notification__c to TRUE if the Account_Play_Expiry_Date__c is changed. Test class:MarketingOpptyAssnUtilsTest
 * 2.0		7700					29-Nov-2012		Jagadeesan		Added functionality to populate campaign owner field with campaign owner id.
 * 3.0		8491		14.10		22-Aug-2013		Mukul			Update Mascot_Update_Flag__c field to capture the date/time automatically.
 * 4.0      11480     	16.07       18-May-2015     Ragu            This logic is separated from campaignBeforeInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
 * 5.0		11555		16.07       29-May-2015     Ragu			Populate CampaignMemberRecordTypeId for Campaign 2.0.
 * 5.1		TFS:200975	16.10		01-Oct-2015		Ragu			CM is created of type lead when there is related contact associated with the lead is created from Eloqua.
 * 6.0		13805   	01.03		07-Dec-2016		Sajith			Rename 'Eloqua Integration profile' to 'Mkt_Apps Integration profile'
 * 
 */

public class CampaignFieldPopulator {

    public static void populateCampaignFieldsOnInsertUpdate(list<Campaign> lstNewCampaigns, map<Id, Campaign> mapOldCampaigns, TriggerHandler.TriggerEvent trigEvent) {
    	Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0');
    	Id CM2RTId = StaticFactory.getRecordTypeIdByNameDESC('CampaignMember', 'Campaign Member 2.0');
    	User currentUser = StaticFactory.getCurrentUserDetails();
    	
    	for(Campaign newCampaign : lstNewCampaigns) {
    		Campaign oldCampaign;
    		if(mapOldCampaigns != null) {
    			oldCampaign = mapOldCampaigns.get(newCampaign.Id);
    		}
    		
    		// v1.0 - Starts
    		if(newCampaign.RecordTypeId != campaign2RTId && newCampaign.Account_Play_Expiry_Date__c != null 
    			&& (trigEvent == TriggerHandler.TriggerEvent.ISINSERT 
    				|| (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && newCampaign.Account_Play_Expiry_Date__c != oldCampaign.Account_Play_Expiry_Date__c)))
    		{
	        	newCampaign.Send_Notification__c = true;
	        } 
    		// v1.0 - Ends
    		
    		// v2.0 - Starts
	    	if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT || (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && newCampaign.OwnerId != oldCampaign.OwnerId)) {
            	newCampaign.Campaign_Owner__c = newCampaign.OwnerId;
	        }
	        // v2.0 - Ends
	        
	        // v3.0 - Starts
	        if(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE
	        	&& (oldCampaign.Total_Value_Opportunities_Planned__c != newCampaign.Total_Value_Opportunities_Planned__c
			    	|| oldCampaign.Follow_Up_Role__c != newCampaign.Follow_Up_Role__c
			    	|| oldCampaign.NumberOfOpportunities != newCampaign.NumberOfOpportunities 
			    	|| oldCampaign.NumberOfWonOpportunities != newCampaign.NumberOfWonOpportunities
					|| oldCampaign.AmountAllOpportunities != newCampaign.AmountAllOpportunities 
					|| oldCampaign.AmountWonOpportunities != newCampaign.AmountWonOpportunities
					|| oldCampaign.Campaign_ROI__c != newCampaign.Campaign_ROI__c 
					|| oldCampaign.Campaign_Profit__c != newCampaign.Campaign_Profit__c
					|| oldCampaign.Sales_Ready_Leads__c != newCampaign.Sales_Ready_Leads__c 
					|| oldCampaign.Eloqua_Campaign__c != newCampaign.Eloqua_Campaign__c))
		    {
		    	newCampaign.Mascot_Update_Flag__c = System.now();
		    }
		    // v3.0 - Ends
		    
		    if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
		    	// v5.1 - Starts
		    	// 6.0
		    	if(newCampaign.Global_Campaign_Type__c == 'Campaign 2.0' && currentUser.Profile.Name == 'Mkt_Apps Integration profile') {
		    		newCampaign.RecordTypeId = campaign2RTId;
		    	}
		    	// v5.1 - Ends
		    	
		    	// v5.0 - Starts
		    	if(newCampaign.RecordTypeId == campaign2RTId) {
		    		newCampaign.CampaignMemberRecordTypeId = CM2RTId;
		    	}
		    	// v5.0 - Ends
		    }
	    }
    }

}