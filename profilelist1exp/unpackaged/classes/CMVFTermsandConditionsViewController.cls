Public Class CMVFTermsandConditionsViewController{
    Id contractId{get;set;}
    id stdRecTypeId;
    id nonStdRecTypeId;
    set<Id> standardTerms = new set<Id>();
    set<Id> nonStandardStdTerms = new set<Id>();
    public string contractName;
    public contract contractobj{set;get;}
    boolean stdTerms=false;
    boolean nonStdTerms=false;
    boolean noStdTermdefined=true;
    boolean noNonStdTermdefined=true;
    List<Contract_Terms_and_Conditions__c> contractStdTermsandConditionsList = new List<Contract_Terms_and_Conditions__c>();
    List<Contract_Terms_and_Conditions__c> contractNonStdTermsandConditionsList = new List<Contract_Terms_and_Conditions__c>();
    list<TermsandConditionsViewClass> stdTermsandConditionsViewList = new list<TermsandConditionsViewClass>();
    list<TermsandConditionsViewClass> nonStdTermsandConditionsViewList = new list<TermsandConditionsViewClass>();
    public class TermsandConditionsViewClass{
        public CSMB_Terms_and_Conditions_Maintenance__c repositoryName{get;set;}
        public list <Contract_Terms_and_Conditions__c> ConTermsandConditionsList{get;set;}
        public TermsAndConditionsViewClass(CSMB_Terms_and_Conditions_Maintenance__c standardTermsObj,list<Contract_Terms_and_Conditions__c> ConTermsandConditionsList){
            repositoryName=standardTermsObj;
            this.ConTermsandConditionsList= ConTermsandConditionsList;
        }
    }
    public CMVFTermsandConditionsViewController(ApexPages.StandardController controller){
        contractObj = (Contract)controller.getRecord();
        for(RecordType recType : [select id,name from RecordType where SobjectType='Contract_Terms_and_Conditions__c']){
            if(recType.Name =='Standard Terms and Conditions')
                stdRecTypeid = recType.id;
            if(recType.Name =='Non-Standard Terms and Conditions')
                nonStdRecTypeId = recType.id;
        } 
        contractStdTermsandConditionsList=[select id,RecordtypeId,Contract__c,Standard_Term__c,Terms_and_Conditions__c,Terms_and_conditions_Content__c,section__c from Contract_Terms_and_Conditions__c where contract__c=:contractObj.id and Recordtypeid=:stdRecTypeid];
        contractNonStdTermsandConditionsList=[select id,RecordtypeId,Contract__c,Standard_Term__c,Standard_Term__r.name,Terms_and_conditions_Content__c,section__c  from Contract_Terms_and_Conditions__c where contract__c=:contractObj.id and recordtypeid=:nonStdRecTypeId];
        displayTerms(contractStdTermsandConditionsList,stdTermsandConditionsViewList,stdRecTypeid);
        standardterms.clear();
        displayTerms(contractNonStdTermsandConditionsList,nonStdTermsandConditionsViewList,nonStdRecTypeId); 
        if(stdTermsandConditionsViewList.size()>0){
            stdTerms = true;
            noStdTermdefined=false;
        }
        if(nonStdTermsandConditionsViewList.size()>0){
            nonStdTerms = true;
            noNonStdTermdefined=false;
        }
    }
    public void displayTerms(List<Contract_Terms_and_Conditions__c> ConTandCList,list<TermsandConditionsViewClass> TermsandConditionsViewList,Id rectype){
        
            for(Contract_Terms_and_Conditions__c uniqeStandardTerms: ConTandCList){
                standardTerms.add(uniqeStandardTerms.Standard_Term__c);
            }
            List<CSMB_Terms_and_Conditions_Maintenance__c>  viewStandardTermsList= new List<CSMB_Terms_and_Conditions_Maintenance__c>();
            viewStandardTermsList=[select id,name from  CSMB_Terms_and_Conditions_Maintenance__c where id in :standardTerms];
            for(CSMB_Terms_and_Conditions_Maintenance__c displayStdTerm:viewStandardTermsList){
                list<Contract_Terms_and_Conditions__c> tempviewTermsList = new list<Contract_Terms_and_Conditions__c>();
                for(Contract_Terms_and_Conditions__c displayTerm:ConTandCList){    
                    if(displayStdTerm.id==displayTerm.Standard_Term__c){
                        tempviewTermsList.add(displayTerm);  
                    }
                }
                if(rectype==stdRecTypeid){
                    TermsandConditionsViewList.add(new TermsandConditionsViewClass(displayStdTerm,tempviewTermsList));            
                }else if(rectype==nonStdRecTypeId){
                    NonStdTermsandConditionsViewList.add(new TermsandConditionsViewClass(displayStdTerm,tempviewTermsList));            
                }
            }
        
         
    }
   /* public void displayTerms(List<Contract_Terms_and_Conditions__c> ConTandCList,list<TermsandConditionsViewClass> TermsandConditionsViewList,Id rectype){
        if(rectype==stdRecTypeid){
            for(Contract_Terms_and_Conditions__c uniqeStandardTerms: ConTandCList)
            {
                standardTerms.add(uniqeStandardTerms.Standard_Term__c);
            }
            List<CSMB_Terms_and_Conditions_Maintenance__c>  viewStandardTermsList= new List<CSMB_Terms_and_Conditions_Maintenance__c>();
            viewStandardTermsList=[select id,name from  CSMB_Terms_and_Conditions_Maintenance__c where id in :standardTerms];
            for(CSMB_Terms_and_Conditions_Maintenance__c displayStdTerm:viewStandardTermsList)
            {
                list<Contract_Terms_and_Conditions__c> tempviewTermsList = new list<Contract_Terms_and_Conditions__c>();
                for(Contract_Terms_and_Conditions__c displayTerm:ConTandCList)
                {    
                    if(displayStdTerm.id==displayTerm.Standard_Term__c)
                    {
                        tempviewTermsList.add(displayTerm);  
                    }
                }
                TermsandConditionsViewList.add(new TermsandConditionsViewClass(displayStdTerm,tempviewTermsList));            
            }
        }
        if(rectype==nonStdRecTypeId){
            for(Contract_Terms_and_Conditions__c uniqeStandardTerms: ConTandCList)
            {
                standardTerms.add(uniqeStandardTerms.Standard_Term__c);
            }
            List<CSMB_Terms_and_Conditions_Maintenance__c>  viewStandardTermsList= new List<CSMB_Terms_and_Conditions_Maintenance__c>();
            viewStandardTermsList=[select id,name from  CSMB_Terms_and_Conditions_Maintenance__c where id in :standardTerms];
            for(CSMB_Terms_and_Conditions_Maintenance__c displayStdTerm:viewStandardTermsList)
            {
                list<Contract_Terms_and_Conditions__c> tempviewTermsList = new list<Contract_Terms_and_Conditions__c>();
                for(Contract_Terms_and_Conditions__c displayTerm:ConTandCList)
                {    
                    if(displayStdTerm.id==displayTerm.Standard_Term__c)
                    {
                        tempviewTermsList.add(displayTerm);  
                    }
                }
                NonStdTermsandConditionsViewList.add(new TermsandConditionsViewClass(displayStdTerm,tempviewTermsList));            
            }
        }  
    }*/
    public PageReference clickOk(){
         return PageUtils.redirect('/'+contractObj.Id);
    }
    public list<TermsandConditionsViewClass> getstdTermsandConditionsViewList(){
        return stdTermsandConditionsViewList;
    }
    public void setstdTermsandConditionsViewList(list<TermsandConditionsViewClass> stdTermsandConditionsViewList){
        this.stdTermsandConditionsViewList=stdTermsandConditionsViewList;
    }
    public list<TermsandConditionsViewClass> getnonStdTermsandConditionsViewList(){
        return nonStdTermsandConditionsViewList;
    }
    public void setnonStdTermsandConditionsViewList(list<TermsandConditionsViewClass> nonStdTermsandConditionsViewList){
        this.nonStdTermsandConditionsViewList=nonStdTermsandConditionsViewList;
    }
    public boolean getStdTerms(){
        return stdTerms;
    }
    private void setStdTerms(boolean stdTerms){
        this.stdTerms =stdTerms;
    }
    public boolean getNonStdTerms(){
        return nonStdTerms;
    }
    private void setnonStdTerms(boolean nonStdTerms){
        this.nonStdTerms=nonStdTerms;
    }
    public boolean getnoStdTermdefined(){
        return noStdTermdefined;
    }
    private void setnoStdTermdefined(boolean noStdTermdefined){
        this.noStdTermdefined=noStdTermdefined;
    }
    public boolean getnoNonStdTermdefined(){
        return noNonStdTermdefined;
    }
    private void setnoNonStdTermdefined(boolean noNonStdTermdefined){
        this.noNonStdTermdefined=noNonStdTermdefined;
    } 
}