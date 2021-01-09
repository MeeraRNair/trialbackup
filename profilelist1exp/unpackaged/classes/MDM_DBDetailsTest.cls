@isTest(SeeAllData=true)
private class MDM_DBDetailsTest
{
static testmethod void myTest()
    {
       //Profile SSIprofile = [select id from profile where name like '%GBL Sales Rep - Non SSO%' Limit 1];
       Profile SSIprofile = [select id from profile where name like '%Sales Rep%' Limit 1];
       User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = SSIprofile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        
        insert testUser;
        string output;
        string oAddress1;
        string dunsnumber;
        string affiid;
        string accid;
       // List<dunsDataWrapper> allDunsData = new list<dunsDataWrapper>();
        
        
        Account testAcc = new Account(name='testaccount',D_U_N_S__c='1234',Global_D_U_N_S__c='1234',account_id__c='12345');
        insert testAcc;
        PageReference p = Page.MDM_DBAccountDetailsPage;
        Test.setcurrentpage(p);
        apexpages.currentpage().getparameters().put('dunsnumber',testAcc.D_U_N_S__c);
        dunsnumber = apexpages.currentpage().getparameters().get('dunsnumber');
        apexpages.currentpage().getparameters().put('affinityid',testAcc.account_id__c);
        affiid = apexpages.currentpage().getparameters().get('affinityid');
        apexpages.currentpage().getparameters().put('id',testAcc.id);
        accid = apexpages.currentpage().getparameters().get('id');
        apexpages.currentpage().getparameters().put('owner',testAcc.owner.name);
        string accowner = apexpages.currentpage().getparameters().get('owner');
        apexpages.currentpage().getparameters().put('owneremail',testAcc.owner.email);
        string owneremail = apexpages.currentpage().getparameters().get('owneremail');
        
        system.Test.startTest();
        ApexPages.standardcontroller sc = new ApexPages.standardcontroller(testAcc);
        MDM_DBAccountDetails inst = new MDM_DBAccountDetails(sc);
       // inst.showpopup(dunsnumber);
        Test.setMock(HttpCalloutMock.class, new MDM_DBDetailMockHttpResponseGenerator ());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        output = res.getbody();
        inst.searchDuns(output);
        inst.export();
        
        system.Test.stopTest();
        String contentType = res.getHeader('content-type');
        System.assertEquals('application/xml',contentType);
        String expectedValue = '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">CIL/IExploreAffinity/SearchDunsResponse</a:Action><a:RelatesTo>urn:uuid:73c530ae-661a-4443-b7e7-87b670fd36bf</a:RelatesTo></s:Header><s:Body><SearchDunsResponse xmlns="CIL"><SearchDunsResult i:type="c:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common"><b:CommonSearchResponse><b:CommonSearchResponseBObj i:type="d:DunsDetailSearchResponseBObj" xmlns:d="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Duns.Response"><d:Account><d:DunsAccountExtObj><d:AccountId>2095213961</d:AccountId><d:AccountName>us 03 Inc</d:AccountName></d:DunsAccountExtObj></d:Account><d:Address><d:Address1>26 Borgartun</d:Address1><d:Address2/><d:City>Reykjavik</d:City><d:CityCode/><d:ContinentCode>1</d:ContinentCode><d:ContinentCodeDup>1</d:ContinentCodeDup><d:Country>ALGERIA</d:Country><d:CountryCode>013</d:CountryCode><d:CountyCode>000</d:CountyCode><d:MailAddress>PO Box 8220</d:MailAddress><d:MailCityName>Reykjavik</d:MailCityName><d:MailCountryCode>013</d:MailCountryCode><d:MailCountryName>ALGERIA</d:MailCountryName><d:MailCountyCode>000</d:MailCountyCode><d:MailCountyName/><d:MailPostalCode>I S 128</d:MailPostalCode><d:MailStateAbbreviation/><d:MailStateCode>000</d:MailStateCode><d:MailStateName/><d:OwnsOrRentDetail/><d:PostalCode/><d:SquareFootage>000000000</d:SquareFootage><d:SquareFootageIndicator/><d:State/><d:StateAbbreviation/><d:StateCode>000</d:StateCode><d:TerritoryCoverage/><d:UndeliverableAddressIndicator/></d:Address><d:CRM><d:ActivityIndicator>000</d:ActivityIndicator><d:LineOfBusiness>Auto and home supply stores, nsk</d:LineOfBusiness><d:MarketableOrNonMarketable>N</d:MarketableOrNonMarketable><d:NationalId>4601692919</d:NationalId><d:NationalIdSystemCode>00555</d:NationalIdSystemCode><d:OOB>N</d:OOB><d:PrimaryLocalActivityCode/><d:SIC6Code/><d:US_1987_SIC1>5531</d:US_1987_SIC1><d:US_1987_SIC2>5013</d:US_1987_SIC2><d:US_1987_SIC3>5039</d:US_1987_SIC3><d:US_1987_SIC4/><d:US_1987_SIC5/><d:US_1987_SIC6/><d:UndeterminedSICIndicator>N</d:UndeterminedSICIndicator></d:CRM><d:CompanyDetail><d:numberofPcs/><d:aggregatednumberofpcsultimate/><d:AnnualSales>939000000</d:AnnualSales><d:AnnualSalesIndicator>2</d:AnnualSalesIndicator><d:AnnualSalesUSDollar>12958200</d:AnnualSalesUSDollar><d:BaseYearEmployees>0</d:BaseYearEmployees><d:BaseYearSales>0</d:BaseYearSales><d:BlueCollarEstimator/><d:CurrencyCode>0420</d:CurrencyCode><d:EmployeeSize>90</d:EmployeeSize><d:EmployeesHere>90</d:EmployeesHere><d:EmployeesHereIndicator>2</d:EmployeesHereIndicator><d:EmployeesTotalIndicator>0</d:EmployeesTotalIndicator><d:MarketingFileDelistIndicator>N</d:MarketingFileDelistIndicator><d:NumberOfAccounts>000000000</d:NumberOfAccounts><d:PercentGrowthEmployeesSign>+</d:PercentGrowthEmployeesSign><d:PercentGrowthSalesSign>+</d:PercentGrowthSalesSign><d:PricipalsIncludedIndicator>N</d:PricipalsIncludedIndicator><d:PublicOrprivateIndicator/><d:WhiteCollarEstimator/><d:YearStarted>1999</d:YearStarted></d:CompanyDetail><d:Contact><d:CEOName>Bjarni Benediktsson</d:CEOName><d:CEOTitle>Chairman</d:CEOTitle><d:EighthExecutiveName>Stefan Afrni Einarsson</d:EighthExecutiveName><d:EighthExecutiveNameMrc>Z799</d:EighthExecutiveNameMrc><d:EighthExecutiveTitle>Manager</d:EighthExecutiveTitle><d:FifthExecutiveName>Agnar Hjartar</d:FifthExecutiveName><d:FifthExecutiveNameMrc>G7O6</d:FifthExecutiveNameMrc><d:FifthExecutiveTitle>Purchasing Manager</d:FifthExecutiveTitle><d:FirstExecutiveName>Hinrik Morthens</d:FirstExecutiveName><d:FirstExecutiveNameMrc>Z699</d:FirstExecutiveNameMrc><d:FirstExecutiveTitle>Director</d:FirstExecutiveTitle><d:FourthExecutiveName>Ivar Gudjonsson</d:FourthExecutiveName><d:FourthExecutiveNameMrc>Z699</d:FourthExecutiveNameMrc><d:FourthExecutiveTitle>Director</d:FourthExecutiveTitle><d:SecondExecutiveName>Egill Tryggvason</d:SecondExecutiveName><d:SecondExecutiveNameMrc>Z699</d:SecondExecutiveNameMrc><d:SecondExecutiveTitle>Director</d:SecondExecutiveTitle><d:SeventhExecutiveName>Bjarni Jonsson</d:SeventhExecutiveName><d:SeventhExecutiveNameMrc>I7P1</d:SeventhExecutiveNameMrc><d:SeventhExecutiveTitle>Sales Manager</d:SeventhExecutiveTitle><d:SixthExecutiveName>Hrefna Bragadottir</d:SixthExecutiveName><d:SixthExecutiveNameMrc>Z799</d:SixthExecutiveNameMrc><d:SixthExecutiveTitle>Manager</d:SixthExecutiveTitle><d:ThirdExecutiveName>Hermann Saevar Gudmundsson</d:ThirdExecutiveName><d:ThirdExecutiveNameMrc>Z699</d:ThirdExecutiveNameMrc><d:ThirdExecutiveTitle>Director</d:ThirdExecutiveTitle><d:TotalNumberOfAdditionalContactNames>8</d:TotalNumberOfAdditionalContactNames></d:Contact><d:Parent><d:NoOfFamilyMembersGlobal>567</d:NoOfFamilyMembersGlobal><d:DomesticUltimateAddress/><d:DomesticUltimateDuns>abc</d:DomesticUltimateDuns><d:DomesticUltimateCityCode/><d:DomesticUltimateCityName/><d:DomesticUltimateCountryCode>000</d:DomesticUltimateCountryCode><d:DomesticUltimateName/><d:DomesticUltimatePostalCode/><d:DomesticUltimateState/><d:DomesticUltimateStateAbbreviation/><d:GlobalUltimateAddress/><d:globalUltimateDuns/><d:GlobalUltimateCityCode/><d:GlobalUltimateCityName/><d:GlobalUltimateContinentCode/><d:GlobalUltimateCountryCode>000</d:GlobalUltimateCountryCode><d:GlobalUltimateCountryName/><d:GlobalUltimateCountyCode>000</d:GlobalUltimateCountyCode><d:GlobalUltimateName/><d:GlobalUltimatePostalCode/><d:GlobalUltimateState/><d:GlobalUltimateStateAbbreviation/><d:GlobalUltimatedIndicator>N</d:GlobalUltimatedIndicator><d:HQParentAddress/><d:HQParentCityCode/><d:HQParentCityName/><d:HQParentContinentCode/><d:HQParentCountryCode>000</d:HQParentCountryCode><d:HQParentCountryName/><d:HQParentCountyCode>000</d:HQParentCountyCode><d:HQParentDuns>236789</d:HQParentDuns><d:HQParentName/><d:HQParentPostalCode/><d:HQParentStateAbbreviation/><d:HQParentStateProvince/><d:HierarchyCode/></d:Parent><d:Misc><d:BusinessTradeName>Intersport</d:BusinessTradeName><d:CottageFileIndicator/><d:DiasCode/><d:DomesticUltimateTotalEmployees>000000200</d:DomesticUltimateTotalEmployees><d:Filler1/><d:Filler2/><d:Filler3/><d:FranchiseCodeIndicator/><d:FranchiseFileCode1/><d:FranchiseFileCode2/><d:FranchiseFileCode3/><d:FranchiseFileCode4/><d:FranchiseFileCode5/><d:FranchiseFileCode6/><d:ImportExportCode>B</d:ImportExportCode><d:LegalStatus>003</d:LegalStatus><d:MSA/><d:RecordClassType/><d:SiteBroadbandDemandScore/><d:StatusCode>0</d:StatusCode><d:SubsidiaryIndicator>0</d:SubsidiaryIndicator></d:Misc><d:Primary><d:PreviousDuns>123</d:PreviousDuns><d:BusinessName>Intersport</d:BusinessName><d:DunsId>360303150</d:DunsId><d:EmployeeSize>90</d:EmployeeSize><d:RegisteredAddressIndicator>N</d:RegisteredAddressIndicator><d:TradestyleName/><d:Phone><d:CableOrTelex/><d:CountryAccessCode>0001</d:CountryAccessCode><d:FaxNumber>21234567</d:FaxNumber><d:TelephoneNumber>21234567</d:TelephoneNumber></d:Phone></d:Primary></b:CommonSearchResponseBObj></b:CommonSearchResponse><c:Requester>Authenticated User</c:Requester><c:TxStatusCode>SUCCESS</c:TxStatusCode></SearchDunsResult></SearchDunsResponse></s:Body></s:Envelope>';
        System.assertEquals(output, expectedValue);
        System.assertEquals(200, res.getStatusCode());
     }
    }