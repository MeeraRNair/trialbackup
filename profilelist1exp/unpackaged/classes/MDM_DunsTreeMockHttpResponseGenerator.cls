@isTest
global class MDM_DunsTreeMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method. text/xml;charset=UTF-8
        //System.assertEquals('https://soagw-dmznonprod.ins.dell.com/AffinityService/AffinityService.svc/ws', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        String fakeBody = '<?xml version="1.0" encoding="UTF-8"?>'+
                            '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing">'+
                            '<s:Header>'+
                            '<a:Action s:mustUnderstand="1">CIL/IExploreAffinity/GetDunsHierarchyResponse</a:Action>'+
                            '<a:RelatesTo>urn:uuid:363c97e0-b4fa-4e19-8334-c1f8c6f8d0e1</a:RelatesTo>'+
                            '</s:Header>'+
                            '<s:Body>'+
                            '<GetDunsHierarchyResponse xmlns="CIL">'+
                            '<GetDunsHierarchyResult i:type="c:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common">'+
                            '<b:CommonSearchResponse>'+
                            '<b:CommonSearchResponseBObj i:type="d:DunsHierarchySearchResponseBObj" xmlns:d="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone">'+
                            '<d:AccountType>1</d:AccountType>'+
                            '<d:AddressLine1>100 N Riverside Plz</d:AddressLine1>'+
                            '<d:City>Chicago</d:City>'+
                            '<d:Country>USA</d:Country>'+
                            '<d:DunsName>The Boeing Company</d:DunsName>'+
                            '<d:DunsNumber>9256819</d:DunsNumber>'+
                            '<d:EmployeeSize>168400</d:EmployeeSize>'+
                            '<d:HasChildren>Y</d:HasChildren>'+
                            '<d:HqDuns>9256819</d:HqDuns>'+
                            '<d:Level>1</d:Level>'+
                            '<d:PhoneNumber>3125442000</d:PhoneNumber>'+
                            '<d:PostalCode>606062016</d:PostalCode>'+
                            '<d:SalesRevenue>86623000000</d:SalesRevenue>'+
                            '<d:State>Illinois</d:State>'+
                            '<d:TradestyleName>Boeing</d:TradestyleName>'+
                            '</b:CommonSearchResponseBObj>'+
                            '<b:CommonSearchResponseBObj i:type="d:DunsHierarchySearchResponseBObj" xmlns:d="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone">'+
                            '<d:AccountType>1</d:AccountType>'+
                            '<d:AddressLine1>Onbekend Nederlands Adre</d:AddressLine1>'+
                            '<d:City>Onbekend</d:City>'+
                            '<d:Country>NETHERLANDS</d:Country>'+
                            '<d:DunsName>Boeing International B.V.</d:DunsName>'+
                            '<d:DunsNumber>406813316</d:DunsNumber>'+
                            '<d:HasChildren>Y</d:HasChildren>'+
                            '<d:HqDuns>9256819</d:HqDuns>'+
                            '<d:Level>2</d:Level>'+
                            '<d:PostalCode>0000AA</d:PostalCode>'+
                            '</b:CommonSearchResponseBObj>'+
                            '<b:CommonSearchResponseBObj i:type="d:DunsHierarchySearchResponseBObj" xmlns:d="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone">'+
                            '<d:AccountType>1</d:AccountType>'+
                            '<d:AddressLine1>Frankfurter Str. 233</d:AddressLine1>'+
                            '<d:City>Neu-Isenburg</d:City>'+
                            '<d:Country>GERMANY</d:Country>'+
                            '<d:DunsName>Boeing CAS GmbH</d:DunsName>'+
                            '<d:DunsNumber>344018846</d:DunsNumber>'+
                            '<d:HasChildren>Y</d:HasChildren>'+
                            '<d:HqDuns>406813316</d:HqDuns>'+
                            '<d:Level>3</d:Level>'+
                            '<d:PhoneNumber>61025077300</d:PhoneNumber>'+
                            '<d:PostalCode>63263</d:PostalCode>'+
                            '<d:State>Hessen</d:State>'+
                            '</b:CommonSearchResponseBObj>'+
                            '<b:CommonSearchResponseBObj i:type="d:DunsHierarchySearchResponseBObj" xmlns:d="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone">'+
                            '<d:AccountType>1</d:AccountType>'+
                            '<d:AddressLine1>Frankfurter Str. 233</d:AddressLine1>'+
                            '<d:City>Neu-Isenburg</d:City>'+
                            '<d:Country>GERMANY</d:Country>'+
                            '<d:DunsName>Boeing International B.V. &amp; Co. Holding KGaA</d:DunsName>'+
                            '<d:DunsNumber>537653581</d:DunsNumber>'+
                            '<d:EmployeeSize>760</d:EmployeeSize>'+
                            '<d:HasChildren>Y</d:HasChildren>'+
                            '<d:HqDuns>344018846</d:HqDuns>'+
                            '<d:Level>4</d:Level>'+
                            '<d:PhoneNumber>61025070</d:PhoneNumber>'+
                            '<d:PostalCode>63263</d:PostalCode>'+
                            '<d:SalesRevenue>233168296</d:SalesRevenue>'+
                            '<d:State>Hessen</d:State>'+
                            '<d:TradestyleName>Boeing International</d:TradestyleName>'+
                            '</b:CommonSearchResponseBObj>'+
                            '<b:CommonSearchResponseBObj i:type="d:DunsHierarchySearchResponseBObj" xmlns:d="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone">'+
                            '<d:AccountType>1</d:AccountType>'+
                            '<d:AddressLine1>Gate House</d:AddressLine1>'+
                            '<d:AddressLine2>Fretherne Road</d:AddressLine2>'+
                            '<d:City>Welwyn Garden City</d:City>'+
                            '<d:Country>ENGLAND</d:Country>'+
                            '<d:DunsName>CONTINENTAL DATAGRAPHICS LTD</d:DunsName>'+
                            '<d:DunsNumber>536200363</d:DunsNumber>'+
                            '<d:EmployeeSize>80</d:EmployeeSize>'+
                            '<d:HasChildren>Y</d:HasChildren>'+
                            '<d:HqDuns>537653581</d:HqDuns>'+
                            '<d:Level>5</d:Level>'+
                            '<d:PhoneNumber>1707367700</d:PhoneNumber>'+
                            '<d:PostalCode>AL8 6NS</d:PostalCode>'+
                            '<d:SalesRevenue>12372455</d:SalesRevenue>'+
                            '<d:State>HERTFORDSHIRE</d:State>'+
                            /*'<d:faultcode>DataPower</d:faultcode>'+
                            '<d:faultstring>size</d:faulstring>'+
                            '<d:Message>No Record Found</d:Message>'+
                            '<d:Fault>test</d:Fault>'+*/
                            '</b:CommonSearchResponseBObj>'+
                            '</b:CommonSearchResponse>'+
                            '<c:Requester>Authenticated User</c:Requester>'+
                            '<c:TxStatusCode>SUCCESS</c:TxStatusCode>'+
                            '</GetDunsHierarchyResult>'+
                            '</GetDunsHierarchyResponse>'+
                            '</s:Body>'+
                            '</s:Envelope>';
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type','application/xml');
        //res.setBody('<?xml version="1.0" encoding="utf-16"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><ActivityId CorrelationId="a00b5029-8c84-42a0-82e1-383c21d5e25e" xmlns="http://schemas.microsoft.com/2004/09/ServiceModel/Diagnostics">5257f1a0-9835-4188-9900-a57f24c41ed4</ActivityId></s:Header><s:Body><GetHierarchyResponse xmlns="CIL"><GetHierarchyResult i:type="b:TxRemarks" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common"><b:CommonSearchResponse><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>Mountain View</c:City><c:Country>USA</c:Country><c:DunsName>Google Inc.</c:DunsName><c:DunsNumber>60902413</c:DunsNumber><c:HqDuns>60902413</c:HqDuns><c:Level>1</c:Level><c:PartyId>727392242</c:PartyId><c:PostalCode>940431351</c:PostalCode><c:State>California</c:State><c:TradestyleName>Google</c:TradestyleName></a:CommonSearchResponseBObj><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>Mountain View</c:City><c:Country>USA</c:Country><c:DunsName>Youtube, LLC</c:DunsName><c:DunsNumber>19496789</c:DunsNumber><c:HqDuns>60902413</c:HqDuns><c:Level>1</c:Level><c:PostalCode>940431351</c:PostalCode><c:State>California</c:State></a:CommonSearchResponseBObj><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>Mountain View</c:City><c:Country>USA</c:Country><c:DunsName>Youtube, LLC</c:DunsName><c:DunsNumber>19496789</c:DunsNumber><c:HqDuns>60902413</c:HqDuns><c:Level>2</c:Level><c:PostalCode>940431351</c:PostalCode><c:State>California</c:State></a:CommonSearchResponseBObj><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>New York</c:City><c:Country>USA</c:Country><c:DunsName>Next New Networks, Inc.</c:DunsName><c:DunsNumber>795709257</c:DunsNumber><c:HqDuns>19496789</c:HqDuns><c:Level>2</c:Level><c:PartyId>2434779670</c:PartyId><c:PostalCode>100168409</c:PostalCode><c:State>New York</c:State></a:CommonSearchResponseBObj><a:CommonSearchResponseBObj i:type="c:DunsHierarchySearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Respone"><c:City>New York</c:City><c:Country>USA</c:Country><c:DunsName>Next New Networks, Inc.</c:DunsName><c:DunsNumber>795709257</c:DunsNumber><c:HqDuns>19496789</c:HqDuns><c:Level>3</c:Level><c:PartyId>2434779670</c:PartyId><c:PostalCode>100168409</c:PostalCode><c:State>New York</c:State><c:AddressLine1>test1</c:AddressLine1><c:AddressLine2>test2</c:AddressLine2><c:SalesRevenue>12345</c:SalesRevenue><c:EmployeeSize>12345</c:EmployeeSize><c:PhoneNumber>12345</c:PhoneNumber><c:HasChildren>Y</c:HasChildren><c:AccountType>4</c:AccountType><c:faultcode>DataPower</c:faultcode><c:faultstring>size</c:faulstring><c:Message>No Record Found</c:Message><c:Fault>test</c:Fault></a:CommonSearchResponseBObj></b:CommonSearchResponse><c:Requester>Authenticated User</c:Requester><c:TxStatusCode>SUCCESS</c:TxStatusCode></GetHierarchyResult></GetHierarchyResponse></s:Body></s:Envelope>');
        res.setBody(fakeBody);
        res.setStatusCode(200);
        return res;
    }
}