/* 
Author: Micky Toms

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0                     Micky        Created for MultiEdit Page
1.0                     Hanan        Created for FindAndReplace Page
                                     
1.1     27-Nov-2012     Micky        Created for adding Salesmotion Product list to MultiEdit page  

*/ 
   
public class SalesMotion_MultiEditPageController{
    public Sales_Motion__c SalesMotionInfo=new Sales_Motion__c();
    Public Set<string> TandC= new Set<string>();
    Public Set<string> TandCId= new Set<string>();
    Public Set<string> TandCPagesId= new Set<string>();
    Public Set<string> TandCStages= new Set<string>();
    Public Set<string> TandCSections= new Set<string>();
    Public Set<string> TandCDomain= new Set<string>();
    Public Set<string> TandCSolutionType= new Set<string>();
    Public Set<string> TandCProducts= new Set<string>();
    Public Set<string> SalesmotionPages= new Set<string>();
    Public Set<string> SalesmotionStages= new Set<string>();
    Public Set<string> SalesmotionSections= new Set<string>();
    Public Set<string> SalesmotionRecords= new Set<string>();
    Public List<string> termsToAdd = new List<string>();
    Public List<string> termsToAddatSkip=new List<string>();
    Public List<string> termsToAddId = new List<string>();
    Public List<string> termsToRemove = new List<string>();
    Public List<string> pagesToAdd = new List<string>();
    Public List<string> pagesToAddatSkip = new List<string>();
    Public List<string> pagesToRemove = new List<string>();
    Public List<string> stagesAvailable = new List<string>();
    Public List<string> stagesAdded = new List<string>();
    Public List<string> domainsToAdd = new List<string>();
    Public List<string> domainsToRemove = new List<string>();
    Public List<string> solutionTypeToAdd = new List<string>();
    Public List<string> solutionTypeToRemove = new List<string>();
    Public List<string> sectionsToAdd = new List<string>();
    Public List<string> sectionsToRemove = new List<string>();
    Public List<string> productsToAdd = new List<string>();
    Public List<string> productsToRemove = new List<string>();
    Public List<selectOption> fullAvailableSalesmotions = new List<SelectOption>();
    Public List<selectOption> fullavailablePages= new List<SelectOption>();
    Public List<selectOption> fullavailableStages= new List<SelectOption>();
    Public List<selectOption> fullavailableSections= new List<SelectOption>();
    Public List<selectOption> availableSalesmotions = new List<selectOption>();
    Public List<selectOption> availablePages= new List<selectOption>();
    Public List<selectOption> availableSections= new List<selectOption>();
    Public List<selectOption> stages= new List<selectOption>();
    Public List<selectOption> availableStages= new List<selectOption>();
    Public List<string> availableStagesatSkip= new List<string>();
    Public List<selectOption> selectedStages= new List<selectOption>();
    Public List<selectOption> availableDomains= new List<selectOption>();
    Public List<selectOption> selectedDomains= new List<selectOption>();
    Public List<selectOption> availableSolutionType= new List<selectOption>();
    Public List<selectOption> selectedSolutionType= new List<selectOption>();
    Public List<selectOption> selectedSalesmotions = new List<selectOption>();
    Public List<selectOption> selectedPages = new List<selectOption>();
    Public List<selectOption> selectedSections = new List<selectOption>();
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
    Public Map<Id,String> mapOfSalesmotionPagestoNameId= new  Map<Id,String>();
    Public Map<string,Id> mapOfSalesmotionSectionsIdtoName= new  Map<String,Id>();
    Public Map<string,Id> mapOfProductIdtoName= new  Map<String,Id>();
    Public List<Sales_Motion__c> salesmotionproduct=new List<Sales_Motion__c>();
    Public Boolean previousSalesmotion=false;
    Public Boolean previousSalesmotionPages=false;
    Public Boolean previousSalesmotionSections=false;
    Public Integer previousSalesmotionedited=0;
    Public Integer previousSalesmotionPagesedited=0;
    Public Integer previousSalesmotionSectionsedited=0;
    Map<Id,String> salesMotionMap=new Map<Id,String>(); 
    Map<Id,String> pagesMap=new Map<Id,String>(); 
    Map<Id,String> sectionMap=new Map<Id,String>(); 
    
   //Initializing the controller
    public SalesMotion_MultiEditPageController(){
        loadStages();
        loadDomains();
        loadSolutionTypes();
        loadProducts();
        //initializeSalesmotions();
   }

    public void loadStages(){
        Schema.DescribeFieldResult fieldResult =Sales_Motion_Page_Section__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        availableStages.add(new SelectOption('No Stages', 'No Stages'));  
        availableStagesatSkip.add('No Stages');      
        for(Schema.PicklistEntry f : ple){
            availableStages.add(new SelectOption(f.getLabel(), f.getValue()));
            availableStagesatSkip.add(f.getValue());
        }
    }
    public void loadDomains(){
        Schema.DescribeFieldResult fieldResult =Sales_Motion__c.Domain__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for(Schema.PicklistEntry f : ple){
            availableDomains.add(new SelectOption(f.getLabel(), f.getValue()));
        }
    }
    public void loadSolutionTypes(){
        Schema.DescribeFieldResult fieldResult =Sales_Motion__c.Solution_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for(Schema.PicklistEntry f : ple){
            availableSolutionType.add(new SelectOption(f.getLabel(), f.getValue()));
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

    public void initializeSalesmotions(){
        fullAvailableSalesmotions.clear();
        availableSalesmotions.clear(); 
        Set<Sales_Motion__c> editModeStdTermsSet = new Set<Sales_Motion__c>();
        List<Sales_Motion__c> editModeStdTermsList;
        List<Sales_Motion__c> newCSMBTandCList = new List<Sales_Motion__c>();
        
        
        if(TandCDomain.size()>0 && TandCSolutionType.size()==0 && TandCProducts.size()==0){
            editModeStdTermsList=[select Id,Name from Sales_Motion__c where Domain__c in:TandCDomain order by name limit 1000];
        }
        if(TandCDomain.size()==0 && TandCSolutionType.size()>0 && TandCProducts.size()==0){
            editModeStdTermsList=[select Id,Name from Sales_Motion__c where Solution_Type__c in:TandCSolutionType order by name limit 1000];
        }
        if(TandCDomain.size()>0 && TandCSolutionType.size()>0 && TandCProducts.size()==0){
            editModeStdTermsList=[select Id,Name from Sales_Motion__c where Domain__c in:TandCDomain AND Solution_Type__c in:TandCSolutionType order by name limit 1000];
        }
        if(TandCDomain.size()==0 && TandCSolutionType.size()==0 && TandCProducts.size()>0){
            editModeStdTermsList=[select Id,Name from Sales_Motion__c where Product__c in:TandCProducts order by name limit 1000];
        }

        if(TandCDomain.size()>0 && TandCSolutionType.size()>0 && TandCProducts.size()>0){
            System.Debug('###MTTandCDomain '+TandCDomain);
            System.Debug('###MTTandCSolutionType '+TandCSolutionType);
            System.Debug('###MTTandCProducts ' +TandCProducts);

            editModeStdTermsList=[select Id,Name from Sales_Motion__c where (Domain__c in:TandCDomain AND Solution_Type__c in:TandCSolutionType) OR Product__c in:TandCProducts order by name limit 1000];
            System.Debug('###MTTeditModeStdTermsList '+editModeStdTermsList);


        }

        if(TandCDomain.size()==0 && TandCSolutionType.size()>0 && TandCProducts.size()>0){
            editModeStdTermsList=[select Id,Name from Sales_Motion__c where Solution_Type__c in:TandCSolutionType OR Product__c in:TandCProducts order by name limit 1000];
        }
        if(TandCDomain.size()>0 && TandCSolutionType.size()==0 && TandCProducts.size()>0){
            editModeStdTermsList=[select Id,Name from Sales_Motion__c where Domain__c in:TandCDomain OR Product__c in:TandCProducts order by name limit 1000];
        }
                
        for(Sales_Motion__c SMVar:editModeStdTermsList){
            editModeStdTermsSet.add(SMVar);
            if(mapOfSalesmotionIdtoName.get(SMVar.Id)==null){
                mapOfSalesmotionIdtoName.put(SMVar.Id,SMVar.id);
            }
            fullAvailableSalesmotions.add(new selectOption(SMVar.Id,SMVar.Name));
            termsToAddatSkip.add(SMVar.Name);
            salesMotionMap.put(SMVar.Id,SMVar.name);
        }
        /*
        for(Sales_Motion__c stdTerm:newCSMBTandCList){
            if(editModeStdTermsSet.contains(stdTerm)){
                termsToAdd.add(stdTerm.Name);
            }
            fullAvailableSalesmotions.add(new selectOption(stdTerm.Name,stdTerm.Name));
        }*/
        availableSalesmotions=fullAvailableSalesmotions;
        system.debug('####availableSalesmotions:' + availableSalesmotions);

        selectedSalesmotions = addToList(selectedSalesmotions,termsToAdd);
        availableSalesmotions = removeFromList(availableSalesmotions,termsToAdd);
        for(string terms:termsToAdd){
            TandC.add(terms);
        }
    }

    public void initializeSalesmotionPages(){
        fullavailablePages.clear();
        availablePages.clear(); 
        system.debug('####TandCId:' + TandCId);
        
        List<Sales_Motion_Page__c> editModeSalesmotionPagesList= [select Name,Sales_Motion_Name__c,Sales_Motion_Name__r.Name  from Sales_Motion_Page__c where Sales_Motion_Name__c in :TandCId  order by name limit 1000];
                        
        for(Sales_Motion_Page__c smPages:editModeSalesmotionPagesList){            
            if(mapOfSalesmotionPagesIdtoName.get(smPages.id)==null){
                mapOfSalesmotionPagesIdtoName.put(smPages.id,smPages.id);
            }
            fullavailablePages.add(new selectOption(smPages.id,smPages.Sales_Motion_Name__r.Name+':'+smPages.Name));
            pagesToAddatSkip.add(smPages.Sales_Motion_Name__r.Name+':'+smPages.Name);
            pagesMap.put(smPages.Id,smPages.Sales_Motion_Name__r.Name+':'+smPages.Name);
        
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
        fullavailableSections.clear();
        availableSections.clear(); 
        List<Sales_Motion_Page_Section__c> editModeSalesmotionSectionsList;
        List<String> lstpageSectionRecords=new List<String>{};
        
        for(Sales_Motion_Page_Section__c smSection:[select Id,Name,Sales_Motion_Page__c,Stage__c,Sales_Motion_Page__r.name,Sales_Motion_Page__r.Sales_Motion_Name__c,
                                                        Sales_Motion_Page__r.Sales_Motion_Name__r.name from Sales_Motion_Page_Section__c where Sales_Motion_Page__c in :TandCPagesId  order by Name limit 1000]){
            
            if(TandCStages.contains(smSection.Stage__c)){
                String salesmotionname= smSection.Sales_Motion_Page__r.Sales_Motion_Name__r.name;
                mapOfSalesmotionPagestoNameId.put(smSection.Sales_Motion_Page__c,salesmotionname);
            
                if(mapOfSalesmotionSectionsIdtoName.get(smSection.Id)==null){
                    mapOfSalesmotionSectionsIdtoName.put(smSection.Id,smSection.id);
                }
                fullavailableSections.add(new selectOption(smSection.Id,salesmotionname+':'+smSection.Sales_Motion_Page__r.Name+':'+smSection.Name));
                sectionMap.put(smSection.Id,salesmotionname+':'+smSection.Sales_Motion_Page__r.Name+':'+smSection.Name);
            }
            if(TandCStages.contains('No Stages') && smSection.Stage__c==null){
                String salesmotionname= smSection.Sales_Motion_Page__r.Sales_Motion_Name__r.name;
                mapOfSalesmotionPagestoNameId.put(smSection.Sales_Motion_Page__c,salesmotionname);
            
                if(mapOfSalesmotionSectionsIdtoName.get(smSection.Id)==null){
                    mapOfSalesmotionSectionsIdtoName.put(smSection.Id,smSection.id);
                }
                fullavailableSections.add(new selectOption(smSection.Id,salesmotionname+':'+smSection.Sales_Motion_Page__r.Name+':'+smSection.Name));
                sectionMap.put(smSection.Id,salesmotionname+':'+smSection.Sales_Motion_Page__r.Name+':'+smSection.Name);
            }
            
        }
        availableSections=fullavailableSections;
        system.debug('####availableSections:' + availableSections);
        selectedSalesmotionSections = addToList(selectedSalesmotionSections ,sectionsToAdd );
        availableSalesmotionSections = removeFromList(availableSalesmotionSections,sectionsToAdd);
        for(string sections:sectionsToAdd){
            salesmotionSections.add(sections);
        }
    }       

    public List<SelectOption> getavailableStages(){
        availableStages.sort();
        return availableStages;
    }

    public List<SelectOption> getavailableDomains(){
        availableDomains=SortOptionList(availableDomains);
        return availableDomains;
    }
    public List<SelectOption> getavailableSolutionType(){
        availableSolutionType=SortOptionList(availableSolutionType);
        return availableSolutionType;
    }

    public Sales_Motion__c getSalesMotionInfo(){
        return SalesMotionInfo;
    }
    public void  SetSalesMotionInfo(Sales_Motion__c SalesMotionInfo){
        this.SalesMotionInfo=SalesMotionInfo;
    }

    // Common method to add selected multiPickList values
    private List<SelectOption> addToList(List<SelectOption> theList, String[] theSelected){
        List<SelectOption> newList = new List<SelectOption>();        
        newList.addAll(theList);
         String valueStr='';
        for(String tAndC : theSelected){
             try{
                if(valueStr==''||valueStr==null){
                     valueStr=salesMotionMap.get(tAndC);
                 }
                 //system.debug('####valueStr from salesMotionMap:' + valueStr);
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
            if(!temptheSelected.containsKey(listItem.getValue())){
                newList.add(new SelectOption(listItem.getValue(), listItem.getLabel()));
            }            
        }        
        return newList;
    }

    public void addCurSalesmotions(){
        if(previousSalesmotionPages==true){
            previousSalesmotionPagesedited=1;
        }   
        selectedSalesmotions = addToList(selectedSalesmotions,termsToAdd);
        availableSalesmotions = removeFromList(availableSalesmotions,termsToAdd);
            for(string terms:termsToAdd){
               TandC.add(terms);
               string idStr=mapOfSalesmotionIdtoName.get(terms);
               TandCId.add(idStr);
            }
          
           
    }
    public void removeCurSalesmotions(){
        if(previousSalesmotionPages==true){
            previousSalesmotionPagesedited=1;
        }
        availableSalesmotions = addToList(availableSalesmotions,termsToRemove);
        selectedSalesmotions = removeFromList(selectedSalesmotions,termsToRemove); 
        for(String terms:termsToRemove){           
            TandC.remove(terms);
            string idStr=mapOfSalesmotionIdtoName.get(terms);
            TandCId.remove(idStr); 
        }
             
    }   
    
     public void addCurSelectedStages(){
          if(previousSalesmotionSections==true){
            previousSalesmotionSectionsedited=1;
        }
          selectedStages = addToList(selectedStages ,stagesAvailable);
          availableStages= removeFromList(availableStages,stagesAvailable);
            for(string terms:stagesAvailable){
               TandCStages.add(terms);
          }                
    }
    public void removeCurSelectedStages(){
        if(previousSalesmotionSections==true){
            previousSalesmotionSectionsedited=1;
        }
        availableStages= addToList(availableStages,stagesAdded);
        selectedStages = removeFromList(selectedStages ,stagesAdded); 
        for(String terms:stagesAdded){           
            TandCStages.remove(terms);
        }
       
     }
     public void addCurSelectedDomains(){
        if(previousSalesmotion==true){
            previousSalesmotionedited=1;
            previousSalesmotionPagesedited=1;
        } 
        selectedDomains = addToList(selectedDomains,domainsToAdd);
        availableDomains= removeFromList(availableDomains,domainsToAdd);
        for(string terms:domainsToAdd){
            TandCDomain.add(terms);
          }                
    }
    public void removeCurSelectedDomains(){
        if(previousSalesmotion==true){
            previousSalesmotionedited=1;
            previousSalesmotionPagesedited=1;
        }
        availableDomains= addToList(availableDomains,domainsToRemove);
        selectedDomains= removeFromList(selectedDomains,domainsToRemove); 
        for(String terms:domainsToRemove){           
            TandCDomain.remove(terms);
        }
       
     }
     public void addCurSelectedSolutionType(){
        if(previousSalesmotion==true){
            previousSalesmotionedited=1;
        }
        selectedSolutionType = addToList(selectedSolutionType ,solutionTypeToAdd);
        availableSolutionType= removeFromList(availableSolutionType,solutionTypeToAdd);
        for(string terms:solutionTypeToAdd){
            TandCSolutionType.add(terms);
        }                
    }
    public void removeCurSelectedSolutionType(){
        if(previousSalesmotion==true){
            previousSalesmotionedited=1;
        }
        availableSolutionType= addToList(availableSolutionType,solutionTypeToRemove);
        selectedSolutionType = removeFromList(selectedSolutionType ,solutionTypeToRemove); 
        for(String terms:solutionTypeToRemove){           
            TandCSolutionType.remove(terms);
        }
       
     }
     
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

    public void addCurSelectedPages(){
        SelectedPages = addToList(SelectedPages ,pagesToAdd);
        availablePages = removeFromList(availablePages ,pagesToAdd);
        system.debug('####pagesToAdd:' + pagesToAdd);

         for(String tAndC : pagesToAdd){
            string idStr=mapOfSalesmotionPagesIdtoName.get(tAndC);
            TandCPagesId.add(idStr);
          }
          system.debug('####TandCPagesId:' + TandCPagesId);

           
    }
    public void removeCurSelectedPages(){
        availablePages = addToList(availablePages ,pagesToRemove);
        SelectedPages = removeFromList(SelectedPages ,pagesToRemove); 
         for (String tAndC : pagesToRemove){
            string idStr=mapOfSalesmotionPagesIdtoName.get(tAndC);
            TandCPagesId.remove(idStr);   
        }       
    }    
     public void addCurSelectedSections(){
        SelectedSections = addToList(SelectedSections,sectionsToAdd);
        availableSections = removeFromList(availableSections,sectionsToAdd);
         for(String tAndC : sectionsToAdd){
            string idStr=mapOfSalesmotionSectionsIdtoName.get(tAndC);
            TandCSections.add(idStr);
          }
        system.debug('####TandCSections:' + TandCSections); 
    }
    public void removeCurSelectedSections(){
       availableSections = addToList(availableSections ,sectionsToRemove);
        SelectedSections = removeFromList(SelectedSections ,sectionsToRemove); 
         for (String tAndC : sectionsToRemove){
            string idStr=mapOfSalesmotionSectionsIdtoName.get(tAndC);
            TandCSections.remove(idStr);   
        }       
    }
     
     //........................SELECT ALL........................// 
     
     public PageReference SelectAllSalesMotions(){
        
        termsToAdd.Clear();
        //termsToAdd=termsToAddatSkip;
        selectedSalesmotions.Clear();
        termsToRemove.Clear();
        availableSalesmotions.Clear();
        
        if(TandCDomain.size()>0 && TandCSolutionType.size()==0 && TandCProducts.size()==0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Domain__c in:TandCDomain order by name limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                selectedSalesmotions.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(TandCDomain.size()==0 && TandCSolutionType.size()>0 && TandCProducts.size()==0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Solution_Type__c in:TandCSolutionType order by name limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                selectedSalesmotions.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(TandCDomain.size()>0 && TandCSolutionType.size()>0 && TandCProducts.size()==0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Domain__c in:TandCDomain AND Solution_Type__c in:TandCSolutionType order by name limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                selectedSalesmotions.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(TandCDomain.size()==0 && TandCSolutionType.size()==0 && TandCProducts.size()>0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Product__c in:TandCProducts order by name limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                selectedSalesmotions.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(TandCDomain.size()>0 && TandCSolutionType.size()>0 && TandCProducts.size()>0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where (Domain__c in:TandCDomain AND Solution_Type__c in:TandCSolutionType) OR Product__c in:TandCProducts order by name limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                selectedSalesmotions.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(TandCDomain.size()==0 && TandCSolutionType.size()>0 && TandCProducts.size()>0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Solution_Type__c in:TandCSolutionType OR Product__c in:TandCProducts order by name limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                selectedSalesmotions.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        if(TandCDomain.size()>0 && TandCSolutionType.size()==0 && TandCProducts.size()>0){            
            for(Sales_Motion__c tAndC :[select Id,Name from Sales_Motion__c where Domain__c in:TandCDomain OR Product__c in:TandCProducts order by name limit 1000]){            
                TandCId.add(tAndC.Id);
                termsToRemove.add(tAndC.Id);
                termsToAdd.add(tAndC.Id);
                selectedSalesmotions.add(new selectOption(tAndC.Id,tAndC.Name));
            }
        }
        
        
        
        if(previousSalesmotionPages==true){
            previousSalesmotionPagesedited=1;
        }   
        //selectedSalesmotions = addToList(selectedSalesmotions,termsToAdd);
        initializeSalesmotionPages();
        return Page.SalesMotion_SelectSMPage_VF_Page;
    }
    
    
        
    Public PageReference SelectAllPages(){        
        pagestoAdd.Clear();        
        selectedPages.Clear();
        pagesToRemove.Clear();
        availablePages.Clear();
                
        for(Sales_Motion_Page__c tAndC :[select Id,Name,Sales_Motion_Name__c,Sales_Motion_Name__r.name from Sales_Motion_Page__c where Sales_Motion_Name__c in :TandCId order by name limit 1000]){            
            TandCPagesId.add(tAndC.Id);
            pagestoAdd.add(tAndC.Id);
            pagesToRemove.add(tAndC.Id);
            SelectedPages.add(new selectOption(tAndC.Id,tAndC.Sales_Motion_Name__r.Name+':'+tAndC.Name));
        } 
        return Page.SalesMotion_SelectStage_VF_Page;
    }
    
    
        public PageReference SelectAllStages(){               
            stagesAvailable.clear();
            availableStages.clear();
            selectedStages.clear();
            Schema.DescribeFieldResult fieldResult =Sales_Motion_Page_Section__c.Stage__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
            
            TandCStages.add('No Stages'); 
            stagesAdded.add('No Stages'); 
            selectedStages.add(new selectOption('No Stages','No Stages'));
            for(Schema.PicklistEntry f : ple){
                stagesAdded.add(f.getValue()); 
                selectedStages.add(new selectOption(f.getValue(),f.getValue()));
                TandCStages.add(f.getValue());                      
            }        
            for(String tAndC : pagesToAdd){
                //string idStr=mapOfSalesmotionPagesIdtoName.get(tAndC);
                //system.debug('####idStr:' + idStr);
                TandCPagesId.add(tAndC);
            }  
            initializeSalesmotionSections();
            return Page.SalesMotion_SelectSMPageSection_VF_Page;
      }
      
      
      
        public PageReference SelectAllSections(){
        sectionsToAdd.Clear();        
        selectedSections.Clear();
        sectionsToRemove.Clear();
        availableSections.Clear();
        
        
        for(Sales_Motion_Page_Section__c obj:[select Id,Name,Stage__c,Sales_Motion_Page__r.Name,Sales_Motion_Page__r.Sales_Motion_Name__r.name from Sales_Motion_Page_Section__c where Sales_Motion_Page__c in :TandCPagesId order by name limit 1000]){
            
            if(TandCStages.contains('No Stages') && obj.Stage__c==null){
                TandCSections.add(obj.Id);
                sectionsToRemove.add(obj.Id);
                sectionsToAdd.add(obj.Id);            
                selectedSections.add(new selectOption(obj.Id,obj.Sales_Motion_Page__r.Sales_Motion_Name__r.Name+':'+obj.Sales_Motion_Page__r.Name+':'+obj.Name));
           }
           if(TandCStages.contains(obj.Stage__c)){
               TandCSections.add(obj.Id);
                sectionsToRemove.add(obj.Id);
                sectionsToAdd.add(obj.Id);            
                selectedSections.add(new selectOption(obj.Id,obj.Sales_Motion_Page__r.Sales_Motion_Name__r.Name+':'+obj.Sales_Motion_Page__r.Name+':'+obj.Name));
           
           }
            
        }  
        PageReference pageRef=queryRecords();
         
        return pageRef;
    }
//.............................................................//
          
    public List<selectOption> getavailableSalesmotions(){
        availableSalesmotions=SortOptionList(availableSalesmotions);
        return availableSalesmotions;
    }
    public List<selectOption> getavailablePages(){
        availablePages=SortOptionList(availablePages);
        return availablePages;
    }
    /*public List<selectOption> getavailableStages(){
        return availableStages;
    } */   
    public List<selectOption> getselectedStages(){

        selectedStages.sort();
        return selectedStages;
    }
     public List<selectOption> getselectedDomains(){
        return selectedDomains;
    }
    public List<selectOption> getselectedSolutionType(){
        return selectedSolutionType;
    }


    public List<selectOption> getselectedPages(){
        return selectedPages;
    }
    public List<selectOption> getselectedSections(){
        return selectedSections;
    }

    public List<selectOption> getselectedProducts(){
        return selectedProducts;
    }
     
    public List<selectoption> getfullAvailableSalesmotions(){
        return fullAvailableSalesmotions;
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
    
    public void setavailableSalesmotions(list<selectOption> availableSalesmotions){
        this.availableSalesmotions=availableSalesmotions;
    }
        
    public void setfullAvailableSalesmotions(list<selectoption> fullAvailableSalesmotions){
        this.fullAvailableSalesmotions=fullAvailableSalesmotions;
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
    public void setavailableDomains(list<selectoption> availableDomains){
        this.availableDomains=availableDomains;
    }
    public void setavailableSolutionType(list<selectoption> availableSolutionType){
        this.availableSolutionType=availableSolutionType;
    }


    public void setstages(list<selectoption> stages){
        this.stages=stages;
    }

    public void setselectedStages(list<selectoption> selectedStages){
        this.selectedStages=selectedStages;
    }
    public void setselectedDomains(list<selectoption> selectedDomains){
        this.selectedDomains=selectedDomains;
    }
    public void setselectedSolutionType(list<selectoption> selectedSolutionType){
        this.selectedSolutionType=selectedSolutionType;
    }
    public void setselectedPages(list<selectoption> selectedPages){
        this.selectedPages=selectedPages;
    }
    public void setselectedSections(list<selectoption> selectedSections){
        this.selectedSections=selectedSections;
    }
    
    public void setselectedProducts(list<selectoption> selectedProducts){
        this.selectedProducts=selectedProducts;
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
    
     public List<selectOption> getavailableProducts(){
        return availableProducts;
    }
     public void setavailableProducts(list<selectOption> availableProducts){
        this.availableProducts=availableProducts;
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
     public List<string> getstagesAvailable(){
        return stagesAvailable;
    }
    public void setstagesAvailable(List<string> stagesAvailable){
        this.stagesAvailable=stagesAvailable;
    }
     public List<string> getstagesAdded(){
        return stagesAdded;
    }
    public void setstagesAdded(List<string> stagesAdded){
        this.stagesAdded=stagesAdded;
    }
    public List<string> getdomainsToAdd(){
        return domainsToAdd;
    }
    public void setdomainsToAdd(List<string> domainsToAdd){
        this.domainsToAdd=domainsToAdd;
    }
     public List<string> getdomainsToRemove(){
        return domainsToRemove;
    }
    public void setdomainsToRemove(List<string> domainsToRemove){
        this.domainsToRemove=domainsToRemove;
    }
    public List<string> getsolutionTypeToAdd(){
        return solutionTypeToAdd;
    }
    public void setsolutionTypeToAdd(List<string> solutionTypeToAdd){
        this.solutionTypeToAdd=solutionTypeToAdd;
    }
     public List<string> getsolutionTypeToRemove(){
        return solutionTypeToRemove;
    }
    public void setsolutionTypeToRemove(List<string> solutionTypeToRemove){
        this.solutionTypeToRemove=solutionTypeToRemove;
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


    
    public List<selectOption> getselectedSalesmotions(){
        return selectedSalesmotions;
    }
    
    public void setselectedSalesmotions(list<selectOption> selectedSalesmotions){
        this.selectedSalesmotions=selectedSalesmotions;
    }
    public PageReference NextPage1(){
        //getSalesmotionRecords();
        system.debug('####TandCDomain:' + TandCDomain);

        if(TandCDomain.isEmpty()&& TandCSolutionType.isEmpty() && TandCProducts.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a value for either Domain or Solution Type or Product or for All'));
            return null;
        }
        else if(previousSalesmotionedited==1){
            selectedSalesmotions.Clear();
            TandCId.Clear();
            initializeSalesmotions();
            return Page.SalesMotion_SelectSM_VFpage;
            
       }
       else if(previousSalesmotion==true){
            return Page.SalesMotion_SelectSM_VFpage;
        }
        else{
            initializeSalesmotions();
            return Page.SalesMotion_SelectSM_VFpage;
        }
    }
    
    public PageReference NextPage2(){
                
        if(TandCId.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Salesmotion Records before clicking Next button'));
            return null;
        }
        else if(previousSalesmotionPagesedited==1){
            selectedPages.Clear();
            TandCPagesId.Clear();
            initializeSalesmotionPages();
            return Page.SalesMotion_SelectSMPage_VF_Page;
            
       }
       else if(previousSalesmotionPages==true){
            return Page.SalesMotion_SelectSMPage_VF_Page;
        }
        else{
            initializeSalesmotionPages();
            return Page.SalesMotion_SelectSMPage_VF_Page;
        }
    }
    
    public PageReference NextPage3(){
        if(TandCPagesId.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Salesmotion Pages before clicking Next button'));
            return null;
        }
        
        else{
            return Page.SalesMotion_SelectStage_VF_Page;
        }
    }

    Public PageReference NextPage4(){
        if(TandCStages.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Stages Pages before clicking Next button'));
            return null;
        }
        else if(previousSalesmotionSectionsedited==1){
            selectedSections.Clear();
            TandCSections.Clear();
            initializeSalesmotionSections();
            return Page.SalesMotion_SelectSMPageSection_VF_Page;
            
       }
       else if(previousSalesmotionSections==true){
            return Page.SalesMotion_SelectSMPageSection_VF_Page;
        }
        else{
            initializeSalesmotionSections();
            return Page.SalesMotion_SelectSMPageSection_VF_Page;
        }
       
    }
    public PageReference PreviousPage2(){
        previousSalesmotion=true;
        return Page.SalesMotion_SelectDomainTypePage;
    }
    public PageReference CancelPage2(){
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCDomain.Clear();
        TandCSolutionType.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear(); 
        availableDomains.Clear();
        availableSolutionType.Clear();
        availableSalesmotions.Clear();
        availableProducts.Clear();
        selectedSalesmotions.Clear(); 
        selectedDomains.Clear();
        selectedSolutionType.Clear();
        selectedProducts.Clear();
        domainsToAdd.Clear();
        domainsToRemove.Clear();
        productsToAdd.Clear();
        productsToRemove.Clear();
        solutionTypeToAdd.Clear();
        solutionTypeToRemove.Clear();
        //-----------
        stagesAdded.Clear();
        stagesAvailable.Clear();
        availableStages.Clear();
        selectedStages.Clear();

        loadStages();
        loadDomains();
        loadSolutionTypes();
        loadProducts();
        return Page.SalesMotion_SelectDomainTypePage;
    }
    public PageReference PreviousPage3(){
        previousSalesmotionPages=true;
        return Page.SalesMotion_SelectSM_VFpage;
    }
    Public PageReference CancelPage3(){
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCPagesId.Clear();
        TandCDomain.Clear();
        TandCSolutionType.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear();
        pagesToAdd.Clear();
        pagesToRemove.Clear(); 
        availableDomains.Clear();
        availableSolutionType.Clear();
        availableSalesmotions.Clear(); 
        availableProducts.Clear(); 
        selectedSalesmotions.Clear();
        selectedDomains.Clear();    
        selectedSolutionType.Clear();
        selectedProducts.Clear();
        domainsToAdd.Clear();
        domainsToRemove.Clear();
        productsToAdd.Clear();
        productsToRemove.Clear();
        solutionTypeToAdd.Clear();
        solutionTypeToRemove.Clear();
        availablePages.Clear();
        selectedPages.Clear(); 
        //-----------
        stagesAdded.Clear();
        stagesAvailable.Clear();
        availableStages.Clear();
        selectedStages.Clear();

        loadStages();
        loadDomains();
        loadSolutionTypes();
        loadProducts();        
        return Page.SalesMotion_SelectDomainTypePage;
    }
    
    public PageReference PreviousPage4(){
        return Page.SalesMotion_SelectSMPage_VF_Page;
    }
    public PageReference CancelPage4(){
        SalesMotionInfo.Domain__c=null;
        SalesMotionInfo.Solution_Type__c=null;
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCPagesId.Clear();
        TandCDomain.Clear();
        TandCPagesId.Clear();
        TandCStages.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear();
        pagesToAdd.Clear();
        pagesToRemove.Clear(); 
        stagesAvailable.Clear();
        stagesAdded.Clear();
        availableDomains.Clear();
        availableSolutionType.Clear();
        availableSalesmotions.Clear(); 
        availableProducts.Clear(); 
        selectedSalesmotions.Clear();
        selectedDomains.Clear();    
        selectedSolutionType.Clear();
        domainsToAdd.Clear();
        domainsToRemove.Clear();
        productsToAdd.Clear();
        productsToRemove.Clear();
        solutionTypeToAdd.Clear();
        solutionTypeToRemove.Clear();
        availablePages.Clear();
        selectedPages.Clear(); 
        selectedProducts.Clear();
        availableStages.Clear();
        selectedStages.Clear();
        loadStages();
        loadDomains();
        loadSolutionTypes();
        loadProducts();
        return Page.SalesMotion_SelectDomainTypePage;
     }  

    public PageReference PreviousPage5(){
        previousSalesmotionSections=true;
        return Page.SalesMotion_SelectStage_VF_Page;
    }
    
    public PageReference CancelPage5(){
        SalesMotionInfo.Domain__c=null;
        SalesMotionInfo.Solution_Type__c=null;
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCPagesId.Clear();
        TandCDomain.Clear();
        TandCPagesId.Clear();
        TandCStages.Clear();
        TandCSections.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear();
        pagesToAdd.Clear();
        pagesToRemove.Clear(); 
        stagesAvailable.Clear();
        stagesAdded.Clear();
        sectionsToAdd.Clear();
        sectionsToRemove.Clear();
        availableDomains.Clear();
        availableSolutionType.Clear();
        availableSalesmotions.Clear(); 
        selectedSalesmotions.Clear();
        selectedDomains.Clear();    
        selectedSolutionType.Clear();
        domainsToAdd.Clear();
        domainsToRemove.Clear();
        productsToAdd.Clear();
        productsToRemove.Clear();
        solutionTypeToAdd.Clear();
        solutionTypeToRemove.Clear();
        availablePages.Clear();
        selectedPages.Clear(); 
        availableStages.Clear();
        selectedStages.Clear();          
        availableSections.Clear();
        availableProducts.Clear(); 
        selectedSections.Clear();
        selectedProducts.Clear();
        loadStages();
        loadDomains();
        loadSolutionTypes();
        loadProducts();
        return Page.SalesMotion_SelectDomainTypePage;
        

    }

     //-------------------------------------------Code for tree structue-----------------------------------------------------//
     
     
     
     
    Map<Id,Sales_Motion__c> SalesMotionRecs=new Map<Id,Sales_Motion__c>();
    Map<Id,Sales_Motion_Page_Section__c> SMSectionRecs=new Map<Id,Sales_Motion_Page_Section__c>();
    List<Sales_Motion_Page__c> SalesMotionPageRecs=new List<Sales_Motion_Page__c>();
    List<Sales_Motion_Page_Section__c> SalesMotionPageSectionRecs=new List<Sales_Motion_Page_Section__c>();
    //List<Sales_Motion_Mappings__c> SalesMotionMapRecs;
    List<SalesMotionToSMPage> SMtoSMPageList=new List<SalesMotionToSMPage>();
    
    Map<Id,List<Sales_Motion_Page__c>> SMToSMPageMap=new Map<Id,List<Sales_Motion_Page__c>>(); 
    Map<Id,List<Sales_Motion_Page_Section__c>> SMPageToSMPageSectionMap=new Map<Id,List<Sales_Motion_Page_Section__c>>(); 
    
    Map<Id,SalesMotionToSMPage> SalesMotionToSMPageMap=new Map<Id,SalesMotionToSMPage>(); 
    Map<Id,SMPageToSMPageSection> IdSMPageToSMPageSectionMap=new Map<Id,SMPageToSMPageSection>();
    
    
    Public PageReference Submit(){        
        return Page.SalesMotionMultiEditPage;
    }
    
    
    
    public class SMPageToSMPageSection{        
        public Sales_Motion_Page__c SMPage{get; set;}
        public List<Sales_Motion_Page_Section__c> SMPageSectionList {get; set;}  
        public String display{get; set;} 
        public String displayShow{get; set;} 
        public String displayHide{get; set;}      
        public SMPageToSMPageSection(Sales_Motion_Page__c page,List<Sales_Motion_Page_Section__c> sectionList){                
                SMPage=page;
                SMPageSectionList=sectionList;
                display='none';
                displayShow='block';
                displayHide='none';
        }
    }
    
    public class SalesMotionToSMPage{
        public Sales_Motion__c SMName{get; set;}        
        public List<SMPageToSMPageSection> SMPageList{get; set;} 
        public String display{get; set;} 
        public String displayShow{get; set;} 
        public String displayHide{get; set;}      
        public SalesMotionToSMPage(Sales_Motion__c name,List<SMPageToSMPageSection> pages){
                SMName=name;
                SMPageList=pages;
                display='none';
                displayShow='block';
                displayHide='none';
        }
    }
    
    
    public PageReference ShowPageRecs(){        
        Id SMId=ApexPages.currentPage().getParameters().get('smid');
        for(SalesMotionToSMPage var:SMtoSMPageList){
            if(var.SMName.Id==SMId){
                var.display='block';
                var.displayShow='none';
                var.displayHide='block';
                 break;
            }               
        }
        return null;
    } 
    
    public PageReference HidePageRecs(){        
        Id SMId=ApexPages.currentPage().getParameters().get('smid2');
        for(SalesMotionToSMPage var:SMtoSMPageList){
            if(var.SMName.Id==SMId){
                var.display='none';
                var.displayShow='block';
                var.displayHide='none';
                 break;
            }               
        } 
        return null;
    }
    
    public PageReference ShowSectionRecs(){
       Id SMId=ApexPages.currentPage().getParameters().get('smid3');
       Id SMPageId=ApexPages.currentPage().getParameters().get('smpageid');
        for(SalesMotionToSMPage var:SMtoSMPageList){
            if(var.SMName.Id==SMId){
              
                SMPageToSMPageSection var2=IdSMPageToSMPageSectionMap.get(SMPageId);
                var2.display='block';
                var2.displayShow='none';
                var2.displayHide='block';
                 //break;
            }               
        }
        return null;
    } 
    
    public PageReference HideSectionRecs(){
       Id SMId=ApexPages.currentPage().getParameters().get('smid4');
       Id SMPageId=ApexPages.currentPage().getParameters().get('smpageid2');
        for(SalesMotionToSMPage var:SMtoSMPageList){
            if(var.SMName.Id==SMId){               
                SMPageToSMPageSection var2=IdSMPageToSMPageSectionMap.get(SMPageId);
                var2.display='none';
                var2.displayShow='block';
                var2.displayHide='none';
            }               
        }
        
        return null;
    }  
    
    //Public PageReference queryRecords
    
    Public PageReference queryRecords(){
       if(selectedSections.Isempty()){
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'You have to add Page Sections before clicking Submit button!'));
        return null;
       }

       //SMtoSMPageList.clear();
       for(Sales_Motion__c SMVar:[Select id,name,Domain__c,SalesEdge_Category__c,SalesMotionUniqueId__c,Solution_Name__c,Solution_Type__c,Product__c from Sales_Motion__c where Id in:TandCId  limit 1000]){
           SalesMotionRecs.put(SMVar.Id,SMVar);
       }    
       
       SalesMotionPageRecs=[Select id,Sales_Motion_Name__c,Sort_Order__c,Stages_Enabled__c,Name from Sales_Motion_Page__c where Id in:TandCPagesId  limit 1000];
       

       if(TandCPagesId.size()>0){
           /*
           SalesMotionPageSectionRecs=[Select id,Name,Configure_Country__c,Country__c,Country_List__c,SalesEdge_Category__c,Sales_Motion_Page__c,
           Section_Content__c,Side_Bar__c,Sort_Order__c,Stage__c,Type__c,Sales_Motion_Page__r.Sales_Motion_Name__R.Solution_Name__c,Sales_Motion_Page__r.Sales_Motion_Name__R.Domain__c,Sales_Motion_Page__r.Sales_Motion_Name__R.Solution_Type__c  
           from Sales_Motion_Page_Section__c where Id in:TandCSections];
           */
           
           for(Sales_Motion_Page_Section__c SMSection:[select Id,Name,Configure_Country__c,Country__c,
               Country_List__c,SalesEdge_Category__c,Sales_Motion_Page__c,
              Sales_Motion_Page__r.name,Sales_Motion_Page__r.Sales_Motion_Name__c,
              Sales_Motion_Page__r.Sales_Motion_Name__r.name,Section_Content__c,Side_Bar__c,
              Sort_Order__c,Stage__c,Type__c,Sales_Motion_Page__r.Sales_Motion_Name__R.Domain__c,
              Sales_Motion_Page__r.Sales_Motion_Name__R.Solution_Type__c,Sales_Motion_Page__r.Sales_Motion_Name__R.Solution_Name__c  from 
              Sales_Motion_Page_Section__c where Id in :TandCSections  order by Name  limit 1000]){ 
              if(TandCStages.contains(SMSection.Stage__c)){
                  SalesMotionPageSectionRecs.add(SMSection);
              }
              if(TandCStages.contains('No Stages') && SMSection.Stage__c==null){
                  SalesMotionPageSectionRecs.add(SMSection);
              }
              
              SMSectionRecs.put(SMSection.Id,SMSection);
          }
          
       }
       
       System.debug('### SalesMotionPageSectionList after querying '+SalesMotionPageSectionRecs);
       
       for(Sales_Motion_Page__c smPage:SalesMotionPageRecs){
           if(SMToSMPageMap.containsKey(smPage.Sales_Motion_Name__c)==false){
               SMToSMPageMap.put(smPage.Sales_Motion_Name__c,new List<Sales_Motion_Page__c>{smPage});    
           }else{
               SMToSMPageMap.get(smPage.Sales_Motion_Name__c).add(smpage);   
           }
           
       }
       
       for(Sales_Motion_Page_Section__c smPageSection:SalesMotionPageSectionRecs){
           if(SMPageToSMPageSectionMap.containsKey(smPageSection.Sales_Motion_Page__c)==false){
               SMPageToSMPageSectionMap.put(smPageSection.Sales_Motion_Page__c,new List<Sales_Motion_Page_Section__c>{smPageSection});    
           }else{
               SMPageToSMPageSectionMap.get(smPageSection.Sales_Motion_Page__c).add(smPageSection);   
           }           
       }
       
       
       for(Sales_Motion__c SMElt:SalesMotionRecs.Values()){
           List<Sales_Motion_Page__c> SMPageList=new List<Sales_Motion_Page__c>();
           if(SMToSMPageMap.size()>0){
               SMPageList=SMToSMPageMap.get(SMElt.Id);  //list of SMPage of the SalesMotion
            }
           List<SMPageToSMPageSection> pagesList=new List<SMPageToSMPageSection>();
           
           if(SMPageList!=null){
               for(Sales_Motion_Page__c SMPageElt:SMPageList){
                   List<Sales_Motion_Page_Section__c> SalesMotionPageSectionList=new List<Sales_Motion_Page_Section__c>();
                   if(SMPageToSMPageSectionMap.size()>0){
                       SalesMotionPageSectionList=SMPageToSMPageSectionMap.get(SMPageElt.Id); //List of SMPageSection of the SMPage
                   }
                   SMPageToSMPageSection PageToSectionVar=new SMPageToSMPageSection(SMPageElt,SalesMotionPageSectionList); //Creating SMPageToSMPageSection object using SMPage &                                                                                                                             // SalesMotionPageSectionList
                   pagesList.add(PageToSectionVar);
                   IdSMPageToSMPageSectionMap.put(SMPageElt.Id,PageToSectionVar);
               }
           }
            
                   SalesMotionToSMPage SMToPages=new SalesMotionToSMPage(SMElt,pagesList); // Creating SalesMotionToSMPage object using SalesMotion variable & pagesList 
                   SMtoSMPageList.add(SMToPages);            
                  
         }

       PageReference pageref=new Pagereference('/apex/SalesMotionMultiEditPage');
       //Page.SalesMotionMultiEditPage
        return pageref;
    }    
    
    public List<SalesMotionToSMPage> getSMtoSMPageList(){
        return SMtoSMPageList; 
    }
    
    public PageReference PreviousPage6(){
        previousSalesmotionSections=true;
        
        //Please do not comment/remove anything below this line
        SMtoSMPageList.clear();
        SalesMotionRecs.clear();
        SalesMotionPageRecs.clear();
        SalesMotionPageSectionRecs.clear();
        SMToSMPageMap.clear();
        SalesMotionToSMPageMap.clear();
        IdSMPageToSMPageSectionMap.clear();
        SMPageToSMPageSectionMap.clear();
        //Please do not comment/remove anything above this line
        
        return Page.SalesMotion_SelectSMPageSection_VF_Page; 
    }
    
    public PageReference CancelPage6(){
        SalesMotionInfo.Domain__c=null;
        SalesMotionInfo.Solution_Type__c=null;
        TandCPagesId.Clear(); 
        TandCId.Clear();
        TandCPagesId.Clear();
        TandCDomain.Clear();
        TandCPagesId.Clear();
        TandCStages.Clear();
        TandCSections.Clear();
        TandCProducts.Clear();
        termsToAdd.Clear();
        termsToRemove.Clear();
        pagesToAdd.Clear();
        pagesToRemove.Clear(); 
        stagesAvailable.Clear();
        stagesAdded.Clear();
        sectionsToAdd.Clear();
        sectionsToRemove.Clear();
        availableDomains.Clear();
        availableSolutionType.Clear();
        availableSalesmotions.Clear(); 
        selectedSalesmotions.Clear();
        selectedDomains.Clear();    
        selectedSolutionType.Clear();
        domainsToAdd.Clear();
        domainsToRemove.Clear();
        solutionTypeToAdd.Clear();
        solutionTypeToRemove.Clear();
        availablePages.Clear();
        availableProducts.Clear();
        selectedProducts.Clear(); 
        selectedPages.Clear(); 
        availableStages.Clear();
        selectedStages.Clear();          
        availableSections.Clear();
        selectedSections.Clear();
        
        if(SalesMotionRecs.size()>0){
            SalesMotionRecs.clear();
        }
        if(SalesMotionPageRecs.size()>0){
             SalesMotionPageRecs.clear();
        }
        if(SalesMotionPageSectionRecs.size()>0){
             SalesMotionPageSectionRecs.clear();
        }
        if(SMToSMPageMap.size()>0){
            SMToSMPageMap.clear();
        }
        if(SalesMotionToSMPageMap.size()>0){
            SalesMotionToSMPageMap.clear();
        }
        if(IdSMPageToSMPageSectionMap.size()>0){
            IdSMPageToSMPageSectionMap.clear();
        }
        if(SMtoSMPageList.size()>0){
            SMtoSMPageList.clear();
        }
        if(SMPageToSMPageSectionMap.size()>0){
           SMPageToSMPageSectionMap.clear();
        }
         
        loadStages();
        loadDomains();
        loadSolutionTypes();
        loadProducts();
        return Page.SalesMotion_SelectDomainTypePage;   
    }
    
     Public PageReference GoToPreviewPage(){
        PageReference pageRef;
        String str_domain='';
        String str_solType='';
        String str_solName='';
        String str_country='';
        String str_stage='';
        String str_page='';
        Id salesMotionId=ApexPages.currentPage().getParameters().get('salesMotionId');
        Id sectionId=ApexPages.currentPage().getParameters().get('sectionId');
        Sales_Motion__c smElt=SalesMotionRecs.get(salesMotionId);
        Sales_Motion_Page_Section__c sectionElt=SMSectionRecs.get(sectionId);
        Id smPdctId;
        
        smPdctId=smElt.Product__c;
        str_domain=smElt.Domain__c; 
        str_solType=smElt.Solution_Type__c; 
        str_solName=smElt.Solution_Name__c;
        //str_country=smElt.Country__c;
        str_stage=sectionElt.Stage__c;
        str_page=sectionElt.Sales_Motion_Page__c;
        System.debug('### Before replace #########');
        System.debug('###str_domain'+str_domain);
        System.debug('###str_solType'+str_solType);
        System.debug('###str_solName'+str_solName);
        System.debug('###str_stage'+str_stage);
         
        if(str_solType!=null){        
            str_solType=str_solType.replace('&','%26'); 
        }
        if(str_solName!=null){    
            str_solName=str_solName.replace('&','%26');
        }    
        if(str_stage!=null){
            str_stage=str_stage.replace('%','%25');
        }
        System.debug('### After replace #########');
        System.debug('###str_domain'+str_domain);
        System.debug('###str_solType'+str_solType);
        System.debug('###str_solName'+str_solName);
        System.debug('###str_stage'+str_stage);
        
        if(smPdctId!=null){       
            str_domain='';
            str_solType='';
            str_solName='';
            str_country='';
            System.debug('### Inside product not null null #########');
            System.debug('###smPdctId'+smPdctId);
            System.debug('###str_domain'+str_domain);
            System.debug('###str_solType'+str_solType);
            System.debug('###str_solName'+str_solName);
            System.debug('###str_stage'+str_stage);
        
            String finalURL='/apex/SalesMotion?domain='+str_domain+'&solType='+str_solType+'&solName='+str_solName+'&product='+smPdctId+'&country='+str_country+'&stage='+str_page+'&region='+'&businessunit=';
            //String finalURL='/apex/SalesMotion?domain='+str_domain+'&solType='+str_solType+'&solName='+str_solName+'&country='+str_country+'&currentStage='+str_stage+'&currentPage='+str_page;
            System.debug('###finalURL'+finalURL);
        
            pageRef=new PageReference(finalURL);
       } 
       else{
           String finalURL='/apex/SalesMotion?domain='+str_domain+'&solType='+str_solType+'&solName='+str_solName+'&country='+str_country+'&currentStage='+str_stage+'&currentPage='+str_page+'&region='+'&businessunit=';
           System.debug('###finalURL'+finalURL);
        
           pageRef=new PageReference(finalURL);
       
       } 
        return pageRef; 
    
    }   
    
}