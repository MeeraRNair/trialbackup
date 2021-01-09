public with sharing class ltng_ToolsForJob {
	private static final String SHARED_PICKLISTVALUE = 'Global';
	@AuraEnabled
	public static wrapperTFJ getTFJList() {
		List<String> sectionList = new List<String> ();
		List<String> whereList = new List<String> ();
		List<Tools_For_The_Job__c> TFJList = new List<Tools_For_The_Job__c>();
		List<Schema.Picklistentry> sectionValues;              
 
		Schema.DescribeFieldResult fSection = Tools_For_The_Job__c.Section__c.getDescribe();
		sectionValues = fSection.getPicklistValues();

		for (Schema.PicklistEntry sectionValue: sectionValues) {
			if (sectionValue.getLabel() != SHARED_PICKLISTVALUE) sectionList.add(sectionValue.getLabel());
			whereList.add(sectionValue.getLabel());    
		}
		sectionList.sort();

		TFJList = [ SELECT Name, URL__c, Lightning_URL__c,Section__c, Sub_section__c, Help_Text__c                 
			FROM Tools_For_The_Job__c 
			WHERE Active__c = true AND Section__c IN :whereList
			ORDER BY Section__c, sequence__c, Name ASC];

		// create a wrapper class object and set the wrapper class @AuraEnabled properties and return it to the lightning component.
		wrapperTFJ wrapObj = new  wrapperTFJ ();
		wrapObj.lstSection = sectionList;
		wrapObj.lstTFJ = TFJList;
		System.debug('wrapObj: ' + wrapObj);
		return wrapObj;
	}
	// wrapper or Inner class with @AuraEnabled
	public class wrapperTFJ{
		@AuraEnabled public String sHeader = 'Global Standard Links';
		@AuraEnabled public String plValue = 'Global';
		@AuraEnabled public List<String> lstSection;
		@AuraEnabled public List<Tools_For_The_Job__c> lstTFJ;
	}
}