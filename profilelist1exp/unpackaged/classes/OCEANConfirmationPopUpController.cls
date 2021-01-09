/*
History:
    
    Version Date        Modified By      CR         Description     
--------------------------------------------------------------------------------------
1.0                                                 Created
...     ...             ...             ...
2.0     21-May-2015     Azwanti         CR11453: MAJ16.07:Consolidate LOT form into Needed Quote
2.1     22-Mar-2016     Afiq            CR12751   Added logic to check other fields to popup Needed Quote popup
3.0     11-jUN-2018     Ravindra Babu	CR15946   Merged methods confirmOceanEligible() and confirmNotOceanEligible() for Code Optimisation
*/
public class OCEANConfirmationPopUpController {
    Opportunity oppty;
    
    public OCEANConfirmationPopUpController(ApexPages.StandardController controller) {
        oppty = (Opportunity)controller.getRecord();
        //System.debug('###DEBUG###' + oppty );
    }

    public PageReference setNotificationFlag() {
        System.debug('###DEBUG### setNotificationFlag ');
			oppty.Ocean_Opportunity_Notification_Pop_Up__c = false;
			if(oppty.Eligible_for_Ocean__c == 'No')
			{
			  oppty.Do_you_want_to_pursue_Ocean__c = 'No';
			}
			
			try {
				update oppty;
			} catch (Exception e) {
				System.debug('###DEBUG### e - ' + e);
				throw e;
			}
			return null;
    }
      
	public void confirmOceanEligible() {
        OCEANConfirmationPopUpController.OceanEligibleMergeMethod(true,false,oppty);     
    } 
    
    public void confirmNotOceanEligible() {
        OCEANConfirmationPopUpController.OceanEligibleMergeMethod(false,true,oppty);
    }
    
    // [MB-6th June- Move this code it is not being called in main functionality]
    //CR11453 - validate if LineItems has blank 'Quote #' or 'Customer Requested Date'.
    public boolean getShowConsolidatePage(){
        boolean hasValidLineItem = false; 
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        lineItems = [SELECT Id, Quote__c, Customer_Requested_Date__c
                    FROM OpportunityLineItem
                    //CR12751 Added logic for Quantity and Configuration services 
                    WHERE OpportunityId =: oppty.Id AND (Quantity = null OR Configuration_Services__c = null OR Quote__c = null OR Customer_Requested_Date__c = null)];
        if(lineItems.size() > 0){
            hasValidLineItem = true;     
        }                    
        return hasValidLineItem;
    }
     
	public static void OceanEligibleMergeMethod(boolean OceanEligible, boolean OceanNotEligible, opportunity oppty){
		oppty.Ocean_Opportunity_Notification_Pop_Up__c = false;
		/*******Modification for CR 2810*****************/  
        /*If LOT Mandatory Flag is checked and Quote No and Shipment No are null, set LOT Mandatory Flag to False and LOT Large Flag to True*/
        /*******Modification for CR CR12751*****************/  
        /* Add query for OpportunityLineItem*/
        List<OpportunityLineItem> lineItemsNew = new List<OpportunityLineItem>();
        lineItemsNew = [SELECT Id, Quote__c, Customer_Requested_Date__c
                    FROM OpportunityLineItem
                    WHERE OpportunityId =: oppty.Id AND (Quantity = null OR Configuration_Services__c = null OR Quote__c = null OR Customer_Requested_Date__c = null)];
        /*******Modification for CR CR12751 Ends*****************/  
        
        /*******Modification for CR CR12751*****************/  
        /*To check on Opportunity Line Items instead of Opportunity Quote*/
		if(oppty.LOT_Mandatory_Fields__c && (oppty.How_many_shipments__c != null && oppty.Quote_Numbers__c != null)) {

            oppty.LOT_Mandatory_Fields__c = false;
            oppty.LOT_Large_Opportunity__c = true;                  
        }
		if(OceanEligible){
			oppty.Do_you_want_to_pursue_Ocean__c = 'Yes';
		}else if(OceanNotEligible){
			oppty.Do_you_want_to_pursue_Ocean__c = 'No';
		}
		try {
            update oppty;
        } catch (Exception e) {
            throw e;
        }
	}
}