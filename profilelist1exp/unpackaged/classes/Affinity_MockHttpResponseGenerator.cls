@isTest

global class Affinity_MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml'); 
        res.setBody('<?xml version="1.0" encoding="UTF-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><X-OPNET-Transaction-Trace xmlns="http://opnet.com">0c2c06d9-3ab6-41d3-a8d8-b1a6f0bce5ca-1892-213</X-OPNET-Transaction-Trace></s:Header><s:Body><CreateAccountResponse xmlns="CIL"><CreateAccountResult i:type="b:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response"><b:MDMError><b:Message>SalesRep RRID/BadgeNumber is Invalid</b:Message><b:SearchStatus>WARNING</b:SearchStatus></b:MDMError><b:Requester>Authenticated User</b:Requester><b:TxStatusCode>SUCCESS</b:TxStatusCode></CreateAccountResult></CreateAccountResponse></s:Body></s:Envelope>');
        res.setStatusCode(200);
        return res;
    }
}