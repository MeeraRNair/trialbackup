public class VFCntrlr_SyncAccountToPartnerProfile {

    public String accountId;
    List<String> accountIdList;
    
    public VFCntrlr_SyncAccountToPartnerProfile(ApexPages.StandardController controller) {
        this.accountId = controller.getRecord().Id;

        accountIdList = new List<String>();
        
        accountIdList.add(accountId);        
    }

	public void integratePartnerData() {
		PartnerProfileIntegration.integratePartnerData(accountIdList);		
	}
    
	static TestMethod void test_initializeController() {
           
        VFCntrlr_SyncAccountToPartnerProfile controller;
                    
        System.debug('DEBUG: ***************** START test_initializeController *****************');
        
		//Creating new Acccount
        Account acct = new Account(name='TestMethodAccount01');
        insert acct;

        System.debug('DEBUG: ACCOUNT ID = ' + acct.Id);
         
        PageReference pr = Page.SyncAccountToPartnerProfile;
        
        Test.setCurrentPage(pr);
        
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());        
        
        //Testing initialization with a valid 'id'
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', acct.Id); 
        System.debug('###DEBUG### currentUrl=' + ApexPages.currentPage().getURL());
        System.assert(ApexPages.currentPage().getURL().toLowerCase().contains('/apex/syncaccounttopartnerprofile?id='+String.valueOf(acct.id).toLowerCase()));
        
        controller = new VFCntrlr_SyncAccountToPartnerProfile(new ApexPages.StandardController(acct) ); 
        controller.integratePartnerData();
		//future method, nothing to assert
        
        
    }
}