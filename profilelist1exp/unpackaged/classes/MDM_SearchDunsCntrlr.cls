/***********************************************************
* Name          : MDM_SearchDunsCntrlr
* Description   : Extension class for the D&B Account hierarchy page
* ---------------------------------------------------------
* Revision      Release     Name        Date            Description
* 1.0           16.03       Ninie     9-12-2014       Developed parsing the response, building the hierarhcy (parent-child relationships of the wrapper class),
                                                        and sorting by Region or Country
************************************************************/

public class MDM_SearchDunsCntrlr{
    
    public Id AccountId;
    public Account AccountObj{get;set;}
    public Country__c CountryObj{get;set;}
    public List<dunsdetails> finalList{get;set;}
    public List<String> primarySubChildList {get;set;}
    //maps added by Rap
    public Map<String, String> sfdcCountryMap;
    public Map<String, String> sfdcRegionMap;
    public Map<String, String> sfdcCountryCodeMap;
    public Map<String, String> sfdcDNBCountryCodeMap;
    //public Map<String, String> sfdcDNBIsoCodeMap;
    public List <Country__c> CountryName;
    public String currentDNBCode {get;set;}
    public Boolean dunsNameCountryPostal {get;set;}
    
    public String oCountry{get;set;}
    public String oCountyCode{get;set;}
    public String oCity{get;set;}
    public String oDunsId{get;set;}
    public String oBusinessName{get;set;}
    public String oState{get;set;}
    public String oPostalCode{get;set;}
    public String oAddress1{get;set;}
    public String oOOB{get;set;}
    public String oEmployeeSize{get;set;}
    public String oMessage{get;set;}
    public String searchMethod {get;set;}
    public String iDunsId{get;set;}  //changed from string to integer
    public String iAffinityId{get;set;}
    public String iCustNum{get;set;}
    public String iBUID{get;set;}
    public String iDunsName{get;set;}
    public String iCountry{get;set;}
    public String iState{get;set;}
    public String iCity{get;set;}
    public String iPostalCode{get;set;}
    public String iRegion{get;set;}
    public String iProbabilistic{get;set;}
    public String iDeterministic{get;set;}
    public String iProNDetministic{get;set;}
    public String AccountCountryCode{get;set;}
    public String selectedDuns{get;set;}
    public String selectedDunsValue{get;set;}
    public String RegionList{get;set;}
    public Boolean Showclose{get;set;} 
    public Boolean isupdtd{get;set;} 
    public String checkVal{get;set;} 
    
    public string ResError; 
    public string CILResError;
    public string CILresponseBody;
    public Integer SearchOrgReCount;
    public String isLightning {get;set;}
    
    public Boolean showDunsNumber, showAffinity, showCusNum, showBUID, showDunsName, showCountry, showState, showCity, showPostalCode, showResultTable, showResultBlock, showRegion;
    Account acct;
    
public MDM_SearchDunsCntrlr(ApexPages.StandardController stdController){
    isupdtd = false;
    isLightning = 'false';
    system.debug('Value of lightning variable is1'+isLightning);
    acct = (Account)stdController.getRecord();
    AccountObj = new Account();
    showclose = Boolean.valueOf(system.currentpagereference().getparameters().get('close'));
    isLightning = apexpages.currentpage().getparameters().get('lightningPage');
    system.debug('Value of lightning variable is2'+isLightning);
    system.debug('showclose:::::' + showclose);
    sfdcCountryMap = new Map<String,String>();
    sfdcRegionMap = new Map<String,String>();
    sfdcCountryCodeMap = new Map<String,String>();
    sfdcDNBCountryCodeMap = new Map<String,String>();
    dunsNameCountryPostal = false;
    if(isLightning== 'true')
    showclose = false;
    CountryName = [Select Name, DNB_ISO_Country_Code__c, DNB_Country_Code__c, DNB_Region__c from Country__c where DNB_ISO_Country_Code__c != null AND DNB_Country_Code__c != null AND DNB_Region__c != null order by Name];
    for (Country__c CName: CountryName) {
        sfdcCountryMap.put(CName.DNB_Country_Code__c, CName.Name);
        sfdcRegionMap.put(CName.DNB_ISO_Country_Code__c, CName.DNB_Region__c);
        sfdcCountryCodeMap.put(CName.DNB_Country_Code__c, CName.DNB_ISO_Country_Code__c);
        sfdcDNBCountryCodeMap.put(CName.Name, CName.DNB_Country_Code__c);
    }
    if (ApexPages.currentPage().getParameters().containsKey('Id'))
            AccountId = ApexPages.currentPage().getParameters().get('Id');
        else if (ApexPages.currentPage().getParameters().containsKey('newid')) {
            AccountId = ApexPages.currentPage().getParameters().get('newid');
        }
    List<Account> AccountList = [Select Account_ID__c, Name, Account_Country_Code__c, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry from Account where Id =: AccountId LIMIT 1];
    showResultBlock = false;
    If(AccountId == null){
        showAffinity = true;
        showResultBlock = false;
     }
    else{
    AccountObj = AccountList[0];
    System.Debug('ACCOUNT ID##'+AccountObj.Account_ID__c);
    String AffinityId = AccountObj.Account_ID__c;
    String DunsName = AccountObj.Name;
    String ShippingCountry = AccountObj.ShippingCountry;
    String ShippingState = AccountObj.ShippingState;
    String ShippingCity = AccountObj.ShippingCity;
    String ShippingPostalCode = AccountObj.ShippingPostalCode;
    
    If(AffinityId != null){
        iAffinityId = AffinityId;
        searchMethod = 'Affinity ID';
        showAffinity = true;
        showResultTable = false;
        showResultBlock = false;
        callMDM();
    }
    
     else if (AffinityId == null){
        iDunsName = DunsName;
        currentDNBCode = sfdcDNBCountryCodeMap.get(ShippingCountry);
        iCountry = sfdcCountryCodeMap.get(currentDNBCode);
        iPostalCode = ShippingPostalCode;
        searchMethod = 'DUNS Name + Country + Postal Code';
        showDunsName = true;
        showCountry = true;
        showPostalCode = true;
        showResultTable = false;
        dunsNameCountryPostal = true;
        callMDM();

     }
    }
    }
    String[] countries = new String[] {};
    public PageReference test() {
        return null;
    }
    public List <SelectOption> getItems() {
        
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('', ''));
        for (Country__c CName: CountryName) {
            options.add(new SelectOption(CName.DNB_Country_Code__c, CName.Name));
        }
        return options;
    }

    public String[] getCountries() {
        return countries;
    }

    public void setCountries(String[] countries) {
        this.countries = countries;
    }
    
   public List<SelectOption> getRegionOptions() {
        List<SelectOption> regionOptions = new List<SelectOption>();
        regionOptions.add(new SelectOption('AMER','AMER'));
        regionOptions.add(new SelectOption('APJ','APJ'));
        regionOptions.add(new SelectOption('EMEA','EMEA'));
        return regionOptions;
    }
    String asciiRegEx = '^[0-9]+$'; 
    Pattern MyPattern = Pattern.compile(asciiRegEx);
    
    public Boolean checkAscii(String toCheck){
        Matcher MyMatcher = MyPattern.matcher(toCheck);
        Boolean result = MyMatcher.matches();
        return result;
    }
    public PageReference showErroronPage(boolean labelsSwitch)
    {
        String ErrorMessage;
        if(labelsSwitch == true)
        {
            ErrorMessage = System.Label.MDM_Search_Field_Error;
        }
        else
        {
            ErrorMessage = System.Label.MDM_Numeric_Only_Error;
        }
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, +ErrorMessage);
        ApexPages.addMessage(myMsg);
        showResultTable = false;
        showResultBlock = false;
        return null;
    }

    public PageReference callMDM(){
        System.debug('iProNDetministic:'+iProNDetministic);
        System.debug('isupdtd:'+isupdtd);
        if(isupdtd == true){
            checkVal = iProNDetministic;
        }
        else{
            iProNDetministic = checkVal;
        }
        isupdtd = false;
        String ErrorMessage = System.Label.MDM_Search_Field_Error;
        if (showDunsNumber== true && (iDunsId == ''|| iDunsId == null)){   //
            showErroronPage(true);
        }
        else if(showAffinity == true && (iAffinityId==''||iAffinityId==null)){
            showErroronPage(true);
        }
        else if(showCusNum == true  && ( iCustNum=='' || iCustNum==null)){  //
            showErroronPage(true);
        }
        else if(showBUID == true && ( iBUID == '' || iBUID == null)){ //
            showErroronPage(true);
        }
        else if(showDunsName == true && (iDunsName == '' || iDunsName == null)){
            showErroronPage(true);
        }
        else if(showCountry == true && (iCountry == '' || iCountry == null)){
            showErroronPage(true);
        }
        else if(showState == true && (iState == '' || iState == null)){
            showErroronPage(true);
        }
        else if(showPostalCode == true && (iPostalCode == '' || iPostalCode == null)){
            showErroronPage(true);
        }
        else if(showCity == true && (iCity == '' || iCity == null)){
            showErroronPage(true);
        }
        else if(showRegion == true && (iRegion == '' || iRegion == null)){
            showErroronPage(true);
        }
        else if(iDunsId != null && !(checkAscii(iDunsId))){
            showErroronPage(false);
        }
        else if(iAffinityId != null && !(checkAscii(iAffinityId))){
            showErroronPage(false);
        }
        else if(iCustNum != null && !(checkAscii(iCustNum))){
            showErroronPage(false);
        }
        else if(iBUID != null && !(checkAscii(iBUID))){
            showErroronPage(false);
        }
        else if (searchMethod.contains('DUNS Name')) {
            searchDunsByName();
        }
        else{
            searchDuns();
        }

        return null;
    }
    
    public List<SelectOption> getSearchOptions() {
        List<SelectOption> searchOptions = new List<SelectOption>();
        searchOptions.add(new SelectOption('Affinity ID', System.Label.MDM_Field_AffinityID));
        searchOptions.add(new SelectOption('Duns Number', System.Label.MDM_Field_DunsNumber));
        searchOptions.add(new SelectOption('Customer Number + BUID', System.Label.MDM_Field_CustomerNumber + ' +  ' + System.Label.MDM_Field_BUID));
        searchOptions.add(new SelectOption('DUNS Name + Country', System.Label.MDM_Field_DunsName + ' +  ' + System.Label.MDM_Field_Country));
        searchOptions.add(new SelectOption('DUNS Name + Country + State', System.Label.MDM_Field_DunsName + ' +  ' + System.Label.MDM_Field_Country + ' +  ' + System.Label.MDM_Field_State));
        searchOptions.add(new SelectOption('DUNS Name + Country + State + City', System.Label.MDM_Field_DunsName + ' +  ' + System.Label.MDM_Field_Country + ' +  ' + System.Label.MDM_Field_State + ' +  ' + System.Label.MDM_Field_City));
        searchOptions.add(new SelectOption('DUNS Name + Country + Postal Code', System.Label.MDM_Field_DunsName + ' +  ' + System.Label.MDM_Field_Country + ' +  ' + System.Label.MDM_Field_PostalCd));
        searchOptions.add(new SelectOption('DUNS Name + Region', System.Label.MDM_Field_DunsName + ' +  ' + System.Label.MDM_Field_Region));

        return searchOptions;
    }

    public PageReference selectSearch(){

        iAffinityId = null;
        iDunsName = null;
        iDunsId = null;
        iBUID = null;
        iCity = null;
        iPostalCode = null;
        iCustNum = null;
        iCountry = null;
        iRegion = null;
        showResultBlock = false;
        showResultTable = false;
        oMessage = null;
        checkVal = 'P';
        
        if (searchMethod.contains('Duns Number')){
            showDunsNumber = true;
        }
        else
            showDunsNumber = false;
        
        if (searchMethod.contains('Affinity ID')){
            showAffinity = true;
        }
        else
            showAffinity = false;
            
        if (searchMethod.contains('Customer Number')){
            showCusNum = true;
        }
        else
            showCusNum = false;
            
        if (searchMethod.contains('BUID')){
            showBUID = true;
        }
        else
            showBUID = false;
            
        if (searchMethod.contains('DUNS Name')){
            showDunsName = true;
        }
        else
            showDunsName = false;
            
        if (searchMethod.contains('Country')){
            showCountry = true;
        }
        else
            showCountry = false;
            
        if (searchMethod.contains('State')){
            showState = true;
        }
        else
            showState = false;
            
        if (searchMethod.contains('City')){
            showCity = true;
        }
        else
            showCity = false;
            
        if (searchMethod.contains('Postal Code')){
            showPostalCode = true;
        }
        else
            showPostalCode = false;
        
         if (searchMethod.contains('Region')){
            showRegion = true;
        }
        else
            showRegion = false;
        
        
        return null;
    }

    public Boolean getShowDunsNumber(){
        return showDunsNumber;
    }

    public Boolean getShowAffinity(){
        return showAffinity;
    }

    public Boolean getShowCusNum(){
        return showCusNum;
    }

    public Boolean getShowBUID(){
        return showBUID;
    }

    public Boolean getShowDunsName(){
        return showDunsName;
    }

    public Boolean getShowCountry(){
        return showCountry;
    }

    public Boolean getShowState(){
        return showState;
    }

    public Boolean getShowCity(){
        return showCity;
    }

    public Boolean getShowPostalCode(){
        return showPostalCode;
    }
    
    public Boolean getShowRegion(){
        return showRegion;
    }
    public Boolean getshowResultTable(){
        return showResultTable;
    }
    public Boolean getshowResultBlock(){
        return showResultBlock;
    }
    
 public void searchDuns() {
 
        oMessage = null;
        Integer i;
        Integer lastcount = 0;
        List<Dom.XmlNode> childlist = new List<Dom.XmlNode>();
        List<Dom.XmlNode> primaryChildList = new List<Dom.XmlNode>();
        String PrimaryChildElementName;
        primarySubChildList = new List<String>();
        
        string responseBody;
        Integer childElementCount =0;
        Integer primaryChildElementsCount = 0;
        Integer PrimarysubChildElementsCount = 0;
        showResultTable = false;
        showResultBlock = false;
        
        String Requestbody;
        if (searchMethod.contains('Duns Number')){
            Requestbody =                '<b:Account>No</b:Account><b:Address>No</b:Address><b:CRM>No</b:CRM><b:CompanyDetail>No</b:CompanyDetail><b:Contact>No</b:Contact><b:DunsId xmlns:c="http://schemas.microsoft.com/2003/10/Serialization/Arrays"><c:long>'+iDunsId+'</c:long></b:DunsId><b:Firmography>No</b:Firmography><b:Primary>Yes</b:Primary>';
        }else if (searchMethod.contains('Affinity ID')){
            Requestbody =
            '<b:AffinityId>'+iAffinityId+'</b:AffinityId>';
        }else if (searchMethod.contains('Customer Number')){
            Requestbody =
            '<b:Buid>'+iBUID+'</b:Buid><b:CustomerId>'+iCustNum+'</b:CustomerId>';
        }
        
        
        string xmlString = '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing">'
   +'<s:Header>'
      +'<a:Action s:mustUnderstand="1">CIL/IExploreAffinity/SearchDuns</a:Action>'
      +'<a:MessageID>'+System.Label.MDM_MessageID+'</a:MessageID>'
      +'<a:ReplyTo>'
         +'<a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>'
      +'</a:ReplyTo>'
      +'<a:To s:mustUnderstand="1">'+System.Label.MDM_SITURL+'</a:To>'
   +'</s:Header>'
   +'<s:Body>'
      +'<SearchDuns xmlns="CIL">'
         +'<request i:type="b:CustomerMDMDunsSearchRequestBObj" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Duns.Request" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
            +'<b:DunsBObj>'+Requestbody+'</b:DunsBObj>'
         +'</request>'
      +'</SearchDuns>'
   +'</s:Body>'
+'</s:Envelope>';
    
      Httprequest req = new Httprequest();
    req.setMethod('POST');
    req.setHeader('content-type','text/xml;charset=UTF-8');
    req.setHeader('SOAPAction','');
    req.setHeader('Authorization',System.Label.MDM_Credentials);
 
         if(Environment.isProduction()) { 
             req.setEndpoint(System.Label.MDM_Prod_Url);
         }else{
             req.setEndpoint(System.Label.MDM_Sandbox_Url);   
         }   
    req.setBody(xmlString);
    req.setTimeout(120000);
    system.debug('Request Body: '+ req.getBody());
    
    http http = new http();
    
    try{
        httpresponse res;
        Integer totalRun;
            for(Integer a = 0; a <= 9; a++){
                res = http.send(req);
                
                if(res.getstatuscode() == 200){
                    responseBody = res.getBody();
                    totalRun = a+1;
                    break;
                }
            }
            
            ResError = res.getStatus();
        System.debug('Response Body' +responseBody); 
        if(!ResError.contains('OK')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MDM_Connection_Failure);
            ApexPages.addMessage(myMsg);
            showResultTable = false;
            showResultBlock = false;       
        }    
        else {

            Dom.Document doc = new Dom.Document();
            doc.load(responseBody);
            System.Debug('ResponseBody##' +responseBody);
            
            Dom.XMLNode rootElement = doc.getRootElement();
            //System.Debug('rootElement'+rootElement);
            
            String rootElementName = rootElement.getName();
            //System.Debug('rootElementName'+rootElementName);
            
            Dom.XMLNode Body = rootElement.getChildElements()[1];
            String BodyName =  Body.getName();
            System.debug('Body :' +BodyName + Body);
            
            Dom.XMLNode SearchDunsResponse = Body.getChildElements()[0];
            String SearchDunsResponseName =  SearchDunsResponse.getName();
            //System.debug('SearchDunsResponseName :' +SearchDunsResponseName +' '+SearchDunsResponse);
            
            Dom.XMLNode SearchDunsResult = SearchDunsResponse.getChildElements()[0];
            String SearchDunsResultName =  SearchDunsResult.getName();
            //System.debug('SearchDunsResultName :' +SearchDunsResultName +' '+SearchDunsResult);
            
            Dom.XMLNode CommonSearchResponse = SearchDunsResult.getChildElements()[0];
            String CommonSearchResponseName =  CommonSearchResponse.getName();
            //System.debug('CommonSearchResponseName :' +CommonSearchResponseName +' '+CommonSearchResponse);
            
            Dom.XMLNode CommonSearchResponseObj = CommonSearchResponse.getChildElements()[0];
            String CommonSearchResponseObjName =  CommonSearchResponseObj.getName();
            //System.debug('CommonSearchResponseObjName :' +CommonSearchResponseObjName +' '+CommonSearchResponseObj);
                If (CommonSearchResponseObj.getName() == 'Message'){
                    oMessage = CommonSearchResponseObj.getText();
                    //System.debug('oMessage##' +oMessage);
                    showResultBlock = true;
                }
            
        for(Dom.XMLNode childelement : CommonSearchResponse.getChildElements())
                    {
                        childlist.add(childelement);
                        childElementCount++;
                        System.Debug('Child Element1:' +childElementCount +' ' + childelement);
                        System.Debug('childlist' +childlist);
                        finalList = new List<dunsdetails>();
                    }
            for (i=0; i < childElementCount; i++){
                for(Dom.XMLNode subChildElement: childlist[i].getChildElements())
                {
                    primaryChildList.add(subChildElement);
                    primaryChildElementsCount++;
                    //System.Debug('PrimSubChildElement:' +primaryChildElementsCount +' ' + subChildElement);
                    //System.Debug('primaryChildList' +primaryChildList);
                    
                    for(Dom.XMLNode PrimaryElement: primaryChildList[i].getChildElements()){
                    PrimaryChildElementName = PrimaryElement.getName();
                    primarySubChildList.add(PrimaryChildElementName);
                    PrimarysubChildElementsCount++;
                    System.Debug('Primary Sub Child Element:' +PrimarysubChildElementsCount +' ' + PrimaryChildElementName);
                        
                        If(primaryElement.getName() == 'Address1'){
                            oAddress1 = primaryElement.getText();
                            //System.Debug('Address1' +oAddress1);
                        }                    
                        If(primaryElement.getName() == 'BusinessName'){
                            oBusinessName = primaryElement.getText();
                            //System.Debug('oBusinessName' +oBusinessName);
                        }
                        If(primaryElement.getName() == 'City'){
                            oCity = primaryElement.getText();
                            //System.Debug('oCity' +oCity);
                        }
                        If(primaryElement.getName() == 'Country'){
                            oCountry = primaryElement.getText();
                            //System.Debug('oCountry' +oCountry);
                        }
                        If(primaryElement.getName() == 'CountyCode'){
                            oCountyCode = primaryElement.getText();
                            //System.Debug('oCountyCode' +oCountyCode);
                        }
                        If(primaryElement.getName() == 'DunsId'){
                            oDunsId = primaryElement.getText();
                            //System.Debug('oDunsId' +oDunsId);
                        }
                         If(primaryElement.getName() == 'OOB'){
                            oOOB = primaryElement.getText();
                            //System.Debug('oOOB' +oOOB);
                        }                   
                        If(primaryElement.getName() == 'PostalCode'){
                            oPostalCode = primaryElement.getText();
                        }
                         If(primaryElement.getName() == 'State'){
                            oState = primaryElement.getText();
                        }
                        If(primaryElement.getName() == 'EmployeeSize'){
                            oEmployeeSize = primaryElement.getText();
                        }
                    }   
                //added by Rap
                //oCountry = sfdcCountryMap.get(oCountyCode);
                finalList.add(new dunsdetails(true,oAddress1,oBusinessName,oCity,oCountry,oCountyCode,oDunsId,oOOB,oPostalCode,oState,oEmployeeSize));
            showResultTable = true;
            showResultBlock = true;
                }
                       
            }   
        }
    }
            
    catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MDM_Connection_Failure);
            ApexPages.addMessage(myMsg);
            system.debug('get the error' + e.getmessage() + '-' + e.getStackTraceString());
             
    }
            
   }
   
   
   
   /******************************BEGIN SEARCH DUNS BY DUNS NAME PARSING************************************/
   public void searchDunsByName() {
              
        Integer i;
        Integer lastcount = 0;
        List<Dom.XmlNode> SearchOrgReList = new List<Dom.XmlNode>();
        List<Dom.XmlNode> OrgExtChilList = new List<Dom.XmlNode>();
        List<Dom.XmlNode> AddressList = new List<Dom.XmlNode>();

        //string CILresponseBody;
        //Integer SearchOrgReCount = 0;
        SearchOrgReCount = 0;
        Integer OrgExtChildCount = 0;
        Integer AddressNodeCount  = 0;
        
        
        if(dunsNameCountryPostal == false){
            currentDNBCode = iCountry;
            iCountry = sfdcCountryCodeMap.get(currentDNBCode);
        }
        System.Debug('COUNTRYCODE?' + iCountry);
        System.Debug('sfdcRegionMap?' + sfdcRegionMap);
        //added by Rap
        If(iRegion == null || iRegion ==''|| iCountry!=null){
            iRegion = sfdcRegionMap.get(iCountry);
        }
        
        If(iProNDetministic == null || iProNDetministic==''){
            iProNDetministic = 'P';         
        }
        If(iCountry == null ){
            iCountry = '';
            currentDNBCode = null;
        }
        If(iState == null){
            iState = '';         
        }       
        If(iCity == null){
            iCity = '';         
        }       
        If(iPostalCode == null){
            iPostalCode = '';         
        }       


        System.Debug('COUNTRYCODE?' + iCountry);
        System.Debug('REGION?' + iRegion);
        System.Debug('PRO/Det?' + iProNDetministic);
        System.Debug('DunsName?' + iDunsName);
        System.Debug('State?' + iState);
        System.Debug('City?' + iCity);
        String CILXMLString;
        
        If(searchMethod == 'DUNS Name + Region'){
            CILXmlString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:cus="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:cus1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities" xmlns:cus2="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Utility">'
                            +'<soapenv:Header/>'
                            +'<soapenv:Body>'
                            +'<SearchDnBOrganization xmlns="http://tempuri.org/">'
                            +'<searchDNBRequestDTO xmlns:d4p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
                            +'<d4p1:OrganizationRequestObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities">'
                            +'<d5p1:OrganizationName>'+iDunsName+'</d5p1:OrganizationName>'
                            +'<d5p1:OrganizationType>FullName</d5p1:OrganizationType>'
                            +'</d4p1:OrganizationRequestObject>'
                            +'<d4p1:CommonObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities">'
                            +'<d5p1:SearchType>'+iProNDetministic+'</d5p1:SearchType>'
                            +'</d4p1:CommonObject>'
                            +'<d4p1:BasicFlag>Y</d4p1:BasicFlag>'
                            +'<d4p1:AddressFlag>Y</d4p1:AddressFlag>'
                            +'<d4p1:MiscFlag>Y</d4p1:MiscFlag>'
                            +'<d4p1:ParentFlag>Y</d4p1:ParentFlag>'
                            +'<d4p1:PhoneFlag>Y</d4p1:PhoneFlag>'
                            +'<d4p1:ContactFlag>Y</d4p1:ContactFlag>'
                            +'<d4p1:CrmFlag>Y</d4p1:CrmFlag>'
                            +'<d4p1:CompanyDetailsFlag>Y</d4p1:CompanyDetailsFlag>'
                            +'<d4p1:Region>'+iRegion+'</d4p1:Region>'
                            +'</searchDNBRequestDTO>'
                            +'<ApplicationName>SFDC</ApplicationName>'
                            +'</SearchDnBOrganization>'
                            +'</soapenv:Body>'
                            +'</soapenv:Envelope>';
        } else{
            CILXMLString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:cus="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:cus1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities" xmlns:cus2="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Utility">'
                            +'<soapenv:Header/>'
                            +'<soapenv:Body>'
                            +'<SearchDnBOrganization xmlns="http://tempuri.org/">'
                            +'<searchDNBRequestDTO xmlns:d4p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
                            +'<d4p1:OrganizationRequestObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities">'
                            +'<d5p1:OrganizationName>'+iDunsName+'</d5p1:OrganizationName>'
                            +'<d5p1:OrganizationType>FullName</d5p1:OrganizationType>'
                            +'</d4p1:OrganizationRequestObject>'
                            +'<d4p1:CommonObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities">'
                            +'<d5p1:SearchType>'+iProNDetministic+'</d5p1:SearchType>'
                            +'<d5p1:CityName>'+iCity+'</d5p1:CityName>  '  
                            +'<d5p1:CountryType>'+iCountry+'</d5p1:CountryType>  '
                            +'<d5p1:ZipPostalCode>'+iPostalCode+'</d5p1:ZipPostalCode>' 
                            +'<d5p1:Region>'+iState+'</d5p1:Region>'
                            +'</d4p1:CommonObject>'
                            +'<d4p1:BasicFlag>Y</d4p1:BasicFlag>'
                            +'<d4p1:AddressFlag>Y</d4p1:AddressFlag>'
                            +'<d4p1:MiscFlag>Y</d4p1:MiscFlag>'
                            +'<d4p1:ParentFlag>Y</d4p1:ParentFlag>'
                            +'<d4p1:PhoneFlag>Y</d4p1:PhoneFlag>'
                            +'<d4p1:ContactFlag>Y</d4p1:ContactFlag>'
                            +'<d4p1:CrmFlag>Y</d4p1:CrmFlag>'
                            +'<d4p1:CompanyDetailsFlag>Y</d4p1:CompanyDetailsFlag>'
                            +'<d4p1:Region>'+iRegion+'</d4p1:Region>'
                            +'</searchDNBRequestDTO>'
                            +'<ApplicationName>SFDC</ApplicationName>'
                            +'</SearchDnBOrganization>'
                            +'</soapenv:Body>'
                            +'</soapenv:Envelope>';
                            
        }
      
     Httprequest CILreq = new Httprequest();
     CILreq.setMethod('POST');
     CILreq.setHeader('content-type','text/xml;charset=UTF-8');
     CILreq.setHeader('SOAPAction','http://tempuri.org/ICustomerSearchService/SearchDnBOrganization');
     //CILreq.setHeader('Authorization','Basic U2VydmljZUNJTDpNRE1AZDNsbA==');
     CILreq.setHeader('Authorization',System.Label.MDM_Credentials);
     // CILreq.setEndpoint('https://soagw-dmznonprod.ins.dell.com/CIL_1.0/CustomerSearchService/CIL.SearchService.svc/secure');
        // Set header parameters for Production 
         if(Environment.isProduction()) { 
             CILreq.setEndpoint(System.Label.MDM_CIL_Prod_Url);
         // Set header parameters for Sandbox 
         }else{
             CILreq.setEndpoint(System.Label.MDM_CIL_Sandbox_Url);   
         }   
    CILreq.setBody(CILXMLString);
    CILreq.setTimeout(120000);
    system.debug('Request Body: '+ CILreq.getBody());
    
    
     http http = new http();
         try{
         httpresponse CILres;
         //string CILResError;
         Integer totalRun;
        // if(!test.isrunningtest()){   //commented for test class
            for(Integer a = 0; a <= 9; a++){
                CILres = http.send(CILreq);
                
                if(CILres.getstatuscode() == 200){
                    CILresponseBody = CILres.getBody();
                    totalRun = a+1;
                    break;
                }
            }
            iProNDetministic = 'P';
            iCountry = currentDNBCode;
            dunsNameCountryPostal = false;
            CILResError = CILres.getStatus();
            system.debug('response body:' + CILres.getBody());
            system.debug('status: ' + CILres.getStatus());
            system.debug('status_code: '+ CILres.getstatuscode());
        //} 
        
         if(!CILResError.contains('OK') || CILresponseBody.contains('No Record Found') || CILresponseBody.contains('No Data found')){
            if(!CILResError.contains('OK')){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MDM_Connection_Failure);
                ApexPages.addMessage(myMsg);
                showResultTable = false;
                showResultBlock = false;
            }
            if(CILresponseBody.contains('No Record Found') || CILresponseBody.contains('No Data found')){
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MDM_Connection_Failure);
                //ApexPages.addMessage(myMsg);
                oMessage = System.Label.MDM_No_Record_Found;
                //finalList.clear();
                showResultTable = false;
                showResultBlock = true;
            }
         }
         else {
            oMessage = '';
            Dom.Document doc = new Dom.Document();
            doc.load(CILresponseBody);
            System.Debug('ResponseBody##' +CILresponseBody);
            
            Dom.XMLNode rootElement = doc.getRootElement();
            System.Debug('rootElement'+rootElement);
            
            String rootElementName = rootElement.getName();
            System.Debug('rootElementName'+rootElementName);
            
            Dom.XMLNode Body = rootElement.getChildElements()[1];
            String BodyName =  Body.getName();
            System.debug('Body :' +BodyName + Body);
            Dom.XMLNode SearchDnBOrganizationResponse = Body.getChildElements()[0];
            String SearchDnBOrganizationResponseName =  SearchDnBOrganizationResponse.getName();
            System.debug('SearchDnBOrganizationResponseName :' +SearchDnBOrganizationResponseName +' '+SearchDnBOrganizationResponse);
            Dom.XMLNode SearchDnBOrganizationResult = SearchDnBOrganizationResponse.getChildElements()[0];
            String SearchDnBOrganizationResultName =  SearchDnBOrganizationResult.getName();
            System.debug('SearchDnBOrganizationResultName :' +SearchDnBOrganizationResultName +' '+SearchDnBOrganizationResult);
            Dom.XMLNode OrganizationList = SearchDnBOrganizationResult.getChildElements()[1];
            String OrganizationListName =  OrganizationList.getName();
            System.debug('OrganizationListName :' +OrganizationListName +' '+OrganizationList);

            System.debug('OrganizationList.getChildElements()++++' +OrganizationList.getChildElements());

            for(Dom.XMLNode SearchOrganizationResultElement : OrganizationList.getChildElements()){
            System.Debug('Search Org. Result11'+SearchOrgReCount+' '+SearchOrganizationResultElement);
                SearchOrgReList.add(SearchOrganizationResultElement);
                System.Debug('Search Org. Result22'+SearchOrgReCount+' '+SearchOrganizationResultElement);
                SearchOrgReCount++;
                System.Debug('Search Org. Result33'+SearchOrgReCount+' '+SearchOrganizationResultElement);
                finalList = new List<dunsdetails>();
                for (i= 0; i < SearchOrgReCount; i++){
                Dom.XMLNode OrgResultTest = OrganizationList.getChildElements()[i];
                String OrgResultTestName =  OrgResultTest.getName();
                //System.debug('OrgResultTestName :' +OrgResultTestName +' '+OrgResultTest);
         
                // To get Party
                Dom.XMLNode SeacrhChildOrg = OrgResultTest.getChildElements()[0];
                String SearchChildOrgName = SeacrhChildOrg.getName();
                //System.debug('SearchChildOrgName :' +SearchChildOrgName +' '+SeacrhChildOrg);
                Dom.XMLNode PartyChild = SeacrhChildOrg.getChildElements()[0];
                String PartyChildName = PartyChild.getName();
                //System.debug('PartyChild :' +PartyChildName +' '+PartyChild);
                Dom.XMLNode PartyChild1 = PartyChild.getChildElements()[0];
                String PartyChildName1 = PartyChild.getName();
                //System.debug('PartyChild1 :' +PartyChildName1 +' '+PartyChild1);
                Dom.XMLNode OrganizationElement = PartyChild1.getChildElements()[0];
                String OrganizationElementName = OrganizationElement.getName();
               // System.debug('OrganizationElementName :' +OrganizationElementName +' '+OrganizationElement);
                //To get Duns Name
                Dom.XMLNode OrganizationName = OrganizationElement.getChildElements()[0];
                String OrganizationChildtName = OrganizationName.getName();
                //System.debug('OrganizationChildName :' +OrganizationChildtName +' '+OrganizationName);
                Dom.XMLNode OrganizationName1 = OrganizationName.getChildElements()[0];
                Dom.XMLNode OrganizationNameValue = OrganizationName1.getChildElements()[0];
                    oBusinessName = OrganizationNameValue.getText();
                    System.debug('DUNS NAME' + oBusinessName);
                
                // to get OrganizationExtensionElement Duns Name, OOB and EmployeeSize
                Dom.XMLNode OrganizationExtension1 = PartyChild.getChildElements()[0];
                String OrganizationExtensionName1 = OrganizationExtension1.getName();
                //System.debug('OrganizationExtensionName1 :' +OrganizationExtensionName1 +' '+OrganizationExtension1);
                Dom.XMLNode Organizationduns1 = OrganizationExtension1.getChildren()[0];
                String Organizationdunsname = Organizationduns1.getName();
                //system.debug('Organizationdunsname : ' + Organizationdunsname +' '+Organizationduns1);
                Dom.XMLNode Organizationduns2 = Organizationduns1.getChildElements()[1];
                String Organizationdunsname2 = Organizationduns2.getName();
                //system.debug('Organizationdunsname 2: ' + Organizationdunsname2 +' '+Organizationduns2);
                for(Dom.XMLNode OrganizationExtensionChild : Organizationduns2.getChildElements()){
                    OrgExtChilList.add(OrganizationExtensionChild);
                    OrgExtChildCount++;
                    //System.Debug('Extension Child Element1:' +OrgExtChildCount +' ' + OrganizationExtensionChild);
                    //System.Debug('OrgExtChilList' +OrgExtChilList);
                    
                        If(OrganizationExtensionChild.getName() == 'DunsNumber'){
                        oDunsId = OrganizationExtensionChild.getText();
                        //System.Debug('DunsNumber##' +oDunsId);
                        }
                        If(OrganizationExtensionChild.getName() == 'OutOfBusinessIndi'){
                            oOOB = OrganizationExtensionChild.getText();
                            //System.Debug('oOOB' +oOOB);
                        }
                        If(OrganizationExtensionChild.getName() == 'EmployeesTotal'){
                            oEmployeeSize = OrganizationExtensionChild.getText();
                            //system.debug('employeesize: ' +oEmployeeSize );
                        }   
                }
                
                Dom.XMLNode PartyAddressElement = PartyChild.getChildElements()[1];
                String PartyAddressElementName = PartyAddressElement.getName();
                //System.debug('PartyAddressElementName :' +PartyAddressElementName +' '+PartyAddressElement);
                Dom.XMLNode PartyAddressChildElement = PartyAddressElement.getChildElements()[0];
                String PartyAddressChildElementName = PartyAddressChildElement.getName();
                //debug('PartyAddressChildElement :' +PartyAddressChildElementName +' '+PartyAddressChildElement);
                Dom.XMLNode AddressElement = PartyAddressChildElement.getChildElements()[0];
                String AddressElementdName = AddressElement.getName();
                //System.debug('AddressElementdName :' +AddressElementdName +' '+AddressElement);
                Dom.XMLNode AddressChildElement = AddressElement.getChildElements()[0];
                String AddressChildElementName = AddressChildElement.getName();
                //System.debug('AddressChildElement :' +AddressChildElementName +' '+AddressChildElement);
                
                
                for(Dom.XMLNode AddressChild : AddressChildElement.getChildElements()){
                    AddressList.add(AddressChild);
                    AddressNodeCount++;
                    System.Debug('AddressNode##:' +AddressNodeCount +' ' + AddressChild);
                    //system.debug('List of address child node' + AddressList);
                    
                        If(AddressChild.getName() == 'AddressLineOne'){
                            oAddress1 = AddressChild.getText();
                            //System.Debug('Address1' +oAddress1);
                        }
                        If(AddressChild.getName() == 'City'){
                            oCity = AddressChild.getText();
                            //System.Debug('oCity' +oCity);
                        }
                        If(AddressChild.getName() == 'CountryValue'){ 
                            system.debug('checking for countryvalue');
                            //oCountry = AddressChild.getText();
                            oCountyCode = AddressChild.getText();
                            //System.Debug('oCountry' + oCountry);
                        }
                        /*If(AddressChild.getName() == 'CountyCode'){
                            oCountyCode = AddressChild.getText();
                            System.Debug('oCountyCode' +oCountyCode);
                        }*/
                        If(AddressChild.getName() == 'ZipPostalCode'){
                            oPostalCode = AddressChild.getText();
                            //system.debug('zippostalcode' + oPostalCode);
                        }
                         If(AddressChild.getName() == 'Region'){
                            oState = AddressChild.getText();
                            //system.debug('state/region:' +oState);
                        }
                }
            //added by Rap
            oCountry = sfdcCountryMap.get(oCountyCode);   //commented because map was not fetching any values
            //System.debug('this is sfdc country code: ' + oCountyCode);
            //System.debug('this is sfdc map: ' + sfdcCountryMap);
            System.debug('this is sfdc country: ' + oCountry);
            if(searchMethod.contains('Country')){
                if(currentDNBCode == oCountyCode) //added to display only relevant results
                    finalList.add(new dunsdetails(false,oAddress1,oBusinessName,oCity,oCountry,oCountyCode,oDunsId,oOOB,oPostalCode,oState,oEmployeeSize));
            }
            else
                finalList.add(new dunsdetails(false,oAddress1,oBusinessName,oCity,oCountry,oCountyCode,oDunsId,oOOB,oPostalCode,oState,oEmployeeSize));
            
            if(!finalList.isEmpty()){
                showResultTable = true;
                showResultBlock = true;
            }
            else{
                oMessage = System.Label.MDM_No_Record_Found;
                showResultTable = false;
                showResultBlock = true;
            }
            
            System.debug('FINALLIST'+finalList);
               } 
           }
           }
               
            
            }
             catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MDM_Connection_Failure);
            ApexPages.addMessage(myMsg);
            system.debug('get the error' + e.getmessage() + '-' + e.getStackTraceString());
    }
            
   }
   
   /******************************END SEARCH DUNS BY DUNS NAME PARSING************************************/
    
                                                     
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
        
            public dunsdetails(Boolean selected, String Address, String DunsName, String City, String Country, String CountyCode, String DunsId, String OOB, String PostalCode, String State, String EmployeeSize){
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

            

        }
    }
    
/******************************END SEARCH DUNS PARSING************************************/ 

/******************************BEGIN SELECTED DUNS DETAIL************************************/ 
    public pagereference selectedDuns(){
        Integer count = 0;
        
        for(dunsdetails obj: finalList){
        System.debug('obj.selected:'+obj.selected);
            if(obj.selected){
                count++;
                System.debug('SelectedDuns Count:'+count);
            }
        }
        if(count == 1){
            for(dunsdetails obj:finalList){
                if(obj.selected){
                System.debug('FinalList size:'+finalList.size());
                    if(finalList.size()>0){
                    selectedDuns = obj.DunsId;
                    System.debug('SelectedDuns Value:'+selectedDuns);
                    }
               
                }
            }
            
        }
        return null;
        
    }
/******************************END SELECTED DUNS DETAIL************************************/ 

/******************************BEGIN RESET************************************/ 
public pageReference reset()    {
      showResultTable = false;
      showResultBlock = false;
      this.iAffinityId = null;
      this.iDunsId = null;
      this.iCustNum = null; //''
      this.iBUID = null; //''
      this.iDunsName = null;
      this.iCountry = null;
      this.iState = null;
      this.iCity = null;
      this.iPostalCode = null;
      this.iRegion = null;
      checkVal = 'P';
      return null;    
      }  
      
/******************************END RESET************************************/ 
}