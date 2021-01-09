/*
Author: Micky Toms

History:
Version Date            Modified By     Description     
------------------------------------------------------------------------------------------------
1.0     Nov-2012     Micky Toms   Created for R14.2 - VF controller for Sales Motion Search Page

*/
public class SalesMotionSearchCtrl {
    //private final Sales_Motion__c salesMotion;
    //public String searchRecordType
    public String selectRecordType {get;set;}
    public boolean solnDomainRender {get;set;}
    public boolean productRender {get;set;}
    public boolean textSearchRender {get;set;}
    public boolean domainTableRender {get;set;}
    public boolean prodcutTableRender {get;set;}
    public boolean textSearchTableRender {get;set;}
    public boolean GenericTableRender {get;set;}
    public boolean GenericsearchTableRender {get;set;}
    public string searchtext{get;set;}
    public List<String> textStringList = new List<String>();
    public Sales_Motion__c salesMotion{ get; set; }
    public Sales_Motion_Page_Section__c salesMotionPageSection {get;set;}
    public List<Sales_Motion__c> SMPSList=new List<Sales_Motion__c>();
    public List<Sales_Motion__c> smList = new List<Sales_Motion__c>();
    public string url {get; set;}
    public boolean searchrec {get;set;}
    public string selectedCountry {get;set;}
    public boolean errormsg=false;
    public User salesRep{get; set;}
    public Sales_Motion_Country__c smCountry=new Sales_Motion_Country__c();
    public Sales_Motion_Page__c smPRec{get;set;}
    
    //Pagination Variables
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;} 
        
    public SalesMotionSearchCtrl(){
        smPRec = new Sales_Motion_Page__c();
        selectRecordType = 'Domain, Solution Type and Name';
        solnDomainRender = true; 
        productRender = false;
        textSearchRender = false;
        domainTableRender = false;
        textSearchTableRender =false;
        GenericSearchTableRender= false;
        GenericTableRender = false;
        salesMotion = new Sales_Motion__c ();
        salesMotionPageSection = new Sales_Motion_Page_Section__c ();
    }
        
    public List<SelectOption> getSearchRecordTypeList() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Domain, Solution Type and Name','Domain, Solution Type and Name')); 
        options.add(new SelectOption('Product','Product')); 
        options.add(new SelectOption('TextSearch','TextSearch'));
        options.add(new SelectOption('GenericSales','Generic Sales')); 
        return options; 
    }
                   
    public Pagereference Display()
    {
        if(selectRecordType == 'Domain, Solution Type and Name')
           {
               solnDomainRender = true; 
               productRender = false;
               textSearchRender = false;
               domainTableRender = false;
               prodcutTableRender = false;
               textSearchTableRender = false;
               GenericTableRender = false;
               GenericsearchTableRender = false;
               salesMotionPageSection.Country__c = null;
               salesMotionPageSection.Sales_Motion_Country__c=null;
               salesMotionPageSection.Region__c = null;
               salesMotionPageSection.Business_Unit__c = null;
               salesMotion.Domain__c = null;
               salesMotion.Solution_Type__c = null;
               salesMotion.Solution_Name__c = null;
               salesMotion.Product__c = null;
               searchtext=null;
           }
        if(selectRecordType == 'Product')
           {
               solnDomainRender = false; 
               productRender = true;
               textSearchRender = false;
               domainTableRender = false;
               prodcutTableRender = false;
               textSearchTableRender = false;
               GenericTableRender = false;
               GenericsearchTableRender = false;
               salesMotionPageSection.Country__c = null;
               salesMotionPageSection.Sales_Motion_Country__c=null;
               salesMotionPageSection.Region__c = null;
               salesMotionPageSection.Business_Unit__c = null;
               salesMotion.Domain__c = null;
               salesMotion.Solution_Type__c = null;
               salesMotion.Solution_Name__c = null;
               salesMotion.Product__c = null;
               searchtext=null;
           }
        if(selectRecordType == 'TextSearch')
           {
               solnDomainRender = false; 
               productRender = false;
               textSearchRender = true;
               domainTableRender = false;
               prodcutTableRender = false;
               textSearchTableRender = false;
               GenericTableRender = false;
               GenericsearchTableRender = false;
               salesMotionPageSection.Country__c = null;
               salesMotionPageSection.Sales_Motion_Country__c=null;
               salesMotionPageSection.Region__c = null;
               salesMotionPageSection.Business_Unit__c = null;
               salesMotion.Domain__c = null;
               salesMotion.Solution_Type__c = null;
               salesMotion.Solution_Name__c = null;
               salesMotion.Product__c = null;
               searchtext=null;
           }
           if(selectRecordType == 'GenericSales')
           {
               GenericTableRender = true;
               solnDomainRender = false; 
               productRender = false;
               textSearchRender = false;
               domainTableRender = false;
               prodcutTableRender = false;
               textSearchTableRender = false;
               GenericsearchTableRender = false;
               salesMotionPageSection.Country__c = null;
               salesMotionPageSection.Sales_Motion_Country__c=null;
               salesMotionPageSection.Region__c = null;
               salesMotionPageSection.Business_Unit__c = null;
               salesMotion.Domain__c = null;
               salesMotion.Solution_Type__c = null;
               salesMotion.Solution_Name__c = null;
               salesMotion.Product__c = null;
               searchtext=null;  
           }
        smPRec = new Sales_Motion_Page__c();   
        return null;
    }
    public PageReference Search(){
        List<Sales_Motion__c> smList = new List<Sales_Motion__c>();
        List<Sales_Motion_Page_Section__c> smListTextSearch = new List<Sales_Motion_Page_Section__c>();
        List<Sales_Motion__c> smListSearch = new List<Sales_Motion__c>();
        List<Sales_Motion_Page_Section__c> smListBusUnit = new List<Sales_Motion_Page_Section__c>();
        List<Sales_Motion_Page_Section__c> smListRegion = new List<Sales_Motion_Page_Section__c>();
        List<Sales_Motion_Page_Section__c> smListCountry = new List<Sales_Motion_Page_Section__c>();
        Set<Id> dupeCheckSet = new Set<Id>();
        Set<Id> dupeCheckSetbusunit = new Set<Id>();
        Set<Id> dupeCheckSetregion = new Set<Id>();
        Set<Id> dupeCheckSetcountry = new Set<Id>();
        searchrec=true;
        
        if(salesMotionPageSection.Region__c==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Region'));
            return null;
        }
        if(salesMotionPageSection.Business_Unit__c==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Business Unit'));
            return null;
        }
        if(salesMotionPageSection.Sales_Motion_Country__c==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Country'));
            return null;
        }
        if(selectRecordType == 'TextSearch'){
            textStringList=searchtext.split(';');
            System.debug('#####textStringList:'+textStringList);
            //smListTextSearch=[Select Name, Id, Sales_Motion_Name__c, Domain__c, Solution_Type__c, Solution_Name__c, Country__c, Business_Unit__c, Region__c,Country_List__c,Business_Unit_List__c,Region_List__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Id, Sales_Motion_Page__r.Sales_Motion_Name__r.Product__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Product__r.Name, Sales_Motion_Page__r.Sales_Motion_Name__r.Solution_Description__c, Sales_Motion_Page__r.Sales_Motion_Name__r.Sales_Motion_Use_Case__c from Sales_Motion_Page_Section__c where Sales_Motion_Page__r.Sales_Motion_Name__r.IsActive__c=true];
            smListSearch=[Select Name,Domain__c,IsActive__c,Product__c,Sales_Motion_Use_Case__c,Solution_Description__c,Solution_Name__c,Solution_Type__c,Product__r.Name from Sales_Motion__c where IsActive__c=true];
            for(Sales_Motion__c a : smListSearch){
                    if(a.Sales_Motion_Use_Case__c!=''){
                        for(String s:textStringList){
                        System.debug('########FirstUseCase:'+a.Sales_Motion_Use_Case__c);
                        if(a.Sales_Motion_Use_Case__c==null){
                                System.debug('########MTNull');
                            }
                            else if(a.Sales_Motion_Use_Case__c!=null){
                            System.debug('########MT Not Null:'+a.Sales_Motion_Use_Case__c);
                            System.debug('########MT -- > Text to Search:'+s);                          
                                if(a.Sales_Motion_Use_Case__c.containsIgnoreCase(s)){
                                        if(dupeCheckSet.add(a.Id))
                                                smList.add(a);
                                        //break;
                                }
                            }
                        }
                    }
                    System.debug('########BusinessUnit'+salesMotionPageSection.Business_Unit__c);
                
                }
                textSearchTableRender=true;
        }   
        //Search criteria for 'Domain, Solution Type and Name'
        if(selectRecordType == 'Domain, Solution Type and Name'){
        
            if(salesMotion.Domain__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Domain before clicking Search'));
                searchrec=false;
                return null;
            }
            if(salesMotion.Domain__c!=null && salesMotion.Solution_Type__c==null && salesMotion.Solution_Name__c==null){
                //smListTextSearch=[Select Name, Id, Sales_Motion_Name__c, Domain__c, Solution_Type__c, Solution_Name__c, Country__c, Business_Unit__c, Region__c,Country_List__c,Business_Unit_List__c,Region_List__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Id, Sales_Motion_Page__r.Sales_Motion_Name__r.Product__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Product__r.Name, Sales_Motion_Page__r.Sales_Motion_Name__r.Solution_Description__c, Sales_Motion_Page__r.Sales_Motion_Name__r.Sales_Motion_Use_Case__c from Sales_Motion_Page_Section__c where Domain__c=:salesMotion.Domain__c and Sales_Motion_Page__r.Sales_Motion_Name__r.IsActive__c=true];
                
                smListSearch=[Select Name,Domain__c,IsActive__c,Product__c,Sales_Motion_Use_Case__c,Solution_Description__c,Solution_Name__c,Solution_Type__c,Product__r.Name from Sales_Motion__c where IsActive__c=true and Domain__c=:salesMotion.Domain__c];
            }
            else if(salesMotion.Domain__c!=null && salesMotion.Solution_Type__c!=null && salesMotion.Solution_Name__c==null){
                //smListTextSearch=[Select Name, Id, Sales_Motion_Name__c, Domain__c, Solution_Type__c, Solution_Name__c, Country__c, Business_Unit__c, Region__c,Country_List__c,Business_Unit_List__c,Region_List__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Id, Sales_Motion_Page__r.Sales_Motion_Name__r.Product__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Product__r.Name, Sales_Motion_Page__r.Sales_Motion_Name__r.Solution_Description__c, Sales_Motion_Page__r.Sales_Motion_Name__r.Sales_Motion_Use_Case__c from Sales_Motion_Page_Section__c where Domain__c=:salesMotion.Domain__c and Solution_Type__c =:salesMotion.Solution_Type__c and Sales_Motion_Page__r.Sales_Motion_Name__r.IsActive__c=true];
                
                smListSearch=[Select Name,Domain__c,IsActive__c,Product__c,Sales_Motion_Use_Case__c,Solution_Description__c,Solution_Name__c,Solution_Type__c,Product__r.Name from Sales_Motion__c where IsActive__c=true and Domain__c=:salesMotion.Domain__c and Solution_Type__c =:salesMotion.Solution_Type__c];
            }
            else if(salesMotion.Domain__c!=null && salesMotion.Solution_Type__c!=null && salesMotion.Solution_Name__c!=null){
                //smListTextSearch=[Select Name, Id, Sales_Motion_Name__c, Domain__c, Solution_Type__c, Solution_Name__c, Country__c, Business_Unit__c, Region__c,Country_List__c,Business_Unit_List__c,Region_List__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Id, Sales_Motion_Page__r.Sales_Motion_Name__r.Product__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Product__r.Name, Sales_Motion_Page__r.Sales_Motion_Name__r.Solution_Description__c, Sales_Motion_Page__r.Sales_Motion_Name__r.Sales_Motion_Use_Case__c from Sales_Motion_Page_Section__c where Domain__c=:salesMotion.Domain__c and Solution_Type__c =:salesMotion.Solution_Type__c and Solution_Name__c =:salesMotion.Solution_Name__c and Sales_Motion_Page__r.Sales_Motion_Name__r.IsActive__c=true];
                
                smListSearch=[Select Name,Domain__c,IsActive__c,Product__c,Sales_Motion_Use_Case__c,Solution_Description__c,Solution_Name__c,Solution_Type__c,Product__r.Name from Sales_Motion__c where IsActive__c=true and Domain__c=:salesMotion.Domain__c and Solution_Type__c =:salesMotion.Solution_Type__c and Solution_Name__c =:salesMotion.Solution_Name__c];
            }
            System.Debug('smListTextSearchMK'+smListSearch); 
            for(Sales_Motion__c a : smListSearch){
                if(dupeCheckSet.add(a.Id))
                        smList.add(a);
            }
            domainTableRender = true;
        }
        
        //Search criteria for 'Product'
        if(selectRecordType == 'Product')
        {
            prodcutTableRender = true;
            if(salesMotion.product__c==null){
                smListTextSearch=[Select Name, Id, Sales_Motion_Name__c, Domain__c, Solution_Type__c, Solution_Name__c, Country__c, Business_Unit__c, Region__c,Country_List__c,Business_Unit_List__c,Region_List__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Id, Sales_Motion_Page__r.Sales_Motion_Name__r.Product__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Product__r.Name, Sales_Motion_Page__r.Sales_Motion_Name__r.Solution_Description__c, Sales_Motion_Page__r.Sales_Motion_Name__r.Sales_Motion_Use_Case__c from Sales_Motion_Page_Section__c where Sales_Motion_Page__r.Sales_Motion_Name__r.Product__c!=null and Sales_Motion_Page__r.Sales_Motion_Name__r.IsActive__c=true];
                
                smListSearch=[Select Name,Domain__c,IsActive__c,Product__c,Sales_Motion_Use_Case__c,Solution_Description__c,Solution_Name__c,Solution_Type__c,Product__r.Name from Sales_Motion__c where IsActive__c=true and Product__c!=null];
            }
            else if (salesMotion.product__c!=null){
                smListTextSearch=[Select Name, Id, Sales_Motion_Name__c, Domain__c, Solution_Type__c, Solution_Name__c, Country__c, Business_Unit__c, Region__c,Country_List__c,Business_Unit_List__c,Region_List__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Id, Sales_Motion_Page__r.Sales_Motion_Name__r.Product__c,Sales_Motion_Page__r.Sales_Motion_Name__r.Product__r.Name, Sales_Motion_Page__r.Sales_Motion_Name__r.Solution_Description__c, Sales_Motion_Page__r.Sales_Motion_Name__r.Sales_Motion_Use_Case__c from Sales_Motion_Page_Section__c where Sales_Motion_Page__r.Sales_Motion_Name__r.Product__c=:salesMotion.product__c and Sales_Motion_Page__r.Sales_Motion_Name__r.IsActive__c=true];
                
                smListSearch=[Select Name,Domain__c,IsActive__c,Product__c,Sales_Motion_Use_Case__c,Solution_Description__c,Solution_Name__c,Solution_Type__c,Product__r.Name from Sales_Motion__c where IsActive__c=true and Product__c=:salesMotion.product__c];
            }
            System.debug('########smListTextSearchMK'+smListSearch);
            for(Sales_Motion__c a : smListSearch){
                if(dupeCheckSet.add(a.Id))
                            smList.add(a);
            }
        }
        
                  
        //Filtering based on Country
        if(salesMotionPageSection.Sales_Motion_Country__c!=null)
        {
            smCountry=[Select id,Name from Sales_Motion_Country__c where id=:salesMotionPageSection.Sales_Motion_Country__c];
            System.debug('########Country'+smCountry.Name);
            selectedCountry=smCountry.Name;
                  
        }
        
         if(selectRecordType == 'GenericSales')
         {
                      
            string recordTypeID =IdLookupUtils.getRecordTypeId('Generic Sales', 'Sales_Motion__c', true);
            system.debug('--record type id-'+recordTypeId+'---sales motion Id----'+smPRec.Sales_Motion_Name__c);
            string smId=smPRec.Sales_Motion_Name__c;
            if(smPRec.Sales_Motion_Name__c!=null   )
            {
                smListSearch=[Select Name,Domain__c,IsActive__c,Product__c,Sales_Motion_Use_Case__c,Solution_Description__c,Solution_Name__c,Solution_Type__c,Product__r.Name from Sales_Motion__c where id=: smID AND IsActive__c=true AND recordTypeId=:recordTypeId];
            }
            if(smPRec.Sales_Motion_Name__c==null)
            {
                smListSearch=[Select Name,Domain__c,IsActive__c,Product__c,Sales_Motion_Use_Case__c,Solution_Description__c,Solution_Name__c,Solution_Type__c,Product__r.Name from Sales_Motion__c where  IsActive__c=true AND recordTypeId=:recordTypeId];
            }
            System.debug('########smListTextSearchMK'+smListSearch);
            for(Sales_Motion__c a : smListSearch){
                if(dupeCheckSet.add(a.Id))
                            smList.add(a);
            }
            //if(smList==null || smList.size()==0)
            // {
            //        SMPSList=null;
            //        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Sales Motions available for the selected filter criteria'));
            //        searchrec=false;
            //        errormsg=true;
            // }
            // else
            // {
            //        System.debug('########smList'+smList);
            //        SMPSList=new List<Sales_Motion__c>();
            //        SMPSList=smList;
            //        searchrec=true;
            //        errormsg=false;
            // }
             GenericsearchTableRender =true;
            //insertSMSearchUsageTracker(errormsg);
             
            // return null;
        }
        if(smList==null || smList.size()==0)
        {
                    SMPSList=null;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Sales Motions available for the selected filter criteria'));
                    searchrec=false;
                    errormsg=true;
        }
        else{
                   System.debug('########smList'+smList);
                    SMPSList=smList;
                    searchrec=true;
                    errormsg=false;
        }
                insertSMSearchUsageTracker(errormsg);
                
         
        return null;
    }
           
        public void insertSMSearchUsageTracker(boolean errormsg){
            Product2 smProduct=new Product2();
            salesRep = [select id,name,title from user where id= :UserInfo.getUserId()];
            SM_Search_Usage_Tracker__c newSMSrchTrac = new SM_Search_Usage_Tracker__c();
            newSMSrchTrac.Sales_Rep_Name__c = salesRep.name;
            newSMSrchTrac.Sales_Rep_Title__c = salesRep.title;
            newSMSrchTrac.Region__c = salesMotionPageSection.Region__c;
            newSMSrchTrac.Country__c=smCountry.Name;
            newSMSrchTrac.Segment_Business_Unit__c=salesMotionPageSection.Business_Unit__c;
            newSMSrchTrac.Domain__c=salesMotion.Domain__c;
            newSMSrchTrac.Solution_Type__c=salesMotion.Solution_Type__c;
            newSMSrchTrac.Solution_Name__c=salesMotion.Solution_Name__c;
            if (salesMotion.product__c!=null){
                smProduct=[Select id,Name from Product2 where id=:salesMotion.product__c];
                System.debug('########ProductName'+smProduct.Name); 
                newSMSrchTrac .Product__c=smProduct.Name;
            }
            else{
                newSMSrchTrac .Product__c=null;
            }
            newSMSrchTrac.Stage__c='Plan - 1%';
            newSMSrchTrac.SMSearch_Button_click_Date_Time__c=system.now();
            newSMSrchTrac.SM_Error_Message__c=errormsg;
            insert newSMSrchTrac;
        }
    
    
    public List<Sales_Motion__c> getSMPSList(){
        return SMPSList;
     }
    public void setSMPSList(List<Sales_Motion__c> SMPSList){
        this.SMPSList=SMPSList;
     }
   
     
}