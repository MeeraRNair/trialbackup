@isTest
Global Class CC_DSAProductMock Implements HttpCalloutMock {
        
    protected Integer intcode;
    protected String strstatus;
    protected String strbodyAsString;
    protected Blob blbbodyAsBlob;
    protected Map<String, String> mapresponseHeaders;
    
    public CC_DSAProductMock(Integer intcode, String strstatus, String strbody,
                             Map<String, String> mapresponseHeaders) {
                                 this.intcode = intcode;
                                 this.strstatus = strstatus;
                                 this.strbodyAsString = strbody;
                                 this.blbbodyAsBlob = null;
                                 this.mapresponseHeaders = mapresponseHeaders;
                             }
    
    public CC_DSAProductMock(Integer intcode, String strstatus, Blob blbbody,
                             Map<String, String> mapresponseHeaders) {
                                 this.intcode = intcode;
                                 this.strstatus = strstatus;
                                 this.blbbodyAsBlob = blbbody;
                                 this.strbodyAsString = null;
                                 this.mapresponseHeaders = mapresponseHeaders;
                             }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(intcode);
        resp.setStatus(strstatus);
        if (blbbodyAsBlob != null) {
            resp.setBodyAsBlob(blbbodyAsBlob);
        } else {
            resp.setBody(strbodyAsString);
        }
        
        if (mapresponseHeaders != null) {
            for (String strkey : mapresponseHeaders.keySet()) {
                resp.setHeader(strkey, mapresponseHeaders.get(strkey));
            }
        }
        return resp;
    }

}