@isTest
public class ProfileServicesCalloutMockTest implements HttpCalloutMock{

    public HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('{"contactId": "82f2bcf0-0d44-40a4-abfc-440ae2549574","partnerTrackId": "a9ne00000008pmw" }');
    return res;
  }
}