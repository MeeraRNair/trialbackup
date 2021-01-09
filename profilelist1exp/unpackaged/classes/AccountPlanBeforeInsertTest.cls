/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountPlanBeforeInsertTest {
	
	static User userRecord1;
    static Account testEUAccount;
    static SFDC_Acct_Plan__c testAccountPlan1;
	static SFDC_Acct_Plan__c testAccountPlan2;
	
    static testMethod void Test_AccountPlanInsert() {
    	
    	TestDataCreation();
        // TO DO: implement unit test
    }
    
    static void TestDataCreation(){
		List<User> userList = new List<User>();
		
     	//Create a user with Standard User profile     	
     	Profile profile = [select id from profile where Name = 'System Administrator' limit 1];
     	
		for (integer i=0; i< 2; i++) {     	
     		User userRecord = new User(Username='testvaliduser2'+i+ System.currentTimeMillis()+'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test212'+'@dell.com',            
                                    LastName='Test22',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Country='US',
                                    Badge_Number__c='Test'+i+System.currentTimeMillis());
			userList.add(userRecord);
		}
        insert userList;

                
        //Create Account using the user profile
        System.runAs(userList[0]){
        	testEUAccount = new Account(Name='Test EU Account for Account Plan Test',Type = 'End User',
                                                Participating_in_LOB_Program__c = true,
                                                OwnerId = userList[0].Id);
        	insert testEUAccount;
        	
        	//Create Account Plan for the Account
        	//Creating new Account Plan
			testAccountPlan1 = new SFDC_Acct_Plan__c(name='TestPlan01',Account__c= testEUAccount.Id,Plan_Starting_Fiscal_Year__c='FY12', Sales_Manager__c = userList[1].Id);
        	insert testAccountPlan1;
        	
        	try {
	        	testAccountPlan2 = new SFDC_Acct_Plan__c(name='TestPlan02',Account__c= testEUAccount.Id,Plan_Starting_Fiscal_Year__c='FY12', Sales_Manager__c = userList[1].Id);
	        	insert testAccountPlan2;
        	}
        	catch (System.Dmlexception e) {        		
        		System.assert(e.getMessage().contains('An account plan already exists for the financial year for this account. Please save a different financial year, or edit the existing account plan.'));
        	}
        }
        
        
        
        
     }
}