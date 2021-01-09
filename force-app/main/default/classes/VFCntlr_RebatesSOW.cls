public class VFCntlr_RebatesSOW {

    ID mkpID;
    Integer itemCount;
    Marketing_Plan__c mkprecord;
    
    List <Rebate_Rule_Line_Item__c> RRLI_List_FR=new List<Rebate_Rule_Line_Item__c> ();
    List <Rebate_Rule_Line_Item__c> RRLI_List_SKU=new List<Rebate_Rule_Line_Item__c> ();
    List <Rebate_Rule_Line_Item__c> RRLI_List_Class=new List<Rebate_Rule_Line_Item__c> ();        
    public Map<String,RecordType> RRLI_RT=new Map<String,RecordType>();
    public Boolean FR_business=False;
    public Boolean FR_RT=False;
    public Boolean SKU_RT=False;
    public Boolean Class_RT=False;
    public Boolean lineitem=False;
    Map<Integer,String> monthBynameMap = new Map<Integer,String>{1=> 'January',2=> 'February',3=> 'March',4=>'April',5=> 'May',6=> 'June',7=>'July',8=>'August',9=>'September',10=>'October',11=>'November',12=>'December'};
    Map<String, Fiscal_Years__c> fiscalQuartersMap = Fiscal_Years__c.getAll();
    public String years {get; set;} 
    public Boolean FR_mfg=False;
    public Boolean FR_comments=False;       
    public Boolean FR_flatrate=False;

    public Boolean SKU_business=False;
    public Boolean SKU_amount=False;
    public Boolean SKU_rebate=False;
    public Boolean SKU_sku=False;
    public Boolean SKU_mfg=False;
    public Boolean SKU_maxAmount=False;
    public Boolean SKU_minUnit=False;
    public Boolean SKU_maxUnit=False;
    public Boolean SKU_comments=False;      
    
    public Boolean Class_business=False;
    public Boolean Class_amount=False;
    public Boolean Class_rebate=False;
    public Boolean Class_class=False;
    public Boolean Class_subClass=False;
    public Boolean Class_maxAmount=False;
    public Boolean Class_minUnit=False;
    public Boolean Class_maxUnit=False;
    public Boolean Class_comments=False;  
    
    public String addMarketingStr {get; set;} 
    public List<String> lstOfStr = new List<String>();
    public String addBillingStr {get; set;} 
    public List<String> lstOfBillingStr = new List<String>();      
    
    public VFCntlr_RebatesSOW (ApexPages.StandardController controller) {
    
        this.mkprecord= (Marketing_Plan__c)controller.getRecord();   
        mkpID=mkprecord.id;
        for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='Rebate_Rule_Line_Item__c'])    {           
            RRLI_RT.put(rtElt.Name,rtElt);
        }
        for(Rebate_Rule_Line_Item__c LineItem:[Select id,Name,recordtypeId,Amount__c,Business_Segment__c,Dell_SKU__c,Mfg_SKU__c,Class__c,Sub_Class__c,Effective_Date_From__c,Effective_Date_To__c,Comments__c, 
                                              Flat_Rate__c,Rebate__c,Max_Amount__c,Min_Units__c,Max_Units__c  from Rebate_Rule_Line_Item__c where Rebate_Rule_Header__c=:mkprecord.Rebate_Rule_Header__c]){
        
            if(LineItem.recordtypeId==RRLI_RT.get('Flat Rate').Id){
                FR_RT=True;
                RRLI_List_FR.add(LineItem);
                
                if(LineItem.Business_Segment__c !=Null){
                    FR_business=True;
                }
                if(LineItem.Flat_Rate__c !=Null){
                    FR_flatrate=True;
                }       
                if(LineItem.Mfg_SKU__c !=Null){
                    FR_mfg=True;
                }
          
                if(LineItem.Comments__c !=Null){
                    FR_comments=True;
                }  
                
                
                
            }else if(LineItem.recordtypeId==RRLI_RT.get('SKU Based').Id){
                SKU_RT=True;
                RRLI_List_SKU.add(LineItem);
                
                if(LineItem.Business_Segment__c !=Null){
                    SKU_business=True;
                }
                if(LineItem.Amount__c !=Null){
                    SKU_amount=True;
                }
                if(LineItem.Rebate__c !=Null){
                    SKU_rebate=True;
                }
                if(LineItem.Dell_SKU__c !=Null){
                    SKU_sku=True;
                }   
                if(LineItem.Mfg_SKU__c !=Null){
                    SKU_mfg=True;
                }
                if(LineItem.Max_Amount__c !=Null){
                    SKU_maxAmount=True;
                }   
                if(LineItem.Min_Units__c !=Null){
                    SKU_minUnit=True;
                }   
                if(LineItem.Max_Units__c !=Null){
                    SKU_maxUnit=True;
                }               
                if(LineItem.Comments__c !=Null){
                    SKU_comments=True;
                }                   
            }else {
                Class_RT=True;
                RRLI_List_Class.add(LineItem);
                if(LineItem.Business_Segment__c !=Null){
                    Class_business=True;
                }
                if(LineItem.Amount__c !=Null){
                    Class_amount=True;
                }
                if(LineItem.Rebate__c !=Null){
                    Class_rebate=True;
                }
                if(LineItem.Class__c !=Null){
                    Class_class=True;
                }   
                if(LineItem.Sub_Class__c !=Null){
                    Class_subClass=True;
                }
                if(LineItem.Max_Amount__c !=Null){
                    Class_maxAmount=True;
                }   
                if(LineItem.Min_Units__c !=Null){
                    Class_minUnit=True;
                }   
                if(LineItem.Max_Units__c !=Null){
                    Class_maxUnit=True;
                }
                if(LineItem.Comments__c !=Null){
                    Class_comments=True;
                }               
            }
                       
        }
        if(FR_RT==True || SKU_RT==True || Class_RT==True){
            lineitem=True;
        }
        
         //CR: 7330 - To show City/State/Zip/Country in a single row for Marketing Contact Section
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        
        mkprecord= database.query(ViperSOQLMethod.getQueryMethod1(new Marketing_Plan__c(),'VFCntlr_RebatesSOW') + ' where id=:mkpID and Contract_Type__c=\'Rebates\'');
       
        
        IF(mkprecord.Fiscal_Quarter__c != Null && !fiscalQuartersMap.isEmpty()){
             String startingYear;
             String endingYear;
             if(integer.valueof(mkprecord.Fiscal_Quarter__c.substring(2,4)) >= 16){
                 Date startdate = fiscalQuartersMap.get(mkprecord.Fiscal_Quarter__c).Start_Date__c;
                 startingYear = monthBynameMap.get(startdate.month())+' '+ startdate.day()+', '+startdate.year();
                 Date enddate = fiscalQuartersMap.get(mkprecord.Fiscal_Quarter__c).End_Date__c;
                 endingYear = monthBynameMap.get(enddate.month())+' '+ enddate.day()+', ' +enddate.year();
             }
             if(startingYear != null && endingYear != null){
                 years = ' ('+startingYear+' - '+endingYear+')';                            
             }
        }  
        
        String str;
        if(mkprecord.Primary_Marketing_Contact_City__c != null){
            str = mkprecord.Primary_Marketing_Contact_City__c;
            lstOfStr.add(str);
        }
        if(mkprecord.Primary_Marketing_Contact_State__c != null){
            str = mkprecord.Primary_Marketing_Contact_State__c;
            lstOfStr.add(str);
        }
        if(mkprecord.Primary_Marketing_Contact_Zip__c != null){
            str = mkprecord.Primary_Marketing_Contact_Zip__c;
            lstOfStr.add(str);
        }
        if(mkprecord.Primary_Marketing_Contact_Country__c != null){
            str = mkprecord.Primary_Marketing_Contact_Country__c;
            lstOfStr.add(str);
        }
        for(Integer i=0; i<lstOfStr.size(); i++){
            If(addMarketingStr == null){
                addMarketingStr = lstOfStr[i];
            }
            else{
                addMarketingStr = addMarketingStr  + ','+ ' ' + lstOfStr[i];
            }
        }
        //CR: 7330 - To show City/State/Zip/Country in a single row for Billing Contact Section
        if(mkprecord.Billing_City__c != null){
            str = mkprecord.Billing_City__c;
            lstOfBillingStr.add(str);
        }
        if(mkprecord.Billing_State__c != null){
            str = mkprecord.Billing_State__c;
            lstOfBillingStr.add(str);
        }
        if(mkprecord.Billing_Zip__c != null){
            str = mkprecord.Billing_Zip__c;
            lstOfBillingStr.add(str);
        }
        if(mkprecord.Billing_Contact_Country__c != null){
            str = mkprecord.Billing_Contact_Country__c;
            lstOfBillingStr.add(str);
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
    
    public List <Rebate_Rule_Line_Item__c> getRRLI_List_FR(){
        return RRLI_List_FR;
    }
    public List <Rebate_Rule_Line_Item__c> getRRLI_List_SKU(){
        return RRLI_List_SKU;
    }
    public List <Rebate_Rule_Line_Item__c> getRRLI_List_Class(){
        return RRLI_List_Class;
    }            

    public boolean getFR_business(){
        return FR_business; 
    }
    public boolean getFR_RT(){
        return FR_RT; 
    }
    public boolean getSKU_RT(){
        return SKU_RT; 
    }
    public boolean getClass_RT(){
        return Class_RT; 
    }
    public boolean getlineitem(){
        return lineitem; 
    }

    public boolean getFR_flatrate(){
        return FR_flatrate; 
    }   
    public boolean getFR_mfg(){
        return FR_mfg; 
    }
    public boolean getFR_comments(){
        return FR_comments; 
    }   
    
   
    public boolean getSKU_business(){
        return SKU_business; 
    }
    public boolean getSKU_amount(){
        return SKU_amount; 
    }
    public boolean getSKU_rebate(){
        return SKU_rebate; 
    }
    public boolean getSKU_sku(){
        return SKU_sku; 
    }   
    public boolean getSKU_mfg(){
        return SKU_mfg; 
    }
    public boolean getSKU_maxAmount(){
        return SKU_maxAmount; 
    }   
    public boolean getSKU_minUnit(){
        return SKU_minUnit; 
    }
    public boolean getSKU_maxUnit(){
        return SKU_maxUnit; 
    }   
    public boolean getSKU_comments(){
        return SKU_comments; 
    }  
     
    public boolean getClass_business(){
        return Class_business; 
    }
    public boolean getClass_amount(){
        return Class_amount; 
    }
    public boolean getClass_rebate(){
        return Class_rebate; 
    }
    public boolean getClass_class(){
        return Class_class; 
    }   
    public boolean getClass_subClass(){
        return Class_subClass; 
    }
    public boolean getClass_maxAmount(){
        return Class_maxAmount; 
    }   
    public boolean getClass_minUnit(){
        return Class_minUnit; 
    }
    public boolean getClass_maxUnit(){
        return Class_maxUnit; 
    }   
    public boolean getClass_comments(){
        return Class_comments; 
    }       
              
}