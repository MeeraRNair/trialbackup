@isTest
global class SendUcidMock implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setBody('{"UCID": "UCID"}');
        res.setStatusCode(200);
        return res;
    }  
}