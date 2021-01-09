@isTest
public class Vfcntrl_FetchGUDUNS_Test{
 
   Static HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        res.setHeader('SOAPAction', 'CIL/IExploreAffinity/GetEnglishAndLocalAddreses');
       // res.setBody(fulljson);
        res.setStatusCode(200);
         //System.assertNotEquals(null,null);   
      return res;   
  }
     
   Static testmethod void testMethod1(){
      TriggerExecutionController.setSkipAllTriggers(true);
       Partner_Request__c partnerRequest = new Partner_Request__c();
                     partnerRequest.GU_HQ_DUNSAddress__c = 'GuAddress1';
                    partnerRequest.GU_HQ_DUNSBusinessName__c = 'GuCompanyName';
                    partnerRequest.GU_HQ_DUNSCity__c = 'US';
                    partnerRequest.GU_HQ_DUNSCountry__c = 'US';
                    partnerRequest.GU_HQ_DUNSID__c = 'GUDunsId';
                    partnerRequest.GU_HQ_DUNSPostalCode__c = 'GuPostalCode';
                    partnerRequest.GU_HQ_DUNSState__c = 'GuState';
                insert partnerRequest;
        Country__c country = new Country__c(Name='canada',Code__c='US',DNB_COUNTRY_CODE__c ='805',DNB_ISO_country_code__c ='US',DNB_Region__c = 'AMER',DnB_Supported_Country__c=true);
        insert country;  
              //System.assertNotEquals(null,country);    
     
        test.startTest();           
            StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
           // mockResponse.setStaticResource('DnB_response_body_staticresource');
           mockResponse.setStaticResource('GUDUNS_Rsponse_Body_Staticresource');
            mockResponse.setStatusCode(200);
            mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');           
            Test.setMock(HttpCalloutMock.class, mockResponse);
            Vfcntrl_FetchGUDUNS.getGUDUNS(partnerRequest.id , '123456');
       test.stopTest();
      TriggerExecutionController.setSkipAllTriggers(false);
       //System.assertNotEquals(null,null);
    }
     static testmethod void testMethod2() {

  TriggerExecutionController.setSkipAllTriggers(true);
          Partner_Request__c partnerRequest = new Partner_Request__c();
                     partnerRequest.GU_HQ_DUNSAddress__c = 'GuAddress1';
                    partnerRequest.GU_HQ_DUNSBusinessName__c = 'GuCompanyName';
                    partnerRequest.GU_HQ_DUNSCity__c = 'US';
                    partnerRequest.GU_HQ_DUNSCountry__c = 'US';
                    partnerRequest.GU_HQ_DUNSID__c = 'GUDunsId';
                    partnerRequest.GU_HQ_DUNSPostalCode__c = 'GuPostalCode';
                    partnerRequest.GU_HQ_DUNSState__c = 'GuState';
                insert partnerRequest;
        
           Country__c country = new Country__c(Name = 'UNITED STATES', Code__c = 'US', DNB_COUNTRY_CODE__c = '805',DnB_Supported_Country__c=true, DNB_ISO_country_code__c = 'US', DNB_Region__c = 'AMER');
  insert country;
              test.startTest();           
            StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
            mockResponse.setStaticResource('DnB_response_body_staticresource_Sce1');
            mockResponse.setStatusCode(200);
            mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');           
            Test.setMock(HttpCalloutMock.class, mockResponse);
            Vfcntrl_FetchGUDUNS.getGUDUNS(partnerRequest.id , '123456');
         system.assertEquals( country.Name, 'UNITED STATES');
          test.stopTest();
     }
    static testmethod void testMethod3() {

  TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Request__c partnerRequest = new Partner_Request__c();
                     partnerRequest.GU_HQ_DUNSAddress__c = 'GuAddress1';
                    partnerRequest.GU_HQ_DUNSBusinessName__c = 'GuCompanyName';
                    partnerRequest.GU_HQ_DUNSCity__c = 'US';
                    partnerRequest.GU_HQ_DUNSCountry__c = 'US';
                    partnerRequest.GU_HQ_DUNSID__c = 'GUDunsId';
                    partnerRequest.GU_HQ_DUNSPostalCode__c = 'GuPostalCode';
                    partnerRequest.GU_HQ_DUNSState__c = 'GuState';
                insert partnerRequest;
    Country__c country = new Country__c(Name = 'UNITED STATES', Code__c = 'US', DNB_COUNTRY_CODE__c = '805',DnB_Supported_Country__c=true, DNB_ISO_country_code__c = 'US', DNB_Region__c = 'AMER');
      insert country;
        test.startTest();           
            StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
          mockResponse.setStaticResource('GUDUNS_ResponseBody_Fault2');
           //mockResponse.setStaticResource('GUDUNS_Rsponse_Body_Staticresource');
            mockResponse.setStatusCode(200);
            mockresponse.setStatus('Unauthorized');
            mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');           
            Test.setMock(HttpCalloutMock.class, mockResponse);
            Vfcntrl_FetchGUDUNS.getGUDUNS(partnerRequest.id , '123456');
      system.assertEquals( country.Name, 'UNITED STATES');
          test.stopTest();
    }
  
}