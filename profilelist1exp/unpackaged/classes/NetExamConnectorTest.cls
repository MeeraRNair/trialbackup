/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class NetExamConnectorTest {
    
    
    static testMethod void testGetInfoMethods () {
        
        // grab a test contact id
        Contact[] testContact  = getTestContactRecord();
        String contactId = testContact[0].Id;
        
        // get contact info
        System.debug('Getting needed contact info');
        Contact[] contactInfo = NetExamConnector.getContactInfo( contactId );
        
        // this should always be a single contact record
        System.assertEquals( contactInfo.size(), 1);
        
        User[] userInfo = NetExamConnector.getUserInfo( contactId );
        
        // this may or may not have a single record but no more than 1
        System.assert( userInfo.size() <= 1 );
        
    }
    
    static testMethod void testApplyDefault(){
        
        string testVar;
        string resultString;
        
        // should return the default value
        resultString = NetExamConnector.applyDefault(testVar, 'default_value');
        System.assertEquals(resultString, 'default_value');
        
        // should return the value
        testVar = 'specified_value';
        resultString = NetExamConnector.applyDefault(testVar, 'default_value');
        System.assertEquals(resultString, 'specified_value');
        
    }
    
    static testMethod void testWebserviceMethods(){
        
        HttpRequest req = NetExamConnector.buildWebServiceRequest();
        
        // represents the body of the response returned from the web service 
        String responseBody;
        
        System.debug('attempting to handle empty response');
        responseBody = '';
        NetExamConnector.handleResponseText(responseBody);
        
        System.debug('attempting to handle success response');
        responseBody = 'success';
        NetExamConnector.handleResponseText(responseBody);
        
        System.debug('attempting to handle other response');
        responseBody = 'This user must first be associated with an account';
        try{ NetExamConnector.handleResponseText(responseBody); }
        catch(NetexamException e){ }
        
    }
    
    static testMethod void testSendAccount () {
        
        // grab a test contact id
        Account[] testAccount  = getTestAccountRecord();
        String accountId = testAccount[0].Id;
        
        // get account info
        System.debug('Getting account info');
        Account[] accountInfo = NetExamConnector.getAccountInfo( accountId );
        
        // this should always be a single account record
        System.assertEquals( accountInfo.size(), 1);
        
        System.assert( accountInfo[0].Name.length() > 0 );
        
        
        HttpRequest req = NetExamConnector.buildWebServiceRequest();
        
        // represents the body of the response returned from the web service 
        String responseBody;
        
        System.debug('attempting to handle empty response');
        responseBody = '';
        NetExamConnector.handleResponseText(responseBody);
        
        System.debug('attempting to handle success response');
        responseBody = 'success';
        NetExamConnector.handleResponseText(responseBody);
        
        System.debug('attempting to handle other response');
        responseBody = 'This user must first be associated with an account';
        try{ NetExamConnector.handleResponseText(responseBody); }
        catch(NetexamException e){ }        
    }
    
    static testMethod User[] getTestUserRecord () {
        
        User[] userRecord = [
            select 
                Id, City, Country, Email, Firstname, Lastname, Phone, 
                Postalcode, State, Street, TimezoneSidKey, LanguageLocaleKey,
                Enable_Partner_Admin__c 
            from User
            limit 1
        ];
        
        return userRecord;
        
    }
    
    static testMethod Contact[] getTestContactRecord () {

        Contact[] contactRecord = [
            select 
                Id, Email, FirstName, LastName, MailingCity, MailingCountry, MailingPostalCode, 
                MailingState, MailingStreet, OtherCity, OtherCountry, OtherPhone, OtherPostalCode, 
                OtherState, OtherStreet, Phone, AccountId 
            from Contact
            limit 1
        ];
        
        return contactRecord;
        
    }
    
    static testMethod Account[] getTestAccountRecord () {

        Account[] accountRecord = [
            select 
                Id, Name, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, Phone
            from Account 
            limit 1
        ];
        
        return accountRecord;
        
    }
    
    static testMethod void testSerializeMethods () {   
        
        Contact[] contactInfo = getTestContactRecord();
                
        String accountId = contactInfo[0].AccountId;
        
        Account[] accountInfo = NetExamConnector.getAccountInfo( accountId );

        User[] userInfo = getTestUserRecord();        
        
        String username = 'testusername14890419j41jf0j09j092f089gh08fh840238h0fh4284hf0hf409hf029hf0';
        
        string serializedContact = NetExamConnector.serializeContactToFormBody( accountInfo[0], contactInfo[0], userInfo, username );
        
        string serializedAccount = NetExamConnector.serializeAccountToFormBody( accountInfo[0] );
        
    }
    
    static testMethod void testSendContactWithAccount () {
    
        Test.startTest();
       
        // grab a test contact id
        Contact[] testContact  = getTestContactRecord();
        String contactId = testContact[0].Id;
         
        // set test userid value
        String username = 'testusername14890419j41jf0j09j092f089gh08fh840238h0fh4284hf0hf409hf029hf0';
        
        List<String> resultMessages = NetExamConnector.sendContactWithAccount( contactId, username );
        System.debug( resultMessages.size() );
        
        Test.stopTest();
         
    }   
    
    static testMethod void testSendContactWithAccountAndPartnerAdmin () {      
        // grab a test contact id
        Contact[] testContact  = getTestContactRecord();
        String contactId = testContact[0].Id;
         
        // set test userid value
        String username = 'testusername14890419j41jf0j09j092f089gh08fh840238h0fh4284hf0hf409hf029hf0';
        
        List<String> resultMessages = NetExamConnector.sendContactWithAccount( contactId, username, true );
        System.debug( resultMessages.size() );
    }

}