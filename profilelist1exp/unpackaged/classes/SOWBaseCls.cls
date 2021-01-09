public virtual class SOWBaseCls  {
    
    public String addMarketingStr {get; set;} 
    public List<String> lstOfStr = new List<String>();
    public String addBillingStr {get; set;} 
    public List<String> lstOfBillingStr = new List<String>();
   
    public Marketing_Plan__c MarketingPlan {get; set;}
   
    public Map<Integer,String> monthBynameMap = new Map<Integer,String>{1=> 'January',2=> 'February',3=> 'March',4=>'April',5=> 'May',6=> 'June',7=>'July',8=>'August',9=>'September',10=>'October',11=>'November',12=>'December'};
    public Map<String, Fiscal_Years__c> fiscalQuartersMap = Fiscal_Years__c.getAll();
    public String years {get;  set;} 
    
    public String BSgmnt;
    public Set<String> businessSegmentSet=new Set<String>();
    Map<String,List<Associated_Programs_Vendors__c>> apvListMap2=new Map<String,List<Associated_Programs_Vendors__c>>(); 
    Map<Id,Package__c> packageMap=new Map<Id,Package__c>(); 
    public string strPackName = '';
    public string displayStr = 'none';
    public List<Associated_Programs_Vendors__c> apvList {get; set;}
    public List<Associated_Programs_Vendors__c> apvsList;
    public List<Associated_Programs_Vendors__c>  NoPkgApvs;
    public List<Associated_Programs_Vendors__c>  PkgApvs;
    
     
    public void  populateYear() {
         
        IF(MarketingPlan.Fiscal_Quarter__c != Null && !fiscalQuartersMap.isEmpty()){
             String startingYear;
             String endingYear;
             if(integer.valueof(MarketingPlan.Fiscal_Quarter__c.substring(2,4)) >= 16){
                 Date startdate = fiscalQuartersMap.get(MarketingPlan.Fiscal_Quarter__c).Start_Date__c;
                 startingYear = monthBynameMap.get(startdate.month())+' '+ startdate.day()+', '+startdate.year();
                 Date enddate = fiscalQuartersMap.get(MarketingPlan.Fiscal_Quarter__c).End_Date__c;
                 endingYear = monthBynameMap.get(enddate.month())+' '+ enddate.day()+', ' +enddate.year();
             }
             if(startingYear != null && endingYear != null){
                 years = ' ('+startingYear+' - '+endingYear+')';                            
             }
        }  
     }
     
    public void popualtePackageMap() {
        
        for(Package__c pkg:[Select Name,id,Fiscal_Quarter__c,Marketing_Plan__c,
        Package_Price_del__c  from Package__c where Marketing_Plan__c=:MarketingPlan.Id]){
            packageMap.put(pkg.Id,pkg);             
        } 
    }
    
    public void groupAPVBybusinessSegment() {
        
        apvList= new list<Associated_Programs_Vendors__c>([select id,name,vendor__c,Status__c,POP_Status__c,
        MDF_Program__c, recordtypeId,Business_Segment__c,Marketing_Plan__c,Package__c,
        Region__c,Sub_Region__c,MDF_Program__r.recordType.name,
        MDF_Program__r.Region__c,MDF_Program__r.name,MDF_Program__r.Fiscal_Quarter__c,
        MDF_Program__r.Program_Objective__c,MDF_Program__r.Program_Detail__c,
        MDF_Program__r.Vendor_Materials_Needed__c,MDF_Program__r.POP_Details__c,MDF_Program__r.POP_Owner__r.name,
        MDF_Program__r.Audience_Description__c,MDF_Program__r.Email__c,MDF_Program__r.Audience_Size__c,
        MDF_Program__r.Program_Status__c,MDF_Program__r.Program_Owner__r.name,MDF_Program__r.Rate_Card_Price__c,Budgeted_Price__c,MDF_Program__r.Program_Type__c,Program_Notes__c,MDF_Program__r.Detailed_Job_Description__c
        from Associated_Programs_Vendors__c where vendor__c=:MarketingPlan.Vendor__c 
        and Marketing_Plan__c=:MarketingPlan.Id and Status__c='Accepted' order by Region__c]);
        
           for(Associated_Programs_Vendors__c apvListElt:apvList){              
                  //BSgmnt=apvListElt.Package__c+'#'+apvListElt.Business_Segment__c+' - *'+apvListElt.Region__c+' - *'+apvListElt.Sub_Region__c;
                 if(apvListElt.Region__c == 'Global'){
                     BSgmnt=apvListElt.Region__c+' - '+apvListElt.Business_Segment__c;
                 }
                 else{ 
                     BSgmnt=apvListElt.Region__c+' - '+apvListElt.Sub_Region__c+' - '+apvListElt.Business_Segment__c;
                 }
                       
                 system.debug('###BSgmnt: ' + BSgmnt);          
                  if(apvListMap2.containsKey(BSgmnt)){
                       apvListMap2.get(BSgmnt).add(apvListElt);
                   }else{
                        apvListMap2.put(BSgmnt,new List<Associated_Programs_Vendors__c>{apvListElt});                
                   }
                   businessSegmentSet.add(BSgmnt);                  
           }
    }
    
    public void prepareDisplayDetails(String strBSeg) {
        
            strPackName = '';
            displayStr = 'none';
            apvsList=apvListMap2.get(strBSeg);
            NoPkgApvs=new List<Associated_Programs_Vendors__c> () ;
            PkgApvs=new List<Associated_Programs_Vendors__c> () ;
            for(Associated_Programs_Vendors__c apv:apvsList){
                if(apv.Package__c==null){
                    NoPkgApvs.add(apv);
                }
                if(apv.Package__c!=null){
                    displayStr = 'block';
                    PkgApvs.add(apv);
                    if(packageMap.get(apv.Package__c) != null)
                        strPackName = packageMap.get(apv.Package__c).Name;
                }
            }
    }
    
    public void concatenateAddress() {
        
            if(MarketingPlan.Primary_Marketing_Contact_City__c != null){
                
                lstOfStr.add(MarketingPlan.Primary_Marketing_Contact_City__c);
            }
            if(MarketingPlan.Primary_Marketing_Contact_State__c != null){
                
                lstOfStr.add(MarketingPlan.Primary_Marketing_Contact_State__c);
            }
            if(MarketingPlan.Primary_Marketing_Contact_Zip__c != null){
              
                lstOfStr.add(MarketingPlan.Primary_Marketing_Contact_Zip__c);
            }
            if(MarketingPlan.Primary_Marketing_Contact_Country__c != null){
               
                lstOfStr.add(MarketingPlan.Primary_Marketing_Contact_Country__c);
            }
            for(Integer i=0; i<lstOfStr.size(); i++){
                If(addMarketingStr == null){
                    addMarketingStr = lstOfStr[i];
                }
                else{
                    addMarketingStr = addMarketingStr  + ','+ ' ' + lstOfStr[i];
                }
            }
       
            if(MarketingPlan.Billing_City__c != null){
               
                lstOfBillingStr.add(MarketingPlan.Billing_City__c);
            }
            if(MarketingPlan.Billing_State__c != null){
               
                lstOfBillingStr.add(MarketingPlan.Billing_State__c);
            }
            if(MarketingPlan.Billing_Zip__c != null){
               
                lstOfBillingStr.add(MarketingPlan.Billing_Zip__c);
            }
            if(MarketingPlan.Billing_Contact_Country__c != null){
               
                lstOfBillingStr.add(MarketingPlan.Billing_Contact_Country__c);
            }
            for(Integer i=0; i<lstOfBillingStr.size(); i++){
                If(addBillingStr == null){
                    addBillingStr = lstOfBillingStr[i];
                }
                else{
                    addBillingStr = addBillingStr  + ','+ ' ' + lstOfBillingStr[i];
                }
            } 
        
    }
   
}