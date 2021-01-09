global class NDA_DirectLogincontrollerMock implements HttpCalloutMock{
   // Creating some Fake Response 
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"name":"System Administrator Mock Class"}');
        res.setStatusCode(200);
        return res;
    }
}