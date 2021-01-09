Public Class VFCntrlr_MoveMPlanPrograms{

    Boolean createMPlan=false; 
    Boolean MPlanOptionList=false;
    Boolean mpErr=false;    
    Boolean apvOptionList=false;
    Boolean errorMsg=false;
    String contractType;
    Id selectedMplan;
    Set<Id> alaCarteIds2=new Set<Id>(); 
    Marketing_Plan__c marketingPlanRec=new Marketing_Plan__c(); 
    Marketing_plan__c newMPlan=new Marketing_plan__c();
    List<APVWrapper> apvWrapperList;
    List<Marketing_Plan__c> mPlanList=new List<Marketing_Plan__c>();
    List<Marketing_Plan__c> mPlanList2=new List<Marketing_Plan__c>();
    List<Marketing_plan__c> mPlans;    
    List<Id> MplanIds=new List<Id>();
    List<Associated_Programs_Vendors__c> selectedAPVs=new List<Associated_Programs_Vendors__c>();     
    List<Associated_Programs_Vendors__c> apvsOfMP;    
    Map<Id,Associated_Programs_Vendors__c> apvMap=new Map<Id,Associated_Programs_Vendors__c>(); 
    Map<Id,Marketing_Plan__c> mPlanMap=new Map<Id,Marketing_Plan__c>();   
    
    public VFCntrlr_MoveMPlanPrograms(ApexPages.StandardController controller){ 
        
        Id marketingPlanId=controller.getId();
        Id subVendorId;
        Set<Id> alaCarteIds=new Set<Id>();
        apvsOfMP=new List<Associated_Programs_Vendors__c>(); 
        mPlans=new List<Marketing_plan__c>();         
        marketingPlanRec=[select id,name,Contract_Status__c,Contract_Type__c,Fiscal_Quarter__c,
        Invoice__c,Invoice_Amount__c,Purchase_Order__c,Rebate_Rule_Header__c,
        Region__c,Term__c,Vendor__c,Vendor__r.name,Volume_Based_Rule_Header__c,Vendor__r.Budgeted_Discount__c,
        Sub_Region__c from Marketing_Plan__c where id=:marketingPlanId];   
         
        apvsOfMP=[select id,name,vendor__c,Status__c,POP_Status__c,Business_Segment__c,
                MDF_Program__c, recordtypeId,Rate_Card_Price__c,
                Budgeted_Price__c,Marketing_Plan__c,LE__c,PUB__c,
                SMB__c,CSMR__c,MDF_Program__r.name,MDF_Program__r.Fiscal_Quarter__c,
                MDF_Program__r.Program_Status__c,MDF_Program__r.Region__c,
                MDF_Program__r.Rate_Card_Price__c,MDF_Program__r.Pricing_Type__c,
                MDF_Program__r.POP_Details__c,Accounting_Treatment__c   
                from Associated_Programs_Vendors__c 
                where vendor__c=:marketingPlanRec.vendor__c and Marketing_Plan__c=:marketingPlanRec.id
                and (status__c='Pending' OR status__c='Declined')order by MDF_Program__r.name];
                
         if(apvsOfMP.size()>0){
             APVOptionList=true;
             errorMsg=false;
         } 
         if(apvsOfMP.size()==0){
             APVOptionList=false;
             errorMsg=true;
         }        
         System.debug('####apvsOfMP'+apvsOfMP);       
       for(Marketing_Plan__c mPlanRec:[select id,name,Contract_Status__c,Contract_Type__c,Fiscal_Quarter__c,
           Invoice__c,Invoice_Amount__c,Purchase_Order__c,Rebate_Rule_Header__c,Region__c,Term__c,
           Vendor__c,Vendor__r.name,Volume_Based_Rule_Header__c,Vendor__r.Budgeted_Discount__c,Sub_Region__c
            from Marketing_Plan__c where Vendor__c=:marketingPlanRec.vendor__c and 
           Fiscal_Quarter__c=:marketingPlanRec.Fiscal_Quarter__c and
          (Contract_Type__c='Volume Based' OR Contract_Type__c='Ala Carte')]){
              if(mPlanRec.Contract_Type__c=='Volume Based' && mPlanRec.id!=marketingPlanRec.id){                  
                  mPlanMap.put(mPlanRec.Id,mPlanRec);                  
                  mPlanList.add(mPlanRec);
              } 
              if(mPlanRec.Contract_Type__c=='Ala Carte' && mPlanRec.Contract_Status__c=='Pending'  && mPlanRec.id!=marketingPlanRec.id){                
                  mPlanMap.put(mPlanRec.Id,mPlanRec);                   
                  mPlanList.add(mPlanRec);
                  if(marketingPlanRec.Contract_Type__c=='Volume Based'){
                      alaCarteIds.add(mPlanRec.Id);
                  }                  
              }
        }
        System.debug('####mPlanList'+mPlanList);     
        if(marketingPlanRec.Contract_Type__c=='Volume Based' && alaCarteIds.size()>0){             
             for(Associated_Programs_Vendors__c apv:[select id,name,vendor__c,Status__c,Marketing_Plan__c from 
             Associated_Programs_Vendors__c where  Marketing_Plan__c in:alaCarteIds]){
                 if(apv.Status__c!='Pending'){
                     alaCarteIds2.add(apv.Marketing_Plan__c);                     
                 }             
             }
         }
        newMPlan.vendor__c=marketingPlanRec.vendor__c;
        newMPlan.Fiscal_Quarter__c=marketingPlanRec.Fiscal_Quarter__c;
        newMPlan.Contract_Status__c='Pending';
        
        if(mPlanList.size()==0){
            MPlanOptionList=false;
            apvOptionList=true;
            errorMsg=false;
            mpErr=true;
        }    
    }
  

 //Wrapper class
    public class APVWrapper{
        public Associated_Programs_Vendors__c apvElt{get; set;}
        public Boolean selected {get; set;}

        //Constructor for wrapper class
        public APVWrapper(Associated_Programs_Vendors__c apvObj){
            apvElt = apvObj;
            selected = false;
        }
    } 
    public Boolean getMpErr(){
        return mpErr;
    }
    
    public Boolean getErrorMsg(){
        return errorMsg;
    }
    public Boolean getAPVOptionList(){
        return apvOptionList;
    }

    public List<APVWrapper> getAPVWrapper(){
        apvWrapperList=new List<APVWrapper>();
        for(Associated_Programs_Vendors__c apvRec: apvsOfMP){             
             apvWrapperList.add(new APVWrapper(apvRec));             
         }     
         return apvWrapperList;   
    }
   
    public void setAPVWrapper(List<APVWrapper> lst){
        this.apvWrapperList=lst;
    }
    public pageReference move2ExistingMPlan(){
        if(marketingPlanRec.Contract_Type__c=='Volume Based' && alaCarteIds2.size()>0){
            for(integer i=0;i<mPlanList.size();i++){
                if(!alaCarteIds2.contains(mPlanList[i].Id)){
                    mPlanList2.add(mPlanList[i]);
                }
            }
            if(mPlanList2.size()>0){
                mPlans=mPlanList2;
            }
        }
        if((marketingPlanRec.Contract_Type__c=='Volume Based' && alaCarteIds2.size()==0)||(marketingPlanRec.Contract_Type__c=='Ala Carte')){
            mPlans=mPlanList;
        }
        
        for(APVWrapper apvrec:apvWrapperList){
             if(apvrec.selected==true){                 
                 selectedAPVs.add(apvrec.apvElt);
             }     
         }
        if(selectedAPVs.size()==0){                    
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select a program.');
            ApexPages.addMessage(msg);            
            return null;        
        }else if(selectedAPVs.size()>0){
            MPlanOptionList=true;
            apvOptionList=false;
            MpErr=false;
            createMPlan=false;
        }
        return null;
    }
    public List<Associated_Programs_Vendors__c> getAPVList(){         
        return selectedAPVs;
    }    
    public List<Marketing_plan__c> getMarketingPlanList(){
        return mPlans;
    }
    public Boolean getMPlanOptionList(){
        return MPlanOptionList;
    }
    public pageReference changeMPlanOfAPV(){
         Associated_Programs_Vendors__c apvObj;         
         Id mplanId2=ApexPages.currentPage().getParameters().get('mid'); 
         Set<String> signedSet=new Set<String>();         
         pageReference retStr=new pageReference('/'+marketingPlanRec.Id);
         List<Associated_Programs_Vendors__c> apvUpdateList=new List<Associated_Programs_Vendors__c>();         
         Marketing_Plan__c destinationMPlan=new Marketing_Plan__c(); 
         for(Associated_Programs_Vendors__c apvrec:selectedAPVs){             
             apvObj=new Associated_Programs_Vendors__c(
                 Id=apvrec.Id,
                 marketing_plan__c=mplanId2,
                 Status__c='Pending',
                 APV_Status__c=null
             );
             apvUpdateList.add(apvObj);                
         }
         if(apvUpdateList.size()>0){
             update apvUpdateList; 
         } 
         
         destinationMPlan=mPlanMap.get(mplanId2);
         destinationMPlan.Contract_Status__c='Pending';
         update destinationMPlan;                 
         return retStr;
    }
    
    public pageReference move2NewMPlan(){ 
        for(APVWrapper apvrec:apvWrapperList){
             if(apvrec.selected==true){                 
                 selectedAPVs.add(apvrec.apvElt);
             }     
         }
         if(selectedAPVs.size()==0){                    
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select a program.');
            ApexPages.addMessage(msg);            
            return null;        
        }else if(selectedAPVs.size()>0){
            createMPlan=true;
            MPlanOptionList=false;
            apvOptionList=false;
            MpErr=false;
        }
        return null; 
    }
    
    public Marketing_plan__c getMarketingPlan(){
        return newMPlan;
    }
    public void  setMarketingPlan(Marketing_plan__c mPlanElt){
        this.newMPlan=mPlanElt;
    }
    public Boolean getCreateMPlan(){
        return  createMPlan;
    }
    
    public pageReference saveMPlan(){           
         Associated_Programs_Vendors__c apvObj;
         pageReference retStr;
         List<Associated_Programs_Vendors__c> apvUpdateList=new List<Associated_Programs_Vendors__c>();
                    
         if(contractType=='Volume Based'){
             RecordType mPlanVBRT=[Select Name, Id From RecordType where sObjectType='Marketing_Plan__c' 
             and name='Volume Based Marketing Plan' limit 1];
             newMPlan.recordTypeId=mPlanVBRT.Id;
             newMPlan.Contract_Type__c='Volume Based';
         }
         if(contractType=='Ala Carte'){
             RecordType mPlanACRT=[Select Name, Id From RecordType where 
             sObjectType='Marketing_Plan__c' and name='Ala Carte Marketing Plan' limit 1];
             newMPlan.recordTypeId=mPlanACRT.Id;
             newMPlan.Contract_Type__c='Ala Carte';
         }
         
         try{
             insert newMPlan;
             retStr=new pageReference('/'+newMPlan.Id);
             for(Associated_Programs_Vendors__c apvrec:selectedAPVs){             
                 apvObj=new Associated_Programs_Vendors__c(
                     Id=apvrec.Id,
                     marketing_plan__c=newMPlan.Id,
                     Status__c='Pending',
                     APV_Status__c=null
                 );
                 apvUpdateList.add(apvObj);                  
             }
             if(apvUpdateList.size()>0){
                 update apvUpdateList;
             }
         }Catch(Exception e){
              ApexPages.Message msg;     
              msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error occured while saving the marketing plan. A marketing plan with the same combination of region, fiscal quarter & contract type already ready exists. '+
              'Please select a different combination');
              ApexPages.addMessage(msg);            
              retStr=null;            
              return null;
         }
        
         return retStr;
    }
    public List<SelectOption> getContractTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Volume Based','Volume Based'));
        options.add(new SelectOption('Ala Carte','Ala Carte'));        
        return options;
    }
    
    public String getContractType(){
        return contractType;
    }
    
    public void setContractType(String cType){
        this.contractType=cType;
    }
}