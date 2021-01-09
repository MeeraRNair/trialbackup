/*
 * Author		: Ragu
 * Purpose		: Act as a central point for controlling the trigger exection for any object.
 * Created Date	: 11-Apr-2014
 * Change Descriptions
 *
 * Version	Release		Date			Modified By				Description     
 * -------  -------		------------  	------------------- 	--------------------------------------------------------
 * 1.0 					11-Apr-2014 	Ragu 					Code added for controlling Opportunity related triggers.
 * 
 * 
 */

public class TriggerControlHandler {
	
	//START: Trigger Controllers for Opportunity
	private static boolean opportunityTriggers = true;
	
	public static void setOpportunityTriggersActive() {
		opportunityTriggers = true;
	}
	
	public static void setOpportunityTriggersInactive() {
		opportunityTriggers = false;
	}
	
	public static boolean isOpportunityTriggersActive() {
		return opportunityTriggers;
	}
	//END: Trigger Controllers for Opportunity
	
	

}