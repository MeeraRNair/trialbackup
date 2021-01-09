public class RebateLineItemMassInsert_VFCntrlr{
    Id RRHID;
    public Rebate_Rule_Line_Item__c LineItem;
    public Rebate_Rule_Line_Item__c rebateRuleLnItemObj=new Rebate_Rule_Line_Item__c();   
    public Map<Id,RecordType> LineItemRT=new Map<Id,RecordType>();
    public Id RectypeId;
    public Rebate_Rule_Line_Item__c lnItemRecType=new Rebate_Rule_Line_Item__c();
    public List<RecordType> Recdtypelst=new List <RecordType> ();    
    public Integer rowCount=0;
    public boolean IncRow=False;
    public boolean messageBlk=False;
    
    public List<RRLnItemRec> classOrSubClassList=new List<RRLnItemRec>();
    public List<RRLnItemRec> flatRateList=new List<RRLnItemRec>();
    public List<RRLnItemRec> skuBasedList=new List<RRLnItemRec>();
    
    public List<RRLnItemRec> rebateRuleLineItemList=new List<RRLnItemRec>();
    
   public boolean ClassOrSubClass=False;
   public boolean FlatRate=False;
   public boolean SKUBased=False;
   public boolean recTypebol=False;
   
   public string str_recordType;
   
   public class RRLnItemRec{
       public Boolean add{get; set;}
       public Boolean subtract{get; set;}
       public Rebate_Rule_Line_Item__c rrlnElt{get; set;}
       
       public RRLnItemRec(Boolean Bol1,Boolean Bol2,Rebate_Rule_Line_Item__c rrli){
           this.add=Bol1;
           this.subtract=Bol2;
           this.rrlnElt=rrli;
       } 
   }
    
    public RebateLineItemMassInsert_VFCntrlr(ApexPages.StandardController controller) {         
        Rebate_Rule_Header__c  rrh=(Rebate_Rule_Header__c)controller.getRecord();   
        RRHID=rrh.Id;
        for(RecordType rtElt:[Select Name,Id,description From RecordType where sObjectType='Rebate_Rule_Line_Item__c']){           
            LineItemRT.put(rtElt.Id,rtElt);
            Recdtypelst.add(rtElt);
        }
        LineItem=new Rebate_Rule_Line_Item__c();
        recTypebol=true;
    }
  
    
    public List<RecordType> getRecdtypelist() {
        return Recdtypelst;
    }
    public Rebate_Rule_Line_Item__c getRRLNRecType(){
        return lnItemRecType;
    }
    
    public void setRRLNRecType(Rebate_Rule_Line_Item__c recType){
        this.lnItemRecType=recType;
    }
    
    public List<RRLnItemRec> getRebateRuleLineItemList(){
        return rebateRuleLineItemList;
    }
          
    public void setRebateRuleLineItemList(List<RRLnItemRec> LineItem){
        this.rebateRuleLineItemList=LineItem;
    }
    
    /**********Boolean******************/
    
    
    public Boolean getBolClsSubCls(){
        return ClassOrSubClass;
    }
    
    public void setBolClsSubCls(Boolean bol){
        this.ClassOrSubClass=bol;
    }
    
    public Boolean getBolFlatRate(){
        return FlatRate;
    }
    
    public void setBolFlatRate(Boolean bol){
        this.FlatRate=bol;
    }
    
    public Boolean getBolSKUBased(){
        return SKUBased;
    }
    
    public void setBolSKUBased(Boolean bol){
        this.SKUBased=bol;
    }
    
    public Boolean getBolRecType(){
        return recTypebol;
    }
    
    public void setBolRecType(Boolean bol){
        this.recTypebol=bol;
    }
    
    public Boolean getMessgaeBlock(){
        return messageBlk;
    }
    
    
    /***************************action functions*******************/
    public String getRecordTypeName(){
        return str_recordType;
    }
    
    public Pagereference selectRecordType(){
        rebateRuleLnItemObj=new Rebate_Rule_Line_Item__c();
        rebateRuleLnItemObj.recordtypeId=lnItemRecType.recordtypeId;
        RRLnItemRec wrapeprClsVar=new RRLnItemRec(false,false,rebateRuleLnItemObj);
          
        str_recordType=LineItemRT.get(lnItemRecType.recordtypeId).name;              
        if(str_recordType=='Class / Sub Class'){                    
            ClassOrSubClass=true;
        } 
        if(str_recordType=='Flat Rate'){
            FlatRate=true;            
        } 
        if(str_recordType=='SKU Based'){
            SKUBased=true;            
        }
        rebateRuleLineItemList.add(wrapeprClsVar);
        recTypebol=false;
        messageBlk=true;             
        return null;     
    }
    
    public Pagereference AddRow(){
        rebateRuleLnItemObj=new Rebate_Rule_Line_Item__c();
        rebateRuleLnItemObj.recordtypeId=lnItemRecType.recordtypeId;
        RRLnItemRec wrapeprClsVar=new RRLnItemRec(false,false,rebateRuleLnItemObj); 
        rebateRuleLineItemList.add(wrapeprClsVar);
        return null;     
    }
    
    public Pagereference deleteRow(){
        Integer i=rebateRuleLineItemList.Size();        
        rebateRuleLineItemList.remove(i-1);
        return null;     
    }
    
    public Pagereference insertRebateRuleLnItems(){
        Pagereference pageRef=new Pagereference('/'+RRHID);
        Rebate_Rule_Line_Item__c rrln; 
        List<Rebate_Rule_Line_Item__c> rrliList=new List<Rebate_Rule_Line_Item__c>();
        
        for(Integer i=0;i<rebateRuleLineItemList.size();i++){
                rrln=new Rebate_Rule_Line_Item__c();
                rrln=rebateRuleLineItemList[i].rrlnElt;
                 if(rrln.Effective_Date_From__c==null || rrln.Effective_Date_To__c==null || rrln.Business_Segment__c==null){                 
                      ApexPages.Message msg;     
                      msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, you need to enter a value for  the following fields: Effective_Date_From and Effective_Date_To and Business_Segment.');
                      ApexPages.addMessage(msg);
                      return null;
                  }else if(rrln.Rebate__c!=null && rrln.Amount__c!=null &&(rrln.recordtypeId=='012A0000000VhN6' || rrln.recordtypeId=='012A0000000VhN8')){                 
                      ApexPages.Message msg;     
                      msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, Enter either Rebate % or Amount only.');
                      ApexPages.addMessage(msg);
                      return null;
                  }else if(rrln.Effective_Date_From__c!=null && rrln.Effective_Date_To__c!=null && rrln.Business_Segment__c!=null){
                    rrln.Rebate_Rule_Header__c=RRHID;
                    rrln.recordtypeId=lnItemRecType.recordtypeId;
                    rrliList.add(rrln);    
                }     
         }  
            
 
        if(rrliList.size()>0){
            try{
                insert rrliList;
           }Catch(Exception e){
                  
                 return null;
           }
                 
        }
        
        return pageRef; 
    }
}