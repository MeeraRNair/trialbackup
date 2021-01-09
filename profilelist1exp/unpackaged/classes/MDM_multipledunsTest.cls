@isTest(SeeAllData=true)
private class MDM_multipledunsTest
{
static testmethod void myTest()
    {
       Profile SSIprofile = [select id from profile where name like '%GBL Sales Rep - Non SSO%' Limit 1];
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
        string duns1;
        string duns2;
        string accid;        
       
        Account testAcc = new Account(name='testaccount',D_U_N_S__c='1234',Global_D_U_N_S__c='1234',account_id__c='1234');
        insert testAcc;
        PageReference p = Page.MDM_MultipleDunsPage;
        Test.setcurrentpage(p);
        apexpages.currentpage().getparameters().put('duns1',testAcc.D_U_N_S__c);
        duns1 = apexpages.currentpage().getparameters().get('duns1');
        apexpages.currentpage().getparameters().put('duns2',testAcc.Global_D_U_N_S__c);
        duns2 = apexpages.currentpage().getparameters().get('duns2');
        apexpages.currentpage().getparameters().put('id',testAcc.id);
        accid = apexpages.currentpage().getparameters().get('id');
        
        set<string> dunsset = new set<string>();
        dunsset.add(duns1);
        dunsset.add(duns2);
        
        MDM_MultipleDunsCntrlr inst = new MDM_MultipleDunsCntrlr();
        system.Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MDM_MockHttpResponseGenerator());
         HttpResponse res = CalloutClass.getInfoFromExternalService();
         output = res.getbody();
         inst.parsexml(output);
        
        inst.goToSearchPage();
        
        system.Test.stopTest();
        String contentType = res.getHeader('content-type');
        System.assertEquals('application/xml',contentType);
        String expectedValue = '<?xml version="1.0" encoding="UTF-8"?><s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action s:mustUnderstand="1">CIL/IExploreAffinity/SearchDunsResponse</a:Action><a:RelatesTo>urn:uuid:363c97e0-b4fa-4e19-8334-c1f8c6f8d0e1</a:RelatesTo></s:Header><s:Body><SearchDunsResponse xmlns="CIL"><SearchDunsResult i:type="c:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common"><b:CommonSearchResponse><b:CommonSearchResponseBObj i:type="d:DunsBasicSearchResponseBObj" xmlns:d="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Duns.Response"><d:Address1>Cra 55 # 14-22 Ofic 225</d:Address1><d:Address2>Behind the coconut tree</d:Address2><d:BusinessName>Intersport</d:BusinessName><d:City>Santiago > home</d:City><d:Country>ANGUILLA</d:Country><d:CountyCode>000</d:CountyCode><d:DunsId>1001411</d:DunsId><d:EmployeeSize>550</d:EmployeeSize><d:OOB>N</d:OOB><d:PostalCode>33333</d:PostalCode><d:RegisteredAddressIndicator>N</d:RegisteredAddressIndicator><d:State>SANTIAGO</d:State><d:TradestyleName>CBC</d:TradestyleName><d:HqDuns>abc</d:HqDuns><d:Level>2</d:Level></b:CommonSearchResponseBObj><b:CommonSearchResponseBObj i:type="d:DunsBasicSearchResponseBObj" xmlns:d="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Duns.Response"><d:Address1>399 Park Ave</d:Address1><d:BusinessName>Citigroup Inc. Citigroup</d:BusinessName><d:City>New York</d:City><d:Country>USA</d:Country><d:CountyCode>492</d:CountyCode><d:DunsId>197329691</d:DunsId><d:EmployeeSize>251000</d:EmployeeSize><d:OOB>N</d:OOB><d:PostalCode>100224699</d:PostalCode><d:PreviousDuns>4041989</d:PreviousDuns><d:RegisteredAddressIndicator>N</d:RegisteredAddressIndicator><d:State>New York</d:State><d:TradestyleName>Citigroup</d:TradestyleName></b:CommonSearchResponseBObj></b:CommonSearchResponse><c:Requester>Authenticated User</c:Requester><c:TxStatusCode>SUCCESS</c:TxStatusCode></SearchDunsResult></SearchDunsResponse></s:Body></s:Envelope>';
        System.assertEquals(output, expectedValue);
        System.assertEquals(200, res.getStatusCode());
     
     }
    }