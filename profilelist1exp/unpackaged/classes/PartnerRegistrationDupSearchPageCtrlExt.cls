global class PartnerRegistrationDupSearchPageCtrlExt  {
	
	private static FINAL Integer PAGESIZE = 25;
	
	global List<Account> accounts {get;private set;}
	global SObjectPaginator acctPaginator {get;private set;}
	
	global List<Partner_Request__c> partnerReqs {get;private set;}
	global SObjectPaginator prPaginator {get;private set;}
	
	
	global PartnerRegistrationDupSearchPageCtrlExt(){
		accounts = new List<Account>();
		partnerReqs = new List<Partner_Request__c>();
		this.AcctPaginator = new SObjectPaginator(PAGESIZE,new AccountListListener(this));
		this.prPaginator = new  SObjectPaginator(PAGESIZE,new PartnerReqListListener(this));
	}
		
	global void setAccountRecords(List<Account> accounts){
		this.AcctPaginator.setRecords(accounts);
	}
	
	global void setPartnerRecords(List<Partner_Request__c> partners){
		this.prPaginator.setRecords(partners);
	}
	
	global class AccountListListener implements SObjectPaginatorListener {
		private PartnerRegistrationDupSearchPageCtrlExt controller;
		global AccountListListener(PartnerRegistrationDupSearchPageCtrlExt controller){
			this.controller = controller;
		}
		global void handlePageChange(List<SObject> newPage){
			controller.handleAccountListPageChange(newPage);
		}
	}
	
	global class PartnerReqListListener implements SObjectPaginatorListener {
		private PartnerRegistrationDupSearchPageCtrlExt controller;
		global PartnerReqListListener(PartnerRegistrationDupSearchPageCtrlExt controller){
			this.controller = controller;
		}
		global void handlePageChange(List<SObject> newPage){
			controller.handlePartnerReqListPageChange(newPage);
		}
	}
	
	global void handleAccountListPageChange(List<SObject> newPage){
		accounts.clear();
		if(newPage != null){
			for(SObject acct : newPage){
				accounts.add((Account)acct);
			}
		}
	}
	
	global void handlePartnerReqListPageChange(List<SObject> newPage){
		partnerReqs.clear();
		if(newPage != null){
			for(SObject pr : newPage){
				partnerReqs.add((Partner_Request__c)pr);
			}
		}
	}

	global SObjectPaginator getAccountPaginator(List<Account> accounts){
		setAccountRecords(accounts);
		return this.AcctPaginator;
	}
	
	global SObjectPaginator getPartnerPaginator(List<Partner_Request__c> partners){
		setPartnerRecords(partners);
		return this.prPaginator;
	}	
	
}