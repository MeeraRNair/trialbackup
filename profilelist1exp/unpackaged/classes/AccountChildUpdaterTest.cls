/*
 * Author   : Ragu
 * Purpose  : To test AccountChildUpdater class. 
 *
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12369    16.12       16-Dec-2015     Ragu            Defect 216660 - Created.
 * 
 */
 
@isTest
private class AccountChildUpdaterTest {

    static testMethod void test_populateRADCode() {
       	TriggerExecutionController.setSkipAllTriggers(true);
    	AccountTestData.iNumberOfAccounts = 1;
	  	AccountTestData.createEndUserAccount();
	  	list<Account> lstAccounts = AccountTestData.lstAccounts;
	  	
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstDirectLeads2 = LeadTestData.lstLeads;
        
        lstDirectLeads2[0].Account__c = lstAccounts[0].Id;
        Database.insert(lstDirectLeads2);
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        //Start Test
 		Test.startTest();
		
		lstAccounts[0].RAD_Code__c = '1234';
        Database.update(lstAccounts);
        
        Test.stopTest();
    }
    
}