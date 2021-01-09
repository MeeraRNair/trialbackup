public class PartnerToolLookupMyAccountIDsCtrl {
	public String ssoMyAccountLookupURL {get{return PartnerConstants.SSO_LINK_MY_ACCT_URL;}}
	public List<SelectOption> countrySelectOptions {get;set;}
	
	public PartnerToolLookupMyAccountIDsCtrl(){
		this.countrySelectOptions = new List<SelectOption>();
		List<Country__c> countries = [select id,name,code__c from Country__c order by name];
		if(countries != null && countries.size() > 0){
			for(Country__c country : countries){
		  	 	countrySelectOptions.add(new SelectOption(country.code__c,country.name));
			}
		}
	}
}