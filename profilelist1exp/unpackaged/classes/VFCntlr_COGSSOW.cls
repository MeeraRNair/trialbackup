public class VFCntlr_COGSSOW extends SOWBaseCls{
    
    RecordType volumeBasedRT;
    
    public List<DisplayDetailsWrapper> DisplayDetails {get;set;}
    public List<Volume_Based_Rule_Line_Item__c> VBRHLLnList {get;set;}
    public boolean isValueFlatRate {get;set;}
    public boolean isValueDedReason {get;set;}
    
   
    public class DisplayDetailsWrapper{
        public String dispStr {get;set;}
        public String packageName {get;set;}
        public String businessSegment {get;set;}
        public List<Associated_Programs_Vendors__c> apvList {get;set;}      
        public List<Associated_Programs_Vendors__c> apvListWithoutPkg {get;set;}
        public DisplayDetailsWrapper(String pkgRec,String bSegment,List<Associated_Programs_Vendors__c> apvRecs,List<Associated_Programs_Vendors__c> apvElts,String dStr){
                packageName=pkgRec;
                dispStr=dStr;
                businessSegment=bSegment;
                apvList=apvRecs;
                apvListWithoutPkg=apvElts;
        }
    }
    
    public VFCntlr_COGSSOW(ApexPages.StandardController controller) {
      
        DisplayDetails = new List<DisplayDetailsWrapper>();
        volumeBasedRT=[select id,name,SobjectType  from RecordType 
        where SobjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
         
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        
        MarketingPlan= database.query(ViperSOQLMethod.getQueryMethod1(new Marketing_Plan__c(),'VFCntlr_COGSSOW') + ' where id=\''+controller.getId()+'\' and recordTypeId=\''+volumeBasedRT.id+'\' and Contract_Type__c=\'Volume Based\'');
         System.debug('MarketingPlan: ' + MarketingPlan);
        
        populateYear();
        
         if(MarketingPlan.Volume_Based_Rule_Header__r.Flat_Rate_Deduction__c == null ){
           
            isValueFlatRate = false;
        }
        else{
            isValueFlatRate = true;
        }
        
        if(MarketingPlan.Volume_Based_Rule_Header__r.Deduction_Reason__c == null){
            isValueDedReason = false;       
        }else{
            isValueDedReason  = true;
        }
        
       popualtePackageMap();
       groupAPVBybusinessSegment();
           
       for(String strBSeg:businessSegmentSet){
            
            prepareDisplayDetails(strBSeg);
            DisplayDetails.add(new DisplayDetailsWrapper(strPackName,strBSeg,PkgApvs,NoPkgApvs,displayStr));
        
        } 
       
        try{
            VBRHLLnList=new list<Volume_Based_Rule_Line_Item__c>([Select id,Accrual__c,Additional_Notes__c,Amount_Per_Unit__c,Business_Segment__c,Category__c,
            Class_SubClass__c,Dell_SKU__c,Include_Exclude__c,Manufacturer__c,Vendor__c  
            from Volume_Based_Rule_Line_Item__c where Volume_Based_Rule_Header__c =:MarketingPlan.Volume_Based_Rule_Header__c]);   
            
        }Catch(Exception e){
        }
       
        concatenateAddress();
        
        
    }
   
}