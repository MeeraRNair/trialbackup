public class CMStdTermsController {
    Public List<CSMB_Terms_and_Conditions_Maintenance__c> newCSMBTandCList = new List<CSMB_Terms_and_Conditions_Maintenance__c>();
    Public List<CSMB_Terms_and_Condition__c> newTandCList = new list<CSMB_Terms_and_Condition__c>();
    Public List<Contract_Terms_and_Conditions__c> ContractTermsandConditionsList= new list<Contract_Terms_and_Conditions__c>();
    Public List<TermsAndConditionInnerClass> TermsAndConditionInnerClassList = new List<TermsAndConditionInnerClass>();
    public List<SelectedTermsandConditionsClass> SelectedTermsandConditionsClassList = new list<SelectedTermsandConditionsClass>();
    public List<InactiveSelectedTermsandConditionsClass> InactiveStdTerms=new list<InactiveSelectedTermsandConditionsClass>();
    public List<TermsAndConditionInactiveInnerClass> InactiveTerms = new list<TermsAndConditionInactiveInnerClass>();
    Public List<selectOption> availableTandC = new List<selectOption>();
    Public List<selectOption> selectedTandC = new List<selectOption>();
    Public List<selectOption> fullAvailableTandC = new List<SelectOption>();
    Public List<string> termsToAdd = new List<string>{};
    Public List<string> termsToRemove = new List<string>{};        
    Public Set<string> TandC= new Set<string>();
    Public Set<Id> curSelEditstandardTerms = new Set<Id>();
    Public Set<Id> curSelEditTerms = new Set<Id>();    
    Public Id contractId{get;set;}
    Public Id recTypeID{get;set;}
    Public string recType{get;set;}
    Public boolean showTandC = false;
    Public boolean editTerms=false;
    Public boolean showMultiPickofTandC=true;
    Public boolean inactiveTermsbool=false;
    public boolean showStdTandC=false;
    public string statusContract{get;set;} 
    public boolean isEditButtonClicked{get;set;}
    Public boolean isNewButtonClicked{get;set;}
    public boolean messageClickEdit{get;set;}
    public boolean messageClickNew{get;set;} 
    public class TermsAndConditionInnerClass{
        public boolean isSelected{get;set;}
        public boolean prevStatus{get;set;}
        public CSMB_Terms_and_Condition__c termsObj{get;set;}
        public TermsAndConditionInnerClass(CSMB_Terms_and_Condition__c termsObj,boolean isselected,boolean prevStatus){
            this.termsObj = termsObj;
            this.isselected=isselected;
            this.prevStatus=prevStatus;
        }
    }    
    public class SelectedTermsandConditionsClass{
        public CSMB_Terms_and_Conditions_Maintenance__c repositoryName{get;set;}
        public List<TermsAndConditionInnerClass> TermsAndConditionClassList{get;set;}
        public SelectedTermsandConditionsClass(CSMB_Terms_and_Conditions_Maintenance__c repName,List<TermsAndConditionInnerClass> TermsAndConditionClassList){
             repositoryName = repName;
             this.TermsAndConditionClassList=TermsAndConditionClassList;
        }
       
    }
    public class TermsAndConditionInactiveInnerClass{
        public boolean isSelectedInactive{get;set;}
        public boolean prevStatusInactive{get;set;}
        public Contract_Terms_and_Conditions__c inactiveTermsObj{get;set;}
        public TermsAndConditionInactiveInnerClass(Contract_Terms_and_Conditions__c inactiveTermsObj,boolean isSelectedInactive,boolean prevStatusInactive){
            this.inactiveTermsObj= inactiveTermsObj;
            this.isSelectedInactive=isSelectedInactive;
            this.prevStatusInactive=prevStatusInactive;
        }
    }
    public class InactiveSelectedTermsandConditionsClass{
        public CSMB_Terms_and_Conditions_Maintenance__c repositoryName{get;set;}
        public List<TermsAndConditionInactiveInnerClass> InactiveTermsAndConditionClassList{get;set;}
        public InactiveSelectedTermsandConditionsClass(CSMB_Terms_and_Conditions_Maintenance__c repName,List<TermsAndConditionInactiveInnerClass> InactiveTermsAndConditionClassList){
             repositoryName = repName;
             this.InactiveTermsAndConditionClassList=InactiveTermsAndConditionClassList;
        }
       
    }
    public CMStdTermsController(ApexPages.StandardController controller) {    
        contractId=controller.getID();
        recTypeID =IdLookupUtils.getRecordTypeId('Standard Terms and Conditions', 'Contract_Terms_and_Conditions__c', true);
        newCSMBTandCList =[select name from CSMB_Terms_and_Conditions_Maintenance__c where status__c=:true order by name];
        getStatusForCon(contractId);
        try{
            isEditButtonClicked = BooleanUtils.strToBoolean(StringUtils.defaultString(Apexpages.currentPage().getParameters().get('isEditButtonClicked')));
            isNewButtonClicked = BooleanUtils.strToBoolean(StringUtils.defaultString(Apexpages.currentPage().getParameters().get('isNewButtonClicked')));
           }catch(Exception e){
               //PageUtils.addError(e);
               System.debug('please please '+e);
           }
        initializeTandC();
        
    }    
    public void initializeTandC(){
        fullavailableTandC.clear();
        availableTandC.clear();      
        ContractTermsandConditionsList=[select id,Contract__c,Standard_Term__c,Terms_and_Conditions__c,Terms_and_conditions_Content__c from Contract_Terms_and_Conditions__c where contract__c=:contractId and recordtypeid=:recTypeID];
        Set<CSMB_Terms_and_Conditions_Maintenance__c> editModeStdTermsSet = new Set<CSMB_Terms_and_Conditions_Maintenance__c>();
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
            showStdTandC = false;
            inactiveTermsbool= false;
        }else if(contractTermsandConditionsList.size()>0 && isNewButtonClicked==false){      
            for(Contract_Terms_and_Conditions__c stdTerms:contractTermsandConditionsList){
                curSelEditstandardTerms.add(stdTerms.Standard_Term__c);
                curSelEditTerms.add(stdTerms.Terms_and_Conditions__c);
            }
            List<CSMB_Terms_and_Conditions_Maintenance__c> editModeStdTermsList=[select id,name from CSMB_Terms_and_Conditions_Maintenance__c where id in:curSelEditstandardTerms];
            for(CSMB_Terms_and_Conditions_Maintenance__c stdTerms:editModeStdTermsList){
                editModeStdTermsSet.add(stdTerms);
            }
            for(CSMB_Terms_and_Conditions_Maintenance__c stdTerm:newCSMBTandCList){
                if(editModeStdTermsSet.contains(stdTerm)){
                    termsToAdd.add(stdTerm.name);
                }
                fullavailableTandC.add(new selectOption(stdTerm.name,stdTerm.name));
            }
            availableTandC=fullavailableTandC;
            SelectedTandC = addToList(SelectedTandC,termsToAdd);
            availableTandC = removeFromList(availableTandC,termsToAdd);
            for(string terms:termsToAdd){
                TandC.add(terms);
            }
            editTerms=true;
            confirmTerms();
            newTandCList=[Select id,Standard_Term__c,name,Standard_Terms_and_Conditions__c from CSMB_Terms_and_Condition__c where Standard_Term__c in :curSelEditTerms order by name];        
            if(newTandCList.size()>0){
              showTandC = true;  
            }  
        }else if(contractTermsandConditionsList.isEmpty() && isEditButtonClicked==true){
            messageClickEdit = true;
            showTandC = false;
            showMultiPickofTandC = false;
            showStdTandC = false;
            inactiveTermsbool= false;
        }else{
                for(CSMB_Terms_and_Conditions_Maintenance__c obj:newCSMBTandCList){
                    fullavailableTandC.add(new selectOption(obj.name,obj.name));
                }
                availableTandC=fullavailableTandC;
              } 
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
        newList.addAll(theList);
        for(String tAndC : theSelected){
            newList.add(new SelectOption(tAndC, tAndC));   
        }       
        return SortOptionList(newList);
    }
    // Common method to remove selected multiPickList values
    private List<SelectOption> removeFromList(List<SelectOption> theList, String[] theSelected){
        Map<String, String> temptheSelected = new Map<String, String> {};        
        for (String tAndC : theSelected){
            temptheSelected.put(tAndC,tAndC);
        }               
        List<SelectOption> newList = new List<SelectOption>();
        for(SelectOption listItem: theList){
            if(!temptheSelected.containsKey(listItem.getValue())){
                newList.add(new SelectOption(listItem.getValue(), listItem.getLabel()));
            }            
        }        
        return newList;
    }
    public void confirmTerms(){
        Map<CSMB_Terms_and_Conditions_Maintenance__c,List<CSMB_Terms_and_Condition__c>> mapOfTandC = new Map<CSMB_Terms_and_Conditions_Maintenance__c,List<CSMB_Terms_and_Condition__c>>();
        Set<CSMB_Terms_and_Condition__c> editModeTermsSet = new set<CSMB_Terms_and_Condition__c>();
        List<string> sortedTandC = new List<string>();
        if(editTerms==false){
            newTandCList.clear();
            SelectedTermsandConditionsClassList.clear();
            for(string tandC:TandC){
                    sortedTandC.add(tandC);
                }
                sortedTandC.sort();
                TandC.clear();
                for(string sorted:sortedTandC){
                    TandC.add(sorted);
                }       
            for(CSMB_Terms_and_Conditions_Maintenance__c repName:[select id,name from  CSMB_Terms_and_Conditions_Maintenance__c where name in :TandC order by name]){
                mapOfTandC.put(repName,[Select id,Standard_Term__c,name,Standard_Terms_and_Conditions__c from CSMB_Terms_and_Condition__c where Standard_Term__c=:repname.id and status__c=:true order by  Standard_Term__r.name]);
             } 
            for(CSMB_Terms_and_Conditions_Maintenance__c repName:mapOfTandC.keySet()){
                List<TermsAndConditionInnerClass> listofTandCInner = new List<TermsAndConditionInnerClass>();
                for(CSMB_Terms_and_Condition__c term:mapOfTandC.get(repName)){                    
                    listofTandCInner.add(new TermsAndConditionInnerClass(term,false,false));
                }                
                SelectedTermsandConditionsClassList.add(new SelectedTermsandConditionsClass(repName,listofTandCInner));
            }  
            if(TandC.size()>0){
              showTandC = true;  
            }
         }
         else{
                SelectedTermsandConditionsClassList.clear();
                List<TermsAndConditionInnerClass> mainListofTandC = new List<TermsAndConditionInnerClass>();
                List<CSMB_Terms_and_Condition__c> editModeTermsList =[select id,Standard_Term__c,name,Standard_Terms_and_Conditions__c from CSMB_Terms_and_Condition__c where id in:curSelEditTerms];
                for(CSMB_Terms_and_Condition__c term:editModeTermsList){
                    editModeTermsSet.add(term);
                    
                }
                List<CSMB_Terms_and_Conditions_Maintenance__c> maintananceIdList=[select id,name from  CSMB_Terms_and_Conditions_Maintenance__c where name in :TandC order by name];
                for(CSMB_Terms_and_Conditions_Maintenance__c repName:[select id,name from  CSMB_Terms_and_Conditions_Maintenance__c where name in :TandC]){
                mapOfTandC.put(repName,[Select id,Standard_Term__c,name,Standard_Terms_and_Conditions__c from CSMB_Terms_and_Condition__c where Standard_Term__c=:repname.id and status__c=:true order by Standard_Term__r.name]);
                }            
                for(CSMB_Terms_and_Conditions_Maintenance__c repName:mapOfTandC.keySet()){
                    List<TermsAndConditionInnerClass> listofTandCInner = new List<TermsAndConditionInnerClass>();
                    for(CSMB_Terms_and_Condition__c term:mapOfTandC.get(repName)){
                        if(editModeTermsSet.contains(term)){                   
                            listofTandCInner.add(new TermsAndConditionInnerClass(term,true,true));
                        }
                        else{
                            listofTandCInner.add(new TermsAndConditionInnerClass(term,false,false));
                        }
                    }                
                SelectedTermsandConditionsClassList.add(new SelectedTermsandConditionsClass(repName,listofTandCInner));
                }
                if(TandC.size()>0){
                  showTandC = true;  
                }
         }
         if(statusContract=='Approved'){
             boolean check=false;
             inactiveTermsbool=false;
             inactiveStdTerms.clear();
             list<CSMB_Terms_and_Conditions_Maintenance__c> stdTerms=[select id,name from  CSMB_Terms_and_Conditions_Maintenance__c where status__c=false]; 
             for( CSMB_Terms_and_Conditions_Maintenance__c sTerms:stdTerms){
                 list<TermsAndConditionInactiveInnerClass> InactiveTerms = new list<TermsAndConditionInactiveInnerClass>();
                 for(Contract_Terms_and_Conditions__c constdterms:contractTermsandConditionsList){
                     if(sTerms.id==constdterms.Standard_Term__c)           {
                         InactiveTerms.add(new TermsAndConditionInactiveInnerClass(constdterms,true,true));
                         check=true;
                         inactiveTermsbool=true;
                     }
                 }
                 if(check==true){
                     InactiveStdTerms.add( new InactiveSelectedTermsandConditionsClass(sTerms,inactiveTerms));
                     check=false;
                 }  
             }
             if(InactiveStdTerms.size() > 0){
                 inactiveTermsbool=true;
             }
         }
         showStdTandC=True;
    } 
    public PageReference saveTerms(){   
        list<Contract_Terms_and_Conditions__c> termsToSaveList=new list<Contract_Terms_and_Conditions__c>();
        list<Contract_Terms_and_Conditions__c> termsToDelList=new list<Contract_Terms_and_Conditions__c>();
        termsToSaveList.clear();
        for(SelectedTermsandConditionsClass termsoSaveMaster: SelectedTermsandConditionsClassList){
            for(TermsAndConditionInnerClass termsToSave: termsoSaveMaster.TermsAndConditionClassList){
                if(termsToSave.isSelected==true & termsToSave.prevStatus==false ){    
                    Contract_Terms_and_Conditions__c addTermObj = new Contract_Terms_and_Conditions__c();
                    addTermObj=createConTerms(termsoSaveMaster,termsToSave);
                    termsToSaveList.add(addTermObj);
                }else{ 
                        if(termsToSave.isSelected==false & termsToSave.prevStatus==true){
                        Contract_Terms_and_Conditions__c delTermObj = new Contract_Terms_and_Conditions__c();
                        delTermObj=createConTerms(termsoSaveMaster,termsToSave);
                        termsToDelList.add(delTermObj);                        
                    }
                }
            }
        }  
        for(InactiveSelectedTermsandConditionsClass termsoSaveMaster: InactiveStdTerms){
            for(TermsAndConditionInactiveInnerClass termsToSave: termsoSaveMaster.InactiveTermsAndConditionClassList){                
                if(termsToSave.isSelectedInactive==false & termsToSave.prevStatusInactive==true ){    
                    Contract_Terms_and_Conditions__c currentTermObj = new Contract_Terms_and_Conditions__c();
                    currentTermObj.contract__c = contractId;
                    currentTermObj.RecordTypeID=recTypeId;
                    currentTermObj.Standard_Term__c=termsoSaveMaster.repositoryName.id;
                    currentTermObj.Terms_and_Conditions__c=termsToSave.inactiveTermsObj.Terms_and_Conditions__c;
                    currentTermObj.Terms_and_conditions_Content__c=termsToSave.inactiveTermsObj.Terms_and_conditions_Content__c;
                    //currentTermObj.Non_Standard_Term_Repository__c=termsToSave.inactiveTermsObj.Terms_and_conditions_Content__c;
                    termsToDelList.add(currentTermObj);
                }
            }
        }
        try{
            List<Contract_Terms_and_Conditions__c> contractTermsDelList = [select id,Standard_Term__r.name from Contract_Terms_and_Conditions__c where contract__c=:contractId and Standard_Term__r.status__c=:true and Standard_Term__r.name not in:TandC];
            if(termsToDelList.size()>0){                
                for(Contract_Terms_and_Conditions__c itemOfContractTerms:contractTermsandConditionsList){
                    for(Contract_Terms_and_Conditions__c itemsToDelete:termsToDelList){
                        if(itemOfContractTerms.Standard_Term__c==itemsToDelete.Standard_Term__c & itemOfContractTerms.Terms_and_conditions_Content__c==itemsToDelete.Terms_and_conditions_Content__c ){
                            contractTermsDelList.add(itemOfContractTerms);
                        }
                    }
                }   
            }
            if(contractTermsDelList.size()>0){
                delete contractTermsDelList;
            }
            if(termsToSaveList.size()>0){
                insert termsToSaveList;
            }
        }catch(Exception e){
         System.debug(e);
        }
       return PageUtils.redirect('/'+contractId);
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
    public Contract_Terms_and_Conditions__c createConTerms(SelectedTermsandConditionsClass selTandCobj,TermsAndConditionInnerClass tandCInnerObj){
        Contract_Terms_and_Conditions__c curConTermObj = new Contract_Terms_and_Conditions__c();
        curConTermObj.contract__c = contractId;
        curConTermObj.RecordTypeid=recTypeId;
        curConTermObj.Standard_Term__c=selTandCobj.repositoryName.id;
        curConTermObj.Terms_and_Conditions__c=tandCInnerObj.termsObj.id;
        curConTermObj.Terms_and_conditions_Content__c=tandCInnerObj.termsObj.Standard_Terms_and_Conditions__c;
        return curConTermObj;
    }
    public void getStatusForCon(id contractId){
        List<contract> conList = new List<contract>();
        conList=[select status from contract where id=:contractId];
        if(conList.size()>0){
           statusContract=conList[0].status;
        }
    }
    public List<selectOption> getavailableTandC(){
        return availableTandC;
    }
    public List<selectOption> getSelectedTandC(){
        return selectedTandC;
    }
    public List<selectoption> getfullavailableTandC(){
        return fullavailableTandC;
    }
    public void setavailableTandC(list<selectOption> availableTandC){
        this.availableTandC=availableTandC;
    }
    public void setfullavailableTandC(list<selectoption> fullavailableTandC){
        this.fullavailableTandC=fullavailableTandC;
    }
    public void setselectedTandC(list<selectOption> selectedTandC){
        this.selectedTandC=selectedTandC;
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
    public List<CSMB_Terms_and_Condition__c> getNewTandCList(){
        return newTandCList;
    }
    public void setNewTandCList(List<CSMB_Terms_and_Condition__c> newTandCList){
        this.newTandCList = newTandCList;
    }
    public boolean getshowTandC(){
        return showTandC;
    }
    public void setshowTandC(boolean showTandC){
        this.showTandC = showTandC;
    }
    public boolean getshowStdTandC(){
        return showStdTandC;
    }
    public void setshowStdTandC(boolean showStdTandC){
        this.showStdTandC= showStdTandC;
    }
    public List<TermsAndConditionInnerClass> getTermsAndConditionInnerClassList(){
        return termsAndConditionInnerClassList;
    }
    public void setTermsAndConditionInnerClassList(List<TermsAndConditionInnerClass> TermsAndConditionInnerClassList){
        this.TermsAndConditionInnerClassList = TermsAndConditionInnerClassList;
    }
    public List<SelectedTermsandConditionsClass> getSelectedTermsandConditionsClassList(){
        return SelectedTermsandConditionsClassList;
    }
    public void setSelectedTermsandConditionsClassList(list<SelectedTermsandConditionsClass> s){
        SelectedTermsandConditionsClassList=s;
    } 
    public boolean getshowMultiPickofTandC(){
        return showMultiPickofTandC;
    } 
    public void setshowMultiPickofTandC(boolean showMultiPickofTandC){
        this.showMultiPickofTandC=showMultiPickofTandC;
    } 
    public boolean getinactiveTermsbool(){
       return inactiveTermsbool; 
    }
    public void setinactiveTermsbool(boolean inactiveTermsbool){
        this.inactiveTermsbool=inactiveTermsbool;
    }
    public List<TermsAndConditionInactiveInnerClass> getInactiveTerms(){
        return InactiveTerms;
    }
    public void setInactiveTerms(list<TermsAndConditionInactiveInnerClass> InactiveTerms){
        this.InactiveTerms=InactiveTerms;
    }
    public List<InactiveSelectedTermsandConditionsClass> getInactiveStdTerms(){
        return InactiveStdTerms;
    }
    public void setInactiveStdTerms(list<InactiveSelectedTermsandConditionsClass> InactiveStdTerms){
        this.InactiveStdTerms=InactiveStdTerms;
    }
 }