@isTest
global class PMC_MockHttpResponseGenerator implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setBody('{"contract": {'
    			+'"contractExtension": {'
      			+'"salesSegment": "dhs",'
      			+'"webSourceId": "800004"},'
        		+'"contractComponent": {'
      			+'"contractPartyRoleList": [{'
          		+'"contractRoleIdPK": "451419288",'
                +'"sourceSystemCode": "DSA",'
          		+'"startDate": "2017-11-03T04:31:20.4379143-05:00",'
          		+'"contractPartyRoleLastUpdateDate": "2017-11-03T04:31:20.4379143-05:00",'
 	         	+'"contractPartyRoleLastUpdateUser": "sample user",'
          		+'"contractRoleLocationList": [{'
              	+'"contractRoleLocationLastUpdateDate": "2017-11-03T04:31:20.4379143-05:00",'
              	+'"partyContactMethod": {'
                +'"contactMethod": {'
                + ' "referenceNumber": "dit1113test04@dell.com"},'
                +'"contactMethodUsageType": "Email"},'
              	+'"marketingPreferenceFlag": "Y"}],'
          		+'"party": {'
            	+'"preferredLanguageValue": "EN"},'
          		+'"country": "US"}]}}}');
        res.setStatusCode(200);
        return res;
    }	
}