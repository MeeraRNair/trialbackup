public class CMNonStdTermsController {
    Public List<CSMB_Terms_and_Conditions_Maintenance__c> nonStdTandCList = new List<CSMB_Terms_and_Conditions_Maintenance__c>();
    Public List<Contract_Terms_and_Conditions__c> ContractTermsandConditionsList= new list<Contract_Terms_and_Conditions__c>();
    Public List<Contract_Terms_and_Conditions__c> conTermsListToDelete = new List<Contract_Terms_and_Conditions__c>();
    Public List<Contract_Terms_and_Conditions__c> conTermsListToUpdate = new List<Contract_Terms_and_Conditions__c>();
    Public List<selectOption> availableTandC = new List<selectOption>();
    Public List<selectOption> selectedTandC = new List<selectOption>();
    Public List<selectOption> fullAvailableTandC = new List<SelectOption>();
    Public List<string> termsToAdd = new List<string>{};
    Public List<string> termsToRemove = new List<string>{};        
    Public Set<string> TandC= new Set<string>();   
    Public Contract conObj= new contract();
    Public Id recTypeID{get;set;}
    Public boolean showTandC{get;set;}
    Public boolean showMultiPickofTandC=true;
    public boolean showNonStdTandC=false;
    public string statusContract{get;set;} 
    public boolean isEditButtonClicked{get;set;}
    Public boolean isNewButtonClicked{get;set;}
    public boolean messageClickEdit{get;set;}
    public boolean messageClickNew{get;set;}
    Public List<TermsAndConditionClass> TermsandConditionsClassList = new List<TermsAndConditionClass>();
    Public Map<String,Contract_Terms_and_Conditions__c> mapOfConTermsandTermsClass = new  Map<String,Contract_Terms_and_Conditions__c>();
    public class TermsAndConditionClass{
        public CSMB_Terms_and_Conditions_Maintenance__c nonSTdtermsObj{get;set;}
        public String content{get;set;}
        public string status{get;set;}
        public String section{get;set;}
        public TermsAndConditionClass(CSMB_Terms_and_Conditions_Maintenance__c nonSTdtermsObj,String content,String section ,String Status){
            this.nonSTdtermsObj = nonSTdtermsObj;
            this.content= content;
            this.status=status;
            this.section=section;
            }
    }
    public CMNonStdTermsController(ApexPages.StandardController controller){
       conObj=(Contract)controller.getrecord();
       recTypeID =IdLookupUtils.getRecordTypeId('Non-Standard Terms and Conditions', 'Contract_Terms_and_Conditions__c', true);
       nonStdTandCList=[select name from CSMB_Terms_and_Conditions_Maintenance__c order by name];
       isEditButtonClicked = BooleanUtils.strToBoolean(StringUtils.defaultString(Apexpages.currentPage().getParameters().get('isEditButtonClicked')));
       isNewButtonClicked = BooleanUtils.strToBoolean(StringUtils.defaultString(Apexpages.currentPage().getParameters().get('isNewButtonClicked')));    
       showTandC=false;
       initializeTandC();
    }
    public void initializeTandC(){
        fullavailableTandC.clear();
        availableTandC.clear();      
        ContractTermsandConditionsList=[select id,Contract__c,Standard_Term__c,Standard_Term__r.name,Terms_and_conditions_Content__c,section__c from Contract_Terms_and_Conditions__c where contract__c=:conObj.id and recordtypeid=:recTypeID];
        if( isNewButtonClicked ==  isEditButtonClicked ){
            if(contractTermsandConditionsList.size() ==0){
                isNewButtonClicked = true;
                isEditButtonClicked=false;
            }
            else{       
                isEditButtonClicked = true;
                isNewButtonClicked =false;
            }
        }
        if(contractTermsandConditionsList.size()>0 && isNewButtonClicked==true){
            messageClickNew = true;
            showTandC = false;
            showMultiPickofTandC = false;
            showNonStdTandC = false;
        }else if(contractTermsandConditionsList.size()>0 && isNewButtonClicked==false){
            for(Contract_Terms_and_Conditions__c nonStdTerms:ContractTermsandConditionsList){
                TandC.add(nonStdTerms.Standard_Term__r.name);
                termsToAdd.add(nonStdTerms.Standard_Term__r.name);
            }
            for(CSMB_Terms_and_Conditions_Maintenance__c nonStdTerms:nonStdTandCList){
                fullavailableTandC.add(new selectOption(nonStdTerms.name,nonStdTerms.name));
            }
            availableTandC=fullavailableTandC;
            SelectedTandC = addToList(SelectedTandC,termsToAdd);
            availableTandC = removeFromList(availableTandC,termsToAdd);
            confirmTerms();
        }else if(contractTermsandConditionsList.size()==0 && isEditButtonClicked==true){
            messageClickEdit = true;
            showTandC = false;
            showMultiPickofTandC = false;
            showNonStdTandC = false;
        }else{
            for(CSMB_Terms_and_Conditions_Maintenance__c nonStdTerms:nonStdTandCList){
                fullavailableTandC.add(new selectOption(nonStdTerms.name,nonStdTerms.name));
            }
            availableTandC=fullavailableTandC;
       }   
    }
    public void confirmTerms(){
        showNonStdTandC=true;
        showTandC=true;
        TermsandConditionsClassList.clear();
        if(contractTermsandConditionsList.size()>0){
            List<Contract_Terms_and_Conditions__c> editContractTermsandConditionsList=[select id,Contract__c,Standard_Term__c,Standard_Term__r.name,Terms_and_conditions_Content__c,section__c from Contract_Terms_and_Conditions__c where contract__c=:conObj.Id and recordtypeid=:recTypeID and Standard_Term__r.name in :TandC];
            set<string> editNonStdTermName = new set<string>(); 
            for(Contract_Terms_and_Conditions__c conNonStdTerms:editContractTermsandConditionsList){
                CSMB_Terms_and_Conditions_Maintenance__c nonStdTermsObj = new CSMB_Terms_and_Conditions_Maintenance__c();
                nonStdTermsObj.name=conNonStdTerms.Standard_Term__r.name;                            
                TermsandConditionsClassList.add(new TermsAndConditionClass(nonStdTermsObj,conNonStdTerms.Terms_and_conditions_Content__c,conNonStdTerms.Section__c,'update'));
                editNonStdTermName.add(conNonStdTerms.Standard_Term__r.name);
                mapOfConTermsandTermsClass.put(nonStdTermsObj.name,conNonStdTerms);
            }
            for(CSMB_Terms_and_Conditions_Maintenance__c nonStdTerms:[select id,name from CSMB_Terms_and_Conditions_Maintenance__c where name in :TandC]){
                if(!editNonStdTermName.contains(nonStdTerms.name)){
                    TermsandConditionsClassList.add(new TermsAndConditionClass(nonStdTerms,'','','insert'));
                }
            }
            for(Contract_Terms_and_Conditions__c conNonStdTerms:ContractTermsandConditionsList){
                if(!TandC.contains(conNonStdTerms.Standard_Term__r.name)){
                    conTermsListToDelete.add(conNonStdTerms);
                }   
            }
        }
        else{       
            for(CSMB_Terms_and_Conditions_Maintenance__c nonStdTerms:[select id,name from CSMB_Terms_and_Conditions_Maintenance__c where name in :TandC]){
                TermsandConditionsClassList.add(new TermsAndConditionClass(nonStdTerms,'','','insert'));
            }
        }   
    }
    public PageReference saveTerms(){
        List<Contract_Terms_and_Conditions__c> conTermsListToInsert = new List<Contract_Terms_and_Conditions__c>();
        for(TermsAndConditionClass nonStdTermsandContent:TermsandConditionsClassList){
            Contract_Terms_and_Conditions__c conTermsObj = new Contract_Terms_and_Conditions__c();
            conTermsObj=createConTermObj(nonStdTermsandContent);
            if(nonStdTermsandContent.status=='insert' & conTermsObj.Terms_and_conditions_Content__c!=''){               
                conTermsListToInsert.add(conTermsObj);
            }
            else if(nonStdTermsandContent.status=='update'){
                Contract_Terms_and_Conditions__c savedConTermsObj=mapOfConTermsandTermsClass.get(nonStdTermsandContent.nonSTdtermsObj.name);
                if(savedConTermsObj.Terms_and_conditions_Content__c <> conTermsObj.Terms_and_conditions_Content__c || savedConTermsObj.Section__c <> conTermsObj.Section__C ){
                    savedConTermsObj.Terms_and_conditions_Content__c=conTermsObj.Terms_and_conditions_Content__c;
                    savedConTermsObj.Section__c=conTermsObj.Section__c; 
                    if(conTermsObj.Terms_and_conditions_Content__c=='' && conTermsObj.Section__c==''){
                        conTermsListToDelete.add(savedConTermsObj);
                    }else          
                        conTermsListToUpdate.add(savedConTermsObj);
                }
                
            }        
        }
        System.debug('***************************************** conTermsListToDelete  ****** :'+conTermsListToDelete);
        System.debug('***************************************** conTermsListToUpdate ****** :'+conTermsListToUpdate);
        try{
            if(conTermsListToDelete.size()>0){
                delete conTermsListToDelete;
            }
            if(conTermsListToUpdate.size()>0){
                update conTermsListToUpdate;
            }
            if(conTermsListToInsert.size()>0){
                insert conTermsListToInsert;
            }
        }catch(Exception e){
         System.debug(e);
        }
        return PageUtils.redirect('/'+conObj.Id);
    }
    public void addCurSelectedTandC(){
        SelectedTandC = addToList(SelectedTandC,termsToAdd);
        availableTandC = removeFromList(availableTandC,termsToAdd);
          for(string terms:termsToAdd){
               TandC.add(terms);
          }
    }
    public void removeCurSelectedTandC(){
       availableTandC = addToList(availableTandC,termsToRemove);
        SelectedTandC = removeFromList(SelectedTandC,termsToRemove); 
        for(String terms:termsToRemove){           
            TandC.remove(terms);
        }
    }
    // Common method to add selected multiPickList values
    private List<SelectOption> addToList(List<SelectOption> theList, String[] theSelected){
        List<SelectOption> newList = new List<SelectOption>();
        if(theList != null){
            newList.addAll(theList);
        }
        if(theSelected != null){
            for(String tAndC : theSelected){
                newList.add(new SelectOption(tAndC, tAndC));   
            }
        }
               
        return SortOptionList(newList);
    }
    // Common method to remove selected multiPickList values
    private List<SelectOption> removeFromList(List<SelectOption> theList, String[] theSelected){
        set<string> temptheSelected = new set<string>();
        temptheSelected.addall(theSelected);                     
        List<SelectOption> newList = new List<SelectOption>();
        for(SelectOption listItem: theList){
            if(!temptheSelected.contains(listItem.getValue())){
                newList.add(new SelectOption(listItem.getValue(), listItem.getLabel()));
            }            
        }        
        return newList;
    }
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
    public Contract_Terms_and_Conditions__c createConTermObj(TermsAndConditionClass nonStdTermsandContent){
        Contract_Terms_and_Conditions__c conTermsObj = new Contract_Terms_and_Conditions__c();
        conTermsObj.Standard_Term__c=nonStdTermsandContent.nonSTdtermsObj.id;
        conTermsObj.Terms_and_conditions_Content__c=nonStdTermsandContent.content;
        conTermsObj.section__C=nonStdTermsandContent.section;
        conTermsObj.contract__C=conObj.Id;
        conTermsObj.RecordTypeID=recTypeId;
        return conTermsObj; 
    }
    public list<selectOption> getavailableTandC()
    {
        return availableTandC;
    }
    public list<selectOption> getSelectedTandC()
    {
        return selectedTandC;
    }
    public list<selectoption> getfullavailableTandC()
    {
        return fullavailableTandC;
    }
    public void setavailableTandC(list<selectOption> availableTandC)
    {
        this.availableTandC=availableTandC;
    }
    public void setfullavailableTandC(list<selectoption> fullavailableTandC)
    {
        this.fullavailableTandC=fullavailableTandC;
    }
    public void setselectedTandC(list<selectOption> selectedTandC)
    {
        this.selectedTandC=selectedTandC;
    }
    public string[] gettermsToAdd()
    {
        return termsToAdd;
    }
    public void settermsToAdd(string[] termsToAdd)
    {
        this.termsToAdd=termsToAdd;
    }
    public string[] gettermsToRemove()
    {
        return termsToRemove;
    }
    public void settermsToRemove(string[] termsToRemove)
    {
        this.termsToRemove=termsToRemove;
    }
    public boolean getshowMultiPickofTandC(){
        return showMultiPickofTandC;
    } 
    public void setshowMultiPickofTandC(boolean showMultiPickofTandC){
        this.showMultiPickofTandC=showMultiPickofTandC;
    }
    public boolean getshowNonStdTandC(){
        return showNonStdTandC;
    }
    public void setshowNonStdTandC(boolean showNonStdTandC){
        this.showNonStdTandC= showNonStdTandC;
    }
    public List<TermsAndConditionClass> getTermsandConditionsClassList(){
        return TermsandConditionsClassList;
    }
    public void setTermsandConditionsClassList(List<TermsAndConditionClass> TermsandConditionsClassList){
        this.TermsandConditionsClassList=TermsandConditionsClassList;
    } 
}