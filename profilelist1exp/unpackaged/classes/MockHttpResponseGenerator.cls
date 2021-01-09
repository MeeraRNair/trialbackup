@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       // System.assertEquals('https://cs13-api.salesforce.com/services/Soap/u/28.0', req.getEndpoint());
       // System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><loginResponse><result><metadataServerUrl>https://dellapps--corpUAT.cs1.my.salesforce.com/services/Soap/m/28.0/00DS0000003KRDj</metadataServerUrl><passwordExpired>false</passwordExpired><sandbox>true</sandbox><serverUrl>https://dellapps--corpUAT.cs1.my.salesforce.com/services/Soap/u/28.0/00DS0000003KRDj</serverUrl><sessionId>00DS0000003KRDj!ARoAQKzaQySP66LoBGlltfaKV7UOdoZUQT1TJm.KDO6oKYRTArfoz2r.78Yworj7VGaFq_g0m4lRV8IlGym91CWZ2cciFmuN</sessionId><userId>00570000002dEqaAAE</userId><userInfo><accessibilityMode>false</accessibilityMode><currencySymbol>$</currencySymbol><orgAttachmentFileSizeLimit>26214400</orgAttachmentFileSizeLimit><orgDefaultCurrencyIsoCode>USD</orgDefaultCurrencyIsoCode><orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments><orgHasPersonAccounts>false</orgHasPersonAccounts><organizationId>00DS0000003KRDjMAO</organizationId><organizationMultiCurrency>false</organizationMultiCurrency><organizationName>Dell Non-CRM Org</organizationName><profileId>00e7000000141hPAAQ</profileId><roleId>00E700000010UPDEA2</roleId><sessionSecondsValid>14400</sessionSecondsValid><userDefaultCurrencyIsoCode xsi:nil="true"/><userEmail>devika_pujari@dell.com</userEmail><userFullName>SFDC PIMP Integration USER</userFullName><userId>00570000002dEqaAAE</userId><userLanguage>en_US</userLanguage><userLocale>en_US</userLocale><userName>pimp_integuser@dellpmo.com.corpuat</userName><userTimeZone>America/Chicago</userTimeZone><userType>Standard</userType><userUiSkin>Theme3</userUiSkin></userInfo></result></loginResponse></soapenv:Body></soapenv:Envelope>');
        res.setStatusCode(200);
        return res;
    }
}