/*
History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      21-May-2012    Krishnamoorthi  Updated for R13.7 Maintenance CR 6942
2.0      03-Jun-2018    sharad  : CR15884  ,VIPER: - APV Creation from Marketing Plan Page
*/
public class ViperContractManagement{              
    
    String Link;
    String businessSeg;
    Id ruleId;  
   
    Boolean createMPlan=false; 
    Boolean MPlanOptionList=false;
    Boolean programList=false;
    Boolean APVList=false;  
    Boolean insertAPV=false;
    Boolean vbrh=false;
    Boolean rrhCreate=false; 
    Boolean vbrhCreate=false;
    Boolean rrh=false;
    Boolean apvOptionList=false;
    Boolean pgmErr=false;
    Boolean apvErr=false;
    Boolean alaCarteErr=false;
                
    MDF_Program__c mdfProgram;
    Marketing_Plan__c marketingPlanRec=new Marketing_Plan__c(); 
    Marketing_plan__c newMPlan=new Marketing_plan__c();
    List<SelectOption> options = new List<SelectOption>();
    List<SelectOption> MPlanOptions = new List<SelectOption>();
    List<Id> MplanIds=new List<Id>();
    
    List<Id> vBRHIdList=new List<Id>(); 
    List<Id> rRHIdList=new List<Id>();
    String selectedRule;
    
    List<MPWrapper> apvMPWrapperList {get; set;} 
    List<MPWrapper> apvMPSelectedList=new List<MPWrapper>(); 
    
    //Wrapper Classes
    List<MPWrapper> listOfMpWrapperRecords {get; set;}
    List<MPWrapper> selectedMpWrapperRecs=new List<MPWrapper>();
    
    List<ProgramWrapper> listOfPgmWrapperRecs {get; set;}
    List<ProgramWrapper> selectedPgmWrapperRecs=new List<ProgramWrapper>();
     
   
    List<Associated_Programs_Vendors__c> apvInsertList=new List<Associated_Programs_Vendors__c>();
    List<Associated_Programs_Vendors__c> mpAPVDisplayList=new List<Associated_Programs_Vendors__c>();
    List<Associated_Programs_Vendors__c> apvsOfMP=new List<Associated_Programs_Vendors__c>();
    List<MDF_Program__c> mdfProgramList=new List<MDF_Program__c>(); 
    
    Map<Id,Marketing_Plan__c> mPlanMap=new Map<Id,Marketing_Plan__c>();   
    
    List<Volume_Based_Rule_Header__c> vBRHList=new List<Volume_Based_Rule_Header__c>();
    List<Rebate_Rule_Header__c> rRHList=new List<Rebate_Rule_Header__c>();
    
    Volume_Based_Rule_Header__c vbrhObj=new Volume_Based_Rule_Header__c();
    Rebate_Rule_Header__c rRHObj=new Rebate_Rule_Header__c(); 
    Map<String,Budgeted_Price_Distribution__c> BudgetedPriceDistributionMap=new Map<String,Budgeted_Price_Distribution__c>();   
   
    List<Associated_Programs_Vendors__c> selectedAPVs=new List<Associated_Programs_Vendors__c>();
    List<Id> selectedIds=new List<Id>();
    List<Volume_Based_Rule_Line_Item__c> vbrhLnItemList=new List<Volume_Based_Rule_Line_Item__c>();  
 
 
     /*********************Constructor***********************************/ 
       
    public ViperContractManagement(ApexPages.StandardController controller){      
    
        String currentURL=ApexPages.currentPage().getUrl();
        String hCFQ1;
        String hCFQ2;
        String hCFQ3;
        String hCFQ4;
        Integer idx=0;
        Id marketingPlanId=controller.getId();
        Id subVendorId;
       
        List<Associated_Programs_Vendors__c> associatedPgmVendorList=new List<Associated_Programs_Vendors__c>();
        List<Associated_Programs_Vendors__c> apvMPList=new List<Associated_Programs_Vendors__c>();        
        List<Associated_Programs_Vendors__c> marketingPlanAPVList=new List<Associated_Programs_Vendors__c>();
        
        Set<Id> programIdSet=new Set<Id>();
        Set<Id> alaCarteNonPendingIdSet=new Set<Id>();
        Set<Id> programIds=new Set<Id>();           
        
        marketingPlanRec=[select id,Contract_Status__c,Contract_Type__c,Fiscal_Quarter__c,
        Invoice__c,Invoice_Amount__c,Purchase_Order__c,Rebate_Rule_Header__c,Region__c,
        Term__c,Vendor__c,Vendor__r.name,Volume_Based_Rule_Header__c,Vendor__r.Budgeted_Discount__c,
        Sub_Region__c,OwnerId from Marketing_Plan__c where id=:marketingPlanId];
        
        subVendorId=marketingPlanRec.Vendor__c;
        
        if(marketingPlanRec.Contract_Type__c!='Rebates'){
            Map<string,string> fqMap=new Map<string,string>(); 
            Schema.DescribeFieldResult F = Marketing_Plan__c.Fiscal_Quarter__c.getDescribe();
            List<Schema.PicklistEntry> pLE=F.getPicklistValues();
            
            for(integer i=0;i<pLE.size();i++){
                //1.0 change -- The Fiscal Quarter filter for associated programs
                if(marketingPlanRec.Fiscal_Quarter__c==String.ValueOf(pLE[i].getLabel())){                    
                    idx=i;
                    break;
                }                   
            }
            if(marketingPlanRec.Term__c=='1' && idx<(pLE.size())){
                hCFQ1=pLE[idx].getLabel();
            } 
            if(marketingPlanRec.Term__c=='2' && idx<(pLE.size()-1)){
                hCFQ1=pLE[idx].getLabel();
                hCFQ2=pLE[idx+1].getLabel();
            } 
            if(marketingPlanRec.Term__c=='3' && idx<(pLE.size()-2)){
                hCFQ1=pLE[idx].getLabel();
                hCFQ2=pLE[idx+1].getLabel();
                hCFQ3=pLE[idx+2].getLabel(); 
            }
            if(marketingPlanRec.Term__c=='4' && idx<(pLE.size()-3)){
                hCFQ1=pLE[idx].getLabel();
                hCFQ2=pLE[idx+1].getLabel();
                hCFQ3=pLE[idx+2].getLabel();
                hCFQ4=pLE[idx+3].getLabel();
            } 
            
           if(marketingPlanRec.Contract_Type__c=='Ala Carte' && marketingPlanRec.Contract_Status__c!='Signed'){
               for(Associated_Programs_Vendors__c apvListElt:[select id,name,vendor__c,Status__c from Associated_Programs_Vendors__c 
                                                            where vendor__c=:subVendorId and Marketing_Plan__c=:marketingPlanRec.Id]){
                   if(marketingPlanRec.Contract_Type__c=='Ala Carte' && (apvListElt.Status__c!=null && apvListElt.Status__c=='Signed')){
                       alaCarteNonPendingIdSet.add(apvListElt.Id);   
                   }   
                }
           } 
            
            if(alaCarteNonPendingIdSet.size()==0 || marketingPlanRec.Contract_Type__c=='Volume Based' || marketingPlanRec.Contract_Type__c=='Headcount'){                
                for(Associated_Programs_Vendors__c apvListElt:[select id,name,vendor__c,Status__c,POP_Status__c,
                                                                MDF_Program__c, recordtypeId,Rate_Card_Price__c,
                                                                Budgeted_Price__c,Business_Segment__c,Marketing_Plan__c,LE__c,PUB__c,
                                                                SMB__c,CSMR__c,MDF_Program__r.name,MDF_Program__r.Fiscal_Quarter__c,
                                                                MDF_Program__r.Program_Status__c,MDF_Program__r.Region__c,
                                                                MDF_Program__r.Rate_Card_Price__c,MDF_Program__r.Pricing_Type__c,
                                                                MDF_Program__r.POP_Details__c,Accounting_Treatment__c,MDF_Program__r.Program_Type__c    
                                                                from Associated_Programs_Vendors__c 
                                                                where vendor__c=:subVendorId and 
                                                                Marketing_Plan__c=null                                                     
                                                                order by MDF_Program__r.Name LIMIT 1000]){                   
                  
                  if((marketingPlanRec.Contract_Type__c!='Headcount')&& 
                      apvListElt.MDF_Program__r.Fiscal_Quarter__c==marketingPlanRec.Fiscal_Quarter__c){
                      if(marketingPlanRec.Region__c != 'Global'){
                          if(apvListElt.MDF_Program__r.Region__c!=null  
                             && apvListElt.MDF_Program__r.Region__c==marketingPlanRec.Region__c){
                                 mpAPVDisplayList.add(apvListElt); 
                          }         
                      } 
                      else{
                          if(apvListElt.MDF_Program__r.Region__c!=null){
                                mpAPVDisplayList.add(apvListElt); 
                          }           
                      }                   
                  }
                  if(marketingPlanRec.Contract_Type__c=='Headcount' && (
                      apvListElt.MDF_Program__r.Fiscal_Quarter__c==hCFQ1||
                      apvListElt.MDF_Program__r.Fiscal_Quarter__c==hCFQ2||
                      apvListElt.MDF_Program__r.Fiscal_Quarter__c==hCFQ3||
                      apvListElt.MDF_Program__r.Fiscal_Quarter__c==hCFQ4)){
                      if(marketingPlanRec.Region__c != 'Global'){
                          if(apvListElt.MDF_Program__r.Region__c!=null  
                             && apvListElt.MDF_Program__r.Region__c==marketingPlanRec.Region__c){
                                 mpAPVDisplayList.add(apvListElt); 
                          }
                      }
                      else{
                          if(apvListElt.MDF_Program__r.Region__c!=null){
                                 mpAPVDisplayList.add(apvListElt); 
                          }  
                      }
                     
                  }
                      
                }
            }
            
            if((marketingPlanRec.Contract_Type__c=='Headcount' && mpAPVDisplayList.size()==0) || (marketingPlanRec.Contract_Type__c=='Volume Based' && mpAPVDisplayList.size()==0)
            || (marketingPlanRec.Contract_Type__c=='Ala Carte' && mpAPVDisplayList.size()==0 && alaCarteNonPendingIdSet.size()==0 && marketingPlanRec.Contract_Status__c!='Signed')){
                for(Associated_Programs_Vendors__c apvListElt:[select id,name,vendor__c,MDF_Program__c
                    from Associated_Programs_Vendors__c where vendor__c=:subVendorId]){                    
                        programIds.add(apvListElt.MDF_Program__c);                    
                }
                string soql;
                string marketingRegion = marketingPlanRec.Region__c;
                string programStatus = 'Approved';              
                if(marketingPlanRec.Region__c != 'Global'){
                    soql = 'select Id,Name,Program_Status__c,OwnerId,Rate_Card_Price__c,Program_Type__c,Pricing_Type__c,POP_Details__c,  Fiscal_Quarter__c,Region__c ,Business_Segment__c, HCID__c from MDF_Program__c where id not in:programIds and  Region__c=: marketingRegion and Program_Status__c =:programStatus order by LastModifiedDate DESC,name LIMIT 1000';       //2.0                    
                }
                else{
                    soql = 'select Id,Name,Program_Status__c,OwnerId,Rate_Card_Price__c,Program_Type__c,Pricing_Type__c,POP_Details__c,  Fiscal_Quarter__c,Region__c ,Business_Segment__c, HCID__c from MDF_Program__c where id not in:programIds and Program_Status__c =:programStatus order by LastModifiedDate DESC,name LIMIT 1000'; //2.0
                }
                
                for(MDF_Program__c mdfPgmElt:Database.Query(soql)){               
                  if(marketingPlanRec.Contract_Type__c=='Headcount'&&(mdfPgmElt.Fiscal_Quarter__c==hCFQ1||
                      mdfPgmElt.Fiscal_Quarter__c==hCFQ2||mdfPgmElt.Fiscal_Quarter__c==hCFQ3||
                      mdfPgmElt.Fiscal_Quarter__c==hCFQ4)){
                        mdfProgramList.add(mdfPgmElt);
                  }
                  if(marketingPlanRec.Contract_Type__c!='Headcount'&& mdfPgmElt.Fiscal_Quarter__c==marketingPlanRec.Fiscal_Quarter__c){
                        mdfProgramList.add(mdfPgmElt);
                  }                       
                } 
            }
            
            System.Debug('mpAPVDisplayList.size()##'+mpAPVDisplayList.size());
            System.Debug('mdfProgramList.size()##'+mdfProgramList.size());
            if(marketingPlanRec.Contract_Type__c=='Ala Carte' &&( marketingPlanRec.Contract_Status__c=='Signed' || (mpAPVDisplayList.size()==0 && mdfProgramList.size()==0))){
                apvErr=false;
                programList=false;
                APVList=false;
                alaCarteErr=true;
            }
            
            if(mpAPVDisplayList.size()==0 && mdfProgramList.size()==0 && marketingPlanRec.Contract_Type__c!='Ala Carte'){
                apvErr=true;
                programList=false;
                APVList=false;
                alaCarteErr=false;
            }
            if(mpAPVDisplayList.size()>0){            
                APVList=true;
                programList=false;
                apvErr=false;
                alaCarteErr=false;
            }
            
            if(mdfProgramList.size()>0){            
                programList=true;
                APVList=false;
                apvErr=false;
                alaCarteErr=false;
            }                 
        
        }
        
        
       //Adding volume based rules to marketing plan 
        
        if(marketingPlanRec.Contract_Type__c=='Volume Based'){        
            vBRHList=[Select Name,Vendor__c,Fiscal_Quarter__c,Region__c, Sub_Region__c from Volume_Based_Rule_Header__c 
                        where Vendor__c=:subVendorId and Fiscal_Quarter__c=:marketingPlanRec.Fiscal_Quarter__c
                        and Region__c=:marketingPlanRec.Region__c];
                        
            if(vBRHList.size()==0 && marketingPlanRec.Contract_Type__c=='Volume Based'){
                Link='/a0w/e?CF00NT0000001H4hA='+marketingPlanRec.Vendor__r.name+
                '&CF00NT0000001H4hA_lkid='+marketingPlanRec.Vendor__c+'&retURL=%2F'+marketingPlanRec.Id;                
               
                vbrhObj.Vendor__c=marketingPlanRec.Vendor__c;
                vbrhObj.Fiscal_Quarter__c=marketingPlanRec.Fiscal_Quarter__c;
                vbrhObj.Region__c=marketingPlanRec.Region__c;
                vbrhObj.Sub_Region__c='--None--';
                vbrhObj.Country__c ='--None--';
                vbrhObj.Status__c='Pending';
                vbrhCreate=true;
      
            } 
            if(vBRHList.size()>1 && marketingPlanRec.Contract_Type__c=='Volume Based'){             
                 for(Volume_Based_Rule_Header__c vbrhRec:vBRHList){
                     options.add(new SelectOption(vbrhRec.Id,vbrhRec.Name));
                     vBRHIdList.add(vbrhRec.Id);
                  }
                  MPlanOptionList=true;              
            } 
        } 
        
        //Adding rebate  rules to marketing plan 
        
        if(marketingPlanRec.Contract_Type__c=='Rebates'){
             rRHList=[select Name,Vendor__c, fiscal_quarter__c,Region__c,sub_Region__c from Rebate_Rule_Header__c
             where Vendor__c=:subVendorId and Fiscal_Quarter__c=:marketingPlanRec.Fiscal_Quarter__c
             and Region__c=:marketingPlanRec.Region__c];
             
               if(rRHList.size()==0 && marketingPlanRec.Contract_Type__c=='Rebates'){
                    Link='/a0x/e?CF00NT0000001H4hK='+marketingPlanRec.Vendor__r.name+
                    '&CF00NT0000001H4hK_lkid='+marketingPlanRec.Vendor__c+'&retURL=%2F'+marketingPlanRec.Id;
                    
                    rRHObj.Vendor__c=marketingPlanRec.Vendor__c;
                    rRHObj.Fiscal_Quarter__c=marketingPlanRec.Fiscal_Quarter__c;
                    rRHObj.Region__c=marketingPlanRec.Region__c;
                    rRHObj.Sub_Region__c='--None--';
                    rRHObj.Country__c ='--None--';
                    rrhCreate=true;
                }
                if(rRHList.size()>1 && marketingPlanRec.Contract_Type__c=='Rebates'){             
                     for(Rebate_Rule_Header__c rrhRec:rRHList){
                         options.add(new SelectOption(rrhRec.Id,rrhRec.Name));
                         rRHIdList.add(rrhRec.Id);
                     } 
                     
                      MPlanOptionList=true;                
                } 
                         
        } 
        
        if(currentURL.contains('MPVolumeBasedRuleLineItem')){
            try{
                 vbrhLnItemList=[Select id,Accrual__c,Additional_Notes__c,Amount_Per_Unit__c,Business_Segment__c,Category__c,
                 Class_SubClass__c,Dell_SKU__c,Include_Exclude__c,Manufacturer__c,Vendor__c,Name 
                 from Volume_Based_Rule_Line_Item__c where Volume_Based_Rule_Header__c =:marketingPlanRec.Volume_Based_Rule_Header__c];   
            
             }Catch(Exception e){
             }
        }
        
             
       
    }//END CONSTRUCTOR
    
   /******************************MP pgm Association *******************************/  
   
     public Boolean getAPVList(){
         return APVList; 
     }
     
     public Boolean getProgramList(){
         return programList; 
     }
     
     public Boolean getApvErr(){
         return apvErr;
     }
     
     public Boolean getAlacarteErr(){
         return alaCarteErr;
     }
        
    public List<MDF_Program__c> getMDFProgramList(){
         return mdfProgramList;
    } 
        
         //Wrapper class
    public class MPWrapper{
        public Associated_Programs_Vendors__c apvMpElt {get; set;}
        public Boolean selected {get; set;}

        //Constructor for wrapper class
        public MPWrapper(Associated_Programs_Vendors__c apvMpObj){
            apvMpElt = apvMpObj;
            selected = false;
        }
    } 
    
    
    public List<MPWrapper> getListOfMpWrapperRecords(){
        MPWrapper mpWrapperElt;
        listOfMpWrapperRecords=new List<MPWrapper>();            
        
        for(Associated_Programs_Vendors__c apv:mpAPVDisplayList){                
            listOfMpWrapperRecords.add(new MPWrapper(apv));
        }
         
        return listOfMpWrapperRecords;
    }
        
    public void setListOfMpWrapperRecords(List<MPWrapper> mpWrapperRecList){
        this.listOfMpWrapperRecords=mpWrapperRecList;
                   
    }
    
    public pagereference updateMPAPVRecords(){
        Associated_Programs_Vendors__c apvRecElt;
        Associated_Programs_Vendors__c tempElt=new Associated_Programs_Vendors__c();
         
        List<Associated_Programs_Vendors__c> apvRecList=new List<Associated_Programs_Vendors__c>(); 
       
        PageReference currentPageRef=new PageReference('/'+marketingPlanRec.Id); 
       
         
         RecordType rtVA=[Select  r.SobjectType, r.Name  From RecordType r where 
        SobjectType='Associated_Programs_Vendors__c'  and name='Vendor Association MP'
         limit 1];
              
        for(MPWrapper MpWElt:listOfMpWrapperRecords){
            
            if(MpWElt.selected==true){                
                tempElt=MpWElt.apvMpElt;                
                apvRecElt=new Associated_Programs_Vendors__c(                                
                    id=MpWElt.apvMpElt.id,
                    Marketing_Plan__c=marketingPlanRec.Id,
                    recordtypeId=rtVA.Id
                    //POP_Status__c='Pending'                   
                );
                if(tempElt.POP_Status__c==null){
                    apvRecElt.POP_Status__c='Pending';
                }
                apvRecList.add(apvRecElt); 
            }             
        }  
                  
        update apvRecList; 
        
        return currentPageRef;     
    }
    
    
    /******************************New MP - Program Association******************************/
    
    
    public class ProgramWrapper{
        public MDF_Program__c pgmMpElt {get; set;}
        public Boolean selected {get; set;}
        public Decimal budgetedPriceDec {get; set;}
        //Constructor for wrapper class
        public ProgramWrapper(MDF_Program__c pgmMpObj){
            pgmMpElt = pgmMpObj;
            selected = false;
            budgetedPriceDec=0;
        }
    } 
    
    
    public List<ProgramWrapper> getListOfPgmWrapperRecs(){
        ProgramWrapper pgmWrapperElt;
        listOfPgmWrapperRecs=new List<ProgramWrapper>();        
        Decimal budPrice=0;
        for(MDF_Program__c pgm:mdfProgramList){           
            if((pgm.Pricing_Type__c=='Variable') || (marketingPlanRec.Vendor__r.Budgeted_Discount__c==null)){
                budPrice=pgm.Rate_Card_Price__c;               
            }
            if(pgm.Pricing_Type__c=='Non-Variable' && pgm.Rate_Card_Price__c!=null && marketingPlanRec.Vendor__r.Budgeted_Discount__c!=null){                    
                budPrice=pgm.Rate_Card_Price__c*((100 - marketingPlanRec.Vendor__r.Budgeted_Discount__c)/100);
            } 
            pgmWrapperElt=new ProgramWrapper(pgm);
            pgmWrapperElt.budgetedPriceDec=budPrice; 
            listOfPgmWrapperRecs.add(pgmWrapperElt);
        }
        System.debug('###listOfPgmWrapperRecs'+listOfPgmWrapperRecs);         
        return listOfPgmWrapperRecs;
    }
        
    public void setListOfPgmWrapperRecs(List<ProgramWrapper> pgmWrapperList){        
        this.listOfPgmWrapperRecs=pgmWrapperList;                    
    }   
    
    public PageReference insertAPVs(){
        MDF_Program__c pgmRecord=new MDF_Program__c();
        Budgeted_Price_Distribution__c budgetedPriceElt;
        Associated_Programs_Vendors__c apvRecord;
        Double budgetedPrice=0; 
        PageReference currentPageRef=new PageReference('/'+marketingPlanRec.Id);         
        
        RecordType rtMP=[Select  r.SobjectType, r.Name  From RecordType r where SobjectType='Associated_Programs_Vendors__c'  and name='Vendor Association MP' limit 1];         
        
        for(ProgramWrapper pgmWELt:listOfPgmWrapperRecs){
            pgmRecord=pgmWELt.pgmMpElt;                      
            if(pgmWELt.selected==true){
                apvRecord=new Associated_Programs_Vendors__c(                                
                    Marketing_Plan__c=marketingPlanRec.Id,
                    MDF_Program__c=pgmRecord.id,
                    recordtypeId=rtMP.Id,
                    Vendor__c=marketingPlanRec.Vendor__c,                                        
                    Rate_Card_Price__c=pgmRecord.Rate_Card_Price__c,
                    POP_Status__c='Pending',
                    //changes by sharad for story 4886286  //2.0
                    Headcount__c=pgmRecord.HCID__c                     
                );
                
                if((pgmRecord.Pricing_Type__c=='Variable')|| (marketingPlanRec.Vendor__r.Budgeted_Discount__c==null)){
                    apvRecord.Budgeted_Price__c=pgmRecord.Rate_Card_Price__c;
                    budgetedPrice=pgmRecord.Rate_Card_Price__c;
                }
                if(pgmRecord.Pricing_Type__c=='Non-Variable' && pgmRecord.Rate_Card_Price__c!=null && marketingPlanRec.Vendor__r.Budgeted_Discount__c!=null){                    
                    apvRecord.Budgeted_Price__c=pgmRecord.Rate_Card_Price__c*((100 - marketingPlanRec.Vendor__r.Budgeted_Discount__c)/100);                    
                    budgetedPrice=pgmRecord.Rate_Card_Price__c*((100 - marketingPlanRec.Vendor__r.Budgeted_Discount__c)/100);
                }       
                apvInsertList.add(apvRecord);
            }
        }
        if(apvInsertList.size()>0){
            try{
                insert apvInsertList;
            }Catch(Exception e){
            }
        }
        
        insertAPV=true;
        return currentPageRef;
    }
    
    public Boolean getInsert(){
        return insertAPV;
    }
    
    public List<Associated_Programs_Vendors__c> getAPVs(){
        List<Associated_Programs_Vendors__c> apvDisplay=new List<Associated_Programs_Vendors__c>(); 
        if(apvInsertList.size()>0){
            apvDisplay=apvInsertList;
        }
        return apvDisplay; 
    } 
    
    /**********Marketing Plan Rules**************************/
    
    public  PageReference  updateMarketingPlanRuleHeader(){
        PageReference currentPageRef; 
        Marketing_Plan__c marketingPlanUnit;  
         if(Link!=null && (vBRHList.size()==0||rRHList.size()==0)){             
             currentPageRef=null;
         }
         
        if(vBRHList.size()==1){            
            marketingPlanUnit=new Marketing_Plan__c(
            id=marketingPlanRec.Id,Volume_Based_Rule_Header__c=vBRHList[0].Id);
            update marketingPlanUnit; 
            currentPageRef=new PageReference('/'+marketingPlanRec.Id);
        }
        if(rRHList.size()==1){            
            marketingPlanUnit=new Marketing_Plan__c(
            id=marketingPlanRec.Id, Rebate_Rule_Header__c=rRHList[0].Id);
            update marketingPlanUnit; 
            currentPageRef=new PageReference('/'+marketingPlanRec.Id);
        }
        if(vBRHList.size()>1){            
            
            currentPageRef=null;
        }
        if(rRHList.size()>1){
            currentPageRef=null;
        }
        return currentPageRef;     
            
    } 
     
    
        public Volume_Based_Rule_Header__c getVolumeBasedRH(){
            return vbrhObj;
        }
        
        public  void setVolumeBasedRH(Volume_Based_Rule_Header__c vbrh){
            this.vbrhObj=vbrh;
        }
        
        public Boolean getCreateVBRH(){
            return vbrhCreate;
        }
        
        public Rebate_Rule_Header__c getRebateRH(){
            return rRHObj;
        }
        
        public  void setRebateRH(Rebate_Rule_Header__c  rrh){
            this.rRHObj=rrh;
        } 
        
        public Boolean getCreateRRH() {
            return rrhCreate;
        } 
    
        public List<SelectOption> getDisplayItems() {
            return options;
        }
        public String getRuleIds() {
           
            return selectedRule;
        }
        public void setRuleIds(String ruleId){       
            this.selectedRule=ruleId;
        }
        
        public Boolean getMPlanOptionList() {
            return MPlanOptionList;
        }
        
        public  PageReference  updateMarketingPlanRuleHeader2(){
            PageReference currentPageRef; 
            Marketing_Plan__c marketingPlanElt;
            if(vBRHList.size()>1){            
                marketingPlanElt=new Marketing_Plan__c(
                Id=marketingPlanRec.Id,Volume_Based_Rule_Header__c=selectedRule);
                update marketingPlanElt; 
                currentPageRef=new PageReference('/'+marketingPlanRec.Id);
            }
            if(rRHList.size()>1){            
                marketingPlanElt=new Marketing_Plan__c(
                Id=marketingPlanRec.Id, Rebate_Rule_Header__c=selectedRule);
                update marketingPlanElt; 
                currentPageRef=new PageReference('/'+marketingPlanRec.Id);
            }
            
            return currentPageRef;  
        
        }
        
        public  PageReference  SaveVBRH(){
            PageReference currentPageRef=new PageReference('/'+marketingPlanRec.Id); 
                    
            insert vbrhObj;
                       
            Marketing_Plan__c marketingPlanElt=new Marketing_Plan__c(
            Id=marketingPlanRec.Id);
            marketingPlanElt.Volume_Based_Rule_Header__c=vbrhObj.Id;
            update marketingPlanElt; 
                
            return currentPageRef;
        }
        
        public  PageReference  SaveRRH(){
            PageReference currentPageRef=new PageReference('/'+marketingPlanRec.Id);
             
            insert rRHObj;
            
            Marketing_Plan__c marketingPlanElt=new Marketing_Plan__c(
            Id=marketingPlanRec.Id);
            marketingPlanElt.Rebate_Rule_Header__c=rRHObj.Id;
            update marketingPlanElt; 
                
            return currentPageRef; 
        }
        
        /*******************Auto Approval********************************/
        
        public static void autoApproveMarketingPlanRecord(List<Marketing_Plan__c> MarketingPlanList){
              
              Id[] idArr; 
            try{
                for(Marketing_Plan__c mplanRec:MarketingPlanList){
                    idArr = new Id[]{};
                    idArr.add(mplanRec.OwnerId);
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for Auto-approval.');
                    req1.setObjectId(mplanRec.Id); 
                    req1.setNextApproverIds(idArr);   
                    
                    Approval.ProcessResult result = Approval.process(req1);
                    System.assert(result.isSuccess());
                    System.assertEquals('Pending', result.getInstanceStatus(), 'Instance status'+result.getInstanceStatus());
                    if(result.isSuccess()==true){
                        List<Id> newWorkItemIds = result.getNewWorkitemIds();
                        
                        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                        req2.setComments('Auto-approved');
                        req2.setAction('Approve');              
                        req2.setNextApproverIds(idArr);
                        req2.setWorkitemId(newWorkItemIds.get(0));
                        
                        Approval.ProcessResult result2 = Approval.process(req2);
                       System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
                       System.assertEquals('Approved', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());
                
                    }
                
                }
            }catch(Exception e){
            }
           
        }
        
        /*Custom code should also query the 'Budgeted Price Distribution' object based on the 'Business Segment' and 'Contract Type'    
        to get the values for 'LE', 'PUB', 'SMB' and 'CSMR'. Multiply these values with the 'Budgeted Price' field value from    
        'Associated Programs' object and populate it into 'LE', 'PUB', 'SMB' and 'CSMR' fields respectively. Update the Record     
        Type to 'Associated Program MP'.*/
        
        public static void UpdateBudgetedPriceDistribution(Set<String> mPlanBSegSet,Set<String> mPlanContractTypeSet,List<Associated_Programs_Vendors__c> APVBPDList,Map<Id,MDF_Program__c> mdfPgmMap){
            try{  

                List<Budgeted_Price_Distribution__c> VB_AlaC_HeadC_BPDList=new List<Budgeted_Price_Distribution__c>(); 

                if(mPlanBSegSet.size()>0 && mPlanContractTypeSet.size()>0){
                    for(Budgeted_Price_Distribution__c bpdElt:[select id,Business_Segment__c,Contract_Type__c,CSMR__c,LE__c,
                                                                PUB__c,SMB__c from Budgeted_Price_Distribution__c where Business_Segment__c =:mPlanBSegSet
                                                                and  Contract_Type__c in:mPlanContractTypeSet]){                                
                        
                        if(bpdElt.Contract_Type__c=='Volume Based' || bpdElt.Contract_Type__c=='Ala Carte' ||bpdElt.Contract_Type__c=='Headcount'){
                            VB_AlaC_HeadC_BPDList.add(bpdElt);
                        } 
                        
                    }


                    RecordType rtMP=[Select  r.SobjectType, r.Name  From RecordType r where SobjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];            

                    for(Associated_Programs_Vendors__c apvElt:APVBPDList){

                       if((apvElt.MP_Contract_Type__c=='Volume Based' || apvElt.MP_Contract_Type__c=='Ala Carte' || apvElt.MP_Contract_Type__c=='Headcount')
                         && VB_AlaC_HeadC_BPDList.size()>0 && apvElt.Budgeted_Price__c!=null){
                            for(Budgeted_Price_Distribution__c BPDRec:VB_AlaC_HeadC_BPDList){
                                if(apvElt.Business_Segment__c==BPDRec.Business_Segment__c && (BPDRec.Contract_Type__c=='Volume Based' || BPDRec.Contract_Type__c=='Ala Carte' || BPDRec.Contract_Type__c=='Headcount')
                                && BPDRec.Contract_Type__c==apvElt.MP_Contract_Type__c){
                                    apvElt.CSMR__c=BPDRec.CSMR__c*(apvElt.Budgeted_Price__c/100);
                                    apvElt.LE__c=BPDRec.LE__c*(apvElt.Budgeted_Price__c/100);
                                    apvElt.PUB__c=BPDRec.PUB__c*(apvElt.Budgeted_Price__c/100);
                                    apvElt.SMB__c=BPDRec.SMB__c*(apvElt.Budgeted_Price__c/100);
                                    apvElt.recordTypeId=rtMP.Id;
                                }
                            }
                        }
                    }
                } 
            }Catch(Exception e){
            }
        }        
        public List<Volume_Based_Rule_Line_Item__c> getVBRHLLnList(){
            return vbrhLnItemList;
        } 
}