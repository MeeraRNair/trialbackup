/*
 * @Author 		: Prasanthi M
 * Created Date : 1/2/2019
 * Purpose		: Implementing Mock Response for the send UCID information to suggestion API web service
 */
@isTest
global class AffinityUCID_MockHttpResponseGenerator implements HttpCalloutMock{
    global HTTPResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"CommonSearchResponse": null,"RequestId": null,"SuggestionID": 1,"Error": null}');
        res.setStatusCode(200);
        return res;
    }
}