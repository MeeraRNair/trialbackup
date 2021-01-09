/***********************************************************
* Name          : MDM_DBAccountDetails 
* Description   : To display the account details from hub
* ---------------------------------------------------------
* Revision      Release     Name        Date            Description
* 1.0           16.03       Nisha       9-12-2014       Developed parsing the response, and displaying the account details on a page.
                                                        
************************************************************/

public class MDM_DBAccountDetails {
    
    public List<dunsdetails> finalList{get;set;}
    public list<dunsdetails2> finalList2{get;set;}
    public list<dunsdetails3> finalList3{get;set;}
    public list<dunsdetails4> finalList4{get;set;}
    public transient List<Dom.XmlNode> subChildElementsList {get;set;}
    public transient List<String> sub2ChildElementsList {get;set;}
    public String oCountyCode{get;set;}
    public String oCity{get;set;}
    public transient List<Dom.XMLNode> oAccountId{get;set;}
    public string oAccId{get;set;}
    public String oAccountName{get;set;}
    public String oAddress1{get;set;}
    public String oCityCode{get;set;}
    public String oContinentCode{get;set;}
    public String oContinentCodeDup{get;set;}
    public String oEmpSize{get;set;}
    public String oDomesticUltimateAddress{get;set;}
    public String oDomesticUltimateDuns{get;set;}
    public String oDomesticUltimateName{get;set;}
    public String oDomesticUltimateTotalEmployees{get;set;}
    public String oEmployeesTotal{get;set;}
    public String oGlobalUltimateAddress{get;set;}
    public String oGlobalUltimateDuns{get;set;}
    public String oGlobalUltimateName{get;set;}
    public String oHierarchyCode{get;set;}
    public String oHqParentAddress{get;set;}
    public String oHQParentDuns{get;set;}
    public String oHQParentName{get;set;}
    public String oPreviousDuns{get;set;}
    public string oSubsidiaryIndicator{get;set;}
    public string oFaxNumber{get;set;}
    public String ostate{get;set;}
    public String oPostalCode{get;set;}
    public string oMailCountryCode{get;set;}
    public String oMailCountryName{get;set;}
    public String oNationalId{get;set;}
    public String oNationalIdSystemCode{get;set;}
    public String oTelephoneNumber{get;set;}
    public String oCEOName{get;set;}
    public String oCEOTitle{get;set;}
    public String oSquareFootage{get;set;}
    public String oCableOrTelex{get;set;}
    public string oDiasCode{get;set;}
    public String oLegalStatus{get;set;}
    public String oOwnsOrRentDetail{get;set;}
    public String oPrimaryLocalActivityCode{get;set;}
    public String oSiteBroadbandDemandScore{get;set;}
    public string oUndeliverableAddressIndicator{get;set;}
    public string oWhiteCollarEstimator{get;set;}
    public string oRecordClassType{get;set;}
    public string oAnnualSales{get;set;}
    public string oAnnualSalesIndicator{get;set;}
    public string oAnnualSalesUSDollar{get;set;}
    public string oBaseYearEmployees{get;set;}
    public string oBaseYearSales{get;set;}
    public string oBlueCollarEstimator{get;set;}
    public string oImportExportCode{get;set;}
    public string oLineOfBusiness{get;set;}
    public string oOOB{get;set;}
    public string oPercentGrowthEmployees{get;set;}
    public string oPercentGrowthSalesSign{get;set;}
    public string oPublicOrprivateIndicator{get;set;}
    public string oDunsId{get;set;}
    public String oBusinessName{get;set;}
    public string oTradestyleName{get;set;}
    public string oEmployeesHere{get;set;}
    public string oEmployeesTotalIndicator{get;set;}
    public string oEmployeesHereIndicator{get;set;}
    public string oFranchiseCode1{get;set;}
    public string oFranchiseCode2{get;set;}
    public string oFranchiseCode3{get;set;}
    public string oFranchiseCode4{get;set;}
    public string oFranchiseCode5{get;set;}
    public string oFranchiseCode6{get;set;}
    public string oFranchiseCodeIndicator{get;set;}
    public string oStatusCode{get;set;}
    public string oUnderminedSICIndicator{get;set;}
    public string oUS_1987_SIC1{get;set;}
    public string oSIC6COde{get;set;}
    public string oUS_1987_SIC2{get;set;}
    public string oUS_1987_SIC3{get;set;}
    public string oUS_1987_SIC4{get;set;}
    public string oUS_1987_SIC5{get;set;}
    public string oUS_1987_SIC6{get;set;}
    public string oTrendyearSales{get;set;}
    public string oTrendyearEmployees{get;set;}
    public string oAddress2{get;set;}
    public string oMailAddress{get;set;}
    public string oMailCityName{get;set;}
    public string oMailStatename{get;set;}
    public string oMailPostalCode{get;set;}
    public string oCountry{get;set;}
    public string oCountrycode{get;set;}
    public string ostatecode{get;set;}
    public string oCountryaccesscode{get;set;}
    public string oFirstExecutiveNameMRC{get;set;}
    public string oSecondExecutiveNameMRC{get;set;}
    public string oThirdExecutiveNameMRC{get;set;}
    public string oFourthExecutiveNameMRC{get;set;}
    public string oFifthExecutiveNameMRC{get;set;}
    public string osixthExecutiveNameMRC{get;set;}
    public string oSeventhExecutiveNameMRC{get;set;}
    public string oEighthExecutiveNameMRC{get;set;}
    public string oFirstExecutiveName{get;set;}
    public string oSecondExecutiveName{get;set;}
    public string oThirdExecutiveName{get;set;}
    public string oFourthExecutiveName{get;set;}
    public string oFifthExecutiveName{get;set;}
    public string oSixthExecutiveName{get;set;}
    public string oSeventhExecutiveName{get;set;}
    public string oEighthExecutiveName{get;set;}
    public string oYearStarted{get;set;}
    public string ocottagefileindicator{get;set;}
    public string omarketingfiledelistindicator{get;set;}
    public string oMSA{get;set;}
    public string ofiller1{get;set;}
    public string ofiller2{get;set;}
    public string ofiller3{get;set;}
    public string oMarketableNonMarketable{get;set;}
    public string oNumberofPcs{get;set;}
    public string oaggregatednumberofpcsultimate{get;set;}
    public string onumberofaccounts{get;set;}
    public string onumberoffamilymembersglobal{get;set;}
    public string oterritorycovered{get;set;}
    public string oFirstExecutiveTitle{get;set;}
    public string oSecondExecutiveTitle{get;set;}
    public string oThirdExecutiveTitle{get;set;}
    public string oFourthExecutiveTitle{get;set;}
    public string oFifthExecutiveTitle{get;set;}
    public string osixthExecutiveTitle{get;set;}
    public string oSeventhExecutiveTitle{get;set;}
    public string oEighthExecutiveTitle{get;set;}
    public Map<string,string> accountdetailsmap{get;set;}
    public list<string> accountdetaillist{get;set;}
    public list<string> string2{get;set;}
    public account newaccount{get;set;}
    public string aid{get;set;}
    public string affiid{get;set;}
    public string accname{get;set;}
    public string accowner{get;set;}
    public string owneremail{get;set;}
    public list<string> oaffinityidlist{get;set;}
    String allNode;
    public string body;
    public string output;
    Account acct;
    public string dunsnumber{get;set;}
    public List<dunsdetails5> finalList5{get;set;}
    public string oemployeestotalhere{get;set;}
    public string otopexecutivecontacts{get;set;}
    public string oemployeestotalherecode{get;set;}
    public string oFranchisecodes{get;set;}
    public string osiccodessecondary{get;set;}
    public string otrendyearemployeesales{get;set;}
    public string oexecutivecontactmrccode{get;set;}
    public string oexecutivecontacttitle{get;set;}
    public string oreportdate{get;set;}
    public string obaseyearemployeessales{get;set;}
    public Boolean showResultTable{get;set;}
    public String errorMsg{get;set;}
    public String oMessage{get;set;}
        
    public string charSupport {
        get {
            return EncodingUtil.base64decode('77u/').tostring();
        }
    }
        
    
    public MDM_DBAccountDetails (ApexPages.StandardController stdController){ 
        acct = (Account)stdController.getRecord();
        finalList2 = new list<dunsdetails2>();
        finalList3 = new list<dunsdetails3>();
        finalList4 = new list<dunsdetails4>();
        finalList5 = new list<dunsdetails5>();
        aid = apexpages.currentpage().getparameters().get('id');
        affiid = apexpages.currentpage().getparameters().get('affinityid');
        accname = apexpages.currentpage().getparameters().get('name');
        accowner = apexpages.currentpage().getparameters().get('owner');
        owneremail = apexpages.currentpage().getparameters().get('owneremail');
        oaffinityidlist = new list<string>();
        oexecutivecontactmrccode = '';
        dunsnumber = apexpages.currentpage().getparameters().get('dunsnumber');
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');
    }
    
    public Boolean displaypopup{get;set;}

    public PageReference showpopup() {
        body = accountdetailsbody(dunsnumber);   
        try{
            output = sendingrequest(body);
            output = output.trim().replaceFirst('^([\\W]+)<','<');
            searchDuns(output);
        }catch (Exception e){
           system.debug('displaying error message' + e.getmessage());
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');
          return null;
    }
    public string sendingrequest(string body1 ){
        output = sendrequest(body1);  
        return output;
    }

    //constructing the request body
    public string accountdetailsbody( string dn){
        body = '';
        body = '<?xml version="1.0"?>'+
            '<s:Envelope xmlns:a="http://www.w3.org/2005/08/addressing" xmlns:s="http://www.w3.org/2003/05/soap-envelope">'+
            '<s:Header>'+
            '<a:Action s:mustUnderstand="1">CIL/IExploreAffinity/SearchDuns</a:Action>'+
            '<a:MessageID>'+System.Label.MDM_MessageID+'</a:MessageID>'+
            '<a:ReplyTo>'+
            '<a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>'+
            '</a:ReplyTo>'+
            '<a:To s:mustUnderstand="1">'+System.Label.MDM_SITURL+'</a:To>'+
            '</s:Header>'+
            '<s:Body>'+
            '<SearchDuns xmlns="CIL">'+
            '<request xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Duns.Request" i:type="b:CustomerMDMDunsSearchRequestBObj">'+
            '<b:DunsBObj>'+
            '<b:Account>Yes</b:Account><b:Address>Yes</b:Address><b:CRM>Yes</b:CRM><b:CompanyDetail>Yes</b:CompanyDetail><b:Contact>Yes</b:Contact><b:DunsId xmlns:c="http://schemas.microsoft.com/2003/10/Serialization/Arrays">'+
            '<c:long>'+dunsnumber+'</c:long>'+
            '</b:DunsId><b:Misc>Yes</b:Misc><b:Parent>Yes</b:Parent><b:Phone>Yes</b:Phone><b:Primary>Yes</b:Primary>'+
            '</b:DunsBObj>'+
            '</request>'+
            '</SearchDuns>'+
            '</s:Body>'+
            '</s:Envelope>';
        return body;
    }

    //constructing the request header
    public string sendrequest( string body2){  
        string xmloutput;
        httprequest req = new httprequest();
        req.setMethod('POST');
        req.setHeader('content-type','text/xml;charset=UTF-8');
        req.setHeader('SOAPAction','');
        //req.setHeader('Authorization','Basic QWZmaW5pdHlTZWFyY2g6TURNQGQzbGw=');
        req.setHeader('Authorization',System.Label.MDM_Credentials);
        if(Environment.isProduction()) { 
                 req.setEndpoint(System.Label.MDM_Prod_Url);
        }else{
                 req.setEndpoint(System.Label.MDM_Sandbox_Url); 
        }
        req.setBody(body2);
        http http = new http();
        try{
            httpresponse res;
            if(!test.isrunningtest()){
                res = http.send(req);
                xmloutput = res.getBody();
        } 
        }catch(Exception e){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
             System.Label.MDM_Connection_Failure);
             ApexPages.addMessage(myMsg);
             showResultTable = false;
        }
        return xmloutput;
    }
    
    //functionality for export
    public PageReference export(){
        PageReference p = new PageReference('/apex/MDM_ExportAccountDetailsTest');
        return p;
    }
    
    //parsing the xml response
    public void searchDuns(string responsebody) {
        showResultTable = true;
        Integer i;
        Integer lastcount = 0;
        List<Dom.XmlNode> childlist = new List<Dom.XmlNode>();
        String subChildElementName;
        subChildElementsList = new List<Dom.XmlNode>();
        sub2ChildElementsList = new list<String>();
        string sub2ChildElementsName;

        Integer childElementCount =0;
        Integer subChildElementsCount = 0;
        Integer sub2ChildElementsCount = 0;
        Dom.Document doc = new Dom.Document();
        doc.load(responseBody);
        Dom.XMLNode rootElement = doc.getRootElement();
        String rootElementName = rootElement.getName();
        Dom.XMLNode Body = rootElement.getChildElements()[1];
        String BodyName =  Body.getName();
        Dom.XMLNode HierarchyResponse = Body.getChildElements()[0];
        String HierarchyResponseName =  HierarchyResponse.getName();
        Dom.XMLNode HierarchyResult = HierarchyResponse.getChildElements()[0];
        String HierarchyResultName =  HierarchyResult.getName();
        Dom.XMLNode CommonSearchResponse = HierarchyResult.getChildElements()[0];
        String CommonSearchResponseName =  CommonSearchResponse.getName();
        for(Dom.XMLNode childelement : CommonSearchResponse.getChildElements())
        {
            childlist.add(childelement);
            childElementCount++;
            finalList = new List<dunsdetails>();
            If(childelement.getName() == 'Message'){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                System.Label.MDM_No_Record_Found);
                showResultTable = false;
                ApexPages.addMessage(myMsg);
            }
        }
        for (i= 0; i < childElementCount; i++){
            for(Dom.XMLNode subChildElement: childlist[i].getChildElements())
            {
                subChildElementName = subChildElement.getName();
                subChildElementsList.add(subChildElement);
                subChildElementsCount++;
            }
        }
        for(i=0; i<subChildElementsCount; i++)
        {
            for(Dom.XMLNode sub2childElement: subChildElementsList[i].getChildElements())
            {
                sub2ChildElementsName = sub2childElement.getName();
                sub2ChildElementsList.add(sub2ChildElementsName);
                sub2ChildElementsCount++;
                If(sub2childElement.getName() == 'DunsAccountExtObj')
                { 
                    for(Dom.XMLNode AccountChild: sub2childElement.getChildElements())
                    {
                        if(AccountChild.getName() == 'AccountId'){
                            oAccId = AccountChild.getText();
                        }
                    }
                    oaffinityidlist.add(oAccId);
                }
                
                If(sub2childElement.getName() == 'Address1'){
                    oAddress1 = sub2childElement.getText();
                }
                If(sub2childElement.getName() == 'CountyCode'){
                    oCountyCode = sub2childElement.getText();
                }
                If(sub2childElement.getName() == 'City'){
                    oCity = sub2childElement.getText();
                }
                 If(sub2childElement.getName() == 'CityCode'){
                    oCityCode = sub2childElement.getText();
                }                   
                If(sub2childElement.getName() == 'ContinentCode'){
                    oContinentCode = sub2childElement.getText();
                }
                 If(sub2childElement.getName() == 'ContinentCodeDup'){
                    oContinentCodeDup = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'DomesticUltimateAddress'){
                    oDomesticUltimateAddress = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'DomesticUltimateDuns'){
                    oDomesticUltimateDuns = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'DomesticUltimateName'){
                    oDomesticUltimateName = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'DomesticUltimateTotalEmployees'){
                    oDomesticUltimateTotalEmployees = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'EmployeeSize'){
                    oEmployeesTotal = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'GlobalUltimateAddress'){
                    oGlobalUltimateAddress = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'GlobalUltimateDuns'){
                    oGlobalUltimateDuns = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'GlobalUltimateName'){
                    oGlobalUltimateName = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'HierarchyCode'){
                    oHierarchyCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'HqParentAddress'){
                    oHqParentAddress = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'HQParentDuns'){
                    oHQParentDuns = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'HQParentName'){
                    oHQParentName = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'PreviousDuns'){
                    oPreviousDuns = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'SubsidiaryIndicator'){
                    oSubsidiaryIndicator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'FaxNumber'){
                    oFaxNumber = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'state'){
                    ostate = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'PostalCode'){
                    oPostalCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'MailCountryCode'){
                    oMailCountryCode = sub2childElement.getTExt();
                }
                if(sub2childElement.getName() == 'MailCountryName'){
                    oMailCountryName = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'NationalId'){
                    oNationalId = sub2childElement.getTExt();
                }
                if(sub2childElement.getName() == 'NationalIdSystemCode'){
                    oNationalIdSystemCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'TelephoneNumber'){
                    oTelephoneNumber = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'CEOName'){
                    oCEOName = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'CEOTitle'){
                    oCEOTitle = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'SquareFootage'){
                    oSquareFootage = sub2childElement.getTExt();
                }
                if(sub2childElement.getName() == 'CableOrTelex'){
                    oCableOrTelex = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'DiasCode'){
                    oDiasCode = sub2childElement.getTExt();
                }
                if(sub2childElement.getName() == 'LegalStatus'){
                    oLegalStatus = sub2childElement.getTExt();
                }
                if(sub2childElement.getName() == 'OwnsOrRentDetail'){
                    oOwnsOrRentDetail = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'PrimaryLocalActivityCode'){
                    oPrimaryLocalActivityCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'SiteBroadbandDemandScore'){
                    oSiteBroadbandDemandScore = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'UndeliverableAddressIndicator'){
                    oUndeliverableAddressIndicator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'WhiteCollarEstimator'){
                    oWhiteCollarEstimator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'RecordClassType'){
                    oRecordClassType = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'AnnualSales'){
                    oAnnualSales = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'AnnualSalesIndicator'){
                    oAnnualSalesIndicator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'AnnualSalesUSDollar'){
                    oAnnualSalesUSDollar = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'BaseYearEmployees'){
                    oBaseYearEmployees = sub2childElement.getText();
                    if(oBaseYearEmployees != null || oBaseYearEmployees != '0'){
                        obaseyearemployeessales = oBaseYearEmployees;
                     }
                }
                if(sub2childElement.getName() == 'BaseYearSales'){
                    oBaseYearSales = sub2childElement.getText();
                    if(oBaseYearSales != null || oBaseYearSales != '0'){
                        if(obaseyearemployeessales != null)
                            obaseyearemployeessales = obaseyearemployeessales + ';' + oBaseYearSales;
                        else
                            obaseyearemployeessales = oBaseYearSales;
                    }
                }
                if(sub2childElement.getName() == 'BlueCollarEstimator'){
                    oBlueCollarEstimator = sub2childElement.getTExt();
                }
                if(sub2childElement.getName() == 'ImportExportCode'){
                    oImportExportCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'LineOfBusiness'){
                    oLineOfBusiness = sub2childElement.getTExt();
                }
                if(sub2childElement.getName() == 'OOB'){
                    oOOB = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'PercentGrowthEmployees'){
                    oPercentGrowthEmployees = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'PercentGrowthSalesSign'){
                    oPercentGrowthSalesSign = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'PublicOrprivateIndicator'){
                    oPublicOrprivateIndicator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'DunsId'){
                    oDunsId = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'BusinessName'){
                    oBusinessName = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'TradestyleName'){
                    oTradeSTyleName = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'EmployeesHere'){
                    oEmployeesHere = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'EmployeesTotalIndicator'){
                    oEmployeesTotalIndicator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'EmployeesHereIndicator'){
                    oEmployeesHereIndicator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'FranchiseFileCode1'){
                    oFranchiseCode1 = sub2childElement.getText();
                    if(oFranchiseCode1 != null && oFranchiseCode1 != ''){
                        oFranchisecodes = oFranchiseCode1;
                    }
                }
                if(sub2childElement.getName() == 'FranchiseFileCode2'){
                    oFranchiseCode2 = sub2childElement.getText();
                    if(oFranchiseCode2 != null && oFranchiseCode2 != ''){
                        if(oFranchisecodes != null)
                            oFranchisecodes = oFranchisecodes + ';' + oFranchiseCode2;
                        else 
                            oFranchisecodes = oFranchiseCode2;
                    } 
                }
                if(sub2childElement.getName() == 'FranchiseFileCode3'){
                    oFranchiseCode3 = sub2childElement.getText();
                    if(oFranchiseCode3 != null && oFranchiseCode3 != ''){
                        if(oFranchisecodes != null)
                            oFranchisecodes = oFranchisecodes + ';' + oFranchiseCode3 ;
                        else 
                            oFranchisecodes = oFranchiseCode3 ;
                    } 
                }
                if(sub2childElement.getName() == 'FranchiseFileCode4'){
                    oFranchiseCode4 = sub2childElement.getText();
                    if(oFranchiseCode4 != null && oFranchiseCode4 != ''){
                        if(oFranchisecodes != null)
                            oFranchisecodes = oFranchisecodes + ';' + oFranchiseCode4 ;
                        else
                            oFranchisecodes = oFranchiseCode4 ;
                    } 
                }
                if(sub2childElement.getName() == 'FranchiseFileCode5'){
                    oFranchiseCode5 = sub2childElement.getText();
                    if(oFranchiseCode5 != null && oFranchiseCode5 != ''){
                        if(oFranchisecodes != null)
                            oFranchisecodes = oFranchisecodes + ';' + oFranchiseCode5 ;
                        else
                            oFranchisecodes = oFranchiseCode5 ;
                    } 
                }
                if(sub2childElement.getName() == 'FranchiseFileCode6' ){
                    oFranchiseCode6 = sub2childElement.getText();
                    if(oFranchiseCode6 != null && oFranchiseCode6 != '' ){
                        if(oFranchisecodes != null)
                            oFranchisecodes = oFranchisecodes + ';' + oFranchiseCode6 ;
                        else
                            oFranchisecodes = oFranchiseCode6 ;
                    } 
                }
                if(sub2childElement.getName() == 'FranchiseCodeIndicator'){
                    oFranchiseCodeIndicator = sub2childElement.getText();
                    if(oFranchiseCodeIndicator != null && oFranchiseCodeIndicator != ''){
                        if(oFranchisecodes != null)
                            oFranchisecodes = oFranchisecodes + ';' + oFranchiseCodeIndicator ;
                        else 
                            oFranchisecodes = oFranchiseCodeIndicator ;
                    } 
                }
                if(sub2childElement.getName() == 'StatusCode'){
                    oStatusCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'UndeterminedSICIndicator'){
                    oUnderminedSICIndicator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'US_1987_SIC1'){
                    oUS_1987_SIC1 = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'SIC6Code'){
                    oSIC6Code = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'US_1987_SIC2'){
                    oUS_1987_SIC2 = sub2childElement.getText();
                    if(oUS_1987_SIC2 != null && oUS_1987_SIC2 != ''){
                        osiccodessecondary = oUS_1987_SIC2;
                    }
                }
                if(sub2childElement.getName() == 'US_1987_SIC3'){
                    oUS_1987_SIC3 = sub2childElement.getText();
                    if(oUS_1987_SIC3  != null && oUS_1987_SIC3 != ''){
                        if(osiccodessecondary != null)
                            osiccodessecondary = osiccodessecondary + ';' + oUS_1987_SIC3;
                        else 
                            osiccodessecondary = oUS_1987_SIC3;
                    }
                }
                if(sub2childElement.getName() == 'US_1987_SIC4'){
                    oUS_1987_SIC4 = sub2childElement.getText();
                    if(oUS_1987_SIC4 != null && oUS_1987_SIC4 != ''){
                        if(osiccodessecondary != null)
                            osiccodessecondary = osiccodessecondary + ';' + oUS_1987_SIC4;
                        else
                            osiccodessecondary = oUS_1987_SIC4;
                    }
                }
                if(sub2childElement.getName() == 'US_1987_SIC5'){
                    oUS_1987_SIC5 = sub2childElement.getText();
                    if(oUS_1987_SIC5 != null && oUS_1987_SIC5 != ''){
                        if(osiccodessecondary != null)
                            osiccodessecondary = osiccodessecondary + ';' + oUS_1987_SIC5;
                        else 
                            osiccodessecondary = oUS_1987_SIC5;
                    }
                }
                if(sub2childElement.getName() == 'US_1987_SIC6'){
                    oUS_1987_SIC6 = sub2childElement.getText();
                    if(oUS_1987_SIC6 != null && oUS_1987_SIC6 != ''){
                        if(osiccodessecondary != null)
                            osiccodessecondary = osiccodessecondary + ';' + oUS_1987_SIC6;
                        else 
                            osiccodessecondary = oUS_1987_SIC6;
                    }
                }
                if(sub2childElement.getName() == 'trendyearsales'){
                    otrendyearsales = sub2childElement.getText();
                    otrendyearemployeesales = otrendyearsales;
                }
                if(sub2childElement.getName() == 'trendyearemployees'){
                    otrendyearemployees = sub2childElement.getText();
                    if(otrendyearemployees != null && otrendyearemployees != ''){
                        if(otrendyearemployeesales != null)
                            otrendyearemployeesales = otrendyearemployeesales + ';' + otrendyearemployees;
                        else 
                            otrendyearemployeesales = otrendyearemployees;
                    }
                }
                if(sub2childElement.getName() == 'Address2'){
                    oAddress2 = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'MailAddress'){
                    oMailAddress = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'MailCityName'){
                    oMailCityName = sub2childElement.getText();
                }

                if(sub2childElement.getName() == 'MailStateName'){
                    oMailStateName = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'MailAddressPostalCode'){
                    oMailPostalCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'Country'){
                    oCountry = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'CountryCode'){
                    oCountryCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'stateCode'){
                    ostateCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'countryaccessCode'){
                    ocountryaccessCode = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'FirstExecutiveNameMRC'){
                    oFirstExecutiveNameMRC = sub2childElement.getText();
                    
                }
                if(sub2childElement.getName() == 'SecondExecutiveNameMRC'){
                    oSecondExecutiveNameMRC = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'ThirdExecutiveNameMRC'){
                    oThirdExecutiveNameMRC = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'FourthExecutiveNameMRC'){
                    oFourthExecutiveNameMRC = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'FifthExecutiveNameMRC'){
                    oFifthExecutiveNameMRC = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'SixthExecutiveNameMRC'){
                    oSixthExecutiveNameMRC = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'SeventhExecutiveNameMRC'){
                    oSeventhExecutiveNameMRC = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'EighthExecutiveNameMRC'){
                    oEighthExecutiveNameMRC = sub2childElement.getText();
                }
                    
                if(sub2childElement.getName() == 'FirstExecutiveName'){
                    oFirstExecutiveName = sub2childElement.getText();
                    otopexecutivecontacts = oFirstExecutiveName;
                }
                if(sub2childElement.getName() == 'SecondExecutiveName'){
                    oSecondExecutiveName = sub2childElement.getText();
                    if(oSecondExecutiveName != null && oSecondExecutiveName != ''){
                        if(otopexecutivecontacts != null)
                            otopexecutivecontacts = otopexecutivecontacts + ';' + oSecondExecutiveName;
                        else 
                            otopexecutivecontacts = oSecondExecutiveName;
                    }
                }
                if(sub2childElement.getName() == 'ThirdExecutiveName'){
                    oThirdExecutiveName = sub2childElement.getText();
                    if(oThirdExecutiveName != null && oThirdExecutiveName != ''){
                        if(otopexecutivecontacts != null)
                            otopexecutivecontacts = otopexecutivecontacts + ';' + oThirdExecutiveName ;
                        else 
                            otopexecutivecontacts = oThirdExecutiveName ;
                    }
                }
                if(sub2childElement.getName() == 'FourthExecutiveName'){
                    oFourthExecutiveName = sub2childElement.getText();
                    if(oFourthExecutiveName != null && oFourthExecutiveName != ''){
                        if(otopexecutivecontacts != null)
                            otopexecutivecontacts = otopexecutivecontacts + ';' + oFourthExecutiveName ;
                        else 
                            otopexecutivecontacts = oFourthExecutiveName ;
                    }
                }
                if(sub2childElement.getName() == 'FifthExecutiveName'){
                    oFifthExecutiveName = sub2childElement.getText();
                    if(oFifthExecutiveName != null && oFifthExecutiveName != ''){
                        if(otopexecutivecontacts != null)
                            otopexecutivecontacts = otopexecutivecontacts + ';' + oFifthExecutiveName ;
                        else 
                            otopexecutivecontacts = oFifthExecutiveName ;
                    }
                }
                if(sub2childElement.getName() == 'SixthExecutiveName'){
                    oSixthExecutiveName = sub2childElement.getText();
                    if(oSixthExecutiveName != null && oSixthExecutiveName != ''){
                        if(otopexecutivecontacts != null)
                            otopexecutivecontacts = otopexecutivecontacts + ';' + oSixthExecutiveName ;
                        else
                            otopexecutivecontacts = oSixthExecutiveName ;
                    }
                }
                if(sub2childElement.getName() == 'SeventhExecutiveName'){
                    oSeventhExecutiveName = sub2childElement.getText();
                    if(oSeventhExecutiveName != null && oSeventhExecutiveName != ''){
                        if(otopexecutivecontacts != null)
                            otopexecutivecontacts = otopexecutivecontacts + ';' + oSeventhExecutiveName ;
                        else
                            otopexecutivecontacts = oSeventhExecutiveName ;
                    }
                }
                if(sub2childElement.getName() == 'EighthExecutiveName'){
                    oEighthExecutiveName = sub2childElement.getText();
                    if(oEighthExecutiveName != null && oEighthExecutiveName != ''){
                        if(otopexecutivecontacts != null)
                            otopexecutivecontacts = otopexecutivecontacts + ';' + oEighthExecutiveName ;
                        else 
                            otopexecutivecontacts = oEighthExecutiveName ;
                    }
                }
                if(sub2childElement.getName() == 'YearStarted'){
                    oyearstarted = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'cottagefileindicator'){
                    ocottagefileindicator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'marketingfiledelistindicator'){
                    omarketingfiledelistindicator = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'filler1'){
                    ofiller1 = sub2childElement.getText();
                    if(ofiller1 != null && ofiller1 != ''){
                        oreportdate = ofiller1;
                    }
                }
                if(sub2childElement.getName() == 'filler2'){
                    ofiller2 = sub2childElement.getText();
                    if(ofiller2 != null && ofiller2 != ''){
                        if(oreportdate != null)
                            oreportdate = oreportdate + ';' + ofiller2;
                        else
                            oreportdate = ofiller2;
                    }
                }
                if(sub2childElement.getName() == 'filler3'){
                    ofiller3 = sub2childElement.getText();
                    if(ofiller3 != null && ofiller3 != ''){
                        if(oreportdate != null)
                            oreportdate = oreportdate + ';' + ofiller3;
                        else
                            oreportdate = ofiller3;
                    }
                }
                if(sub2childElement.getName() == 'MSA'){
                    oMSA = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'MarketableOrNonMarketable'){
                    oMarketableNonMarketable = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'NumberofPcs'){
                    oNumberofPcs = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'aggregatednumberofpcsultimate'){
                    oaggregatednumberofpcsultimate = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'numberofaccounts'){
                    onumberofaccounts = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'NoOfFamilyMembersGlobal'){
                    onumberoffamilymembersglobal = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'territorycoverage'){
                    oterritorycovered = sub2childElement.getText();
                }
                if(sub2childElement.getName() == 'FirstExecutiveTitle'){
                    oFirstExecutiveTitle = sub2childElement.getText();
                    oexecutivecontacttitle = oFirstExecutiveTitle;
                }
                if(sub2childElement.getName() == 'SecondExecutiveTitle'){
                    oSecondExecutiveTitle = sub2childElement.getText();
                    if(oSecondExecutiveTitle != null && oSecondExecutiveTitle != ''){
                        if(oexecutivecontacttitle != null)
                            oexecutivecontacttitle = oexecutivecontacttitle + ';' + oSecondExecutiveTitle;
                        else
                            oexecutivecontacttitle = oSecondExecutiveTitle;
                    }
                }
                if(sub2childElement.getName() == 'ThirdExecutiveTitle'){
                    oThirdExecutiveTitle = sub2childElement.getText();
                    if(oThirdExecutiveTitle != null && oThirdExecutiveTitle != ''){
                        if(oexecutivecontacttitle != null)
                            oexecutivecontacttitle = oexecutivecontacttitle + ';' + oThirdExecutiveTitle ;
                        else 
                            oexecutivecontacttitle = oThirdExecutiveTitle ;
                    }
                }
                if(sub2childElement.getName() == 'FourthExecutiveTitle'){
                    oFourthExecutiveTitle = sub2childElement.getText();
                    if(oFourthExecutiveTitle != null && oFourthExecutiveTitle != ''){
                        if(oexecutivecontacttitle != null)
                            oexecutivecontacttitle = oexecutivecontacttitle + ';' + oFourthExecutiveTitle ;
                        else 
                            oexecutivecontacttitle = oFourthExecutiveTitle ;
                    }
                }
                if(sub2childElement.getName() == 'FifthExecutiveTitle'){
                    oFifthExecutiveTitle = sub2childElement.getText();
                    if(oFifthExecutiveTitle != null && oFifthExecutiveTitle != ''){
                        if(oexecutivecontacttitle != null)
                            oexecutivecontacttitle = oexecutivecontacttitle + ';' + oFifthExecutiveTitle ;
                        else 
                            oexecutivecontacttitle = oFifthExecutiveTitle ;
                    }
                }
                if(sub2childElement.getName() == 'SixthExecutiveTitle'){
                    oSixthExecutiveTitle = sub2childElement.getText();
                    if(oSixthExecutiveTitle != null && oSixthExecutiveTitle != ''){
                        if(oexecutivecontacttitle != null)
                            oexecutivecontacttitle = oexecutivecontacttitle + ';' + oSixthExecutiveTitle ;
                        else 
                            oexecutivecontacttitle = oSixthExecutiveTitle ;
                    }
                }
                if(sub2childElement.getName() == 'SeventhExecutiveTitle'){
                    oSeventhExecutiveTitle = sub2childElement.getText();
                    if(oSeventhExecutiveTitle != null && oSeventhExecutiveTitle != ''){
                        if(oexecutivecontacttitle != null)
                            oexecutivecontacttitle = oexecutivecontacttitle + ';' + oSeventhExecutiveTitle ;
                        else 
                            oexecutivecontacttitle = oexecutivecontacttitle + ';' + oSeventhExecutiveTitle ;
                    }
                }
                if(sub2childElement.getName() == 'EighthExecutiveTitle'){
                    oEighthExecutiveTitle = sub2childElement.getText();
                    if(oEighthExecutiveTitle != null && oEighthExecutiveTitle != ''){
                        if(oexecutivecontacttitle != null)
                            oexecutivecontacttitle = oexecutivecontacttitle + ';' + oEighthExecutiveTitle ;
                        else 
                            oexecutivecontacttitle = oEighthExecutiveTitle ;
                    }
                }
            }
        }
        if(oFirstExecutiveNameMRC != null && oFirstExecutiveNameMRC != '' && oFirstExecutiveNameMRC != '0'){
            oexecutivecontactmrccode = oFirstExecutiveNameMRC ;
        }
        if(oSecondExecutiveNameMRC != '' ){
            if(oexecutivecontactmrccode != null)
                oexecutivecontactmrccode = oexecutivecontactmrccode + ';' + oSecondExecutiveNameMRC;
            else 
                oexecutivecontactmrccode = oSecondExecutiveNameMRC;
        }
        if(oThirdExecutiveNameMRC != null  && oThirdExecutiveNameMRC != '' && oThirdExecutiveNameMRC != '0'){
            if(oexecutivecontactmrccode != null)
                oexecutivecontactmrccode = oexecutivecontactmrccode + ';' + oThirdExecutiveNameMRC ;
            else 
                oexecutivecontactmrccode = oThirdExecutiveNameMRC ;
        }
        if(oFourthExecutiveNameMRC != null && oFourthExecutiveNameMRC != '' && oFourthExecutiveNameMRC != '0'){
            if(oexecutivecontactmrccode != null)
                oexecutivecontactmrccode = oexecutivecontactmrccode + ';' + oFourthExecutiveNameMRC ;
            else 
                oexecutivecontactmrccode = oFourthExecutiveNameMRC ;
        }
        if(oFifthExecutiveNameMRC != null && oFifthExecutiveNameMRC != '' && oFifthExecutiveNameMRC != '0'){
            if(oexecutivecontactmrccode != null)
                oexecutivecontactmrccode = oexecutivecontactmrccode + ';' + oFifthExecutiveNameMRC ;
            else 
                oexecutivecontactmrccode = oFifthExecutiveNameMRC ;
        }
        if(oSixthExecutiveNameMRC != null && oSixthExecutiveNameMRC != '' && oSixthExecutiveNameMRC != '0'){
            if(oexecutivecontactmrccode != null)
                oexecutivecontactmrccode = oexecutivecontactmrccode + ';' + oSixthExecutiveNameMRC ;
            else
                oexecutivecontactmrccode = oSixthExecutiveNameMRC ;
        }
        if(oSeventhExecutiveNameMRC != null && oSeventhExecutiveNameMRC != '' && oSeventhExecutiveNameMRC != '0'){
            if(oexecutivecontactmrccode != null)
                oexecutivecontactmrccode = oexecutivecontactmrccode + ';' + oSeventhExecutiveNameMRC ;
            else 
                oexecutivecontactmrccode = oSeventhExecutiveNameMRC ;
        }
        if(oEighthExecutiveNameMRC != null && oEighthExecutiveNameMRC != '' && oEighthExecutiveNameMRC != '0'){
            if(oexecutivecontactmrccode != null)
                oexecutivecontactmrccode = oexecutivecontactmrccode + ';' + oEighthExecutiveNameMRC ;
            else 
                oexecutivecontactmrccode = oEighthExecutiveNameMRC ;
        }
        if(oEmployeesTotal != null  && oEmployeesTotal != '' && oEmployeesTotal != '0'){
                oemployeestotalhere = oEmployeesTotal;
        }
        if(oEmployeesHere != null && oEmployeesHere != '' && oEmployeesHere != '0'){
            if(oemployeestotalhere != null)
                oemployeestotalhere = oemployeestotalhere + ';' + oEmployeesHere;
            else 
                oemployeestotalhere = oEmployeesHere;
        }
        if(oEmployeesTotalIndicator != null && oEmployeesTotalIndicator != '' && oEmployeesTotalIndicator != '0'){
               oemployeestotalherecode = oEmployeesTotalIndicator;
        }
        if(oEmployeesHereIndicator != null && oEmployeesHereIndicator != '' && oEmployeesHereIndicator != '0'){
            if(oemployeestotalherecode != null)
                oemployeestotalherecode = oemployeestotalherecode  + ';' + oEmployeesHereIndicator ;
            else
                oemployeestotalherecode = oEmployeesHereIndicator ;
        }
                
        finalList.add(new dunsdetails(oAddress2,oMailAddress, ostatecode,oUnderminedSICIndicator ,oEmployeesHere, oAddress1,oCountry,oCountyCode,oCity,oCityCode,oContinentCode,oContinentCodeDup,oDomesticUltimateDuns,oDomesticUltimateName,oDomesticUltimateTotalEmployees,oEmployeesTotal,oGlobalUltimateAddress,oGlobalUltimateDuns,oGlobalUltimateName,oHierarchyCode,oHqParentAddress,oHQParentDuns,oHQParentName,oPreviousDuns,oSubsidiaryIndicator,oFaxNumber,ostate,oPostalCode,oNationalId,oNationalIdSystemCode,oTelephoneNumber,oCEOName));
        finalList2.add(new dunsdetails2( oEmployeesHereIndicator, oEmployeesTotalIndicator, oDomesticUltimateAddress, oTradeStyleName, oBusinessName, oDunsId, oCEOTitle,oSquareFootage,oCableOrTelex,oDiasCode,oLegalStatus,oOwnsOrRentDetail,oPrimaryLocalActivityCode,oSiteBroadbandDemandScore,oUndeliverableAddressIndicator,oWhiteCollarEstimator,oRecordClassType,oAnnualSales,oAnnualSalesIndicator,oAnnualSalesUSDollar,oBaseYearEmployees,oBaseYearSales,oBlueCollarEstimator,oImportExportCode,oLineOfBusiness,oOOB,oPercentGrowthEmployees,oPercentGrowthSalesSign,oPublicOrprivateIndicator));
        finalList3.add(new dunsdetails3(oMailCountryCode,oMailCountryName,oFranchiseCodeIndicator, oEighthExecutiveNameMRC ,oSeventhExecutiveNameMRC , oSixthExecutiveNameMRC , oFirstExecutiveNameMRC, oSecondExecutiveNameMRC , oThirdExecutiveNameMRC ,oFourthExecutiveNameMRC ,oFifthExecutiveNameMRC , ocountryaccessCode, oCountryCode, oMailCityName, oMailStateName , oMailPostalCode, otrendyearsales , otrendyearemployees ,oUS_1987_SIC1 ,oSIC6Code ,oUS_1987_SIC2, oUS_1987_SIC3, oUS_1987_SIC4, oUS_1987_SIC5,oUS_1987_SIC6, oStatusCode , oFranchiseCode1 , oFranchiseCode2 , oFranchiseCode3 ,oFranchiseCode4 ,oFranchiseCode5 ,oFranchiseCode6));   
        finalList4.add(new dunsdetails4 (oAccId, oaffinityidlist, oEighthExecutiveTitle ,oSeventhExecutiveTitle ,oSixthExecutiveTitle, oFifthExecutiveTitle ,oFourthExecutiveTitle ,oThirdExecutiveTitle ,oSecondExecutiveTitle , oFirstExecutiveTitle , oterritorycovered, onumberoffamilymembersglobal, onumberofaccounts,oaggregatednumberofpcsultimate, oNumberofPcs, oMarketableNonMarketable, ofiller1, ofiller2, ofiller3,oMSA,omarketingfiledelistindicator,ocottagefileindicator ,oyearstarted ,oEighthExecutiveName ,oSeventhExecutiveName ,oSixthExecutiveName ,oFifthExecutiveName,oFourthExecutiveName ,oThirdExecutiveName ,oSecondExecutiveName , oFirstExecutiveName));  
        finalList5.add(new dunsdetails5(oemployeestotalhere,otopexecutivecontacts,oemployeestotalherecode,oFranchisecodes,osiccodessecondary,otrendyearemployeesales,oexecutivecontactmrccode,oexecutivecontacttitle,oreportdate,obaseyearemployeessales));
    }
        
    public class dunsdetails{
        public boolean selected{get;set;}
        public String AccId{get;set;}
        public string AccountName{get;set;}
        public string City{get;set;}
        public string Country{get;set;}
        public string CountyCode{get;set;}
        public string Address1{get;set;}
        public string CityCode{get;set;}
        public string ContinentCode{get;set;}
        public string ContinentCodeDup{get;set;}
        public string DomesticUltimateDuns{get;set;}
        public string DomesticUltimateName{get;set;}
        public string DomesticUltimateTotalEmployees{get;set;}
        public string EmployeesTotal{get;set;}
        public string GlobalUltimateAddress{get;set;}
        public string GlobalUltimateDuns{get;set;}
        public string GlobalUltimateName{get;set;}
        public string HierarchyCode{get;set;}
        public string HqParentAddress{get;set;}
        public string HQParentDuns{get;set;}
        public string HQParentName{get;set;}
        public string PreviousDuns{get;set;}
        public string SubsidiaryIndicator{get;set;}
        public string FaxNumber{get;set;}
        public string state{get;set;}
        public string PostalCode{get;set;}
        
        public string NationalId{get;set;}
        public string NationalIdSystemCode{get;set;}
        public string TelephoneNumber{get;set;}
        public string CEOName{get;set;}
        public string EmployeesHere{get;set;}
        public string UnderminedSICIndicator{get;set;}
        public string statecode{get;set;}
        public string Address2{get;set;}
        public string MailAddress{get;set;}
        
        public dunsdetails(string Address2, string MailAddress, string statecode, string UnderminedSICIndicator, string EmployeesHere, String Address1, String Country, String CountyCode, String City, String CityCode, String ContinentCode, String ContinentCodeDup, string DomesticUltimateDuns,string DomesticUltimateName,string DomesticUltimateTotalEmployees,string EmployeesTotal,string GlobalUltimateAddress,string GlobalUltimateDuns, string GlobalUltimateName,string HierarchyCode,string HqParentAddress,string HQParentDuns,string HQParentName,string PreviousDuns,string SubsidiaryIndicator,string FaxNumber,string state,string PostalCode,string NationalId,string NationalIdSystemCode,string TelephoneNumber,string CEOName){   
            this.UnderminedSICIndicator = UnderminedSICIndicator;
            this.Address1 = Address1;
            this.EmployeesHere = EmployeesHere;
            this.Address2 = Address2;
            this.MailAddress = MailAddress;
            this.Country = Country;
            this.CountyCode = CountyCode;           
            this.CityCode = CityCode;
            this.ContinentCode = ContinentCode;
            this.ContinentCodeDup = ContinentCodeDup;
            this.City = City;
            this.DomesticUltimateDuns = DomesticUltimateDuns;
            this.DomesticUltimateName = DomesticUltimateName;
            this.DomesticUltimateTotalEmployees = DomesticUltimateTotalEmployees;
            this.EmployeesTotal = EmployeesTotal;
            this.GlobalUltimateAddress = GlobalUltimateAddress;
            this.GlobalUltimateDuns = GlobalUltimateDuns;
            this.GlobalUltimateName = GlobalUltimateName;
            this.HierarchyCode = HierarchyCode;
            this.HqParentAddress = HqParentAddress;
            this.HQParentDuns = HQParentDuns;
            this.HQParentName = HQParentName;
            this.PreviousDuns = PreviousDuns;
            this.SubsidiaryIndicator = SubsidiaryIndicator;
            this.FaxNumber = FaxNumber;
            this.state = state;
            this.PostalCode = PostalCode;
            this.NationalId = NationalId;
            this.NationalIdSystemCode = NationalIdSystemCode;
            this.TelephoneNumber = TelephoneNumber;
            this.CEOName = CEOName;
            this.statecode = statecode;  
        }
    }
                    
    public class dunsdetails2{
        public string CEOTitle{get;set;}
        public string SquareFootage{get;set;}
        public string CableOrTelex{get;set;}
        public string DiasCode{get;set;}
        public string LegalStatus{get;set;}
        public string OwnsOrRentDetail{get;set;}
        public string PrimaryLocalActivityCode{get;set;}
        public string SiteBroadbandDemandScore{get;set;}
        public string UndeliverableAddressIndicator{get;set;}
        public string WhiteCollarEstimator{get;set;}
        public string RecordClassType{get;set;}
        public string AnnualSales{get;set;}
        public string AnnualSalesIndicator{get;set;}
        public string AnnualSalesUSDollar{get;set;}
        public string BaseYearEmployees{get;set;}
        public string BaseYearSales{get;set;}
        public string BlueCollarEstimator{get;set;}
        public string ImportExportCode{get;set;}
        public string LineOfBusiness{get;set;}
        public string OOB{get;set;}
        public string PercentGrowthEmployees{get;set;}
        public string PercentGrowthSalesSign{get;set;}
        public string PublicOrprivateIndicator{get;set;}
        public string DunsId{get;set;}
        public string BusinessName{get;set;}
        public string TradeStyleName{get;set;}
        public string DomesticUltimateAddress{get;set;}
        public string EmployeesTotalIndicator{get;set;}
        public string EmployeesHereIndicator{get;set;}
        
        public dunsdetails2(string EmployeesHereIndicator, string EmployeesTotalIndicator,  string DomesticUltimateAddress, string TradeStyleName, string BusinessName, string DunsId, string CEOTitle, string SquareFootage,string CableOrTelex,string DiasCode,string LegalStatus,string OwnsOrRentDetail,string PrimaryLocalActivityCode,string SiteBroadbandDemandScore,string UndeliverableAddressIndicator,string WhiteCollarEstimator,string RecordClassType,string AnnualSales,string AnnualSalesIndicator,string AnnualSalesUSDollar,string BaseYearEmployees,string BaseYearSales,string BlueCollarEstimator,string ImportExportCode,string LineOfBusiness,string OOB,string PercentGrowthEmployees,string PercentGrowthSalesSign,string PublicOrprivateIndicator){   //,
            this.EmployeesHereIndicator = EmployeesHereIndicator;
            this.EmployeesTotalIndicator = EmployeesTotalIndicator;
            this.TradeStyleName = tradestylename;
            this.DomesticUltimateAddress=DomesticUltimateAddress;
            this.BusinessName = BusinessName;
            this.DunsId = DunsId;
            this.CEOTitle = CEOTitle;
            this.SquareFootage = SquareFootage;
            this.CableOrTelex = CableOrTelex;
            this.DiasCode =DiasCode;
            this.LegalStatus = LegalStatus;
            this.OwnsOrRentDetail = OwnsOrRentDetail;
            this.PrimaryLocalActivityCode = PrimaryLocalActivityCode;
            this.SiteBroadbandDemandScore = SiteBroadbandDemandScore;
            this.UndeliverableAddressIndicator = UndeliverableAddressIndicator;
            this.WhiteCollarEstimator = WhiteCollarEstimator;
            this.RecordClassType = RecordClassType;
            this.AnnualSales = AnnualSales;
            this.AnnualSalesIndicator = AnnualSalesIndicator;
            this.AnnualSalesUSDollar = AnnualSalesUSDollar;
            this.BaseYearEmployees = BaseYearEmployees;
            this.BaseYearSales= BaseYearSales;
            this.BlueCollarEstimator = BlueCollarEstimator;
            this.ImportExportCode = ImportExportCode;
            this.LineOfBusiness = LineOfBusiness;
            this.OOB = OOB;
            this.PercentGrowthEmployees = PercentGrowthEmployees;
            this.PercentGrowthSalesSign = PercentGrowthSalesSign;
            this.PublicOrprivateIndicator = PublicOrprivateIndicator;
        }
    }
            
    public class dunsdetails3{
        public string FranchiseCode1{get;set;}
        public string FranchiseCode2{get;set;}
        public string FranchiseCode3{get;set;}
        public string FranchiseCode4{get;set;}
        public string FranchiseCode5{get;set;}
        public string FranchiseCode6{get;set;}
        public string StatusCode{get;set;}
        public string MailCountryCode{get;set;}
        public string MailCountryName{get;set;}
        public string US_1987_SIC1{get;set;}
        public string SIC6Code{get;set;}
        public string US_1987_SIC2{get;set;}
        public string US_1987_SIC3{get;set;}
        public string US_1987_SIC4{get;set;}
        public string US_1987_SIC5{get;set;}
        public string US_1987_SIC6{get;set;}
        public string trendyearsales{get;set;}
        public string trendyearemployees{get;set;}
        public string MailCityName{get;set;}
        public string MailStatename{get;set;}
        public string MailPostalCode{get;set;}
        public string CountryCode{get;set;}
        public string FranchiseCodeIndicator{get;set;}
        public string countryaccessCode{get;set;}
        public string FirstExecutiveNameMRC{get;set;}
        public string SecondExecutiveNameMRC{get;set;}
        public string ThirdExecutiveNameMRC{get;set;}
        public string FourthExecutiveNameMRC{get;set;}
        public string FifthExecutiveNameMRC{get;set;}
        public string SixthExecutiveNameMRC{get;set;}
        public string SeventhExecutiveNameMRC{get;set;}
        public string EighthExecutiveNameMRC{get;set;}
         
        public dunsdetails3(string MailCountryCode,string MailCountryName, string FranchiseCodeIndicator, string SeventhExecutiveNameMRC, string EighthExecutiveNameMRC, string FifthExecutiveNameMRC, string SixthExecutiveNameMRC, string FirstExecutiveNameMRC, string SecondExecutiveNameMRC, string ThirdExecutiveNameMRC, string FourthExecutiveNameMRC,string countryaccessCode,  string CountryCode, string MailPostalCode, string MailStatename,  string MailCityName, string trendyearsales, string trendyearemployees, string US_1987_SIC1, string US_1987_SIC2, string US_1987_SIC3,string US_1987_SIC4, string US_1987_SIC5, string US_1987_SIC6, string SIC6Code,  string StatusCode, string FranchiseCode1, string FranchiseCode2, string FranchiseCode3, string FranchiseCode4, string FranchiseCode5, string FranchiseCode6){       
            this.FranchiseCodeIndicator = FranchiseCodeIndicator;
            this.FirstExecutiveNameMRC = FirstExecutiveNameMRC;
            this.SecondExecutiveNameMRC = SecondExecutiveNameMRC;
            this.ThirdExecutiveNameMRC = ThirdExecutiveNameMRC;
            this.FourthExecutiveNameMRC = FourthExecutiveNameMRC;
            this.FifthExecutiveNameMRC = FifthExecutiveNameMRC;
            this.SixthExecutiveNameMRC = SixthExecutiveNameMRC;
            this.countryaccessCode = countryaccessCode ;
            this.SeventhExecutiveNameMRC = SeventhExecutiveNameMRC;
            this.EighthExecutiveNameMRC = EighthExecutiveNameMRC;
            this.CountryCode = CountryCode;
            this.MailPostalCode = MailPostalCode;
            this.MailStatename = MailStatename;
            this.MailCountryCode = MailCountryCode;
            this.MailCountryName = MailCountryName;
            this.MailCityName = MailCityName;
            this.trendyearsales = trendyearsales;
            this.trendyearemployees = trendyearemployees;
            this.SIC6Code = SIC6Code;
            this.US_1987_SIC1 = US_1987_SIC1;
            this.US_1987_SIC2 = US_1987_SIC2;
            this.US_1987_SIC3 = US_1987_SIC3;
            this.US_1987_SIC4 = US_1987_SIC4;
            this.US_1987_SIC5 = US_1987_SIC5;
            this.US_1987_SIC6 = US_1987_SIC6;
            this.StatusCode = StatusCode ;
            this.FranchiseCode6 = FranchiseCode6;
            this.FranchiseCode5 = FranchiseCode5;
            this.FranchiseCode4 = FranchiseCode4;
            this.FranchiseCode3 = FranchiseCode3;
            this.FranchiseCode2 = FranchiseCode2;
            this.FranchiseCode1 = FranchiseCode1;
        }
    }
    public class dunsdetails4{
        public list<string> affinityidlist{get;set;}
        public string AccId{get;set;}
        public string FirstExecutiveName{get;set;}
        public string SEcondExecutiveName{get;set;}
        public string ThirdExecutiveName{get;set;}
        public string FourthExecutiveName{get;set;}
        public string FifthExecutiveName{get;set;}
        public string SixthExecutiveName{get;set;}
        public string SeventhExecutiveName{get;set;}
        public string EighthExecutiveName{get;set;}
        public string yearstarted{get;set;}
        public string cottagefileindicator{get;set;}
        public string marketingfiledelistindicator{get;set;}
        public string MSA{get;set;}
        public string filler1{get;set;}
        public string filler2{get;set;}
        public string filler3{get;set;}
        public string MarketableNonMarketable{get;set;}
        public string NumberofPcs{get;set;}
        public string aggregatednumberofpcsultimate{get;set;}
        public string numberofaccounts{get;set;}
        public string numberoffamilymembersglobal{Get;set;}
        public string territorycovered{get;set;}
        public string FirstExecutiveTitle{get;set;}
        public string SecondExecutiveTitle{get;set;}
        public string thirdExecutiveTitle{get;set;}
        public string FourthExecutiveTitle{get;set;}
        public string FifthExecutiveTitle{get;set;}
        public string SixthExecutiveTitle{get;set;}
        public string SeventhExecutiveTitle{get;set;}
        public string EighthExecutiveTitle{get;set;}
        
        public dunsdetails4(string AccId, list<string> affinityidlist, string EighthExecutiveTitle, string SeventhExecutiveTitle, string SixthExecutiveTitle, string FifthExecutiveTitle, string FirstExecutiveTitle, string SecondExecutiveTitle, string thirdExecutiveTitle, string FourthExecutiveTitle, string territorycovered, string numberoffamilymembersglobal, string numberofaccounts, string aggregatednumberofpcsultimate, string NumberofPcs, string oMarketableNonMarketable, string filler1, string filler2, string filler3, string MSA, string marketingfiledelistindicator, string cottagefileindicator , string yearstarted, string EighthExecutiveName, string FourthExecutiveName, string FifthExecutiveName, string SixthExecutiveName, string SeventhExecutiveName, string FirstExecutiveName, string SEcondExecutiveName, string ThirdExecutiveName){
            this.AccId = AccId;
            this.affinityidlist = affinityidlist;
            this.EighthExecutiveTitle = EighthExecutiveTitle;
            this.SeventhExecutiveTitle = SeventhExecutiveTitle;
            this.SixthExecutiveTitle = SixthExecutiveTitle;
            this.FifthExecutiveTitle = FifthExecutiveTitle;
            this.FourthExecutiveTitle =FourthExecutiveTitle;
            this.thirdExecutiveTitle = thirdExecutiveTitle;
            this.SecondExecutiveTitle = SecondExecutiveTitle;
            this.FirstExecutiveTitle = FirstExecutiveTitle;
            this.territorycovered = territorycovered;
            this.numberoffamilymembersglobal = numberoffamilymembersglobal;
            this.numberofaccounts = numberofaccounts;
            this.aggregatednumberofpcsultimate = aggregatednumberofpcsultimate;
            this.NumberofPcs = NumberofPcs;
            this.MarketableNonMarketable = MarketableNonMarketable;
            this.filler1 = filler1;
            this.filler2 = filler2;
            this.filler3 = filler3;
            this.MSA = MSA;
            this.marketingfiledelistindicator = marketingfiledelistindicator;
            this.cottagefileindicator = cottagefileindicator ;
            this.yearstarted = yearstarted;
            this.FirstExecutiveName = FirstExecutiveName;
            this.SEcondExecutiveName = SEcondExecutiveName;
            this.ThirdExecutiveName = ThirdExecutiveName;
            this.FourthExecutiveName = FourthExecutiveName;
            this.FifthExecutiveName = FifthExecutiveName;
            this.SixthExecutiveName = SixthExecutiveName;
            this.SeventhExecutiveName = SeventhExecutiveName;
            this.EighthExecutiveName = EighthExecutiveName;
       }
   }
   
   public class dunsdetails5{
   public string employeestotalhere{get;set;}
   public string topexecutivecontacts{get;set;}
   public string employeestotalherecode{get;set;}
   public string Franchisecodes{get;set;}
   public string siccodessecondary{get;set;}
   public string trendyearemployeesales{get;set;}
   public string executivecontactmrccode{get;set;}
   public string executivecontacttitle{get;set;}
   public string reportdate{get;set;}
   public string baseyearemployeessales{get;set;}
   
       public dunsdetails5(string employeestotalhere, string topexecutivecontacts, string employeestotalherecode, string Franchisecodes, string siccodessecondary, string trendyearemployeesales, string executivecontactmrccode, string executivecontacttitle, string reportdate, string baseyearemployeessales ){
           this.employeestotalhere = employeestotalhere;
           this.topexecutivecontacts = topexecutivecontacts;
           this.employeestotalherecode  = employeestotalherecode ;
           this.Franchisecodes = Franchisecodes;
           this.siccodessecondary = siccodessecondary;
           this.trendyearemployeesales  = trendyearemployeesales;
           this.executivecontactmrccode = executivecontactmrccode;
           this.executivecontacttitle= executivecontacttitle;
           this.reportdate = reportdate;
           this.baseyearemployeessales = baseyearemployeessales;
       }
   }

   public MDM_DBAccountDetails(Boolean val, Id recId, string recname, string recownername, string recowneremail, Boolean Exist){
       this.check = val;
       this.AffRecId = recId;
       this.AccRecName = recname;
       this.AccRecOwnerName = recownername;
       this.AccRecOwnerEmail = recowneremail;
       this.AccountExist = Exist;
   }
   
   //Functionality for pop up windows from D&B Account detail page
   public Boolean check{set;get;}
   public Boolean AccountExist{set;get;}
   public Id AffRecId {set;get;}
   public String AccRecName {set;get;}
   public String AccRecOwnerName{set;get;}
   public String AccRecOwnerEmail{set;get;}
   Public Static String MyAffId{set;get;}
   public static Account newaccount2{get;set;}
   @RemoteAction
   public static MDM_DBAccountDetails CheckAccess(String MyId){
       MDM_DBAccountDetails temp;
       if([select Count() from Account where account_id__c = : MyId] > 0){          
       
           newaccount2 = [select id,name,account_id__c,owner.name,owner.email from Account where account_id__c = : MyId];
          if([select RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND HasReadAccess = true AND RecordId = :newaccount2.id].size() > 0){
               userrecordaccess u = [SELECT RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND HasReadAccess = true AND RecordId = :newaccount2.id];
               temp = new MDM_DBAccountDetails(true, newaccount2.Id, newaccount2.name, newaccount2.owner.name, newaccount2.owner.email, true);
               return temp ;
           }
           else {
           temp = new MDM_DBAccountDetails(false, newaccount2.Id, newaccount2.name, newaccount2.owner.name, newaccount2.owner.email, true);
           return temp;
           }
       }else if([select Count() from Account where account_id__c = : MyId] == 0){
           temp = new MDM_DBAccountDetails(false, null,null,null,null, false);
           return temp;
       }
   else return null;
   }
}