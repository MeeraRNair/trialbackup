public class PartnerOnboardingIntegrationServices {
    public static final Integer TIMEOUT=120000;
    public static final String METHOD='POST';
    public static  String strUSERNAME;
    public static  String strPASSWORD;
    public static  String strENDPOINT;
    public static  boolean bauthenticationRequired = true; 
    public final static String SANDBOX = 'Sandbox';
    
    @future (callout=true)
    public static void profileServicesIntegration(Map<String,String>mapConVsPT){
       system.debug('ProfileServicesIntegration'+mapConVsPT);
        for(String strConGUIDs : mapConVsPT.keySet()){
            
           HttpRequest request = new HttpRequest();
            //request.setEndpoint(system.Label.Channel_Profile_API_PROD_EndPoint);
            String strrequestBody = getContactRequestBody(strConGUIDs, mapConVsPT.get(strConGUIDs));
            if(strrequestBody != null) { 
                   HTTPResponse resp =  sendHttpRequest(strrequestBody);
               System.debug('resp>>>>****>>>'+resp);
            }
        }
         
    }
    
    private static String getContactRequestBody(String strContactGUID, String strPartnerTrack) {
        JSONGenerator objGen = JSON.createGenerator(false);
        objGen.writeStartObject();
        objGen.writeObjectField('contactId',strContactGUID ); 
        objGen.writeObjectField('partnerTrackId',strPartnerTrack ); 
        objGen.writeEndObject();
        String strJsonOutput = objGen.getAsString();
        system.debug('strJsonOutput>>>>>>****'+strJsonOutput);
        return strJsonOutput;
    }
    
    private static void setAuthenticationInfo() {
           if (StaticFactory.getEnvironment() == SANDBOX) {
            strUSERNAME = System.Label.DP_API_PP_SB_UNAME;
            strPASSWORD = System.Label.DP_API_PP_SB_PASSWORD;
            strENDPOINT = System.Label.DP_API_PP_SB;
            bAUTHENTICATIONREQUIRED = true;
             }
        else {
            strUSERNAME = System.Label.DP_API_PP_PROD_UNAME; //for PRODUCTION env
            strPASSWORD = System.Label.DP_API_PP_PROD_PASSWORD;
            strENDPOINT = System.Label.DP_API_PP_PROD;
            bAUTHENTICATIONREQUIRED = true;
            system.debug('&&&***');
        }

    }
    
    public static HttpRequest createHttpRequestHeaderToProfileServices() {
       HttpRequest request = new HttpRequest();
         setAuthenticationInfo();
         request.setEndpoint(strENDPOINT);
         request.setMethod('GET');
        if (bAUTHENTICATIONREQUIRED) {
            Blob blbheaderValue = Blob.valueOf(strUSERNAME + ':' + strPASSWORD);
            String strauthorizationHeader = 'Basic ' + EncodingUtil.base64Encode(blbheaderValue);
            request.setHeader('Authorization', strauthorizationHeader);
            request.setHeader('content-type', 'application/json;charset=UTF-8');
        }
        
        //Set the timeout value for the Request
        request.setTimeout(TIMEOUT);
        return request;
    }
     public static HTTPResponse  sendHttpRequest(String strrequestBody){

        HttpRequest req=createHttpRequestHeaderToProfileServices();
       system.debug('req>>>>>>>72>>>>>'+req);
        req.setBody(strrequestBody);
    
        Http http = new Http();
             
         //Sending the HTTP request
          HTTPResponse res  =new  HTTPResponse();
                res  =http.send(req); 
         return res;
     }
    
}