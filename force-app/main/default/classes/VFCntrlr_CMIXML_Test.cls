/*********************************************************************************************************************************
REVISION HISTORY
================
Version     Author        Date            Release#    CR#     Description
-------     ------        ----            --------    ---     -----------
1.0      Krishnamoorthi  14-Dec-2012    	14.2      7679    Created for - R14.2 Maintenance apex class VFCntrlr_CMIXML

***********************************************************************************************************************************/
@isTest
private class VFCntrlr_CMIXML_Test {
	static Account testAccount;
	static Account testAccount1;
    static Contact testContact; 
    static Contact testContact1;
    
    static testMethod void conIdCMITest() {
    	
    	createdata();
      	PageReference  pr=new PageReference('apex/CMI_XML');
        Test.setCurrentPage(pr);
        VFCntrlr_CMIXML cntrlr = new VFCntrlr_CMIXML();
		
		cntrlr.inputValue = testContact.Id;
		cntrlr.inputValue = testContact1.Id;
		cntrlr.sendHttpRequest();
		
    }
    
    static testMethod void emailCMITest() {
    	
    	createdata();
    	PageReference  pr=new PageReference('apex/CMI_XML');
        Test.setCurrentPage(pr);
        VFCntrlr_CMIXML cntrlr = new VFCntrlr_CMIXML();
        
        cntrlr.inputValue = testContact.Email;
        cntrlr.sendHttpRequest();
    	
    }
    
     static testMethod void GUIDCMITest() {
    	
    	createdata();
    	PageReference  pr=new PageReference('apex/CMI_XML');
        Test.setCurrentPage(pr);
        VFCntrlr_CMIXML cntrlr = new VFCntrlr_CMIXML();
        
        cntrlr.inputValue = testContact.Partner_My_Account_GUID__c;
        cntrlr.sendHttpRequest();
    	
    }
    
    static testMethod void blankCMITest() {
    	
    	createdata();
    	PageReference  pr=new PageReference('apex/CMI_XML');
        Test.setCurrentPage(pr);
        VFCntrlr_CMIXML cntrlr = new VFCntrlr_CMIXML();
        
        cntrlr.inputValue = '';
        cntrlr.sendHttpRequest();
    	
    }
    
    public static void createdata(){
    	
    	testAccount = new Account (name='Test Account', Account_ID__c = '2151111656');
      	insert  testAccount;
      	
      	testAccount.IsPartner=true;
      	update testAccount;
      	
      	testAccount1 = new Account (name='Test Account1');
      	insert  testAccount1;
      
      	testContact = new Contact (AccountId=testAccount.Id, FirstName = 'Con', LastName = 'Test', Phone='3213213211', Email='test@dell.com', Partner_My_Account_GUID__c = '0d37f1ab-c49b-4c11-9d1d-45acd229a989');
      	insert  testContact;
      	
      	testContact1 = new Contact (AccountId=testAccount1.Id, FirstName = 'Con', LastName = 'Test1', Phone='3353213211', Email='test1@dell.com', Partner_My_Account_GUID__c = '0d37f1ab-c49b-4c11-9d1d-43rcd229a989');
      	insert  testContact1;
    	
    }
}