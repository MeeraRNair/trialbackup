public class LatticeVFLinkExtension
	{
	private final Account accountObj;
	
	//CR 4463 - Add Lattice Plays field to Contact, Account Play, and Relationship Lead
	private String countryCode 	 		{get;set;}
	private String countryString 		{get;set;}
	public  String paramURL 	 		{get;set;}
	private String tempId 				{get;set;}
	public  Boolean isForbiddenRegionFlag 		= false;
	private Map<String,String> sitRegionURLMap 	= null;  
	private Map<String,String> prodRegionURLMap = null;
	private Map<String,Map<String,String>> regionTabList = null;
	public static final Boolean isProduction = Environment.isProduction();
	
	// The extension constructor initializes the private member
	// variable account by using the getRecord method from the standard
	// controller.
	public LatticeVFLinkExtension(ApexPages.StandardController
	stdController) {
		System.debug('Account.sObjectType == stdController==' +  stdController.getRecord().getsObjectType());
		System.debug('Account.sObjectType=='+Account.sObjectType);
		
		
		if(stdController.getRecord().getsObjectType()==Account.sObjectType){
			this.accountObj  = (Account)stdController.getRecord();	
			tempId = this.accountObj.id;
		}
		else if(stdController.getRecord().getsObjectType()==Contact.sObjectType){
				tempId = stdController.getRecord().id;
				List<Contact> contactList = [SELECT account.id, account.Account_ID__c, account.name, account.POET_Leads__c, account.POET_Open_Leads__c FROM Contact WHERE id=:tempId limit 1];
				system.debug('contactList[0].account =='+contactList[0].account);
				this.accountObj = contactList[0].account;
			}
		else if(stdController.getRecord().getsObjectType()==Account_Play__c.sObjectType){
				tempId = stdController.getRecord().id;
				List<Account_Play__c> accPlayList = [SELECT  Account__r.id, Account__r.Account_ID__c, Account__r.name,account__r.POET_Leads__c, account__r.POET_Open_Leads__c FROM Account_Play__c WHERE id=:tempId limit 1];
				system.debug('accPlayList[0].account =='+accPlayList[0].Account__r);
				this.accountObj = accPlayList[0].Account__r;
			}	
		else if(stdController.getRecord().getsObjectType()==Relationship_Lead__c.sObjectType){
				tempId = stdController.getRecord().id;
				List<Relationship_Lead__c> relList = [SELECT Contact__r.Account.id, Contact__r.account.Account_ID__c, Contact__r.account.name, Contact__r.account.POET_Leads__c, Contact__r.account.POET_Open_Leads__c  FROM Relationship_Lead__c WHERE id=:tempId limit 1];
				system.debug('relList[0].Contact__r.account =='+relList[0].Contact__r.account);
				this.accountObj = relList[0].Contact__r.account;
		}
					
		
		List<Account> accountList = [SELECT id, Account_country_code__c, Account_Country__c, POET_Leads__c,POET_Open_Leads__c  FROM Account WHERE id=:this.accountObj.id limit 1];
		if(accountList.size()>0){
			countryCode   = accountList[0].Account_country_code__c;
			countryString = accountList[0].Account_Country__c;
			System.debug('Account id =' +this.accountObj.id + ',countryCode = '+ countryCode + ', countryString='+countryString);
		}
		
		system.debug('accountList size ='+accountList.size());
		paramURL = retFinalURL(countryCode,countryString);
		System.debug('paramURL ='+paramURL);
		
	}
	
	//CR 4463 - return URL that used for passing over to LatticeVFTab page 
	public String retFinalURL(String tempCountryCode, String tempCountryString){
		
		String retURL = '';
		List<Country__c> countryList = null;
		if(StringUtils.isNotBlank(tempCountryCode) || StringUtils.isNotBlank(tempCountryString)){
			countryList = [SELECT Region__c FROM Country__c 
						   WHERE name =:tempCountryString OR code__c =:tempCountryCode 
						   limit 1];
			if(countryList.size()>0 ){
				if(isForbiddenRegion(countryList[0].region__c)){
					isForbiddenRegionFlag = true;
				}				
				else{				
					retURL = getDefinedRegionURL(countryList[0].region__c);
			}				
			}			   
		}
		return retURL;
	}
	
	public Boolean isForbiddenRegion(String tempRegion){
		Boolean isForbiddenRegion = false;
		Set<String> avoidCountrySet = new Set<String>{'LATAM'};
		if(avoidCountrySet.contains(tempRegion)){
			isForbiddenRegion = true;
			System.debug('Region ='+ tempRegion +' is prohibit region');
		}
		return isForbiddenRegion;
	}
	
	public String getDefinedRegionURL(String tempRegion){
		String retURL = '';		
		initializedRegionTabWithID();
		if(regionTabList.containsKey(tempRegion.toUpperCase().trim())){
			String tabName = ''; String tabID = '';   		
			
			for(String regionKey : regionTabList.keySet()){
			for(String tabKey : regionTabList.get(regionKey).keyset()){ //should set the variable and create a dynamic link
				System.debug('regionKey='+regionKey +', Tabkey='+tabKey +', Tab id='+regionTabList.get(regionKey).get(tabKey));			
				if(StringUtils.equalsIgnoreCase(regionKey, tempRegion.toUpperCase().trim())){
					retURL = '/apex/'+tabKey+'?sfdc.tabName='+regionTabList.get(regionKey).get(tabKey)+'&prismAccountId='+PageUtils.encodeVariable(accountObj.Account_ID__c);
					System.debug('getDefinedRegionURL retURL =' + retURL);
				}
				}
			}
		}
		return retURL;
	}
	
	//Tab id required to change in each environment	
	public void initializedRegionTabWithID(){
		if(regionTabList==null){
			regionTabList = new Map<String,Map<String,String>>{
				'NA'=>new Map<String,String>{'LatticeVFTab'=>'01rA0000000LHG2'},
				'LATAM'=>new Map<String,String>{'LatticeVFTabLATAM'=>'01rT0000000973j'},
				'EMEA'=>new Map<String,String>{'LatticeVFTabEMEA'=>'01rA0000000Lq74'},
				'EC-EMEA'=>new Map<String,String>{'LatticeVFTabEMEA'=>'01rA0000000Lq74'},
				'APJ'=>new Map<String,String>{'LatticeVFTabAPJ'=>'01rA0000000Lq73'}
			};					
			
		}
		
		/*
		for(String regionKey : regionTabList.keySet()){
			for(String tabKey : regionTabList.get(regionKey).keyset()){ //should set the variable and create a dynamic link
				System.debug('regionKey='+regionKey +', Tabkey='+tabKey +', Tab id='+regionTabList.get(regionKey).get(tabKey));
			}
		}
		*/
	
	}
	// create a map for different tab
	//get the tab to pass as LINK
	
	public PageReference goToPrism()
	{	
	
	String link = '';
	PageReference pageRef = null;
	
	if(StringUtils.isNotBlank(paramURL)){
		link = paramURL;
		pageRef = new PageReference(link);
	}
	else{		
        //PageUtils.addError('Please ensure account country is set!');
        //ApexPages.currentPage().getParameters().put('errorStr', 'Please ensure account country is set!');
        pageRef = Page.LatticeNoRegionError;
        if(isForbiddenRegionFlag){
        	pageRef.getParameters().put('errorStr','Lattice is not available for this Account.');
        }else{
        	pageRef.getParameters().put('errorStr','Please ensure account country is set.');
        }
        
        System.debug('tempId = '+tempId);
        pageRef.getParameters().put('retURL','/'+tempId);
		//link = '/apex/LatticeNoRegionError';
	}
				
	pageRef.setRedirect(true);
	
	return pageRef;
	}
	public String getLinkToPrism()
	{
	return goToPrism().getURL();
	}
	public Boolean getIsPrismAccount()
	{
	return accountObj.POET_Leads__c > 0;
	}
	public String getSummary()
	{
	String toReturn = 'N/A';
	if(accountObj != null)
	{
	if(accountObj.POET_Leads__c > 0)
	{
	toReturn = accountObj.POET_Open_Leads__c.format() + '/' +
	accountObj.POET_Leads__c.format();
	}
	}
	return toReturn;
	}
	}