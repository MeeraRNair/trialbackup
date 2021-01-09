public class BoomiReferralLeadExtTest {

	private static testmethod void doCreateAccount(){
		String accountName  = '';
		String accountId    = '';
		
		Map<String, String> sParams;

		//Create Account
		sParams = new Map<String, String>();
		sParams.put('str_name', 'Test Account');
		Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
		sParams.clear();	
		
		accountId = testAcc.id;
		
		//Create contact
		 List<Contact> contactList=new List<Contact>();
		 
            for(integer count=0;count<5;count++){
                Contact newContact=new Contact(Status__c='Active', AccountId=testAcc.Id, 
                                    EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                    firstname='Test'+count,MobilePhone='111-1000', Decision_Making_Role__c='Influencer', LastName='TestContact0367');
                contactList.add(newContact);
            }
         
         insert contactList;

		ApexPages.currentPage().getParameters().put('accountid', accountId);
		
		ApexPages.StandardController controller = new ApexPages.StandardController(testAcc);
		BoomiReferralLeadExt boomiExt = new BoomiReferralLeadExt(controller);
	 	PageReference pgSearch = boomiExt.doPageLoad();
	 	
	 	System.assertEquals(false,boomiExt.getShowErrorMsg());
	 	
		//test Pagination	    
         BoomiContactPaginationCtrlExt PaginatorCtrl = new BoomiContactPaginationCtrlExt();
         List<Contact> contactPaginationList         = new List<Contact>(); 
         SObjectPaginator contactPaginator = new SObjectPaginator();
         
         List<Account> accountList = boomiExt.doQueryContactSearch();
					
		 for(Account acct : accountList){
			contactList = acct.contacts;
			accountName = acct.name;
			System.debug('Account id='+ acct.id + ' with size='+ contactList.size());
		}
			
		contactPaginator 							= PaginatorCtrl.getContactPaginator(contactList);			
		contactPaginationList						= PaginatorCtrl.contacts;
		
		system.assertEquals(contactPaginationList.size(),5);
		
		//test create contact
		PageReference newContactView = new PageReference('/apex/contactDupeChecker?accountId=' + accountId +  ('&saveURL=/apex/BoomiContactSearch?accountName='+PageUtils.encodeVariable(accountName+ '&accountId='+ accountId + '&created=true')) + ('&retURL=/apex/BoomiContactSearch?accountName='+PageUtils.encodeVariable(accountName + '&accountId='+ accountId )));
		
		system.debug('newContactView URL='+newContactView.getUrl());
		system.debug('doCreateContact URL='+boomiExt.doCreateContact().getUrl());
		
		
		system.assertEquals(newContactView.getUrl(), boomiExt.doCreateContact().getUrl());
		
		PageReference pgCancel = new PageReference('/'+testAcc.id); 
		system.assertEquals(pgCancel.getUrl(), boomiExt.doCancel().getUrl());
	}
}