/*---------------------------------------------
Description: Class to send data to SQL DB2016
CR# 13831
Author: Uday

* Revision CR Number           Release No      Date            Modified By     Description
* -------- ---------           ----------      -----------     ------------    -----------
* 1.0 -     15997,16000,16007   FY18-DCS-0102   06-06-2018:    khanm37, manip4  Decommisioned netexam and Provisioned_in_Netexam_on__c as Part of Story# 4988554 & 4988525 
* 1.1 -     16001               FY18-DCS-0102   18-06-2018:     manip4          Decommisioned Json attributes as part of "NET007 - Enhancement on existing Profiling Services Integration" story
*
--------------------------------------------*/


    public class PartnerPortalProfilingserviceIntegration{

      public static final Integer TIMEOUT=120000;
      public static final String METHOD='POST';
      public static  String USERNAME;
      public static  String PASSWORD;
      public static  String ENDPOINT;
      public static  boolean authenticationRequired = true;  
      public static String PassedRecId;
          

          
      public static void  integratePartnerDataWithAccount(String recordId) {
               
                integratePartnerDataWithAccountOrContact(recordId, null);
      }

      public static String integratePartnerDataWithContact(String recordId) {
     
            return integratePartnerDataWithAccountOrContact(recordId, null);
      }
    
      public static String integratePartnerDataWithAccountOrContact(String recordId, String userId) {
      
            String recordIdPrefix;  
            recordIdPrefix = StringUtils.defaultString(StringUtils.substring(recordId, 0, 3));
          
        
            //Determine if the recordid is of a Contact     
            if(recordIdPrefix.equals(Contact.sObjectType.getDescribe().getKeyPrefix())){                    
                return sendContactInfo(recordId, userId);
            }
            
              if(recordIdPrefix.equals(Account.sObjectType.getDescribe().getKeyPrefix())){ 
              Account a = [select id,(select id,Partner_User__c,Partner_My_Account_GUID__c,Partner_User_Active__c  from Contacts where Partner_User__c != null  and Partner_My_Account_GUID__c != null and Partner_User_Active__c=true) From Account where id=:recordId] ;                  
                if(a.contacts.size()>0){
                return sendAccountInfo(String.valueOf(a.contacts[0].id), userId);
                }
            }
            return null;                
        }
        
      public static String sendAccountInfo(String recordId, String userId){
            return sendContactInfo(recordId, userId, false);
         }
     
      public static String sendContactInfo(String recordId, String userId){
            return sendContactInfo(recordId, userId, false);
        }
     
     
      public static String sendContactInfo(String recordId, String userId, boolean isDisabled){
        PassedRecId = recordId;
        
        String requestBody = getContactRequestBody(recordId, userId);
         
        if(requestBody != null) { 
            
            System.debug('##### RequestBody : '+ requestBody);         
            //calls the method to send the request.

            return sendHttpRequest(requestBody).getbody();       

         
         }   
         return null;
      }
     
     

       private static String getContactRequestBody(String recordId, String userId) {
        List<User> userList = new List<User>();
        
        List<Contact> contactList=[SELECT Account.Partner_Registration__r.Country__r.User_Language_Locale_Key__c,Account.Partner_Registration__r.Country__r.Code__c,id,Email,Partner_My_Account_GUID__c,Account.Partner_Registration__c,Account.Account_ID__c, AccountId, 
                                    Is_Rebate_User__c, 
                                   Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, Warranty_parts_Info__c
                                   ,Is_Enabled_for_Incentives__c,Is_Incentives_Updated__c,Vendor_Update_Datetime__c,Last_Operation_Performed__c,
                                   Is_Vendor_Updated__c,Account.Partner_Type__c,Account.Partner_Relationship__c,
                                   Account.Partner_Tier__c,Account.Account_Country__c,Account.Account_Country_Code__c,
                                   Account.Sales_Channel__r.name,Account.Name,Account.States_Provinces_doing_business__c,
                                   Account.IsPartner,Account.Dell_Certification_Areas__c,
                                   Account.Partner_Registration__r.Partner_Terms_Conditions__c,Account.Partner_Registration__r.Export_Compliance_Agreed__c,
                                   Account.Is_Incentive_Updated__c,Account.Vendor_Update_Datetime__c,Account.Is_Vendor_Updated__c,
                                   Account.New_Partner_Programme_T_C_s__c,Account.Partner_Level__c,Account.Strategic_Programs__c,Account.Is_Enabled_for_Incentives__c,Account.last_Operation_Performed__c
                                   FROM Contact 
                                   WHERE id=:recordId AND Partner_My_Account_GUID__c != null]; 
        
        if(contactList.size()>0){
           
                if(userId == null) {
            //Get Corresponding User info
                userList=[Select IsActive, LastName, LanguageLocaleKey, FirstName,ContactId,Enable_Partner_Deal_Registration__c, 
                          Enable_Partner_Admin__c,Enable_Partner_Lead_Management__c,
                          //remove for FAP packaging 
                          Is_Admin_for_Partner_Finder_Profile__c,
                          LastLoginDate,TimeZoneSidKey 
                          From User where ContactId=:recordId];
            }
            else {
                userList=[Select IsActive, LastName, LanguageLocaleKey, FirstName,ContactId,Enable_Partner_Deal_Registration__c, 
                          Enable_Partner_Admin__c,Enable_Partner_Lead_Management__c,
                          //remove for FAP packaging
                          Is_Admin_for_Partner_Finder_Profile__c,
                          LastLoginDate,TimeZoneSidKey 
                          From User where Id=:userId];                 
            }  
       
                                 
            if( userList.size()==0){ 
                 
                 return null;
            }
            //craete request body for Contact profile  
            String requestBody = createContactHTTPRequestBodyStringForDataPower(contactList[0],userList[0]);  
            
            return requestBody;
        }
        else {
            return null;
        }
     } 
       //Method to create Contact Info HTTP Request body
     public static String createContactHTTPRequestBodyStringForDataPower(Contact contactRecord,User userRecord){
   
          JSONGenerator objGen = JSON.createGenerator(false);
          
          objGen.writeStartObject();
          objGen.writeObjectField('contactId', contactRecord.Partner_My_Account_GUID__c ); 
          objGen.writeEndObject();


         String strJsonOutput = objGen.getAsString();
       


        return strJsonOutput;
    }
    
    
    //athentication Method   
   private static void setAuthenticationInfo() {

      //Set header parameters for Production    
        if(UserInfo.getOrganizationId() == '00D300000006urqEAA') { 
            USERNAME=System.Label.DP_API_PP_PROD_UNAME;  //for PRODUCTION env
            PASSWORD=System.Label.DP_API_PP_PROD_PASSWORD; // to be filled in later
            ENDPOINT= System.Label.DP_API_PP_PROD;
     
        }
        //Set header parameters for Sandbox 
        else{
            USERNAME=System.Label.DP_API_PP_SB_UNAME;
            PASSWORD=System.Label.DP_API_PP_SB_PASSWORD;
            ENDPOINT= System.Label.DP_API_PP_SB;
            //'https://soagw-dmznonprod.ins.dell.com/api/G3/profile/upsert';
            authenticationRequired = true;
        }   
        

    }
    
    
   //Method to create HTTPRequest Header
   public static HttpRequest createHttpRequestHeader(){
    

        HttpRequest req = new HttpRequest();
       
        setAuthenticationInfo();
        
        //Set endpoint URL      
        req.setEndpoint(ENDPOINT);
        //Set the method Type
        req.setMethod(METHOD);
        if(authenticationRequired){
                        
            // Specify the required user name and password to access the endpoint
            // As well as the header and header information     
            Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type','application/json');
        }
        
        
        //Set the timeout value for the Request
        req.setTimeout(TIMEOUT);
        return req; 
    }   
        
      
 public static HTTPResponse  sendHttpRequest(String requestBody){

        //method call to create HttpRequest
        HttpRequest req=createHttpRequestHeader();      
        //sets the request body
        req.setBody(requestBody);
    
        Http http = new Http();
             
         //Sending the HTTP request
          HTTPResponse res  =new  HTTPResponse() ;
     
          if(!Test.isRunningtest()){
                res  =http.send(req); 
             }
              
      
         System.debug('###### Request is :'+requestBody);
         System.debug('>>>>>>>>>>>> Responce is : '+res);
      System.debug('>>>>>>>>>>>> Responce is : '+System.Label.statusCode.contains(String.ValueOf( res.getStatusCode())));
      if(!System.Label.statusCode.contains(String.ValueOf( res.getStatusCode())) || !res.getBody().contains('success') ){
         try{
           if(System.Label.CreateException=='True'){  
            System.debug('inserting exception');
            //if Responce we got is not success insert a record in EXCEPTION Object
            //and Attach the Request JSON STRING As Attachment to That Particular Record
            
             Exception__c exc = new Exception__c();
             exc.Process_Name__c = 'Partner profile Integration';
             exc.Error_Messages__c  = String.valueOf(res.getStatusCode());
             exc.Object_type__c = 'Account/Contact';
             exc.Object_ID__c = PassedRecId;
             exc.Notes__c = res.getBody();
             
             PartnerProfileIntegration.lstException.add(exc);
             //insert exc;
            
             Attachment attachment = new Attachment();
             attachment.Body = Blob.valueOf(requestBody);
             attachment.Name = String.valueOf(PassedRecId+'.txt');
             PartnerProfileIntegration.lstAttachment.add(attachment);
             //attachment.ParentId = exc.id; 
             //insert attachment;
            }
            }catch(exception ex){
             System.debug('Failed to insert Exception');
             }
         
         }
          
        return res;      
    }
   
}