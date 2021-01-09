public with sharing class VFCntrlr_CertTracker_RegionPopup {
    
    public String Region{get; set;}
    public String fromPage {get; set;} // query string parameter
    
    public VFCntrlr_CertTracker_RegionPopup(){
        fromPage = ApexPages.currentPage().getParameters().get('frompg');
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
    
   public PageReference go(){
        PageReference pgRef = null;
        if (fromPage == 'Eval'){
            pgRef = new PageReference('/apex/Certification_Evaluation?region=' + Region);
        }
        else{
            pgRef = new PageReference('/apex/Certification_tracker?region=' + Region);
        }
        pgRef.setRedirect(true); 
        return pgRef;
    }     
    public Static String getKeyprefix(){   
        Schema.DescribeSObjectResult sObjDesc = Certification_Tracker__c.sObjectType.getDescribe();  
        //return '/'+ sObjDesc.keyPrefix;
        return '/'+ sObjDesc.keyPrefix;
    }
    public PageReference Cancel(){        
        return new PageReference(getKeyPrefix());    
    } 
}