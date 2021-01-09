/***********************************************************
    * Name          : VFcntrl_SearchEndCustomerFromDnBTest
    * Description   : Test Class for VFcntrl_SearchEndCustomerFromDnB class
    * ---------------------------------------------------------
    * Revision     Name            Date             Description
    * 1.0         Yeswanth     25. july. 2016    Test Class for VFcntrl_SearchEndCustomerFromDnB class
************************************************************/
@isTest
public class VFcntrl_SearchEndCustomerFromDnBTestDupe{
    
    // Method to cover success scenario
    static testmethod void testMethod1(){
        
     Country__c country = new Country__c(Name='United States',Code__c='US',DNB_COUNTRY_CODE__c ='805',DNB_ISO_country_code__c ='US',DNB_Region__c = 'AMER');
     insert country;
        
            PageReference pageRef = Page.searchEndCustomerFromDnB;
            Test.setCurrentPage(pageRef);

            VFcntrl_SearchEndCustomerFromDnB DnBController = new VFcntrl_SearchEndCustomerFromDnB();
            DnBController.onPageLoad();
            DnBController.useOriginalAddress();
            DnBCOntroller.getEndCustomer();
            DnBCOntroller.searchDnB();
            DnBController.EndCustomer.name = 'BMW';
            DnBController.EndCustomer.Mailing_country__c = 'United States';
            StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
            mockResponse.setStaticResource('DnB_response_body_staticresource');
            mockResponse.setStatusCode(200);
            mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponse);
            DnBCOntroller.searchDnB();
            Test.stopTest();
            DnBCOntroller.getshowResultBlock();
            DnBCOntroller.getshowResultTable();
          DnBCOntroller.getItems();
           // DnBCOntroller.reset();
           // DnBCOntroller.cancel();

    }
    
    // Method to cover exception scenarios
    static testmethod void testmethod2(){
                
     Country__c country = new Country__c(Name='United States',Code__c='US',DNB_COUNTRY_CODE__c ='805',DNB_ISO_country_code__c ='US',DNB_Region__c = 'AMER');
     insert country;
        
            PageReference pageRef = Page.searchEndCustomerFromDnB;
            Test.setCurrentPage(pageRef);

            VFcntrl_SearchEndCustomerFromDnB DnBController = new VFcntrl_SearchEndCustomerFromDnB();
            DnBController.onPageLoad();       
            DnBController.EndCustomer.name = 'BMW';
            DnBController.EndCustomer.Mailing_country__c = 'United States';
            StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
            mockResponse.setStaticResource('DnB_response_body_staticresource_exception');
            mockResponse.setStatusCode(200);
            mockresponse.setStatus('Internal Failure');
            mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponse);
            DnBCOntroller.searchDnB();
            Test.stopTest();       
    }
    
    
    // Method to cover success scenario 1
    static testmethod void testMethod3(){
     
     Country__c country = new Country__c(Name='United States',Code__c='US',DNB_COUNTRY_CODE__c ='805',DNB_ISO_country_code__c ='US',DNB_Region__c = 'AMER');
     insert country;
        
            PageReference pageRef = Page.searchEndCustomerFromDnB;
            Test.setCurrentPage(pageRef);

            VFcntrl_SearchEndCustomerFromDnB DnBController = new VFcntrl_SearchEndCustomerFromDnB();
            DnBController.onPageLoad();
            DnBController.useOriginalAddress();
            DnBCOntroller.getEndCustomer();
            DnBCOntroller.searchDnB();
            DnBController.EndCustomer.name = 'BMW';
            DnBController.EndCustomer.Mailing_country__c = 'United States';
            StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
            mockResponse.setStaticResource('DnB_response_body_staticresource_Sce1');
            mockResponse.setStatusCode(200);
            mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mockResponse);
            DnBCOntroller.searchDnB();
            Test.stopTest();
            DnBCOntroller.getshowResultBlock();
            DnBCOntroller.getshowResultTable();
           // DnBCOntroller.reset();
           // DnBCOntroller.cancel();
        
            
    }
    
}