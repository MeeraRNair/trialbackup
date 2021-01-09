public class CalloutClass {
    public static HttpResponse getInfoFromExternalService() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://soagw-dmznonprod.ins.dell.com/AffinityService/AffinityService.svc/ws');
        //req.setHeader('content-type','text/xml;charset=UTF-8');
        req.setMethod('POST');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
}