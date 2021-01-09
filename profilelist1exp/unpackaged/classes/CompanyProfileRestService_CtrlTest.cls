@isTest(seeAllData=False)
public with sharing class CompanyProfileRestService_CtrlTest{

   @testSetup 
    static void setup() {
        
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        User userRecord = new User(
            Username='testUser'+System.currentTimeMillis()+'@test.com',
            Alias = 'test', 
            Email='test@dell.com', 
            FirstName='Tfirst',
            LastName='TLast',
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='2283881'
        );
        insert userRecord; 
        
        Campaign campaignObj=new Campaign(Name='Campaign',
                                          Campaign_Objective__c='Acquisition/Site Development',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Total_Targets__c = 12.0,  
                                          IsActive = true,
                                          Partner_event_or_campaign__c = true);
        insert campaignObj;  
        
        partner_request__c request = new partner_request__c();
        request.Last_Name__c='pr last';
        request.Company__c='pr last';
        request.OwnerID=userRecord.Id; 
        request.email__c = 'test@test.com';
        insert request;
        Lead suggestionLead = new Lead();
        suggestionLead.LastName = request.Last_Name__c;
        suggestionLead.Company = request.Company__c;
        suggestionLead.Status = 'Open';
        suggestionLead.Universal_Customer_ID_UCID__c='232323';
        suggestionLead.Partner_Request__c = request.ID;
        System.debug('####request.OwnerID'+request.OwnerID);
        suggestionLead.OwnerID = request.OwnerID;
        suggestionLead.Email = 'test@test.com';
        suggestionLead.MobilePhone = '21441242421'; 
        suggestionLead.Fax = '3737433'; 
        suggestionLead.Lead_Type__c = 'Inbound';
        suggestionLead.Country_Code__c = 'US';
        suggestionLead.Website = 'www.testing.com';
        suggestionLead.Account_Owner__c = userRecord.Id;
        suggestionLead.DMU_Flag__c = true;
        suggestionLead.Campaign__c=campaignObj.id;
        suggestionLead.Location_Number__c=23;
        suggestionLead.LeadSource='Web';
        suggestionLead.Suggestion_ID__c='123456789'; 
        suggestionLead.Partner_User__c= userRecord.Id;
        suggestionLead.Dell_Partner_can_contact_me__c = false;
        
        insert suggestionLead;
        system.runAs(userRecord){                              
            request.Lead__c=suggestionLead.Id;
            update request;
        }
        
  }       
 
                
 static testMethod void mockreq(){
     
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
     mock.setStaticResource('mockResponse');
     mock.setStatusCode(201);
     mock.setHeader('Content-Type', 'application/json');
     
     partner_request__c PR = [select id from partner_request__c where Last_Name__c = 'pr last' limit 1];
         
     Test.startTest();                       
     ApexPages.StandardController sc = new ApexPages.StandardController(PR);
     CompanyProfileRestService_Ctrl ser=new CompanyProfileRestService_Ctrl(sc); 
     ser.strCompleteFlag = 'true';                           
     Test.setMock(HttpCalloutMock.class, mock);
     ser.companyProfileWebservice();
     ser.goBacktoPRPage();
     Test.stopTest();     
   }
 
static testMethod void mockreq1(){
     
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
     mock.setStaticResource('mockResponse');
     mock.setStatusCode(302);
     mock.setHeader('Content-Type', 'application/json');
     
     partner_request__c PR = [select id from partner_request__c where Last_Name__c = 'pr last' limit 1];
         
     Test.startTest();                       
     ApexPages.StandardController sc = new ApexPages.StandardController(PR);
     CompanyProfileRestService_Ctrl ser=new CompanyProfileRestService_Ctrl(sc); 
     ser.strCompleteFlag = 'true';                           
     Test.setMock(HttpCalloutMock.class, mock);
     ser.companyProfileWebservice();
     ser.goBacktoPRPage();
     Test.stopTest();     
   }
   
 static testMethod void mockreq2(){
     
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
     mock.setStaticResource('mockResponse');
     mock.setStatusCode(424);
     mock.setHeader('Content-Type', 'application/json');
     
     partner_request__c PR = [select id from partner_request__c where Last_Name__c = 'pr last' limit 1];
         
     Test.startTest();                       
     ApexPages.StandardController sc = new ApexPages.StandardController(PR);
     CompanyProfileRestService_Ctrl ser=new CompanyProfileRestService_Ctrl(sc); 
     ser.strCompleteFlag = 'true';                           
     Test.setMock(HttpCalloutMock.class, mock);
     ser.companyProfileWebservice();
     ser.goBacktoPRPage();
     Test.stopTest();     
   }
   
  static testMethod void mockreq3(){
     
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
     mock.setStaticResource('mockResponse');
     mock.setStatusCode(500);
     mock.setHeader('Content-Type', 'application/json');
     
     partner_request__c PR = [select id from partner_request__c where Last_Name__c = 'pr last' limit 1];
         
     Test.startTest();                       
     ApexPages.StandardController sc = new ApexPages.StandardController(PR);
     CompanyProfileRestService_Ctrl ser=new CompanyProfileRestService_Ctrl(sc); 
     ser.strCompleteFlag = 'true';                           
     Test.setMock(HttpCalloutMock.class, mock);
     ser.companyProfileWebservice();
     ser.goBacktoPRPage();
     Test.stopTest();     
   }
   
   static testMethod void mockreq4(){
     
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
     mock.setStaticResource('mockResponse');
     mock.setStatusCode(404);
     mock.setHeader('Content-Type', 'application/json');
     
     partner_request__c PR = [select id from partner_request__c where Last_Name__c = 'pr last' limit 1];
         
     Test.startTest();                       
     ApexPages.StandardController sc = new ApexPages.StandardController(PR);
     CompanyProfileRestService_Ctrl ser=new CompanyProfileRestService_Ctrl(sc); 
     ser.strCompleteFlag = 'true';                           
     Test.setMock(HttpCalloutMock.class, mock);
     ser.companyProfileWebservice();
     ser.goBacktoPRPage();
     Test.stopTest();     
   }
}