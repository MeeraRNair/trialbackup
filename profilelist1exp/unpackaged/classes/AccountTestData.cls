/*
 * Author   : Ragu
 * Purpose  : Utility test class for creating Account related data. 
 *
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 11967	16.10       23-Sep-2015     Ragu            Created.
 * 
 */

@isTest
public class AccountTestData {

	public static boolean bCreate = true;
	public static integer iNumberOfAccounts = 5;
	public static list<Account> lstAccounts;
	
    public static testMethod void createEndUserAccount() {
        populateCommonAccountFields();
        Id endUserRTId = StaticFactory.getRecordTypeIdByName('Account', 'End-User Account');
        for(Account accIterator : lstAccounts) {
        	accIterator.RecordTypeId = endUserRTId;
        	accIterator.Type = 'End User';
        }
        if(bCreate) {
        	insert lstAccounts;
        }
    }
    
    public static testMethod void createPartnerAccount() {
       	populateCommonAccountFields();
        Id partnerRTId = StaticFactory.getRecordTypeIdByName('Account', 'Partner Account');
        for(Account accIterator : lstAccounts) {
        	accIterator.RecordTypeId = partnerRTId;
        	accIterator.Type = 'Partner';
        }
        if(bCreate) {
        	insert lstAccounts;
        }
    }
    
    private static testMethod void populateCommonAccountFields() {
    	lstAccounts = new list<Account>();
    	for(integer i=0; i<iNumberOfAccounts; i++) {
    		Account accIterator = new Account();
    		accIterator.Name = 'AccountTestData_' + i;
			
            lstAccounts.add(accIterator);
    	}
    }

}