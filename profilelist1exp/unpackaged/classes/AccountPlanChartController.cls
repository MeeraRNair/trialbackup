/***********************************************************
* Name          : AccountPlanChartController
* Description   : Controller for Business Unit Report in Account Plan
* ---------------------------------------------------------
* Revision  Name                Date             Description
* 1.0       Goldy Raj           9.Dec.2019    Story 7540275:Account Planning: Strategy Business Unit Component High Impact(Vikings)
* 1.1   Srinivasarao Mandalapu  9.Dec 2019    Story 7540279:Account Planning: Strategy Transformation Component High Impact 
* 1.2   Hemalatha Baskaran      12 Dec 2019   Story 7540277: Account Planning: Strategy Unweighted Revenue Component High Impact
************************************************************/

global without sharing class AccountPlanChartController {
    public Static String yField { get; set; }
    public static List<ProductChartData> lstProductChartData {get;set;}
    public static Map<Id,String> mapProductTypes;    
    public static string productValues {get;set;}
    public static string urlforvf{get;set;}
    
    
    @AuraEnabled
    public static Id getAccountId(Id recordId)
    {
        Id account;
        SFDC_Acct_Plan__c accPlan=[select id,Account__c from SFDC_Acct_Plan__c where Id=:recordId];
        account=accPlan.Account__c ;
        return account;
        
    }
    @AuraEnabled
    public static String getStrategyStatus(Id recordId)
    {
        String status;
        SFDC_Strategy__c strategy=[SELECT Id,Strategy_Status__c FROM SFDC_Strategy__c where Id=:recordId];
        status=strategy.Strategy_Status__c ;
        return status;
        
    }
    @AuraEnabled
    public static Map<String,Integer> getTranformationPillarValues(Id accountPlanId)
    {
        Map<String,Integer> mapTransformations = new Map<String,Integer>();
        
        Integer iValueCount;
        Integer iTotalStrategy;
        String strValue;
        
        try{       
            //get All Strategy associated with Account Plan.
            List<SFDC_Strategy__c> lstStrategyRecs=[SELECT Id,Transformation__c FROM SFDC_Strategy__c WHERE SFDC_Acct_Plan__c=: accountPlanId];
            iTotalStrategy=lstStrategyRecs.size();
            
            //Get only active picklist values from Strategy Object > Transformation feild > picklist values.        
            List<Schema.PicklistEntry> activeItems = SFDC_Strategy__c.Transformation__c.getDescribe().getPicklistValues();
            
            //Loop through transformation picklist values and count strategy agianst each Transfrormation type.
            for(Schema.PicklistEntry ple:activeItems)
            {
                strValue =ple.getValue();
                iValueCount=0;
                
                //Calculate tranformation value count.
                for(Integer i=0; i<iTotalStrategy; i++)
                {               
                    if((lstStrategyRecs[i].Transformation__c!='')
                       && (lstStrategyRecs[i].Transformation__c!=null)
                       && (lstStrategyRecs[i].Transformation__c.contains(strValue)))
                    {
                        iValueCount++;
                    }
                }
                //Add Transformation Type and No.Of Strategy
                mapTransformations.put(strValue,iValueCount);           
            }
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
            
        }
        
        return mapTransformations;
    }   
    
    @RemoteAction
    global static Map<String,Integer> BusinessUnitControllerFetchStrategy(String urlfecthed) {
        
        String recordId;
        if(Test.isRunningTest()){
            recordId=urlfecthed;
        }
        else{
            recordId=urlfecthed.substring(urlfecthed.length() - 18);
        }
        String jsonStringreturn;
        Map<String,Integer> mapofBU=new Map<String,Integer>();
        try{
            Integer count =0;
            Schema.DescribeFieldResult fieldsofBU = SFDC_Strategy__c.Which_LOB_will_you_offer__c.getDescribe();
            List<Schema.PicklistEntry> pickVals = fieldsofBU.getPicklistValues();
            
            
            for(Schema.PicklistEntry picklist1:pickVals){
                mapofBU.put(picklist1.getLabel(), 0);
                
            }
            
            List<SFDC_Strategy__c> strategyList =[SELECT Id,Which_LOB_will_you_offer__c,SFDC_Acct_Plan__c,Name FROM SFDC_Strategy__c where SFDC_Acct_Plan__c=:recordId ];
            
            for(SFDC_Strategy__c strategy:strategyList){
                if(strategy.Which_LOB_will_you_offer__c!=null){
                    
                    List<String> productoffering=strategy.Which_LOB_will_you_offer__c.split(';');
                    
                    for(String product:productoffering){
                        
                        if(mapofBU.keySet().contains(product))
                        {
                            
                            count = mapofBU.get(product);
                            mapofBU.put(product, ++count);
                        }
                    }
                }
            }
            
            
        }
        
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
            
        }
        return mapofBU;
    }
    
    //Get the Rolling Quartes of previous,current and 6 upcoming quartes a head
    public static List<String> getAllRollingQuarters(){
        try
        {
            //Getting the current quarter,Start Date,End Date using today
            List<String> FYQuarterList = new List<String>();
            List<Fiscal_Years__c> currentQuarter = [select Name,Start_Date__c from Fiscal_Years__c where Start_Date__c <= today order by Name desc limit 1];
            //Get the start date from the current quarter and subract one from the start date and get all the related records
            Date currentQuarterStartDate = (currentQuarter[0].Start_Date__c).addDays(-1);
            String StartDate = Datetime.newInstance(currentQuarterStartDate.year(), currentQuarterStartDate.month(), currentQuarterStartDate.day()).format('yyy-MM-dd');
            List<Fiscal_Years__c> rollingQuarter = [select Name from Fiscal_Years__c where (End_Date__c >= today or End_Date__c = :currentQuarterStartDate) order by Name asc limit 8];
            for(Fiscal_Years__c quarterName : rollingQuarter)
            {
                FYQuarterList.add(quarterName.Name);
            }
            return FYQuarterList;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
        
    }    
    
    public static Map<Id,String> getProductTypes()
    {
        return mapProductTypes;
    }
    
    // Story: 7540277
    // This function is used to get Account Plan stack chart to show Products with Total Price by rolling qurters. 
    // X-Axis: will be CurrentQtr-1, Current Qtr, Ahead 6 Qrts.
    // Y-Axis: Total Price
    // Stacked on Product Types
    // This function returns the FYqtrs and associated ProductType Totalprice.
    public static Map<String,List<Double>> getProdTypeQuarterValues(Id accPlanId)
    {
        Set<Id> oppIds=new Set<Id>();
        Set<String> setProdTypes=new Set<String>();
        List<String> lstProdTypes=new List<String>();
        List<String> fyQrt;
        List<OpportunityLineItem> lstOppLineItm;
        Map<String,List<Double>> mapProdTotal=new Map<String,List<Double>>();
        Map<String,Map<String,Double>> FYmap=new Map<String,Map<String,Double>>();
        List<Double> lstPrice;        
        String strFYQ;
        Integer indexProd=-1;
        Integer prodSize=0;
        Integer qtrLength=0;
        List<double> lstProdPrice;
        Map<String,Double> prodTypemap;
        Double price;
        
        try {
            //Get Associated Account from Acc PLan.
            SFDC_Acct_Plan__c accPlan=[SELECT Account__c FROM SFDC_Acct_Plan__c WHERE Id=:accPlanId LIMIT 1];
            Id accId=accPlan.Account__c;
            List<Opportunity> lstOpp=[SELECT Id,Name,Fiscal_Book_Date__c,(SELECT Line_Item_ID__c,Product_Type__c,TotalPrice,OpportunityId FROM OpportunityLineItems ) 
                                      FROM Opportunity 
                                      WHERE AccountId=:accId AND StageName IN('Plan - 1%','Discover - 10%','Qualify - 30%','Propose - 60%','Commit - 90%','Order Submitted - 99%')];
            fyQrt=getAllRollingQuarters(); 
           
            lstOppLineItm=new List<OpportunityLineItem>();
            
            
            for(Opportunity opp:lstOpp){
               
                for(OpportunityLineItem ol:opp.OpportunityLineItems){

                    if(ol.Product_Type__c!=null){
                   
                        setProdTypes.add(ol.Product_Type__c);
                      
                        String quaterdate=opp.Fiscal_Book_Date__c.left(7).replace(' ','');
                        
                        if(fyQrt.contains(quaterdate) ){
                          
                            if(FYmap.containsKey(quaterdate)){
                                prodTypemap=FYmap.get(quaterdate);
                                if(prodTypemap!=null)
                                {
                                   
                                    if(prodTypemap.containsKey(ol.Product_Type__c)){
                                        price=0;
                                     
                                        price=prodTypemap.get(ol.Product_Type__c);
                                    
                                        price=price+ol.TotalPrice;
                                        prodTypemap.put(ol.Product_Type__c,price);
                                      
                                    }
                                    else
                                    {                                        
                                                                           
                                        prodTypemap.put(ol.Product_Type__c, ol.TotalPrice);                                       
                                        //FYmap.get(quaterdate).value=prodTypemap;
                                        FYmap.put(quaterdate,prodTypemap);
                                      
                                    }
                               }
                            }
                            else{
                                
                                prodTypemap=new Map<String,Double>();
                             
                                prodTypemap.put(ol.Product_Type__c, ol.TotalPrice);
                                FYmap.put(quaterdate,prodTypemap);
                            
                            }
                            
                        }
                        
                        
                    }
                }
                
            }
           
            
            //Add products to list;
            lstProdTypes.addAll(setProdTypes);
            lstProdTypes.sort();
            prodSize=setProdTypes.size();
            
            qtrLength=fyQrt.size();
            //Prepare Map of AccId with Product Types to be used by chart Title.
            mapProductTypes= new Map<Id,String>();
            mapProductTypes.put(accPlanId,String.join(lstProdTypes,','));
            for(Integer i=0; i<qtrLength; i++)
            {
                lstPrice=new List<Double>();
                for(Integer j=0; j<prodSize;j++)
                {
                    lstPrice.add(0);
                }
                mapProdTotal.put(fyQrt[i],lstPrice);
            }
         
            for(String quat:fyQrt){
                if(FYmap.containsKey(quat)){
                     lstProdPrice=mapProdTotal.get(quat);
                 
                  Map<String,Double> mapVal=FYmap.get(quat);
                 if(lstProdTypes!=null){
                     for(String prodTy:lstProdTypes){
                     
                         if(mapVal.containsKey(prodTy)){
                             
                                 indexprod=lstProdTypes.indexOf(prodTy);
                            
                             	 if(indexprod >=0){
                                    lstProdPrice[indexprod]=mapVal.get(prodTy);
                                
                                } 
                         }
                     }
                 }
                    
                }
            }
           
            system.debug('final mapProdTotal'+mapProdTotal); 
        } 
        catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
     
        return mapProdTotal;
        
    }
    
    public static void productTypeChartData(String accId) 
    {
        try{
            Integer keyRow = 0;
            Integer keyValues = 1;
            Integer countElement = 0;
            lstProductChartData = new List<ProductChartData>();
            List<String> yfieldsArray = new List<String>();
            Map<string,List<Double>> productTotalPrice = getProdTypeQuarterValues(accId);
            Map<Id,string> mapProdTypes = getProductTypes();
            if(mapProdTypes!=null){
                productValues =  mapProdTypes.get(accId);
            }
            
            for(string key : productTotalPrice.keyset()){
                //Map the value as key and list<Double>
                lstProductChartData.add(new ProductChartData(key, productTotalPrice.get(key)));
                //Mapping the values for the legend data
                if(keyRow == 0){
                    countElement = productTotalPrice.get(key).size();
                    for(Double productValues : productTotalPrice.get(key)){
                        if(keyValues <= countElement){
                            yfieldsArray.add('data'+keyValues);
                            keyValues++;
                        }
                    }
                }
                keyRow++;
            }
            yField = String.join(yfieldsArray,',');
        }catch(Exception e){
            system.debug('Error in following'+e.getMessage());
        }
    }
    public string callfunc{get;set;}
    
    public pagereference productPipelineTotalPrice(){
        String accId = apexpages.currentpage().getparameters().get('recordId');
        AccountPlanChartController.productTypeChartData(accId);
        
        String headerData=URL.getSalesforceBaseUrl().toExternalForm().split('\\.')[0]; 
        urlforvf=headerData.toLowerCase()+'.lightning.force.com';
        callfunc='<script> spinnerdisplay(); </script>';
        return null;
    }
    
    // Wrapper class
    public class ProductChartData {
        public String name { get; set; }
        public List<Double> numbers { get; set; }
        public ProductChartData(String name, List<Double> numbers ) {
            this.name = name;
            this.numbers  = numbers;
        }
    } 
  
}