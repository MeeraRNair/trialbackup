/***********************************************************
    * Name          : VFcntrl_DnBLookUpPage
    * Description   : DnB lookup for Deal Reg Analysts
    * ---------------------------------------------------------
    * Revision  Name               Date             Description
    * 1.0       Yeswanth        16.Sep.2016    CR 13500: BUilding DnB search functionality and to populate
                                                         selected duns into end customer duns field tied to opportunity
    * 2.0       Yeswanth        26.Sep.2016    CR 13541: Point DnB search to Deterministic
************************************************************/


public class VFcntrl_DnBLookUpPage {

//Declare variables
    public boolean showCountryError{set;get;}
    public boolean showError{set;get;}
    public map<string,string> countryCodeMap;
    public map<string,string> regionMap;
    public Opportunity oppRecord {get; set;}
    public List<Country__c>  countriesList;
    public Map<String, String> sfdcCountryMap1;
    public Map<String, String> sfdcRegionMap;
    public Map<String, String> sfdcCountryCodeMap;
    public Map<String, String> sfdcDNBCountryCodeMap;
    public Map<String, String> sfdcCountryRegionMap;
    public Set <Country__c> CountryName;
    public List<dunsdetails> finalList{get;set;}
    public Integer totalRun;
    public Set<string>validDnBCountries;
    public Boolean showResultTable {get; set;}
    public Boolean showResultBlock {get; set;}
    public String oMessage{get;set;}
    public string CILresponseBody;
    public string acctName {get;set;}
    public string city {get;set;}
    public string mailingCountry {get;set;}
    public string state {get;set;}
    public Integer SearchOrgReCount;
    public String oCountry{get;set;}
    public String oCountyCode{get;set;}
    public String oCity{get;set;}
    public String oDunsId{get;set;}
    public String oBusinessName{get;set;}
    public String oState{get;set;}
    public String oPostalCode{get;set;}
    public String oAddress1{get;set;}
    public String oOOB{get;set;}
    public boolean isEMEA{get;set;}
    public String oEmployeeSize{get;set;}
    public String oTaxId{get;set;}
    public string CILResError;
    public String country;
    public boolean showErroMsg{get;set;}
    public boolean showSearchBlock{get;set;}
    public boolean isLocalLanguageSearch{get;set;}
    public boolean showLocaLanguageCheckBox{get;set;}
    Public End_Customer__c endCustomer=new End_Customer__c();
    public boolean performDnBSearch{get;set;}
       string requestBody;
     string responseBody;


 public VFcntrl_DnBLookUpPage(ApexPages.StandardController controller) {
  //Initialize variables  
  sfdcCountryMap1 = new Map < String, String > ();
  sfdcRegionMap = new Map < String, String > ();
  sfdcCountryCodeMap = new Map < String, String > ();
  sfdcDNBCountryCodeMap = new Map < String, String > ();
  validDnBCountries = new Set < String > ();
  showErroMsg = false;
  showSearchBlock = true;
  acctName = '';
  city = '';
  state = '';
  mailingCountry = 'None';
  performDnBSearch = false;
  isLocalLanguageSearch = false;
  try{
      countriesList = [SELECT Name,CurrencyIsoCode,Region__c,DNB_COUNTRY_CODE__c,DnB_Supported_Country__c,DNB_Region__c,DNB_ISO_country_code__c FROM Country__c where DnB_Supported_Country__c=true];
      countryCodeMap = new map < string, string > ();
      regionMap = new map < string, string > ();
      sfdcCountryRegionMap = new map<string,string>();
      //Create required country map
      for (country__c temp: countriesList) {
               countryCodeMap.put(temp.Name, temp.DNB_ISO_country_code__c);
               sfdcCountryMap1.put(temp.DNB_Country_Code__c, temp.Name);
               regionmap.put(temp.Name, temp.DNB_Region__c);
               sfdcCountryCodeMap.put(temp.DNB_Country_Code__c, temp.DNB_ISO_Country_Code__c);
               sfdcDNBCountryCodeMap.put(temp.Name, temp.DNB_Country_Code__c);
               validDnBCountries.add(temp.Name);
               sfdcCountryRegionMap.put(temp.Name,temp.Region__c);
      }
      system.debug('***validDnBCountries' + validDnBCountries);

  oppRecord = [select id,name,End_Customer__c, End_Customer__r.Mailing_country__c, End_Customer__r.name,End_Customer__r.Mailing_city__c,
                End_Customer__r.Mailing_State__c from opportunity where id = : ApexPages.currentPage().getParameters().get('id')]; 
     
     if(oppRecord.End_Customer__c!= null){
         acctName = oppRecord.End_Customer__r.name;
         city = oppRecord.End_Customer__r.Mailing_city__c;
         mailingCountry = oppRecord.End_Customer__r.Mailing_country__c;
         state = oppRecord.End_Customer__r.Mailing_State__c;         
         performDnBSearch = true;       
       }
      else{
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is no End Customer record tied to this opportunity'));
      }
      
      markRequired();
          
     }catch (Exception ex) {
          system.debug('----catch 1---' + ex.getMessage());
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
       }
   }
    
     public pagereference markRequired(){
          showResultTable = false;
          showResultBlock = false;
        system.debug('**mailing country'+mailingCountry);
        System.debug('Region:'+sfdcCountryRegionMap.get(mailingCountry));
        isEMEA = false;
        if(sfdcCountryRegionMap.get(mailingCountry) !=null){
            isEMEA = sfdcCountryRegionMap.get(mailingCountry).contains('EMEA');
        }
         
       // Local language checkbox will be enabled for the countries stored in custom setting
       isLocalLanguageSearch = false;
       Map<string,Dnb_Local_language_supported_countries__c> countryMap = Dnb_Local_language_supported_countries__c.getAll();
        Set<String> KeySet = new Set<String>();
        for(String s: countryMap.keySet()){
            KeySet.add(s.toUpperCase());
        }
        if (KeySet.contains(mailingCountry)){
            showLocaLanguageCheckBox = true;
        }else{
            showLocaLanguageCheckBox = false;
        }
         return null;
     }
     public pagereference  goBack() {
      system.debug('Calling Go Back');
      String strOppRecId = ApexPages.currentPage().getParameters().get('id');
      pagereference newPageRef = new pagereference('/'+strOppRecId);
      return newPageRef;
  }
 
    
public pagereference searchDnB(){
    if(performDnBSearch == true){
    try{
        //declare variables
        finalList = new List<dunsdetails>(); 
        showError = false;
        showErroMsg = false;
        showCountryError = false;
        SearchOrgReCount =  0;
        Integer lastcount = 0;
        List<Dom.XmlNode> SearchOrgReList = new List<Dom.XmlNode>();
        List<Dom.XmlNode> OrgExtChilList = new List<Dom.XmlNode>();
        List<Dom.XmlNode> AddressList = new List<Dom.XmlNode>();
        Integer OrgExtChildCount = 0;
        Integer AddressNodeCount  = 0;
        requestBody = '' ;
        responseBody = '';
        
        //check for required fields
        if (acctName == ''||acctName == null||acctName.isWhitespace()||city == ''||city == null||city.isWhitespace()||mailingCountry == 'None'){        
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Field_Custom_Error_label));
            showError = true;
            showResultTable = false;
            showResultBlock = false;
        }
        
         //Add region checking for Mailing_State__c 
                if(sfdcCountryRegionMap.get(mailingCountry) !=null){
                    if ((state == null || state == '' || state.isWhitespace())&& !sfdcCountryRegionMap.get(mailingCountry).contains('EMEA')) {
                        system.debug('***insideIf***');
                      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.Mandatory_Field_Custom_Error_label));
                       showError = true;
                        showResultTable = false;
                        showResultBlock = false;
                    }
                }
                    
    
        country = mailingCountry == 'UNITED KINGDOM'?'England':mailingCountry ;
        System.debug(country);
        if(!validDnBCountries.contains(country) && showError != true ){
            oMessage = System.Label.DealReg_NoRecordFound;
            showResultTable = false;
            showResultBlock = true;
            return null;
        } 

        if(showError != true){
            string countryiso = countryCodeMap.get(country );
            string region = regionMap.get(country);       
            System.debug('**region***'+region);
            System.debug('***Country***'+country);
            System.debug('***countryiso***'+countryiso);
            
            string modifiedOrgname = escapeSpecialChar(acctName);
          string modifiedMailingCity = escapeSpecialChar(city);
          string modifiedMailingState = escapeSpecialChar(state);
             string localLangInd = 'N';
                if(isLocalLanguageSearch){
                    localLangInd = 'Y';                    
                }
                system.debug('**localLangInd***' +localLangInd);

   String requestXMLString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:cus="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:cus1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities" xmlns:cus2="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.PartyEntities" xmlns:cus3="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Utility">'
            +'<soapenv:Header/>'
            +'<soapenv:Body>'
            +'<SearchDnBOrganization xmlns="http://tempuri.org/">'
            +'<searchDNBRequestDTO xmlns:d4p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
            +'<d4p1:OrganizationRequestObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities">'
            +'<d5p1:OrganizationName>'+modifiedOrgname+'</d5p1:OrganizationName>'  //EndCustomer.Name.escapeHtml4()
            +'</d4p1:OrganizationRequestObject>'
            +'<d4p1:CommonObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.PartyEntities">'
            +'<d5p1:SearchType>D</d5p1:SearchType>';
            if(city != null){
                requestXMLString += '<d5p1:CityName>'+modifiedMailingCity+'</d5p1:CityName>';
            }            

            requestXMLString += '<d5p1:CountryType>'+countryiso +'</d5p1:CountryType>';


            if(state !=null ){
                requestXMLString += '<d5p1:Region>'+modifiedMailingState+'</d5p1:Region>';
            }
           
            requestXMLString += '</d4p1:CommonObject>'
            +'<d4p1:LocalLangInd>'+localLangInd+'</d4p1:LocalLangInd>'
            +'<d4p1:BasicFlag>Y</d4p1:BasicFlag>'
            +'<d4p1:AddressFlag>Y</d4p1:AddressFlag>'
            +'<d4p1:MiscFlag>Y</d4p1:MiscFlag>'
            +'<d4p1:ParentFlag>Y</d4p1:ParentFlag>'
            +'<d4p1:PhoneFlag>Y</d4p1:PhoneFlag>'
            +'<d4p1:ContactFlag>Y</d4p1:ContactFlag>'
            +'<d4p1:CrmFlag>Y</d4p1:CrmFlag>'
            +'<d4p1:CompanyDetailsFlag>Y</d4p1:CompanyDetailsFlag>'
            +'<d4p1:Region>'+region+'</d4p1:Region>'
            +'</searchDNBRequestDTO>'
            +'<clientApplicationInfo xmlns:d4p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Utility" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
            +'<d4p1:ApplicationName>SFDC</d4p1:ApplicationName>'
            +'</clientApplicationInfo>'
            +'</SearchDnBOrganization>'                            
            +'</soapenv:Body>'
            +'</soapenv:Envelope>'; 

             // Creating request       
            Httprequest request = new Httprequest();
            request.setMethod('POST');
            request.setHeader('Content-Type','text/xml;charset=UTF-8');
            request.setHeader('SOAPAction',system.Label.MDM_Soap_action);
            if(Environment.isProduction()){                                
                request.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);
                request.setEndpoint(System.Label.Deal_Reg_MDM_CIL_Prod_Url);
            }
            else{
                request.setHeader('Authorization',System.Label.Deal_Reg_MDM_Sandbox_Credentials);
                request.setEndpoint(System.Label.Deal_Reg_MDM_CIL_Sandbox_Url);
            }
            request.setBody(requestXMLString);
            request.setTimeout(integer.valueOf(System.Label.Deal_Reg_timeout_variable));
            httpresponse responseXML;
            system.debug('***Request**' +request.getBody());
            Http http = new Http();

            //retrying in case of failure 
            for(Integer a = 0; a <= integer.valueOf(System.Label.Deal_Reg_retry_count_variable); a++){
                System.debug('Before Send:'+DateTime.now());
                responseXML = http.send(request);  
                System.debug('After Send:'+DateTime.now());             
                if(responseXML.getstatuscode() == 200){
                    CILresponseBody = responseXML.getBody();
                    totalRun = a+1;
                    break;
                }
            }                                   

            CILResError = responseXML.getStatus();
            
             requestBody = request.getBody();
            responseBody = responseXML.getBody();

            System.debug('****Status****' +CILResError);
            System.debug('****Status Code****' +responseXML.getStatusCode());
            
            /**** Exception handling begins*****/
            
            if(!CILResError.contains('OK')  || CILresponseBody.contains('faultcode')){
            //If status is not OK - means failure
                if(!CILResError.contains('OK')){
                    System.debug('Inside error');
                    oMessage = System.Label.Deal_reg_exception_message;
                    showResultTable = false;
                    showResultBlock = true;
                    String ErrorMessage = 'Null';
                    String ErrorCodeValue ;
                    String TransactionIdValue ;
                    
                    try{
                    Dom.Document doc = new Dom.Document();
                    doc.load(responseXML.getBody());
                    Dom.XMLNode rootElement = doc.getRootElement();
                    System.Debug('**rootElement**'+rootElement);
                    
                   Dom.XMLNode Body = rootElement.getChildElements()[0];  // <env:Body>
                   String BodyName = Body.getName();
                   Dom.XMLNode FaultNode;
                   if (BodyName == 'Body') {
                     FaultNode = body.getChildElements()[0];     // <env:Fault>
                   }
                   Dom.XMLNode CodeNode = FaultNode.getChildElements()[0];  // <env:Code>
                   Dom.XMLNode ErrorCode = CodeNode.getChildElements()[0];  //<env:Value>
                    String ErroCodetext = ErrorCode.gettext();
                   ErrorCodeValue = splitMethod(ErroCodetext);
                       System.Debug('**ErrorCodeValue**'+ErrorCodeValue);
                  Dom.XMLNode ReasonNode = FaultNode.getChildElements()[1];  // <env:Reason>
                  Dom.XMLNode TextNode = ReasonNode.getChildElements()[0];  // <env:Text>
                    String TransactionIdtext = TextNode.gettext();
                    TransactionIdValue = splitMethod(TransactionIdtext);
                       System.Debug('**TransactionIdValue**'+TransactionIdValue);
                    Dom.XMLNode TextNode1 = ReasonNode.getChildElements()[1];    // <env:Text>
                    String ErrorMessagetext = TextNode1.gettext();
                    ErrorMessage = splitMethod(ErrorMessagetext);
                       System.Debug('**ErrorMessage**'+ErrorMessage);
                    }
                    catch(Exception ex){
                        System.debug(ex.getMessage());
                        oMessage = System.Label.Deal_reg_exception_message;
                        showResultTable = false;
                        showResultBlock = true;       
                    }
                    finally{
             // insert exception record                  
                   Exception__C exceptionRecord = new Exception__C();
                   exceptionRecord.Process_Name__c = 'Deal Reg Customer Selection';
                   exceptionRecord.Object_type__c = 'User';
                   exceptionRecord.Object_ID__c = userinfo.getUserId();
                   exceptionRecord.Notes__c = ErrorMessage;
                   exceptionRecord.Error_Messages__c = 'Error Code:-'+' ' +ErrorCodeValue + '\n' + 'TransactionId:-'+' '+TransactionIdValue + '\n' + 'Status:-'+' '+CILResError + '\n' + 'Exception occured on Data Power Side';
                   Database.SaveResult resultStatus = database.insert(exceptionRecord);
                  
                 if(resultStatus.isSuccess()){
                     list<attachment> attachlist = new list<attachment>();
                       attachment reqattachment = new attachment();
                       reqattachment.Body = Blob.valueOf(request.getBody());
                       reqattachment.Name = 'Request.txt';
                       reqattachment.ParentId=  exceptionRecord.Id;
                       attachlist.add(reqattachment);
                       
                       attachment responseattachment = new attachment();
                       responseattachment.Body = Blob.valueOf(responseXML.getBody());
                       responseattachment.Name = 'Response.txt';
                       responseattachment.ParentId=  exceptionRecord.Id;
                       attachlist.add(responseattachment);
                     
                       database.insert(attachlist);
                   }                                            
                }
                }

                //if status is OK but response contains failure code
                else if(CILresponseBody.contains('faultcode')){
                    if(CILresponseBody.contains('No Data found') || CILresponseBody.contains('No Record Found') ){
                        System.debug('No Record found');
                        oMessage = System.Label.DealReg_NoRecordFound;
                        showResultTable = false;
                        showResultBlock = true;
                     }
                    
                   else  if(CILresponseBody.contains('DeserializationFailed')){
                        System.debug('No Record found');
                        oMessage = System.Label.DealReg_NoRecordFound;
                        showResultTable = false;
                        showResultBlock = true;
                     } 
             else{
                    System.debug('Inside faultcode');                  
                      oMessage = System.Label.Deal_reg_exception_message;
                        showResultTable = false;
                        showResultBlock = true;
                       String ErrorMessagetext ='Null';
                       String faultCodeValue;
                       String MessageIDValue;
                       
                       
                 try{
                    Dom.Document doc = new Dom.Document();
                    doc.load(CILresponseBody);
                    Dom.XMLNode rootElement = doc.getRootElement();
                    System.Debug('**rootElement**'+rootElement);

                    String rootElementName = rootElement.getName();
                    System.Debug('rootElementName'+rootElementName);                       

               Dom.XMLNode Body = rootElement.getChildElements()[0]; //  <s:Header>
               String BodyName = Body.getName();    
               if (BodyName == 'Header') {
                Dom.XMLNode MessageID = body.getChildElements()[0]; // <MessageId>
                MessageIDValue = MessageID.gettext();
                system.debug('****MessageIDValue****' + MessageIDValue);
                Body = rootElement.getChildElements()[1];
               }
               Dom.XMLNode faultcode = Body.getChildElements()[0]; //  <s:Fault>
               String faultcodename = faultcode.getName();
               System.debug(faultcodename);
               Dom.XMLNode faultstring = faultcode.getChildElements()[0]; // <faultcode> 
               faultCodeValue = faultstring.gettext();
               system.debug('****faultCodeValue****' + faultCodeValue);
               Dom.XMLNode faultstring1 = faultcode.getChildElements()[1]; // <faultstring>
               String faultstringval = faultstring1.getText();
               Dom.XMLNode Detail = faultcode.getChildElements()[2]; // <detail>
               Dom.XMLNode Result = Detail.getChildElements()[0]; // <Result>
               Dom.XMLNode ResultCode = Result.getChildElements()[1]; // <ResultCode>
               String ResultString = ResultCode.getText();
               system.debug('****ResultStatus****' + ResultString);
               Dom.XMLNode ErrorList = Result.getChildElements()[2]; // <ErrorList>
              ErrorMessagetext =''; 
              for(Dom.XMLNode Error : ErrorList.getChildElements()){ // <a:Error>
               Dom.XMLNode ErrorMessage = Error.getChildElements()[0]; // <a:ErrorMessage>
               String ErrorMessageName = ErrorMessage.getname();
               if (ErrorMessageName == 'ErrorMessage') {
                ErrorMessagetext = ErrorMessagetext + '\n' +ErrorMessage.gettext();
                system.debug('****ErrorMessagetext****' + ErrorMessagetext);
               }
                 } 
                 }
               catch(Exception ex){
                        System.debug(ex.getMessage());
                        oMessage = System.Label.Deal_reg_exception_message;
                        showResultTable = false;
                        showResultBlock = true;             
                    }
                 finally{
          // insert exception record         
                Exception__C exceptionRecord = new Exception__C();
                 exceptionRecord.Process_Name__c = 'Deal Reg Customer Selection';
                 exceptionRecord.Object_type__c = 'User';
                 exceptionRecord.Object_ID__c = userinfo.getUserId();
                 exceptionRecord.Notes__c = ErrorMessagetext;
                 exceptionRecord.Error_Messages__c = 'Fault Code:-'+' ' +faultCodeValue + '\n' + 'MessageID:-'+' '+MessageIDValue + '\n' + 'Exception occured on CIL layer';
                 Database.SaveResult resultStatus = database.insert(exceptionRecord);
                 
                 if(resultStatus.isSuccess()){
                     list<attachment> attachlist = new list<attachment>();
                       attachment reqattachment = new attachment();
                       reqattachment.Body = Blob.valueOf(request.getBody());
                       reqattachment.Name = 'Request.txt';
                       reqattachment.ParentId=  exceptionRecord.Id;
                       attachlist.add(reqattachment);
                       
                       attachment responseattachment = new attachment();
                       responseattachment.Body = Blob.valueOf(CILresponseBody);
                       responseattachment.Name = 'Response.txt';
                       responseattachment.ParentId=  exceptionRecord.Id;
                       attachlist.add(responseattachment);
                     
                       database.insert(attachlist);
                   }                
                 }
               }
             }
             return null;
        }  
            
        /**** Exception handling Ends*****/
            
            //if valid records returned in the search
            else {            
                                
                oMessage = '';
                Dom.Document doc = new Dom.Document();
                doc.load(CILresponseBody);
                System.Debug('ResponseBody##' +CILresponseBody);

                Dom.XMLNode rootElement = doc.getRootElement();//envelope

                String rootElementName = rootElement.getName();
                //sazleen update from 1 to 0
                Dom.XMLNode Body = rootElement.getChildElements()[1];//body
                String BodyName =  Body.getName();
                Dom.XMLNode SearchDnBOrganizationResponse = Body.getChildElements()[0];//SearchDnBOrganizationResponse
                String SearchDnBOrganizationResponseName =  SearchDnBOrganizationResponse.getName();
                Dom.XMLNode SearchDnBOrganizationResult = SearchDnBOrganizationResponse.getChildElements()[0];//SearchDnBOrganizationResult
                String SearchDnBOrganizationResultName =  SearchDnBOrganizationResult.getName();
                Dom.XMLNode OrganizationList = SearchDnBOrganizationResult.getChildElements()[2];//OrganizationList
                String OrganizationListName =  OrganizationList.getName();
                
                    for(Dom.XMLNode SearchOrganizationResultElement : OrganizationList.getChildElements()){
                    //initialize all variables for each search
                    oBusinessName =  '';
                    oDunsId =  '';
                    oOOB =  '';
                    oEmployeeSize =  '';
                    oAddress1 =  '';
                    oCity =  '';
                    oCountyCode =  '';
                    oPostalCode =  '';
                    oState =  '';
                    oTaxId =  '';
                    SearchOrgReList.add(SearchOrganizationResultElement);
                    SearchOrgReCount++;

                    String OrgResultTestName =  SearchOrganizationResultElement.getName();

                    // To get Party
                    Dom.XMLNode SeacrhChildOrg = SearchOrganizationResultElement.getChildElements()[0];//<b:Party
                    String SearchChildOrgName = SeacrhChildOrg.getName();
                    Dom.XMLNode PartyChild = SeacrhChildOrg.getChildElements()[0];//<c:Party>
                    String PartyChildName = PartyChild.getName();
                    Dom.XMLNode PartyChild1 = PartyChild.getChildElements()[0];//<c:Organization>
                    String PartyChildName1 = PartyChild.getName();
                    //To get Duns Name
                    Dom.XMLNode OrganizationName = PartyChild1.getChildElements()[0];//<b:OrganizationName>
                    String OrganizationChildtName = OrganizationName.getName();
                    
                    Dom.XMLNode OrganizationName1 = OrganizationName.getChildElements()[0];//<b:OrganizationName>
                    Dom.XMLNode OrganizationNameValue = OrganizationName1.getChildElements()[0];//<b:Name>Center BMW</b:Name>
                    oBusinessName = OrganizationNameValue.getText();
                    System.debug('DUNS NAME' + oBusinessName);
                    
                  // Local language search
                        if(isLocalLanguageSearch){
                            oBusinessName = '';
                            Dom.XMLNode OrganizationNameExtension = OrganizationName1.getChildElements()[1];  // <b:OrganizationNameExtension>
                            Dom.XMLNode OrganizationNameExtension1 = OrganizationNameExtension.getChildElements()[0]; // <d:OrganizationNameExtension>
                            system.debug('***OrganizationNameExtension1**' +OrganizationNameExtension1);
                            Dom.XMLNode localLangDunsName = OrganizationNameExtension1.getChildElements()[0];
                            oBusinessName = localLangDunsName.getText();
                            System.debug('**localLangDunsName***' + oBusinessName);
                        }

                    // to get OrganizationExtensionElement Duns Name, OOB and EmployeeSize
                    Dom.XMLNode OrganizationExtension1 = PartyChild.getChildElements()[0];//<c:Organization>
                    String OrganizationExtensionName1 = OrganizationExtension1.getName();
                    Dom.XMLNode Organizationduns2 = OrganizationExtension1.getChildElements()[1];//<b:OrganizationExtension>get duns details
                    String Organizationdunsname2 = Organizationduns2.getName();
                    for(Dom.XMLNode OrganizationExtensionChild : Organizationduns2.getChildElements()){
                        //Iterate through DUNs details


                        If(OrganizationExtensionChild.getName() == 'DunsNumber'){
                            oDunsId = OrganizationExtensionChild.getText();
                            System.Debug('DunsNumber##' +oDunsId);
                        }
                        If(OrganizationExtensionChild.getName() == 'OutOfBusinessIndi'){
                            oOOB = OrganizationExtensionChild.getText();
                            System.Debug('oOOB' +oOOB);
                        }
                        If(OrganizationExtensionChild.getName() == 'EmployeesTotal'){
                            oEmployeeSize = OrganizationExtensionChild.getText();
                        } 
                        If(OrganizationExtensionChild.getName() == 'NationalId'){
                            oTaxId = OrganizationExtensionChild.getText();
                        }   
                    }

                    Dom.XMLNode PartyAddressElement = PartyChild.getChildElements()[1];//<c:PartyAddress>
                    String PartyAddressElementName = PartyAddressElement.getName();
                    Dom.XMLNode PartyAddressChildElement = PartyAddressElement.getChildElements()[0];//<c:PartyAddress>
                    String PartyAddressChildElementName = PartyAddressChildElement.getName();
                    Dom.XMLNode AddressElement = PartyAddressChildElement.getChildElements()[1];//<c:Address>
                    String AddressElementdName = AddressElement.getName();

                         for(Dom.XMLNode AddressChild : AddressElement.getChildElements()){
                        //iterate to get address elements
                        AddressList.add(AddressChild);
                        AddressNodeCount++;

                        If(AddressChild.getName() == 'AddressLineOne'){//need to add null checking
                            oAddress1 = AddressChild.getText();
                        }
                        If(AddressChild.getName() == 'City'){
                            oCity = AddressChild.getText();
                            System.Debug('oCity' +oCity);
                        }
                        If(AddressChild.getName() == 'CountryValue'){ 
                            oCountyCode = AddressChild.getText();
                            oCountyCode = String.valueOf(Integer.valueOf(oCountyCode));
                            System.Debug('oCountry' + oCountyCode);
                        }

                        If(AddressChild.getName() == 'ZipPostalCode'){
                            oPostalCode = AddressChild.getText();
                        }
                        If(AddressChild.getName() == 'Region'){
                            oState = AddressChild.getText();
                        }
                       // local language search                               
                            if(isLocalLanguageSearch){                               
                                if(AddressChild.getName() == 'AddressExtension'){
                                    Dom.XMLNode AddressExtension = AddressChild.getChildElements()[0]; // <d:AddressExtension>
                                    system.debug('**AddressExtension***' +AddressExtension);
                                    for(Dom.XMLNode LocalLangAddressChild : AddressExtension.getChildElements()){
                                          If(LocalLangAddressChild.getName() == 'LocallangAddrLineOne'){
                                                oAddress1 = '';
                                                oAddress1 = LocalLangAddressChild.getText();
                                                System.Debug('LocalLangAddress1' +oAddress1);
                                            }
                                            If(LocalLangAddressChild.getName() == 'LocallangCity'){
                                                oCity = '';
                                                oCity = LocalLangAddressChild.getText();
                                                System.Debug('LocalLangCity' +oCity);
                                           }
                                        If(LocalLangAddressChild.getName() == 'LocallangState'){
                                              oState = '';
                                              oState = LocalLangAddressChild.getText();
                                       }
                                    }
                                }
                            }
                        
                    }
                    //added by Rap
                oCountry = sfdcCountryMap1.get(oCountyCode);   //commented because map was not fetching any values
            
               if (oCountry == NULL){
                        oCountry = mailingCountry;           
                  }
                    System.debug('this is sfdc country: ' + oCountry);
                    if(oOOB == 'N' &&oAddress1 != ''){   // oCountry.equalsIgnoreCase(mailingCountry) && 
                        finalList.add(new dunsdetails(false,oAddress1,oBusinessName,oCity,oCountry,oCountyCode,oDunsId,oOOB,oPostalCode,oState,oEmployeeSize,oTaxId));
                    }
                    System.debug('FINALLIST'+finalList);

                }
            if(!finalList.isEmpty()){
                showResultTable = true;
                showResultBlock = true;
            }
            else{
                oMessage = System.Label.DealReg_NoRecordFound;
                showResultTable = false;
                showResultBlock = true;
            }
        }
    }
    }catch(Exception e){
        System.debug(e.getMessage());
        oMessage = 'Exception Occured while doing D&B Search. Error Message: '+e.getMessage();
        showResultTable = false;
        showResultBlock = true;
        
        if(!test.isRunningTest()){ 
        // Creating exception record for unhandled exceptions
              Exception__C exceptionRecord = new Exception__C();
                   exceptionRecord.Process_Name__c = 'Deal Reg Customer Selection';
                   exceptionRecord.Object_type__c = 'User';
                   exceptionRecord.Object_ID__c = userinfo.getUserId();
                   exceptionRecord.Error_Messages__c = e.getMessage();
                   Database.SaveResult resultStatus = database.insert(exceptionRecord);
                  
                 if(resultStatus.isSuccess() && requestBody!= '' && responseBody != '' && requestBody!= null && responseBody != null){
                     list<attachment> attachlist = new list<attachment>();
                       attachment reqattachment = new attachment();
                       reqattachment.Body = Blob.valueOf(requestBody);
                       reqattachment.Name = 'Request.txt';
                       reqattachment.ParentId=  exceptionRecord.Id;
                       attachlist.add(reqattachment);
                       
                       attachment responseattachment = new attachment();
                       responseattachment.Body = Blob.valueOf(responseBody);
                       responseattachment.Name = 'Response.txt';
                       responseattachment.ParentId=  exceptionRecord.Id;
                       attachlist.add(responseattachment);
                     
                       database.insert(attachlist);
                   }  
        }
    }
    System.debug(oMessage);
}
    return null;
    }

  // Method to fetch country values from end customer mailing country picklist field
  public List<SelectOption> getcountries() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','--None--'));
        Schema.DescribeFieldResult fieldResult = end_customer__C.Mailing_country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        options.add(new SelectOption(p.getValue(), p.getValue()));        
        return options;
    }
    
    
  // Add customer to Deal method  
     public pagereference addCustomerToDeal(){
      end_Customer__c endcustomer = new end_customer__c();
       showError = false;  
         try{
            string selectedduns = System.currentPagereference().getParameters().get('selectedDUnsId');

                if(selectedduns == null){
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.DealReg_no_record_selected));
                     showError = true;
                 }
               else{
                           endcustomer.DUNS_Number__c = string.valueof(selectedduns);
                           endcustomer.id = oppRecord.End_Customer__c;
                           update endcustomer;    
                           return new PageReference('javascript:window.self.close()');
                  }
         }catch (exception ex){
             system.debug('----catch 2---' + ex.getMessage());
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
              showError = true;
              showResultTable = false;
              showResultBlock = false;
          }
            return null;  
     }

 public class dunsdetails{
        public boolean selected{get;set;}
        public string Address{get;set;}
        public string DunsName{get;set;}
        public string City{get;set;}
        public string Country{get;set;}
        public string CountyCode{get;set;}
        public string DunsId{get;set;}
        public string OOB{get;set;}
        public string PostalCode{get;set;}
        public string State{get;set;}
        public string EmployeeSize{get;set;}
        public string TaxId{get;set;}
        

  public dunsdetails(Boolean selected, String Address, String DunsName, String City, String Country, String CountyCode, String DunsId, String OOB, String PostalCode, String State, String EmployeeSize, String TaxId) {
   this.selected = selected;
   this.Address = Address;
   this.DunsName = DunsName;
   this.City = City;
   this.Country = Country;
   this.CountyCode = CountyCode;
   this.DunsId = DunsId;
   this.OOB = OOB;
   this.PostalCode = PostalCode;
   this.State = State;
   this.EmployeeSize = EmployeeSize;
   this.TaxId = TaxId;
  }
 }

// Method to split the error code,transaction id and error message from response   
 public string splitMethod(String text) {
  if (text != null) {
   list < String > textSplitValues = new list < String > ();
   textSplitValues = text.split(':');
   String SplitValue = textSplitValues[1];
   return SplitValue;
  }
  return null;
 }

 // Method to escape special characters in Input
 public string escapeSpecialChar(String text) {
  if (text != null) {
   system.debug('html4escaped:' + text.escapeHtml4());
   string modifiedText = text.replace('"', '&quot;').replace('<', '&lt;').replace('>', '&gt;').replace('&', '&amp;');
   system.debug('****modifiedtext***' + modifiedText);
   return modifiedText;
  }
  return null;
 }
}