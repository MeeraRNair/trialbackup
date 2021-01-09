@isTest(SeeAllData=true)
private class MDM_DunsTreePageCntrlrTest{
    
    static testmethod void dunsTreeTest(){
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
        /*string output;
        string oAddress1;
        string dunsnumber;
        string affiid;
        string accid;*/

        
        Account testAcc = new Account(name='testaccount',D_U_N_S__c='60902413', account_id__c='12345');
        insert testAcc;
        
        
        PageReference p = Page.MDM_DunsTreePage;
        Test.setcurrentpage(p);
        
        apexpages.currentpage().getparameters().put('duns2',testAcc.D_U_N_S__c);
        //dunsnumber = apexpages.currentpage().getparameters().get('dunsnumber');
        
        
        apexpages.currentpage().getparameters().put('id',testAcc.id);
        //accid = apexpages.currentpage().getparameters().get('id');
        
        
        apexpages.currentpage().getparameters().put('close','true');

        
        //ApexPages.controller sc = new ApexPages.controller(testAcc);
        
        // inst.showpopup(dunsnumber);
        //Test.setMock(HttpCalloutMock.class, new MDM_DunsTreeMockHttpResponseGenerator ());
        //HttpResponse res = CalloutClass.getInfoFromExternalService();
        //output = res.getbody();
        //inst.searchDuns(output);
        //inst.export();
        //inst.beginCallout();
        
        system.Test.startTest();
        MDM_DunsTreePageCntrlr inst = new MDM_DunsTreePageCntrlr();
        inst.getLevelOptions();
        inst.sortCriteria = 'Postal Code';
        inst.requestTopToBottom();
        
        inst.requestGlobal();
        
        inst.requestBottomToTop();
        
        inst.beginExport();
        inst.goToSearchPage();
        
        system.Test.stopTest();
        //String contentType = res.getHeader('content-type');
        //System.assertEquals('application/xml',contentType);
        //String expectedValue = '<?xml version="1.0" encoding="utf-16"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><ActivityId CorrelationId="a00b5029-8c84-42a0-82e1-383c21d5e25e" xmlns="http://schemas.microsoft.com/2004/09/ServiceModel/Diagnostics">5257f1a0-9835-4188-9900-a57f24c41ed4</ActivityId></s:Header><s:Body><GetHierarchyResponse xmlns="CIL"><GetHierarchyResult i:type="b:TxRemarks" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common"><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>Mountain View</c:City><c:Country>USA</c:Country><c:DunsName>Google Inc.</c:DunsName><c:DunsNumber>60902413</c:DunsNumber><c:HqDuns>60902413</c:HqDuns><c:Level>1</c:Level><c:PartyId>727392242</c:PartyId><c:PostalCode>940431351</c:PostalCode><c:State>California</c:State><c:TradestyleName>Google</c:TradestyleName></a:CommonSearchResponseBObj><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>Mountain View</c:City><c:Country>USA</c:Country><c:DunsName>Youtube, LLC</c:DunsName><c:DunsNumber>19496789</c:DunsNumber><c:HqDuns>60902413</c:HqDuns><c:Level>1</c:Level><c:PostalCode>940431351</c:PostalCode><c:State>California</c:State></a:CommonSearchResponseBObj><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>Mountain View</c:City><c:Country>USA</c:Country><c:DunsName>Youtube, LLC</c:DunsName><c:DunsNumber>19496789</c:DunsNumber><c:HqDuns>60902413</c:HqDuns><c:Level>2</c:Level><c:PostalCode>940431351</c:PostalCode><c:State>California</c:State></a:CommonSearchResponseBObj><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>New York</c:City><c:Country>USA</c:Country><c:DunsName>Next New Networks, Inc.</c:DunsName><c:DunsNumber>795709257</c:DunsNumber><c:HqDuns>19496789</c:HqDuns><c:Level>2</c:Level><c:PartyId>2434779670</c:PartyId><c:PostalCode>100168409</c:PostalCode><c:State>New York</c:State></a:CommonSearchResponseBObj><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>New York</c:City><c:Country>USA</c:Country>c:DunsName>Next New Networks, Inc.</c:DunsName><c:DunsNumber>795709257</c:DunsNumber><c:HqDuns>19496789</c:HqDuns><c:Level>3</c:Level><c:PartyId>2434779670</c:PartyId><c:PostalCode>100168409</c:PostalCode><c:State>New York</c:State></a:CommonSearchResponseBObj><b:Requester>AMERICAS\Raphael_Bernardo</b:Requester><b:TxStatusCode>SUCCESS</b:TxStatusCode></GetHierarchyResult></GetHierarchyResponse></s:Body></s:Envelope>';
        //System.assertEquals(output, expectedValue);
        //System.assertEquals(200, res.getStatusCode());
    }
}