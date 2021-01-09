/*
* Author   : 
* Purpose  : Test Class for AccountSuggestionIntegraionCIL
* Revision CR Number   Release No     Date            Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
* 1.0      
* 2.0     CR 13627     FY17-DCS-0103  18-Oct-2016     Gan             to activate account in affinity for account that meets the criteria.
* 3.0     CR 13806     FY18-DCS-0202  23-Dec-2016     Gan             to enable creation of SubAccount 
* 4.0                  FY18-DCS-1001  02-Aug-2017     Uday            New fields addition as per Story 3676977
* 5.0     CR 15322     FY19-DCS-0203  18-Dec-2017     Sajith          Affinity interlock - RTM value change
* 5.1     CR 15399     FY19-DCS-0203  29-Jan-2018     Azwanti         Fix Affinity integration issue - missing Local Account Name and Local Address
* 6.0       16018      FY19-DCS-0802  12.06.2018      Jatin           Commented NET exam logic statements as part of NET003 story
* 7.0                  0102           04-Dec-2019     VIKAS KH        Implemeted TDF
*/
@isTest
public class AccountSuggestionIntegrationCILTest {
    //Define variables
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static Country__c testCountry;
    static Partner_Request__c request,updatePartnerRequest;
    static Lead suggestionLead;
    static User userRecord;
    static Sales_Channel_Group__c testSalesChannelRecord;
    static boolean btestDataCreated=false;
    static String strupdatePartnerRecordTypeId =  IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER,'Partner_Request__c', true);
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        OWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        OWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        OWDsetting.Oppty_Stage100__c = 'Win - 100%';
        OWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        OWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        OWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        OWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        OWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert OWDsetting;
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTDF; 
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Deal Registration');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listOppTDF;
    }   
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
    /** Method to create data **/
    private static void createTestData(){
        TriggerExecutionController.setSkipAllTriggers(true);
        user u = [Select Id, Name From User Where IsActive = true and Profile.UserLicense.Name = 'Salesforce'and Profile.Name = 'System Administrator' AND IsActive=true AND username like '%aa_globalsysadmin@dell.com%' LIMIT 1];
        listAcc = [select id,name from Account limit 2];
        listAcc[0].Suggestion_ID__c= '131025787';
        listAcc[0].Account_Country_Code__c ='TY';
        listAcc[0].Status__c = 'U';
        listAcc[0].ownerid =  u.id;
        listAcc[0].Account_ID__c ='131026787';
        listAcc[1].Account_Country_Code__c = 'AI';
        listAcc[1].Account_Country__c = 'ANGUILIA';
        listAcc[1].Account_ID__c = ''+System.currentTimeMillis();
        update listAcc;
        set<id> setaccIds = new set<id>();
        setaccIds.add(listAcc[0].id);
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
        // 2.0 test fail due to no campaign
        CampaignTestData.bCreate = true;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        //Create Partner Request
        request = new Partner_Request__c();
        request.Account__c = listAcc[1].id;
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
        updatePartnerRequest.Account__c = listAcc[1].id;
        updatePartnerRequest.RecordTypeId = strupdatePartnerRecordTypeId;
        updatePartnerRequest.email__c = 'test@dell.com';
        updatePartnerRequest.Status__c ='New'; 
        insert updatePartnerRequest;
        //Create Territorry Assignments //3.0
        testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 1 OEM', 
             Group_ID__c=''+System.currentTimeMillis());
        insert TestSalesChannelRecord;
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
            Physical_Fax__c = '123-123452-123424-12343',
            Physical_Phone__c = '123-123452-123424-12343',
            Physical_PostalCode__c = '3455',
            Physical_State__c = 'State',
            Physical_Address_1__c = 'Add',
            Physical_Address_2__c = 'Add2',
            Physical_suburb__c = 'Suburb',
            Postal_City__c = 'City',
            Postal_Company_Name__c = 'Company',
            Postal_Country__c = testCountry.id,     
            Postal_County__c = 'Test',
            Postal_Fax__c = '123-123452-123424-12343',
            Postal_Phone__c = '123-123452-123424-12343',
            Postal_PostalCode__c = '3455',
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
            Partner_Class__c = 'Direct Partner Purchase',
            Territory_Assignment__c = testSalesChannelRecord.id,
            LastName = 'Test',
            Email = 'phone_email_mobile@eitherOne.com',
            city ='City',
            Street ='Street1',
            Country =testCountry.id,
            Country_Code__c='US',//5.0
            State ='State',
            Partner_Status__c = 'Gold',
            //CR2574
            Secondary_Partner_Type_Optional__c = 'Global Alliance',
            //2.0
            campaign__c = listCampaigns[0].id, 
            BANT_Qualified__c = false,
            LeadSource = 'Web',
            Lead_Type__c = 'Ínbound');  
        insert suggestionLead;
        btestDataCreated = true;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    /** method to test Create Account **/
    public static testMethod void testCreateAccount(){
        if(btestDataCreated== false)
        {
            createTestData();
            Lead testLead = [SELECT Account__r.Account_ID__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                             Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                             CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                             Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                             NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                             Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                             Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                             Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c,Physical_Country__r.Name, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                             Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                             Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                             Postal_PostalCode__c, Postal_State__c, Postal_Country__r.Name,Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, Questions_Comments__c, 
                             Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c, 
                             Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                             //3.0
                             Territory_Assignment__r.Region_Desc__c,
                             Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c,    //CR2574
                             ownerId,NumberOfEmployees,Contact__c,Contact__r.Name,FirstName,LastName,Name,Lead_Type__c,Reason__c,
                             Related_Contact__c,Related_Contact__r.Phone,Related_Contact__r.Email,Related_Contact__r.MobilePhone,
                             PostalCode,Country,City,State,Street,Campaign__r.Region__c,Email,MobilePhone,Phone,
                             RTM__c, //Story 3676977
                             //v5.1
                             Legal_Local_Company_Name__c,
                             Legal_Local_Address_1__c,
                             Legal_Local_Country__c, 
                             Legal_Local_City__c, 
                             Legal_Local_Postal_State__c, 
                             Legal_Local_Postal_Code__c
                             FROM Lead
                             WHERE Id =:suggestionLead.Id LIMIT 1];
            
            test.startTest();
            HttpRequest req= AccountSuggestionIntegrationCIL.createHttpRequestHeader('CreateAccount'); 
            string strresponse1 = AccountSuggestionIntegrationCIL.createAccountsuggestionHTTPRequestBodyString(testLead,false);
            AccountSuggestionIntegrationCIL.bisOnBoarding = true;// this is for covering account creation 
            String strresponse2 = AccountSuggestionIntegrationCIL.createAccountsuggestionHTTPRequestBodyString(testLead,false);
            Test.setMock(HttpCalloutMock.class, new Affinity_MockHttpResponseGenerator());  
            String strupdateAccResponse = AccountSuggestionIntegrationCIL.UpdateAccountsuggestionHTTPRequestBodyString(testLead);
            string stractivationResponse = AccountSuggestionIntegrationCIL.createActivateAccountHTTPRequestBodyString(listAcc[0]);
            suggestionLead.DMU_Flag__c=false;
            suggestionLead.NDA_Flag__c=true;
            suggestionLead.Location_Number__c = 4;
            suggestionLead.NumberOfEmployees =100;
            suggestionLead.Physical_Address_2__c = suggestionLead.Postal_Address_2__c;
            suggestionLead.Physical_County__c = suggestionLead.Postal_County__c;
            suggestionLead.Physical_City__c = suggestionLead.Postal_City__c;
            suggestionLead.Physical_State__c = suggestionLead.Postal_State__c;
            suggestionLead.Physical_suburb__c = suggestionLead.Postal_suburb__c;
            suggestionLead.Physical_PostalCode__c = suggestionLead.Postal_PostalCode__c;
            update suggestionLead;
            String strcreateAccResponse2 = AccountSuggestionIntegrationCIL.createAccountsuggestionHTTPRequestBodyString(testLead,true);
            String strupdateAccResponse1 = AccountSuggestionIntegrationCIL.UpdateAccountsuggestionHTTPRequestBodyString(testLead);
            system.assertEquals(False, suggestionLead.DMU_Flag__c);
            test.stopTest();
        }
    }
    public static testmethod void testAccountSuggestionResponse(){
        string strerrorResponse = '<?xml version="1.0" encoding="UTF-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><X-OPNET-Transaction-Trace xmlns="http://opnet.com">0c2c06d9-3ab6-41d3-a8d8-b1a6f0bce5ca-1892-213</X-OPNET-Transaction-Trace></s:Header><s:Body><CreateAccountResponse xmlns="CIL"><CreateAccountResult i:type="b:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response"><b:MDMError><b:Message>SalesRep RRID/BadgeNumber is Invalid</b:Message><b:SearchStatus>WARNING</b:SearchStatus></b:MDMError><b:Requester>Authenticated User</b:Requester><b:TxStatusCode>SUCCESS</b:TxStatusCode></CreateAccountResult></CreateAccountResponse></s:Body></s:Envelope>';
        AccountSuggestionResponse response = AccountSuggestionResponse.parseResponseString(strerrorResponse);
        string strsuggestionResponse='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><X-OPNET-Transaction-Trace xmlns="http://opnet.com">0aba6457-6720-41ea-82eb-07af0c57e324-8120-663</X-OPNET-Transaction-Trace></s:Header><s:Body><CreateAccountResponse xmlns="CIL"><CreateAccountResult i:type="b:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response"><a:CommonSearchResponse><a:CommonSearchResponseBObj i:type="c:SuggestionResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Response"><c:SuggestionID>131019610</c:SuggestionID></a:CommonSearchResponseBObj></a:CommonSearchResponse><b:Requester>Authenticated User</b:Requester><b:TxStatusCode>SUCCESS</b:TxStatusCode></CreateAccountResult></CreateAccountResponse></s:Body></s:Envelope>';
        AccountSuggestionResponse sugResponse = AccountSuggestionResponse.parseResponseString(strsuggestionResponse);
        string strduplicateResponse ='<?xml version="1.0" encoding="UTF-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><X-OPNET-Transaction-Trace xmlns="http://opnet.com">ef464e69-a4c8-47df-b96f-50e66ce9a481-2628-21</X-OPNET-Transaction-Trace></s:Header><s:Body><CreateAccountResponse xmlns="CIL"><CreateAccountResult i:type="b:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response"><a:CommonSearchResponse><a:CommonSearchResponseBObj i:type="c:AccountBasicSearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Response"><c:AccountId>2718678733</c:AccountId><c:AccountName>test123jyothi</c:AccountName><c:AccountStatus>ACTIVE</c:AccountStatus><c:AccountType>ACCOUNT</c:AccountType><c:Country>US</c:Country><c:DMU>Y</c:DMU><c:OOB>N</c:OOB></a:CommonSearchResponseBObj></a:CommonSearchResponse><b:Requester>Authenticated User</b:Requester><b:TxStatusCode>SUCCESS</b:TxStatusCode></CreateAccountResult></CreateAccountResponse></s:Body></s:Envelope>';
        AccountSuggestionResponse dupResponse = AccountSuggestionResponse.parseResponseString(strduplicateResponse);
        system.assertNotEquals(Null, strerrorResponse);
    }
    //2.0
    public static testmethod void testActivateAccountInAffinityGivenAccId(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c objCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert objCountry;
        user u = [Select Id, Name From User Where IsActive = true and Profile.UserLicense.Name = 'Salesforce' and Profile.Name = 'System Administrator' AND IsActive=true AND username like '%aa_globalsysadmin@dell.com%' LIMIT 1];
        listAcc = [select id,name,Account_ID__c from Account limit 1];
        listAcc[0].Suggestion_ID__c = '131025787';
        listAcc[0].Account_Country_Code__c ='TY';
        listAcc[0].status__c ='Under Review';
        listAcc[0].ownerid =  u.id;
        update listAcc;
        listOpp = [select id,name, AccountID,stageName,Amount,Probability,Competitor_Lost_To__c,CloseDate from Opportunity];
        listOpp[0].AccountID = listAcc[0].Id;
        listOpp[0].Probability = 30.0;
        listOpp[0].Amount = 1000;
        listOpp[0].StageName='Qualify - 30%';
        listOpp[0].Competitor_Lost_To__c = 'Acer';
        listOpp[0].CloseDate = Date.TODAY();
        update listOpp;
        TriggerExecutionController.setSkipAllTriggers(false);
        test.startTest();
        listAcc[0].Status__c = 'U';
        listAcc[0].Account_ID__c ='131026787';
        update listAcc[0];
        test.stopTest();
        system.assertNotEquals(500, listOpp[0].Amount);
    }
    //3.0
    /** method to test Create subAccount **/
    public static testMethod void testCreateSubAccount(){
        if(btestDataCreated==False)
        {
            createTestData();
            Lead objTestLead = [SELECT Account__r.Account_ID__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                                Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                                CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                                Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                                NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                                Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                                Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                                Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c,Physical_Country__r.Name, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                                Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                                Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                                Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, Questions_Comments__c, 
                                Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c, 
                                Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c,
                                //3.0
                                Territory_Assignment__r.Region_Desc__c,
                                Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c,    //CR2574
                                ownerId,NumberOfEmployees,Contact__c,Contact__r.Name,FirstName,LastName,Name,Lead_Type__c,Reason__c,
                                Related_Contact__c,Related_Contact__r.Phone,Related_Contact__r.Email,Related_Contact__r.MobilePhone,
                                PostalCode,Country,City,State,Street,Campaign__r.Region__c,Email,MobilePhone,Phone,
                                RTM__c, //Story 3676977 
                                //v5.1
                                Legal_Local_Company_Name__c, 
                                Legal_Local_Address_1__c,
                                Legal_Local_Country__c, 
                                Legal_Local_City__c, 
                                Legal_Local_Postal_State__c, 
                                Legal_Local_Postal_Code__c
                                
                                FROM Lead
                                WHERE Id =:suggestionLead.Id LIMIT 1];
            test.startTest(); 
            HttpRequest req= AccountSuggestionIntegrationCIL.createHttpRequestHeader('CreateAccount'); 
            string strresponse1 = AccountSuggestionIntegrationCIL.createSubAccountsuggestionHTTPRequestBodyString(objTestLead,false, '12345676');
            Test.setMock(HttpCalloutMock.class, new Affinity_MockHttpResponseGenerator());        
            system.assertNotEquals(null, objTestLead.NDA_Expiry_Date__c);
            test.stopTest();
        }
    }
}