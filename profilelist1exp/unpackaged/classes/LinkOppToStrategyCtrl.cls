/***********************************************************
* Name          : LinkOppToStrategyCtrl
* Description   : Controller class for LinkOppToStrategy page
* ---------------------------------------------------------
* Revision   Release       Name           Date              Description   
* 1.0        R15.07        Jessie Tan     23-May-2014       To Link Existing Opportunity to Strategy
* 2.0        R15.07        Kokila         03-Jul-2014       Code added for skipping all the opportunity related triggers when doing an Opportunity update
* 3.0        R15.07        Kokila         11-Jul-2014       Defect 111469. To display validation rule error messages on Link Existing Opportunity Page
* 4.0        R15.10        Jessie Tan     03-Nov-2014       CR10590 - to remove the code of skipping the opp trigger when linking the opp to strategy (from strategy)
* 5.0        FY18-DCS-0802 Syidah         12-Jun-2017       CR14509 - Added "Order Submitted - 99%" picklist value under StageName
************************************************************/
public class LinkOppToStrategyCtrl{

    public String errorMessage { get; set; }
    public String strategyId {get;set;}
    private String queryString;
    public Id accId {get;set;}
    public String accName {get;set;}
    public Integer noOfRecords {get;set;}
    //public boolean canProceed = true;       
    public Final static Integer PAGE_SIZE = 20;
    public String selectedOppId {get;set;}
    public boolean showError {get;set;}
    
    //CR14509
    public OWD__c owd = OWD__c.getOrgDefaults(); 
    
    public class OppWrapper{
        public Opportunity opp {get;set;}
        public String getFormattedLastModifiedDate(){
            return this.opp.LastModifiedDate.format();
        }
        public String getFormattedCloseDate(){
            return this.opp.CloseDate.format();
        } 
        public OppWrapper( Opportunity opp){
            this.opp = opp;
        }           
    }
    
    /*public boolean getCanProceed(){        
        return canProceed;    
    }*/
    
    public integer getOppListCount(){
        return (componentRecords.getRecords()==null)?0:componentRecords.getRecords().size();          
    }
        
    public List<OppWrapper> getOppList(){    
        
        List<Opportunity> currentOppList = (List<Opportunity>)componentRecords.getRecords();
        List<OppWrapper> currentOppWrapperList = new List<OppWrapper>();
        
        for (Opportunity opp : currentOppList ){
            currentOppWrapperList.add(new OppWrapper(opp));        
        }
        
        return currentOppWrapperList;
               
    }
     
    public void getParameters(){    
        strategyId =  ApexPages.currentPage().getParameters().get('strategyId');          
    }
    
    public LinkOppToStrategyCtrl() {
    
        try{
           showError = false;
            System.debug('### Run Controller');
            getParameters();    
            getAccountInfo();  
            constructQueryString();     
                   
        }catch(Exception e){
            handleError(e);            
        }
        
    }
    Set<string> setStr = new Set<string>();
    Set<string> setProdType = new Set<string>();
    Set<string> setProdGrp = new Set<string>();    
    public void getAccountInfo(){
        Map<String, StrategyandOppValues__c> mapStrProd = new Map<String, StrategyandOppValues__c>(StrategyandOppValues__c.getAll());
        SFDC_Strategy__c strategy = [Select SFDC_Acct_Plan__r.Account__c, Account_Name__c,What_BU_s_are_involved__c,Which_LOB_will_you_offer__c from SFDC_Strategy__c where Id = :strategyId];        
        accId = strategy.SFDC_Acct_Plan__r.Account__c;
        accName = strategy.Account_Name__c; 
        if(strategy.What_BU_s_are_involved__c != null){        
            setStr.addAll(strategy.What_BU_s_are_involved__c.split(';'));
        }
        if(strategy.Which_LOB_will_you_offer__c != null){
            setStr.addAll(strategy.Which_LOB_will_you_offer__c.split(';'));
        }
        for(StrategyandOppValues__c str : mapStrProd.values()){
            if(setStr.contains(str.Bu_s_Are_Offering__c) || setStr.contains(str.Bu_s_Are_Involved__c)){
               setProdType.add(str.Product_Type__c);
               setProdGrp.add(str.Product_Group__c);
            }
            
        }
          
    }
     Set<Id> setOppId = new Set<Id>();   
    public void constructQueryString(){
        
        componentRecords = null;
        List<OpportunityLineItem> listProd = [SELECT Name,OpportunityId,Productcode,Product_Type__c FROM OpportunityLineItem WHERE Opportunity.AccountId =: accId and Productcode IN :setProdGrp and Product_Type__c IN :setProdType];
        for(OpportunityLineItem oppid : listProd){
            setOppId.add(oppid.OpportunityId);
        } 
        
        //CR14509 - Introduce new StageName values and replace hard-coded StageName values
        queryString = 'Select Id, Name, Deal_ID__c, StageName, Unweighted_Rev_Formula__c, CloseDate, Weighted_Rev_Formula__c, ' +
                        'Deal_Reg_Oppty__c, LastModifiedDate ' +
                        'From Opportunity where AccountId = \'' + accId + '\' and Id IN :setOppId and Related_Strategy__c = null and ' +
                        'StageName IN (\'' + owd.Oppty_Stage1__c + '\', \'' + owd.Oppty_Stage10__c + '\', \'' + owd.Oppty_Stage30__c + '\', \'' + owd.Oppty_Stage60__c + '\', \'' + owd.Oppty_Stage90__c + '\', \'' + owd.Oppty_Stage99__c + '\') '+ 
                        'Order By Name limit 10000';              
        
        system.debug('testclasstest1'+queryString);
    }
    
    public ApexPages.StandardSetController componentRecords {
        get {            
            if(componentRecords== null) {
                System.debug('###queryString :  ' + queryString );
                System.debug('###Re-searching the data and persists the records');
                componentRecords= new ApexPages.StandardSetController(
                    Database.getQueryLocator(queryString));
                componentRecords.setPageSize(PAGE_SIZE);    
                //noOfRecords = componentRecords.getResultSize();
            }
            return componentRecords;
        }
        public set;
    }
    
    public void link(){
     system.debug('testclasstest2'+queryString);
        try{
        
            updateOpportunity();
            showError =false;
            
        }catch(Exception e){
        showError = true;
           handleError(e); 
       //    return null;  
        }
        
// return back();
                
    }
    
    public PageReference view(){
     
        try{
        
            return new PageReference('/' + selectedOppId);   
            
        }catch(Exception e){
            handleError(e); 
            return null;           
        }
                        
    }
    
    private void handleError(Exception e){                
      
        //String errMsg;                
        
        System.debug('### error : ' + e.getStackTraceString());
        System.debug('### error Message: ' + e.getMessage());
        
        //3.0 - Start 
        if (e instanceOf System.DmlException ){
           createError(' This Opportunity can not be linked due to the following error:' + '<br />' +e.getDmlMessage(0));
           return;
        } //3.0 - End  
 
        createError(System.Label.Strategy_LinkOppToStrat_GeneralErrMessage);      
          
    }    
 
    private void createError(String errMsg){
        //3.0 - Start
        //apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMsg));   
        errorMessage = errMsg; //3.0 - End         
        System.debug('###Error  : ' + errMsg);
    }
          
      
    public PageReference back(){        
        return new PageReference('/' + strategyId);        
    }
    
    private void updateOpportunity(){
    system.debug('testclasstest3'+queryString);
        
        System.debug('###Selected Opp Id [ ' + selectedOppId + ']');
        
        Opportunity opp = new Opportunity(
                    Id = selectedOppId,
                    Related_Strategy__c = strategyId
          );
          system.debug('testclasstest4'+queryString);
        
        //v4.0 - start
        //TriggerControlHandler.setOpportunityTriggersInactive(); // v2.0 - Start
        update opp ;
        //TriggerControlHandler.setOpportunityTriggersActive(); // v2.0 - End
        //v4.0 - end        
    }
    
    public Integer getLastPage(){
    
        return (componentRecords.getResultSize()/componentRecords.getPageSize()) + (Math.mod(componentRecords.getResultSize(), componentRecords.getPageSize())>0?1:0);
    
    }
         
}