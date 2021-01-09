/*
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         TK Chin     17-Apr-2013     14.5        7642    Start versioning. 
1.1         TK Chin     17-Apr-2013     14.5        7642    Allow users to select image to upload.
*/
Public class SalesMotionFindNReplaceController{
    
    public Sales_Motion__c SalesMotionInfo=new Sales_Motion__c();
    string domainname=null;
    string solutiontype=null;
    Public boolean showMultiPickofTandC=true;
    Public Set<string> TandC= new Set<string>();
    Public Set<string> TandCId= new Set<string>();
    Public Set<string> TandCPagesId= new Set<string>();
    Public Set<string> TandCStages= new Set<string>();
    Public Set<string> TandCSections= new Set<string>();
    Public Set<string> TandCProducts= new Set<string>();
    Public Set<string> SalesmotionPages= new Set<string>();
    Public Set<string> SalesmotionStages= new Set<string>();
    Public Set<string> SalesmotionSections= new Set<string>();
    Public List<string> termsToAdd = new List<string>{};
    Public List<string> termsToAddId = new List<string>{};
    Public List<string> termsToRemove = new List<string>{};
    Public List<string> pagesToAdd = new List<string>{};
    Public List<string> pagesToRemove = new List<string>{};
    Public List<string> stagesToAdd = new List<string>{};
    Public List<string> stagesToRemove = new List<string>{};
    Public List<string> sectionsToAdd = new List<string>{};
    Public List<string> sectionsToRemove = new List<string>{};
    Public List<string> productsToAdd = new List<string>();
    Public List<string> productsToRemove = new List<string>();
    Public List<String> lstRecords =new List<String>{};
    
    Public Set<string> allStages = new Set<string>();
    Public Set<string> addedStages = new Set<string>();
    Public List<Sales_Motion__c> recsalesmotion = new List<Sales_Motion__c>(); 
    Public List<Sales_Motion__c> salesmotionproduct=new List<Sales_Motion__c>();
    Public List<selectOption> fullAvailableTandC = new List<SelectOption>();
    Public List<selectOption> fullavailablePages= new List<SelectOption>();
    Public List<selectOption> fullavailableStages= new List<SelectOption>();
    Public List<selectOption> fullavailableSections= new List<SelectOption>();
    Public List<selectOption> availableTandC = new List<selectOption>();
    Public List<selectOption> availablePages= new List<selectOption>();
    Public List<selectOption> availableSections= new List<selectOption>();
    Public List<selectOption> stages= new List<selectOption>();
    Public List<selectOption> availableStages= new List<selectOption>();
    Public List<selectOption> selectedStages= new List<selectOption>();
    Public List<Sales_Motion__c> newCSMBTandCList = new List<Sales_Motion__c>();
    Public List<Sales_Motion_Page__c> newSalesmotionPageList = new List<Sales_Motion_Page__c>();
    Public List<selectOption> selectedTandC = new List<selectOption>();
    Public List<selectOption> selectedPages = new List<selectOption>();
    Public List<selectOption> selectedSections = new List<selectOption>();
    //Public List<SelectedAreaWithTerms> selectedAreaWithTermsList = new List<SelectedAreaWithTerms>();
    //public Map<string,SelectedAreaWithTerms> mapOfAreaAndTerms = new  Map<string,SelectedAreaWithTerms>();
    Public List<selectOption> availableSalesmotionPages = new List<selectOption>();
    Public List<selectOption> selectedSalesmotionPages = new List<selectOption>();
    Public List<selectOption> availableSalesmotionStages = new List<selectOption>();
    Public List<selectOption> selectedSalesmotionStages = new List<selectOption>();
    Public List<selectOption> availableSalesmotionSections = new List<selectOption>();
    Public List<selectOption> selectedSalesmotionSections = new List<selectOption>();
    Public List<selectOption> availableProducts= new List<selectOption>();
    Public List<selectOption> selectedProducts= new List<selectOption>();
    Public Map<string,Id> mapOfSalesmotionIdtoName= new  Map<String,Id>();
    Public Map<string,Id> mapOfSalesmotionPagesIdtoName= new  Map<String,Id>();
    Public Map<string,Id> mapOfSalesmotionSectionsIdtoName= new  Map<String,Id>();
    Public Map<Id,Id> mapOfSalesmotionRecordsIdtoName= new Map<Id,String>();
    Public Map<string,Id> mapOfProductIdtoName= new  Map<String,Id>();
    Map<Id,String> salesMotionMap=new Map<Id,String>(); 
    Map<Id,String> pagesMap=new Map<Id,String>(); 
    Map<Id,String> sectionMap=new Map<Id,String>(); 
    
    Public string areaNameStr{get;set;}
    
    Public Boolean previousSalesmotion=false;
    Public Boolean previousSalesmotionPages=false;
    Public Boolean previousSalesmotionSections=false;
    Public Integer previousSalesmotionedited=0;
    Public Integer previousSalesmotionPagesedited=0;
    Public Integer previousSalesmotionSectionsedited=0;
    
    //Version 1.1 - Use an RTF field instead of string for replaceText.
    Public Idea rtfReplaceTextObj { get; set; }
    
    String searchText='';
    String replaceText='';
    Set<String> SetOfStages=new Set<String>();
    List<Sales_Motion_Page_Section__c> SalesMotionPageSectionRecs=new List<Sales_Motion_Page_Section__c>();
    List<Sales_Motion_Page_Section__c> SalesMotionPageSectionUpdateRecs=new List<Sales_Motion_Page_Section__c>();
    List<SMPageSection> SMPageSectionList=new List<SMPageSection>();
    List<SMPageSection> BKPSMPageSectionList=new List<SMPageSection>();
    Map<Id,Sales_Motion_Page_Section__c> SMPagesectionMap=new Map<Id,Sales_Motion_Page_Section__c>(); 
    
    Boolean userMsg=false;
    Boolean showTbl=false;
    Boolean showSearch=false;
   
    RecordType RT;
    
     
     public class SMPageSection{        
        public Sales_Motion_Page_Section__c SMPageSection{get; set;}          
        public Boolean selected{get; set;} 
          
        public SMPageSection(Sales_Motion_Page_Section__c section){                
                SMPageSection=section;
                //selected=bool;                
        }
    }
    
    
    Public SalesMotionFindNReplaceController(){ 
        //Version 1.1
        rtfReplaceTextObj = new Idea();
        //availableStages.clear();       
        loadStages();
        initializeTandC(); 
        init();   
        initSolutionType();    
        //initProductType();
        loadProducts();
    } 
    
    public void loadStages(){
        Schema.DescribeFieldResult fieldResult =Sales_Motion_Page_Section__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        availableStages.add(new SelectOption('No Stages', 'No Stages'));  
              
        for(Schema.PicklistEntry f : ple){
            availableStages.add(new SelectOption(f.getLabel(), f.getValue()));
            SetOfStages.add(f.getValue());
        }
    } 
    
    public void loadProducts(){
        salesmotionproduct=[Select Solution_Type__c, Solution_Name__c, Product__r.Name,Product__r.id From Sales_Motion__c where  Product__r.id !=null order by Product__r.Name asc];
        for(Sales_Motion__c Salesmotionproductlist:salesmotionproduct){
            availableProducts.add(new SelectOption(Salesmotionproductlist.Product__r.Name, Salesmotionproductlist.Product__r.Name));
            if(mapOfProductIdtoName.get(Salesmotionproductlist.Id)==null){
                mapOfProductIdtoName.put(Salesmotionproductlist.Product__r.Name,Salesmotionproductlist.Product__r.id);
            }

        }
    }
    
    
    //*===========Added By Micky Toms for Product===============================//
    
    public void addCurSelectedProduct(){
        if(previousSalesmotion==true){
            previousSalesmotionedited=1;
        }
        selectedProducts = addToList(selectedProducts ,productsToAdd);
        availableProducts= removeFromList(availableProducts,productsToAdd);
        for(string terms:productsToAdd){
            //TandCProducts.add(terms);
            string idStr=mapOfProductIdtoName.get(terms);
            TandCProducts.add(idStr);
            system.debug('####TandCProducts:' + TandCProducts);

        }                
    }

    public void removeCurSelectedProduct(){
        if(previousSalesmotionPages==true){
            previousSalesmotionPagesedited=1;
        }
        availableProducts= addToList(availableProducts,productsToRemove);
        selectedProducts = removeFromList(selectedProducts ,productsToRemove); 
        for(String terms:productsToRemove){           
            //TandC.remove(terms);
            string idStr=mapOfProductIdtoName.get(terms);
            TandCProducts.remove(idStr); 
        }
             
    }  
    
     public List<selectOption> getselectedProducts(){
        return selectedProducts;
    }
    
    public void setselectedProducts(list<selectoption> selectedProducts){
        this.selectedProducts=selectedProducts;
    }
    public List<selectOption> getavailableProducts(){
        return availableProducts;
    }
     public void setavailableProducts(list<selectOption> availableProducts){
        this.availableProducts=availableProducts;
    }
    public List<string> getproductsToAdd(){
        return productsToAdd;
    }
    public void setproductsToAdd(List<string> productsToAdd){
        this.productsToAdd=productsToAdd;
    }
    
    public List<string> getproductsToRemove(){
        return productsToRemove;
    }
    public void setproductsToRemove(List<string> productsToRemove){
        this.productsToRemove=productsToRemove;
    }
//==============================end==============================================//
    
    /*****************************Domain Name**********************************/
    
    Public Set<String> unSelectedDomain = new Set<String>();
    Public Set<String> selectedDomain = new Set<String>();   

    Set<String> unSelectedDomainName = new Set<String>();
    Set<String> selectedBSegs = new Set<String>();
    Set<String> addALLDomainName = new Set<String>();
    Set<String> removeALLDomainName = new Set<String>();
    List<String> selectedOptionLst=new List<String>();  
    //public List<String> unselected {get; set; }    
    List<String> selected =new List<String>();
    List<String> unselected =new List<String>();     
    List<String> domainList=new List<String>(); 
    List<String> selectedBsegList=new List<String>(); 
    Map<String,String> schemaMap=new Map<String,String>();
    
    
    public List<SelectOption> getDomainOptions() {
        Schema.DescribeFieldResult domainFld = Sales_Motion__c.Domain__c.getDescribe(); 
        List<Schema.PicklistEntry> domainPLE = domainFld.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.PicklistEntry ple:domainPLE){
            options.add(new SelectOption(ple.getLabel(),ple.getValue()));    
        }        
        return options;
    }
    public List<String> getDomainName() {
        return domainList;
    }
    public void setDomainName(List<String> strList) {
        this.domainList = strList;
    }
    
    
    private void init() {
        Schema.DescribeFieldResult BSegFld = Sales_Motion__c.Domain__c.getDescribe();         
        for (Schema.PicklistEntry ple:BSegFld.getPicklistValues()) {        
            unSelectedDomainName.add(ple.getLabel()); 
            addALLDomainName.add(ple.getLabel()); 
            removeALLDomainName.add(ple.getLabel());
            schemaMap.put(ple.getLabel(),ple.getValue());       
        }
    }
    
    
    public List<SelectOption> getSelectedOptions(){        
        List<String> sorted = new List<String>(selectedBSegs);
        sorted.sort();
        List<SelectOption> options = new List<SelectOption>();
        for (String ple: sorted) {
            options.add(new SelectOption(ple,schemaMap.get(ple)));
            selectedOptionLst.add(ple);
        }            
        return options;       
    }
    public List<SelectOption> getUnSelectedOptions(){       
        List<String> sorted = new List<String>(unSelectedDomainName);
        sorted.sort();
        List<SelectOption> options = new List<SelectOption>();
        for (String ple: sorted) {
            options.add(new SelectOption(ple,schemaMap.get(ple)));
        }            
        return options;        
    }

    public pagereference doSelect() { 
        if(previousSalesmotion==true){
            previousSalesmotionedited=1;
            previousSalesmotionPagesedited=1;
        } 
        for (String s: selected) {            
            selectedBSegs.add(s);
            unSelectedDomainName.remove(s);
        }
        return null;
    }
    public pagereference doUnSelect(){
         if(previousSalesmotion==true){
            previousSalesmotionedited=1;
            previousSalesmotionPagesedited=1;
        }
        for (String s: unselected) {            
            unSelectedDomainName.add(s);
            selectedBSegs.remove(s);            
        }
        return null;
    }
    
    public List<String> getSelected(){        
        return selected;
    }
    public void setSelected(List<String> bSegment){        
        this.selected = bSegment;
    }
    public List<String> getUnSelected() {        
        return unSelected;
    }
    public void setUnSelected(List<String> bSegment){        
        this.unSelected = bSegment;
    }
    
    
     /**********************end domain*********************************/
     
     /*****************************SOLUTION TYPE**********************************/
    
    Public Set<String> unSelectedSolutionType = new Set<String>();
    Public Set<String> selectedSolutionType = new Set<String>();
    Set<String> addALLSolutionType = new Set<String>();
    Set<String> removeALLSolutionType = new Set<String>();
    List<String> selectedSolutionTypes=new List<String>();
    List<String> selectedSolnTypes =new List<String>();
    List<String> unselectedSolnTypes =new List<String>();     
    List<String> SolutionTypeList=new List<String>(); 
    List<String> selectedSolutionTypeList=new List<String>(); 
    Map<String,String> SolutionTypeSchemaMap=new Map<String,String>();
    
    
    public List<SelectOption> getSolutionTypeOptions() {
        Schema.DescribeFieldResult domainFld = Sales_Motion__c.Solution_Type__c.getDescribe(); 
        List<Schema.PicklistEntry> domainPLE = domainFld.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.PicklistEntry ple:domainPLE){
            options.add(new SelectOption(ple.getLabel(),ple.getValue()));    
        }        
        return options;
    }
    public List<String> getSolutionType() {
        return SolutionTypeList;
    }
    public void setSolutionType(List<String> strList) {
        this.SolutionTypeList = strList;
    }
    
    private void initSolutionType(){
        Schema.DescribeFieldResult SolTypeFld = Sales_Motion__c.Solution_Type__c.getDescribe();         
        for(Schema.PicklistEntry ple:SolTypeFld.getPicklistValues()){        
            unSelectedSolutionType.add(ple.getLabel()); 
            addALLSolutionType.add(ple.getLabel()); 
            removeALLSolutionType.add(ple.getLabel());
            SolutionTypeSchemaMap.put(ple.getLabel(),ple.getValue());       
        }
    }
    
    public List<SelectOption> getSelectedSolutionTypeOptions(){        
        List<String> sorted = new List<String>(selectedSolutionType);
        sorted.sort();
        List<SelectOption> options = new List<SelectOption>();
        for (String ple: sorted) {
            options.add(new SelectOption(ple,SolutionTypeSchemaMap.get(ple)));
            selectedSolutionTypes.add(ple);
        }            
        return options;       
    }
    public List<SelectOption> getUnSelectedSolutionTypeOptions(){       
        List<String> sorted = new List<String>(unSelectedSolutionType);
        sorted.sort();
        List<SelectOption> options = new List<SelectOption>();
        for (String ple: sorted) {
            options.add(new SelectOption(ple,SolutionTypeSchemaMap.get(ple)));
        }            
        return options;        
    }

    public pagereference doSelectSolutionTypes() {
        if(previousSalesmotion==true){
            previousSalesmotionedited=1;
        }
        for (String s: selectedSolnTypes) {            
            selectedSolutionType.add(s);
            unSelectedSolutionType.remove(s);
        }
        return null;
    }
    public pagereference doUnSelectSolutionTypes() { 
        if(previousSalesmotion==true){
            previousSalesmotionedited=1;
        }
        for (String s: unselectedSolnTypes) {            
            unSelectedSolutionType.add(s);
            selectedSolutionType.remove(s);            
        }
        return null;
    }   
      
    
    public List<String> getSelectedSolutionTypes() {        
        return selectedSolnTypes;
    }
    public void setSelectedSolutionTypes(List<String> SolnType) {        
        this.selectedSolnTypes = SolnType;
    }
    public List<String> getUnSelectedSolutionTypes() {        
        return unselectedSolnTypes;
    }
    public void setUnSelectedSolutionTypes(List<String> SolnType) {        
        this.unselectedSolnTypes = SolnType;
    }
    
    
     /**********************end Solution Type*********************************/
     
     
     
     
    
    public List<Sales_Motion__c> getRecsalesmotion(){
      return recsalesmotion;
    }

       
    public void initializeTandC(){
        fullavailableTandC.clear();
        availableTandC.clear(); 
        List<Sales_Motion__c> SalesMotionList=new List<Sales_Motion__c>(); 
        
        if(selectedBSegs.size()>0 && selectedSolutionType.size()==0 && TandCProducts.size()==0){
            SalesMotionList=[select Id,Name from Sales_Motion__c where Domain__c in:selectedBSegs  Limit 1000];
        }
        if(selectedBSegs.size()==0 && selectedSolutionType.size()>0 && TandCProducts.size()==0){
            SalesMotionList=[select Id,Name from Sales_Motion__c where Solution_Type__c in:selectedSolutionType Limit 1000];
        }
        if(selectedBSegs.size()==0 && selectedSolutionType.size()==0 && TandCProducts.size()>0){
            SalesMotionList=[select Id,Name from Sales_Motion__c where Product__c in:TandCProducts order by name Limit 1000];
        }
        if(selectedBSegs.size()>0 && selectedSolutionType.size()>0 && TandCProducts.size()>0){
            SalesMotionList=[select Id,Name from Sales_Motion__c where (Domain__c in:selectedBSegs AND Solution_Type__c in:selectedSolutionType) OR Product__c in:TandCProducts Limit 1000];
        }
        if(selectedBSegs.size()==0 && selectedSolutionType.size()>0 && TandCProducts.size()>0){
            SalesMotionList=[select Id,Name from Sales_Motion__c where Solution_Type__c in:selectedSolutionType OR Product__c in:TandCProducts Limit 1000];
        }
        if(selectedBSegs.size()>0 && selectedSolutionType.size()==0 && TandCProducts.size()>0){
            SalesMotionList=[select Id,Name from Sales_Motion__c where Domain__c in:selectedBSegs OR Product__c in:TandCProducts Limit 1000];
        }
        if(selectedBSegs.size()>0 && selectedSolutionType.size()>0 && TandCProducts.size()==0){
            SalesMotionList=[select Id,Name from Sales_Motion__c where Domain__c in:selectedBSegs AND Solution_Type__c in:selectedSolutionType Limit 1000];
        }
       
        for(Sales_Motion__c SMVar:SalesMotionList){            
            if(mapOfSalesmotionIdtoName.get(SMVar.Id)==null){
                mapOfSalesmotionIdtoName.put(SMVar.Id,SMVar.Id);
            }
            salesMotionMap.put(SMVar.Id,SMVar.name);
            fullavailableTandC.add(new selectOption(SMVar.Id,SMVar.Name));
        }        
        availableTandC=fullavailableTandC;
        system.debug('####availableTandC:' + availableTandC);
         system.debug('####salesMotionMap:' + salesMotionMap);
        SelectedTandC = addToList(SelectedTandC,termsToAdd);
        availableTandC = removeFromList(availableTandC,termsToAdd);
        for(string terms:termsToAdd){
            TandC.add(terms);
        }
    }

    public void initializeSalesmotionPages(){
        fullavailablePages.clear();
        availablePages.clear(); 
        system.debug('####TandCId:' + TandCId);
        
        List<Sales_Motion_Page__c> editModeSalesmotionPagesList= [select Id,Name,Sales_Motion_Name__c,Sales_Motion_Name__r.Name  from Sales_Motion_Page__c where Sales_Motion_Name__c in :TandCId  Limit 1000];
                        
        for(Sales_Motion_Page__c salesmotionPages:editModeSalesmotionPagesList){
            Set<Sales_Motion_Page__c> editModeSalesmotionPagesSet = new Set<Sales_Motion_Page__c>();
            editModeSalesmotionPagesSet.add(salesmotionPages);
                if(mapOfSalesmotionPagesIdtoName.get(salesmotionPages.Id)==null){
                    mapOfSalesmotionPagesIdtoName.put(salesmotionPages.Id,salesmotionPages.id);
                }
            fullavailablePages.add(new selectOption(salesmotionPages.Id,salesmotionPages.Sales_Motion_Name__r.Name+':'+salesmotionPages.Name));
            //pagesToAddatSkip.add(salesmotionPages.Sales_Motion_Name__r.Name+':'+salesmotionPages.Name);
            pagesMap.put(salesmotionPages.Id,salesmotionPages.Sales_Motion_Name__r.Name+':'+salesmotionPages.Name);
        }
        availablePages=fullavailablePages;
        system.debug('####availablePages:' + availablePages);
        selectedSalesmotionPages = addToList(selectedSalesmotionPages,pagesToAdd);
        availableSalesmotionPages = removeFromList(availableSalesmotionPages,pagesToAdd);
        for(string pages:pagesToAdd){
            SalesmotionPages.add(pages);
        }
    }             
  

    public void initializeSalesmotionSections(){
       // List<Sales_Motion_Page_Section__c> editModeSalesmotionSectionsList=new List<Sales_Motion_Page_Section__c>();
       // List<String> lstpageSectionRecords=new List<String>{};
        
        fullavailableSections.clear();
        availableSections.clear();
        //Set<Sales_Motion_Page_Section__c> editModeSalesmotionSectionsSet = new Set<Sales_Motion_Page_Section__c>();
        
        for(Sales_Motion_Page_Section__c SMSection:[select Id,Name,Sales_Motion_Page__c,Stage__c,Sales_Motion_Page__r.name,Sales_Motion_Page__r.Sales_Motion_Name__c,
                                                        Sales_Motion_Page__r.Sales_Motion_Name__r.name,Section_Content__c from Sales_Motion_Page_Section__c where Sales_Motion_Page__c in :TandCPagesId  Limit 1000]){ 
             
             if(TandCStages.contains(SMSection.Stage__c)&& SMSection.Section_Content__c!=null){
                
                  String salesmotionname= SMSection.Sales_Motion_Page__r.Sales_Motion_Name__r.name;
                    String pagename= SMSection.Sales_Motion_Page__r.name;
                    
                    fullavailableSections.add(new selectOption(SMSection.id,salesmotionname+':'+pagename+':'+SMSection.Name));
                    sectionMap.put(SMSection.id,salesmotionname+':'+pagename+':'+SMSection.Name);
                    
             }
             if(TandCStages.contains('No Stages') && SMSection.Stage__c==null&&SMSection.Section_Content__c!=null){
                 
                 String salesmotionname= SMSection.Sales_Motion_Page__r.Sales_Motion_Name__r.name;
                String pagename= SMSection.Sales_Motion_Page__r.name;
                
                fullavailableSections.add(new selectOption(SMSection.id,salesmotionname+':'+pagename+':'+SMSection.Name));
                sectionMap.put(SMSection.id,salesmotionname+':'+pagename+':'+SMSection.Name);
               
             }                                          
        }
 
        availableSections=fullavailableSections;
        system.debug('####availableSections:' + availableSections);
        selectedSalesmotionSections = addToList(selectedSalesmotionSections ,sectionsToAdd);
        availableSalesmotionSections = removeFromList(availableSalesmotionSections,sectionsToAdd);
        for(string sections:sectionsToAdd){
            salesmotionSections.add(sections);
        }
    }       

    public List<SelectOption> getavailableStages(){
        availableStages.sort();                   
        return availableStages;        
    }
    public List<SelectOption> getrectypes(){
        List<SelectOption> options = new List<SelectOption>();
        domainname=SalesMotionInfo.Domain__c;
        solutiontype=SalesMotionInfo.Solution_Type__c;
      
        for(Sales_Motion__c a : [select SalesMotionUniqueId__c,Name from Sales_Motion__c where Domain__c=:domainname and Solution_Type__c=:solutiontype]){
            recsalesmotion.add(a);
            options.add(new SelectOption(a.Name,a.Name)); 
        }
        return options;
    }
    public Sales_Motion__c getSalesMotionInfo(){
        return SalesMotionInfo;
    }
    public void  SetSalesMotionInfo(Sales_Motion__c SalesMotionInfo){
        this.SalesMotionInfo=SalesMotionInfo;
    }


    public List<Sales_Motion__c> getSalesmotionRecords(){
        if(recsalesmotion == null){
            recsalesmotion = new List<Sales_Motion__c>();
            domainname=SalesMotionInfo.Domain__c;
            system.debug('####domainname:' + domainname);
            solutiontype=SalesMotionInfo.Solution_Type__c;
            system.debug('####solutiontype:' + solutiontype);

            for(Sales_Motion__c a : [select SalesMotionUniqueId__c,Name from Sales_Motion__c where Domain__c=:domainname and Solution_Type__c=:solutiontype order by Name]){
                recsalesmotion.add(a);
            }
        }
        system.debug('####recsalesmotion:' + recsalesmotion);
        return recsalesmotion;
    }

    // Common method to add selected multiPickList values
    private List<SelectOption> addToList(List<SelectOption> theList, String[] theSelected){
        string valueStr='';
        List<SelectOption> newList = new List<SelectOption>();
        newList.addAll(theList);
        for(String tAndC : theSelected){
            //string idStr=mapOfSalesmotionIdtoName.get(tAndC);  
             
            try{
                if(valueStr==''||valueStr==null){
                     valueStr=salesMotionMap.get(tAndC);
                 }
                 system.debug('####valueStr from salesMotionMap:' + valueStr);
            }Catch(Exception e){
                valueStr='';
            }  
            try{
                if(valueStr==''||valueStr==null){
                    valueStr=pagesMap.get(tAndC);
                }                
            }Catch(Exception e){
                valueStr='';
            }       
            try{
                if(valueStr==''||valueStr==null){
                    valueStr=sectionMap.get(tAndC);
                }
            }Catch(Exception e){
                valueStr='';
            }
            if(valueStr!=''&&valueStr!=null){
                newList.add(new SelectOption(tAndC,valueStr));
                valueStr='';
            }else{
                newList.add(new SelectOption(tAndC, tAndC));
            }
            //TandCId.add(idStr);   
        }       
        return SortOptionList(newList);
    }

     //Method to sort List of SelectOption
    public static List<SelectOption> SortOptionList(List<SelectOption> ListToSort){
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;    
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = 0;       
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);        
        for(SelectOption x : ListToSort){
            if(x.getLabel() <= pivotValue.getLabel()){
                Less.add(x);                
            }
           else if(x.getLabel() > pivotValue.getLabel()){
                 Greater.add(x);                    
            }
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater));
        return returnList; 
    }

    // Common method to remove selected multiPickList values
    private List<SelectOption> removeFromList(List<SelectOption> theList, String[] theSelected){
        Map<String, String> temptheSelected = new Map<String, String> {};        
        for (String tAndC : theSelected){
            //string idStr=mapOfSalesmotionIdtoName.get(tAndC);
            temptheSelected.put(tAndC,tAndC);
            //TandCId.remove(idStr);   
        }               
        List<SelectOption> newList = new List<SelectOption>();
        for(SelectOption listItem: theList){
            System.debug('### removeFromList value'+listItem.getValue() +'    listitem'+listItem);
            if(!temptheSelected.containsKey(listItem.getValue())){
                newList.add(new SelectOption(listItem.getValue(), listItem.getLabel()));
            }            
        }
        System.debug('### newList'+newList);        
        return newList;
    }

    public void addCurSelectedTandC(){
        SelectedTandC = addToList(SelectedTandC,termsToAdd);
        availableTandC = removeFromList(availableTandC,termsToAdd);
          System.debug('###SelectedTandC addCurSelectedTandC'+SelectedTandC);   
          for(String terms: termsToAdd){           
            TandCId.add(terms);
            TandC.add(terms);
          }
          if(previousSalesmotionPages==true){
            previousSalesmotionPagesedited=1;
        }   
        
    }
    public void removeCurSelectedTandC(){
       availableTandC = addToList(availableTandC,termsToRemove);
        SelectedTandC = removeFromList(SelectedTandC,termsToRemove); 
        if(previousSalesmotionPages==true){
            previousSalesmotionPagesedited=1;
        }        
         for (String terms: termsToRemove){            
            TandCId.remove(terms); 
            TandC.remove(terms);
        }       
    }   
    
    
    public void addCurSelectedPages(){
        SelectedPages = addToList(SelectedPages ,pagesToAdd);
        availablePages = removeFromList(availablePages ,pagesToAdd);
         for(String tAndC : pagesToAdd){
            //string idStr=mapOfSalesmotionPagesIdtoName.get(tAndC);
            TandCPagesId.add(tAndC);
          }
           
    }
    public void removeCurSelectedPages(){
       availablePages = addToList(availablePages ,pagesToRemove);
        SelectedPages = removeFromList(SelectedPages ,pagesToRemove); 
         for (String tAndC : pagesToRemove){
            //string idStr=mapOfSalesmotionPagesIdtoName.get(tAndC);
            TandCPagesId.remove(tAndC);   
        }       
    } 
     public void addCurSelectedStages(){
        if(previousSalesmotionSections==true){
            previousSalesmotionSectionsedited=1;
        }
      selectedStages = addToList(selectedStages ,stagesToAdd);      
      availableStages= removeFromList(availableStages,stagesToAdd);
        for(string terms:stagesToAdd){
           TandCStages.add(terms);
      } 
      
    }
    
    public void removeCurSelectedStages(){
        if(previousSalesmotionSections==true){
            previousSalesmotionSectionsedited=1;
        }
       availableStages= addToList(availableStages,stagesToRemove);
        selectedStages = removeFromList(selectedStages ,stagesToRemove); 
        for(String terms:stagesToRemove){           
            TandCStages.remove(terms);
        }
       
     } 
     public void addCurSelectedSections(){
        SelectedSections = addToList(SelectedSections,sectionsToAdd);
        availableSections = removeFromList(availableSections,sectionsToAdd);
         for(String tAndC : sectionsToAdd){
            //string idStr=mapOfSalesmotionSectionsIdtoName.get(tAndC);
            TandCSections.add(tAndC);
          }
    }
    
    public void removeCurSelectedSections(){
       availableSections = addToList(availableSections ,sectionsToRemove);
        SelectedSections = removeFromList(SelectedSections ,sectionsToRemove); 
         for (String tAndC : sectionsToRemove){
            //string idStr=mapOfSalesmotionSectionsIdtoName.get(tAndC);
            TandCSections.remove(tAndC);   
        }       
    }
     
    public void setrecsalesmotion(List<Sales_Motion__c> recsalesmotion ){
        this.recsalesmotion =recsalesmotion;
    }
     
    public boolean getshowMultiPickofTandC(){
        return showMultiPickofTandC;
    } 
    public void setshowMultiPickofTandC(boolean showMultiPickofTandC){
        this.showMultiPickofTandC=showMultiPickofTandC;
    } 
     
    public List<selectOption> getavailableTandC(){
        availableTandC=SortOptionList(availableTandC);
        return availableTandC;
    }
    public List<selectOption> getavailablePages(){
       availablePages=SortOptionList(availablePages); 
        return availablePages;
    }
     
    public List<selectOption> getselectedStages(){
        selectedStages.sort();
        return selectedStages;
    }
    public List<selectOption> getselectedPages(){
        selectedPages=SortOptionList(selectedPages);
        return selectedPages;
    }
    public List<selectOption> getselectedSections(){
        selectedSections=SortOptionList(selectedSections);
        return selectedSections;
    }     
    public List<selectoption> getfullavailableTandC(){
        return fullavailableTandC;
    }
    
    public List<selectoption> getfullavailablePages(){
        return fullavailablePages;
    }
    public List<selectoption> getfullavailableStages(){
        return fullavailableStages;
    }
    public List<selectoption> getfullavailableSections(){
        return fullavailableSections;
    }
    public List<selectoption> getavailableSections(){
        availableSections=SortOptionList(availableSections);
        return availableSections;
    }
    
    public void setavailableTandC(list<selectOption> availableTandC){
        this.availableTandC=availableTandC;
    }
        
    public void setfullavailableTandC(list<selectoption> fullavailableTandC){
        this.fullavailableTandC=fullavailableTandC;
    }
    
    public void setfullavailablePages(list<selectoption> fullavailablePages){
        this.fullavailablePages=fullavailablePages;
    }
    public void setfullavailableStages(list<selectoption> fullavailableStages){
        this.fullavailableStages=fullavailableStages;
    }
    public void setfullavailableSections(list<selectoption> fullavailableSections){
        this.fullavailableSections=fullavailableSections;
    }
    public void setavailableSections(list<selectoption> availableSections){
        this.availableSections=availableSections;
    }

    public void setavailablePages(list<selectoption> availablePages){
        this.availablePages=availablePages;
    }
    public void setavailableStages(list<selectoption> availableStages){
        this.availableStages=availableStages;
    }
    public void setstages(list<selectoption> stages){
        this.stages=stages;
    }

    public void setselectedStages(list<selectoption> selectedStages){
        this.selectedStages=selectedStages;
    }


    public void setselectedPages(list<selectoption> selectedPages){
        this.selectedPages=selectedPages;
    }
    public void setselectedSections(list<selectoption> selectedSections){
        this.selectedSections=selectedSections;
    }

    public List<selectOption> getavailableSalesmotionPages(){
        return availableSalesmotionPages ;
    }
     public void setavailableSalesmotionPages(list<selectOption> availableSalesmotionPages){
        this.availableSalesmotionPages=availableSalesmotionPages;
    }
    public List<selectOption> getavailableSalesmotionStages(){
        return availableSalesmotionStages ;
    }
     public void setavailableSalesmotionStages(list<selectOption> availableSalesmotionStages){
        this.availableSalesmotionStages=availableSalesmotionStages;
    }

    public List<selectOption> getselectedSalesmotionPages(){
        //selectedSalesmotionPages.sort();
        return selectedSalesmotionPages;
    }
     public void setselectedSalesmotionPages(list<selectOption> selectedSalesmotionPages){
        this.selectedSalesmotionPages=selectedSalesmotionPages;
    }
    public List<selectOption> getselectedSalesmotionStages(){
        return selectedSalesmotionStages;
    }
     public void setselectedSalesmotionStages(list<selectOption> selectedSalesmotionStages){
        this.selectedSalesmotionStages=selectedSalesmotionStages;
    }
    public List<selectOption> getavailableSalesmotionSections(){
        return availableSalesmotionSections ;
    }
     public void setavailableSalesmotionSections(list<selectOption> availableSalesmotionSections){
        this.availableSalesmotionSections=availableSalesmotionSections;
    }
    public List<selectOption> getselectedSalesmotionSections(){
        return selectedSalesmotionSections;
    }
     public void setselectedSalesmotionSections(list<selectOption> selectedSalesmotionSections){
        this.selectedSalesmotionSections=selectedSalesmotionSections;
    }
    public List<string> gettermsToAdd(){
        return termsToAdd;
    }
    public void settermsToAdd(List<string> termsToAdd){
        this.termsToAdd=termsToAdd;
    }
    public List<string> gettermsToRemove(){
       return termsToRemove;
    }
    public void settermsToRemove(List<string> termsToRemove){
        this.termsToRemove=termsToRemove;
    }
    public List<string> getpagesToAdd(){
        return pagesToAdd;
    }
    public void setpagesToAdd(List<string> pagesToAdd){
        this.pagesToAdd=pagesToAdd;
    }
     public List<string> getstagesToAdd(){
        return stagesToAdd;
    }
    public void setstagesToAdd(List<string> stagesToAdd){
        this.stagesToAdd=stagesToAdd;
    }
     public List<string> getstagesToRemove(){
        return stagesToRemove;
    }
    public void setstagesToRemove(List<string> stagesToRemove){
        this.stagesToRemove=stagesToRemove;
    }
     public Set<string> getallStages(){
        return allStages;
    }
    public void setallStages(Set<string> allStages){
        this.allStages=allStages;
    }

    public Set<string> getaddedStages(){
        return addedStages;
    }
    public void setaddedStages(Set<string> allStages){
        this.addedStages=addedStages;
    }


    public List<string> getpagesToRemove(){
        return pagesToRemove;
    }
    public void setpagesToRemove(List<string> pagesToRemove){
        this.pagesToRemove=pagesToRemove;
    }
     public List<string> getsectionsToAdd(){
        return sectionsToAdd;
    }
    public void setsectionsToAdd(List<string> sectionsToAdd){
        this.sectionsToAdd=sectionsToAdd;
    }
     public List<string> getsectionsToRemove(){
        return sectionsToRemove;
    }
    public void setsectionsToRemove(List<string> sectionsToRemove){
        this.sectionsToRemove=sectionsToRemove;
    }

    public List<selectOption> getSelectedTandC(){
        //selectedTandC=SortOptionList(selectedTandC);
        
        return selectedTandC;
    }
   
    
    public void setselectedTandC(list<selectOption> selectedTandC){
        this.selectedTandC=selectedTandC;
    }
    public PageReference NextPage1(){
        //getSalesmotionRecords();
            PageReference pageref;
       
         if(unSelectedDomainName.size()>0 && unSelectedSolutionType.size()>0 && selectedBSegs.size()==0 && selectedSolutionType.size()==0 && TandCProducts.size()==0){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: Please select domain name or solution type or Product.');
            ApexPages.addMessage(msg);
            pageref=null;
            return pageref;
        }else if(previousSalesmotionedited==1){
            selectedTandC.Clear();
            TandCId.Clear();            
            initializeTandC();
            pageref=new PageReference('/apex/SMFindNReplace_SalesMotion');            
        }else if(previousSalesmotion==true){
            //initializeTandC();
            pageref=new PageReference('/apex/SMFindNReplace_SalesMotion');  
        }else{
            initializeTandC();
            pageref=new PageReference('/apex/SMFindNReplace_SalesMotion');
        }
        return pageref;
    }
    
    public PageReference NextPage2(){
        PageReference pageref;
        if(availableTandC.size()>0 && SelectedTandC.size()==0){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: Please select SalesMotion.');
            ApexPages.addMessage(msg);
            pageref=null;
            return pageref;
        }else if(previousSalesmotionPagesedited==1){
            selectedPages.Clear();
            TandCPagesId.Clear();
            initializeSalesmotionPages();
            pageref=new PageReference('/apex/SMFindNReplace_SMPages');
        }else if(previousSalesmotionPages==true){
            pageref=new PageReference('/apex/SMFindNReplace_SMPages');
        }else{
            initializeSalesmotionPages();
            pageref=new PageReference('/apex/SMFindNReplace_SMPages');
        }
        return pageref;
    }
    
    public PageReference NextPage3(){
        PageReference pageref;
        if(selectedPages.size()==0 && availablePages.size()>0){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: Please select SalesMotionPages.');
            ApexPages.addMessage(msg);
            pageref=null;
            return pageref;
        }else{            
            pageref=new PageReference('/apex/SMFindNReplace_SMStages');            
        }
        return pageref;
    }

    Public PageReference NextPage4(){
        PageReference pageref;
        if(selectedStages.size()==0 && availableStages.size()>0){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: Please select stages.');
            ApexPages.addMessage(msg);
            pageref=null;
            return pageref;
        }else if(previousSalesmotionSectionsedited==1){
            selectedSections.Clear();
            TandCSections.Clear();
            initializeSalesmotionSections();
            pageref=new PageReference('/apex/SMFindNReplace_SMPageSection');   
            
       }else if(previousSalesmotionPages==true||previousSalesmotionSections==true){
           //initializeSalesmotionSections();
            pageref=new PageReference('/apex/SMFindNReplace_SMPageSection');   
        }
        else{
            initializeSalesmotionSections();
            pageref=new PageReference('/apex/SMFindNReplace_SMPageSection');   
        }
        
      
        
        return pageref;
    }
    
    
    //........................SELECT ALL........................// 
    Public PageReference SelectAllSalesMotion(){
         termsToAdd.Clear();
        //termsToAdd=termsToAddatSkip;
        SelectedTandC.Clear();
        termsToRemove.Clear();
        availableTandC.Clear();
        
        if(selectedBSegs.size()>0 && selectedSolutionType.size()==0 && TandCProducts.size()==0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Domain__c in:selectedBSegs  order by Name  Limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                SelectedTandC.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(selectedBSegs.size()==0 && selectedSolutionType.size()>0 && TandCProducts.size()==0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Solution_Type__c in:selectedSolutionType  order by Name  Limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                SelectedTandC.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(selectedBSegs.size()>0 && selectedSolutionType.size()>0 && TandCProducts.size()==0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Domain__c in:selectedBSegs AND Solution_Type__c in:selectedSolutionType order by name Limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                SelectedTandC.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(selectedBSegs.size()==0 && selectedSolutionType.size()==0 && TandCProducts.size()>0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Product__c in:TandCProducts order by Name  Limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                SelectedTandC.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(selectedBSegs.size()>0 && selectedSolutionType.size()>0 && TandCProducts.size()>0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where (Domain__c in:selectedBSegs AND Solution_Type__c in:selectedSolutionType) OR Product__c in:TandCProducts  order by name Limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                SelectedTandC.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(selectedBSegs.size()==0 && selectedSolutionType.size()>0 && TandCProducts.size()>0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Solution_Type__c in:selectedSolutionType OR Product__c in:TandCProducts  order by name Limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                SelectedTandC.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(selectedBSegs.size()>0 && selectedSolutionType.size()==0 && TandCProducts.size()>0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Domain__c in:selectedBSegs OR Product__c in:TandCProducts  order by name Limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                SelectedTandC.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        initializeSalesmotionPages();
        return Page.SMFindNReplace_SMPages;
    }
       
    Public PageReference SelectAllPages(){
        pagestoAdd.Clear();        
        selectedPages.Clear();
        pagesToRemove.Clear();
        availablePages.Clear();
        //addCurSelectedPages();
        
        
        for(Sales_Motion_Page__c tAndC :[select Id,Name,Sales_Motion_Name__c,Sales_Motion_Name__r.name from Sales_Motion_Page__c where Sales_Motion_Name__c in :TandCId  Limit 1000]){            
            TandCPagesId.add(tAndC.Id);
            pagestoAdd.add(tAndC.Id);
            pagesToRemove.add(tAndC.Id);
            SelectedPages.add(new selectOption(tAndC.Id,tAndC.Sales_Motion_Name__r.Name+':'+tAndC.Name));
        
        } 
        
        return Page.SMFindNReplace_SMStages;
    }
    public PageReference SelectAllStages(){
        stagesToAdd.clear();
        availableStages.clear();
        selectedStages.clear();
        
        Schema.DescribeFieldResult fieldResult =Sales_Motion_Page_Section__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        TandCStages.add('No Stages');  
        stagesToRemove.add('No Stages'); 
        selectedStages.add(new selectOption('No Stages','No Stages'));
        for(Schema.PicklistEntry f : ple){
            stagesToRemove.add(f.getValue()); 
            selectedStages.add(new selectOption(f.getValue(),f.getValue()));
            TandCStages.add(f.getValue());            
        }        
        for(String tAndC : pagesToAdd){            
            TandCPagesId.add(tAndC);
        }        
        
        initializeSalesmotionSections();
        return Page.SMFindNReplace_SMPageSection;
    }
    public PageReference SelectAllSections(){        
        
        sectionsToAdd.Clear();        
        selectedSections.Clear();
        sectionsToRemove.Clear();
        availableSections.Clear();        
        
        for(Sales_Motion_Page_Section__c obj:[select Id,Name,Stage__c,Section_Content__c,Sales_Motion_Page__r.Name,Sales_Motion_Page__r.Sales_Motion_Name__r.name from Sales_Motion_Page_Section__c where Sales_Motion_Page__c in :TandCPagesId Limit 1000]){
            if(TandCStages.contains('No Stages') && obj.Stage__c==null&& obj.Section_Content__c!=null){
                TandCSections.add(obj.Id);
                sectionsToRemove.add(obj.Id);
                sectionsToAdd.add(obj.Id);            
                selectedSections.add(new selectOption(obj.Id,obj.Sales_Motion_Page__r.Sales_Motion_Name__r.Name+':'+obj.Sales_Motion_Page__r.Name+':'+obj.Name));
           }
           if(TandCStages.contains(obj.Stage__c)&& obj.Section_Content__c!=null){
               TandCSections.add(obj.Id);
                sectionsToRemove.add(obj.Id);
                sectionsToAdd.add(obj.Id);            
                selectedSections.add(new selectOption(obj.Id,obj.Sales_Motion_Page__r.Sales_Motion_Name__r.Name+':'+obj.Sales_Motion_Page__r.Name+':'+obj.Name));
           
           }
            
        }         
        return Page.SalesMotionFindNReplacePage;
    }   
    
    //---------------END of Select ALL -----------------------------//
    
    public PageReference PreviousPage2(){
         previousSalesmotion=true;
        return Page.SMFindNReplace_DomainNSolnType;
    }
    
   
    public PageReference CancelPage2(){
        
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear(); 
        availableTandC.Clear(); 
        selectedTandC.Clear();
        availableProducts.Clear();
        selectedProducts.Clear();  
        
         //-----------
         stagesToAdd.Clear();
        stagesToRemove.Clear();
        availableStages.Clear();
        selectedStages.Clear();
        
         //---------------
        
        if(selectedBSegs!=null){
            unSelectedDomainName.addAll(selectedBSegs);
            selectedBSegs.clear();
        }        
        unselected.clear();
        
       if(selectedSolutionType!=null){ 
            unSelectedSolutionType.addAll(selectedSolutionType);   
            selectedSolutionType.clear();            
        }
        unselectedSolnTypes.clear();
      loadStages();
      loadProducts(); 
        
        return Page.SMFindNReplace_DomainNSolnType;
    }
    public PageReference PreviousPage3(){
        previousSalesmotionPages=true;
        return Page.SMFindNReplace_SalesMotion;
    }
    Public PageReference CancelPage3(){
        SalesMotionInfo.Domain__c=null;
        SalesMotionInfo.Solution_Type__c=null; 
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCPagesId.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear();
        pagesToAdd.Clear();
        pagesToRemove.Clear(); 
        availableTandC.Clear(); 
        selectedTandC.Clear();
        availablePages.Clear();
        selectedPages.Clear();  
        availableProducts.Clear();
        selectedProducts.Clear();  

        
         //-----------
         stagesToAdd.Clear();
        stagesToRemove.Clear();
        availableStages.Clear();
        selectedStages.Clear();
        
        if(selectedBSegs!=null){
            unSelectedDomainName.addAll(selectedBSegs);
            selectedBSegs.clear();
        }        
        unselected.clear();
        
       if(selectedSolutionType!=null){ 
            unSelectedSolutionType.addAll(selectedSolutionType);   
            selectedSolutionType.clear();            
        }
        unselectedSolnTypes.clear();
        
        
       loadStages(); 
       loadProducts();      
        return Page.SMFindNReplace_DomainNSolnType;
    }
    
    public PageReference PreviousPage4(){
        return Page.SMFindNReplace_SMPages;
    }
    public PageReference CancelPage4(){
        SalesMotionInfo.Domain__c=null;
        SalesMotionInfo.Solution_Type__c=null;
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCPagesId.Clear();
        TandCStages.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear();
        pagesToAdd.Clear();
        pagesToRemove.Clear(); 
        stagesToAdd.Clear();
        stagesToRemove.Clear();
        availableTandC.Clear(); 
        selectedTandC.Clear();
        availablePages.Clear();
        selectedPages.Clear(); 
        availableStages.Clear();
        selectedStages.Clear();
        availableProducts.Clear();
        selectedProducts.Clear();  
        
         //-----------       
        
         
        
        if(selectedBSegs!=null){
            unSelectedDomainName.addAll(selectedBSegs);
            selectedBSegs.clear();
        }        
        unselected.clear();
        
       if(selectedSolutionType!=null){ 
            unSelectedSolutionType.addAll(selectedSolutionType);   
            selectedSolutionType.clear();            
        }
        unselectedSolnTypes.clear();
        
         loadStages();
         loadProducts();
        return Page.SMFindNReplace_DomainNSolnType;
    }

    public PageReference PreviousPage5(){
       // previousSalesmotionSections=true;
        previousSalesmotionSections=true;
        return Page.SMFindNReplace_SMStages;
    }
    
    public PageReference CancelPage5(){
        searchText=''; 
        replaceText='';
        //Version 1.1
        if(rtfReplaceTextObj!=null) rtfReplaceTextObj.Body='';
        SalesMotionInfo.Domain__c=null;
        SalesMotionInfo.Solution_Type__c=null;
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCPagesId.Clear();
        TandCStages.Clear();
        TandCSections.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear();
        pagesToAdd.Clear();
        pagesToRemove.Clear(); 
        stagesToAdd.Clear();
        stagesToRemove.Clear();
        sectionsToAdd.Clear();
        sectionsToRemove.Clear();
        availableTandC.Clear(); 
        selectedTandC.Clear();
        availablePages.Clear();
        selectedPages.Clear(); 
        availableStages.Clear();
        selectedStages.Clear();          
        availableSections.Clear();
        availableProducts.Clear();
        selectedProducts.Clear(); 
        selectedSections.Clear();
        SMPageSectionList.Clear();
        //---------------
        
        if(selectedBSegs!=null){
            unSelectedDomainName.addAll(selectedBSegs);
            selectedBSegs.clear();
        }        
        unselected.clear();
        
       if(selectedSolutionType!=null){ 
            unSelectedSolutionType.addAll(selectedSolutionType);   
            selectedSolutionType.clear();            
        }
        unselectedSolnTypes.clear();
        loadStages();
        loadProducts();
        return Page.SMFindNReplace_DomainNSolnType;
    }

    
    //---------------------------------------Find N Replace---------------------------------------//
    
    Public PageReference Submit(){
        PageReference pageref; 
        
        if(selectedSections.size()==0 && availableSections.size()>0){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: Please select SalesMotionSections.');
            ApexPages.addMessage(msg);
            pageref=null;
            return pageref;
        }else{
           // initializeSalesmotionSections();            
            pageref=new PageReference('/apex/SalesMotionFindNReplacePage');            
        }
        
        searchText=''; 
        replaceText='';
        //Version 1.1
        if(rtfReplaceTextObj!=null) rtfReplaceTextObj.Body=''; 
        return pageref; 
    }
    
    Public PageReference queryRecords(){                   
        showTbl=false;
        showSearch=true;
        userMsg=false;
        searchText=''; 
        replaceText=''; 
        //Version 1.1
        if(rtfReplaceTextObj!=null) rtfReplaceTextObj.Body='';      
        return null;
    }
    
    Public String getSearchText() {
        return searchText;
    }
    
    Public void setSearchText(String s) {
        this.searchText = s;
    }
    
    Public String getReplaceText() {
        //return replaceText;
        //Version 1.1
        return rtfReplaceTextObj.Body;
    }
    
    Public void setReplaceText(String s) {
        //this.replaceText = s;
        //Version 1.1
        this.rtfReplaceTextObj.Body = s;
    }
    
    
    Public List<SMPageSection> getSMPageSectionList() {
        return SMPageSectionList;
    } 
    
    Public  void setSMPageSectionList(List<SMPageSection> sectionList) {       
        this.SMPageSectionList=sectionList;
    } 
    
    Public Boolean getUserMsg() {
        return userMsg;
    }
    
    Public  void setUserMsg(Boolean bool) {        
        this.userMsg=bool;
    }
    
    Public Boolean getShowTbl() {
        return showTbl;
    }
    
    Public  void setShowTbl(Boolean bool) {        
        this.showTbl=bool;
    }
    
    Public Boolean getShowSearch() {
        return showSearch;
    }
    
    Public  void setShowSearch(Boolean bool) {        
        this.showSearch=bool;
    }
    
    
    Public Pagereference searchSectionContent(){  
        if(searchText==null || searchText==''){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: Please enter a search criteria.');
            ApexPages.addMessage(msg);
            return null;
        }
        //if(replaceText==null || replaceText==''){
        //Version 1.1
        if(rtfReplaceTextObj.Body==null || rtfReplaceTextObj.Body==''){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: Please enter a replace criteria.');
            ApexPages.addMessage(msg);
            return null;
        }
        if(searchText!=null && searchText==null && searchText.length()<=2){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: Please enter more than 2 alphabets as search text .');
            ApexPages.addMessage(msg);
            return null;
        }
        //if((searchText!=null && replaceText!=null)&&(searchText!='' && replaceText!='')){
        //Version 1.1
        if((searchText!=null && rtfReplaceTextObj.Body!=null)&&(searchText!='' && rtfReplaceTextObj.Body!='')){
            // where Id in:TandCSections
            SalesMotionPageSectionRecs=[Select id,Name,Configure_Country__c,Country__c,Country_List__c,SalesEdge_Category__c,
                                     Sales_Motion_Page__c,Sales_Motion_Page__r.name,Sales_Motion_Page__r.Sales_Motion_Name__c,
                                     Sales_Motion_Page__r.Sales_Motion_Name__r.name ,Section_Content__c,Side_Bar__c,Sort_Order__c,
                                     Stage__c,Type__c from Sales_Motion_Page_Section__c where Id in:TandCSections  order by Name  Limit 1000];
               
            String searchTxtLowerCase;   
            for(Sales_Motion_Page_Section__c sectionElt:SalesMotionPageSectionRecs){
                 SMPagesectionMap.put(sectionElt.Id,sectionElt);                               
                if(sectionElt.Section_Content__c!=null && sectionElt.Section_Content__c!=''){                    
                    String content=String.ValueOf(sectionElt.Section_Content__c); 
                    String sectionContent=String.ValueOf(sectionElt.Section_Content__c);
                    system.debug('####sectionContentMK' + sectionContent);
                    String sectionContentLwr=sectionContent.toLowerCase();
                    system.debug('####sectionContentLwrMK' + sectionContentLwr);
                    String searchLwr=searchText.toLowerCase();
                    system.debug('####searchLwrMK' + searchLwr);
                    String subStrContent='';
                    String input='(?i)'+searchText;
                    system.debug('####inputMK' + input);
                    Integer index=0;
                    List<String> searchLst=searchText.split(' ');
                    String FinalContent='';
                    List<String> tagLst;                    
                    
                        //searchLwr=searchLst[i].toLowerCase();
                        //input='(?i)'+searchLst[i];
                    if(sectionContentLwr.contains(searchLwr)){
                        index = sectionContentLwr.indexOf(searchLwr);
                        system.debug('####Entered here' + index );
                        String actual= content.substring(index,index+searchText.length());  
                        system.debug('####actual:' + actual);                        
                        String formatted='<span style="background-color:#FFFF00" title="YellowHighLighterSpan">'+actual+'</span>';
                        system.debug('####formatted:' + formatted);
                        system.debug('####FinalContent:' + FinalContent);
                        if(!sectionContentLwr.contains('/>')&&!sectionContentLwr.contains('</')){
                        
                            //input='(?i)'+searchLwr;
                            if(FinalContent==''){
                                FinalContent=content.replaceAll(input,formatted);
                                system.debug('####FinalContent:' + FinalContent);
                            }
                            if(FinalContent!=''&&FinalContent!=null){                                                                       
                                subStrContent='';                                    
                                if(FinalContent!=''&&FinalContent!=null){
                                    tagLst=FinalContent.split('<');
                                    system.debug('####tagLst:' + tagLst);

                                }                                    
                                for(String elt:tagLst){  
                                    String lwr=elt.tolowercase();                                                                               
                                    Pattern MyPattern = Pattern.compile(input);
                                    if(elt.contains('>')){
                                        Integer idx=elt.indexOf('>');
                                        String xyz=lwr.Substring(idx);
                                        if(xyz.contains(searchLwr)){
                                            xyz=elt.Substring(idx);
                                            Matcher MyMatcher = MyPattern.matcher(xyz);
                                            xyz=MyMatcher.replaceAll(formatted);
                                            //xyz=xyz.replaceAll(input,formatted);
                                            subStrContent=subStrContent+elt.substring(0,idx)+xyz+'<';                                                    
                                        }else{
                                            subStrContent=subStrContent+elt+'<';
                                        }
                                    }else{
                                        if(lwr.contains(searchLwr)){
                                            Matcher MyMatcher= MyPattern.matcher(elt);                     
                                            elt=MyMatcher.replaceAll(formatted);
                                            //str=str.replaceAll(input,formatted);
                                            subStrContent=subStrContent+elt+'<';
                                        }else{
                                             subStrContent=subStrContent+elt+'<';
                                        }
                                    }
                                }                            
                                FinalContent=subStrContent.substring(0,subStrContent.length()-1);   
                                tagLst.clear();
                            }
                            
                        }
                        if(sectionContentLwr.contains('/>')||sectionContentLwr.contains('</')){
                            //input='(?i)([<]*)([>]*)'+searchText;  
                            //input='(?i)'+searchLst[i];
                            FinalContent=subStrContent;
                            system.debug('####FinalContent2:' + FinalContent);
                            subStrContent='';
                            if(FinalContent==''){
                                tagLst=content.split('<');
                            }
                            if(FinalContent!=''&&FinalContent!=null){
                                tagLst=FinalContent.split('<');
                            }                                    
                            for(String elt:tagLst){  
                                String lwr=elt.tolowercase();                                                                               
                                Pattern MyPattern = Pattern.compile(input);
                                if(elt.contains('>')){
                                    Integer idx=elt.indexOf('>');
                                    String xyz=lwr.Substring(idx);
                                    if(xyz.contains(searchLwr)){
                                        xyz=elt.Substring(idx);
                                        Matcher MyMatcher = MyPattern.matcher(xyz);
                                        xyz=MyMatcher.replaceAll(formatted);
                                        //xyz=xyz.replaceAll(input,formatted);
                                        subStrContent=subStrContent+elt.substring(0,idx)+xyz+'<';
                                            
                                    }else{
                                        subStrContent=subStrContent+elt+'<';
                                    }
                                }else{
                                    if(lwr.contains(searchLwr)){
                                        Matcher MyMatcher= MyPattern.matcher(elt);                     
                                        elt=MyMatcher.replaceAll(formatted);
                                        //str=str.replaceAll(input,formatted);
                                        subStrContent=subStrContent+elt+'<';
                                    }else{
                                         subStrContent=subStrContent+elt+'<';
                                    }
                                }
                            }                            
                            FinalContent=subStrContent.substring(0,subStrContent.length()-1);   
                            tagLst.clear();
                        }///xxxx
                    }
                        
                   
                    if(FinalContent.contains('<span style="background-color:#FFFF00" title="YellowHighLighterSpan">')){
                        //subStrContent=subStrContent.substring(0,subStrContent.length()-1);
                        //if(!FinalContent.contains('</img>')||!FinalContent.contains('/servlet/')||!FinalContent.contains('<img')){
                            sectionElt.Section_Content__c=FinalContent;
                            SMPageSection  wrapperElt=new SMPageSection(sectionElt); 
                            SMPageSectionList.add(wrapperElt);
                        //}
                    }
                    FinalContent='';
                    
                }  //EOF IF                                                     
            }                        
            showTbl=true;
            showSearch=false;
            userMsg=false; 
        }                                      
        return null;
    }
    
    Public Pagereference replaceSectionContent(){  
        for(SMPageSection wrapperElt:SMPageSectionList){            
            if(wrapperElt.selected==true){                
                Sales_Motion_Page_Section__c SMSectionVar=SMPagesectionMap.get(wrapperElt.SMPageSection.Id);
                String sectionContent=String.ValueOf(SMSectionVar.Section_Content__c);
                String content=String.ValueOf(SMSectionVar.Section_Content__c);                 
                content=content.replaceAll('<span style="background-color:#FFFF00" title="YellowHighLighterSpan">',''); 
                content=content.replaceAll('</span>',''); 
                sectionContent=sectionContent.replaceAll('<span style="background-color:#FFFF00" title="YellowHighLighterSpan">',''); 
                sectionContent=sectionContent.replaceAll('</span>','');                
                sectionContent=sectionContent.toLowerCase();
                String searchLwr=searchText.toLowerCase();
                //String input='(?i)'+searchText; 
                String input='(?i)'+searchText;  
                             
                if(sectionContent.contains(searchLwr)){                                                           
                    Pattern MyPattern = Pattern.compile(input);                    
                    Matcher MyMatcher = MyPattern.matcher(content);
                    //content=MyMatcher.replaceAll(replaceText);
                    //Version 1.1
                    content=MyMatcher.replaceAll(rtfReplaceTextObj.Body);
                    SMSectionVar.Section_Content__c=content;
                    SalesMotionPageSectionUpdateRecs.add(SMSectionVar);
                }                 
            }                                                       
        }
        if(SalesMotionPageSectionUpdateRecs.size()>0){
            update SalesMotionPageSectionUpdateRecs;
            UserMsg=true;            
            showTbl=false;
            showSearch=false;            
        }  
        BKPSMPageSectionList=SMPageSectionList;
        SMPageSectionList.clear();
        SalesMotionPageSectionUpdateRecs.clear();  
        searchText=''; 
        replaceText='';
        //Version 1.1
        if(rtfReplaceTextObj!=null) rtfReplaceTextObj.Body='';                
        return null;
    }
    
    
    public PageReference PreviousPage6(){
       
        previousSalesmotionSections=true;
        return Page.SMFindNReplace_SMPageSection;
    }
    public PageReference ChangeFindNReplaceCriteria(){
        searchText='';
        replaceText='';
        //Version 1.1
        if(rtfReplaceTextObj!=null) rtfReplaceTextObj.Body='';
        UserMsg=false;            
        showTbl=false;
        showSearch=true; 
        SMPageSectionList.clear();       
        return null;
    }
    
    public PageReference exit(){
        searchText=''; 
        replaceText='';
        //Version 1.1
        if(rtfReplaceTextObj!=null) rtfReplaceTextObj.Body='';
        if(selectedBSegs!=null){
            unSelectedDomainName.addAll(selectedBSegs);
            selectedBSegs.clear();
        }        
        unselected.clear();
        
       if(selectedSolutionType!=null){ 
            unSelectedSolutionType.addAll(selectedSolutionType);   
            selectedSolutionType.clear();            
        }
        unselectedSolnTypes.clear();
        
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCPagesId.Clear();
        TandCStages.Clear();
        TandCSections.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear();
        pagesToAdd.Clear();
        pagesToRemove.Clear(); 
        stagesToAdd.Clear();
        stagesToRemove.Clear();
        sectionsToAdd.Clear();
        sectionsToRemove.Clear();
        availableTandC.Clear(); 
        selectedTandC.Clear();
        availablePages.Clear();
        selectedPages.Clear(); 
        availableStages.Clear();
        selectedStages.Clear();          
        availableSections.Clear();
        selectedSections.Clear();
        availableProducts.Clear();
        selectedProducts.Clear(); 
        SMPageSectionList.Clear();
        SalesMotionPageSectionUpdateRecs.clear();
        Schema.DescribeFieldResult fieldResult =Sales_Motion_Page_Section__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();    
        availableStages.add(new SelectOption('No Stages', 'No Stages'));       
        for(Schema.PicklistEntry f : ple){
            availableStages.add(new SelectOption(f.getLabel(), f.getValue()));
            SetOfStages.add(f.getValue());
        }
        loadProducts();
        return Page.SMFindNReplace_DomainNSolnType;
    }
}