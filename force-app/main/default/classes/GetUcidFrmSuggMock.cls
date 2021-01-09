@isTest

global class GetUcidFrmSuggMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml'); 
        res.setBody(' { "CommonSearchResponse" : [{"PartnerTrackInformation": [{"PartnerProfiledAccountUCID":"12345"}]}] }');
        //res.setBody('{"CommonSearchResponse": [  {"MasterGroupInformation": {"MasterGroupID": 0},"TrackInformation": {},"PartnerTrackInformation": {"PartnerProfiledAccountUCID": "","PartnerProfiledAccountFlag": ""},"SellingMotion": {"TerritoryInformation": [  {"ActionFlag": null,"GroupID": 100100199}],"AddressInformation": [  {"AddressType": null}],"SuggestionInformation": {"AccountType": 1,"SuggestionID": 301917662,"EffectiveDate": "1/8/2019 11:02:20 AM","SuggestionTypeId": 100,"IsDSRequester": false}}],"RequestId": null}');
        res.setStatusCode(200);
        return res;
    }
}