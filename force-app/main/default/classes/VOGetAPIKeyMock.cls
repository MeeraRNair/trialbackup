/********************************************
Name   : VOGetAPIKeyMock
Description   : Used for Callout test classes
Author   : Priyanka Challa, VisitOps

*********************************************/
global without sharing class VOGetAPIKeyMock implements HttpCalloutMock {
    private Integer returnedStatusCode;
    private string returnedBody;
    private string returnedStatus;
    
    public VOGetAPIKeyMock(Integer returnedStatusCode,string returnedStatus) {
        this.returnedStatusCode = returnedStatusCode;
        this.returnedStatus=returnedStatus;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        // you can use System.assert here and "if" calls to check the request and affect your return if you wish
        HttpResponse res = new HttpResponse();
        res.setStatusCode(returnedStatusCode);
        res.setStatus(returnedStatus);
        return res;
    }
}