@isTest

global class VMWare_MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":"true","responseCode":200,"message":"SUCCESSFULLY RETRIEVED DATA","accts":[{"ZipPostalCode":"560048","StateProvince":"Karnataka","Name":"Wells Fargo","DomainName":null,"CustomerID":"CUST-0001573041","Country":"INDIA","City":"Bangalore","Address_4":null,"Address_3":null,"Address_2":"Total Mall, K R Puram Hobli, Mahadevapura","Address_1_del":"Sez Unit, Bagmane Tech Park, Opposite To Doddanekundi","AccountId":"00180000019uDpUAAU"}]}');
        res.setStatusCode(200);
        return res;
    }
}