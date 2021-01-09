@isTest

global class CPDB_MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setHeader('SOAPAction', '\"http://tempuri.org/IPrimaryContactServices/UpdatePrimaryContactWithSegment\"');
        res.setBody('<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Header><CorrelationId>1b44af8d-46d5-40ea-80cb-8184f70386d7</CorrelationId></s:Header><s:Body><UpdatePrimaryContactWithSegmentResponse xmlns="http://tempuri.org/"><UpdatePrimaryContactWithSegmentResult>true</UpdatePrimaryContactWithSegmentResult></UpdatePrimaryContactWithSegmentResponse></s:Body></s:Envelope>');
        res.setStatusCode(200);
        return res;
    }
}