/*
Description: To initialize global variables
	
Version: 1.1

Author: Caleb Sidel/Christophe Pebre

History:
	1.0 - 17-oct-2007: Creation, to be released in 8.3
	1.1 - 15-nov-2007: Add apexUserName, to be released in 8.3

*/

global class dellConfig {
	
	// For Dellplay
	//public static Boolean inProduction = false;
	//public static String webMethodsName = 'integration_user@dell.com.dellplay';
	//public static String apexUserName = 'apex_user@dell.com.dellplay';
	//public static String errorEmail = 'csidel@salesforce.com';


	// For DIT
	//public static Boolean inProduction = true;
	//public static String webMethodsName = 'integration_user@dell.com.dit';
	//public static String apexUserName = 'apex_user@dell.com.dit';
	//public static String errorEmail = 'csidel@salesforce.com';

	// For SIT
	//public static Boolean inProduction = true;
	//public static String webMethodsName = 'integration_user@dell.com.sit';
	//public static String apexUserName = 'apex_user@dell.com.sit';
	//public static String errorEmail = 'csidel@salesforce.com';

	// For Prod	
	public static Boolean inProduction = true;
	public static String webMethodsName = 'integration_user@dell.com';
	public static String apexUserName = 'apex_user@dell.com';
	public static String errorEmail = 'sfdc_integration@dell.com';
	
	// If the owner is changed to the 'Glbl Data Admin' a user in the system we do NOT want to 
	// update the Account Team.
	// The reason for this is that there are workflows in the system that will 
	// update an Account to be owned by the 'Glbl Data Admin' if the Account is Inactive. 
	// If the Account is Inactive we don't care about it.
	public static String glblDataAdminName = 'Glbl Data Admin';
	public static ID glblDataAdminGUID = '00530000000nY2dAAE'; 

	static testMethod void myTest() {
		// Unit test
		System.assertEquals('integration_user@dell.com', webMethodsName);
		System.assertEquals('Glbl Data Admin', glblDataAdminName);
	}
	
}