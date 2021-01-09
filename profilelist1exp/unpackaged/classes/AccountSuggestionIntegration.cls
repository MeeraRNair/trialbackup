public class AccountSuggestionIntegration{
/*
 * Author   : Niveda
 * Purpose  : This is the controller to send request for duplicate account check in affinity and proceed to create new account/associate with an existing account(11867).
 *
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      12387       16.12       	01-Dec-2015     Niveda           Created New method to send webservice request to activate account in Affinity
 * 2.0      15697       FY19-DCS-0602  	27-Apr-2018     Pallavi          Removed activate Account record type reference as part of Story 4168524   
 * 3.0                  FY19-DCS-0902	01-Aug-2018		Shue			 Story 5199685: Lead 2.0 - Update the Territory assignment end date to blank during Account XML generation
*/
    public final static String SANDBOX = 'Sandbox';
    public final static string START_TAG= 'dell';
    public final static string START_URL= 'http://schemas.xmlsoap.org/soap/envelope/';
    public final static string ENV_URL =  'http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Request';
    public final static string NAMESPACE_URL ='https://soagw-dmznonprod.ins.dell.com';
    public final static string RESPONSE_NAMESPACE_URL ='http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response';
    public static final Integer TIMEOUT = 120000;
    public static final String METHOD = 'POST';
    public static  boolean AUTHENTICATIONREQUIRED = false;
    public static  String USERNAME;
    public static  String PASSWORD;
    public static  String ENDPOINT;
    public static User currentUser;
    public static string regionName;
    public static string countryName;
    
    public static Map<String,String> regionMap=new Map<String,String> 
                                                        {'APJ' => 'ASIA_PACIFIC',
                                                        'EC-EMEA' => 'EUROPE',
                                                        'EMEA' => 'EUROPE',
                                                        'LATAM' => 'AMERICAS',
                                                        'LA' => 'AMERICAS',
                                                        'NA' => 'AMERICAS'}; 
    
    //Send request to affinity to create a new account.
    public static AccountSuggestionResponse sendAccountSuggestion(Lead leadRecord, Boolean isDupCheckRequired){
        AccountSuggestionResponse response = new AccountSuggestionResponse();
        string initialResponse;
        if(leadRecord!=null){
            //create request body from the Account record
            String requestBody = createAccountsuggestionHTTPRequestBodyString(leadRecord, isDupCheckRequired);
            initialResponse = sendHttpRequest(requestBody,'CreateAccount');
            response = AccountSuggestionResponse.parseResponseString(initialResponse );
        }
        return response;
    }
    
    //Send request to affinity to activate a account which is at Under Review status
    public static AccountSuggestionResponse sendAccountActivationRequest(Account accountRecord){
        AccountSuggestionResponse response = new AccountSuggestionResponse();
        string initialResponse;
        if(accountRecord !=null){
            //create request body from the Account record
            String requestBody = createActivateAccountHTTPRequestBodyString(accountRecord);
            initialResponse = sendHttpRequest(requestBody,'UpdateAccount');
            response = AccountSuggestionResponse.parseResponseString(initialResponse );
        }
        return response;
    }
    
    //Method to send HTTPRequest
    public static String sendHttpRequest(String requestBody, String action){
        //method call to create HttpRequest
        HttpRequest req=createHttpRequestHeader(action);
        req.setBody(requestBody);
        Http http = new Http();
        //Sending the HTTP request
        HTTPResponse res = http.send(req);
        return res.getBody();
    }
    
    //Method to create HTTPRequest Header
    public static HttpRequest createHttpRequestHeader(string action){
        if(StaticFactory.getEnvironment() == SANDBOX) {
            USERNAME='AffinitySearch';
            PASSWORD='MDM@d3ll';
            ENDPOINT='https://soagw-dmznonprod.ins.dell.com:443/CIL/AffinityService.svc/ws';            
            AUTHENTICATIONREQUIRED = true;
        }
        //Set header parameters for Sandbox 
        else{
            USERNAME= System.Label.Affinity_Prod_UserName;  //for PRODUCTION env
            PASSWORD= System.Label.Affinity_Prod_Pwd;  
            //Rev 4.0 - start
            ENDPOINT= System.Label.Affinity_Prod_Endpoint;
            //Rev 4.0 - end 
            AUTHENTICATIONREQUIRED = true;
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        String actionMethod = 'CIL/IExploreAffinity/'+action;        
        req.setHeader('SOAPAction',actionMethod );
        req.setMethod(METHOD);
        
        // Specify the required user name and password to access the endpoint
        // As well as the header and header information 
        if(AUTHENTICATIONREQUIRED){ 
            Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
        }
        
        //Set the timeout value for the Request
        req.setTimeout(TIMEOUT);
        return req; 
    }   
    
    //Build xml request body - To create account
    public static String createAccountsuggestionHTTPRequestBodyString(Lead leadRecord, Boolean isDupCheckRequired){
        
        currentUser = StaticFactory.getCurrentUserDetails();
        String toDateInString = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
        User leadOwner = StaticFactory.getUserDetails(leadRecord.ownerid);
        string legacyId = 'SFDC_'+leadRecord.id;
        Country__c leadCountry =[Select name, code__c, region__c from country__c where id =: leadRecord.Physical_Country__c limit 1];
        
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement('soapenv', 'Envelope', START_URL);
        w.writeNamespace('soapenv', START_URL);
        w.writeNamespace('cil', 'CIL');
        w.writeNamespace(START_TAG, ENV_URL);
        
        //Header
        w.writeEmptyElement('soapenv','Header',START_URL);
        
        //Body
        w.writeStartElement('soapenv', 'Body', START_URL);
        w.writeStartElement('cil','CreateAccount',NAMESPACE_URL);
        w.writeStartElement('cil','request',NAMESPACE_URL);
        if(leadRecord.city != null || leadRecord.Street != null || leadRecord.Country != null || leadRecord.State != null){
        w= IntegrationUtilities.startElement(w,'AddressInformation',START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.startElement(w,'AccountAddressInfo',START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Street',START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w,'AddressType','Physical',START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'City',START_TAG, NAMESPACE_URL);
            w= IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Company', START_TAG, NAMESPACE_URL);
            w= IntegrationUtilities.addElementAndValueString(w, 'CountryCode',leadCountry.code__c, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'County', leadRecord, 'Country',START_TAG, NAMESPACE_URL);           
            w = IntegrationUtilities.addElementAndValueString(w,'PostalAddressIsSameAsPhysicalAddress','Yes',START_TAG, NAMESPACE_URL); 
            w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'PostalCode',START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'State',START_TAG, NAMESPACE_URL);   
           w.writeEndElement();
        w.writeEndElement();//end AddressInformation 
        }        
        w= IntegrationUtilities.startElement(w,'BasicInformation',START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'AccountCategory','EndUser', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValue(w, 'AccountName', leadRecord, 'Company', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'AccountStatus','Review', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'AccountType','Account', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValue(w, 'CFIProjectNumber', leadRecord, 'CFI_Project_Numbers__c', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'CountryCode',leadCountry.code__c, START_TAG, NAMESPACE_URL);            
             w= IntegrationUtilities.addElementAndValueString(w, 'DmuFlag','Yes', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'EffectiveDate',toDateInString, START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'HierarchyType','SALES', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'LegacyID',legacyId, START_TAG, NAMESPACE_URL);  
             w= IntegrationUtilities.addElementAndValue(w, 'SalesModelCode', leadRecord, 'Sales_Model_Code__c', START_TAG, NAMESPACE_URL);
        w.writeEndElement();//end BasicInformation
        if(isDupCheckRequired)
         w= IntegrationUtilities.addElementAndValueString(w, 'RequireMatchedAccountInformation','Yes', START_TAG, NAMESPACE_URL);
        else
         w= IntegrationUtilities.addElementAndValueString(w, 'RequireMatchedAccountInformation','No', START_TAG, NAMESPACE_URL);
        
      
        w= IntegrationUtilities.startElement(w,'SalesRepInformation',START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.startElement(w,'AccountSalesRepInfo',START_TAG, NAMESPACE_URL);
           w= IntegrationUtilities.addElementAndValueString(w,'Action', 'Add', START_TAG, NAMESPACE_URL);
           w= IntegrationUtilities.addElementAndValueString(w,'AssignmentType', 'Direct', START_TAG, NAMESPACE_URL);
           w= IntegrationUtilities.addElementAndValueString(w,'BadgeNumber', leadOwner.Badge_Number__c, START_TAG, NAMESPACE_URL);
           w= IntegrationUtilities.addElementAndValueString(w,'Ownerforaccount', 'Yes', START_TAG, NAMESPACE_URL);
           w= IntegrationUtilities.addElementAndValueString(w,'PrimaryAssignee', 'Yes', START_TAG, NAMESPACE_URL);         
           //3.0 leave the date blank -- w= IntegrationUtilities.addElementAndValueString(w,'ResourceRoleEndDate', '9999-07-21T13:38:00', START_TAG, NAMESPACE_URL);
           w= IntegrationUtilities.addElementAndValueString(w,'ResourceRoleStartDate', toDateInString, START_TAG, NAMESPACE_URL);          
         w.writeEndElement();//end AccountSalesRepInfo
        w.writeEndElement();//end SalesRepInformation
        
        w= IntegrationUtilities.startElement(w,'SuggestionInformation',START_TAG, NAMESPACE_URL);
         string region = regionMap.get(leadCountry.region__c);

         w= IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber',leadOwner.Badge_Number__c, START_TAG, NAMESPACE_URL); 
         w= IntegrationUtilities.addElementAndValueString(w, 'CreatedByModule','SFDC_LM', START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'Region',region, START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'SuggestionComments','', START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'SuggestionReason','Generic', START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'SuggestionStatus','Approved', START_TAG, NAMESPACE_URL);
        w.writeEndElement();//end SuggestionInformation
        
        w= IntegrationUtilities.startElement(w,'TerritoryInformation',START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.startElement(w,'AccountTerritoryInfo',START_TAG, NAMESPACE_URL);
         String territoryGroupId; 
         String territoryGroupName;

         if(leadRecord.Territory_Assignment__r.Group_ID__c == null ){
          Sales_Channel_Group__c salesChannelObj = [ select name , Group_ID__c from Sales_Channel_Group__c where id =: leadRecord.Territory_Assignment__c];
            territoryGroupId = salesChannelObj.Group_ID__c;
            territoryGroupName = salesChannelObj.Name;
          }
         else{
             territoryGroupId = leadRecord.Territory_Assignment__r.Group_ID__c;
             territoryGroupName = leadRecord.Territory_Assignment__r.Name;
         }
         w= IntegrationUtilities.addElementAndValueString(w, 'Action','Assign', START_TAG, NAMESPACE_URL);
         //3.0 leave the date blank -- w= IntegrationUtilities.addElementAndValueString(w, 'AssignmentEndDate','9999-07-21T13:38:00', START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'AssignmentStartDate',toDateInString, START_TAG, NAMESPACE_URL);
         if(territoryGroupId != null && territoryGroupName != null){
             w= IntegrationUtilities.addElementAndValueString(w, 'GroupID',territoryGroupId, START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'GroupName',territoryGroupName, START_TAG, NAMESPACE_URL);
         }
         w.writeEndElement();//end AccountTerritoryInfo
         w.writeEndElement();//end TerritoryInformation

         w.writeEndElement(); // end cilRequest
         w.writeEndElement(); // end createAccount
         w.writeEndElement(); //end Body
         w.writeEndElement(); //end envelope
         String xmlOutput = w.getXmlString();
         w.close();
         System.debug('Shue test xmlOutput ---- '+xmlOutput);
         return xmlOutput;
    } 
    
    //v1.0 - When opportunity stage is changed , the method automatically sends webservice call to affinity to activate the related account
    @future(callout=true)
    public static void activateAccountInAffinity(set<id> oppIds){
      map<id,id> oppAccMap = new map<id,id>();
      AccountSuggestionResponse response = new AccountSuggestionResponse();
      list<Account> accountList = new list<Account>();
      for(Opportunity opp : [select id, accountid from opportunity where id in: oppIds]){
       oppAccMap.put(opp.AccountId,opp.Id);
      }
      if(oppAccMap.keyset() != null ){
      for( Account acct: [select Id, Name, Dell_Services_Industry__c, Account_ID__c,Account_Country_Code__c,Sales_Channel__c, Owner.FirstName, Owner.LastName,BillingCountry,BillingStreet,BillingCity,BillingPostalCode,BillingState,Suggestion_ID__c
                                                       from Account where Id in :oppAccmap.keyset() and Suggestion_ID__c != null and Account_ID__c != null and Status__c =: 'U' and Account_Country_Code__c != null and Activate_Suggestion_Id__c = null limit 1]){
          accountList.add(acct);
      }
      
      if(accountList != null && accountList.size() >0 ){
          response = sendAccountActivationRequest(accountList[0]);
          if(response != null && response.error != null){
             Exception__c except = new Exception__c(Object_Type__c = 'Account',Error_Messages__c = response.error,Object_ID__c=accountList[0].id,Process_Name__c ='Affinity Account Activation Call',Opportunity_Failed__c = oppAccMap.get(accountList[0].id));
             insert except; 
          }
          else if(response != null && response.SuggestionId != '0' && !String.isBlank(response.SuggestionId)){
             
             Account acct = new Account (id = accountList[0].id,Activate_Suggestion_Id__c= response.SuggestionId );
             update acct;
          }
       }
     }
    }
    
    //Build xml request body - To activate account 
    public static String createActivateAccountHTTPRequestBodyString(Account accountRecord){
        currentUser = StaticFactory.getCurrentUserDetails();
        String toDateInString = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
        string legacyId = 'SFDC_'+accountRecord.id;
        User accountOwner = StaticFactory.getUserDetails(accountRecord.ownerid);
        Country__c accountCountry =[Select name, code__c, region__c from country__c where code__c =: accountRecord.Account_Country_Code__c limit 1];
        string region = regionMap.get(accountCountry.region__c);
        regionName = accountCountry.region__c ;
        countryName = accountCountry.name ;
        
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement('soapenv', 'Envelope', START_URL);
        w.writeNamespace('soapenv', START_URL);
        w.writeNamespace('cil', 'CIL');
        w.writeNamespace(START_TAG, ENV_URL);
        
        //Header
        w.writeEmptyElement('soapenv','Header',START_URL);
        
        //Body
        w.writeStartElement('soapenv', 'Body', START_URL);
        w.writeStartElement('cil','UpdateAccount',NAMESPACE_URL);
        w.writeStartElement('cil','request',NAMESPACE_URL);

        w= IntegrationUtilities.startElement(w,'BasicInformation',START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'AccountCategory','EndUser', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'AccountId',accountRecord.Account_ID__c, START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'AccountName',accountRecord.name, START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'AccountType','Account', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'CFIProjectNumber','', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'CountryCode',accountCountry.code__c, START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'DmuFlag','Yes', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'EffectiveDate',toDateInString, START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'HierarchyType','SALES', START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'LegacyID',legacyId, START_TAG, NAMESPACE_URL);
             w= IntegrationUtilities.addElementAndValueString(w, 'SalesModelCode','', START_TAG, NAMESPACE_URL);
        w.writeEndElement();//end BasicInformation
        w= IntegrationUtilities.startElement(w,'SuggestionInformation',START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber',accountOwner.Badge_Number__c, START_TAG, NAMESPACE_URL); 
         w= IntegrationUtilities.addElementAndValueString(w, 'CreatedByModule','SFDC_LM', START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'Region',region, START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'RelatedSuggestionIds','0', START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'SuggestionComments','', START_TAG, NAMESPACE_URL); 
         w= IntegrationUtilities.addElementAndValueString(w, 'SuggestionReason','TypoCorrection', START_TAG, NAMESPACE_URL);
         w= IntegrationUtilities.addElementAndValueString(w, 'SuggestionStatus','Pending', START_TAG, NAMESPACE_URL);
        w.writeEndElement();//end SuggestionInformation
        
        w= IntegrationUtilities.addElementAndValueString(w, 'SuggestionUpdateAction','Activate', START_TAG, NAMESPACE_URL);
           
        w.writeEndElement(); // end cilRequest
        w.writeEndElement(); // end updateAccount
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
      }
}