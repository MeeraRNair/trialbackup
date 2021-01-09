public with sharing class VFCntrlr_MasterProgram_ReqList {
    //variables for paging
    private static final Integer PAGE_SIZE=10;
    public Integer currentPage {get; private set;}    
    public Integer lastPage {get; private set;}
    public Boolean hasPreviousAndNext;     
    public Boolean hasNext {get; private set;}    
    public Boolean hasPrevious {get; private set;}
    public Integer NoOfRecords {get; private set;}    
    public Id pageID = null;
    //public string appReq = '';
    //public string region = '';
    //public string country = '';
    List<String> certNames = new List<String>();
    
    private List<Certification_Requirement_Setup__c> recReqList = new List<Certification_Requirement_Setup__c>();
    
    public VFCntrlr_MasterProgram_ReqList (ApexPages.StandardController stdController){
         hasNext = false;
         hasPrevious = false;       
         lastPage = 0;
         currentPage= 0;
         NoOfRecords=0;
         pageID = ApexPages.currentPage().getParameters().get('id');         
         system.debug('page id: ' +pageID);
        if(pageID != null){
         Master_Program_Setup__c masterList = [SELECT Certification_Name__c, Apply_Requirement_To__c, Region__c, Country__c 
                                                 FROM Master_Program_Setup__c  
                                                 WHERE id =:pageId];
        
         //appReq = masterList.Apply_Requirement_To__c;
         //region = masterList.Region__c;
         //country = masterList.Country__c;         
         if (masterList.Certification_Name__c != null)
             certNames = masterList.Certification_Name__c.split(';');
         
         recReqList = (List<Certification_Requirement_Setup__c>) this.setCon.getRecords(); 
        }

    }   
    
     private ApexPages.StandardSetController setCon {
     get { 
         if(this.setCon == null) {             
             /*//region - chk region       
             if(appReq == 'Region'){             
                this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT id, name, Apply_Requirement_To__c, Certification_Name__c 
                     FROM Certification_Requirement_Setup__c 
                     WHERE Apply_Requirement_To__c =:appReq 
                     AND Region__c  = :region
                     AND Certification_Name__c IN :certNames]));                                     
                system.debug(setCon.getRecords());                    
             }
             //country
             else if(appReq == 'Country'){
                this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT id, name, Apply_Requirement_To__c, Certification_Name__c 
                     FROM Certification_Requirement_Setup__c 
                     WHERE Apply_Requirement_To__c =:appReq 
                     AND Country__c =:country
                     AND Certification_Name__c IN :certNames]));
                     system.debug('###country:###' +country);
             }
            //global
            else{}*/ //Checking apply req to
            this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                        [SELECT id, name, Apply_Requirement_To__c, Certification_Name__c 
                         FROM Certification_Requirement_Setup__c 
                         WHERE Certification_Name__c IN :certNames]));
                         /*
                         [SELECT id, name, Apply_Requirement_To__c, Certification_Name__c 
                         FROM Certification_Requirement_Setup__c 
                         WHERE Apply_Requirement_To__c =:appReq 
                         AND Certification_Name__c IN :certNames]));
                         */
                                     
            if(this.setCon.getResultSize()>0){                     
                this.setCon.setPageSize(PAGE_SIZE);
                setNextPrevious();
                NoOfRecords = this.setCon.getResultSize(); 
                this.setCon.last();                                        
                lastPage = this.setCon.getPageNumber();
                this.setCon.first();                        
                currentPage = this.setCon.getPageNumber();
            }                           
        }   
        return this.setCon;        
     }        
     set;
    }
     
     //Function get called when user click on  'Save & Next' link   
     public PageReference next() {        
        if (hasNext){  
            try {
                //save changed records before displaying next list of records    
                this.setCon.save();
                this.setCon.next();             
                currentPage = this.setCon.getPageNumber();
                setNextPrevious();  
            } 
            catch(Exception e){
                ApexPages.addMessages(e);
                return null;
            }           
        }     
        return null;    
     }        
     
     //Function get called when user click on  'Save & previous' link  
     public PageReference previous() {        
        if (hasPrevious){ 
            try {
                this.setCon.save();
                this.setCon.previous();            
                currentPage = this.setCon.getPageNumber();
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
        if (this.setCon.getHasNext()) {            
            hasNext = true;        
        }        
        else {            
            hasNext = false;        
        }        
        if (this.setCon.getHasPrevious()) {            
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
    
    public List<Certification_Requirement_Setup__c> getReqList(){           
        return recReqList ;
    }           
}