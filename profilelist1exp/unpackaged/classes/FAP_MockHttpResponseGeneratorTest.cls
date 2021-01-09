@isTest
public class FAP_MockHttpResponseGeneratorTest implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertNotEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"location" : "location"}');
        res.setStatusCode(200);
        JSONParser responseParser = JSON.createParser(res.getBody());
        return res;
    }
}