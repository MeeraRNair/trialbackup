/* Revision  Name            Date                 CR         Release No              Description
* 1.0       Jatin         12.06.2018             16018       FY-19-DCS-0802          Commented NET exam logic statements as part of NET003 story
* 2.0       Vikas KH      04-Dec-2019                           0102                 Implemented TDF


*/

@isTest(SeeAllData=false)
private class AccountSuggestionTest { 
    //Define variables
    static list<Account> listAcc;
    static list<Campaign> listCamp;
    static Country__c testCountry;
    static Partner_Request__c request,updatePartnerRequest;
    static Lead suggestionLead;
    static User userRecord;
    static Sales_Channel_Group__c testSalesChannelRecord;
    static boolean btestDataCreated=false;
    static String strupdatePartnerRecordTypeId =  IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER,'Partner_Request__c', true);
    @testsetup static void setup() {
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF; 
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
    }    
    //TestMethod 1
    public static testMethod void testdatetimeString() {        
        DateTime dttestTime = DateTime.newInstance(1985,02, 22,07, 07, 56);
        String strconvertedString = AccountSuggestion.datetimeString(dttestTime);
        System.assertEquals(strconvertedString, '1985-02-22T07:07:56');
    }
    //TestMethod 2
    public static testMethod void testdateString() {        
        if(btestDataCreated==false)
        {
            createTestData();
            DateTime dttestTime = DateTime.newInstance(1985,02, 22,07, 07, 56);
            String strconvertedString = AccountSuggestion.dateString(dttestTime);
            System.assertEquals(strconvertedString, '02/22/1985');
        }
    }
    /* TEST METHODS RELATED TO CREATE ACCOUNT SUGGESTION  */
    //TestMethod 3
    public static testMethod void testcreateAccountsuggestionHTTPRequestBodyString() {      
        if(btestDataCreated==false)
        {
            createTestData();
            Lead testLead = [SELECT Account__r.Account_ID__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                             Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                             CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                             Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                             NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                             Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                             Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                             Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                             Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                             Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                             Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, Questions_Comments__c, 
                             Retail_Flag__c, Sales_Model_Code__c,  Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c,
                             Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                             Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c    //CR2574
                             FROM Lead WHERE Id =:suggestionLead.Id ];
            String strresult = AccountSuggestion.createAccountsuggestionHTTPRequestBodyString(testLead, 'submit', true);
            System.assert(strresult.contains('<cmi:userDefinedAttributeData>~I~169~Partner~$~I~86~ISG~$~I~88~Tier 1~$~I~89~Registered~$~I~87~Global Alliance~$</cmi:userDefinedAttributeData>'));
        }
    }
    //TestMethod 4
    public static testMethod void testParseResponseString() {      
        String strresponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><cmi:CreateAccountSuggestionResponse xmlns:cmi="http://cmi.us.dell.com"><cmi:CreateAccountSuggestionResult><cmi:OracleError/><cmi:ErrorDescription/><cmi:ID>595977</cmi:ID><cmi:IsAccountDuplicate>true</cmi:IsAccountDuplicate></cmi:CreateAccountSuggestionResult></cmi:CreateAccountSuggestionResponse></soap:Body></soapenv:Envelope>';
        AccountSuggestion.SuggestionResponse suggestionResponse = AccountSuggestion.parseResponseString(strresponse);
        System.assertEquals(suggestionResponse.strID,'595977');
        strresponse = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><cmi:CreateAccountSuggestionResponse xmlns:cmi="http://cmi.us.dell.com"><cmi:CreateAccountSuggestionResult><cmi:OracleError>Oracle Error</cmi:OracleError><cmi:ErrorDescription>Failed</cmi:ErrorDescription><cmi:ID>0</cmi:ID><cmi:IsAccountDuplicate>false</cmi:IsAccountDuplicate></cmi:CreateAccountSuggestionResult></cmi:CreateAccountSuggestionResponse></soap:Body></soapenv:Envelope>';
        suggestionResponse = AccountSuggestion.parseResponseString(strresponse);
        System.assertEquals(suggestionResponse.strOracleError,'Oracle Error');
    }
    //TestMethod 5
    public static testMethod void testSubmitCreateAccountSuggestion() {      
        if(btestDataCreated==false)
        {
            createTestData();
            Lead testLead = [SELECT Account__r.Account_ID__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                             Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                             Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                             Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                             Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, Questions_Comments__c, 
                             Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c,
                             Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                             Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c    //CR2574
                             FROM Lead WHERE Id =:suggestionLead.Id ];
            Test.startTest();
            try{AccountSuggestion.submitAccountSuggestion(testLead, true);}catch (exception e){}
            Test.stopTest();
            system.assertNotEquals(null, Suggestionlead.Postal_Country__c);
        }
    }
    //TestMethod 6
    public static testMethod void testCreateHttpRequestHeader() {       
        if(btestDataCreated==false)
        {
            createTestData();
            AccountSuggestion.strENDPOINT = 'Test';
            AccountSuggestion.strUSERNAME = 'Username';
            AccountSuggestion.strPASSWORD = '';
            AccountSuggestion.bAUTHENTICATIONREQUIRED = true;
            Test.startTest();
            HttpRequest httpRequest = AccountSuggestion.createHttpRequestHeader();
            Test.stopTest();        
            System.assertNotEquals(httpRequest.getHeader('Authorization'), null);
            System.debug('#MN:END of testCreateHttpRequestHeader()');
        }
    }
    //TestMethod 6
    public static testMethod void testSubmitMethodsNullLead() {       
        System.debug('#MN:START of testSubmitMethodsNullLead()'); 
        AccountSuggestion.SuggestionResponse suggestionResponse;    
        Lead testLeadRecord;
        try{
            suggestionResponse = AccountSuggestion.submitAccountSuggestion(testLeadRecord,true);
        }
        Catch(Exception e){
        }   
        System.assertEquals(suggestionResponse.strID,null);
        try{
            suggestionResponse = AccountSuggestion.submitUpdateAccountSuggestion(testLeadRecord);
        }
        Catch(Exception e){
        }
        System.assertEquals(suggestionResponse.strID,null);
    }
    
    /* TEST METHODS RELATED TO UPDATE ACCOUNT SUGGESTION  */
    //TestMethod 7
    public static testMethod void testUpdateAccountsuggestionHTTPRequestBodyString() {      
        System.debug('#MN:START of testUpdateAccountsuggestionHTTPRequestBodyString()');
        if(btestDataCreated==false)
        {
            createTestData();
            Lead testLead = [SELECT Account__r.Account_ID__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                             Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                             CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                             Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                             NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                             Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                             Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                             Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                             Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                             Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                             Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, Questions_Comments__c, 
                             Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c,
                             Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                             Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c    //CR2574
                             FROM Lead WHERE Id =:suggestionLead.Id ];
            String strresult = AccountSuggestion.updateAccountsuggestionHTTPRequestBodyString(testLead);
            System.assert(strresult.contains('<cmi:userDefinedAttributeData>~I~169~Partner~$~I~86~ISG~$~I~88~Tier 1~$~I~89~Registered~$~I~87~Global Alliance~$</cmi:userDefinedAttributeData>'));
        }
    }
    //TestMethod 8
    public static testMethod void testsubmitUpdateAccountSuggestion() {     
        System.debug('#MN:START of testsubmitUpdateAccountSuggestion()');
        AccountSuggestion.SuggestionResponse suggestionResponse;
        if(btestDataCreated==false)
        {
            createTestData();
            Lead testLead = [SELECT Account__r.Account_ID__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                             Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                             CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                             Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                             NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                             Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                             Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                             Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                             Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                             Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                             Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, Questions_Comments__c, 
                             Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, // SIC_code__c, 
                             Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                             Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c    //CR2574
                             FROM Lead WHERE Id =:suggestionLead.Id ];
            try{
                suggestionResponse = AccountSuggestion.submitUpdateAccountSuggestion(testLead);        
            }
            Catch(Exception e){            
            }
            system.assertNotEquals(null, Suggestionlead.Postal_Country__c);
        }
        
    }
    /* TEST METHODS FOR THE LEAD TRIGGER  */    
    //TestMethod 9
    public static testMethod void testUpdateLeadAndPartnerStatusnonApprovedPR() {      
        if(btestDataCreated==false)
        {
            createTestData();       
            suggestionLead.RecordTypeId = IdLookupUtils.getRecordTypeId('Account Suggestion', 'Lead',true);
            Test.startTest();
            try{            
                update suggestionLead;      
            }
            catch(Exception e) {        
                System.assert(e.getMessage().contains('Associated Partner Request is not in Approved status'));
            }
            Test.stopTest();
        }
    }
    //TestMethod 10
    public static testMethod void testUpdateLeadAndPartnerStatusApprovedPR() {
        TriggerExecutionController.setSkipAllTriggers(true);
        if(btestDataCreated==false)
        {
            createTestData();   
            request.status__c = 'Approved';
            update request;     
            suggestionLead.RecordTypeId = IdLookupUtils.getRecordTypeId('Account Suggestion', 'Lead',true); 
            suggestionLead.Account_Owner__c = userRecord.Id;
            Test.startTest();       
            update suggestionLead;      
            Test.stopTest();
            Lead testLead = [SELECT Status, Partner_Request__r.Status__c
                             FROM Lead
                             WHERE Id =:suggestionLead.Id ];     
            System.assertEquals('Draft', testLead.Status);
            System.assertEquals('Lead Draft',testLead.Partner_Request__r.Status__c);
            TriggerExecutionController.setSkipAllTriggers(false);
        }
    }
    //TestMethod 11
    public static testMethod void testUpdateLeadforUpdateAccountSuggestion() {
        TriggerExecutionController.setSkipAllTriggers(true);
        if(btestDataCreated==false)
        {
            createTestData();
            Id rectype = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead',true);   
            Lead testLead = new Lead(Status = 'Open',  Questions_Comments__c = 'Sample Questions And Comments', Date_Founded__c = DateTime.now(), 
                                     Company = 'Test Company', Website = 'Mywebsite', LastName = 'Test', Account__c = listAcc[0].Id, RecordTypeId= rectype,
                                     Account_Owner__c = userRecord.Id);
            insert testLead;        
            testLead.Suggestion_Reason__c = 'Information Change';
            Test.startTest();       
            update testLead;        
            Test.stopTest();
            testLead = [SELECT Status, Partner_Request__r.Status__c
                        FROM Lead
                        WHERE Id =:testLead.Id ];       
            System.assertEquals('Draft', testLead.Status);
            TriggerExecutionController.setSkipAllTriggers(false);
        }   
    }
    /* END OF TEST METHODS FOR THE LEAD TRIGGER  */
    private static void createTestData(){
        //create Account
        listAcc =[select id,name,Account_Country_Code__c, Account_ID__c from Account limit 1 ];
        listAcc[0].Account_Country_Code__c = 'AI';
        listAcc[0].Account_Country__c = 'ANGUILIA';            
        listAcc[0].Account_ID__c = '333333';
        update listAcc;
        //Create country
        testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        //Create User
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        userRecord = new User(
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
            Badge_Number__c='TEST12345',
            Title = 'Test Title'
        );
        insert userRecord;      
        //Create Partner Request
        request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
        request.Org_Country__c = testCountry.id;
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.Org_State__c = 'state';
        request.Org_Postal_Code__c = 'postalcode';      
        request.Address_Line_1__c = 'Address 1';
        request.Address_Line_2__c = 'Address 2';
        request.Address_Line_3__c = 'Address 3';
        request.City__c = 'city';
        request.State__c = 'state';
        request.Postal_Code__c = 'postalcode';
        request.Last_Name__c = 'Test Last Name';
        request.Country__c = testCountry.id;
        request.OwnerId = userRecord.Id;        
        insert request;
        //Create update Partner Request
        updatePartnerRequest = new Partner_Request__c();
        updatePartnerRequest.Account__c = listAcc[0].id;
        updatePartnerRequest.RecordTypeId = strupdatePartnerRecordTypeId;
        updatePartnerRequest.email__c = 'test@dell.com';
        updatePartnerRequest.Status__c ='New'; 
        insert updatePartnerRequest;
        //Create Territorry Assignments
        testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 1', 
             Group_ID__c=''+System.currentTimeMillis());
        insert TestSalesChannelRecord;
        listcamp = [select id from Campaign limit 1];
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id directLeadRT = IdLookupUtils.getRecordTypeId('Account Suggestion Locked', 'Lead', true);
        //Create Lead
        suggestionLead = new Lead(
            Status = 'Open',
            CFI_Project_Numbers__c = 'testPN',
            Questions_Comments__c = 'Sample Questions And Comments',
            Date_Founded__c = DateTime.now(),
            DMU_Flag__c = true,
            FIN_GEO__c = 'Test',
            Fiscal_Year_End__c = DateTime.now(),
            Company = 'Test Company',
            Function_Category_Code__c = 'Air Force Air Station',
            Program_Type__c = 'Test',
            Location_Number__c = 4,
            Marketing_Class_Code__c = 'Defense Army',
            National_ID__c = '344',
            NDA_Expiry_Date__c = DateTime.now(),
            NDA_Flag__c = false,
            Other_Company_Name__c = 'Other Company',
            Website = 'Mywebsite',
            Physical_City__c = 'City',
            Physical_Company_Name__c = 'Name',
            Organization_Country__c = testCountry.id,       
            Physical_Country__c = testCountry.id,
            Physical_County__c = 'Test',
            Physical_PostalCode__c = '3455',
            Physical_State__c = 'City',
            Physical_Address_1__c = 'Add',
            Physical_Address_2__c = 'Add2',
            Physical_suburb__c = 'Suburb',
            Postal_City__c = 'city',
            Postal_Company_Name__c = 'Company',
            Postal_Country__c = testCountry.id,     
            Postal_County__c = 'County',
            Postal_PostalCode__c = '45554',
            Postal_State__c = 'State',
            Postal_Address_1__c = 'Add1',
            Postal_Address_2__c = 'Add2',
            Postal_suburb__c = 'Suburb',
            Premier_Page_URL__c = 'URL',
            Suggestion_Reason__c = 'Reseller',
            Retail_Flag__c = true,
            Sales_Model_Code__c = 'Relationship',
            Std_Quote_Numbers__c = 'Test',
            Sub_Market_Code__c = 'Army',
            Partner_Request__c = request.id,        
            Account_Category__c = 'Partner',
            Partner_Type__c = 'ISG',
            Partner_Class__c = 'Tier 1',        
            Territory_Assignment__c = testSalesChannelRecord.id,
            LastName = 'Test',
            Email = 'phone_email_mobile@eitherOne.com',
            Country = 'US',
            LeadSource = 'Web',
            RecordTypeId = directLeadRT,
            Partner_Status__c = 'Registered',
            //CR2574
            Secondary_Partner_Type_Optional__c = 'Global Alliance');  
        insert suggestionLead;
        btestDataCreated = true;
    }    
    //Added as a part of CR#2570. [Ambily 03-May-2010]
    /* TEST METHODS RELATED TO : public static void updateAccountPartnerRequests(List<Id> partnerRequestIDList) */
    public static testMethod void testupdateAccountPartnerRequests() { 
        Partner_Request__c testPartnerRequest1=new Partner_Request__c(First_Name__c='testPartnerRequest1',Last_Name__c='testAccount1',Email__c='abc@test.com',
                                                                      Job_Title__c='Engineer',State__c='New',Status__c = 'Account Suggestion Submitted',RecordTypeId = strupdatePartnerRecordTypeId);
        Partner_Request__c testPartnerRequest2=new Partner_Request__c(First_Name__c='testPartnerRequest2',Last_Name__c='testAccount2',Email__c='abc@test.com',
                                                                      Job_Title__c='Engineer',State__c='New',Status__c ='Incomplete',RecordTypeId = strupdatePartnerRecordTypeId);
        List<Partner_Request__c> listtestPartnerRequest=new List<Partner_Request__c>();
        listtestPartnerRequest.add(testPartnerRequest1);
        listtestPartnerRequest.add(testPartnerRequest2);
        insert listtestPartnerRequest;
        List<ID> listpartnerRequestId=new List<Id>();
        for(Integer inti=0;inti<listtestPartnerRequest.size();inti++){           
            listpartnerRequestId.add(listtestPartnerRequest[inti].Id);     
        }
        if(listpartnerRequestId.size()>0){      
            AccountSuggestion.updateAccountPartnerRequests(listpartnerRequestId);       
            List<Partner_Request__c> listpartnerRequestTest=[SELECT id,Status__c FROM Partner_Request__c WHERE id IN : listpartnerRequestId];
            System.assertEquals('Account Suggestion Completed', listpartnerRequestTest[0].Status__c);
            System.assertEquals('Incomplete', listpartnerRequestTest[1].Status__c);
        }
    }
    public static testMethod void testupdateAccountPartnerRequestsTrigger() { 
        Partner_Request__c testPartnerRequest1=new Partner_Request__c(First_Name__c='TestFN',Last_Name__c='LN',Email__c='abc@test.com'
                                                                      ,Job_Title__c='Engineer',State__c='New',Status__c = 'Account Suggestion Submitted',
                                                                      RecordTypeId = strupdatePartnerRecordTypeId );
        insert testPartnerRequest1;
        listAcc =[select id,name,Legacy_ID__c from Account limit 1 ];
        listAcc[0].Legacy_ID__c = 'SFDC_' + testPartnerRequest1.Id;
        Test.startTest();
        update listAcc;        
        Test.stopTest();
        testPartnerRequest1 = [SELECT id,Status__c FROM Partner_Request__c WHERE id =:testPartnerRequest1.Id LIMIT 1];      
        System.assertNotEquals(Null, testPartnerRequest1.Status__c); 
    }
    //TestMethod 13
    public static testMethod void testgetCountryRegion() {    
        if(btestDataCreated==false)
        {
            createTestData();
            System.assertEquals('APJ', AccountSuggestion.getCountryRegion('TY'));
        }   
    }
    //TestMethod 14
    public static testMethod void testsendSelfServiceAccountUpdateSuggestion() {      
        if(btestDataCreated==false)
        {
            createTestData();
            Map<String,String> mapparam = new Map<String,String>{ 'suggestionTypeId' => '103', 'partyId' => '234563', 
                'orgGroupName' => 'Test Partner Account - Ray', 'orgGroupNickName' => 'Doing Business As', 'orgGroupCountryCode' => 'TY', 
                'physicalCompanyName' => 'Test Partner Account - Ray', 'physicalStreetAddr1' => 'Organization Address 1', 
                'physicalStreetAddr2' => 'Organization Address 2, Organization Address 3', 'physicalCity' => 'City', 
                'physicalState' => 'State / Province', 'physicalPostalCode' => '3214323', 'employeesize' => '0' };
                    Test.startTest();
            AccountSuggestion.sendSelfServiceAccountUpdateSuggestion(updatePartnerRequest.Id,Mapparam);
            Test.stopTest();
            //no callout from test method so sets Incomplete
            System.assertEquals('Incomplete',[SELECT id,Status__c FROM Partner_Request__c WHERE id = :updatePartnerRequest.Id LIMIT 1].Status__c);
        }
    }
}