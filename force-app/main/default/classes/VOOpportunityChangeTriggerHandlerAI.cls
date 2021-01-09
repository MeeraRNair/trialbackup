/**
 * Opportunity change event After Insert trigger handler,
 * Performs all the operations on opportunity after change event insert operation
 * can be used for any opp related dml operation but should be only after events
 * Test class - OpportunityChangeUtilityTest
 * @author: Rajiv Ranjan
 * @since: 09-12-2019
 * */
public class VOOpportunityChangeTriggerHandlerAI implements AfterInsert{
	public void handleAfterInsert(List<sObject> listNew){
    	ToggleFeature__c vbToggle = ToggleFeature__c.getValues('VISIT_BUNDLE_SYNC_PLATFORM');
    	if(vbToggle != null && vbToggle.Enable_Feature__c == true)
        {
            OpportunityChangeUtility.populateReledVBRecords((List<OpportunityChangeEvent>)Trigger.new);
        }
    }
}