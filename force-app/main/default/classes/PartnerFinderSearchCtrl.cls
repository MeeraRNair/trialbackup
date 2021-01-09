public without sharing class PartnerFinderSearchCtrl {

	public String searchString {get;set;}
	public List<Account> searchResults {get;set;}
	public Integer getSearchResultsCount(){ if(searchResults == null){ return 0; } else { return searchResults.size(); } }
	public Boolean errorNoSearchResults {get;set;}
	public Boolean errorTooManySearchResults {get;set;}
	public Partner_Request__c accountDataHolder {get;set;}
	
	public String getPreferredLanguageCode(){  return PartnerUtils.getPreferredLanguageCode(); }

	public static final String ACCOUNT_ID_HTTP_PARAM = 'accountId';
	
	public PartnerFinderSearchCtrl(){
		errorNoSearchResults = false;
		errorTooManySearchResults = false;
	}

	public PageReference doSearch(){
		errorNoSearchResults = false;
		errorTooManySearchResults = false;
        try{
        	/* 
        	//RLV 4/7/09 Converted from SOSL => SOQL per defect in SOSL where clause filtering
        	List<List<SObject>> searchList = [
        		FIND :searchString IN ALL FIELDS RETURNING 
        		Account (
					id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Partner_Finder_Business_Description__c,
					ShippingPostalCode,ShippingCountry,Account_Country__c,Account_Country_Code__c
					WHERE IsPartner = true and Partner_Finder_Opt_In__c = true and Partner_Finder_Dell_Opt_in__c = true
					ORDER BY name
				)
				];
			searchResults = ((List<Account>)searchList[0]);
			*/
			String searchStringClone = searchString;
			if(StringUtils.isNotBlank(searchStringClone)){
				if(!StringUtils.startsWith(searchStringClone, '%')){
					searchStringClone = '%' + searchStringClone;
				}
				if(!StringUtils.endsWith(searchStringClone, '%')){
					searchStringClone += '%';
				}
			}
			searchResults = [
				select id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Partner_Finder_Business_Description__c,
					ShippingPostalCode,ShippingCountry,Account_Country__c,Account_Country_Code__c
				from Account
				where IsPartner = true 
					and Partner_Finder_Opt_In__c = true 
					and Partner_Finder_Dell_Opt_in__c = true
					and (name like :searchStringClone or ShippingCity like :searchStringClone 
						or ShippingState like :searchStringClone or ShippingPostalCode like :searchStringClone) 
				order by name];	
			if(searchResults != null){
				for(Account acct : searchResults){
					acct.Partner_Finder_Business_Description__c = 
						StringUtils.abbreviate(acct.Partner_Finder_Business_Description__c,40);
				}	
			}
        }catch(QueryException e){
        	errorTooManySearchResults = true;
        	return null;
        }catch(Exception e1){
			ApexPages.addMessages(e1);
        	return null;
        }        

        if (searchResults.size() == 0){
        	errorNoSearchResults = true;
        }
        return null;
	}

	public PageReference doSelectAccount(){
        String accountId = PageUtils.param(ACCOUNT_ID_HTTP_PARAM);
        if(StringUtils.isBlank(accountId)){
			return null;
        }
        accountDataHolder = createDataHolder(accountId);
        return null;
	}

	public PageReference doBackToSearch(){
		accountDataHolder = null;
		return null;
	}

	private Partner_Request__c createDataHolder(String accountId){
		List<Account> accountList = 
			[select name,Website,ShippingStreet,ShippingState,ShippingPostalCode, ShippingCountry, 
				ShippingCity,Phone,Partner_Finder_Contact_Email__c,Partner_Finder_Business_Description__c	
			from Account 
			where 
				id = :accountId 
				and IsPartner = true 
				and Partner_Finder_Opt_In__c = true 
				and Partner_Finder_Dell_Opt_in__c = true];
		if(accountList.isEmpty()){
			return null;
		}
		Account company = accountList.get(0);
		Partner_Request__c request = new Partner_Request__c();
		request.Company__c = company.name;
		request.Website__c = company.Website;
		String[] addressTokens = StringUtils.split(company.ShippingStreet,'\n'); 
		if(addressTokens == null){ addressTokens = new String[]{}; }
		request.Org_Address_1__c = addressTokens.size() > 0 ? StringUtils.trim(addressTokens[0]) : '';
		request.Org_Address_2__c = addressTokens.size() > 1 ? StringUtils.trim(addressTokens[1]) : '';
		request.Org_Address_3__c = addressTokens.size() > 2 ? StringUtils.trim(addressTokens[2]) : '';
		request.Org_State__c = company.ShippingState;
		request.Org_Postal_Code__c = company.ShippingPostalCode;
		request.Org_City__c = company.ShippingCity;
		request.Org_Phone__c = company.Phone; 
		request.Partner_Finder_Contact_Me_Email__c = company.Partner_Finder_Contact_Email__c;
		request.Description__c = company.Partner_Finder_Business_Description__c;
		return request;
	}

}