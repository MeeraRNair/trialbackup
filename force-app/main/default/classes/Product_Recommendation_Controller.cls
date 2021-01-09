/*
History:
Revision CR Number   Release No      Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0 -    CR#14877 -  FY18DCS-1001 -  05 SEP 2017     Naga         -  Changed code for recommendations has to sort by businessrank.
2.0 -    CR#14878 -  FY18DCS-1001 -  05 SEP 2017     Azlan        -  Added CustomerType to identify if its a Channel or Direct Account (Line# 107 & 269)
3.0 -    CR#16710 -  FY19DCS-0102 -  18 OCT 2018     Shue         -  STORY 5632324EAP SFDC Reporting
4.0 -    CR18351  -  FY20-0102	  -	 10 Dec 2019	 Anil		  -  Changes in Recommended Product UI- Enabling user for selection of fields from the VF page
*/
global class Product_Recommendation_Controller{

    //Global Variables
    public List<recommendationWrapper> lstData {get;set;}
    private string oneElement;
    private string strKey;
    private string strValue;
    private Set<String> checkTags{get;set;}
    private Octane_Config_Settings__c config{get;set;}
    public OpportunityLineItem objOli{get;set;}
    public Boolean isCallout{get;set;}
    public Boolean bIsCommonCatalog{get;set;}
    public List<Pricebook2> listObjCatalog{get;set;}
    public Opportunity objOpp{get;set;}
    Map<String,Product2> mapOfPimToProd = new Map<String,Product2>();
	Map<String, PriceBookEntry> mapOfProdToPriceBook = new Map<String,PriceBookEntry>();
	public List<OpportunityLineItem> listOfOli = new List<OpportunityLineItem>();
    
    public Product_Recommendation_Controller(){
      lstData = new List<recommendationWrapper>();
      isCallout = false;
    }
    
    public void init(){
        if(apexpages.currentpage().getparameters().get('id') != null){
            queryRequestData(apexpages.currentpage().getparameters().get('id'));
        }
        config = fetchConfigSettings();
        
        if(config != null){
            //3.0 Take out checking on config.Enable_Disable_Group_Access__c)
            if(lstData.size() == 0){
                string strResponse  = makeRequestToOctane();
                if(strResponse != null){
                    parseResponseDataFromOctane(strResponse);
                    trackFunctionalityUsage(UserInfo.getUserId(),apexpages.currentpage().getparameters().get('id'));
                }else{
                    //Throw Error Here
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Octane is currently unavailable. Please try again in few minutes.'));
                }
            }
        }
    }
    
    //Method to make callout to Octane.
    public String makeRequestToOctane(){
        Http objReq = new Http();
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(config.User_Name__c + ':' + config.Password__c);
        String authorizationHeader = 'Basic  ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setendpoint(config.Endpoint__c);
        req.setmethod('POST');
        System.Debug('request##'+prepareRequestBodyForOctane());
        req.setbody(prepareRequestBodyForOctane());
        HttpResponse objRes;
        isCallout = false;
        try{
            for(Integer i=0;i<10;i++){       
              if(!Test.isRunningTest()){
                    objRes = objReq.send(req);
                }
                else{
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/xml');
                    res.setBody('<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"><env:Body><res xmlns="http://www.sigmadynamics.com/schema/services/DecisionService"><sa><kv><k>type</k><v>DCP</v></kv><kv><k>skuChoiceId</k><v>1472542215260</v></kv><kv><k>sku</k><v>310-9080</v></kv><kv><k>skuDesc</k><v>6-Cell Lithium-Ion Primary Battery from Dell</v></kv><kv><k>orderCd</k><v/></kv><kv><k>compatibleFlag</k><v>Y</v></kv><kv><k>propensityRank</k><v>1</v></kv><kv><k>businessRank</k><v>1</v></kv><kv><k>shipsWith</k><v>false</v></kv><kv><k>url</k><v>http://snpi.dell.com/snp/images/products/mlrg/en-us~310-9080/310-9080.jpg</v></kv><kv><k>propensityScore</k><v>0.03013183666803879</v></kv><kv><k>reason</k><v>Model Prediction</v></kv><kv><k>inputOrderCd</k><v/></kv><id>DCPOffersByProductVariantCG$310-9080</id></sa><sa><kv><k>type</k><v>DCP</v></kv><kv><k>skuChoiceId</k><v>1472542215305</v></kv><kv><k>sku</k><v>430-2999</v></kv><kv><k>skuDesc</k><v>Dell Wireless 1395 802.11b/g PCI Express Mini Card</v></kv><kv><k>orderCd</k><v/></kv><kv><k>compatibleFlag</k><v>Y</v></kv><kv><k>propensityRank</k><v>3</v></kv><kv><k>businessRank</k><v>1</v></kv><kv><k>shipsWith</k><v>false</v></kv><kv><k>url</k><v>http://snpi.dell.com/snp/images/products/mlrg/en-us~430-2999/430-2999.jpg</v></kv><kv><k>propensityScore</k><v>0.5330276277112476</v></kv><kv><k>reason</k><v>Model Prediction</v></kv><kv><k>inputOrderCd</k><v/></kv><id>DCPOffersCG$430-2999</id></sa><sa><kv><k>returnCode</k><v>0</v></kv><kv><k>returnStatus</k><v>Choices returned successfully!!!</v></kv><id>Status</id></sa><v><a>2017</a><c>1</c></v></res></env:Body></env:Envelope>');
                    res.setStatusCode(200);
                    res.setStatus('OK');
                    objRes = res;
                }
                if(objRes.getStatus() == 'OK' && objRes.getStatusCode() == 200){
                   isCallout = true;
                   break;
                }
            }   
            if(isCallout){
                return objRes.getbody();
            }
            else{
                return null;
            }           
        }
        catch(Exception ex){
            return null;
        }
    }

    //Method to prepare request Body.
    public String prepareRequestBodyForOctane(){
       String strVal;
       Map<String, Octane_Customer_Set_ID__c> mapofCustomerSetId = new Map<String, Octane_Customer_Set_ID__c>(Octane_Customer_Set_ID__c.getAll());
       for(Octane_Customer_Set_ID__c obj : mapofCustomerSetId.values()){
           if(obj.Country_Code__c.Contains(objOli.Opportunity.Account.Account_Country_Code__c)){
              strVal = obj.Customer_Set_ID__c;                             
           }
       } 
       /*Map<String,String> mapRequest = new Map<String,String>{'application'=>'SFDC','country'=>objOli.Opportunity.Account.Account_Country_Code__c !=null?objOli.Opportunity.Account.Account_Country_Code__c:'US','customerSetId'=>'04','language'=>objOli.Opportunity.Owner.LanguageLocaleKey !=null?objOli.Opportunity.Owner.LanguageLocaleKey.substring(0,2).toUpperCase():'EN','productBrand'=>objOli.Product2.Product_Line_Desc__c !=null?objOli.Product2.Product_Line_Desc__c:'LATITUDE','productLOB'=>objOli.Product2.Description !=null?objOli.Product2.Description:'LATITUDE','sfdcAccountId'=>objOli.Opportunity.Account.Id !=null?objOli.Opportunity.Account.Id:'0037000000cN9v3AAC','opportunityID'=>objOli.OpportunityId !=null?objOli.OpportunityId:'','systemQuantity'=>String.valueOf(objOli.Quantity),'customerType'=>objOli.Opportunity.Account.RecordType.Name !='End-User Account'?'CHANNEL':'DIRECT'};*/
       Map<String,String> mapRequest = new Map<String,String>{'application'=>'SFDC','country'=>objOli.Opportunity.Account.Account_Country_Code__c !=null?objOli.Opportunity.Account.Account_Country_Code__c:'','customerSetId'=> strVal,'language'=>objOli.Opportunity.Owner.LanguageLocaleKey !=null?objOli.Opportunity.Owner.LanguageLocaleKey.substring(0,2).toUpperCase():'EN','productBrand'=>objOli.Product2.Product_Line_Desc__c !=null?objOli.Product2.Product_Line_Desc__c:'','productLOB'=>objOli.Product2.Description !=null?objOli.Product2.Description:'','sfdcAccountId'=>objOli.Opportunity.Account.Account_ID__c !=null?objOli.Opportunity.Account.Account_ID__c:'','opportunityID'=>objOli.OpportunityId !=null?objOli.OpportunityId:'','systemQuantity'=>String.valueOf(objOli.Quantity),'customerType'=>objOli.Opportunity.Account.RecordType.Name !='End-User Account'?'CHANNEL':'DIRECT'};
       String requestBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dec="http://www.sigmadynamics.com/schema/services/DecisionService"><soapenv:Header/><soapenv:Body><dec:invoke><dec:is><dec:n>SALESAPP</dec:n><dec:ds>Production</dec:ds></dec:is><dec:req>';
       requestBody +='<dec:sk><dec:k>sessionID</dec:k><dec:v>7dc53df5-703e-49b3-8670-b1c468fysdf</dec:v><dec:ar>?</dec:ar></dec:sk>';
        for(String str:mapRequest.keyset()){
            requestBody +='<dec:at>';
            requestBody +='<dec:k>'+str+'</dec:k>';
            requestBody +='<dec:v>'+mapRequest.get(str)+'</dec:v>';
            requestBody +='<dec:ar>?</dec:ar>';
            requestBody +='</dec:at>';
        }
        requestBody +='<dec:ip>GetBestOnlineOffers</dec:ip><dec:as>?</dec:as><dec:l><dec:l>?</dec:l><dec:c>?</dec:c></dec:l><dec:tr>?</dec:tr></dec:req></dec:invoke></soapenv:Body></soapenv:Envelope>';
        return requestBody;
    }

    //Wrapper class to collect Octane Data
    global class recommendationWrapper implements Comparable{
        public string type{get;set;}
        public string skuChoiceId{get;set;}
        public string sku{get;set;}
        public string skuDesc{get;set;}
        public string orderCd{get;set;}
        public string compatibleFlag{get;set;}
        public string propensityRank{get;set;}
        public string businessRank{get;set;}
        public string shipsWith{get;set;}
        public string url{get;set;}
        public string propensityScore{get;set;}
        public string reason{get;set;}
        public string inputOrderCd{get;set;}
        public decimal dcUnitPrice{get; set;}
        public decimal dcQuantity{get; set;}
        public boolean bIsChecked{get; set;}
        public string strSfdcProductCode{get; set;}
        public boolean bProductPresent{get; set;}
        public OpportunityLineItem oli{get; set;}
        
        public recommendationWrapper(String obj){
            this.type = (obj.containsIgnoreCase('type')?obj.substringBetween('<type>','</type>'):'');
            this.skuChoiceId = (obj.containsIgnoreCase('skuChoiceId')?obj.substringBetween('<skuChoiceId>','</skuChoiceId>'):'');
            this.sku = (obj.containsIgnoreCase('sku')?obj.substringBetween('<sku>','</sku>'):'');
            this.skuDesc = (obj.containsIgnoreCase('skuDesc')?obj.substringBetween('<skuDesc>','</skuDesc>'):'');
            this.orderCd = (obj.containsIgnoreCase('orderCd')?obj.substringBetween('<orderCd>','</orderCd>'):'');
            this.compatibleFlag = (obj.containsIgnoreCase('compatibleFlag')?obj.substringBetween('<compatibleFlag>','</compatibleFlag>'):'');
            this.propensityRank = (obj.containsIgnoreCase('propensityRank')?obj.substringBetween('<propensityRank>','</propensityRank>'):'');
            this.businessRank = (obj.containsIgnoreCase('businessRank')?obj.substringBetween('<businessRank>','</businessRank>'):'');
            this.shipsWith = (obj.containsIgnoreCase('shipsWith')?obj.substringBetween('<shipsWith>','</shipsWith>'):'');
            this.url = (obj.containsIgnoreCase('skuUrl')?obj.substringBetween('<skuUrl>','</skuUrl>'):'');
            this.propensityScore = (obj.containsIgnoreCase('propensityScore')?obj.substringBetween('<propensityScore>','</propensityScore>'):'');
            this.reason = (obj.containsIgnoreCase('reason')?obj.substringBetween('<reason>','</reason>'):'');
            this.inputOrderCd = (obj.containsIgnoreCase('inputOrderCd')?obj.substringBetween('<inputOrderCd>','</inputOrderCd>'):'');
            this.strSfdcProductCode = (obj.containsIgnoreCase('sfdcProductCode')?obj.substringBetween('<sfdcProductCode>','</sfdcProductCode>'):'');
            this.oli = new OpportunityLineItem();
            this.bProductPresent = true;
			this.bIsChecked = false;
        }
        
        /*public recommendationWrapper(String obj){
            this.type = 'Test Type';
            this.skuChoiceId = 'Test Sku Choice';
            this.sku = 'Test Sku';
            this.skuDesc = 'Test Sku Desc';
            this.orderCd = 'Test Order Cd';
            this.compatibleFlag = 'Test Flag';
            this.propensityRank = 'Test Prosperity';
            this.businessRank = 'Test Business';
            this.shipsWith = 'Test Ship';
            this.url = 'www.google.com';
            this.propensityScore = 'Test Score';
            this.reason = 'Test Reason';
            this.inputOrderCd = 'Test Input';
            this.strSfdcProductCode = 'Test PC';
            this.oli = new OpportunityLineItem();
            this.bProductPresent = false;
        }*/
        
        //1.0 - Naga - Changed sorting order from propensityRank to businessRank.
        global Integer compareTo(Object compareTo) {
            recommendationWrapper compareToEmp = (recommendationWrapper)compareTo;
            if (Integer.valueOf(this.businessRank) == Integer.valueOf(compareToEmp.businessRank)) return 0;
            if (Integer.valueOf(this.businessRank) > Integer.valueOf(compareToEmp.businessRank)) return 1;
            return -1;
        }
    }

    //Method to Parse XML response received from Octane
    public List<recommendationWrapper> parseResponseDataFromOctane(String xmlstring){      
        checkTags = new Set<String>();
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(xmlstring);
        for(DOM.XMLNode xmlnodeobj:xmlDOC.getRootElement().getChildElements()){       
            parseChildNodes(xmlnodeobj);        
        }
        System.debug('***Common:'+bIsCommonCatalog);
        mapOfPimToProd = new Map<String,Product2>();
		System.debug('**## In parseResponseDataFromOctane before:'+Limits.getQueries());
        if(bIsCommonCatalog == true)
        {
            List<String> listOfStr = new List<String>();
            for(recommendationWrapper rw:lstData)
            {
                listOfStr.add(rw.strSfdcProductCode);
            }
            System.debug('***List:'+listOfStr);
            List<Product2_PIM_Mapping__c> listOFPIM = [Select SFDC_Prod_ID__c,Classcode_Prod_Offer_Code__c from Product2_PIM_Mapping__c where Classcode_Prod_Offer_Code__c IN: listOfStr];
            List<Id> listOfId = new List<Id>();
            for(Product2_PIM_Mapping__c pim:listOFPIM)
            {
                listOfId.add(pim.SFDC_Prod_ID__c);
            }
			PriceBook2 pb = [Select Id from PriceBook2 where Name = 'Common Catalog'];
            Map<Id,Product2> mapOfProduct = new Map<Id,Product2>([Select Id,IsActive from Product2 where Id IN: listOfId]);
			Map<Id,PriceBookEntry> mapOfEntry = new Map<Id,PriceBookEntry>([Select Id,Product2Id from PriceBookEntry where Product2Id IN:mapOfProduct.keyset() AND PriceBook2Id =: pb.Id AND CurrencyIsoCode =: objOpp.CurrencyIsoCode AND IsActive = true]);
			
			for(PriceBookEntry pbe:mapOfEntry.values())
			{
				mapOfProdToPriceBook.put(pbe.Product2Id,pbe);
			}
			
            for(Product2_PIM_Mapping__c prodPim:listOFPIM)
            {
                Product2 prod = mapOfProduct.get(prodPim.SFDC_Prod_ID__c);
                mapOfPimToProd.put(prodPim.Classcode_Prod_Offer_Code__c,prod);
            }
            
            System.debug('***Map:'+mapOfPimToProd);
            
            for(recommendationWrapper rw:lstData)
            {
                System.debug('***Product code:'+rw.strSfdcProductCode);
                System.debug('***Contains:'+mapOfPimToProd.containsKey(rw.strSfdcProductCode));
                Product2 prod = mapOfPimToProd.get(rw.strSfdcProductCode);
                if(mapOfPimToProd.containsKey(rw.strSfdcProductCode) && mapOfProdToPriceBook.containsKey(prod.Id) && prod.IsActive == true)
				{
                    rw.bProductPresent = false;
				}
            }
        }
        System.debug('**## In parseResponseDataFromOctane after:'+Limits.getQueries());
        lstData.sort();
        return lstData;
    }

    //Parse Through the child elements
    private void parseChildNodes(DOM.XMLNode xmlnode){  
        for(Dom.XMLNode child : xmlnode.getChildElements()){           
            System.Debug('###child.getName()'+child.getName());
            if(child.getName() == 'sa'){
                if(!checkTags.contains('sa')){
                    checkTags.add('sa');
                }
                else{
                    System.Debug('oneElement$$$'+oneElement);
                    lstData.add(new recommendationWrapper(oneElement));
                    System.Debug('lstData$$$'+lstData);
                    oneElement = '';
                }
            }
            if(child.getName() == 'k' || child.getName() == 'v'){
                if(child.getName() == 'k'){
                    if(child.getText() != ''){
                        strKey = child.getText();
                    }   
                }
                System.Debug('###strKey'+strKey);
                if(child.getName() == 'v'){
                    if(child.getText() != ''){
                        strValue = child.getText();
                    }
                }
                System.Debug('###strValue'+strValue);
                if(oneElement == null){
                    if(strKey != '' && strKey != null && strValue != '' && strValue != null){
                        oneElement = '<'+strKey+'>'+strValue+'</'+strKey+'>'+';';
                        strKey ='';
                        strValue = '';
                    }
                }
                else{
                    if(strKey != '' && strKey != null && strValue != '' && strValue != null){
                        oneElement +='<'+strKey+'>'+strValue+'</'+strKey+'>'+';';
                        strKey ='';
                        strValue = '';
                    }
                }
                System.Debug('###oneElement'+oneElement);
            }
            parseChildNodes(child);             
        }
    }

    //Method to check if User has Access To Page
    public Boolean lookUpUserAccess(ID userId){
        Set<ID> allGroupIDs = new Set<ID>();
        for (GroupMember gm : [SELECT Id, group.name, UserOrGroupId  FROM GroupMember where group.name = 'Octane User Group' and UserOrGroupId =:userId]){
            allGroupIDs.add(gm.UserOrGroupId);
        }
        System.Debug('###allGroupIDs'+allGroupIDs);
        return (allGroupIDs.size() > 0?true:false);
    }
    //Method for Environment Check
    public static Boolean runningInASandbox() {
      return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    //Method to retrieve Config Values For Octane Integration Based on Environment.
    public static Octane_Config_Settings__c fetchConfigSettings(){
        String enviroment;
        if(runningInASandbox()){
            enviroment = 'Sandbox';
        }
        else{
            enviroment = 'Production';
        }   
        Octane_Config_Settings__c objConfig = Octane_Config_Settings__c.getValues(enviroment);
        return objConfig;
    }
    //Method to track user name and time when he clicked on the product recommendation button.
    public void trackFunctionalityUsage(String strUserId, String oliId){
        OpportunityLineItem oli = new OpportunityLineItem(Id=apexpages.currentpage().getparameters().get('id'));
        oli.EAP_User__c = strUserId;
        oli.EAP_Date__c = System.Now();
        oli.Recommended_Products_Viewed__c = true;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        try{
            update oli;
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
    }
    //Method to query the mapping fields for preparing Request
    public void queryRequestData(string oliId){
        if(oliId != null){
            objOli = [Select Id,Product2.Id,Product2.Name,Product2.Description,Product2.Product_Line_Desc__c,OpportunityId,Opportunity.Account.Id,Opportunity.Account.Account_ID__c,Opportunity.Account.Name,Opportunity.Owner.LanguageLocaleKey,Opportunity.Account.Account_Country_Code__c,Quantity,Opportunity.Account.RecordType.Name FROM OpportunityLineItem Where Id=:oliId];
            System.debug('**## In queryRequestData before:'+Limits.getQueries());
            objOpp = [Select Id,PriceBook2Id,CurrencyIsoCode from Opportunity Where Id=:objOli.OpportunityId];
			System.debug('###Price book id:'+objOpp.PriceBook2Id);
            if(objOpp.PriceBook2Id != null){
                listObjCatalog = new List<PriceBook2>([Select Id, Name, IsActive from PriceBook2 Where Id=:objOpp.PriceBook2Id]);
                if(listObjCatalog.size() > 0 && listObjCatalog.get(0).Name == 'Common Catalog'){
                    bIsCommonCatalog=true;
                }else{
                    bIsCommonCatalog=false;
                }               
            }       
        }
		System.debug('**## In queryRequestData after:'+Limits.getQueries());
        System.debug('***Common Catalog:'+bIsCommonCatalog);
    }
    
    public PageReference createOli()
    {
        boolean bFlag = false;
        boolean bCheckedFlag = false;
        listOfOli = new List<OpportunityLineItem>();
		System.debug('**## In createOli before:'+Limits.getQueries());
        for(recommendationWrapper rw:lstData)
        {
            if(rw.bIsChecked)
            {
                if(rw.dcUnitPrice == 0 || rw.dcQuantity == 0 || rw.oli.Service_Support_US__c == null)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter value for Unit Price,Quantity and Service/Support'));
                    bFlag = true;
                    return null;
                }
                bCheckedFlag = true;
            }
            
        }
        if(!bCheckedFlag)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select one or more product to save your changes'));
            return null;
        }
        if(!bFlag)
        {
			Product2 prod;
			PriceBookEntry pbe;
            for(recommendationWrapper rw:lstData)
            {
				if(rw.bIsChecked)
				{
					System.debug('Product code:'+rw.strSfdcProductCode);
					prod = mapOfPimToProd.get(rw.strSfdcProductCode);
					if(prod != null)
					{
						pbe = mapOfProdToPriceBook.get(prod.Id);
					}
					OpportunityLineItem oli = new OpportunityLineItem();
					oli.Order_Code__c = rw.sku;
					if(prod != null)
					{
						oli.Product2Id = prod.Id;
					}
					oli.UnitPrice = rw.dcUnitPrice;
					oli.Quantity = rw.dcQuantity;
					if(pbe != null)
					{
						oli.PricebookEntryId = pbe.Id;
					}
					oli.OpportunityId = objOli.OpportunityId;
					oli.Service_Support_US__c = rw.oli.Service_Support_US__c;
					oli.Dell_Business_Model__c = rw.oli.Dell_Business_Model__c;
					listOfOli.add(oli);
					System.debug('OLI:'+oli.Quantity);
				}
            }
        }
		try
		{
			if(listOfOli.size() > 0)
			{
				insert listOfOli;
			}
		}
		catch(Exception e)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save'));
			return null;
		}
		System.debug('**## In createOli after:'+Limits.getQueries());
		return this.cancel();
    }
	
	public PageReference cancel() 
	{
		PageReference oppPage = new ApexPages.StandardController(objOpp).view();
        oppPage.setRedirect(true);
        return oppPage;
    }

}