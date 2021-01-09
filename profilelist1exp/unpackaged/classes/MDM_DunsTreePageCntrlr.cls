/***********************************************************
* Name          : MDM_DunsTreePageCntrlr
* Description   : Extension class for the D&B Account hierarchy page
* ---------------------------------------------------------
* Revision      Release     Name        Date            Description
* 1.0           16.03       Raphael     9-12-2014       Developed parsing the response, building the hierarhcy (parent-child relationships of the wrapper class),
                                                        and sorting by Region or Country
************************************************************/

public class MDM_DunsTreePageCntrlr{

    /*******************Variables*********************/
    public Transient List<dunsDataWrapper> firstLevel {get;set;}
    public Transient Map<String, Map<String, List<dunsDataWrapper>>> allDunsDataMap {get;set;}
    public list<dunsDataWrapper> listdunsDataWrapper {get;set;}
    public String acct {get;set;}
    public Boolean displayTree {get;set;}
    public Boolean displayPage {get;set;}
    public Boolean displayTimeLimit {get;set;}
    public Boolean displayTreeHeaders {get;set;}
    public Boolean sortCountry {get;set;}
    public Boolean sortPostal {get;set;}
    public Boolean showRadios {get;set;}
    public Boolean showCloseButton {get;set;}
    public String xmlString {get;set;}
    public String dunsNumForTree {get;set;}
    public String errorMsg {get;set;}
    public String isLightning {get;set;}
    
    public Integer levelCount {get;set;}
    public Integer rowLimit {get {return Integer.valueOf(System.Label.MDM_Max_Row_Limit);} set;}

    public String sortCriteria {get;set;}
    static String sortThis {get;set;}
    public String sortThisPublic {get;set;}
    public String hierarchyType {get;set;}
    
    public String hierarchyLevel {get;set;}
    public Integer hierarchyLevelNum {get;set;}
    public List<SelectOption> getLevelOptions() {
        List<SelectOption> levelOptions = new List<SelectOption>();
        levelOptions.add(new SelectOption('1','1'));
        levelOptions.add(new SelectOption('2','2'));
        levelOptions.add(new SelectOption('3','3'));
        levelOptions.add(new SelectOption('4','4'));
        levelOptions.add(new SelectOption('5','5'));
    
        return levelOptions;
    }
    public String strMethod {set; get;}
    
    public String requestBodyTree {get{
                     return '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing">'+
                            '<s:Header>'+
                            '<a:Action s:mustUnderstand="1">CIL/IExploreAffinity/GetDunsHierarchy</a:Action>'+
                            '<a:MessageID>'+System.Label.MDM_MessageID+'</a:MessageID>'+
                            '<a:ReplyTo>'+
                            '<a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>'+
                            '</a:ReplyTo>'+
                            '<a:To s:mustUnderstand="1">'+System.Label.MDM_SITURL+'</a:To>'+
                            '</s:Header>'+
                            '<s:Body>'+
                            '<GetDunsHierarchy xmlns="CIL">'+
                            '<request i:type="b:CustomerMDMDunsHierarchySearchRequestBObj" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Hierarchy.Request" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'+
                            '<b:DunsId>' + dunsNumForTree + '</b:DunsId>'+
                            '<b:HierarchyLevel>' + hierarchyLevel + '</b:HierarchyLevel>'+
                            '<b:HierarchyType>' + hierarchyType + '</b:HierarchyType>'+
                            '<a:MaxRowLimit>' + rowLimit + '</a:MaxRowLimit>' +
                            '</request>'+
                            '</GetDunsHierarchy>'+
                            '</s:Body>'+
                            '</s:Envelope>';}
                    set;}
    
    public Integer startHeap {get;set;}
    public Integer endHeap {get;set;}
    public Integer limitHeap {get;set;}
    
    public Integer cpuTime {get;set;}
    public Integer cpuTimeAfterParse {get;set;}
    public Integer cpuTimeBeforeCallout {get;set;}
    public Integer cpuTimeAfterCallout {get;set;}
    public Integer cpuTimeLimit {get;set;}
    
    public Integer cpuTimeBeforeSort {get;set;}
    public Integer cpuTimeAfterSort {get;set;}
    
    public Integer totalRun {get;set;}
    /***************end of variables declaration*******************/
    
    public MDM_DunsTreePageCntrlr(){
        
        isLightning = 'false';               
        acct = system.currentpagereference().getparameters().get('id');
        sortCriteria = 'Country';
        hierarchyType = 'TopToBottom';
        hierarchyLevel = '5';
        showRadios = true;
        isLightning = apexpages.currentpage().getparameters().get('lightningPage');
        showCloseButton = Boolean.valueOf(system.currentpagereference().getparameters().get('close'));
        if(isLightning== 'true')
            showCloseButton = false;
        if(hierarchyType == 'Global')
            showRadios = false;
            
        dunsNumForTree = system.currentpagereference().getparameters().get('dunsnumber');
        if(dunsNumForTree == null)
                dunsNumForTree = system.currentpagereference().getparameters().get('duns1');
        if(dunsNumForTree == null)
                dunsNumForTree = system.currentpagereference().getparameters().get('duns2');
        }
    

    /******************************BEGIN SORTING**************************/

    public void doSort(){
        List<dunsDataWrapper> tempList;
        Map<String, List<dunsDataWrapper>> dunsmap;
        Set <String> dunsmapkeys;
        
        sortThis = sortCriteria;
        sortThisPublic = sortThis;
        if(sortThis == 'Country'){
            sortCountry = true;
            sortPostal = false;
        }
        if(sortThis == 'PostalCode'){
            sortCountry = false;
            sortPostal = true;
        }
        
        cpuTimeBeforeSort = Limits.getCpuTime();
        if(levelCount > 1){
            for(Integer i = levelCount; i >= 2; i--){
                tempList = new List<dunsDataWrapper>();
                dunsmap = new Map<String, List<dunsDataWrapper>>();
                
                dunsmap = allDunsDataMap.get(String.valueOf(i));
                
                dunsmapkeys = new Set<String>();
                dunsmapkeys = dunsmap.keySet();
                
                for(String s : dunsmapkeys){
                    tempList = dunsmap.get(s);
                    if(tempList != null){
                        tempList.sort();
                        
                    }
                    dunsmap.put(s, tempList);
                        
                }
                allDunsDataMap.put(String.valueOf(i), dunsmap);
            }
        }
        
        cpuTimeAfterSort = Limits.getCpuTime();
    }

    /******************************END SORTING**************************/

    /*******************************BEGIN CALLOUT********************************/
    public PageReference beginCallout(){
        strMethod = 'POST';
        displayTree = true;
        displayPage = true;
        displayTreeHeaders = true;
        displayTimeLimit = false;
        sortCountry = true;
        levelCount = 1;
        errorMsg = '';
        startHeap = Limits.getHeapSize();
        hierarchyLevelNum = Integer.valueOf(hierarchyLevel);
        firstLevel = new List<dunsDataWrapper>();
        allDunsDataMap = new Map<String, Map<String, List<dunsDataWrapper>>>();     
        
        try{
            cpuTimeBeforeCallout = Limits.getCpuTime();
            XmlStreamReader xsr = new XmlStreamReader(sendRequest(requestBodyTree));
            cpuTimeAfterCallout = Limits.getCpuTime();
            parsexml(xsr);
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, errorMsg);
            ApexPages.addMessage(msg);
        }
        
        if(errorMsg != ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, errorMsg);
            ApexPages.addMessage(msg);    
        }
        

        endHeap = Limits.getHeapSize();
        limitHeap = Limits.getLimitHeapSize();
        cpuTime = Limits.getCpuTime();
        cpuTimeLimit = Limits.getLimitCpuTime();
        doSort();
        return null;
         
    }

    public string sendrequest(string body){  //string endpoint,
        string xmloutput;
        httprequest req = new httprequest();
        req.setMethod('POST');
        req.setHeader('content-type','text/xml;charset=UTF-8');
        req.setHeader('SOAPAction','');
        req.setHeader('Authorization',System.Label.MDM_Credentials);
        
        if(Environment.isProduction())
             req.setEndpoint(System.Label.MDM_Prod_Url);
        else
            req.setEndpoint(System.Label.MDM_Sandbox_Url);
        req.setBody(body);
        req.setTimeout(120000);
        
        http http = new http();
        httpresponse res;
        
        if(!test.isrunningtest()){
            try{
                for(Integer i = 0; i <= 9; i++){
                    res = http.send(req);
                    totalRun = i+1;
                    if(res.getstatuscode() == 200){
                        xmloutput = res.getBody();
                        break;
                    }
                }
            }catch(Exception e){
                if(e.getmessage().contains('size')){
                    errorMsg = System.Label.MDM_Size_Limit_Error;
                    system.debug('errorMsg 263' + errorMsg);
                    displayTree = false;
                }else{
                    errorMsg = System.Label.MDM_Connection_Failure;
                    system.debug('errorMsg 267' + errorMsg);
                    displayPage = false;
                }
                
            }
            
        if(res.getStatusCode() != 200 && errorMsg == ''){
            errorMsg = System.Label.MDM_Connection_Failure;
            system.debug('errorMsg 275' + errorMsg);
            displayPage = false;
        }
            system.debug('response body:' + res.getBody());
            system.debug('status: ' + res.getStatus());
            system.debug('status_code: '+ res.getstatuscode());
        }
        else{
            Test.setMock(HttpCalloutMock.class, new MDM_DunsTreeMockHttpResponseGenerator ());
            HttpResponse res1 = CalloutClass.getInfoFromExternalService();
            xmloutput = res1.getbody();
            System.debug('Test xmloutput: ' + xmloutput);
        }
        
        return xmloutput;
    }

    public PageReference requestTopToBottom(){
        hierarchyType = 'TopToBottom';
        showRadios = true;
        beginCallout();
        return null;
    }

    public PageReference requestBottomToTop(){
        hierarchyType = 'BottomToTop';
        showRadios = true;
        beginCallout();
        return null;
    }

    public PageReference requestGlobal(){
        hierarchyType = 'Global';
        showRadios = false;
        beginCallout();
        return null;
    }

    /*******************************END CALLOUT********************************/
    /*******************************BEGIN PARSING XML********************************/
    Set<string> dunsFields = new Set<String>{'City', 'Country', 'DunsName', 'DunsNumber', 'HqDuns', 'Level', 'PostalCode', 'State', 'AddressLine1', 'AddressLine2', 'SalesRevenue', 'EmployeeSize', 'PhoneNumber', 'AccountType', 'HasChildren', 'Fault', 'faultcode', 'faultstring', 'Message'};
    
    public /*List<dunsDataWrapper>*/ void parsexml(XmlStreamReader reader) {
        reader.setCoalescing(true);
        List<dunsDataWrapper> tempList;
        Map<String, List<dunsDataWrapper>> dunsMap;
        dunsDataWrapper hierarchy;
        Integer levelNum;
        
        boolean isSafeToGetNextXmlElement = true;
        System.debug('This is test hierarchyType: ' + hierarchyType);
        while(isSafeToGetNextXmlElement) {
            
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                
                if (reader.getLocalName() == 'CommonSearchResponseBObj'){
                    if(Limits.getCpuTime() > 9500){
                        cpuTimeAfterParse = Limits.getCpuTime();
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning, System.Label.MDM_Time_Limit_Warning);
                        ApexPages.addMessage(msg);
                        displayTimeLimit = true;
                        break;
                    }             
                    hierarchy = new dunsDataWrapper();    
                }
                else 
                    if (dunsFields.contains(reader.getLocalName())) {
                        parseHierarchy(reader, reader.getLocalName(), hierarchy);
                        
                    }
                
            }
            else if (reader.getEventType() == XmlTag.END_ELEMENT){
                if (reader.getLocalName() == 'CommonSearchResponseBObj'){
                    if(hierarchy != null){
                        levelNum = Integer.valueOf(hierarchy.Level);
                        if(levelNum > levelCount)
                            levelCount = levelNum;
                        levelNum = levelNum + 1;
                        
                          if(hierarchy.Level == '1'){
                            
                            firstLevel.add(hierarchy);
                            integer count = firstlevel.size();
                            system.debug('countr of first level:' + count);
                        }
                        else{ //if not Level 1
                            tempList = new List<dunsDataWrapper>();
                            dunsmap = new Map<String, List<dunsDataWrapper>>();
                            
                            if(allDunsDataMap.isEmpty()){
                                tempList.add(hierarchy);
                                dunsMap.put(hierarchy.HqDuns, tempList);
                                allDunsDataMap.put(hierarchy.Level, dunsMap);
                            }
                            else{ //if allDunsDataMap got value
                                dunsMap = allDunsDataMap.get(hierarchy.Level);
                                
                                if(dunsMap == null){ //for new levels
                                    tempList.add(hierarchy);
                                    dunsmap = new Map<String, List<dunsDataWrapper>>();
                                    dunsMap.put(hierarchy.HqDuns, tempList);
                                    allDunsDataMap.put(hierarchy.Level, dunsMap);
                                    
                                    
                                }
                                else{ //if the level exists, look for the HqDuns on innermap
                                
                                    if(dunsMap.containsKey(hierarchy.HqDuns) ){
                                        tempList = dunsMap.get(hierarchy.HqDuns);
                                        tempList.add(hierarchy);
                                        dunsMap.put(hierarchy.HqDuns, tempList);
                                        allDunsDataMap.put(hierarchy.Level, dunsMap);
                                    }
                                    else{ //if HqDuns on innermap not yet exist
                                        tempList.add(hierarchy);
                                        dunsMap.put(hierarchy.HqDuns, tempList);
                                        allDunsDataMap.put(hierarchy.Level, dunsMap);
                                    }
                                }
                                
                            }
                        }
                        
                        /*put dummy data to avoid Map key not found error on vfpage*/
                        //if(hierarchyType != 'BottomToTop'){            
                            tempList = new List<dunsDataWrapper>();
                            dunsmap = new Map<String, List<dunsDataWrapper>>();
                            
                            if(allDunsDataMap.get(String.valueOf(levelNum)) == null){
                                dunsMap.put(hierarchy.DunsNumber, tempList);
                                allDunsDataMap.put(String.valueOf(levelNum), dunsMap);
                            }
                            else{ //if level + 1 got value
                                dunsMap = allDunsDataMap.get(String.valueOf(levelNum));
                                dunsMap.put(hierarchy.DunsNumber, tempList);
                                allDunsDataMap.put(String.valueOf(levelNum), dunsMap);    
                            }
                        //}
                    }
                    if(Limits.getCpuTime() > 9500){
                        cpuTimeAfterParse = Limits.getCpuTime();
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning, System.Label.MDM_Time_Limit_Warning);
                        ApexPages.addMessage(msg);
                        displayTimeLimit = true;
                        break;
                    }   
                }
            }
            
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                System.debug('Breaking the first loop');
                break;
            }
        }
        
        if(hierarchyType == 'BottomToTop'){
            Map<String, List<dunsDataWrapper>> dunsMapTemp = new Map<String, List<dunsDataWrapper>>();
            Map<String, List<dunsDataWrapper>> dunsMapTemp2 = new Map<String, List<dunsDataWrapper>>();
            List<dunsDataWrapper> firstLevelCopy = new List<dunsDataWrapper>();
            
            firstLevelCopy.add(firstLevel[0]);
            System.debug('firstLevelCopy: ' + firstLevelCopy);
            
            dunsMapTemp = allDunsDataMap.get(String.valueOf(levelCount));
            Boolean breakOuter = false;
            for(Integer i = 0; i <= dunsMapTemp.size(); i++){
                if(breakOuter == true)
                    break;
                
                for(dunsDataWrapper d : dunsMapTemp.values().get(i)){
                    if(d != null){
                        firstLevel.remove(0);
                        firstLevel.add(d);
                        breakOuter = true;
                        break;
                    }
                }
                
                if(breakOuter == true)
                    break;
            }
            
            
            dunsMapTemp.clear();
            dunsMapTemp.put(firstLevelCopy[0].HQDuns, firstLevelCopy);
            allDunsDataMap.put(String.valueOf(levelCount), dunsMapTemp);
                    
            
            System.debug('allDunsDataMap before: ' + allDunsDataMap);
            System.debug('firstLevel: ' + firstLevel);
            
            Integer midLevels = levelCount -1;
            Integer counter = midLevels;
            Integer breakCheck = 2;
            if(midLevels > 2){
                for(Integer i = 2; i <= midLevels; i++){
                    if(breakCheck == counter)
                        break;
                    dunsMapTemp = allDunsDataMap.get(String.valueOf(counter));
                    
                    dunsMapTemp2 = allDunsDataMap.get(String.valueOf(i));
                    System.debug('dunsMapTemp: ' + dunsMapTemp);
                    System.debug('dunsMapTemp2: ' + dunsMapTemp2);
                    
                    allDunsDataMap.put(String.valueOf(counter), dunsMapTemp2);
                    allDunsDataMap.put(String.valueOf(i), dunsMapTemp);
                    System.debug('allDunsDataMap on ' + i +  ' : ' + allDunsDataMap);
                    
                    counter--;
                    
                }
            }
            
            /*put dummy data to avoid Map key not found error on vfpage*/
                                    
            List<dunsDataWrapper> tempNullList = new List<dunsDataWrapper>();
            for(Integer i = 2; i <= levelCount; i++){
                String currLevel = String.valueOf(i);
                String nextLevel = String.valueOf(i + 1);
                
                dunsMapTemp = allDunsDataMap.get(currLevel);
                dunsMapTemp2 = allDunsDataMap.get(nextLevel);
                
                if(i==2){
                    if(!dunsMapTemp.keySet().contains(firstLevel[0].DunsNumber)){
                        dunsMapTemp.put(firstLevel[0].DunsNumber, tempList);
                        allDunsDataMap.put(nextLevel, dunsMapTemp);
                    }
                }
                
                for(String s : dunsMapTemp.keySet()){
                    for(dunsDataWrapper innerList : dunsMapTemp.get(s)){
                        if(!dunsMapTemp2.keySet().contains(innerList.DunsNumber)){
                            dunsMapTemp2.put(innerList.DunsNumber, tempList);
                            allDunsDataMap.put(nextLevel, dunsMapTemp2);
                            
                        }
                        
                    }
                }
                
                
                    
            }
                
            //allDunsDataMap.remove(String.valueOf(levelCount+1));
            System.debug('allDunsDataMap final: ' + allDunsDataMap);
            
        }
        
    }


    public void parseHierarchy(XmlStreamReader reader, String s, dunsDataWrapper hierarchy) {
        reader.setCoalescing(true);
        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                if(s == 'City')
                    hierarchy.City = reader.getText();
                if(s == 'Country')
                    hierarchy.Country = reader.getText();
                if(s == 'DunsName')
                    hierarchy.DunsName = reader.getText();
                if(s == 'DunsNumber')
                    hierarchy.DunsNumber = reader.getText();
                if(s == 'HqDuns')
                    hierarchy.HqDuns = reader.getText();
                if(s == 'Level')
                    hierarchy.Level = reader.getText();
                if(s == 'PostalCode')
                    hierarchy.PostalCode = reader.getText();
                if(s == 'State')
                    hierarchy.State = reader.getText();
                if(s == 'AddressLine1')
                    hierarchy.Address = reader.getText();
                if(s == 'AddressLine2')
                    hierarchy.Address = hierarchy.Address + ' '+ reader.getText();
                if(s == 'SalesRevenue')
                    hierarchy.SalesRevenue = Decimal.valueOf(reader.getText());
                if(s == 'EmployeeSize')
                    hierarchy.EmployeeSize = reader.getText();
                if(s == 'PhoneNumber')
                    hierarchy.PhoneNumber = reader.getText();
                if(s == 'HasChildren')
                    hierarchy.HasChildren = reader.getText();    
                if(s == 'AccountType'){
                    hierarchy.AccountType = reader.getText();
                    if(hierarchy.AccountType != null){
                        if(hierarchy.AccountType == '0')
                            hierarchy.AddressLabel = System.Label.MDM_HierarchyInfo_SingleLocation;//'Address';
                        if(hierarchy.AccountType == '1')
                            hierarchy.AddressLabel = System.Label.MDM_HierarchyInfo_Headquarters;
                        if(hierarchy.AccountType == '2')
                            hierarchy.AddressLabel = System.Label.MDM_HierarchyInfo_Branch;
                        if(hierarchy.AccountType == '4')
                            hierarchy.AddressLabel = System.Label.MDM_HierarchyInfo_Subsidiary;//'Division';
                    }
                }
                if(s == 'faultcode'){
                    if(reader.getText().contains('DataPower')){
                        errorMsg = System.Label.MDM_Connection_Failure;
                        system.debug('errorMsg 597' + errorMsg);
                        displayPage = false;
                    }
                    
                }
                if(s == 'faultstring'){
                    String strTemp = reader.getText();
                    if(strTemp.contains('size')){
                        errorMsg = System.Label.MDM_Size_Limit_Error;
                    }
                    displayPage = true;
                    displayTree = false;
                    break;
                }
                if(s == 'Message'){
                    if(reader.getText() == 'No Record Found'){
                        errorMsg = System.Label.MDM_No_Record_Found;
                        displayTreeHeaders = false;
                        displayTree = false;
                    }
                    else{
                        errorMsg = System.Label.MDM_Connection_Failure;
                        system.debug('errorMsg 619' + errorMsg);
                        displayPage = false;
                    } 
                    
                    break;
                }
                if(s == 'Fault'){
                    errorMsg = System.Label.MDM_Connection_Failure;
                    system.debug('errorMsg 627' + errorMsg);
                    displayPage = false;    
                }
                
            }
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
    }
    
    /******************************END PARSING XML************************************/ 

    /******************************BEGIN WRAPPER CLASS FOR THE RESPONSE DATA************************************/  

    public class dunsDataWrapper implements Comparable{
        
        public String city {get;set;}
        public String country {get;set;}
        public String Dunsname {get;set;}
        public String DunsNumber {get;set;}
        public String HqDuns {get;set;}
        public String Level {get;set;}
        public String PostalCode {get;set;}
        public String State {get;set;}
        public String Address {get;set;}
        public Decimal SalesRevenue {get;set;}
        public String EmployeeSize {get;set;}
        public String PhoneNumber {get;set;}
        public String AccountType {get;set;}
        public String AddressLabel {get;set;}
        public String HasChildren {get;set;}
        
        
        
        public Integer compareTo(Object compareTo) {
            dunsDataWrapper dunsDataCompare = (dunsDataWrapper) compareTo;
            
            if(sortThis == 'Country'){
                if (country == dunsDataCompare.country) return 0;
                if (country > dunsDataCompare.country) return 1;
            }
            if(sortThis == 'PostalCode'){
                if (PostalCode == dunsDataCompare.PostalCode) return 0;
                if (PostalCode > dunsDataCompare.PostalCode) return 1;
            }
            return -1;        
        }
    
    }

    /******************************END WRAPPER CLASS FOR THE RESPONSE DATA************************************/ 

    /******************************BEGIN SEARCH NAVIGATION************************************/

    public PageReference goToSearchPage(){
        PageReference retUrl;
        retUrl = new PageReference('/apex/MDM_SearchDunsPage?close='+showCloseButton);
        return retUrl;
    }
    
    public void beginExport(){/*out of scope*/}
    /******************************END SEARCH NAVIGATION************************************/
}