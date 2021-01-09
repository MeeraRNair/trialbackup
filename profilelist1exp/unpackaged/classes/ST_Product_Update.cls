/*
Last Modified By    Urvashi Shahi ,  6/7/2018 8:46 AM
History : 
Version Date            Modified By     Description                                            Version
12/07/2018                Sharad        reduce code as the requirement of story                  V1
*/

global class ST_Product_Update implements Schedulable
{
    public PageReference save() {
         InsertProduct();
         return null;
    }
    
   global void execute(SchedulableContext SC) 
   {
      InsertProduct();
   }
      
   // Method to Delete the Product - ST_Product
   public static boolean  DeleteProduct()
   {
      Database.delete([Select Id from ST_Product__c ], false);
      return true;
   }
   
   // Method to Insert the product - ST_Product
   @future(callout=true)
   Public static void InsertProduct()
   {
    integer startingRecCount = 0;
    integer countLimit = 1000;
    integer maxRecordinSingleRequest = 1000;
    integer returnRecordCount = 0;
    List<ST_Product__c> finalProductList = new List<ST_Product__c>();
    do
      {
        startingRecCount = startingRecCount + returnRecordCount ;
        
        List<ST_Product__c> productList = new List<ST_Product__c>();
        productList  = makeCallout_Product(startingRecCount, countLimit);
                
        if (productList != null) 
        {
          returnRecordCount = productList.size();
          for(ST_Product__c product : productList)
          {
           finalProductList.add(product) ;
           }
        }
     } while(returnRecordCount == maxRecordinSingleRequest);
    
    if (finalProductList.size() > 0)
    {
        DeleteProduct();
        upsert finalProductList;
    }     
   }
   
   
   public static List<ST_Product__c> makeCallout_Product(integer startingRecCount, integer countLimit)
   {
     List<ST_Product__c> productList = new List<ST_Product__c>();
     try
     {
       String xmlRequestString = createXmlRequest_Product(startingRecCount, countLimit); 
       productList = sendCalloutREST_Product(xmlRequestString);
     }
     catch( Exception ex){
        
     }  
     
     return productList ;
   }
   
   public static string createXmlRequest_Product(integer startingRecCount, integer countLimit)
    {
        String xmlString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:DELL_PCT_PCT_ProductAliasCPYAssocLookUp_WS">';
        xmlString = xmlString + '<soapenv:Header>';
        xmlString = xmlString + '<urn:AuthenticationInfo>';
        xmlString = xmlString + '<urn:userName>'+ System.Label.ST_Remedy_UserName_Product + '</urn:userName>';
        xmlString = xmlString + '<urn:password>' + System.Label.ST_Remedy_Password_Product + '</urn:password>';
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
   
   public static List<ST_Product__c>sendCalloutREST_Product(String xmlRequestString){
        try{
        
              //System.debug ('------------------ xmlRequestString ---------'+ xmlRequestString);  //V1
              
              String endPointURL = System.Label.ST_DP_endPointURL_Product;  //'https://samplesite.com/samplerest'; 
              String userName = System.Label.ST_DP_UserName_Product; //'samuser';
              String password = System.Label.ST_DP_Password_Product; //'Sam@789';
              String host =System.Label.ST_DP_host_Product;                            
              // Specify the required user name and password to access the endpoint 
               // As well as the header and header information              
              Blob headerValue = Blob.valueOf(userName + ':' + password);          
              String authorizationHeader = 'Basic ' +  EncodingUtil.base64Encode(headerValue);                        
              //System.debug('----------------- Header ---'+authorizationHeader );  //V1
            
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
               HttpResponse response;
               //System.debug('----------------- Request ---'+ request); //V1
               if (Test.isRunningTest() == false)
               {
                   response = http.send(request); 
               }
               else
               {
                  response= null;
               }
               //System.debug('------------   Resposne ---------------'+response ); //V1
               
               //Map the data to the list of products
               List<ST_Product__c> productList= ReadResponse_product(response); 
               
               // retrun the final Product List
               return productList; 
                           
          }
          catch(Exception e){
              System.debug('Error::'+e.getMessage());
          }
          
          return null;          
      }
      
      public static List<ST_Product__c>ReadResponse_product(HttpResponse response)
      {
          try{
                Integer Status_code = response.getStatusCode();
                String resp_body = response.getBody();
                //System.debug('--------------------resp_body : ' + resp_body ); //V1
                Boolean result = resp_body.contains('faultstring');                
                If ( result == true)
                   return null;
                else
                    return  readResponseString(resp_body);             
              }                
              Catch (Exception ex)
              {
                   //System.debug('-----ex.getTypeName()--'+ex.getTypeName());    //V1              
                   if (ex.getTypeName()=='SSD_Exception')
                      throw ex;
                   else
                     throw new SSD_Exception('Incident not created : '+ex);
              } 
              return  null; 
          }
          
          public static List<ST_Product__c> readResponseString( String resp_body)
          {
           try
           {
                Dom.Document doc = new Dom.Document();                
                doc.load(resp_body);   
                             
                //Retrieve the root element for this document.                
                Dom.XMLNode Envelope = doc.getRootElement();
                
                Dom.XMLNode Body= Envelope.getChildElements()[0];                
                //system.debug('-------- Body ------'+ Body); //V1
                 
                Dom.XMLNode step1= Body.getChildElements()[0];                
                //system.debug('-------- step1------'+ step1);  //V1
                 
                List<ST_Product__c>productList = new List<ST_Product__c>();
                  
                for(Dom.XMLNode children : step1.getChildElements()) 
                 {
                    ST_Product__c product = new ST_Product__c();
                    for(Dom.XMLNode child : children.getChildElements()) 
                     {
                        if(child.getName() == 'Product_ID')
                             product.Name =child.getText();
                        else if(child.getName() == 'Product_Categorization_Tier_1')
                            product.Product_Categorization_Tier_1__c=child.getText();
                        else if(child.getName() == 'Product_Categorization_Tier_2')
                            product.Product_Categorization_Tier_2__c=child.getText();
                        else if(child.getName() == 'Product_Categorization_Tier_3')
                            product.Product_Categorization_Tier_3__c=child.getText();
                        else if(child.getName() == 'Product_Name')
                            product.Product_Name__c=child.getText(); 
                        else if(child.getName() == 'Product_Alias')
                            product.Product_Alias__c=child.getText(); 
                      }
                      //System.debug('---------- product-------'+product); //V1
                      productList.add(product);
                 }
                 //System.debug('---------- productList-------'+productList); //V1
                 return productList;
              }                
              Catch (Exception ex){
              
                   //System.debug('-----ex.getTypeName()--'+ex.getTypeName());  //V1            
                   if (ex.getTypeName()=='SSD_Exception')
                      throw ex;
                   else
                     throw new SSD_Exception('Incident not created : '+ex);
              } 
              return  null;         
        }
 }