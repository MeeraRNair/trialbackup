/* 
History:
Version    Date           Modified By     Description     
1.0        1-25-2019       Meenu           FY20-DCE-0402  5513319 Field Trip clean up for Contact (Removed/Commented BestTimeToCall__c field)
*/
global class AposIntegrationUtil {

	global class AposResponseObj {
		webservice string opptyId 					{set;get;}
		webservice string dealId 					{set;get;}
		webservice string errorCode 				{set;get;}
		webservice string errorDesc 				{set;get;}
		public 	   string contactId 				{set;get;}
		public 	   string accountOwner 				{set;get;}				
		
		public AposResponseObj(){}
	
	/*	
		public AposResponseObj(string param_opptyId, string param_dealId, string param_errorCode, string param_errorDesc){
			this.opptyId   		 = param_opptyId;
			this.dealId    		 = param_dealId;
			this.errorCode 		 = param_errorCode;
			this.errorDesc		 =  param_errorDesc;
		}
	*/
	}

	global class AposServiceTagObj {
		webservice string serviceTagNumber 			{set;get;}
		webservice string domainName 				{set;get;}
		webservice string serviceContractType 		{set;get;}
		webservice Date   expirationDate			{set;get;}
		webservice string customerNumber			{set;get;}
		webservice string accountID					{set;get;}
		
	}
	
	global class AposContactObj {
	
		webservice String  accountID 				{set;get;}
		webservice String  firstname 				{set;get;} 
		webservice String  lastname 				{set;get;} 		 
		webservice String  phone 					{set;get;} 
		webservice String  email 					{set;get;} 
		webservice String  preferredContactMethod 	{set;get;}  
		/*Commented By Meenu removed on 1/25/2019 BestTimeToCall__c reference */
		//webservice String  bestTimeToCall 			{set;get;} 
		public	   String  status 					{set;get;}
		public	   String  decisionMakingRole 		{set;get;}
		public     String  purchaseInfOver 			{set;get;}
		public	   String  jobFunction 				{set;get;}
		webservice String  title 					{set;get;}
	}
	
	 public class AposOpportunityObj {

		  string opptyAccountId 					{set;get;}
		  String opptyName         					{set;get;}
		  String opptyOwner        					{set;get;}
		  String opptyAccountName  					{set;get;}	
		  String opptyType         					{set;get;} 
		  String opptySolutionType 					{set;get;}
		  String opptyRecordTypeId   				{set;get;}
		  String opptyCurrency     					{set;get;}
		  String opptyUnweightedRevenue   			{set;get;}
		  Date 	 opptyBookDate       				{set;get;}
		  String opptystage		  					{set;get;}
		  String opptyverOutcome		  			{set;get;}
		
		 public AposOpportunityObj(String param_opptyOwner, String param_accountId){
			this.opptyAccountId			=  param_accountId;
			this.opptyName  			= 'PSM : Warranty Extension';
			this.opptyOwner 			=  param_opptyOwner;			
			this.opptyType 				= 'Deal/Bid - Direct';
			this.opptySolutionType  	= 'APOS' ;
			
			this.opptyCurrency			= 'USD';
			//this.opptyUnweightedRevenue = null; //remove since it is default to null
			this.opptyBookDate 			= OpportunityUtils.getLatestBookDate(); 
			this.opptystage				= 'Discover - 10%';
			this.opptyverOutcome		= 'Documented customer discussion validated by sponsor/champion';
			
		}
	}
	
	
	
	

	public static AposResponseObj doCreateContact(AposContactObj paramContact){
		AposResponseObj tempHolder = new AposResponseObj();
		if(StringUtils.isBlank(paramContact.phone) && StringUtils.isBlank(paramContact.email)){
			tempHolder.errorCode = AposConstants.ERROR_CONTACT_CREATION;
			tempHolder.errorDesc = AposConstants.ERROR_CONTACT_CREATION_NO_EMAIL_PHONE_DESC;
			return tempHolder;
		}
		try{
		    
		    /*Edited By Meenu removed on 1/25/2019 BestTimeToCall__c referencec BestTimeToCall__c=paramContact.bestTimeToCal */
			Contact newContact = new Contact(title=paramContact.title, firstname=paramContact.firstname, lastname=paramContact.lastname, accountid=paramContact.accountID ,
											 phone=paramContact.phone, email=paramContact.email, 
											 Preferred_Contact_Method__c=paramContact.preferredContactMethod,Job_Function_Role__c='Unknown',
											 Job_Function__c = 'Other',Purchaser_Influence_over_Merged__c='APOS Warranty Extension',Source_System__c = 'PSM Portal',
											 Decision_Making_Role__c = 'Unknown', status__c='Customer'  ); 			
			
			insert newContact;
			tempHolder.contactId = newContact.id;
			System.debug('contactId ===='+tempHolder.contactId);
			return 	tempHolder;	
		}
		catch(System.DmlException e){
			tempHolder.errorCode = AposConstants.ERROR_CONTACT_CREATION;
			tempHolder.errorDesc = AposConstants.ERROR_CONTACT_CREATION_DESC;
			return tempHolder;			
		}
			
		
	}
	
	public static AposResponseObj doUpdateContact(AposContactObj paramContact){
		AposResponseObj tempHolder = new AposResponseObj();
		List<contact> contactList = [SELECT id,phone, email,title from contact where firstname=:paramContact.firstname and lastname=:paramContact.lastname  limit 1];
		if(StringUtils.isBlank(paramContact.firstname) || StringUtils.isBlank(paramContact.lastname)){
			tempHolder.errorCode = AposConstants.ERROR_CONTACT_UPDATE_NO_FIRSTLAST_NAME;
			tempHolder.errorDesc = AposConstants.ERROR_CONTACT_UPDATE_NO_FIRSTLAST_NAME_DESC;
			return tempHolder;
		}	
		try{
		if(contactList.size() > 0){
			Contact existingContact = contactList.get(0);
			if(!StringUtils.equalsIgnoreCase(existingContact.phone, paramContact.phone)){existingContact.phone=paramContact.phone;}
			if(!StringUtils.equalsIgnoreCase(existingContact.email, paramContact.email)){existingContact.email=paramContact.email;}
			if(!StringUtils.equalsIgnoreCase(existingcontact.title, paramContact.title)){existingcontact.title=paramContact.title;}
			/*Commented By Meenu removed on 1/25/2019  */
			//existingContact.BestTimeToCall__c=paramContact.bestTimeToCall;
			existingContact.Preferred_Contact_Method__c=paramContact.preferredContactMethod;			
			existingContact.Purchaser_Influence_over_Merged__c='APOS Warranty Extension';
			
			update existingContact;	
			tempHolder.contactId = 	existingContact.id;	
			System.debug('doUpdateContact existingContact.id ==' + existingContact.id);
		}		
		return tempHolder;
		}catch(System.DmlException e){
			tempHolder.errorCode = AposConstants.ERROR_CONTACT_UPDATE;
			tempHolder.errorDesc = AposConstants.ERROR_CONTACT_UPDATE_DESC;
			return tempHolder;
		}
	}
	
	public static Boolean isExistingContact(AposContactObj paramContact){
		System.debug('### Contact firstname:'+paramContact.firstname + ', lastname:'+paramContact.lastname + ', AccountId:'+paramContact.accountID);
		Boolean isExist = false;
		Integer totalRecords = 0;
		if(paramContact != null){
			totalRecords = [SELECT count() from Contact where firstname=:paramContact.firstname and lastname=:paramContact.lastname and Accountid=:paramContact.accountID];
		}
		if(totalRecords > 0){
			isExist = true;		
		}
		return isExist;
	}
	
	
	public static AposResponseObj doCreateOpportunity(AposResponseObj paramRsObj, AposOpportunityObj paramOpp){
		System.debug('paramOpp.opptyName ==='+paramOpp.opptyName);
		System.debug('paramOpp.opptyCurrency ==='+paramOpp.opptyCurrency);
		System.debug('paramOpp.opptyAccountName ==='+paramOpp.opptyAccountName);
		System.debug('paramOpp.opptyType ==='+paramOpp.opptyType);
		System.debug('paramOpp.opptySolutionType ==='+paramOpp.opptySolutionType);
		System.debug('paramOpp.opptyBookDate ==='+paramOpp.opptyBookDate);
		System.debug('paramOpp.opptystage ==='+paramOpp.opptystage);
		System.debug('paramOpp.opptyRecordTypeId ==='+paramOpp.opptyRecordTypeId);
		System.debug('paramOpp.opptyOwner ==='+paramOpp.opptyOwner);
		System.debug('paramOpp.opptyverOutcome ==='+paramOpp.opptyverOutcome);
		List<recordtype> recordType = [Select Id From RecordType  where name='APOS' and SobjectType='Opportunity'];
		paramOpp.opptyRecordTypeId  = recordType.get(0).id;  						
		Opportunity newOpp = new Opportunity(name=paramOpp.opptyName, currencyisocode=paramOpp.opptyCurrency, 		 									 
		 									 AccountId  = paramOpp.opptyAccountId,
		 									 type=paramOpp.opptyType, solution_type__c=paramOpp.opptySolutionType,
		 									 closedate=paramOpp.opptyBookDate, stagename=paramOpp.opptystage, recordtypeid = paramOpp.opptyRecordTypeId,
		 									 ownerId=paramOpp.opptyOwner, Verifiable_Outcome__c=paramOpp.opptyverOutcome,Overlay_Solution_Type__c ='Apos',
		 									 Source_System__c = 'PSM Portal'
		 									 );
		AposResponseObj tempHolder = paramRsObj;
		System.debug('doCreateOpportunity before insert.....');
		try{			
			insert newOpp;
			tempHolder.opptyId = newOpp.id;		
			System.debug('After oppty inserted with oppty id .....' + newOpp.id);
			List<Opportunity> opptyList = [Select Deal_ID__c From Opportunity where id =:newOpp.id];
			tempHolder.dealId  = opptyList.get(0).Deal_ID__c ;
			System.debug('Deal id ====' +newOpp.Deal_ID__c);
			System.debug('tempHolder.dealId ====' +tempHolder.dealId);
			return tempHolder;					
		}catch(System.DmlException e){
			System.debug('Exception ===' + e);
			tempHolder.errorCode = AposConstants.ERROR_OPPTY_CREATION;
			tempHolder.errorDesc = AposConstants.ERROR_OPPTY_CREATION_DESC;
			return tempHolder;
		}
	}
	
	public static AposResponseObj doCreateOppContactRole(AposResponseObj paramRsObj, String paramOppId, String paramContactId){
		try{
		if(StringUtils.isBlank(paramOppId) || StringUtils.isBlank(paramContactId)){
			paramRsObj.errorCode = AposConstants.ERROR_CONTACT_ROLE_NO_OPPTY_CONTACT_ID;
			paramRsObj.errorDesc = AposConstants.ERROR_CONTACT_ROLE_NO_OPPTY_CONTACT_ID_DESC;
		}	
		if(!StringUtils.isBlank(paramOppId) && !StringUtils.isBlank(paramContactId)){
			OpportunityContactRole newContactRole = new OpportunityContactRole(OpportunityId=ParamOppId, contactid=paramContactId, role='Unknown',isPrimary=true); 
			insert newContactRole;	
			System.debug('OpportunityContactRole id ===='+newContactRole.id);
			
		}
		return paramRsObj;
		}
		catch(System.DmlException e){
			paramRsObj.errorCode = AposConstants.ERROR_CONTACT_ROLE_CREATION;
			paramRsObj.errorDesc = AposConstants.ERROR_CONTACT_ROLE_CREATION_DESC;
			return paramRsObj;
		}
	}
	
	/*
	public static AposResponseObj doCreateServiceTag(AposResponseObj paramRsObj, List<AposServiceTagObj> paramServiceTag){
		System.debug('Before doCreateServiceTag() ....');
		String custNumGUID = '';		
		if(paramServiceTag != null){		
			custNumGUID = doReturnCustNumGUID(paramServiceTag[0]);
		}
		try{
		if(paramServiceTag != null){
			for(AposServiceTagObj serviceTagRec : paramServiceTag){
				Contract_Information__c newContractInfo = new Contract_Information__c(Account__c=serviceTagRec.accountID,Customer_Number__c=serviceTagRec.customerNumber, CustomerNumber_LK__c=custNumGUID,
																					 service_tag__c=serviceTagRec.serviceTagNumber, domain_name__c=serviceTagRec.domainName,
																					 service_contract_type__c=servicetagRec.serviceContractType, Service_Contract_Expiration_Date__c=servicetagRec.expirationDate,
																					Opportunity__c=paramRsObj.opptyId);
				insert newContractInfo;																					 
				
			}
		}
						
			return paramRsObj;
		}
		catch(System.DmlException e){
			paramRsObj.errorCode = AposConstants.ERROR_SERVICETAG_CONTRACTS_CREATION;
			paramRsObj.errorDesc = AposConstants.ERROR_SERVICETAG_CONTRACTS_CREATION_DESC;
			return paramRsObj;
		}
		
	}*/
	
	
	//Change to cater multiple Customer number  and tied to respective Customer lookup 
	public static AposResponseObj doCreateServiceTag(AposResponseObj paramRsObj, List<AposServiceTagObj> paramServiceTag){
		System.debug('Before doCreateServiceTag() ....');
		Set<String> 						custNumGUIDSet 			= new Set<String>();	
		List<Contract_Information__c>		contractCreationList 	= new List<Contract_Information__c>();
		Map<String,String>					custNumGUIDMap  		= new Map<String,String>();
		List<customer_number__c>			custNumObjList			= new List<customer_number__c>();	
		
		if(paramServiceTag != null){		
			custNumGUIDSet 	= doCustNumListCreation(paramServiceTag);
			custNumObjList  = doReturnCustNumGUIDList(custNumGUIDSet,paramServiceTag[0].accountID);			
			custNumGUIDMap	= doCustNumGuidNameCreation(custNumObjList);
		}
		try{
		if(paramServiceTag != null){
			for(AposServiceTagObj serviceTagRec : paramServiceTag){
				Contract_Information__c newContractInfo = new Contract_Information__c(Account__c=serviceTagRec.accountID,Customer_Number__c=serviceTagRec.customerNumber, CustomerNumber_LK__c=custNumGUIDMap.get(serviceTagRec.customerNumber),
																					 service_tag__c=serviceTagRec.serviceTagNumber, domain_name__c=serviceTagRec.domainName,
																					 service_contract_type__c=servicetagRec.serviceContractType, Service_Contract_Expiration_Date__c=servicetagRec.expirationDate,
																					Opportunity__c=paramRsObj.opptyId);
				contractCreationList.add(newContractInfo);
																									 
				
			}
		}
		
		if(contractCreationList.size()>0){
			insert contractCreationList;
		}
						
		return paramRsObj;
		}
		catch(System.DmlException e){
			paramRsObj.errorCode = AposConstants.ERROR_SERVICETAG_CONTRACTS_CREATION;
			paramRsObj.errorDesc = AposConstants.ERROR_SERVICETAG_CONTRACTS_CREATION_DESC;
			return paramRsObj;
		}
		
	}
	
	//Set how many customer number object to working on
	public static Set<String> doCustNumListCreation(List<AposServiceTagObj> paramServiceTag){
		Set<String> custNumSet = new Set<String>();
		for(AposServiceTagObj paramServiceTagList : paramServiceTag){
			if(!custNumSet.contains(paramServiceTagList.customerNumber)){
				custNumSet.add(paramServiceTagList.customerNumber);
			}
		}
		return custNumSet;
	}
	
	//Generate Unique Map for Customer number id and name as a reference table of Custom number lookup id 
	public static Map<String,String> doCustNumGuidNameCreation(List<customer_number__c> tempCustNumObjList){
		Map<String,String> retCustNumGuidNameMap = new Map<String,String>();
		
		if(tempCustNumObjList != null && tempCustNumObjList.size()>0){
				for(customer_number__c custNumObj : tempCustNumObjList){
					if(!retCustNumGuidNameMap.containsKey(custNumObj.name)){ //can remove this as using set ?
						retCustNumGuidNameMap.put(custNumObj.name,custNumObj.id);
					}
				}
		}
		
		return retCustNumGuidNameMap;
	}
	
	//Get List of Custom number object via SOQL query
	public static List<customer_number__c> doReturnCustNumGUIDList(Set<String> tempCustNumGUIDSet, String accountId){		
		List<customer_number__c> retCustNumObjList = [SELECT name, id from customer_number__c WHERE name=:tempCustNumGUIDSet AND Account__c=:accountId];		
		return retCustNumObjList;
	}
	
	public static AposResponseObj doGetAccountOwner(AposResponseObj rsObj, AposContactObj paramContact){
		
		if(paramContact!=null && !StringUtils.isBlank(paramContact.accountId) && StringUtils.isBlank(rsObj.errorCode)){
			
			String tempAccountName = '';
			String tempAccountOwner= '';
			
			
			System.debug('paramContact.accountID ===' + paramContact.accountID);
			List<Account> tempAccountList = [Select a.Name , (Select userId From AccountTeamMembers WHERE TeamMemberRole='APOS Inside Sales Rep') From Account a WHERE id=:paramContact.accountID limit 1];
			
			
			
				for(Account acct : tempAccountList){
					tempAccountName = acct.name;
					if(acct.AccountTeamMembers.size() >0){
					for(AccountTeamMember atm: acct.AccountTeamMembers){						
						rsObj.accountOwner =atm.userId; 							
						}
					}else{
						rsObj.errorCode = Aposconstants.ERROR_APOS_INSIDE_REP_NOT_EXIST;
						rsObj.errorDesc = Aposconstants.ERROR_APOS_INSIDE_REP_NOT_EXIST_DESC;
					}			
				}
				
			}		
		
			
		return rsObj;		
	}
	
	//main method to call 
	webservice static AposResponseObj createOpportunity(AposContactObj paramContact, List<AposServiceTagObj> paramServiceTag){
	
		Savepoint sp 		  = null;
		AposResponseObj rsObj = new AposResponseObj();
		
		Boolean isContactExist = isExistingContact(paramContact);
		if(isContactExist){
			rsObj = doUpdateContact(paramContact);
			System.debug('#### Update contact call ###');
		}else{
			rsObj = doCreateContact(paramContact);
			System.debug('#### Create contact call ###');
		}
		
		System.debug('After Create/UpdateContact ==' + rsObj.contactId);
		 System.debug('show error code in rsObj before find apos user==' + rsObj.errorCode);
		//find the user who is 'Apos Inside rep' to hold as account owner
		rsObj = doGetAccountOwner(rsObj, paramContact);
				
			
			//logic to create/update contact will change based on buid 
			//after get the owner, account name, bookdate then start create oppty	 		
			//System.debug('Before AposOpptyObj creation, tempAccountOwner ==' + tempAccountOwner  + ' , paramContact.accountId' + paramContact.accountId);
			
			System.debug('Error code at this stage : '+ rsObj.errorCode);
			
			try{
			sp 		= Database.setSavepoint();	
			if(StringUtils.isBlank(rsObj.errorCode)){
				AposOpportunityObj newOppty = new AposOpportunityObj(rsObj.accountOwner,  paramContact.accountId);				
				rsObj 	= doCreateOpportunity(rsObj,newOppty);	
				System.debug('Contact id in doCreateOppty=='+rsObj.contactId);
				}
			//if oppty create succesfully, then start attach service tag info again
			if(StringUtils.isBlank(rsObj.errorCode)){
				//should it change rsObj.opptyId here, may caused confusion
				System.debug('before doCreateServiceTag ====');
				rsObj	= doCreateServiceTag(rsObj,paramServiceTag);
				System.debug('Contact id in doCreateServiceTag=='+rsObj.contactId);
				System.debug('after doCreateServiceTag ===='); 
			}
			
			//if servicetag and oppty created, Oppty contact role will start create
			if(StringUtils.isBlank(rsObj.errorCode)){
				System.debug('Manged to call into doCreateOppContactRole');
				System.debug('rsObj.opptyId ==' +rsObj.opptyId);
				System.debug('rsObj.contactId ==' +rsObj.contactId);
				rsObj = doCreateOppContactRole(rsObj,rsObj.opptyId,rsObj.contactId);
				System.debug('Manged to go out from  doCreateOppContactRole');
			}
			
			}catch(Exception e){
				 Database.rollback(sp);
			}
												
						 
			return rsObj;
	}

}