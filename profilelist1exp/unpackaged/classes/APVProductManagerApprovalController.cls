public class APVProductManagerApprovalController{
    Boolean NoAPVErr=false;
    Boolean ToBReviewed=false;
    Boolean mplanErr=false;

    Marketing_Plan__c marketingPlanRec=new Marketing_Plan__c(); 
    Map<Id,Associated_Programs_Vendors__c> allAPVMap=new Map<Id,Associated_Programs_Vendors__c>();     
    List<Associated_Programs_Vendors__c> reviewedList=new List<Associated_Programs_Vendors__c>();
    List<Associated_Programs_Vendors__c> ToBReviewedList=new List<Associated_Programs_Vendors__c>();

    public APVProductManagerApprovalController(ApexPages.StandardController controller){  
        marketingPlanRec=[select id,name,Contract_Status__c,Contract_Type__c,Fiscal_Quarter__c,Invoice__c,Invoice_Amount__c,Purchase_Order__c,
        Rebate_Rule_Header__c,Region__c,Term__c,Vendor__c,Vendor__r.name,Volume_Based_Rule_Header__c,Vendor__r.Budgeted_Discount__c,Sub_Region__c,
        OwnerId,Product_Manager_Approval_Status__c from Marketing_Plan__c where id=:controller.getId()];
        
        if(marketingPlanRec.Product_Manager_Approval_Status__c!=null && marketingPlanRec.Product_Manager_Approval_Status__c!='Pending'){
            for(Associated_Programs_Vendors__c apvElt:[select id,name,vendor__c,MDF_Program__c, recordtypeId,Rate_Card_Price__c,Budgeted_Price__c,
            Business_Segment__c,Marketing_Plan__c,MDF_Program__r.name,Fiscal_Quarter__c,Region__c,sub_region__c,Country__c,Product_Manager_Approval__c
            from Associated_Programs_Vendors__c where marketing_plan__c=:marketingPlanRec.Id order by Business_Segment__c]){                    
                allAPVMap.put(apvElt.Id,apvElt); 
                if(apvElt.Product_Manager_Approval__c!='Approved by product Manager' && apvElt.Product_Manager_Approval__c!='Declined by Product Manager'){
                    //allApvList.add(apvElt); 
                    ToBReviewedList.add(apvElt); 
                } 
                
                if(apvElt.Product_Manager_Approval__c=='Approved by product Manager'||apvElt.Product_Manager_Approval__c=='Declined by Product Manager'){
                    reviewedList.add(apvElt);
                }                  
            } 
            if(ToBReviewedList.size()>0){
                ToBReviewed=true;
            } 
            if(ToBReviewedList.size()==0){
                NoAPVErr=true;
            } 
            
        }else{
            mplanErr=true;
        }
    }
    
    //BR8.3.1.16
    
    public List<Associated_Programs_Vendors__c> getReviewedAPVRecs(){
        return reviewedList;
    }
    
    public List<Associated_Programs_Vendors__c> getToBReviwedList(){
        return ToBReviewedList;
    }
    
    
    public void setToBReviwedList(List<Associated_Programs_Vendors__c> listVar){
        this.ToBReviewedList=listVar;
    }
    
    public PageReference updateAPVs(){
        Associated_Programs_Vendors__c apvVar;
        List<Associated_Programs_Vendors__c> updateList=new List<Associated_Programs_Vendors__c>();   
        
        PageReference currentPageRef=new PageReference('/'+marketingPlanRec.Id);
        for(Associated_Programs_Vendors__c elt:ToBReviewedList){
            apvVar=new Associated_Programs_Vendors__c(Id=elt.Id);
            if(allAPVMap.get(apvVar.Id).Product_Manager_Approval__c!=apvVar.Product_Manager_Approval__c){
                apvVar=elt;
                updateList.add(apvVar);
            }
        }
        
        if(updateList.size()>0){
            update updateList;
        }
        return currentPageRef; 
    }
    public PageReference AcceptAll(){
        Associated_Programs_Vendors__c apvVar;
        List<Associated_Programs_Vendors__c> updateList=new List<Associated_Programs_Vendors__c>();   
        
        PageReference currentPageRef=new PageReference('/'+marketingPlanRec.Id);
        for(Associated_Programs_Vendors__c elt:ToBReviewedList){
            apvVar=new Associated_Programs_Vendors__c(Id=elt.Id);
            apvVar.Product_Manager_Approval__c='Approved by product Manager';
            updateList.add(apvVar);            
        }        
        if(updateList.size()>0){
            update updateList;
        }
        return currentPageRef; 
    }
    public PageReference DeclineAll(){
        Associated_Programs_Vendors__c apvVar;
        List<Associated_Programs_Vendors__c> updateList=new List<Associated_Programs_Vendors__c>();   
        
        PageReference currentPageRef=new PageReference('/'+marketingPlanRec.Id);
        for(Associated_Programs_Vendors__c elt:ToBReviewedList){
            apvVar=new Associated_Programs_Vendors__c(Id=elt.Id);
            apvVar.Product_Manager_Approval__c='Declined by Product Manager';
            updateList.add(apvVar);            
        }        
        if(updateList.size()>0){
            update updateList;
        }
        return currentPageRef; 
    }
    public Boolean getNoAPVErr(){
        return NoAPVErr;
    } 
    public Boolean getToBReviewed(){
        return ToBReviewed;
    }
    public Boolean getMplanErr(){
        return mplanErr;
    }
}