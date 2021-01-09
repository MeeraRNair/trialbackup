/*Last Modified by :  Urvashi Shahi ,  6/7/2018 8:56 AM

History : 
Version Date            Modified By     Description                                            Version
12/07/2018                Sharad        reduce code as the requirement of story                  V1

*/

global class ST_Tiers_Update implements Schedulable
{
    public PageReference save() {
         InsertTier();
         return null;
    }

   global void execute(SchedulableContext SC) 
   {
      
      InsertTier();
   } 
      
   // Method to Delete the ST_Tiers__c
   public static boolean  DeleteTier()
   {
      Database.delete([Select Id from ST_Tiers__c], false);
      return true;
   }
   
   // Method to Insert the ST_Tiers__c
   @future(callout=true)
   Public static void InsertTier()
   {
   //ST_Product
    integer startingRecCount = 0;
    integer countLimit = 1000;
    integer maxRecordinSingleRequest = 1000;
    integer returnRecordCount = 0;
    List<ST_Tiers__c> finalTiersList = new List<ST_Tiers__c>();
    do
      {
        startingRecCount = startingRecCount + returnRecordCount ;
       
        List<ST_Tiers__c> tierList = new List<ST_Tiers__c>();
        tierList = makeCallout_Tier(startingRecCount, countLimit);
                
        if (tierList != null) 
        {
          returnRecordCount = tierList.size();
          for(ST_Tiers__c tier: tierList)
          {
            finalTiersList .add(tier) ;
          }
        }
     } while(returnRecordCount == maxRecordinSingleRequest);
    
    if (finalTiersList.size() > 0)
    {
        DeleteTier();
        upsert finalTiersList;
    }     
   }
   
   public static List<ST_Tiers__c> makeCallout_Tier(integer startingRecCount, integer countLimit)
   {
       String xmlRequestString = createXmlRequest_Tier(startingRecCount, countLimit);        
       List<ST_Tiers__c> tierList = new List<ST_Tiers__c>();
       tierList = sendCalloutREST_Tier(xmlRequestString);
        return tierList ;
   }
   
   public static string createXmlRequest_Tier(integer startingRecCount, integer countLimit)
    {
        String xmlString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:DELL_CFG_Service_Catalog_Lookup_Product_WS">';
        xmlString = xmlString + '<soapenv:Header>';
        xmlString = xmlString + '<urn:AuthenticationInfo>';
        xmlString = xmlString + '<urn:userName>'+ System.Label.ST_Remedy_UserName_Tier + '</urn:userName>';
        xmlString = xmlString + '<urn:password>' + System.Label.ST_Remedy_Password_Tier + '</urn:password>';
        xmlString = xmlString + '<!--Optional:-->';
        xmlString = xmlString + '<urn:authentication>?</urn:authentication>';
        xmlString = xmlString + '<!--Optional:-->';
        xmlString = xmlString + '<urn:locale>?</urn:locale>';
        xmlString = xmlString + '<!--Optional:-->';
        xmlString = xmlString + '<urn:timeZone>?</urn:timeZone>';
        xmlString = xmlString + '</urn:AuthenticationInfo>';
        xmlString = xmlString + '</soapenv:Header>';
        xmlString = xmlString + '<soapenv:Body>';
        xmlString = xmlString + '<urn:New_GetList_Operation_0>';
        xmlString = xmlString + '<urn:startRecord>' + startingRecCount +'</urn:startRecord>';
        xmlString = xmlString + '<urn:maxLimit>' + countLimit +'</urn:maxLimit>';
        xmlString = xmlString + '</urn:New_GetList_Operation_0>';
        xmlString = xmlString + '</soapenv:Body>';
        xmlString = xmlString + '</soapenv:Envelope>';
        //System.debug ('-------------------------- Request XML -----'+ xmlString ); //V1
        return xmlString ;
    }
   
   public static List<ST_Tiers__c>sendCalloutREST_Tier(String xmlRequestString){
        try{
        
              //System.debug ('------------------ xmlRequestString ---------'+ xmlRequestString); //V1
              String endPointURL = System.Label.ST_DP_endPointURL_Tier;  //'https://samplesite.com/samplerest'; 
              String userName = System.Label.ST_DP_UserName_Tier; //'samuser';
              String password = System.Label.ST_DP_Password_Tier; //'Sam@789';
              String host =System.Label.ST_DP_host_Tier;                            
              // Specify the required user name and password to access the endpoint 
              
              // As well as the header and header information              
              Blob headerValue = Blob.valueOf(userName + ':' + password);          
              String authorizationHeader = 'Basic ' +  EncodingUtil.base64Encode(headerValue);                        
              //System.debug('----------------- Header ---'+authorizationHeader ); //V1
            
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
              string auth =  request.getHeader('Authorization') ;
             
               //Making call to external REST API
               //System.debug('----------------- Request ---'+ request); //V1
               HttpResponse response;
               if (Test.isRunningTest() == false){
                   response = http.send(request); 
               }
               else{
                  response= null;
               }
               //System.debug('------------   Resposne ---------------'+response ); //V1
               
               //Map the data to the list of products
               List<ST_Tiers__c> tierList= ReadResponse_product(response); 
               // retrun the final Product List
               return tierList; 
         }
          catch(Exception e)
          {
              //System.debug('Error::'+e.getMessage()); //V1
          }
          return null;          
      }
      
      public static List<ST_Tiers__c>ReadResponse_product(HttpResponse response)
      {
          try{
                Integer Status_code = response.getStatusCode();
                String resp_body = response.getBody();
                Boolean result = resp_body.contains('faultstring');                           
                If ( result == true)
                   return null;
                else
                    return  readResponseString(resp_body);             
              }                
              Catch (Exception ex)
              {
                   //System.debug('-----ex.getTypeName()--'+ex.getTypeName());  //V1                  
                   if (ex.getTypeName()=='SSD_Exception')
                      throw ex;
                   else
                     throw new SSD_Exception('Incident not created : '+ex);
              } 
              return  null; 
          }
          
          public static List<ST_Tiers__c> readResponseString(String resp_body)
          {
           try
           {             
                //System.debug('--------------------resp_body : ' + resp_body ); //V1
                Dom.Document doc = new Dom.Document();                
                doc.load(resp_body);                
                //Retrieve the root element for this document.                
                Dom.XMLNode Envelope = doc.getRootElement();
                
                Dom.XMLNode Body= Envelope.getChildElements()[0];                
                //system.debug('-------- Body ------'+ Body); //V1
                 
                Dom.XMLNode step1= Body.getChildElements()[0];                
                //system.debug('-------- step1------'+ step1); //V1
                 
                List<ST_Tiers__c>tierList = new List<ST_Tiers__c>();
                  
                for(Dom.XMLNode children : step1.getChildElements()) 
                 {
                    ST_Tiers__c tier= new ST_Tiers__c();
                    for(Dom.XMLNode child : children.getChildElements()) 
                     {
                        if(child.getName() == 'O2P_ID')
                             tier.Name =child.getText();
                        else if(child.getName() == 'Product_Categorization_Tier_1')
                            tier.Product_Categorization_Tier_1__c=child.getText();
                        else if(child.getName() == 'Product_Categorization_Tier_2')
                            tier.Product_Categorization_Tier_2__c=child.getText();
                        else if(child.getName() == 'Product_Categorization_Tier_3')
                            tier.Product_Categorization_Tier_3__c=child.getText();
                        else if(child.getName() =='Service_Categorization_Tier_1')
                            tier.Service_Categorization_Tier_1__c=child.getText();
                        else if(child.getName() =='Service_Categorization_Tier_2')
                            tier.Service_Categorization_Tier_2__c=child.getText();
                        else if(child.getName() =='Service_Categorization_Tier_3')
                            tier.Service_Categorization_Tier_3__c=child.getText();
                        else if(child.getName() == 'Product_Name')
                            tier.Product_Name__c=child.getText(); 
                        
                      }
                      //System.debug('---------- product-------'+tier); //V1
                      tierList.add(tier);
                 }
                 //System.debug('---------- productList-------'+tierList); //V1
                 return tierList;
              }                
              Catch (Exception ex){
              
                   //System.debug('-----ex.getTypeName()--'+ex.getTypeName());    //V1               
                   if (ex.getTypeName()=='SSD_Exception')
                      throw ex;
                   else
                     throw new SSD_Exception('Incident not created : '+ex);
              } 
              return  null;         
        } 
    
}