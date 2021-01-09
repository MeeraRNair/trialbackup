/* Revision  Name               Date                 CR         Release No            Description
* 1.0       Yeswanth           13.08.2018            16266   Fy-19-DCS-0902       Created for Address validation service in Partner Registration form
*/

global without sharing class PartnerRegistrationAddressValidationExt {
    
    @AuraEnabled
    global static List<dunsdetails> searchDnB(String countryFromCmp,String cityFrmCmp,String stateFrmCmp,String cmpnyNameFrmCmp,boolean localLanguageIndicator){
        // Variables Declaration  
        List<dunsdetails> finalList = new List<dunsdetails>();           
        String requestBody;
        String responseBody;
        String CILResError;
        String CILresponseBody;
        string country;
        Integer totalRun;
        String oCountry;
        String oCountyCode;
        String oCity;
        String oDunsId;
        String oBusinessName;
        String oState;
        String oPostalCode;
        String oAddress1;
        String oOOB;
        String oMessage;
        List<Dom.XmlNode> SearchOrgReList = new List<Dom.XmlNode>();
        List<Dom.XmlNode> AddressList = new List<Dom.XmlNode>();
        List<Country__c>  countriesList = new List<Country__c>();
        Map<String, String> sfdcCountryMap1 = new map<string,string>();
        map<id,String> countryIdMap = new map<id,String>();
        Map<String, String> countryCodeMap = new map<string,string>();
        Map<String, String> regionMap = new map<string,string>();
        Map<String, String> sfdcCountryRegionMap = new map<string,string>();
        Set<String> validDnBCountries = new Set<String>();
        
        try{ 
            countriesList = [SELECT id,Name,CurrencyIsoCode,Region__c,DNB_COUNTRY_CODE__c,DnB_Supported_Country__c,DNB_Region__c,DNB_ISO_country_code__c FROM Country__c where DnB_Supported_Country__c=true];
            
            //Create required country map
            for(country__c temp : countriesList){
                countryIdMap.put(temp.id,temp.name);
                countryCodeMap.put(temp.Name,temp.DNB_ISO_country_code__c);
                sfdcCountryMap1.put(temp.DNB_Country_Code__c,temp.Name );
                regionMap.put(temp.Name, temp.DNB_Region__c);
                validDnBCountries.add(temp.Name);
                sfdcCountryRegionMap.put(temp.Name,temp.Region__c);
            }
            country =countryIdMap.get(countryFromCmp) == 'UNITED KINGDOM'?'England':countryIdMap.get(countryFromCmp) ;
            
            system.debug('**********' +country);
            
            string countryiso = countryCodeMap.get(country);
            string region = regionMap.get(country);       
            
            string modifiedOrgname = escapeSpecialChar(cmpnyNameFrmCmp);
            string modifiedMailingCity = escapeSpecialChar(cityFrmCmp);
            string modifiedMailingState = escapeSpecialChar(stateFrmCmp);
            String requestXMLString;
            string localLanguage;
            if(localLanguageIndicator){
                localLanguage = 'Y';
            }else{
                localLanguage = 'N';
            }
            
            requestXMLString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:cus="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:cus1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities" xmlns:cus2="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.PartyEntities" xmlns:cus3="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Utility">'
                +'<soapenv:Header/>'
                +'<soapenv:Body>'
                +'<SearchDnBOrganization xmlns="http://tempuri.org/">'
                +'<searchDNBRequestDTO xmlns:d4p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
                +'<d4p1:OrganizationRequestObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities">'
                +'<d5p1:OrganizationName>'+modifiedOrgname.trim()+'%</d5p1:OrganizationName>'  
                +'</d4p1:OrganizationRequestObject>'
                +'<d4p1:CommonObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.PartyEntities">'
                +'<d5p1:SearchType>D</d5p1:SearchType>';
            if(cityFrmCmp != null){
                requestXMLString += '<d5p1:CityName>'+modifiedMailingCity.trim()+'</d5p1:CityName>';
            }
            requestXMLString += '<d5p1:CountryType>'+countryiso +'</d5p1:CountryType>';
            if(stateFrmCmp !=null ){
                requestXMLString += '<d5p1:Region>'+modifiedMailingState.trim()+'</d5p1:Region>';
            }
            
            requestXMLString += '</d4p1:CommonObject>'
                +'<d4p1:LocalLangInd>'+localLanguage+'</d4p1:LocalLangInd>'
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
            Http http = new Http();
            //retrying in case of failure 
            for(Integer a = 0; a <= integer.valueOf(System.Label.Deal_Reg_retry_count_variable); a++){
                System.debug('Before Send:'+DateTime.now());
                responseXML = http.send(request);  
                system.debug('**Response '+responseXML);
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
            
            system.debug('requesttt' +requestBody);   
            system.debug('responsee' +responseBody);
            
            /**** Exception handling begins*****/
            if(!CILResError.contains('OK') || CILresponseBody.contains('faultcode')){
                if(!CILResError.contains('OK')){
                    System.debug('Inside error');
                    oMessage = System.Label.Deal_reg_exception_message;
                    String ErrorMessage = 'Null';
                    String ErrorCodeValue ;
                    String TransactionIdValue ;
                    try{
                        Dom.Document doc = new Dom.Document();
                        doc.load(responseXML.getBody());
                        Dom.XMLNode rootElement = doc.getRootElement();
                        Dom.XMLNode Body = rootElement.getChildElements()[0];  
                        String BodyName = Body.getName();
                        Dom.XMLNode FaultNode;
                        if (BodyName == 'Body') {
                            FaultNode = body.getChildElements()[0];     
                        }
                        Dom.XMLNode CodeNode = FaultNode.getChildElements()[0];  
                        Dom.XMLNode ErrorCode = CodeNode.getChildElements()[0];  
                        String ErroCodetext = ErrorCode.gettext();
                        ErrorCodeValue = splitMethod(ErroCodetext);
                        Dom.XMLNode ReasonNode = FaultNode.getChildElements()[1]; 
                        Dom.XMLNode TextNode = ReasonNode.getChildElements()[0];  
                        String TransactionIdtext = TextNode.gettext();
                        TransactionIdValue = splitMethod(TransactionIdtext);
                        Dom.XMLNode TextNode1 = ReasonNode.getChildElements()[1]; 
                        String ErrorMessagetext = TextNode1.gettext();
                        ErrorMessage = splitMethod(ErrorMessagetext);
                    }
                    catch(Exception ex){
                        System.debug(ex.getMessage());
                        oMessage = System.Label.Deal_reg_exception_message;             
                    }
                    finally{
                        // insert exception record                  
                        Exception__C exceptionRecord = new Exception__C();
                        exceptionRecord.Process_Name__c = 'Partner Onboarding';
                        exceptionRecord.Object_type__c = 'User';
                        exceptionRecord.Object_ID__c = userinfo.getUserId();
                        exceptionRecord.Notes__C = ErrorMessage;
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
                    }
                    else  if(CILresponseBody.contains('DeserializationFailed')){
                        System.debug('No Record found');
                        oMessage = System.Label.DealReg_NoRecordFound;
                    } 
                    else{
                        System.debug('Inside faultcode');                  
                        oMessage = System.Label.Deal_reg_exception_message;
                        String ErrorMessagetext ='Null';
                        String faultCodeValue;
                        String MessageIDValue;
                        try{
                            Dom.Document doc = new Dom.Document();
                            doc.load(CILresponseBody);
                            Dom.XMLNode rootElement = doc.getRootElement();
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
                            Dom.XMLNode faultstring1 = faultcode.getChildElements()[1]; // <faultstring>
                            String faultstringval = faultstring1.getText();
                            Dom.XMLNode Detail = faultcode.getChildElements()[2]; // <detail>
                            Dom.XMLNode Result = Detail.getChildElements()[0]; // <Result>
                            Dom.XMLNode ResultCode = Result.getChildElements()[1]; // <ResultCode>
                            String ResultString = ResultCode.getText();
                            Dom.XMLNode ErrorList = Result.getChildElements()[2]; // <ErrorList>
                            ErrorMessagetext =''; 
                            for(Dom.XMLNode Error : ErrorList.getChildElements()){ // <a:Error>
                                Dom.XMLNode ErrorMessage = Error.getChildElements()[0]; // <a:ErrorMessage>
                                String ErrorMessageName = ErrorMessage.getname();
                                if (ErrorMessageName == 'ErrorMessage') {
                                    ErrorMessagetext = ErrorMessagetext + '\n' +ErrorMessage.gettext();
                                }
                            } 
                        }
                        catch(Exception ex){
                            System.debug(ex.getMessage());
                            oMessage = System.Label.Deal_reg_exception_message;                  
                        }
                        finally{
                            // insert exception record         
                            Exception__C exceptionRecord = new Exception__C();
                            exceptionRecord.Process_Name__c = 'Partner Onboarding';
                            exceptionRecord.Object_type__c = 'User';
                            exceptionRecord.Object_ID__c = userinfo.getUserId();
                            exceptionRecord.Notes__C = ErrorMessagetext;
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
                finalList.add(new dunsdetails(oMessage));
                return finalList;
            }  
            
            /**** Exception handling Ends*****/
            
            //if valid records returned in the search
            else {
                oMessage = '';
                Dom.Document doc = new Dom.Document();
                doc.load(CILresponseBody);
                Dom.XMLNode rootElement = doc.getRootElement();//envelope
                String rootElementName = rootElement.getName();
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
                    oAddress1 =  '';
                    oCity =  '';
                    oCountyCode =  '';
                    oPostalCode =  '';
                    oState =  '';
                    SearchOrgReList.add(SearchOrganizationResultElement);
                    String OrgResultTestName =  SearchOrganizationResultElement.getName();
                    // To get Party
                    Dom.XMLNode SeacrhChildOrg = SearchOrganizationResultElement.getChildElements()[0];//<b:Party
                    String SearchChildOrgName = SeacrhChildOrg.getName();
                    //System.debug('SearchChildOrgName :' +SearchChildOrgName +' '+SeacrhChildOrg);
                    Dom.XMLNode PartyChild = SeacrhChildOrg.getChildElements()[0];//<c:Party>
                    String PartyChildName = PartyChild.getName();
                    //System.debug('PartyChild :' +PartyChildName +' '+PartyChild);
                    Dom.XMLNode PartyChild1 = PartyChild.getChildElements()[0];//<c:Organization>
                    String PartyChildName1 = PartyChild.getName();
                    //To get Duns Name
                    Dom.XMLNode OrganizationName = PartyChild1.getChildElements()[0];//<b:OrganizationName>
                    String OrganizationChildtName = OrganizationName.getName();
                    Dom.XMLNode OrganizationName1 = OrganizationName.getChildElements()[0];//<b:OrganizationName>
                    Dom.XMLNode OrganizationNameValue = OrganizationName1.getChildElements()[0];//<b:Name>Center BMW</b:Name>
                    oBusinessName = OrganizationNameValue.getText();
                    
                    // Local language search
                    system.debug('****' +localLanguageIndicator);
                    if(localLanguageIndicator){
                        oBusinessName = '';
                        Dom.XMLNode OrganizationNameExtension = OrganizationName1.getChildElements()[1];  // <b:OrganizationNameExtension>
                        Dom.XMLNode OrganizationNameExtension1 = OrganizationNameExtension.getChildElements()[0]; // <d:OrganizationNameExtension>
                        Dom.XMLNode localLangDunsName = OrganizationNameExtension1.getChildElements()[0];
                        oBusinessName = localLangDunsName.getText();
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
                        }
                        If(OrganizationExtensionChild.getName() == 'OutOfBusinessIndi'){
                            oOOB = OrganizationExtensionChild.getText();
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
                        If(AddressChild.getName() == 'AddressLineOne'){//need to add null checking
                            oAddress1 = AddressChild.getText();
                        }
                        If(AddressChild.getName() == 'City'){
                            oCity = AddressChild.getText();
                        }
                        If(AddressChild.getName() == 'CountryValue'){ 
                            oCountyCode = AddressChild.getText();
                            oCountyCode = String.valueOf(Integer.valueOf(oCountyCode));
                        }
                        If(AddressChild.getName() == 'ZipPostalCode'){
                            oPostalCode = AddressChild.getText();
                        }
                        If(AddressChild.getName() == 'Region'){
                            oState = AddressChild.getText();
                        }
                        
                        // local language search                               
                        if(localLanguageIndicator){                               
                            if(AddressChild.getName() == 'AddressExtension'){
                                Dom.XMLNode AddressExtension = AddressChild.getChildElements()[0]; // <d:AddressExtension>
                                for(Dom.XMLNode LocalLangAddressChild : AddressExtension.getChildElements()){
                                    If(LocalLangAddressChild.getName() == 'LocallangAddrLineOne'){
                                        oAddress1 = '';
                                        oAddress1 = LocalLangAddressChild.getText();
                                    }
                                    If(LocalLangAddressChild.getName() == 'LocallangCity'){
                                        oCity = '';
                                        oCity = LocalLangAddressChild.getText();
                                    }
                                    If(LocalLangAddressChild.getName() == 'LocallangState'){
                                        oState = '';
                                        oState = LocalLangAddressChild.getText();
                                    }
                                }
                            }
                        }
                        
                    }
                    oCountry = sfdcCountryMap1.get(oCountyCode); 
                    // If there is no Country with the country code the display the enduser mailing country
                    if (oCountry == NULL){
                        oCountry = countryIdMap.get(countryFromCmp);                  
                    }
                    //Display only records with OOB Yes and results from searched country
                    if((oOOB == 'N')  && oAddress1 != ''  ){ 
                        finalList.add(new dunsdetails(false,oAddress1,oBusinessName,oCity,oCountry,oCountyCode,oDunsId,oPostalCode,oState,oOOB,oMessage));
                    }
                }
                //if valid results
                if(!finalList.isEmpty()){
                    finalList.sort();
                }
                //if no valid results
                else{
                    oMessage = System.Label.DealReg_NoRecordFound;
                    finalList.add(new dunsdetails(oMessage));
                }
            }
        }catch(Exception e){
            //Track generic exceptions
            System.debug(e.getMessage());
            oMessage = 'Exception Occured while doing D&B Search. Error Message: '+e.getMessage();
            finalList.add(new dunsdetails(oMessage));
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'Partner Registration Address Validation';
            exceptionRecord.Object_type__c = 'Onboarding Form';
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
        System.debug(oMessage);
        return finalList;
    }
    
    
    
    //Dunsdetail
    global class dunsdetails implements Comparable {
        @AuraEnabled
        global boolean selected;
        @AuraEnabled
        global string Address;
        @AuraEnabled
        global string DunsName;
        @AuraEnabled
        global string City;
        @AuraEnabled
        global string Country;
        @AuraEnabled
        global string CountyCode;
        @AuraEnabled
        global string DunsId;
        @AuraEnabled
        global string PostalCode;
        @AuraEnabled
        global string State;
        @AuraEnabled
        global string oOOB;
        @AuraEnabled
        global string oMessage;
        
        global dunsdetails(Boolean selected, String Address, String DunsName, String City, String Country, String CountyCode, String DunsId, String PostalCode, String State,String oOOB,String oMessage){
            this.selected = selected;
            this.Address = Address;
            this.DunsName = DunsName;
            this.City = City;
            this.Country = Country;
            this.CountyCode = CountyCode;           
            this.DunsId = DunsId;
            this.PostalCode = PostalCode;
            this.State = State;
            this.oOOB = oOOB;
            this.oMessage = oMessage;
        }
        
        global dunsdetails(String oMessage){
            this.oMessage = oMessage;
        }
        global Integer compareTo(Object ObjToCompare) {
            return DunsName.CompareTo(((dunsdetails)ObjToCompare).DunsName);
        }
    }
    
    
    @AuraEnabled
    global static dunsdetails getSelectedDuns(String SelectedDuns,string resultList){         
        List<dunsdetails> dunList = (List<dunsdetails>)JSON.deserialize(resultList, List<dunsdetails>.class);
        dunsdetails SelectedDUNSinfo;
        for(dunsdetails detail : dunList){               
            if(detail.DunsId == SelectedDuns ){
                SelectedDUNSinfo = detail;
            }         
        }
        system.debug('Selected Duns:--' +SelectedDUNSinfo);
        return SelectedDUNSinfo;
    }
    
    // Method to escape special characters in Input
    public static string escapeSpecialChar(String text){
        if(text != null){
            string modifiedText = text.replace('"', '&quot;').replace('<', '&lt;').replace('>', '&gt;').replace('&', '&amp;');
            return modifiedText;
        }
        return null;
    }
    
    // Method to split the error code,transaction id and error message from response   
    public static string splitMethod(String text){
        if(text != null){
            list<String> textSplitValues = new list<String>();
            textSplitValues = text.split(':');
            String SplitValue = textSplitValues[1];
            return SplitValue;
        }
        return null;
    }
    
    /* Commented Transalations Custom Metadata and created new Onboarding_Translations__c object
    @AuraEnabled
    public static list < Translations__mdt > getLabels() {
        return [select developerName, MasterLabel, cs__c,da__c,de__c,el__c,en_us__c,es__c,es_mx__c,fi__c,hu__c,fr__c,it__c,iw__c,ja__c,ko__c,nl__c,no__c,pl__c,pt_br__c,ro__c,ru__c,sk__c,sv__c,th__c,tr__c,zh_cn__c,zh_tw__c
                from Translations__mdt];
    } */
    
    @AuraEnabled
    public static list < Onboarding_Translations__c > getLabels() {
        return [select Name,Label__c, cs__c,da__c,de__c,el__c,en_us__c,es__c,es_mx__c,fi__c,hu__c,fr__c,it__c,iw__c,ja__c,ko__c,nl__c,no__c,pl__c,pt_br__c,ro__c,ru__c,sk__c,sv__c,th__c,tr__c,zh_cn__c,zh_tw__c
                from Onboarding_Translations__c];
    }
    
}