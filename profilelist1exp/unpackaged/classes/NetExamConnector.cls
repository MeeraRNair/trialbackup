/***********************************************************
* Name          : NetExamConector
* ---------------------------------------------------------
* Revision      Release          Name           Date              Description   
* 1.0           FY18-DCS-1001    Syidah         22 Aug 2017       Replace hardcoded URL to fetch current environment host URL
************************************************************/

public class NetExamConnector {
    
    public static final string NETEXAM_API_ENDPOINT = 'https://salesforce.admin.netexam.com/API' + (Environment.isSandbox() ? 'TEST' : '') + '/';
      //1.0
    static string BASE_URL_FOR_CURRENT_ENVIRONMENT = URL.getSalesforceBaseUrl().toExternalForm();
    //public static final string SALESFORCE_API_URL = 'https://' + (Environment.isProduction() ? 'na7' : 'cs9') + '.salesforce.com/services/Soap/c/9.0/' + Environment.getShortOrgId();
    public static final string SALESFORCE_API_URL = BASE_URL_FOR_CURRENT_ENVIRONMENT + '/services/Soap/c/9.0/' + Environment.getShortOrgId();
    
    // lookup contact and associated account and send to NetExam
    public static List<String> sendContactWithAccount(String contactId, String username) {
        // get contact info
        Contact[] contactRecord = getContactInfo(contactId);
        
        // grab the associated user as well, if one exists
        User[] userRecord = getUserInfo(contactId);

        // process and send account
        Account[] accountRecord = getAccountInfo(contactRecord[0].AccountId);
        if (!Test.isRunningTest()){
        String accountSendResult = sendAccount(accountRecord);
        handleResponseText(accountSendResult);

        // process and send contact
        String contactSendResult = sendContact(accountRecord, contactRecord, userRecord, username);        
        handleResponseText(contactSendResult);
        }
       
        
        // buildResponse                
        return responseMessages;
    }
    
    //replace Partner Admin value before send to NetExam
    public static List<String> sendContactWithAccount(String contactId, String username, Boolean partnerAdminUser) {
        // get contact info
        Contact[] contactRecord = getContactInfo(contactId);
        
        // grab the associated user as well, if one exists
        User[] userRecord = getUserInfo(contactId);
        // override value from input parameter
        if(userRecord != null && userRecord.size() == 1) {
            userRecord[0].Enable_Partner_Admin__c = partnerAdminUser;
        }
        
        // process and send account
        Account[] accountRecord = getAccountInfo(contactRecord[0].AccountId);
        if (!Test.isRunningTest()){
            String accountSendResult = sendAccount(accountRecord);
            handleResponseText(accountSendResult);
    
            // process and send contact
            String contactSendResult = sendContact(accountRecord, contactRecord, userRecord, username);        
            handleResponseText(contactSendResult);
        }
        
        // buildResponse                
        return responseMessages;
    }
    
    public static String sendAccount(Account[] accountRecord) {
        // serialize user info into format used by form post body 
        String accountFormBody = serializeAccountToFormBody(accountRecord[0]);
        
        // setup request
        HttpRequest req = buildWebServiceRequest();
        
        // setup/send account request
        req.setBody(accountFormBody);
        HTTPResponse res = invokeWebService(new Http(), req);
        
        return res.getBody();
    }
    
    public static String sendContact(Account[] accountRecord, Contact[] contactRecord, User[] userRecord, String username) {
        // serialize user info into format used by form post body 
        String contactFormBody = serializeContactToFormBody(accountRecord[0], contactRecord[0], userRecord, username);
        
        // setup request
        HttpRequest req = buildWebServiceRequest();
        
        // setup/send account request
        req.setBody(contactFormBody);
        HTTPResponse res = invokeWebService(new Http(), req);
        
        return res.getBody();
    }
    
    private static List<String> responseMessages = new List<String>();
    
    public static void handleResponseText(string responseText) {
        // grab and normalize response 
        if(responseText.length() > 0) {
            responseText = responseText.trim();
            if (responseText.toLowerCase() != 'success') {    
                if (responseText == 'No Server URL Supplied') { throw new NetExamNoServerUrlException(responseText); }
                else if (responseText == 'No Session ID Supplied') { throw new NetExamNoSessionIdException(responseText); }
                else if (responseText == 'No Access to API') { throw new NetExamNoAccessToApiException(responseText); }
                else if (responseText == 'No Secure Socket Layer') { throw new NetExamNoSslException(responseText); }
                else if (responseText == 'Action Not Supported') { throw new NetExamActionNotSupportedException(responseText); }
                else if (responseText == 'Malformed XML') { throw new NetExamMalformedXmlException(responseText); }
                else if (responseText == 'No corresponding NetExam account found. Please create a NetExam account if you have not done so') { throw new NetExamAccountNotFoundException(responseText); }
                else if (responseText == 'Invalid Key') { throw new NetExamInvalidKeyException(responseText); }
                else if (responseText == 'User External ID is Empty') { throw new NetExamExternalIdEmptyException(responseText); }
                else if (responseText == 'User First Name is Empty') { throw new NetExamFirstNameEmptyException(responseText); }
                else if (responseText == 'User Last Name is Empty') { throw new NetExamLastNameEmptyException(responseText); }
                else if (responseText == 'User Email is Empty') { throw new NetExamEmailEmptyException(responseText); }
                else if (responseText == 'This Contact must be associated with an Account before sending to NetExam') { throw new NetExamNoAssociatedAccountException(responseText); }
                else if (responseText == 'User Group Name is Empty') { throw new NetExamUserGroupNameEmptyException(responseText); }
                else if (responseText == 'The NetExam account has not been setup or correctly configured.') { throw new NetExamAccountNotSetupException(responseText); }
                else if (responseText == 'Account not found. Please send Account first before sending this Contact.') { throw new NetExamAccountNotFoundException(responseText); }
                else if (responseText == 'Email already exists. Please select a different email address') { throw new NetExamEmailExistsException(responseText); }
                else if (responseText == 'Username already exists. Please select a different username') { throw new NetExamUsernameExistsException(responseText); }
                else { throw new NetExamException(responseText); }
            }
        }
    }
        
    // setup HTTPRequest Method
    public static HttpRequest buildWebServiceRequest() {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(NETEXAM_API_ENDPOINT);
        
        return req;
    }    
    
    public static HttpResponse invokeWebService(Http http, HttpRequest req) {
        System.debug('Calling out to NetExam: ' + req.toString() + '\nBody: ' + req.getBody());
        HttpResponse res = http.send(req);
        System.debug('Received response from NetExam: ' + res.toString() + '\nBody: ' + req.getBody());
        return res;
    }
    
    // pulls info for contact based on contact id
    public static Contact[] getContactInfo(string contactId) {
        // lookup contact
        Contact[] contact = [
            select 
                Id, Email, FirstName, LastName, MailingCity, MailingCountry, MailingPostalCode, 
                MailingState, MailingStreet, OtherCity, OtherCountry, OtherPhone, OtherPostalCode, 
                OtherState, OtherStreet, Phone, AccountId 
            from Contact where Id= :contactId
        ];
        
        return contact;
    }
    
    // pulls info for user based on contact id
    public static User[] getUserInfo(string contactId) {
        // lookup user
        User[] user = [
            select 
                Id, City, Country, Email, Firstname, Lastname, Phone, 
                Postalcode, State, Street, TimezoneSidKey, LanguageLocaleKey, 
                Enable_Partner_Admin__c 
            from User where contactId= :contactId
        ];
        
        return user;        
    }
        
    // pulls info for account based on account id
    public static Account[] getAccountInfo(string accountId) {
        // lookup account
        Account[] account = [
            select 
                Id, Name, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, Phone,
                Account_Country_Code__c
            from Account where Id= :accountId
        ];
        
        return account;
    }
 
    // simple utility method for apply a default to a value   
    public static string applyDefault(string fieldVal, string defaultVal) {
        if(fieldVal == null) {
            return defaultVal;
        } else {
            return fieldVal;
        }
    }
    
    // build out url encoded string for use as form body
    public static string serializeContactToFormBody (Account account, Contact contact, User[] user, String username) {
        string formBody = '';
        formBody += 'action=UserAddEdit';
        formBody += '&type=User';
        formBody += '&Country=' + applyDefault(account.Account_Country_Code__c ,'');
        formBody += '&ExternalId=' + applyDefault(contact.Id,'');
        formBody += '&Id=' + applyDefault(contact.Id,'');
        formBody += '&AccountId=' + applyDefault(account.Id,'');
        formBody += '&Email=' + applyDefault(contact.Email,'');
        formBody += '&FirstName=' + applyDefault(contact.FirstName,'');
        formBody += '&LastName=' + applyDefault(contact.LastName,'');
                
        formBody += '&MailingCity=' + applyDefault(contact.MailingCity,'');
        formBody += '&MailingCountry=' + applyDefault(contact.MailingCountry,'');
        formBody += '&MailingPostalCode=' + applyDefault(contact.MailingPostalCode,'');
        formBody += '&MailingState=' + applyDefault(contact.MailingState,'');
        formBody += '&MailingStreet=' + applyDefault(contact.MailingStreet,'');

        formBody += '&OtherCity=' + applyDefault(contact.OtherCity,'');
        formBody += '&OtherCountry=' + applyDefault(contact.OtherCountry,'');
        formBody += '&OtherPhone=' + applyDefault(contact.OtherPhone,'');
        formBody += '&OtherPostalCode=' + applyDefault(contact.OtherPostalCode,'');
        formBody += '&OtherState=' + applyDefault(contact.OtherState,'');
        formBody += '&OtherStreet=' + applyDefault(contact.OtherStreet,'');

        formBody += '&Phone=' + applyDefault(contact.Phone,'');
        formBody += '&UserGroupExternalID=' + applyDefault(contact.AccountId,'');
        
        formBody += '&sessionID=' + Userinfo.getSessionId();        
        formBody += '&serverUrl=' + SALESFORCE_API_URL;
        
        // add in username
        if(StringUtils.isNotBlank(username)) {
            formBody += '&username=' + username;
        }
        
        // if we have user info, apply it
        if(user != null && user.size() == 1) {
            formBody += '&City=' + applyDefault(user[0].City ,'');
            formBody += '&PostalCode=' + applyDefault(user[0].PostalCode ,'');
            formBody += '&State=' + applyDefault(user[0].State ,'');
            formBody += '&Street=' + applyDefault(user[0].Street ,'');
            formBody += '&TimezoneSidKey=' + applyDefault(user[0].TimezoneSidKey ,'');
            formBody += '&LanguageLocaleKey=' + applyDefault(user[0].LanguageLocaleKey ,'');
            formBody += '&lang=' + applyDefault(user[0].LanguageLocaleKey ,'');
            formBody += '&PartnerAdminUser=' + user[0].Enable_Partner_Admin__c;
        }
        
        return formBody;
    }
    
    // build out url encoded string for use as form body
    public static string serializeAccountToFormBody (Account account) {
        string formBody = '';
        formBody += 'action=UserGroupAddEdit';
        formBody += '&type=Account';
        formBody += '&Id=' + applyDefault(account.Id,'');
        formBody += '&ExternalID=' + applyDefault(account.Id,'');
        formBody += '&UserGroupExternalId=' + applyDefault(account.Id,'');
        formBody += '&IsoCountry=' + applyDefault(account.Account_Country_Code__c,'');
        formBody += '&Country=' + applyDefault(account.Account_Country_Code__c,'');
        
        formBody += '&BillingCity=' + applyDefault(account.BillingCity,'');
        formBody += '&BillingCountry=' + applyDefault(account.BillingCountry,'');
        formBody += '&BillingPostalCode=' + applyDefault(account.BillingPostalCode,'');
        formBody += '&BillingState=' + applyDefault(account.BillingState,'');
        formBody += '&BillingStreet=' + applyDefault(account.BillingStreet,'');
        
        formBody += '&ShippingCity=' + applyDefault(account.ShippingCity,'');
        formBody += '&ShippingCountry=' + applyDefault(account.ShippingCountry,'');
        formBody += '&ShippingPostalCode=' + applyDefault(account.ShippingPostalCode,'');
        formBody += '&ShippingState=' + applyDefault(account.ShippingState,'');
        formBody += '&ShippingStreet=' + applyDefault(account.ShippingStreet,'');
        
        formBody += '&Name=' + applyDefault(account.Name,'');
        formBody += '&Phone=' + applyDefault(account.Phone,'');
        
        formBody += '&UserGroupName=' + applyDefault(account.Name,'');
        formBody += '&sessionID=' + Userinfo.getSessionId();        
        formBody += '&serverUrl=' + SALESFORCE_API_URL;
        
        return formBody;
    }
    
}