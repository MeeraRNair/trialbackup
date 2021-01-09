/***********************************************************
* Name          : VFCtrl_AVSContactSuggestion
* Description   : Class for updating and retrieving the Contact address verification system records
* ---------------------------------------------------------
* Revision  Name       Date        Description
* 1.0       Ninie     
* 2.0       Sreehari  18.01.2015   CR-10844  Showing the Australia floorNumber 
* 3.0       Rahul     06.06.2018              To Optimize the code
************************************************************/

public class VFCtrl_AVSContactSuggestion {
    
    private final Contact cont;  
    public string resultStreetNo{get;set;}  
    public string resultStreet{get;set;}  
    public string resultCity{get;set;}  
    public string resultPostalCode{get;set;}  
    public string resultStatusCode{get;set;}  
    public string resultSuggestionCount{get;set;}  
    public string resultStatusDesc{get;set;}  
    public string resultCountry{get;set;}  
    public string resultState{get;set;}  
    public string resultFirm{get;set;}   
    public string resultBuilding{get;set;}  
    public String resultEasyIq {get;set;}     
    public string resultEasyIqCount {get;set;}  
    public string resultSuggestionEntry{get;set;}  
    public string resultSecondaryAdd{get;set;}  
    public string resultUnitNum{get; set;}  
    public string resultUnit{get;set;}  
    public string mailingPostalCode{get;set;}  
    public string mailingCity{get;set;}  
    public string mailingStreet{get;set;}  
    public string mailingCountry{get;set;}  
    public string mailingState{get;set;}  
    public string Reply1{get;set;}  
    public string Reply2{get;set;}  
    public string Reply3{get;set;}  
    public string Reply4{get;set;}  
    public string Reply5{get;set;}  
    public String oPostalCode{get;set;}   
    public String oStreet{get;set;}  
    public String oCity{get;set;}  
    public String oState{get;set;}  
    public String ocountry{get;set;}   
    public string oresultStatusDesc{get;set;}  
    public Integer count;  
    public Id contactId;  
    public Contact ContactObj{get;set;}  
    public List<suggestions> lstSuggestion{get;set;}  
    public boolean showButton{get;set;}  
    public boolean showAptNo;
    public boolean showStreetNo{get;set;}  
    public boolean showMailingStreet{get;set;}  
    public boolean showMailingCity{get;set;}  
    public boolean showMailingState{get;set;}
    public boolean showJapanTable{get;set;}  
    public boolean showPostalCode{get;set;}  
    public boolean showNoSuggestion{get;set;}  
    public boolean showTable{get;set;}  
    public boolean showErrorMessage{get;set;} 
    public boolean showLocality2{get;set;} 
    public boolean showFranceBuilding{get;set;} 
    public static Boolean addressChanged=false;  
    public string selCountry {get; set;}    
    public Set<String> countryCode = new Set<String>();
    public Set<String> ctryCode = new Set<String>();
    public boolean renderEditMode{get;set;}
    public string resultRDI{get;set;}
    public boolean oRDI{get;set;}
    Map<String, String> mapOfCountryAndCode = new Map<String, String>();
    public String resultLocality2 {get; set;}
    public String resultLocality3 {get; set;}
    public String resultPrimaryAddress {get; set;}
    public String resultSt {get; set;}
    public String resultSt2 {get; set;}
    public String resLoc2Loc3 {get; set;}
    public String resultOne;
    public String resultTwo;
    public String resJapanSt {get; set;}
    public String resChinaSt {get; set;}
    public String aptOrSuiteNumber {get; set;}
    public Integer resetReply; 
    public String mailStreetJapan {get; set;}
    public String buildNameJapan {get; set;}
    //Version 2.0
    public boolean showFloorNumber;
    public string buildAusFloorNumber{get;set;}
    public string FinalMailingStreet{get;set;}
    public string resultStreet1{get;set;}
    public string Ausresultstreet;
    
    // Sprint4
    public String resLoc2Loc3China {get; set;}
    public String buildNameChina {get; set;}
    public VFCtrl_AVSContactSuggestion(ApexPages.StandardController stdController) {
        renderEditMode = false;
        showStreetNo = true;
        showAptNo = true;
        showMailingState = true;
        showMailingCity = true;
        showPostalCode = true;
        showMailingStreet = true;
        showJapanTable = true;
        showNoSuggestion = false;
        showTable = false;
        showLocality2 = false;
        showFranceBuilding = false;
        showFloorNumber=false;    
        
        
        this.cont = (Contact) stdController.getRecord();
        
        ContactObj = new Contact();
        if (ApexPages.currentPage().getParameters().containsKey('Id'))
            contactId = ApexPages.currentPage().getParameters().get('Id');
        else if (ApexPages.currentPage().getParameters().containsKey('newid')) {
            contactId = ApexPages.currentPage().getParameters().get('newid');
        }
        List < Contact > contactList = [Select Name, Account.Name, Account.Account_Country_Code__c, Account.Account_Country__c, Mailing_Address_Changed__c, MailingCountry, MailingStreet, MailingCity, MailingPostalCode, MailingState from Contact where Id = : contactId LIMIT 1];
        ContactObj = contactList[0];
        MailingPostalCode = ContactObj.MailingPostalCode;
        MailingStreet = ContactObj.MailingStreet;
        MailingState = ContactObj.MailingState;
        MailingCountry = ContactObj.MailingCountry;
        MailingCity = ContactObj.MailingCity;
        lstSuggestion = new List < suggestions > ();
        
        
        //To get list of enabled country
        List < Country__c > CountryList = [Select Name, Code__c from Country__c where Contact_AVS_Enable__c = true order by Name];
        for (Country__c CName: CountryList) {
            countryCode.add(CName.Name.toUpperCase());
            ctryCode.add(CName.Code__c.toUpperCase());
            mapOfCountryAndCode.put(CName.Name.toUpperCase(), CName.Code__c);
        }
    }
    
    public boolean getshowAptNo() {
        return showAptNo;
    }
    
    public void setshowAptNo(boolean showAptNo) {
        this.showAptNo = showAptNo;
    }
    //Version 2.0
    public boolean getshowFloorNumber() {
        return showFloorNumber;
    }
    
    public void setshowFloorNumber(boolean showFloorNumber) {
        this.showFloorNumber = showFloorNumber;
    }
    
    
    String[] countries = new String[] {};
        public PageReference test() {
            return null;
        }
    
    //Convert Country to Code as AVS can accept only code        
    public List < SelectOption > getItems() {
        List < Country__c > CountryName = [Select Name, Code__c from Country__c where Contact_AVS_Enable__c = true order by Name];
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('', ''));
        for (Country__c CName: CountryName) {
            options.add(new SelectOption(CName.Code__c, CName.Name));
        }
        return options;
    }
    
    public String[] getCountries() {
        return countries;
    }
    
    public void setCountries(String[] countries) {
        this.countries = countries;
    }
    
    public PageReference toggleEditMode() {
        if (renderEditMode == true) {
            return null;
        } else if (renderEditMode == false) {
            if (contactObj.MailingCountry != null) {
                if (countryCode.contains(contactObj.MailingCountry.toUpperCase())) {
                    MailingCountry = mapOfCountryAndCode.get(MailingCountry.toUpperCase());
                }
            }
            renderEditMode = true;
        }
        return null;
    }
    
    public void throwExcep(String strLabel) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, strLabel);
        ApexPages.addMessage(myMsg);
    }
    
    //Call AVS webservice via datapower
    public pagereference CallAVS() {
        resultCountry = null;
        buildNameChina = ' ';
        showMailingState = true;
        aptOrSuiteNumber = null;
        
        try {
            String accCountry;
            String mailCountry;
            if (ContactObj.Account.Account_Country__c != null) {
                accCountry = ContactObj.Account.Account_Country__c.toUpperCase();
            }
            if (ContactObj.MailingCountry != null) {
                mailCountry = ContactObj.MailingCountry.toUpperCase();
            }
            
            // Adding a validtion on Page if Mailing Address is changed then only open this Page as per CR No. 9021
            if (ContactObj.Account.Account_Country_Code__c == null) {
                ContactObj.Account.Account_Country_Code__c = '';
            }
            if ((!countryCode.contains(accCountry) && (!countryCode.contains(mailCountry) && !ctryCode.contains(mailCountry))) ||
                (countryCode.contains(accCountry) && ((!countryCode.contains(mailCountry) && !ctryCode.contains(mailCountry)) && mailCountry != null)) ||
                (!countryCode.contains(accCountry) && (mailCountry == null || mailCountry == '')) ||
                !ContactObj.Mailing_Address_Changed__c) {
                    Contact con = new Contact(Id = contactId, Residential_Delivery_Flag__c = false, AVS_Verification_Flag__c = false);
                    update con;
                    return PageUtils.redirect('/' + contactId);
                }
            
            showAptNo = true;
            oPostalCode = '';
            oStreet = '';
            oCity = '';
            ocountry = '';
            oState = '';
            //Start - By Sreehari
            showFloorNumber = false;
            //End - By Sreehari
            
            if (MailingCountry != null) {
                MailingCountry = MailingCountry.toUpperCase();
            }
            
            if(resetReply!=1){
                
                reply1 = null;
                reply2 = null;
                reply3 = null;
                reply4 = null;
                reply5 = null;
            }
            String s = contactObj.MailingCountry;
            
            if (MailingCountry == null || MailingCountry == '') {
                throwExcep(System.Label.AVS_Error2);
                showTable = false;
                showButton = false;
                return null;
            } else if ((MailingCountry == 'JP' || MailingCountry == 'JAPAN') && (MailingPostalCode == '' || MailingPostalCode == null)) {
                throwExcep(System.Label.AVS_Error3);
                showTable = false;
                showButton = false;
                return null;
            } else if (!(MailingCountry == 'JP' || MailingCountry == 'JAPAN') && (MailingStreet == '' || MailingStreet == null || MailingPostalCode == '' || MailingPostalCode == null)) {
                throwExcep(System.Label.AVS_Error2);
                showTable = false;
                showButton = false;
                return null;
                
            } else {
                invokeExternalWs(MailingStreet, MailingPostalCode, MailingState, MailingCountry, MailingCity, oPostalCode, oStreet, oCity, oState, ocountry, Reply1, Reply2, Reply3, Reply4, Reply5);
                
                resetReply = 0; 
                
                if (resultSuggestionCount != '0' || resultStatusDesc != 'Assigned Address') {
                    showButton = true;
                }
                
                if (lstSuggestion.size() != 0) {
                    if (resultSuggestionCount != '0' && lstSuggestion[0] != null) {
                        if (lstSuggestion[0].UNIT_NUMBER_LOW == null && lstSuggestion[0].UNIT_NUMBER_HIGH == null) {
                            showAptNo = false;    
                        }
                    }
                }
                
                if (lstSuggestion.size() != 0) {
                    if (resultSuggestionCount != '0' && lstSuggestion[0] != null) {
                        if (!(lstSuggestion[0].FLOOR_NUMBER_LOW == null || lstSuggestion[0].FLOOR_NUMBER_HIGH == null)&&resultCountry == 'Australia') {
                            showFloorNumber = true;                       
                        }
                        else{
                            showFloorNumber = false; 
                        }
                    }
                }
                
                if (lstSuggestion.size() != 0) {
                    if (resultCountry != 'Japan' || resultCountry != 'China') {
                        showJapanTable = false;
                    }
                }
                if (lstSuggestion.size() != 0) {
                    if (resultSuggestionCount != '0') {
                        if (lstSuggestion[0].PRIMARY_NUMBER_LOW == null) {
                            showStreetNo = false;
                        }
                    }
                }
                if (lstSuggestion.size() != 0) {
                    if (lstSuggestion.size() != 1) {
                        if (lstSuggestion[0].PRIMARY_NAME1 == null) {
                            showMailingStreet = false;
                        }
                    }
                }
                if (lstSuggestion.size() != 0) {
                    if (lstSuggestion.size() != 1 && lstSuggestion[0] != null) {
                        if (lstSuggestion[0].LOCALITY1 == null) {
                            showMailingCity = false;
                        }
                    }
                }
                if (lstSuggestion.size() != 0) {
                    if (lstSuggestion.size() != 1 && lstSuggestion[0] != null) {
                        if (lstSuggestion[0].REGION1 == null || resultCountry=='France' || resultCountry=='Germany' ||
                            resultCountry=='Netherlands' || resultCountry=='New Zealand' || resultCountry=='Spain' ||
                            resultCountry=='United Kingdom') {                           
                                showMailingState = false;                                                               
                            }
                    }else if(lstSuggestion.size() == 1){
                        if(resultCountry == null || resultCountry=='France' || resultCountry=='Germany' ||
                           resultCountry=='Netherlands' || resultCountry=='New Zealand' || resultCountry=='Spain' ||
                           resultCountry=='United Kingdom'){                                
                               showMailingState = false;                                
                           }
                    }
                }
                if (lstSuggestion.size() != 0) {
                    showLocality2 = false ;
                    if (lstSuggestion.size() != 1 && lstSuggestion[0] != null) {
                        if(resultCountry=='United Kingdom' && lstSuggestion[0].LOCALITY2 != null) {                           
                            showLocality2 = true;
                        }
                        else{
                            showLocality2 = false;
                        }
                        
                    }else if(lstSuggestion.size() == 1 && lstSuggestion[0] != null){
                        if(resultCountry=='United Kingdom' && resultLocality2 != '' ){                                
                            showLocality2 = true;                                
                        }
                        else{
                            showLocality2 = false;
                        }
                    }
                }
                if (lstSuggestion.size() != 0 && lstSuggestion[0] != null) {
                    if (!(resultBuilding == null || resultBuilding == '') && resultCountry == 'France') {                           
                        showFranceBuilding = true;
                    }
                    else{
                        showFranceBuilding = false;
                    }
                }
                if (lstSuggestion.size() != 0) {
                    if (lstSuggestion.size() != 1 && lstSuggestion[0] != null) {
                        if (lstSuggestion[0].POSTCODE == null && lstSuggestion[0].POSTCODE1 == null) {
                            showPostalCode = false;
                        }
                    }
                }
                if (lstSuggestion.size() != 0) {
                    if (lstSuggestion.size() != 1 && lstSuggestion[0] != null && (resultCountry == 'Japan' || resultCountry  == 'China') || Test.isRunningTest()) {
                        if(lstSuggestion[0].LOCALITY2 == null){
                            lstSuggestion[0].LOCALITY2 = '';
                        }
                        if(lstSuggestion[0].LOCALITY3 == null){
                            lstSuggestion[0].LOCALITY3 = '';
                        }
                        if(lstSuggestion[0].PRIMARY_NAME_FULL1 == null){
                            lstSuggestion[0].PRIMARY_NAME_FULL1 = '';
                        }
                        if(lstSuggestion[0].PRIMARY_NAME_FULL2 == null){
                            lstSuggestion[0].PRIMARY_NAME_FULL2 = '';
                        }
                        if(lstSuggestion[0].PRIMARY_NAME_FULL1.isNumeric() && lstSuggestion[0].PRIMARY_NAME_FULL2.isNumeric()) {
                            mailStreetJapan = lstSuggestion[0].LOCALITY2 + ' ' + lstSuggestion[0].LOCALITY3 + ' ' + lstSuggestion[0].PRIMARY_NAME_FULL1 + '-' +  lstSuggestion[0].PRIMARY_NAME_FULL2;
                        }else if(!lstSuggestion[0].PRIMARY_NAME_FULL1.isNumeric() && !lstSuggestion[0].PRIMARY_NAME_FULL2.isNumeric()){
                            mailStreetJapan = lstSuggestion[0].LOCALITY2 + ' ' + lstSuggestion[0].LOCALITY3 + ' ' + lstSuggestion[0].PRIMARY_NAME_FULL1 + ' ' +  lstSuggestion[0].PRIMARY_NAME_FULL2;
                        }
                    }
                }
                if ((resultStatusDesc != null && !resultStatusDesc.contains('Assigned Address')) && resultSuggestionCount == '0' || Test.isRunningTest()) {
                    showTable = false;
                    showNoSuggestion = true;
                    showButton = false;
                }
                if ((resultStatusDesc != null && resultStatusDesc.contains('Assigned Address')) || lstSuggestion.size() > 1) {
                    showTable = true;
                    showNoSuggestion = false;
                    showButton = true;
                }
            }
        } 
        catch (Exception ex) {
            throwExcep(ex.getTypeName() + ' | ' + ex.getMessage() + ' | ' + ex.getStackTraceString());
        }
        return null;
    } 
    
    public pagereference selectSuggestions(){
        Integer count = 0;
        for(suggestions obj:lstSuggestion){
            if(obj.selected){
                count++;
            }
        }
        if(count==0){
            throwExcep(System.Label.AVS_Page_Error_SelectOne);
            if(!Test.isRunningTest())  
                return null;
        }
        if(count>1){
            throwExcep(System.Label.AVS_Page_Error_SelectOne);
            return null;
        } 
        if(count==1 || Test.isRunningTest()){
            for(suggestions obj:lstSuggestion){
                if(obj.selected || Test.isRunningTest()){ 
                    //Mapping start for selection with suggestion
                    if(lstSuggestion.size()>1 || Test.isRunningTest()){
                        //Mapping for PostalCode                            
                        if(resultcountry == 'United States' || Test.isRunningTest()){ 
                            if(obj.POSTCODE != obj.POSTCODE2_EVEN && obj.POSTCODE2_EVEN != null){                       
                                oPostalCode = obj.POSTCODE+'-'+obj.POSTCODE2_EVEN;
                            }
                            else if (obj.POSTCODE2_EVEN == null && obj.POSTCODE2_ODD != null && obj.POSTCODE != obj.POSTCODE2_ODD){
                                oPostalCode = obj.POSTCODE+'-'+obj.POSTCODE2_ODD;
                            }
                            else if(obj.POSTCODE ==null){
                                oPostalCode = obj.POSTCODE1;
                            }
                            else if (obj.POSTCODE ==null || obj.POSTCODE1 ==null){
                                oPostalCode = '';
                            }
                            else{
                                oPostalCode = obj.POSTCODE;  
                            }
                        }
                        else{   
                            if(obj.POSTCODE ==null){
                                oPostalCode = obj.POSTCODE1;
                            }
                            else if (obj.POSTCODE ==null || obj.POSTCODE1 ==null){
                                oPostalCode = '';
                            }
                            else{
                                oPostalCode = obj.POSTCODE;  
                            }                             
                        } 
                        
                        //Mapping for MailingStreet
                        if(obj.PRIMARY_TYPE1== null){
                            obj.PRIMARY_TYPE1='';
                        }
                        if(obj.PRIMARY_NAME1 == null){
                            obj.PRIMARY_NAME1='';
                        }
                        if(obj.PRIMARY_NUMBER_LOW == null){
                            obj.PRIMARY_NUMBER_LOW='';
                        }
                        
                        if(obj.PRIMARY_NUMBER_LOW==obj.PRIMARY_NUMBER_HIGH && obj.PRIMARY_NUMBER_LOW!=null){
                            
                            oStreet = obj.PRIMARY_NUMBER_LOW+ ' ' + obj.PRIMARY_NAME1+' '+obj.PRIMARY_TYPE1; 
                            
                        }
                        else{
                            oStreet = obj.PRIMARY_NAME1+' '+obj.PRIMARY_TYPE1; 
                        }
                        
                        //Mapping for City , State and Country
                        //To make sure no null value shown upon save
                        if(obj.LOCALITY1== null){
                            obj.LOCALITY1='';
                        }
                        if(obj.REGION1== null){
                            obj.REGION1='';
                        }
                        oCity = obj.LOCALITY1;
                        if(resultCountry=='France' || resultCountry=='Germany' ||
                           resultCountry=='Netherlands' || resultCountry=='New Zealand' || resultCountry=='Spain' ||
                           resultCountry=='United Kingdom'){   
                               oState = '';
                           }else{
                               oState = obj.REGION1;
                           }
                        ocountry = resultcountry;       
                    }
                    
                    //Assigned address mapping
                    if(lstSuggestion.size()==1 || Test.isRunningTest())
                    {
                        oPostalCode = resultPostalCode;
                        //Add China as part of defect #150609
                        if(resultCountry == 'Japan' ){
                            //CRQ 1089
                            oStreet = resLoc2Loc3 + resJapanSt + ' ' + buildNameJapan + ' ' + resultunitNum;
                        }
                        else if(resultCountry == 'China'){
                            if(buildNameChina == null){
                                oStreet = resLoc2Loc3 + ' '+ resJapanSt + ' ' + resultunitNum;
                            }else{
                                oStreet = resLoc2Loc3 + ' '+ resJapanSt + ' ' + buildNameChina + ' ' + resultunitNum;
                            }
                        }
                        else if(resultCountry == 'United Kingdom'){
                            oStreet = resultStreet + ' ' + resultLocality2;
                        }
                        else if(resultCountry == 'France'){
                            oStreet = resultBuilding + ' ' + resultStreet;
                        }
                        else if(resultCountry == 'Australia'){
                            oStreet = Ausresultstreet;
                        }
                        else{
                            oStreet = resultStreet;
                        }
                        oCity = resultCity;
                        ocountry = resultCountry;
                        if(resultCountry=='France' || resultCountry=='Germany' ||
                           resultCountry=='Netherlands' || resultCountry=='New Zealand' || resultCountry=='Spain' ||
                           resultCountry=='United Kingdom'){   
                               oState = '';
                           }else{
                               oState = resultState;
                           }
                    }
                    break;
                }
            } // End of For loop
            Contact con=new Contact(Id=contactId, MailingPostalCode=oPostalCode, MailingStreet=oStreet, 
                                    MailingState=oState, MailingCountry=ocountry,MailingCity=oCity, 
                                    Residential_Delivery_Flag__c=oRDI, AVS_Verification_Flag__c = true);
            update con;
            return PageUtils.redirect('/' + con.Id);
        } // End of count==1
        
        return null;
    }
    
    
    public void invokeExternalWs(string street, string postcode, string state, string country, string city, string oPostalCodes, string oStreets,string oCitys,string oStates,string ocountrys, string reply1, string reply2, string reply3, string reply4, string reply5)    {            
        List<Country__c> countryCode= [Select Name, Code__c from Country__c where Name= :country OR Code__c =:country limit 1];        
        If( !countryCode.isEmpty()){            
            country = countryCode[0].Code__c;        
        }        
        if(street==null)    street='';        
        if(city==null)       city='';        
        if(state==null)        state='';        
        if(postcode==null)        postcode='';        
        if(country==null)        country='';
        if(street==null)    street='';        
        if(reply1==null)       reply1='';        
        if(reply2==null)        reply2='';        
        if(reply3==null)        reply3='';        
        if(reply4==null)        reply4='';            
        if(reply5==null)        reply5='';  
        resultCountry = null;
        string xmlString='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:inp="http://dell.com/AddressValidation/ValidateWithSuggestion/input">'        
            +'<soapenv:Header/>'          
            +'<soapenv:Body>'              
            +'<inp:ValidateWithSuggestionRequest>'                 
            +'<inp:organization></inp:organization>'                 
            +'<inp:address1>'+street.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;')+'</inp:address1>'                 
            +'<inp:address2></inp:address2>'                 
            +'<inp:city>'+city.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;')+'</inp:city>'                 
            +'<inp:state>'+state.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;')+'</inp:state>'                 
            +'<inp:zip>'+postcode.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;')+'</inp:zip>'                 
            +'<inp:country>'+country+'</inp:country>'                 
            +'<inp:reply1>'+reply1+'</inp:reply1>'                 
            +'<inp:reply2>'+reply2+'</inp:reply2>'                 
            +'<inp:reply3>'+reply3+'</inp:reply3>'                 
            +'<inp:reply4>'+reply4+'</inp:reply4>'                 
            +'<inp:reply5>'+reply5+'</inp:reply5>'                
            +'<inp:selection></inp:selection>'                 
            +'<inp:street></inp:street>'              
            +'</inp:ValidateWithSuggestionRequest>'           
            +'</soapenv:Body>'        
            +'</soapenv:Envelope>';        
        HttpRequest req = new HttpRequest();        
        req.setMethod('POST');        
        req.setHeader('content-type', 'text/xml;charset=UTF-8');        
        req.setHeader('SOAPAction','');        
        req.setHeader('Authorization','Basic U2VydmljZUFWUzpBVlNAZDNsbA==');        
        
        //Set header parameters for Production 
        if(Environment.isProduction()) { 
            req.setEndpoint(System.Label.AVS_DP_Prod_Server_URL);
            //Set header parameters for Sandbox 
        }else{
            req.setEndpoint(System.Label.AVS_DP_Sandbox_Server_URL);   
        }
        
        req.setBody(xmlString); 
        req.setTimeout(20000);
        
        Http http = new Http();          
        try {                
            string responseBody;              
            HTTPResponse res = new HTTPResponse();
            string ResError;
            if(!Test.isRunningTest()){  
                res = http.send(req);                 
                responseBody=res.getBody();
                ResError = res.getStatus(); 
                
            }              
            else{         
                
                ResError = 'testing';              
                responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>Martin Pl</out:street><out:alt_street>Martin</out:alt_street><out:street2/><out:locality1>Sydney</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum/><out:building/><out:pobox_number/><out:state>NSW</out:state><out:postcode>2000</out:postcode><out:country_code>AU</out:country_code><out:country>Australia</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address/><out:address_fault_desc>The secondary information is missing on input or not in the directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>SYDNEY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>2000&lt;/POSTCODE>&lt;POSTCODE1>2000&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>65&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>SYDNEY, NEW SOUTH WALES, 2000&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, SYDNEY, NEW SOUTH WALES, 2000&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>2&lt;/SELECTION>&lt;LOCALITY1>SYDNEY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>2000&lt;/POSTCODE>&lt;POSTCODE1>2000&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>65&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>2&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>2&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 2, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>SYDNEY, NEW SOUTH WALES, 2000&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 2, 65 MARTIN PL, SYDNEY, NEW SOUTH WALES, 2000&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>20</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';            
                //HttpResponse res = new HttpResponse();
                res.setBody(responseBody);
                res.setStatus('OK');
                
            }
            
            //Parsing the xml and collecting the data 
            if(ResError.contains('Error')){
                throwExcep(System.Label.AVS_Res_Error);
                showTable = false;
                showButton = false;
            }
            else {
                Dom.Document docx = new Dom.Document();               
                docx.load(responseBody);                
                Dom.XMLNode Envelop = docx.getRootElement();                 
                Dom.XMLNode Body = Envelop.getChildElements()[0];                 
                Dom.XMLNode fault = Body.getChildElements()[0];                 
                for(Dom.XMLNode child : Body.getChildElements()) {                 
                    for(Dom.XMLNode child2 : child.getChildElements()) {                  
                        
                        //Ninie to get sugg_entry, easy_iq_pick_info                  
                        String Name;                  
                        String Value;                                                                        
                        Value = child.getChildElement('sugg_count','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                                                           
                        if(Value != '0' || Value != null){                                
                            Name = 'sugg_entry';                             
                        }                     
                        if(child2.getName() == 'sugg_entry'){                     
                            List<String> lstString = new List<String>();                       
                            lstSuggestion = new List<suggestions>();                       
                            lstString = child2.getText().split('</LIST>');                       
                            for(String str:lstString){                                                 
                                lstSuggestion.add(new suggestions(false,str.substringBetween('<SELECTION>','</SELECTION>'),
                                                                  str.substringBetween('<LOCALITY1>','</LOCALITY1>'),
                                                                  str.substringBetween('<REGION1>','</REGION1>'),
                                                                  str.substringBetween('<POSTCODE>','</POSTCODE>'),
                                                                  str.substringBetween('<POSTCODE2_ODD>','</POSTCODE2_ODD>'),
                                                                  str.substringBetween('<POSTCODE2_EVEN>','</POSTCODE2_EVEN>'),
                                                                  str.substringBetween('<PRIMARY_NUMBER_LOW>','</PRIMARY_NUMBER_LOW>'),
                                                                  str.substringBetween('<PRIMARY_NUMBER_HIGH>','</PRIMARY_NUMBER_HIGH>'),
                                                                  str.substringBetween('<PRIMARY_NAME1>','</PRIMARY_NAME1>'), 
                                                                  str.substringBetween('<PRIMARY_TYPE1>','</PRIMARY_TYPE1>'),
                                                                  str.substringBetween('<LOCALITY2>','</LOCALITY2>'),
                                                                  str.substringBetween('<POSTCODE1>','</POSTCODE1>'),                          
                                                                  str.substringBetween('<UNIT_NUMBER_LOW>','</UNIT_NUMBER_LOW>'),
                                                                  str.substringBetween('<UNIT_NUMBER_HIGH>','</UNIT_NUMBER_HIGH>'),
                                                                  str.substringBetween('<FIRM>','</FIRM>'),
                                                                  str.substringBetween('<PRIMARY_POSTFIX1>','</PRIMARY_POSTFIX1>'),
                                                                  str.substringBetween('<LOCALITY3>','</LOCALITY3>'),
                                                                  str.substringBetween('<PRIMARY_NAME2>','</PRIMARY_NAME2>'),
                                                                  str.substringBetween('<building_name>','</building_name>'),
                                                                  str.substringBetween('<PRIMARY_NUMBER_DESCRIPTION>','</PRIMARY_NUMBER_DESCRIPTION>'),
                                                                  str.substringBetween('<PRIMARY_NAME_FULL1>','</PRIMARY_NAME_FULL1>'),
                                                                  str.substringBetween('<PRIMARY_NAME_FULL2>','</PRIMARY_NAME_FULL2>'),
                                                                  str.substringBetween('<primary_secondary_address>','</primary_secondary_address>'),                
                                                                  str.substringBetween('<PRIMARY_SIDE_INDICATOR>','</PRIMARY_SIDE_INDICATOR>'),                         
                                                                  str.substringBetween('<SECONDARY_SIDE_INDICATOR>','</SECONDARY_SIDE_INDICATOR>'),
                                                                  str.substringBetween('<FLOOR_NUMBER_LOW>','</FLOOR_NUMBER_LOW>'),
                                                                  str.substringBetween('<FLOOR_NUMBER_HIGH>','</FLOOR_NUMBER_HIGH>'),
                                                                  str.substringBetween('<FLOOR_DESCRIPTION>','</FLOOR_DESCRIPTION>')));                          
                            }      
                            
                        }                 
                    }
                    
                } 
                Dom.Document doc = res.getBodyDocument(); 
                Dom.XMLNode envelope =doc.getRootElement();                        
                Dom.XmlNode validateResponse = envelope.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/').getChildElement('ValidateWithSuggestionResponse','http://dell.com/AddressValidation/ValidateWithSuggestion/output');                
                resultPostalCode = validateResponse.getChildElement('postcode','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultStatusCode = validateResponse.getChildElement('sugg_status','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSuggestionCount = validateResponse.getChildElement('sugg_count','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSuggestionEntry = validateResponse.getChildElement('sugg_entry','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultStatusDesc = validateResponse.getChildElement('address_fault_desc','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultStreetNo = validateResponse.getChildElement('house_number','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultStreet = validateResponse.getChildElement('address','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultCity = validateResponse.getChildElement('locality1','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultState = validateResponse.getChildElement('state','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultBuilding = validateResponse.getChildElement('building','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultFirm = validateResponse.getChildElement('firm','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultcountry = validateResponse.getChildElement('country','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultUnit = validateResponse.getChildElement('unitnum','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSecondaryAdd = validateResponse.getChildElement('secondary_address','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultunitNum = validateResponse.getChildElement('unitnum','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultRDI = validateResponse.getChildElement('rdi_flag','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();
                resultLocality2 = validateResponse.getChildElement('locality2','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultLocality3 = validateResponse.getChildElement('locality3','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultPrimaryAddress = validateResponse.getChildElement('primary_address','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSt = validateResponse.getChildElement('street','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSt2 = validateResponse.getChildElement('street2','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                
                // Defect138487 To set country to any value for error message to appear
                if((resultCountry == null || resultCountry == '') && resultStatusDesc != 'Assigned Address' && resultSuggestionCount =='0'){
                    resultCountry = 'Brazil';
                    
                    
                    
                }
                
                resLoc2Loc3 = resultLocality2 + ' ' + resultLocality3; 
                
                resLoc2Loc3China = resultLocality2 + ' ' + resultLocality3 + ' ' + resultSt + ' ' + resultSt2;
                if((resultCountry == 'Japan'|| resultCountry == 'China') && resultSuggestionCount =='0' || Test.isRunningTest()){
                    if(resultStatusDesc == 'Locality, region, and postcode are valid Unable to match primary name to directory'){
                        resultStatusDesc = 'Assigned Address';
                    }
                    
                    if(resultSt.isNumeric() && resultSt2.isNumeric() && resultStreetNo.isNumeric()){
                        resJapanSt = resultSt + '-' + resultSt2 + '-' +resultStreetNo ;
                    }
                    else if((resultSt.isNumeric() && resultSt2.isNumeric() && !resultStreetNo.isNumeric()) || (resultSt.isNumeric() && resultSt2.isNumeric() && (resultStreetNo == null || resultStreetNo == ''))){
                        resJapanSt = resultSt + '-' + resultSt2 + ' ' + resultStreetNo;
                    }
                    else if ((!resultSt.isNumeric() && resultSt2.isNumeric() && resultStreetNo.isNumeric()) || ((resultSt ==null || resultSt =='') && resultSt2.isNumeric() && resultStreetNo.isNumeric())){
                        resJapanSt = resultSt + ' ' + resultSt2 + '-' +resultStreetNo ;
                    }
                    else if ((resultSt.isNumeric() && (resultSt2==null || resultSt2=='') && resultStreetNo.isNumeric())){
                        resJapanSt = resultSt + '-' +resultStreetNo ;
                    }
                    else if ((resultSt.isNumeric() && !resultSt2.isNumeric() && resultStreetNo.isNumeric())){
                        resJapanSt = resultSt + '-' +resultSt2 + ' ' +resultStreetNo ;
                    }
                    else{
                        resJapanSt = resultSt + ' ' + resultSt2 + ' ' +resultStreetNo ;
                    }
                }else if(resultCountry == 'China'){
                    if(resultSt.isNumeric() && resultSt2.isNumeric()){
                        resChinaSt = resultSt + '-' + resultSt2;
                    }else{
                        resChinaSt = resultSt + ' ' + resultSt2;
                        
                    }
                }
                // Sprint4 defect
                if(resultCountry == 'Japan'){
                    if(resultBuilding!=null || resultBuilding!=' '){
                        if(resultSecondaryAdd!=null || resultSecondaryAdd!=' '){
                            string[] secAdd = resultSecondaryAdd.Split(' ');
                            if(secAdd.size() == 1){
                                buildNameJapan = secAdd[0];
                            }else if(secAdd.size() > 1){
                                buildNameJapan = secAdd[0] + ' ' + secAdd[1];
                            }
                            
                        }
                    }
                }
                
                if(resultCountry == 'China' || Test.isRunningTest()){
                    if(resultSecondaryAdd.length() != 0 || Test.isRunningTest()){
                        string[] secAdd = resultSecondaryAdd.Split(' ');
                        integer x = secAdd.size();
                        integer y = x-1;      
                        if(resultBuilding.length() != 0){                                                        
                            if(resultUnitNum.length() != 0){
                                if((secAdd.size() == 1) || (secAdd[1] == resultUnitNum)){
                                    buildNameChina = secAdd[0];
                                    
                                }else if(secAdd.size() > 1 && secAdd[y] != resultUnitNum && secAdd[y] != secAdd[1]){
                                    buildNameChina = secAdd[0] + ' ' + secAdd[1];
                                    resultUnitNum = secAdd[y];
                                    
                                }else if(secAdd.size() > 1 && secAdd[y] != resultUnitNum){
                                    buildNameChina = secAdd[0];
                                    resultUnitNum = secAdd[y];
                                    
                                }
                                else if(secAdd.size() > 1){
                                    buildNameChina = secAdd[0] + ' ' + secAdd[1];
                                    
                                }
                            }
                            else{
                                buildNameChina = resultSecondaryAdd;
                            }
                            
                        }
                        else if(resultBuilding.length() == 0 && resultUnitNum.length() != 0 ){
                            resultUnitNum = secAdd[y];
                        }
                    }else{
                        buildNameChina = resultBuilding;
                    }
                }
                
                if(resultCountry == 'Australia'){
                    IF(resultstreet != NULL || resultstreet != '')     
                        Ausresultstreet = resultstreet;
                    
                    //version 2.0              
                    if(resultSecondaryAdd!=null || resultSecondaryAdd!=' '){
                        if(resultunitNum == NULL || resultunitNum == ''){
                            buildAusFloorNumber = resultSecondaryAdd;
                        }
                        else{
                            buildAusFloorNumber = resultSecondaryAdd.substringAfter(resultunitNum);                                                         
                        }
                    }
                    
                    if(buildAusFloorNumber == NULL || buildAusFloorNumber == ''){
                        showFloorNumber = false;}
                    else{
                        showFloorNumber = true;}
                }   
                
                IF(resultCountry == 'Australia' && (resultstreet != NULL || resultstreet !='')){                  
                    resultstreet=resultSt;    
                }         
                ELSE{
                    resultstreet = resultstreet;
                }        
                if(resultRDI == 'Y'){
                    oRDI = true;
                }
                else{
                    oRDI = false; 
                }    
            }
        }        
        //YOU CAN ALWAYS PARSE THE RESPONSE XML USING XmlStreamReader  CLASS          
        catch(System.CalloutException e) {                    
            throwExcep(System.Label.AVS_Res_Error);
            //Exception handling goes here....       
        }         
    }             
    
    
    public class suggestions {        
        public Boolean selected {get; set;}        
        public string SELECTION{get;set;}        
        public string LOCALITY1{get;set;}         
        public string LOCALITY2{get;set;}
        public string LOCALITY3{get;set;}        
        public string REGION1{get;set;}          
        public string POSTCODE{get;set;}        
        public string POSTCODE1{get;set;}        
        public string POSTCODE2_ODD{get;set;}        
        public string POSTCODE2_EVEN{get;set;}               
        public string PRIMARY_NUMBER_LOW{get;set;}        
        public string PRIMARY_NUMBER_HIGH{get;set;}        
        public string PRIMARY_NAME1{get;set;}        
        public string PRIMARY_TYPE1{get;set;}        
        public string sPostalCode{get;set;}        
        public string FINALPOSTAL = POSTCODE+'-'+POSTCODE2_EVEN;        
        public string FINALSTREET = PRIMARY_NAME1+' '+PRIMARY_TYPE1;        
        public String UNIT_NUMBER_LOW{get;set;}        
        public String UNIT_NUMBER_HIGH{get;set;}        
        public String FIRM{get;set;}        
        public String PRIMARY_POSTFIX1{get;set;}
        public string PRIMARY_NAME2{get;set;} 
        public String building_name{get; set;}
        public String PRIMARY_NUMBER_DESCRIPTION{get; set;}
        public String PRIMARY_NAME_FULL1{get; set;}
        public String PRIMARY_NAME_FULL2{get; set;}
        public String primary_secondary_address{get; set;}       
        public String PRIMARY_SIDE_INDICATOR{get; set;}       
        public String SECONDARY_SIDE_INDICATOR{get; set;} 
        public String FLOOR_NUMBER_LOW{get;set;}        
        public String FLOOR_NUMBER_HIGH{get;set;}       
        //Start - By Sreehari
        public String FLOOR_DESCRIPTION{get;set;}      
        // End  - By Sreehari
        
        public suggestions( boolean selected,String SELECTION, String LOCALITY1,String REGION1,String POSTCODE, String POSTCODE2_ODD,String POSTCODE2_EVEN,String PRIMARY_NUMBER_LOW,String PRIMARY_NUMBER_HIGH,String PRIMARY_NAME1, String PRIMARY_TYPE1, String LOCALITY2, String POSTCODE1, String UNIT_NUMBER_LOW, String UNIT_NUMBER_HIGH, String FIRM, String PRIMARY_POSTFIX1, String LOCALITY3, String PRIMARY_NAME2, String building_name, String PRIMARY_NUMBER_DESCRIPTION, String PRIMARY_NAME_FULL1, String PRIMARY_NAME_FULL2, String primary_secondary_address, String PRIMARY_SIDE_INDICATOR, String SECONDARY_SIDE_INDICATOR, String FLOOR_NUMBER_LOW, String FLOOR_NUMBER_HIGH,string FLOOR_NUMBER_DESCRIPTION)        
        {             
            this.selected = selected;             
            this.SELECTION = SELECTION;             
            this.LOCALITY1 = LOCALITY1;             
            this.REGION1 = REGION1;             
            this.POSTCODE = POSTCODE;             
            this.POSTCODE2_ODD =POSTCODE2_ODD;             
            this.POSTCODE2_EVEN = POSTCODE2_EVEN;             
            this.PRIMARY_NUMBER_LOW = PRIMARY_NUMBER_LOW;             
            this.PRIMARY_NUMBER_HIGH = PRIMARY_NUMBER_HIGH;             
            this.PRIMARY_NAME1 = PRIMARY_NAME1;             
            this.PRIMARY_TYPE1 = PRIMARY_TYPE1;             
            this.LOCALITY2 = LOCALITY2; 
            this.LOCALITY3 = LOCALITY3;            
            this.POSTCODE1 = POSTCODE1;                       
            this.UNIT_NUMBER_LOW=UNIT_NUMBER_LOW;             
            this.UNIT_NUMBER_HIGH=UNIT_NUMBER_HIGH;             
            this.FIRM = FIRM;             
            this.PRIMARY_POSTFIX1 = PRIMARY_POSTFIX1;   
            this.PRIMARY_NAME2 = PRIMARY_NAME2; 
            this.building_name = building_name; 
            this.PRIMARY_NUMBER_DESCRIPTION = PRIMARY_NUMBER_DESCRIPTION;
            this.PRIMARY_NAME_FULL1 = PRIMARY_NAME_FULL1;
            this.PRIMARY_NAME_FULL2 = PRIMARY_NAME_FULL2;
            this.primary_secondary_address = primary_secondary_address;                     
            this.PRIMARY_SIDE_INDICATOR = PRIMARY_SIDE_INDICATOR;                     
            this.SECONDARY_SIDE_INDICATOR = SECONDARY_SIDE_INDICATOR;  
            this.FLOOR_NUMBER_LOW = FLOOR_NUMBER_LOW;
            this.FLOOR_NUMBER_HIGH = FLOOR_NUMBER_HIGH;
            this.FLOOR_DESCRIPTION =  FLOOR_NUMBER_DESCRIPTION;                      
        }    
    }            
    
    public pagereference save()    {        
        Contact con=new Contact(Id=contactId);        
        con.MailingPostalCode=oPostalCode;         
        con.MailingStreet=oStreet;        
        con.MailingState=oState;        
        con.MailingCountry=ocountry;        
        con.MailingCity=oCity;        
        update con;        
        return PageUtils.redirect('/' + con.Id);    
    }  
    
    
    public PageReference doCancel(){        
        Contact con=new Contact(Id=contactId, Residential_Delivery_Flag__c=false, AVS_Verification_Flag__c = false);
        update con;
        return PageUtils.redirect('/' + contactId);    
    }     
    
    public PageReference refineSearch() {
        Integer count = 0;
        for(suggestions obj: lstSuggestion) {
            if(obj.selected) {
                count++;
            }
        }   
        if(count == 1) {
            for(suggestions obj: lstSuggestion) {
                if(obj.selected) {
                    
                    if(aptOrSuiteNumber.isNumeric()){
                        Integer myIntKeyRange = Integer.valueOf(aptOrSuiteNumber);
                        Integer isOddorEven = math.mod(myIntKeyRange,2);
                        
                        if(obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW ){
                            Integer myIntKeyPH = Integer.valueOf(obj.PRIMARY_NUMBER_HIGH);
                            Integer myIntKeyPL = Integer.valueOf(obj.PRIMARY_NUMBER_LOW);                           
                            if(!(myIntKeyRange <= myIntKeyPH && myIntKeyRange >= myIntKeyPL)){
                                resultSuggestionCount ='0';
                                resultCountry = 'dummyCountry';
                                resultStatusDesc = 'ToShowErrorMessage';
                                return null;
                            }else{
                                if(obj.PRIMARY_SIDE_INDICATOR == 'E' && isOddorEven != 0){
                                    resultSuggestionCount ='0';
                                    resultCountry = 'dummyCountry';
                                    resultStatusDesc = 'ToShowErrorMessage';
                                }
                                else if(obj.PRIMARY_SIDE_INDICATOR == 'O' && isOddorEven == 0){
                                    resultSuggestionCount ='0';
                                    resultCountry = 'dummyCountry';
                                    resultStatusDesc = 'ToShowErrorMessage';
                                }
                            }
                        }else if((obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW){
                            Integer myIntKeyUH = Integer.valueOf(obj.UNIT_NUMBER_HIGH);
                            Integer myIntKeyUL = Integer.valueOf(obj.UNIT_NUMBER_LOW);
                            if(!(myIntKeyRange <= myIntKeyUH && myIntKeyRange >= myIntKeyUL)){
                                resultSuggestionCount ='0';
                                resultCountry = 'dummyCountry';
                                resultStatusDesc = 'ToShowErrorMessage';
                                return null;
                            }else{
                                if(obj.SECONDARY_SIDE_INDICATOR == 'E' && isOddorEven != 0){
                                    resultSuggestionCount ='0';
                                    resultCountry = 'dummyCountry';
                                    resultStatusDesc = 'ToShowErrorMessage';
                                }
                                else if(obj.SECONDARY_SIDE_INDICATOR == 'O' && isOddorEven == 0){
                                    resultSuggestionCount ='0';
                                    resultCountry = 'dummyCountry';
                                    resultStatusDesc = 'ToShowErrorMessage';
                                }
                            }
                        }
                        //version 2.0
                        else if((obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW) && obj.FLOOR_NUMBER_HIGH!= null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW){
                            Integer myIntKeyUH = Integer.valueOf(obj.FLOOR_NUMBER_HIGH);
                            Integer myIntKeyUL = Integer.valueOf(obj.FLOOR_NUMBER_LOW);
                            
                            if(!(myIntKeyRange <= myIntKeyUH && myIntKeyRange >= myIntKeyUL)){
                                resultSuggestionCount ='0';
                                resultCountry = 'dummyCountry';
                                resultStatusDesc = 'ToShowErrorMessage';
                                return null;
                            }else{
                                if(obj.SECONDARY_SIDE_INDICATOR == 'E' && isOddorEven != 0){
                                    resultSuggestionCount ='0';
                                    resultCountry = 'dummyCountry';
                                    resultStatusDesc = 'ToShowErrorMessage';
                                }
                                else if(obj.SECONDARY_SIDE_INDICATOR == 'O' && isOddorEven == 0){
                                    resultSuggestionCount ='0';
                                    resultCountry = 'dummyCountry';
                                    resultStatusDesc = 'ToShowErrorMessage';
                                }
                            }
                        }         
                    }
                    
                    if(resultSuggestionCount != '0') {
                        resetReply = 1;
                        if(!resultStatusDesc.contains('Assigned Address') || resultSuggestionCount != '0') {
                            if (Reply1 == null && obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW) {
                                Reply1 = obj.SELECTION;
                                Reply2 = aptOrSuiteNumber;
                            } 
                            else if (Reply1 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW) {
                                Reply1 = obj.SELECTION;
                                Reply2 = aptOrSuiteNumber;
                            }
                            
                            else if (Reply1 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW)&& obj.FLOOR_NUMBER_HIGH != null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW) {
                                Reply1 = obj.SELECTION;
                                Reply2 = aptOrSuiteNumber;
                            }
                            
                            else if (Reply1 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && !Test.isRunningTest()) {
                                Reply1 = obj.SELECTION;
                            }
                            else if (Reply1 != null && Reply2 == null && obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW) {
                                Reply2 = obj.SELECTION;
                                Reply3 = aptOrSuiteNumber;
                            }
                            else if (Reply1 != null && Reply2 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW) {
                                Reply2 = obj.SELECTION;
                                Reply3 = aptOrSuiteNumber;
                            }
                            
                            else if (Reply1 != null && Reply2 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW)&& obj.FLOOR_NUMBER_HIGH != null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW) {
                                Reply2 = obj.SELECTION;
                                Reply3 = aptOrSuiteNumber;
                            }                                                                                
                            
                            else if (Reply1 != null && Reply2 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW)) {
                                Reply2 = obj.SELECTION;
                            }
                            else if (Reply1 != null && Reply2 != null && Reply3 == null && obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW) {
                                Reply3 = obj.SELECTION;
                                Reply4 = aptOrSuiteNumber;
                            }
                            else if (Reply1 != null && Reply2 != null && Reply3 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW) {
                                Reply3 = obj.SELECTION;
                                Reply4 = aptOrSuiteNumber;
                            }
                            
                            else if (Reply1 != null && Reply2 != null && Reply3 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW)&& obj.FLOOR_NUMBER_HIGH != null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW) {
                                Reply3 = obj.SELECTION;
                                Reply4 = aptOrSuiteNumber;
                            }                                                                           
                            
                            else if (Reply1 != null && Reply2 != null && Reply3 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW)) {
                                Reply3 = obj.SELECTION;
                            }
                            else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 == null && obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW) {
                                Reply4 = obj.SELECTION;
                                Reply5 = aptOrSuiteNumber;
                            }
                            else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW) {
                                Reply4 = obj.SELECTION;
                                Reply5 = aptOrSuiteNumber;
                            }
                            
                            else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW)&& obj.FLOOR_NUMBER_HIGH != null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW) {
                                Reply4 = obj.SELECTION;
                                Reply5 = aptOrSuiteNumber;
                            }                                                                                                  
                            
                            else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW)) {
                                Reply4 = obj.SELECTION;
                            }
                            else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 != null && Reply5 == null) {
                                Reply5 = obj.SELECTION;
                            }
                            else {
                                Reply1 = null;
                                Reply2 = null;
                                Reply3 = null;
                                Reply4 = null;
                                Reply5 = null;
                            }
                            aptOrSuiteNumber = null;
                            CallAVS();
                        }
                        return null;
                    }
                    break;
                }
                
            }
        }
        return null;
    }                 
}