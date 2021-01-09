public class VFCntlr_COGSOEMSOW{

    Boolean packageAPVErr=false;
    RecordType volumeBasedRT;
    MDF_Contact__c mdfContact = new MDF_Contact__c();
    Marketing_Plan__c marketingPlanRec;    
    ID recordId;
    Set<String> mdfAssociatedContactset = new Set<String>();   
    List<Package__c> packageList=new List<Package__c>();    
    List<Associated_Programs_Vendors__c> associatedPgmVendorList=new List<Associated_Programs_Vendors__c>();
    List<DisplayDetails> wrapperRecords=new List<DisplayDetails>();
    List<BSgmntAPV> BSgmntAPVRecs=new List<BSgmntAPV>();
    List<Volume_Based_Rule_Line_Item__c> vbrhLnItemList=new List<Volume_Based_Rule_Line_Item__c>();
    public boolean isValueFlatRate {get;set;}
    public boolean isValueDedReason {get;set;}  

    public class DisplayDetails{
        public String dispStr {get; set;}
        public String packageName {get; set;}
        public String businessSegment {get; set;}
        public List<Associated_Programs_Vendors__c> apvList {get; set;}   
        public List<Associated_Programs_Vendors__c> apvListWithoutPkg {get; set;}

        public DisplayDetails(String pkgRec,String bSegment,List<Associated_Programs_Vendors__c> apvRecs,List<Associated_Programs_Vendors__c> apvElts,String dStr){
                dispStr=dStr;
                packageName=pkgRec;
                businessSegment=bSegment;
                apvList=apvRecs;
                apvListWithoutPkg=apvElts;
        }
    }

    public class BSgmntAPV{        
        public String businessSegment {get; set;}
        public List<Associated_Programs_Vendors__c> apvList {get; set;}        
        public BSgmntAPV(String bSegment,List<Associated_Programs_Vendors__c> apvRecs){                
                businessSegment=bSegment;
                apvList=apvRecs;
        }
    } 

    public VFCntlr_COGSOEMSOW(ApexPages.StandardController controller) {
        String BSgmnt;
        String BSgmntRegionSubregion;
        Id marketingPlanId=controller.getId();
        Id subVendorId;
        Set<String> businessSegmentSet=new Set<String>();
        Set<String> BSgmntSet=new Set<String>();
        List<Associated_Programs_Vendors__c> apvLst=new List<Associated_Programs_Vendors__c>();
        Map<Id,Package__c> packageMap=new Map<Id,Package__c>(); 
        Map<String,List<Associated_Programs_Vendors__c>> apvListMap=new Map<String,List<Associated_Programs_Vendors__c>>(); 
        Map<String,List<Associated_Programs_Vendors__c>> apvListMap2=new Map<String,List<Associated_Programs_Vendors__c>>(); 
        String strPackName = '';
        String displayStr = 'none';
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility(); 

        volumeBasedRT=[select id,name,SobjectType  from RecordType where SobjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];

        marketingPlanRec= database.query(ViperSOQLMethod.getQueryMethod1(new Marketing_Plan__c(),'VFCntlr_COGSOEMSOW') + ' where id=\''+controller.getId()+'\' and recordTypeId=\''+volumeBasedRT.id+'\' and Contract_Type__c=\'Volume Based\'');
        
        if(marketingPlanRec.Volume_Based_Rule_Header__r.Flat_Rate_Deduction__c == null ){            
            isValueFlatRate = false;
        }
        else{
            isValueFlatRate = true;
        }

        if(marketingPlanRec.Volume_Based_Rule_Header__r.Deduction_Reason__c == null){        
            isValueDedReason = false;       
        }else{
            isValueDedReason  = true;
        }

        for(Package__c pkg:[Select Name,id,Fiscal_Quarter__c,Marketing_Plan__c,
        Package_Price_del__c  from Package__c where Marketing_Plan__c=:marketingPlanId]){
            packageMap.put(pkg.Id,pkg);             
        }           
        
        associatedPgmVendorList = database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'VFCntlr_COGSOEMSOW') + 'where vendor__c=\''+marketingPlanRec.Vendor__c+'\' and Marketing_Plan__c=\''+marketingPlanId+'\' and Status__c=\'Accepted\' order by Business_Segment__c');

        for(Associated_Programs_Vendors__c apvListElt:associatedPgmVendorList){
            BSgmnt=apvListElt.Business_Segment__c+' - *'+apvListElt.Region__c+' - *'+apvListElt.Sub_Region__c;
                if(apvListMap2.containsKey(BSgmnt)){
                    apvListMap2.get(BSgmnt).add(apvListElt);
                }
                else{
                    apvListMap2.put(BSgmnt,new List<Associated_Programs_Vendors__c>{apvListElt});                
                }
                businessSegmentSet.add(BSgmnt);                  
               //}                              
           }
        
        for(String strBSeg:businessSegmentSet){
            strPackName = '';
            displayStr = 'none';
            List<Associated_Programs_Vendors__c> apvList=apvListMap2.get(strBSeg);
            List<Associated_Programs_Vendors__c>  NoPkgApvs=new List<Associated_Programs_Vendors__c> () ;
            List<Associated_Programs_Vendors__c>  PkgApvs=new List<Associated_Programs_Vendors__c> () ;
            for(Associated_Programs_Vendors__c apv:apvList){
                if(apv.Package__c==null){
                    NoPkgApvs.add(apv);
                }
                if(apv.Package__c!=null){
                    displayStr = 'block';
                    PkgApvs.add(apv);
                    strPackName = packageMap.get(apv.Package__c).Name;
                }
            }
            wrapperRecords.add(new DisplayDetails(strPackName,strBSeg,PkgApvs,NoPkgApvs,displayStr));
            
        }
        
        for(Associated_Programs_Vendors__c apvListElt:associatedPgmVendorList){
            BSgmntRegionSubregion=apvListElt.Business_Segment__c+' - *'+apvListElt.Region__c+' - *'+apvListElt.Sub_Region__c;
            if(apvListElt.Package__c==null){
                if(apvListMap.containsKey(BSgmntRegionSubregion)){
                    apvListMap.get(BSgmntRegionSubregion).add(apvListElt);
                }else{
                    apvListMap.put(BSgmntRegionSubregion,new List<Associated_Programs_Vendors__c>{apvListElt});                
                }
                BSgmntSet.add(BSgmntRegionSubregion);
            }           
       }

        for(String bSeg:BSgmntSet){
            BSgmntAPVRecs.add(new BSgmntAPV(bSeg,apvListMap.get(bSeg)));
        }

        for(MDF_Associated_Contact__c mdfACntct:[select MDF_Contact__c from MDF_Associated_Contact__c
                                              where   Vendor__c =:marketingPlanRec.Vendor__c]){
            mdfAssociatedContactset.add(mdfACntct.MDF_Contact__c);
        }

        RecordType mdfContactRT=[Select Name, Id From RecordType where 
           sObjectType='MDF_Contact__c' and name='Product Manager Contact' limit 1];

        try {
            mdfContact = [select Id, Name, Status__c, Region__c, recordTypeId, Primary_Secondary__c, Email__c,Phone__c
                        from MDF_Contact__c where recordTypeId =: mdfContactRT.Id and Primary_Secondary__c = 'Primary'
                        and id in:mdfAssociatedContactset limit 1];
        } catch (QueryException e) {
            mdfContact = null;        
        }

        if(wrapperRecords.size()==0){
            packageAPVErr=true; 
         }

         try{
             vbrhLnItemList=[Select id,Accrual__c,Additional_Notes__c,Amount_Per_Unit__c,Business_Segment__c,Category__c,
             Class_SubClass__c,Dell_SKU__c,Include_Exclude__c,Manufacturer__c,Vendor__c  
             from Volume_Based_Rule_Line_Item__c where Volume_Based_Rule_Header__c =:marketingPlanRec.Volume_Based_Rule_Header__c];   
         }
         Catch(Exception e){
         }
    }

    public List<Associated_Programs_Vendors__c> getAPVList(){
        return associatedPgmVendorList;
    }
    public Marketing_Plan__c getMarketingPlan(){
        return marketingPlanRec;
    }   
    public List<DisplayDetails> getDisplayDetails(){        
        return wrapperRecords;
    }
    public List<BSgmntAPV> getBSgmntAPV(){        
        return BSgmntAPVRecs;
    }
    public MDF_Contact__c getmdfContact(){
        return mdfContact ;
    }
    public Boolean getPkgApvErr(){
        return packageAPVErr;
    }    
    public List<Volume_Based_Rule_Line_Item__c> getVBRHLLnList(){
        return vbrhLnItemList;
    } 
}