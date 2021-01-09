/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0       16170      FY19-0802   13-July-2018    Sakshi          Reduce code
 * 
 */
public class VFCntrlr_SOWAlaCarteOEM {
    
    RecordType volumeBasedRT;
    MDF_Contact__c mdfContact = new MDF_Contact__c();    
    Marketing_Plan__c marketingPlanRec;   
    Set<String> mdfAssociatedContactset = new Set<String>();  
    List<Associated_Programs_Vendors__c> associatedPgmVendorList=new List<Associated_Programs_Vendors__c>();
    List<DisplayDetails> wrapperRecords=new List<DisplayDetails>();
    public Decimal pkgtotalproposedMDF {get; set;}
      
    public class DisplayDetails{
    	public String dispStr {get; set;}
        public String packageName {get; set;}
        public String businessSegment {get; set;}
        public Decimal pkgratecardpricetotal {get; set;}
        public List<Associated_Programs_Vendors__c> apvList {get; set;}   
        public Double rateCardPriceForNonPkg {get; set;}
        public Double rateCPriceForPkGAndNonPkg {get; set;}
        public List<Associated_Programs_Vendors__c> apvListWithoutPkg {get; set;}  
             
        public DisplayDetails(String pkgRec,String bSegment,List<Associated_Programs_Vendors__c> apvRecs, List<Associated_Programs_Vendors__c> apvElts,String dStr){
        		dispStr=dStr;
                packageName=pkgRec;
                businessSegment=bSegment;
                apvList=apvRecs;
                pkgratecardpricetotal=0;
                rateCardPriceForNonPkg=0;
                rateCPriceForPkGAndNonPkg=0;
                apvListWithoutPkg=apvElts;
                for(Associated_Programs_Vendors__c apv:apvList){
                    if(apv.Budgeted_Price__c!=null){
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
    
    public VFCntrlr_SOWAlaCarteOEM(ApexPages.StandardController controller) {
        pkgtotalproposedMDF = 0;
        String BSgmnt;
        String BSgmntRegionSubregion;
        Id marketingPlanId=controller.getId();
        Set<String> businessSegmentSet=new Set<String>();
        Map<Id,Package__c> packageMap=new Map<Id,Package__c>(); 
        Map<String,List<Associated_Programs_Vendors__c>> apvListMap=new Map<String,List<Associated_Programs_Vendors__c>>(); 
        Map<String,List<Associated_Programs_Vendors__c>> apvListMap2=new Map<String,List<Associated_Programs_Vendors__c>>(); 
        String strPackName = '';
        String displayStr = 'none';
        
        volumeBasedRT=[select id,name,SobjectType  from RecordType 
        where SobjectType='Marketing_Plan__c' and name='Ala Carte Marketing Plan' limit 1];
         
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        
        marketingPlanRec= database.query(ViperSOQLMethod.getQueryMethod1(new Marketing_Plan__c(),'VFCntrlr_SOWAlaCarteOEM') + ' where id=\''+controller.getId()+'\' and recordTypeId=\''+volumeBasedRT.id+'\' and Contract_Type__c=\'Ala Carte\'');
        
        for(Package__c pkg:[Select Name,id,Fiscal_Quarter__c,Marketing_Plan__c,
        Package_Price_del__c  from Package__c where Marketing_Plan__c=:marketingPlanId]){
            packageMap.put(pkg.Id,pkg);             
        } 
        
        associatedPgmVendorList = database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'VFCntrlr_SOWAlaCarteOEM') + 'where vendor__c=\''+marketingPlanRec.Vendor__c+'\' and Marketing_Plan__c=\''+marketingPlanId+'\' and Status__c=\'Accepted\' order by Business_Segment__c');
       
           for(Associated_Programs_Vendors__c apvListElt:associatedPgmVendorList){
                  BSgmnt=apvListElt.Business_Segment__c+' - *'+apvListElt.Region__c+' - *'+apvListElt.Sub_Region__c; 
                                 
                  if(apvListMap2.containsKey(BSgmnt)){
                       apvListMap2.get(BSgmnt).add(apvListElt);
                   }else{
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
        for(DisplayDetails recs:wrapperRecords){
            pkgtotalproposedMDF = pkgtotalproposedMDF+recs.pkgratecardpricetotal+recs.rateCardPriceForNonPkg;
        }
        
        for(Associated_Programs_Vendors__c apvListElt:associatedPgmVendorList){
            BSgmntRegionSubregion=apvListElt.Business_Segment__c+' - *'+apvListElt.Region__c+' - *'+apvListElt.Sub_Region__c;
            if(apvListElt.Package__c==null){
                if(apvListMap.containsKey(BSgmntRegionSubregion)){
                    apvListMap.get(BSgmntRegionSubregion).add(apvListElt);
                }else{
                    apvListMap.put(BSgmntRegionSubregion,new List<Associated_Programs_Vendors__c>{apvListElt});                
                }
            }           
                                        
       }
       
        for(MDF_Associated_Contact__c mdfACntct:[select MDF_Contact__c from MDF_Associated_Contact__c
                                              where   Vendor__c =:marketingPlanRec.Vendor__c]){
            mdfAssociatedContactset.add(mdfACntct.MDF_Contact__c);
        }
                                
        RecordType mdfContactRT=[Select Name, Id From RecordType where 
           sObjectType='MDF_Contact__c' and name='Product Manager Contact' limit 1];
        
        try {
            mdfContact = [select Id, Name, Status__c, Region__c, recordTypeId, Primary_Secondary__c, Email__c, Phone__c
                        from MDF_Contact__c where recordTypeId =: mdfContactRT.Id and Primary_Secondary__c = 'Primary'
                        and id in:mdfAssociatedContactset limit 1];
        } catch (QueryException e) {
            mdfContact = null;        
        }
    }

    public List<Associated_Programs_Vendors__c> getAPVList(){
        return associatedPgmVendorList;
    }  
    public List<DisplayDetails> getDisplayDetails(){        
        return wrapperRecords;
    }
    public MDF_Contact__c getmdfContact(){
        return mdfContact ;
    }
}