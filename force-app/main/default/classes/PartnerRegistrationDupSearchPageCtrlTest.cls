public class PartnerRegistrationDupSearchPageCtrlTest {
	
	
	private static TestMethod void doTestRecordSize(){
		List<Account> accounts = [select name from account limit 100];
		List<Partner_Request__c> pr_accounts = [select name from Partner_Request__c  limit 100];
		PartnerRegistrationDupSearchPageCtrlExt searchCtrl 	= new PartnerRegistrationDupSearchPageCtrlExt();		
		Integer acctSize = accounts.size();
		Integer prAcctSize = pr_accounts.size();
		
		SObjectPaginator tempAcctPaginator = searchCtrl.getAccountPaginator(accounts);
		SObjectPaginator tempPrAcctPaginator = searchCtrl.getPartnerPaginator(pr_accounts);
		
		Integer containerSize = (tempPrAcctPaginator.getPageSize() * tempPrAcctPaginator.pageCount);
					
		System.debug('pageSize>>'+tempPrAcctPaginator.getPageSize());
		System.debug('pageCount>>'+tempPrAcctPaginator.pageCount);
		System.debug('partnerReqs>>'+searchCtrl.partnerReqs.size());
		System.debug('pageCount>>'+tempPrAcctPaginator.pageCount);
		System.debug('containerSize>>'+containerSize);
		
		System.assert(prAcctSize<=containerSize);
		
	} 
	 
}