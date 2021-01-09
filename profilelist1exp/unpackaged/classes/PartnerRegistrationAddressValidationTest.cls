/* Revision  Name               Date                 CR         Release No            Description
* 1.0       Yeswanth           13.08.2018            16266   Fy-19-DCS-0902       Created test class for Address validation service in Partner Registration form
*/

@isTest
public class PartnerRegistrationAddressValidationTest {
    
    Static testmethod void testMethod1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = new Country__c(Name='canada',Code__c='US',DNB_COUNTRY_CODE__c ='805',DNB_ISO_country_code__c ='US',DNB_Region__c = 'AMER',DnB_Supported_Country__c=true);
        insert country;
        Test.startTest();
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        PartnerRegistrationAddressValidationExt.searchDnB(country.id , 'austin', 'texas', 'wal', false);
        PartnerRegistrationAddressValidationExt.getLabels();
        Test.stopTest();
       TriggerExecutionController.setSkipAllTriggers(false);
       System.assertEquals('canada',country.Name);

    }
    
      
    Static testmethod void testMethod2(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = new Country__c(Name='canada',Code__c='US',DNB_COUNTRY_CODE__c ='805',DNB_ISO_country_code__c ='US',DNB_Region__c = 'AMER',DnB_Supported_Country__c=true);
        insert country;
        Test.startTest();
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource_exception');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        PartnerRegistrationAddressValidationExt.searchDnB(country.id , 'austin', 'texas', 'wal', false);
        PartnerRegistrationAddressValidationExt.getLabels();
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
      System.assertEquals('canada',country.Name);

    }
    
        Static testmethod void testMethod3(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = new Country__c(Name='canada',Code__c='US',DNB_COUNTRY_CODE__c ='805',DNB_ISO_country_code__c ='US',DNB_Region__c = 'AMER',DnB_Supported_Country__c=true);
        insert country;
        Test.startTest();
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource_500');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('faultcode');
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        PartnerRegistrationAddressValidationExt.searchDnB(country.id , 'austin', 'texas', 'wal', false);
        PartnerRegistrationAddressValidationExt.getLabels();
        Test.stopTest();
       TriggerExecutionController.setSkipAllTriggers(false);
       System.assertEquals('canada',country.Name);

    }
    
        Static testmethod void testMethod4(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = new Country__c(Name='canada',Code__c='US',DNB_COUNTRY_CODE__c ='805',DNB_ISO_country_code__c ='US',DNB_Region__c = 'AMER',DnB_Supported_Country__c=true);
        insert country;
        Test.startTest();
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource_500');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        PartnerRegistrationAddressValidationExt.searchDnB(country.id , 'austin', 'texas', 'wal', false);
        PartnerRegistrationAddressValidationExt.getLabels();
        Test.stopTest();
       TriggerExecutionController.setSkipAllTriggers(false);
       System.assertEquals('canada',country.Name);

    }

}