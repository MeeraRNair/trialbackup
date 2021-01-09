public class ValidateUCIDNumber{
  public final static String SANDBOX = 'Sandbox';
  public class deserializeResponse
    {
        public string access_token;
        public string strucid;
       
    }
    public Static String returnAccessToken ()
    {
       String straccessToken;
       
       try{   
           String strclientId     =  ''; 
           String strclientSecret =  '';  
           String strusername     =  ''; 
           String strpassword     =  ''; 
           String strdomurl     =  '';
            if (StaticFactory.getEnvironment() == SANDBOX) {
              strclientId     =   Label.PartReq_To_EMC_Client_ID_SB;
              strclientSecret =   Label.PartReq_To_EMC_Client_secret_SB;
              strusername     =   Label.PartReq_To_EMC_UserName_SB;
              strpassword     =   Label.PartReq_To_EMC_Pwd_SB;
              strdomurl       =   Label.PartReq_To_EMC_Domain_URL_SB;
              
            }
            else{
                 strclientId     =   Label.PartReq_To_EMC_Client_ID_Prod;
                 strclientSecret =   Label.PartReq_To_EMC_Client_secret_Prod;
                 strusername     =   Label.PartReq_To_EMC_UserName_Prod;
                 strpassword     =   Label.PartReq_To_EMC_Pwd_Prod;
                 strdomurl       =   Label.PartReq_To_EMC_Domain_URL_Prod;
                }
        String strreqbody =   'grant_type=password&client_id='+strclientId+'&client_secret='+strclientSecret+'&username='+strusername+'&password='+strpassword;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setBody(strreqbody);
        request.setTimeout(120000);
        request.setMethod('POST');
        request.setEndpoint(strdomurl+'/services/oauth2/token'); 
        HttpResponse response = http.send(request);
        deserializeResponse res = (deserializeResponse)JSON.deserialize(response.getbody(),deserializeResponse.class);
        straccessToken = res.access_token;
     
    }
      catch(Exception e){}
         return straccessToken;      
     }
    public static string sendUCID(String strucidd){
        string strendPointURL = Label.Validate_UCID_Number_Domain_End_Point_URL;
        string straccessToken = ValidateUCIDNumber.returnAccessToken();
         String strjsons;
        system.debug('***AccessToken*******' +straccessToken);
        
        if(straccessToken!=null || (Test.isRunningTest()) ) {
            system.debug('***AccessToken' +straccessToken);
            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization','Bearer '+straccessToken);
            request.setHeader('Content-Type','application/json');
            request.setHeader('accept','application/json');
            request.setEndpoint(strendPointURL);
            request.setMethod('POST');
            deserializeResponse ucidNumber = new deserializeResponse();
            ucidNumber.strucid= strucidd;
            String strjsonstr = JSON.serialize(ucidNumber);
            request.setbody(strjsonstr); 
            Http http = new Http();
            HTTPResponse response = http.send(request); 
            System.debug('Responsecode------------'+response.getstatuscode());
            System.debug('***Message***'+response.getBody());
            if(response.getstatuscode() == 200){
            strjsons = response.getBody();
            }else{
              strjsons = 'empty';
            }
         }
        return strjsons;
    }
}