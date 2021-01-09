public with sharing class VFCntrlr_CertTracker_DelCertArea {
    ApexPages.StandardSetController setCon ;
    public String Region{get; set;}
    public String mpText{get; set;}    
    
    public List<String> selAvailableList {get; set;}
    public List<String> selSelectList {get; set;}   
    Set<String> selList = new Set<String>() ;
    Set<String> AvalList = new Set<String>() ;
    boolean showBlkCond = true;
    public boolean chkSelectAll {get; set;}   
    // variables for Paging
    private static final Integer PAGE_SIZE = 25;
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
    
    public VFCntrlr_CertTracker_DelCertArea(){   
        chkSelectAll = false;
        //.... get all valid certification names from the picklist values        
        Schema.DescribeFieldResult availableList_field = Certification_Requirement_Setup__c.Certification_Name__c.getDescribe();
        AvalList.clear();
        for (Schema.PicklistEntry f : availableList_field.getPicklistValues()){           
            AvalList.add(f.getLabel());
        }        
        hasNext = false;
        hasPrevious = false;       
        lastPage = 0;
        currentPage= 0;
        NoOfRecords=0;
        selAvailableList = new  List<String>();
        selSelectList = new  List<String>();
    }
           
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('APJ','APJ'));
        options.add(new SelectOption('Canada','Canada'));       
        options.add(new SelectOption('EC-EMEA','EMEA-EM'));
        options.add(new SelectOption('EMEA','EMEA'));
        options.add(new SelectOption('LATAM','LATAM'));
        options.add(new SelectOption('US','US'));
       return options;
    }
    
    public List<SelectOption> getAvailableList() {        
        List<SelectOption> options = new List<SelectOption>();
        for (String f : AvalList){
            options.add(new SelectOption(f,f));           
        }
        options.sort();
        return options;
    }
          
    public List<SelectOption> getSelectedList() {
        List<SelectOption> selectedOptions = new List<SelectOption>();
        for(String s: selList ){
            selectedOptions.add(new SelectOption(s, s));              
        }
        return selectedOptions;
    }  
     
    //code for right and left button
    public void availableToSelected() {
        try{
            if(selAvailableList != null){ 
                for(string s : selAvailableList ){
                   if(! selList.contains(s))
                       selList.add(s);
                   if ( AvalList.contains(s))
                       AvalList.remove(s);                   
                }               
            }
        }
        catch(Exception e){
            System.debug('Exception : ' + e);
        }
    }
       
    public void unSelectToAvailable() {
        try{
            if(selSelectList != null){ 
                for(string s : selSelectList ){
                    if(! AvalList.contains(s))
                        AvalList.add(s);  
                    
                    if (selList.contains(s))
                        selList.remove(s);                    
                }               
            }
        }
        catch(Exception e){
            System.debug('Exception' +e);
        }
    }
    //end tag for right and left button
    
    public PageReference go(){      
        if(Region == null ){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error,System.Label.NetExam_DelCertArea_ErrorMsg3));
        } 
        else if( selList.isEmpty() && mpText == ''){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error,System.Label.NetExam_DelCertArea_ErrorMsg1));
        }       
        else{
            showBlkCond = false;  
            setcon = null;              
            refersh_setCon();               
        }
        return null;                                                               
        
    }      
   
    public Static String getKeyprefix(){   
        //Schema.DescribeSObjectResult sObjDesc = Account.sObjectType.getDescribe();  
        //return '/'+ sObjDesc.keyPrefix;
        Schema.DescribeSObjectResult sObjDesc = Certification_Tracker__c.sObjectType.getDescribe();  
        return '/'+ sObjDesc.keyPrefix;
    }
    
    public PageReference cancel(){        
        return new PageReference(getKeyPrefix());    
    } 
    
    public PageReference back(){
        showBlkCond = true;
        return null;                                                               
    }
   
    public PageReference delValues(){ 
        chkSelectAll = false;
        list<Certification_Tracker__c> updatedlst_CTracker = new list<Certification_Tracker__c>();   
        integer cntSelRecords = 0;
    
        List<String> mp_CertList = new list<String>();
        if(mpText != '' && mpText != null){         
            Master_Program_Setup__c mpName = [select Master_Program_Name__c, Certification_Name__c
                                                    from Master_Program_Setup__c
                                                    where Master_Program_Name__c = :mpText]; 
            if(mpName.Certification_Name__c != null)                        
                mp_CertList.addAll(mpName.Certification_Name__c.split(';'));
        }
        
        for(acctTableRow aRow : tableRows ){            
            if (aRow.isSelected == true){
                cntSelRecords++;
                Certification_Tracker__c ct = aRow.Acct;                
                Set<String> certCompleted = new Set<String>();
                Set<String> delCertArea = new Set<String>(); 
                
                if(ct.Certification_Completed__c != null)           
                    certCompleted.addAll(ct.Certification_Completed__c.split(';')); 

                if(ct.Dell_Certification_Areas__c != null)
                    delCertArea.addAll(ct.Dell_Certification_Areas__c.split(';'));  
                
                if(selList != null){ 
                    certCompleted.removeAll(selList);
                    delCertArea.removeAll(selList);
                }
                if(mpText != '' && mpText != null){
                    delCertArea.remove(mpText);                    
                    if(! mp_CertList.isEmpty())                        
                        certCompleted.removeAll(mp_CertList);
                }
               
                String cert='';
                for (String c : certCompleted){
                    if (cert =='')
                        cert = c;
                    else
                        cert = cert + ';' + c;
                }
                string delCert='';
                for(String dc : delCertArea){
                    if (delCert=='')
                        delCert= dc;
                    else
                        delCert= delCert+ ';' + dc;
                }
                ct.Certification_Completed__c = cert;
                ct.Dell_Certification_Areas__c = delCert;
                updatedlst_CTracker.add(ct);
            }
        }
        if (!updatedlst_CTracker.isEmpty()){
            update updatedlst_CTracker;
        }
        
        if(cntSelRecords == 0)
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error,System.Label.NetExam_DelCertArea_ErrorMsg2));
        else{
            setcon = null;  
            refersh_setCon();       
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Confirm,System.Label.NetExam_DelCertArea_Msg2));
        }       
        return null;
    }
    
    private void refersh_setCon(){
        try{                
            if(setCon == null) {
                List<Country__c> Country = [select Code__c from Country__c where Region__c = :Region];
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
                String queryCertCriteria = '';
                String queryCertCriteria1 = '';  
                if(! selList.isEmpty()){
                    for (String cert : selList ){
                        if (queryCertCriteria == ''){
                            queryCertCriteria = ' Certification_Completed__c includes (\'' +  cert + '\'';
                        }
                        else{
                            queryCertCriteria = queryCertCriteria + ', \'' + cert + '\'';
                        }
                    }
                if (queryCertCriteria != '')
                    queryCertCriteria = queryCertCriteria + ')';
                }
      
                if(mpText != ''){
                    queryCertCriteria1 = 'Dell_Certification_Areas__c  includes (\'' + mpText + '\' ) ';
                }
    
                String query = 'select  Account_Name__r.id , Account_Name__r.name, ' 
                         + ' Account_Name__r.Account_ID__c,Account_Country__c, Dell_Certification_Areas__c, Certification_Completed__c'
                         + ' from Certification_Tracker__c '
                         + ' where Account_Name__r.Account_Country_Code__c in :CountryCodes ';
    
                if (queryCertCriteria != '' && queryCertCriteria1 =='')          
                        query = query + ' AND ' + queryCertCriteria; 
                        
                if(queryCertCriteria1 !='' && queryCertCriteria == '')
                    query = query + ' AND ' + queryCertCriteria1; 
                    
                if(queryCertCriteria1 !='' && queryCertCriteria != '')
                    query = query + ' AND ( ' + queryCertCriteria + ' OR ' + queryCertCriteria1 + ')'; 
    
                query = query + ' Order By Account_Name__r.name limit 500';   
                 
                setCon =  new ApexPages.StandardSetController(Database.getQueryLocator(query ));
                                   
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
        }   
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
                return null;
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
                return null;
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
         
    //getter methods
    public boolean getHasPreviousAndNext(){        
        return (hasPrevious && hasNext);    
    }
    
    public List<acctTableRow> getAccounts(){
        try{   
            recAccounts= new List<Certification_Tracker__c>(); 
            
            if (setCon != null)         
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
    
    public boolean getshowBlkCond(){
        return showBlkCond;
    }    
}