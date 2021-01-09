/***********************************************************
* Name          : MDM_MultipleDunsCntrlr
* Description   : To display the mulitple duns number
* ---------------------------------------------------------
* Revision      Release     Name        Date            Description
* 1.0           16.03       Nisha       9-12-2014       Developed parsing the response, and displaying the results on a page.
                                                        
************************************************************/
public class MDM_MultipleDunsCntrlr{

    public string body;
    public string body2;
    public string output;
    public List<dunsDataWrapper> allDunsData {get;set;} 
    public string selecteddunsnumber{get;set;}
    public string selectedduns{get;set;}
    Account acct;
    public string duns1{get;set;}
    public string duns2{get;set;}
    public string accountid{get;set;}
    public string[] listofduns{get;set;}
    public set<string> dunsset{get;set;}
    public String selectedDunsValue{get;set;}
    public String oMessage{get;set;}
    public Boolean showResultTable{get;set;}
    
    public MDM_MultipleDunsCntrlr(){ 
        showResultTable = true;
        duns1 = apexpages.currentpage().getparameters().get('duns1');
        system.debug('checking for obtained duns numbers' + duns1);
        duns2 = apexpages.currentpage().getparameters().get('duns2');
        system.debug('checking for duns2' + duns2);
        listofduns = duns1.split(';');
        system.debug('splitting:' + listofduns);
        dunsset = new set<string>(listofduns);
        dunsset.add(duns2);
        system.debug('dunsset:' + dunsset);
        oMessage = null;
        accountid = apexpages.currentpage().getparameters().get('id'); //accountid
        allDunsData = new list<dunsDataWrapper>();
        navigatetomultipleduns(dunsset);
    }
    
    public void navigatetomultipleduns(set<string> dunsset){  
        system.debug('checking if multipleduns method is invoked');
        system.debug('dunsset:' + dunsset);
        body = multipleduns(dunsset);
        system.debug('checking for request body' + body);
        try{
            output = sendingrequest(body);
            output = output.trim().replaceFirst('^([\\W]+)<','<');
            allDunsData = parsexml(output);
            system.debug('checking for response for multiple duns'+ allDunsData);
        }catch (Exception e){
           system.debug('displaying error message' + e.getmessage());
        }
    }
    
    //Method for parsing
    public set<string> dunsFields = new Set<String>{'City', 'Country', 'DunsName', 'DunsNumber', 'HqDuns', 'Level', 'PostalCode', 'State', 'Address' , 'OOBIndicator' , 'Employee Size'};
    public String localName;
    public List<dunsDataWrapper> finalList{get;set;}
    public List<String> subChildElementsList {get;set;}
    public String oCountry{get;set;}
    public String oCountyCode{get;set;}
    public String oCity{get;set;}
    public String oDunsId{get;set;}
    public String oDunsName{get;set;}
    public String oState{get;set;}
    public String oPostalCode{get;set;}
    public String oAddress1{get;set;}
    public String oOOB{get;set;}
    public String oEmpSize{get;set;}
    public String oHqDuns{get;set;}
    public String oLevel{get;set;}
    public string oAddress2{get;set;}
    public string oEmployeeSize {get;set;}
    
     public list<dunsDataWrapper> parsexml(string responsebody) {
               
        Integer i;
        Integer lastcount = 0;
        List<Dom.XmlNode> childlist = new List<Dom.XmlNode>();
        String subChildElementName;
        subChildElementsList = new List<String>();

        Integer childElementCount =0;
        Integer subChildElementsCount = 0;
     try{
            Dom.Document doc = new Dom.Document();
            doc.load(responseBody);
            System.Debug('ResponseBody##' +responseBody);
            
            Dom.XMLNode rootElement = doc.getRootElement();
            System.Debug('rootElement'+rootElement);
            
            String rootElementName = rootElement.getName();
            System.Debug('rootElementName'+rootElementName);
            
            Dom.XMLNode Body = rootElement.getChildElements()[1];
            String BodyName =  Body.getName();
            System.debug('Body :' +BodyName + Body);
            Dom.XMLNode HierarchyResponse = Body.getChildElements()[0];
            String HierarchyResponseName =  HierarchyResponse.getName();
            System.debug('HierarchyResponseName :' +HierarchyResponseName +' '+HierarchyResponse);
            Dom.XMLNode HierarchyResult = HierarchyResponse.getChildElements()[0];
            String HierarchyResultName =  HierarchyResult.getName();
            System.debug('HierarchyResultName :' +HierarchyResultName +' '+HierarchyResult);
            Dom.XMLNode CommonSearchResponse = HierarchyResult.getChildElements()[0];
            String CommonSearchResponseName =  CommonSearchResponse.getName();
            System.debug('CommonSearchResponseName :' +CommonSearchResponseName +' '+CommonSearchResponse);
            
            Dom.XMLNode CommonSearchResponseObj = CommonSearchResponse.getChildElements()[0];
            String CommonSearchResponseObjName =  CommonSearchResponseObj.getName();
            System.debug('CommonSearchResponseObjName :' +CommonSearchResponseObjName +' '+CommonSearchResponseObj);
                If (CommonSearchResponseObj.getName() == 'Message'){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MDM_No_Record_Found);
                    ApexPages.addMessage(myMsg);
                    showResultTable = false;
            }
            
            for(Dom.XMLNode childelement : CommonSearchResponse.getChildElements())
            {
                childlist.add(childelement);
                childElementCount++;
                System.Debug('Child Element:' +childElementCount +' ' + childelement);
                System.Debug('childlist' +childlist);
                finalList = new List<dunsDataWrapper>();
            }
            for (i= 0; i < childElementCount; i++){
                for(Dom.XMLNode subChildElement: childlist[i].getChildElements())
                {
                    subChildElementName = subChildElement.getName();
                    subChildElementsList.add(subChildElementName);
                    subChildElementsCount++;
                    System.Debug('Sub Child Element:' +subChildElementsCount +' ' + subChildElementName);

                    //To dynamicly assinged Value to each node
                 
                    // To get value for required Node
                    If(subchildelement.getName() == 'Address1'){
                        oAddress1 = subchildelement.getText();
                    } 
                    If(subchildelement.getName() == 'Address2'){
                        oAddress2 = subchildelement.getText();
                    } 
                    If(subchildelement.getName() == 'BusinessName'){
                        oDunsName = subchildelement.getText();
                    }
                    If(subchildelement.getName() == 'City'){
                        oCity = subchildelement.getText();
                    }
                    If(subchildelement.getName() == 'Country'){
                        oCountry = subchildelement.getText();
                    }
                    If(subchildelement.getName() == 'CountyCode'){
                        oCountyCode = subchildelement.getText();
                    }
                    If(subchildelement.getName() == 'DunsId'){
                        oDunsId = subchildelement.getText();
                    }
                     If(subchildelement.getName() == 'OOB'){
                        oOOB = subchildelement.getText();
                    }                   
                    If(subchildelement.getName() == 'PostalCode'){
                        oPostalCode = subchildelement.getText();
                    }
                     If(subchildelement.getName() == 'State'){
                        oState = subchildelement.getText();
                    }
                    if(subchildelement.getName() == 'HqDuns'){
                        oHqDuns = subchildelement.getText();
                    }
                    if(subchildelement.getName() == 'Level'){
                        oLevel = subchildelement.getText();
                    }
                    if(subchildelement.getName() == 'EmployeeSize'){
                        oEmployeeSize = subchildelement.getText();
                    }
      
                }
                finalList.add(new dunsDataWrapper(oEmployeeSize ,oAddress2, oLevel, oHqDuns, false,oAddress1,oDunsName,oCity,oCountry,oCountyCode,oDunsId,oOOB,oPostalCode,oState));
            }
         } catch(Exception e){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MDM_Connection_Failure);
             ApexPages.addMessage(myMsg);
             showResultTable = false;
             system.debug('get the error' + e.getmessage());
        }
            return finalList;
   }
    
    
    public class dunsDataWrapper{
        
         public boolean selected{get;set;}
        public string Address1{get;set;}
        public string DunsName{get;set;}
        public string City{get;set;}
        public string Country{get;set;}
        public string CountyCode{get;set;}
        public string DunsId{get;set;}
        public string OOB{get;set;}
        public string PostalCode{get;set;}
        public string State{get;set;}
        public string HqDuns{get;set;}
        public string Level{Get;set;}
        public string Address2{get;set;}
        public string EmployeeSize{get;set;}
        
            public dunsDataWrapper(string EmployeeSize, string Address2, string level,string HqDuns, Boolean selected, String Address1, String DunsName, String City, String Country, String CountyCode, String DunsId, String OOB, String PostalCode, String State){
                this.EmployeeSize = EmployeeSize;
                this.Address2 = Address2;
                this.level = level;
                this.Hqduns = Hqduns;
                this.selected = selected;
                this.Address1 = Address1;
                this.DunsName = DunsName;
                this.City = City;
                this.Country = Country;
                this.CountyCode = CountyCode;           
                this.DunsId = DunsId;
                this.OOB = OOB;
                this.PostalCode = PostalCode;
                this.State = State;
    
    }
    }
    
    //constructing the body for request
    public string multipleduns(set<string> dunsset){
    system.debug('duns 1 inside request building' + dunsset);
    body = '';
    body = '<s:Envelope xmlns:a="http://www.w3.org/2005/08/addressing" xmlns:s="http://www.w3.org/2003/05/soap-envelope">'+
           '<s:Header>'+
           '<a:Action s:mustUnderstand="1">CIL/IExploreAffinity/SearchDuns</a:Action>'+
           '<a:MessageID>'+System.label.MDM_MessageID+'</a:MessageID>'+ 
           '<a:ReplyTo>'+
           '<a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>'+
           '</a:ReplyTo>'+
           '<a:To s:mustUnderstand="1">'+System.label.MDM_SITURL+'</a:To>'+ 
           '</s:Header>'+
           '<s:Body>'+
           '<SearchDuns xmlns="CIL">'+
           '<request xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Duns.Request" i:type="b:CustomerMDMDunsSearchRequestBObj">'+
           '<b:DunsBObj>'+
           '<b:DunsId xmlns:c="http://schemas.microsoft.com/2003/10/Serialization/Arrays">';
           
    body2 ='</b:DunsId>'+
           '</b:DunsBObj>'+
           '</request>'+
           '</SearchDuns>'+
           '</s:Body>'+
           '</s:Envelope>';
           
    if(dunsset != null){
        for( string var: dunsset){
           system.debug('checking for each dunsnumber inside request for loop' + var);
           var = var.replace('{','');
           var = var.replace('}','');
            body = body + '<c:long>'+var+'</c:long>'; 
        }
    }
        body2 = body + body2;
       return body2;
}

    public string sendingrequest(string body1 ){
        output = sendrequest(body1);  
        return output;
    }
    
    //constructing the http request
    public string sendrequest( string body2){  
    string xmloutput;
    httprequest req = new httprequest();
    req.setMethod('POST');
    req.setHeader('content-type','text/xml;charset=UTF-8');
    req.setHeader('SOAPAction','');
    req.setHeader('Authorization',System.Label.MDM_Credentials);
    if(Environment.isProduction()) { 
             req.setEndpoint(System.Label.MDM_Prod_Url);
    }else{
             req.setEndpoint(System.Label.MDM_Sandbox_Url); 
    }

    req.setBody(body2);
    system.debug('Request Body: '+ req.getBody());
    Integer ResErrorCode;
    http http = new http();
    try{
        httpresponse res;
        string ResError;
        
        if(!test.isrunningtest()){
            res = http.send(req);
            ResError = res.getStatus();
            ResErrorCode = res.getStatusCode();
            xmloutput = res.getBody();
            system.debug('response body:' + res.getBody());
            system.debug('status: ' + res.getStatus());
            system.debug('status_code: '+ res.getstatuscode());
        } 
    }catch(Exception e){    
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MDM_Connection_Failure);
            ApexPages.addMessage(myMsg);
        showResultTable = false;
        system.debug('get the error' + e.getmessage());
       
    }
         return xmloutput;
    }
    
    //Functionality for search button
    public PageReference goToSearchPage(){
        PageReference retUrl;
        retUrl = new PageReference('/apex/MDM_SearchDunsPage?close='+true);
        return retUrl;
    }

}