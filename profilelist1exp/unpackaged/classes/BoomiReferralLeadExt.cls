public class BoomiReferralLeadExt {

	public String searchString 					{get;set;}
	public String accountId    					{get;set;}
	public String accountName    				{get;set;}
	public String created  	  					{get;set;}
	public String newid							{get;set;}
			
	public SObjectPaginator contactPaginator 	{get;set;}
	public List<Contact> contactList 			{get;set;}
	public List<Contact> contactPaginationList	{get;set;}
	public Account account 			 			{get;set;}
	
	public Boolean getShowErrorMsg() 			{return StringUtils.isBlank(accountId);}
	public Boolean getShowCreateButton() 		{return ((StringUtils.isBlank(created))&& !(StringUtils.equalsIgnoreCase(created,'true')));}	
	
	public Account accountObj;
	
	public Referral_Lead__c referralLead;
							   

	public BoomiReferralLeadExt(ApexPages.Standardcontroller c){
        
        accountId = ApexPages.currentPage().getParameters().get('accountId');       
        created = ApexPages.currentPage().getParameters().get('created');
        newid = ApexPages.currentPage().getParameters().get('newid');
      
       
        if(StringUtils.isBlank(accountId)){
            PageUtils.addError(System.Label.Boomi_NoAccount_Error);                                              
            return;
         }
             
    }
	
	public PageReference doPageLoad(){		
		doSearch();
		return null;
	}
	
	
	public PageReference doSearch(){
		BoomiContactPaginationCtrlExt PaginatorCtrl = new BoomiContactPaginationCtrlExt();
		
		List<Account> accountList = doQueryContactSearch();
					
		for(Account acct : accountList){
			contactList = acct.contacts;
			accountName = acct.name;
			System.debug('Account id='+ acct.id + ' with size='+ contactList.size());
		}
			
		contactPaginator 							= PaginatorCtrl.getContactPaginator(contactList);			
		contactPaginationList						= PaginatorCtrl.contacts;
		
		
		return null;
	}
	
	public List<Account> doQueryContactSearch(){
				
		String soql = ' SELECT id, name, (SELECT id,Phone, MobilePhone ,Name, Email,Account.name FROM Contacts WHERE id NOT IN (SELECT Contact__c FROM Referral_Lead__c WHERE Account__c=:accountId) ' + ' ORDER BY ' + (StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? 'CreatedDate DESC':'name') + ' LIMIT 1000) FROM Account WHERE id=:accountId limit 1';
		System.debug('soql='+soql);		
		List<Account> searchAccountList = Database.query(soql);
		  
		return searchAccountList;
	} 
	
	public Pagereference doCreateContact(){
		PageReference newContactView = new PageReference('/apex/contactDupeChecker?accountId=' + accountId +  ('&saveURL=/apex/BoomiContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&created=true')) + ('&retURL=/apex/BoomiContactSearch?accountName='+PageUtils.encodeVariable(accountName + '&accountId='+ accountId ))); 						
		return newContactView;
	}
	
	public PageReference doSelectContact(){
		String contactID = ApexPages.currentPage().getParameters().get('linkcontactID');	
		String contactName = ApexPages.currentPage().getParameters().get('linkcontactName');
		Id boomiLeadRecTypeId = IdLookupUtils.getRecordTypeId('Boomi Lead', 
                                                        'Referral_Lead__c', true);	
                                                        
		System.debug('id boomiLeadRecTypeId :' + boomiLeadRecTypeId);
		System.debug('String id boomiLeadRecTypeId :' + String.valueOf(boomiLeadRecTypeId));                                                          
		System.debug('Contact name ='+contactID);							
		String urlStr = '/'+ PageUtils.getSObjectPath('Referral_lead__c') +'/e' + '?CF00NA00000063PC4_lkid=' + contactID +'&CF00NA00000063PC4=' + contactName +'&CF00NA00000063PBw=' + accountName + '&CF00NA00000063PBw_lkid='+ accountId +'&RecordType='+ boomiLeadRecTypeId +'&retURL=/apex/BoomiContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + (StringUtils.isNotBlank(created) && StringUtils.containsIgnoreCase('true', created)? '&created=true':''));		
		
		PageReference referralLeadPage = new PageReference(urlStr);
		return referralLeadPage;
	}
	
	public PageReference doCancel(){		
		return PageUtils.redirect('/' + accountId);
	}
	
}