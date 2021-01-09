public class VFCntrlr_NonCogsSOW extends SOWBaseCls{

    RecordType alaCarteRT;    
    
    public List<DisplayDetailsWrapper> DisplayDetails {get; set;}
   
    public Double pkgtotalproposedMDF {get; set;}
    
    public class DisplayDetailsWrapper{
        public String dispStr {get;  set;}
        public String packageName {get;  set;}
        public String businessSegment {get;  set;}
        public Double pkgratecardpricetotal {get;  set;}
        public List<Associated_Programs_Vendors__c> apvList {get;  set;}
        public Double rateCardPriceForNonPkg { get; set;}
        public Double rateCPriceForPkGAndNonPkg {get;  set;}
        public List<Associated_Programs_Vendors__c> apvListWithoutPkg {get;  set;}   
              
        public DisplayDetailsWrapper(String pkgRec,String bSegment,List<Associated_Programs_Vendors__c> apvRecs,List<Associated_Programs_Vendors__c> apvElts,String dStr){
                dispStr=dStr;
                packageName=pkgRec;
                system.debug('###packageName:' + packageName);
                system.debug('###dispStr:' + dispStr);
                businessSegment=bSegment;
                apvList=apvRecs;
                pkgratecardpricetotal=0;
                rateCardPriceForNonPkg=0;
                rateCPriceForPkGAndNonPkg=0;
                apvListWithoutPkg=apvElts;
                for(Associated_Programs_Vendors__c apv:apvList){
                    if(apv.Package__c!=null && apv.Budgeted_Price__c!=null){
                      
                        pkgratecardpricetotal = pkgratecardpricetotal + apv.Budgeted_Price__c;
                        
                    }
                }
                for(Associated_Programs_Vendors__c apvWithoutPkg:apvListWithoutPkg){
                    if(apvWithoutPkg.Budgeted_Price__c!=null){
                        rateCardPriceForNonPkg = rateCardPriceForNonPkg + apvWithoutPkg.Budgeted_Price__c;
                    }
                }
                rateCPriceForPkGAndNonPkg = pkgratecardpricetotal + rateCardPriceForNonPkg;
        }
    } 
    
   
    public VFCntrlr_NonCogsSOW(ApexPages.StandardController controller) { 
        
        pkgtotalproposedMDF = 0;
        DisplayDetails=new List<DisplayDetailsWrapper>(); 
     
        alaCarteRT=[select id,name,SobjectType  from RecordType 
        where SobjectType='Marketing_Plan__c' and name='Ala Carte Marketing Plan' limit 1]; 
         
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        
        MarketingPlan= database.query(ViperSOQLMethod.getQueryMethod1(new Marketing_Plan__c(),'VFCntrlr_NonCogsSOW') + ' where id=\''+controller.getId()+'\' and recordTypeId=\''+alaCarteRT.id+'\' and Contract_Type__c=\'Ala Carte\'');
       
        
        populateYear();
        popualtePackageMap();
        groupAPVBybusinessSegment();
        for(String strBSeg:businessSegmentSet){
            
            prepareDisplayDetails(strBSeg);
            DisplayDetails.add(new DisplayDetailsWrapper(strPackName,strBSeg,PkgApvs,NoPkgApvs,displayStr));
        
        }
        System.debug('###DisplayDetails'+DisplayDetails);
        for(DisplayDetailsWrapper recs:DisplayDetails){
            pkgtotalproposedMDF = pkgtotalproposedMDF+recs.pkgratecardpricetotal+recs.rateCardPriceForNonPkg;
        }
        
        
        concatenateAddress();
        
    }
   
    
   
    
}