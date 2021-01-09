public class VFCntlr_SOWAlaCarteIngramMicro{

    RecordType volumeBasedRT;    
    Marketing_Plan__c marketingPlanRec;    
    ID recordId;   
    List<Package__c> packageList;  
    List<Associated_Programs_Vendors__c> associatedPgmVendorList=new List<Associated_Programs_Vendors__c>();
    List<DisplayDetails> apvRecLst=new List<DisplayDetails>();
    Decimal budgetPrice=0.00; 
      
    public class DisplayDetails{    
    	public String dispStr {get; set;}
    	public String packageName {get; set;}    
        public String businessSegment {get; set;}
        public List<Associated_Programs_Vendors__c> apvList {get; set;}
        public List<Associated_Programs_Vendors__c> apvListWithoutPkg {get; set;}  
        
        public DisplayDetails(String pkgRec,String bSegment,List<Associated_Programs_Vendors__c> apvRecs,List<Associated_Programs_Vendors__c> apvElts,String dStr){
        		dispStr=dStr;                
                businessSegment=bSegment;
                apvList=apvRecs;
                packageName=pkgRec;
                apvListWithoutPkg=apvElts;
        }
    }   
    
    public VFCntlr_SOWAlaCarteIngramMicro(ApexPages.StandardController controller) { 
        recordId=controller.getId();
        List<Associated_Programs_Vendors__c> apvLst=new List<Associated_Programs_Vendors__c>();
        String busSgmnt;
        String region;
        string subregion;
        String BSgmnt;
        Set<String> businessSegmentSet=new Set<String>();
        Map<Id,Package__c> packageMap=new Map<Id,Package__c>(); 
        Map<String,List<Associated_Programs_Vendors__c>> apvListMap=new Map<String,List<Associated_Programs_Vendors__c>>(); 
        Map<String,List<Associated_Programs_Vendors__c>> apvListMap2=new Map<String,List<Associated_Programs_Vendors__c>>(); 
        String strPackName = '';
        String displayStr = 'none';
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        
        RecordType mPlanACRT=[Select Name, Id From RecordType where 
                             sObjectType='Marketing_Plan__c' and name='Ala Carte Marketing Plan' limit 1];
        
        marketingPlanRec=[select id,Vendor__c,recordTypeId,Contract_Type__c 
        from Marketing_Plan__c where id=:recordId and Contract_Type__c='Ala Carte' and 
        recordTypeId=:mPlanACRT.Id];
            
        for(Package__c pkg:[Select Name,id,Fiscal_Quarter__c,Marketing_Plan__c,
        Package_Price_del__c  from Package__c where Marketing_Plan__c=:marketingPlanRec.Id]){
           packageMap.put(pkg.Id,pkg);             
        } 
            
        associatedPgmVendorList = database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'VFCntlr_SOWAlaCarteIngramMicro') + 
                                ' where vendor__c=\''+marketingPlanRec.vendor__c+'\' and Marketing_Plan__c=\''+recordId+'\' and status__c=\'Accepted\' order by Business_Segment__c'); 
        
        System.debug('###associatedPgmVendorList'+associatedPgmVendorList);
        
        
        for(Associated_Programs_Vendors__c apvListElt:associatedPgmVendorList){     
                 BSgmnt=apvListElt.Business_Segment__c+' - *'+apvListElt.Region__c+' - *'+apvListElt.Sub_Region__c;                
                
                  if(apvListMap2.containsKey(BSgmnt)){
                       apvListMap2.get(BSgmnt).add(apvListElt);
                   }else{
                        apvListMap2.put(BSgmnt,new List<Associated_Programs_Vendors__c>{apvListElt});                
                   }
                   businessSegmentSet.add(BSgmnt);                  
                                             
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
            apvRecLst.add(new DisplayDetails(strPackName,strBSeg,PkgApvs,NoPkgApvs,displayStr));
        }
       
    }
    public List<Associated_Programs_Vendors__c> getApvList(){        
        return associatedPgmVendorList;
    }
    
    public List<DisplayDetails> getDisplayDetails(){        
        return apvRecLst;
    }
    public Decimal getbudgetPrice(){        
        return budgetPrice;
    }
}