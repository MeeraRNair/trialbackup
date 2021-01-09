public class ST_CallDataPower
{
    /**
        * This is method to call external REST API
        * @Param xmlString
      **/
      public static string sendCalloutREST(String xmlRequestString){
        try{
        
              System.debug ('------------------ xmlRequestString ---------'+ xmlRequestString);
              
              String endPointURL = System.Label.ST_DP_endPointURL;  //'https://samplesite.com/samplerest'; 
              String userName = System.Label.ST_DP_UserName; //'samuser';
              String password = System.Label.ST_DP_Password; //'Sam@789';
              String host =System.Label.ST_DP_host;
              
              System.debug('----------------- ST_DP_UserName---------'+userName );
              System.debug('----------------- ST_DP_Password---------'+password );
              System.debug('----------------- ST_DP_endPointURL ---------'+endPointURL );
              // Specify the required user name and password to access the endpoint 
              
              // As well as the header and header information 
             
              Blob headerValue = Blob.valueOf(userName + ':' + password);          
              String authorizationHeader = 'Basic ' +  EncodingUtil.base64Encode(headerValue); 
                       
              System.debug('----------------- Header ---'+authorizationHeader );
            
              Httprequest request = new HttpRequest();
              Http http = new Http();    
              request.setMethod('POST');
              request.setEndpoint(endPointURL);          
              request.setHeader('Content-Type', 'application/xml');
              request.setHeader('Content-Length', '2897');
              request.setHeader('Host',host);
              request.setHeader('Connection', 'Keep-Alive');
              request.setHeader('Authorization', authorizationHeader);// 'Basic UmVtZWR5TlA6UmVtZWR5QEQzbGw=');
              
    
              
              // timeout in milliseconds       
              request.setTimeout(120000); 
              
              request.setBody(xmlRequestString);          
              System.debug('----------------- Request ---'+ request);  
               
               string auth =  request.getHeader('Authorization') ;
             
               //Making call to external REST API
               HttpResponse response = http.send(request); 
               System.debug('------------   Resposne ---------------'+response );
               String IncidentNumber = ReadResponse(response);             
                
               return IncidentNumber ; 
                           
          }
          catch(Exception e)
          {
              System.debug('Error::'+e.getMessage());
              throw new SSD_Exception(e.getMessage()); 
          }
          return null;          
      }
      
      
       public static string ReadResponse(HttpResponse response)
       {
             try{
                Integer Status_code = response.getStatusCode();
                String resp_body = response.getBody();
                Boolean result = resp_body.contains('faultstring');
                
                System.debug('--------------------resp_body : ' + resp_body );
                
                if (result) { // If having any error back from Remedy               
                    Integer endLoc = resp_body.indexOf('</faultstring>');            
                    Integer startLoc = resp_body.indexOf('<faultstring>');
                    String errorMessage= resp_body.substring(startLoc + 13, endLoc);                        
                    System.debug('--------------------errorMessage: ' + errorMessage);
                    Boolean isError= resp_body.contains('ERROR (44699)');
                    if (isError)
                    {
                        throw new SSD_Exception('Incident is not created.\nNo support groups were found using automated routing rules. The selected product is not supported. \n\nPlease select a different product.');
                    }
                    isError= resp_body.contains('ERROR (48272)');
                    System.debug('--------------------isError: ' + isError);                
                    if (isError)
                    {
                        throw new SSD_Exception('Incident not created.\nThe email address configured in the SFDC user profile is not found in Remedy. Please update email address in the user profile.');
                    }
                    
                    throw new SSD_Exception('Incident not created.\n'+ errorMessage);
                }
                
                if (Status_code == 200){ // Without any fault string and got incident Number
                    Integer endLoc = resp_body.indexOf('</ns0:Incident_Number>');            
                    Integer startLoc = resp_body.indexOf('<ns0:Incident_Number>');
                    String IncidentNumber = resp_body.substring(startLoc + 21, endLoc);
                    System.debug('--------------------IncidentNumber: ' + IncidentNumber );
                    
                    return IncidentNumber;                    
                 }                  
                 return null; 
              }                
              Catch (Exception ex){
              
                   System.debug('-----ex.getTypeName()--'+ex.getTypeName());                   
                   if (ex.getTypeName()=='SSD_Exception')
                      throw ex;
                   else
                     throw new SSD_Exception('Incident not created : '+ex);
              } 
              return  null;         
        }      
}