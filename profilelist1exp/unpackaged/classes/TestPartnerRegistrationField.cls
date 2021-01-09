@IsTest
private class TestPartnerRegistrationField {
	
    public class ResellerTaxIDInputField extends PartnerRegistrationField{
    	public ResellerTaxIDInputField(){
    		super(Label.reseller_tax_id, TYPE_STRING,'Reseller_Tax_ID__c',true,true);
    	}
    }
	
	private static testmethod void testString(){
        Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.Show_Reseller_Tax_ID__c = 'Yes';
        country.Require_Reseller_Tax_ID__c = 'Yes';
		insert country;
		
		Partner_Request__c req = new Partner_Request__c();
		ResellerTaxIDInputField field = new ResellerTaxIDInputField();
		field.request = req;
		field.setCountry(country);
		List<SelectOption> options = field.picklistValues;
		System.assertEquals(true,field.visible);
		System.assertEquals(true,field.required);
		System.assertEquals(true,field.isEmpty);
		
		field.value = 'test';
		System.assertEquals(false,field.isEmpty);
		System.assertEquals('test',field.value);
		
	}
	
    public class PrimaryRoutesToMarketInputField extends PartnerRegistrationField{
    	public PrimaryRoutesToMarketInputField(){
    		super('Primary Route to Market', TYPE_PICKLIST_WITH_OTHER, 'Primary_Routes_to_Market__c', true, true);
    	}
		public override List<SelectOption> retrievePicklistValues(){
	    	return getSelectOptions(Partner_Request__c.Primary_Routes_To_Market__c.getDescribe());
    	}  
    }
 
	private static testmethod void testPicklistWithOther(){
        Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.Show_Primary_Routes_to_Market__c = 'Yes';
        country.Require_Primary_Routes_to_Market__c = 'Yes';
		insert country;
		
		Partner_Request__c req = new Partner_Request__c();
		PrimaryRoutesToMarketInputField field = new PrimaryRoutesToMarketInputField();
		System.assertEquals(false,field.showOther);
		field.request = req;
		field.setCountry(country);
		List<SelectOption> options = field.picklistValues;
		System.assertEquals(true,field.visible);
		System.assertEquals(true,field.required);
		System.assertEquals(true,field.isEmpty);
		
		field.value = 'test';
		System.assertEquals(false,field.isEmpty);
		System.assertEquals('test',field.value);
		
		System.assertEquals(null,field.doShowOther());
		System.assertEquals(true,field.showOther);

		field.value = 'test';
		System.assertEquals(false,field.isEmpty);
		System.assertEquals('Other: test',field.value);

		System.assertEquals(null,field.doShowPicklist());
		System.assertEquals(false,field.showOther);
	}

    public class HaveReadPartnerProgramGuideInputField extends PartnerRegistrationField{
    	public HaveReadPartnerProgramGuideInputField(){
    		super('I have read the Partner Program Guide?', TYPE_BOOLEAN, 'Have_read_the_Partner_Program_Guide__c',true,true,
    			'Show_Have_read_Partner_Program_Guide__c','Require_Have_read_Partner_Program_Guide__c');
    	}
    }

	private static testmethod void testBoolean(){
        Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.Show_Have_read_Partner_Program_Guide__c = 'Yes';
        country.Require_Have_read_Partner_Program_Guide__c = 'Yes';
        
		insert country;
		
		Partner_Request__c req = new Partner_Request__c();
		HaveReadPartnerProgramGuideInputField field = new HaveReadPartnerProgramGuideInputField();
		field.request = req;
		field.setCountry(country);
		System.assertEquals(true,field.visible);
		System.assertEquals(true,field.required);
		System.assertEquals(true,field.isEmpty);
		
		field.value = 'true';
		System.assertEquals(false,field.isEmpty);
		System.assertEquals('true',field.value);
		
		field.value = 'false';
		System.assertEquals(true,field.isEmpty);
		System.assertEquals('false',field.value);
		
	}
	
    public class CountriesDoingBusinessInInputField extends PartnerRegistrationField{
    	public CountriesDoingBusinessInInputField(){
    		//super(Label.states_provinces_doing_business_in_prompt, TYPE_MULTIPICKLIST, 
    		super(null, TYPE_MULTIPICKLIST,
    			'States_Provinces_doing_business__c', true, true, 'Show_States_Provinces_doing_bus__c', 
    			'Require_States_Provinces_doing_bus__c');
    	}
		public override List<SelectOption> retrievePicklistValues(){
	    	return getSelectOptions(Partner_Request__c.States_Provinces_doing_business__c.getDescribe());
    	}  
    }
    
	private static testmethod void testMultiPicklist(){
        Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.Show_States_Provinces_doing_bus__c = 'Yes';
        country.Require_States_Provinces_doing_bus__c = 'Yes';
		insert country;
		
		Partner_Request__c req = new Partner_Request__c();
		CountriesDoingBusinessInInputField field = new CountriesDoingBusinessInInputField();
		field.handleSelectionChange();
		System.assertEquals(null,field.valueMultiPicklist);
		System.assertEquals('',field.value);
		System.assertEquals(false,field.showOther);
		field.request = req;
		field.setCountry(country);
		List<SelectOption> options = field.picklistValues;
		System.assertEquals(true,field.visible);
		System.assertEquals(true,field.required);
		System.assertEquals(true,field.isEmpty);
		
		field.valueMultiPicklist = new String[]{'test1','test2'};
		System.assertEquals(false,field.isEmpty);
		ArrayUtils.assertArraysAreEqual(new String[]{'test1','test2'},field.valueMultiPicklist);
		
	}    
 
    public class EnablePartnerFinderInputField extends PartnerRegistrationField{
    	public EnablePartnerFinderInputField(){
    		super('I want to be published to the Dell Partner Finder directory', TYPE_BOOLEAN, 
    			'Feature_Request_Partner_Finder__c',
    			//'Partner_Finder_Enabled__c', false);
    			true, false);
    	}
    }
 
	private static testmethod void testEnableFlagBoolean(){
        Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.Partner_Finder_Enabled__c = 'Yes';
		insert country;
		
		Partner_Request__c req = new Partner_Request__c();
		EnablePartnerFinderInputField field = new EnablePartnerFinderInputField();
		field.request = req;
		field.setCountry(country);
		System.assertEquals(true,field.visible);
		System.assertEquals(false,field.required);
		System.assertEquals(true,field.isEmpty);
		
		field.value = 'true';
		System.assertEquals(false,field.isEmpty);
		System.assertEquals('true',field.value);
		
		field.value = 'false';
		System.assertEquals(true,field.isEmpty);
		System.assertEquals('false',field.value);
	}
	
    public class PreferredLanguageInputField extends PartnerRegistrationField{
    	public PreferredLanguageInputField(){ super('Preferred Language', TYPE_PICKLIST, 'Preferred_Language__c', true, false);}
		public override List<SelectOption> retrievePicklistValues(){
	    	return getSelectOptions(Partner_Request__c.Preferred_Language__c.getDescribe());
    	}  
    }

	private static testmethod void testPicklist(){
		PreferredLanguageInputField field = new PreferredLanguageInputField();
		Partner_Request__c req = new Partner_Request__c();
		field.request = req;
		List<SelectOption> options = field.picklistValues;
		System.assertEquals(true,field.visible);
		System.assertEquals(false,field.required);
		System.assertEquals(true,field.isEmpty);
		
		field.value = 'test';
		System.assertEquals(false,field.isEmpty);
		System.assertEquals('test',field.value);
		
	}    
 
}