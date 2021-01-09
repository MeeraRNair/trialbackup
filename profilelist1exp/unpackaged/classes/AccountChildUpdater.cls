/*
 * Author   : Ragu
 * Purpose  : To handle all explicit updates to the child objects of the Account.
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12369    16.12       16-Dec-2015     Ragu            Defect 216660 - LM2_1_104-Add RAD account field into Direct Lead 2.0 page
 * 2.0      13336    FY17-DCS-0801  19-July-2016    SuiYee          Change RAD_Code__c from text field to formula field 
 */

public class AccountChildUpdater {

	// v1.0 - Common method for updating all Lead records.
	// v5.0
	/*
	public static void updateLeadRecords(map<Id, Account> mapNewAccounts, map<Id, Account> mapOldAccounts) {
		map<Id, Lead> mapLeads = new map<Id, Lead>();
		map<Id, Account> mapRADAccounts = new map<Id, Account>();
		
		for(Account newAccount : mapNewAccounts.values()) {
			Account oldAccount = null;
			
			if(mapOldAccounts != null) {
				oldAccount = mapOldAccounts.get(newAccount.Id);
				
				if(newAccount.RAD_Code__c != oldAccount.RAD_Code__c) {
					mapRADAccounts.put(newAccount.Id, newAccount);
				}
			}
		}
		
		mapLeads = AccountChildUpdater.populateRADCode(mapRADAccounts);
		
		if(!mapLeads.isEmpty()) {
			TriggerExecutionController.setSkipLeadTriggers(true);
			update mapLeads.values();
			TriggerExecutionController.setSkipLeadTriggers(false);
		}
	}
	
	// v1.0 - Method for populating RAD Code in Lead based on the RAD Code from Account.
	public static map<Id, Lead> populateRADCode(map<Id, Account> mapAccounts) {
		map<Id, Lead> mapLeads = new map<Id, Lead>();
		for(Lead leadIterator : [select Id, RAD_Code__c, Account__c from Lead where Account__c = :mapAccounts.keySet() order by CreatedDate desc limit 50000]) {
			Account accItrator = mapAccounts.get(leadIterator.Account__c);
			leadIterator.RAD_Code__c = accItrator.RAD_Code__c;
			mapLeads.put(leadIterator.Id, leadIterator);
		}
		return mapLeads;
	}
*/
}