/*
  * Author   : Ravali K
  * Purpose  : This class is used for Http Call out to the Mulesoft(authentication), VMware(to search and retrieve company details).
  *
  * Revision   CR Number   Release No          Date          Modified By      Description
  * --------  ---------   ----------        -----------     ------------      -----------
  * 1.0         14782     FY18-DCS-1001       25-Aug-17      Ravali - UST      Created new webservice
  *
*/

public with sharing class VMWareSearchAPICallout {
    private static final String METHOD = 'POST';
    public static String USERNAME;
    public static String PASSWORD; 
    public static String ENDPOINT;  
    
    // Get the Access token.
    public static HTTPResponse getAccessToken(){
      HttpRequest req = createHttpRequest();
      Http http = new Http();
      HTTPResponse objHttpResp;
      if(Test.isRunningTest()){ //Fake Response for Test.
        objHttpResp = new HTTPResponse();
        objHttpResp.setHeader('Content-Type', 'application/json');
        objHttpResp.setBody('{"access_token":"AccessToken","token_type":"Bearer","expires_in":"1200"}');
        objHttpResp.setStatusCode(200);
        return objHttpResp ;   
      
      }else{
              objHttpResp = http.send(req); 
      }
      return objHttpResp;
    }

    //Need to Customize more on this method.
    private static HttpRequest createHttpRequest(){
    
        if (StaticFactory.getEnvironment() == 'Sandbox') {
           USERNAME = System.Label.VMware_SFDC_username_sandbox;
           PASSWORD = System.Label.VMware_SFDC_Password_sandbox;
           ENDPOINT = 'callout:Mulesoft/3PS';
        }
        else {
           USERNAME = System.Label.VMware_SFDC_username_Prod; //for PRODUCTION env
           PASSWORD = System.Label.VMware_SFDC_Password_Prod;
           ENDPOINT = 'callout:Mulesoft_Prod/3PS';
        }
 
       HttpRequest objHttpReq = new HttpRequest();
       Project_Services__c MSAuth= Project_Services__c.getValues('Mulesoft');
       objHttpReq.setEndpoint(ENDPOINT);//https://apigw-test.vmware.com/qa/v1/m0/api/token/3PS'
       Blob headerValue = Blob.valueOf(MSAuth.Client_Id__c+':'+MSAuth.Client_Secret__c);
       String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
       objHttpReq.setHeader('Authorization', authorizationHeader);
       String reqBody = 'username='+USERNAME+'&password='+PASSWORD;
       objHttpReq.setBody(reqBody);  
        
       objHttpReq.setHeader('Content-type','text/plain');
       objHttpReq.setMethod(Method);
       system.debug('***Token Request******'+objHttpReq);
       return  objHttpReq;
    }

    // Process the Response - Token
    private class MuleTokenResponse{
      public string access_token;
      public string token_type;
      public string expires_in;
    }
        
    // Call the search API.
    public static HttpResponse getAccountInfo(String strCountry,String strCompanyName, String strState){
    HTTPresponse objHttpRes = null;
        try{         
            HTTPResponse objTokenResp = getAccessToken();
            //system.debug('*******Response from Mulesoft-OAUTH*******'+objTokenResp.getBody());
            if(objTokenResp.getStatusCode() == 200){
                MuleTokenResponse response = (MuleTokenResponse)JSON.deserialize(objTokenResp.getBody(),MuleTokenResponse.class);
                String strToken = response.access_token;
                //system.debug('**********Access Token*********'+strToken);
                
                if (StaticFactory.getEnvironment() == 'Sandbox') {
                   ENDPOINT = 'callout:VMAccountSearch/getAccountInfo';
                }
                else {
                   ENDPOINT = 'callout:VMAccountSearch_Prod/getAccountInfo';
                }
                
                HttpRequest objHttpReq = new HttpRequest();            
                objHttpReq.setHeader('Content-type','application/json');
                objHttpReq.setMethod(Method);
                objHttpReq.setHeader('Authorization','Bearer '+strToken);
                objHttpReq.setEndpoint(ENDPOINT); //https://apigw-test.vmware.com/test41/v1/m1/api/adplussearchapi/getAccountInfo
                //System.debug('**********Endpoint URL**********'+ENDPOINT);
                map<string,string> mapReqBody = new map<string,string>();
                mapReqBody.put('searchText',strCompanyName);
                mapReqBody.put('accountCountry',strCountry);
                mapReqBody.put('accountState',strState);
    
                String JsonBody = JSON.serialize(mapReqBody);
                objHttpReq.setBody(JsonBody);
                //system.debug('*******accountInfo request********'+objHttpReq);
                Http http = new Http();
                objHttpRes= http.send(objHttpReq);
                //system.debug('***************Final Reponse***'+objHttpRes.getBody());
                
            }else{
                return objTokenResp;
            }
               
        }catch(Exception ex){
            HttpResponse objErrorResp= new HttpResponse();
            objErrorResp.setStatusCode(500);
            objErrorResp.setStatus('Internal Server Error');
            objErrorResp.setBody(ex.getStackTraceString());
            return objErrorResp;
        }
        return objHttpRes;
    }  
  
}