@isTest
private class emailUtilsTest {

	private static boolean isExceptionThrow = false;
	
	// Test Condition:
	// 1 recipient, text message
    static testMethod void sendSupportEmail_SingleRecipientTextMail() {
        system.debug('##### Start sendSupportEmail_SingleRecipientTextMail #####');
        
        try {
        	emailUtils.sendSupportEmail('Test method', 'alou@salesforce.com');
        }
        catch (Exception e) {
        	isExceptionThrow = true;
        }
        system.assertEquals(false, isExceptionThrow);
        system.debug('##### End sendSupportEmail_SingleRecipientTextMail #####');
    } 
    
    // Test Condition:
	// >1 recipient, text message
    static testMethod void sendSupportEmails_MultipleRecipientTextMail() {
        system.debug('##### Start sendSupportEmails_MultipleRecipientTextMail #####');
        
        try {
			List<String> recepients=new String[]{'meera.rnair@ust-global.com','Krishnaprasad.Palamangalam@ust-global.com'};
	        emailUtils.sendSupportEmails('Test method', recepients);
        }
        catch (Exception e) {
        	isExceptionThrow = true;
        }
        system.assertEquals(false, isExceptionThrow);        
        system.debug('##### End sendSupportEmails_MultipleRecipientTextMail #####');
    } 
    
    // Test Condition:
	// >1 recipient, subject, text message
    static testMethod void sendTextEmail_MultipleRecipientTextMailWithSubject() {
        system.debug('##### Start sendTextEmail_MultipleRecipientTextMailWithSubject #####');
        
        try {
	        List<String> recepients=new String[]{'meera.rnair@ust-global.com','Krishnaprasad.Palamangalam@ust-global.com'};
	        emailUtils.sendTextEmail(recepients,'Test method', 'This is to test the sendTextNotificationEmail method');
        }
        catch (Exception e) {
        	isExceptionThrow = true;
        }
        system.assertEquals(false, isExceptionThrow);
        system.debug('##### End sendTextEmail_MultipleRecipientTextMailWithSubject #####');
    } 
}