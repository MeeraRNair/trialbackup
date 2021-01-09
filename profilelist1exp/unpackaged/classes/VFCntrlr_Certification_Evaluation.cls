public with sharing class VFCntrlr_Certification_Evaluation {
    
    //variables to store query string parameters
    public String Region{get; set;}
    public Id AC_Id = null; // Account Id if Certification Tracker clicked from Account detail page
    
    public Integer Eval_AcctCount;
    public Boolean result;
    public List<ID> Selected_Accts_lst = new List<Id>();
    public List<String> Evaluation_Failed_Accts;  
    public List<String> Evaluation_Batch_Accts;
    public Map<ID, String> AcctId_NameMap ;
    public boolean chkSelectAll {get; set;}
    
    // variables for Paging
    private static final Integer PAGE_SIZE=10;
    public Integer currentPage {get; private set;}    
    public Integer lastPage {get; private set;}
    public Boolean hasPreviousAndNext;     
    public Boolean hasNext {get; private set;}    
    public Boolean hasPrevious {get; private set;}
    public Integer NoOfRecords {get; private set;}
          
    List<Certification_Tracker__c> recAccounts = new List<Certification_Tracker__c>(); 
    public List<acctTableRow> tableRows { get; set; }        
    public class acctTableRow{
        public Certification_Tracker__c  Acct {get; set;}
        public Boolean isSelected {get; set;}
        
        public  acctTableRow(Certification_Tracker__c  a, Boolean sel){
            Acct = a;
            isSelected = sel;
        }
    }   
        
    public VFCntrlr_Certification_Evaluation(){
        chkSelectAll = false;
         Region = ApexPages.currentPage().getParameters().get('region');
         AC_Id = ApexPages.currentPage().getParameters().get('acid');
        
         hasNext = false;
         hasPrevious = false;       
         lastPage = 0;
         currentPage= 0;
         NoOfRecords=0;
       
         if (setCon != Null) 
              recAccounts = (List<Certification_Tracker__c>) setCon.getRecords(); 
         
         tableRows = new List<acctTableRow>();
        
         for (Certification_Tracker__c  a : recAccounts){
            tableRows.add(new acctTableRow(a, false));
         }
    }
    
     public ApexPages.StandardSetController setCon {
         get {
         try{
            if(setCon == null) {
                 if (AC_Id != null){
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                                    [select Account_Name__r.id , Account_Name__r.name, 
                                     Account_Name__r.Account_ID__c, Account_Name__r.Partner_Relationship__c 
                                    from Certification_Tracker__c
                                    where Evaluate_Criteria__c=true and Account_Name__c= :AC_Id]));
                     
                }
                else{
                        List<Country__c> Country = [select Code__c from Country__c 
                                                    Where Region__c = :Region];
        
                       
                        Set<String> CountryCodes = new Set<String>();
                        
                        if (Country.isEmpty()){
                            if (Region == 'US'){
                                CountryCodes.add('US');
                            }
                            else if (Region == 'Canada'){
                                CountryCodes.add('CA');
                            }
                        }
                        else{
                            for(Country__c c: Country ){
                                CountryCodes.add(c.Code__c);
                            }
                        }
                        
                       setCon =  new ApexPages.StandardSetController(Database.getQueryLocator(                                       
                                    [select  Account_Name__r.id , Account_Name__r.name, 
                                    Account_Name__r.Account_ID__c, Account_Name__r.Partner_Relationship__c 
                                    from Certification_Tracker__c
                                    where Account_Name__r.Account_Country_Code__c in :CountryCodes
                                    and Evaluate_Criteria__c = true
                                    and Account_Name__r.Partner_Relationship__c != NULL                                 
                                    and Account_Name__r.Partner_Relationship__c != ''
                                    Order By Account_Name__r.name
                                    limit 1000]));
                       
                }       
                if (setCon != null){
                    if(setCon.getResultSize()>0){                     
                        this.setCon.setPageSize(PAGE_SIZE);
                        setNextPrevious();
                        NoOfRecords = setCon.getResultSize(); 
                        setCon.last();                                        
                        lastPage = setCon.getPageNumber();
                        setCon.first();                        
                        currentPage = setCon.getPageNumber();
                    }  
                }                           
            }
        }//try
        catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }   
        return setCon;        
    }        
     set;
    }
     public PageReference next() {        
        if (hasNext){  
            try {               
                
                setCon.next();             
                currentPage = setCon.getPageNumber();
                setNextPrevious();  
            } 
            catch(Exception e){
                ApexPages.addMessages(e);
                
            }           
        }     
        return null;    
     }        
     
     //Function get called when user click on previous link in dplicate record list    
     public PageReference previous() {        
        if (hasPrevious){ 
            try {    
                setCon.previous();            
                currentPage = setCon.getPageNumber();
                setNextPrevious();      
            } 
            catch(Exception e){
                ApexPages.addMessages(e);
               
            }                    
        }        
        return null;    
     }        
     
     //Set values for hasNext and hasPrevious booleans    
     private void setNextPrevious() {        
        chkSelectAll = false;
        if (setCon.getHasNext()) {            
            hasNext = true;        
        }        
        else {            
            hasNext = false;        
        }        
        if (setCon.getHasPrevious()) {            
            hasPrevious = true;        
        }        
        else {            
            hasPrevious = false;        
        }    
     }   
  
    public PageReference Evaluate(){
        try {
            chkSelectAll = false;
            Set<Id> Selected_Accts = new Set<Id>(); 
            AcctId_NameMap = new Map<ID, String>();
            Evaluation_Failed_Accts  = new List<String>();
            Evaluation_Batch_Accts  = new List<String>();
            Selected_Accts_lst.clear();
            for(acctTableRow aRow : tableRows ){
                if (aRow.isSelected == true){
                    Selected_Accts.add(aRow.Acct.Account_Name__r.id);
                    AcctId_NameMap.put(aRow.Acct.Account_Name__r.id, aRow.Acct.Account_Name__r.name);
                }
            } 
            Eval_AcctCount = 0;
            Selected_Accts_lst.addAll(Selected_Accts);
            Evaluate_EachAccount();
          } 
        catch(Exception e){
            ApexPages.addMessages(e);
            
        }       
        return null; 
    } 
    
    public PageReference Evaluate_EachAccount(){        
        try {        
            //To avoid Too Many Script Statements Error, evaluating one account at a time.            
            if (Eval_AcctCount >= Selected_Accts_lst.size()){
                Eval_AcctCount = -1;
            }
            else{
                //Set<Id> Selected_Accts = new Set<Id>(); 
                //Selected_Accts.add(Selected_Accts_lst.get(Eval_AcctCount));
                PartnerCertEvaluation pcEval = new PartnerCertEvaluation();            
                //Boolean tempResult = pcEval.Evaluate(Selected_Accts);                
                String strResult = pcEval.Evaluate(Selected_Accts_lst.get(Eval_AcctCount));   
                
                Boolean tmpresult;             
                if(strResult == null){
                    Evaluation_Failed_Accts.add(AcctId_NameMap.get(Selected_Accts_lst.get(Eval_AcctCount)));
                    tmpresult = false;
                }                
                else if(strResult == 'BatchJob'){
                    Evaluation_Batch_Accts.add(AcctId_NameMap.get(Selected_Accts_lst.get(Eval_AcctCount)));
                    tmpresult = false;
                }
                else
                    tmpresult = true;
               
                result = result==null ? tmpresult : result && tmpresult;       
                Eval_AcctCount++;                
            }//else          
         }//try 
        catch(Exception e){
            ApexPages.addMessages(e);
        }
         return null; 
    }
    
    public PageReference ShowMessage(){ 
        chkSelectAll = false;
        if (result == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Confirm,System.Label.NetExam_EvalMsg1));
        }
        else{
            if (Evaluation_Failed_Accts.size() == 0 && Evaluation_Batch_Accts.size() == 0){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,System.Label.NetExam_EvalMsg2));
            }
            else if (Evaluation_Batch_Accts.size() > 0){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_EvalMsg3a + Evaluation_Batch_Accts ));
            }
            else if (Evaluation_Failed_Accts.size() > 0){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_EvalMsg4 + Evaluation_Failed_Accts));
            }
        }
        result = null;
        return null;         
    }
    
    public PageReference Cancel(){
        //redirect to account list view   
         if (AC_Id != null){
            return new PageReference('/' + AC_Id );
        }
        else{     
            return new PageReference(getKeyPrefix());    
        }
    }
    public Static String getKeyprefix(){   
        //Schema.DescribeSObjectResult sObjDesc = Account.sObjectType.getDescribe();  
        //return '/'+ sObjDesc.keyPrefix;
        Schema.DescribeSObjectResult sObjDesc = Certification_Tracker__c.sObjectType.getDescribe();  
        return '/'+ sObjDesc.keyPrefix;
    }
    
    //getter methods
    public boolean getHasPreviousAndNext(){        
        return (hasPrevious && hasNext);    
    }
    
    public List<acctTableRow> getAccounts(){
        try{   
            recAccounts= new List<Certification_Tracker__c>(); 
            
            if (setCon != NULL)         
                recAccounts = (List<Certification_Tracker__c>) setCon.getRecords();
                   
            tableRows = new List<acctTableRow>();
           
             for (Certification_Tracker__c a : recAccounts ){
                tableRows.add(new acctTableRow(a, false));
             }                   
        }
        catch(Exception e){
                ApexPages.addMessages(e);
                return null;
       }  
       return tableRows;
    }       
    public void setEval_AcctCount(Integer cnt) {
        Eval_AcctCount = cnt;
    }
    public Integer getEval_AcctCount() {
        return Eval_AcctCount;
    }
}