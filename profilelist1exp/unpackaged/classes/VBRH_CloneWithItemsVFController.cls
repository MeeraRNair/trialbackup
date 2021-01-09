public class VBRH_CloneWithItemsVFController{ 
    public Volume_Based_Rule_Header__c new_VBH;
    public Volume_Based_Rule_Header__c clone_VBH;
    public Volume_Based_Rule_Header__c cloned_VBH;
    
    public List <Volume_Based_Rule_Line_Item__c> clone_VBRLI_list= new List<Volume_Based_Rule_Line_Item__c>();
    public List <Volume_Based_Rule_Line_Item__c> new_VBRLI_List= new List<Volume_Based_Rule_Line_Item__c>();
    public Volume_Based_Rule_Line_Item__c cloned_VBR_lineItem ;
    
    Vendor__c Vendor =new Vendor__c();  
    
    public ID currid;
    public ID clonedVBHId;
    
    public Boolean displayerr=False;
    public Boolean fiscalyrerr=False;
    public Boolean newfiscalyr=True;
    public Boolean duprecordexist=False;    
    
    public VBRH_CloneWithItemsVFController(ApexPages.StandardController controller){
        //currid= ApexPages.currentPage().getParameters().get('id');
        currid=controller.getId();
        new_VBH = new Volume_Based_Rule_Header__c();
    
        clone_VBH=[select Name,Vendor__c,Fiscal_Quarter__c,Region__c,Sub_Region__c,Country__c,Status__c,COGS__c,
                     Flat_Rate_Deduction__c,Deduction_Reason__c from Volume_Based_Rule_Header__c where id=:currid];
                     
        clone_VBRLI_list=[select Name,Volume_Based_Rule_Header__c,Include_Exclude__c,Manufacturer__c,Additional_Notes__c,Dell_SKU__c,
                        Class_SubClass__c,Category__c,Business_Segment__c,Accrual__c,Amount_Per_Unit__c from Volume_Based_Rule_Line_Item__c
                        where Volume_Based_Rule_Header__c=:currid]; 
     
                       
    }
    
    
    public Volume_Based_Rule_Header__c getnew_VBH (){
        return new_VBH;
    }
    
    public void setnew_VBH (Volume_Based_Rule_Header__c toclone){
        new_VBH = toclone;
    }
    
    public Boolean getdisplayerr(){
        return displayerr;
    }
    
    public Boolean getnewfiscalyr(){
        return newfiscalyr;
    }
    public Boolean getfiscalyrerr(){
        return fiscalyrerr;
    }

    public Boolean getduprecordexist(){
    return duprecordexist;
    }    
    
    
    Public pagereference VBRCloneWithItems() {
         PageReference currpage;
         Savepoint sp = Database.setSavepoint();
     
         if (new_VBH.Fiscal_Quarter__c== clone_VBH.Fiscal_Quarter__c){
             fiscalyrerr=True;
             newfiscalyr=True;
             if (duprecordexist==True){
                 duprecordexist=False;
             }             
//             currpage = new PageReference('/apex/VolumeBasedRuleClonePage');
             return null;
         }    

    //Check for duplicate record with same name, sub-vendor, region and fiscal qtr 
        List <Volume_Based_Rule_Header__c> dupVBHList=new List<Volume_Based_Rule_Header__c>();
        dupVBHList=[select Name,Fiscal_Quarter__c,Vendor__c,Region__c,Sub_Region__c,Country__c from Volume_Based_Rule_Header__c where Fiscal_Quarter__c=:new_VBH.Fiscal_Quarter__c 
                   AND Vendor__c=:clone_VBH.Vendor__c AND Region__c=:clone_VBH.Region__c AND Sub_Region__c=:clone_VBH.Sub_Region__c AND Country__c=:clone_VBH.Country__c ];          
        if( dupVBHList.size()>0){
            duprecordexist=True;
            system.debug('Duplicate record'+dupVBHList);
            if (fiscalyrerr==True){
                fiscalyrerr=False;
            }
            return null;    
        }   
                     
        //Clone VBH rule   
                     
         clone_VBH.Fiscal_Quarter__c=new_VBH.Fiscal_Quarter__c;
//         clone_VBH.Name=new_VBH.Name;
         clone_VBH.Status__c='Pending';
         cloned_VBH=clone_VBH.clone(false);
         insert cloned_VBH;
         clonedVBHId=cloned_VBH.id;
         
        //Clone VBR line item
        try{                
            for(Volume_Based_Rule_Line_Item__c VBRLI:clone_VBRLI_list) {
               cloned_VBR_lineItem=new Volume_Based_Rule_Line_Item__c();      
               cloned_VBR_lineItem=VBRLI.clone(false); 
               cloned_VBR_lineItem.Volume_Based_Rule_Header__c=clonedVBHId;
               new_VBRLI_List.add(cloned_VBR_lineItem);
            }   
            insert new_VBRLI_List;  
        } catch (DmlException e){
            Database.rollback(sp);
            ApexPages.addMessages(e);
            if((e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')) && (e.getMessage().contains('Vendor__c'))) {
                displayerr=True;
                fiscalyrerr=False;
                system.debug('## Vendor not Active ##');
//                currpage = new PageReference('/apex/VolumeBasedRuleClonePage');
                return null;
            }  
        }
         currpage =new PageReference('/'+ clonedVBHId);             
         return currpage;
    }

}