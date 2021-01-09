/***********************************************************
* Name          : GoalIntegrationUtils 
* Description   : All methods for Goal Integration
* ---------------------------------------------------------
* Revision      Release	Name    Date            Description
* 1.0           11.10	MenMee  09.08.2010		CR2688 Migrate Dell Portal functionality to SFDC to capture Software and Peripherals deals         
*
*
************************************************************/

public class VFCntrlr_SnPRecalculate {
	
	public String statusMessage {get; set;}	
	public Boolean isError {get; set;}
	public boolean isFromTest = false;
	
	private String oppId;
	private List<Opportunity> oppRecordList;
	
    public VFCntrlr_SnPRecalculate(ApexPages.StandardController controller) {
		try {					
			isError = false;
			
			oppId = ApexPages.currentPage().getParameters().get('OppId');
	        
			oppRecordList = [SELECT Id, CloseDate, CreatedDate, CurrencyIsoCode, Primary_Product_Delivery_Address_Region__c, 
									Primary_Product_Delivery_Address_Country__c, Account.Segment_Name_lookup__c,
                             		Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingCountry,
                             		Account.ShippingPostalCode 
									FROM Opportunity WHERE Id=:oppId LIMIT 1];								
	    	System.debug ('## oppRecordList = '+ oppRecordList);  
	    	if (oppRecordList.isEmpty()){
	    		isError = true;
	    		statusMessage = 'Could not find a valid Opportunity record';	    		
	    		return;
	    	}	    	
    	}
    	catch (exception e) {
    		system.debug('## [Code: VFCntrlr_SnPRecalculate:VFCntrlr_SnPRecalculate] Caught APEX exception: '+e.getMessage());              
    	}   	
    }
    
    public PageReference recalculateAll() {    	
		try {
			throwTestException(isFromTest);
			
			if (oppRecordList.isEmpty()) return null;
			
			SnPUtils.recalculateQualifiedSnPDRProg(oppRecordList[0]);
			
			statusMessage = 'Done';			
		}
		catch (exception e) {
			isError =true;
			statusMessage = 'A problem has occured: ' + e.getMessage();			
		}	
		return null;
    }
    
    public PageReference backToOpportunity() {  
    	
    	if (oppId != null && OppId.length() > 0) {  	
    		return new PageReference('/'+oppId);
    	}
    	else {    		
    		// Back to Opportunity List Page
    		return new PageReference('/006/o');
    	}
    }
    
	private static void throwTestException(boolean isTest){
        if(isTest){
			throw new dellUtil.DellException('TESTMETHOD EXCEPTION TESTING.');
        }       
	}

}