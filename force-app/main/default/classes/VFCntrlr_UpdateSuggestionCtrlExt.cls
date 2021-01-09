public class VFCntrlr_UpdateSuggestionCtrlExt {

	//Define class variables
    private Account accountRecord;
    private Id rectype;
    private String returnURL;
    private List<Lead> suggestionLeadList;
    private Lead suggestionLead;
    private User currentUser;

    public VFCntrlr_UpdateSuggestionCtrlExt(ApexPages.StandardController controller) {
		accountRecord = (Account)controller.getRecord();
		List<Account> accountRecordList = [Select Website, Type, Tax_Registration_Number__c, Sic, Shipping_Suburb__c, ShippingStreet, ShippingState, ShippingPostalCode,
				   ShippingCountry, ShippingCity, Partner_Type__c, Partner_Tier__c, Partner_Relationship__c, NumberOfEmployees, NameLocal, Name, Account_Country_Code__c,
				   GS_ICA_Indicator__c, Fiscal_Year_End__c, DMU__c, Billing_Suburb__c, BillingStreet, BillingState, BillingPostalCode, BillingCountry,
				   BillingCity From Account where id=:accountRecord.id];

		if(accountRecordList.size() > 0){
			accountRecord = accountRecordList[0];
		}

		rectype = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead',true);
		//gets the current user info
		getCurrentUser();
    }

	public void getCurrentUser(){
    	currentUser =  [SELECT Id, Badge_Number__c, FirstName, LastName, Email
    					FROM User
    					WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

	//Method to navigate to the Lead changing it's RecordType
    public PageReference navigateToLead(){
    	try{
	    	suggestionLeadList = [SELECT id,Account__c, Status
	    						  FROM Lead
	    						  WHERE Account__c=:accountRecord.Id AND OwnerId=:currentUser.Id AND RecordTypeId=:rectype
	    						  AND (Status='Open' OR Status='Draft')
	    						  ORDER BY Status DESC];

	        System.debug('## suggestionLeadList = '+ suggestionLeadList);
	        if(suggestionLeadList.size()==0){
	        	suggestionLead = new Lead(status='Open',RecordTypeId = rectype, FirstName = currentUser.FirstName,
	        							  LastName = currentUser.LastName, Email = currentUser.Email);

	        }
	        else{
	        	suggestionLead = suggestionLeadList[0];
	        }
	        if(suggestionLead.Status == 'Open'&& accountRecord.Id!=null){

	        	//country association
	        	Set<String> countryCodeSet = new Set<String> {accountRecord.ShippingCountry,  accountRecord.BillingCountry, accountRecord.Account_Country_Code__c};
	        	Map<String, String> countryCodesToGUIDmap = getCountryIds(countryCodeSet);




	        	suggestionLead.Account__c = accountRecord.Id;
	        	suggestionLead.Company = accountRecord.Name;


				/*
				//commented as per Defect 53217

				//for street address
	        	Map<String, String> streetAddressMap = new Map<String, String>();
				suggestionLead.Website = accountRecord.Website;

				streetAddressMap = spiltStreetAddress(accountRecord.ShippingStreet);
				suggestionLead.Physical_Address_1__c = streetAddressMap.get('line1');
				suggestionLead.Physical_Address_2__c = streetAddressMap.get('line2');  //   ShippingStreet After /n

				suggestionLead.Physical_City__c = accountRecord.ShippingCity;
				suggestionLead.Physical_suburb__c = accountRecord.Shipping_Suburb__c;
				suggestionLead.Physical_State__c = accountRecord.ShippingState;
				suggestionLead.Physical_PostalCode__c = accountRecord.ShippingPostalCode;

				//lookup
				suggestionLead.Physical_Country__c = countryCodesToGUIDmap.get(accountRecord.ShippingCountry);

				streetAddressMap = spiltStreetAddress(accountRecord.BillingStreet);
				suggestionLead.Postal_Address_1__c = streetAddressMap.get('line1');
				suggestionLead.Postal_Address_2__c = streetAddressMap.get('line2');  //   BillingStreet After /n

				suggestionLead.Postal_City__c = accountRecord.BillingCity;
				suggestionLead.Postal_suburb__c = accountRecord.Billing_Suburb__c;
				suggestionLead.Postal_State__c = accountRecord.BillingState;
				suggestionLead.Postal_PostalCode__c = accountRecord.BillingPostalCode;

				//lookup
				suggestionLead.Postal_Country__c = countryCodesToGUIDmap.get(accountRecord.BillingCountry);

				suggestionLead.Fiscal_Year_End__c = DateTimeUtils.convertToDateTime(accountRecord.Fiscal_Year_End__c);

				*/


				suggestionLead.Organization_Country__c = countryCodesToGUIDmap.get(accountRecord.Account_Country_Code__c);
				suggestionLead.DMU_Flag__c = accountRecord.DMU__c ;

				suggestionLead.National_ID__c = accountRecord.Tax_Registration_Number__c;
				suggestionLead.Program_Type__c = accountRecord.GS_ICA_Indicator__c;
				suggestionLead.CompanyLocal = accountRecord.NameLocal ;
				suggestionLead.Employee_Size__c = accountRecord.NumberOfEmployees;

				/* Commented as of 16-Oct-09 */
				//suggestionLead.SIC_code__c = accountRecord.Sic;

				suggestionLead.Account_Category__c = accountRecord.Type;

				if(accountRecord.Type == 'Partner'){
					suggestionLead.Partner_Class__c = accountRecord.Partner_Tier__c;
					suggestionLead.Partner_Status__c = accountRecord.Partner_Relationship__c;
					suggestionLead.Partner_Type__c = accountRecord.Partner_Type__c;
				}

	        	System.debug('## Before upsert, suggestionLead = '+ suggestionLead);
	        	upsert suggestionLead;
	        	System.debug('## After upsert, suggestionLead = '+ suggestionLead);
	        }

        }catch(Exception e){
            System.debug('##MN: Caught APEX exception ' + e.getMessage());
            emailUtils.sendSupportEmail(e.getMessage()+'[ Code:  VFCntrlr_UpdateSuggestionCtrlExt.navigateToLead() ]', dellConfig.errorEmail);
        }
        returnURL='/'+suggestionLead.id+'/e?cancelURL='+accountRecord.Id
                    +'&retURL='+suggestionLead.id
                    +'&save_new_url='+suggestionLead.id;
    	return PageUtils.redirect(returnURL);
    }




    public Map<String, String> getCountryIds(Set<String> countryCodeSet){

    	Map<String, String> countryCodesToGUIDmap = new Map<String, String>();
    	for(Country__c CountryItem : [SELECT Name, Id, Dell_Online_Country_Code__c, Code__c
    								  FROM Country__c
    								  WHERE Code__c IN :countryCodeSet]){

    		countryCodesToGUIDmap.put(CountryItem.Code__c,CountryItem.Id);
    	}
    	return countryCodesToGUIDmap;
    }

    /*
    commented as per Defect 53217
    public Map<String, String> spiltStreetAddress(String address){

    	Map<String, String> addressMap = new Map<String, String>();
    	address = StringUtils.defaultString(address); // making it not null
    	list<String> addressComponents = address.split('\n', 2);
    	addressMap.put('line1',StringUtils.defaultString(addressComponents[0]));

    	if(addressComponents.size()>1){
    		addressMap.put('line2',StringUtils.defaultString(addressComponents[1]));
    	}
    	else{
    		addressMap.put('line2','');
    	}

    	return addressMap;
    }
    */



}