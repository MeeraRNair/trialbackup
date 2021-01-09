/***********************************************************
* Name          : VFCntrlr_GoalDealCreation 
* Description   : Controller class for GoalDealCreation VF Page
* ---------------------------------------------------------
* Revision	Release	Name    Date            Description
* 1.0        		MenMee  08.03.2010		Creation          
* 2.0		12.3	MenMee	31.03.2011		Defect 69648 Change 'Goal' to all capital		
* 2.1		12.3	MenMee	05.04.2011		Defect 69687 Customize error message
************************************************************/

public class VFCntrlr_GoalDealCreation {
    
    public Opportunity oppRecord;
	public String errorMessage {get; set;}	
	public String backToOpportunity {
		get {
			System.debug('## backToOpportunity: '+oppId);
			return '/'+oppId;
		}
	}
		
	private List<Opportunity> oppRecordList = new List<Opportunity>();
	private String oppId;
	private static final String SERVICE_CREATE = 'SERVICE_CREATE';
	
	//Constructor	
	public VFCntrlr_GoalDealCreation(ApexPages.StandardController controller) {
			
		try {		
			errorMessage = '';
			oppRecord = (Opportunity) controller.getRecord();			
			oppId = StringUtils.subString(oppRecord.Id, 0, 15);
			System.debug('## opp: '+oppId);
	        oppRecordList = [SELECT Id, Deal_Id__c
	        				 FROM Opportunity
							 WHERE Id =:oppId LIMIT 1];
												
	    	System.debug ('## oppRecordList = '+ oppRecordList);  
	    	if (oppRecordList.isEmpty()){
	    		errorMessage = 'Could not find a valid Opportunity record';
	    		return;
	    	}
		}
		catch (Exception e) {            
            errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';           
        }		
	}
	
	//Method to generate vendavo URL
	public PageReference createGoalDeal() {	
		
		String newGoalDealPageURL = '';
				
		try {		
			System.debug('## In VFCntrlr_GoalDealCreation:createGoalDeal');
			newGoalDealPageURL = GoalIntegrationUtils.createNewGoalDealURL(oppRecordList[0].Deal_Id__c);
			System.debug('## Out');
			
			if (newGoalDealPageURL != null) {
				System.debug('## new page '+newGoalDealPageURL);
				PageReference goalDealPage = new PageReference(newGoalDealPageURL);
				return goalDealpage;
			}
			else {
				System.debug('## error when create '+ GoalIntegrationUtils.isErrorResponse);
				if (GoalIntegrationUtils.isErrorResponse) {				
					if (GoalIntegrationUtils.faultCode != null) {
						
						//Check for custom fault string
						errorMessage = GoalIntegrationUtils.handleFaultString(GoalIntegrationUtils.faultCode, SERVICE_CREATE);
					}
					else {
						//Rev 2.1
						errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';							   
					}				
				}
				else {
					//Rev 2.1
					errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';
				}
				return null;
			}
		}
	    catch(Exception e) {
	        errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';
	        system.debug('## [Code: VFCntrlr_GoalDealCreation.createGoalDeal] Caught APEX exception '+e.getMessage());	        
	        return null;
	    }				
	}
	
	public PageReference unsupportedBrowserWarning() {		
		errorMessage = 'Unsupported Browser Detected. Please use Internet Explorer to open GOAL application.';		
		return null;
	}
	
	public PageReference doBack() {
		return new PageReference('/'+oppId);
	}
}