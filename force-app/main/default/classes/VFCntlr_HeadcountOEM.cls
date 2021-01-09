/**********************************************************************************************
History:
Version Date           Modified By     Description
--------------------------------------------------------------------------------------
1.0     03-Apr-2012    Krishnamoorthi  CR7039: For R13.4 Maintenance Project - Headcount OEM Template Modification 
************************************************************************************************/

public class VFCntlr_HeadcountOEM{
    
//    List<Associated_Programs_Vendors__c> APVList=new List<Associated_Programs_Vendors__c>();
    MDF_Contact__c mdfContact = new MDF_Contact__c();
    MDF_Associated_Contact__c mdfAssociatedContact = new MDF_Associated_Contact__c();
    List<Associated_Programs_Vendors__c> APVList=new List<Associated_Programs_Vendors__c>();  
    Marketing_Plan__c marketingPlanRec;    
    Set<String> mdfAssociatedContactset = new Set<String>();  
//    String programName;
//    String businessSeg;
   
    ID currid;
    Decimal budgetprice=0.00;
    Decimal budgetpricesum=0.00;
    Decimal quaterlybudgetprice=0.00;
    Decimal HCTerm;
//    Integer budgetprice=0;
    String programdetail = Null;
    
    public VFCntlr_HeadcountOEM (ApexPages.StandardController controller) {
        currid=controller.getId();
        
        marketingPlanRec=[select Name,Vendor__c,Term__c from Marketing_Plan__c where id=:currid];
       
        if(marketingPlanRec.Term__c ==Null){
            HCTerm=1.00;
        } 
        system.debug('##Term'+marketingPlanRec.Term__c);
        if(marketingPlanRec.Term__c !=Null){
            HCTerm=Decimal.valueof(marketingPlanRec.Term__c);
        }    
    //Get MDF Contact    
        for(MDF_Associated_Contact__c mdfAsCntct:[select MDF_Contact__c 
                        from MDF_Associated_Contact__c
                        where   Vendor__c =:marketingPlanRec.Vendor__c]){
            mdfAssociatedContactset.add(mdfAsCntct.MDF_Contact__c);
        }
        
                           
        RecordType mdfContactRT=[Select Name,Id From RecordType where 
        sObjectType='MDF_Contact__c' and name='Product Manager Contact' limit 1];
        
        try {
            mdfContact = [select Id, Name, Status__c, Region__c, recordTypeId, Primary_Secondary__c, Email__c, Phone__c
                    from MDF_Contact__c where recordTypeId =: mdfContactRT.Id and Primary_Secondary__c = 'Primary'
                    and id in:mdfAssociatedContactset limit 1];
            } catch (QueryException e) {
              System.debug('No Associated MDF Contact');         
        } 
        
    //Get APV List to calculate Program cost
         //Rev 1.0 change -- Start
         //for(Associated_Programs_Vendors__c apvListElt:[select id,name,vendor__c,Budgeted_Price__c,MDF_Program__r.name,MDF_Program__r.Business_Segment__c,MDF_Program__r.recordType.name,Program_Notes__c
            //                                           from Associated_Programs_Vendors__c where vendor__c=:marketingPlanRec.vendor__c AND Marketing_Plan__c=:marketingPlanRec.Id and status__c='Accepted']){                    
            
            for(Associated_Programs_Vendors__c apvListElt:[select id,name,vendor__c,Budgeted_Price__c,MDF_Program__r.name,MDF_Program__r.Business_Segment__c,MDF_Program__r.recordType.name,Program_Notes__c,MDF_Program__r.Program_Type__c,MDF_Program__r.Detailed_Job_Description__c,
            											Business_Segment__c,MDF_Program__r.Fiscal_Quarter__c,MDF_Program__r.POP_Details__c,Region__c,Sub_Region__c
                                                       from Associated_Programs_Vendors__c where vendor__c=:marketingPlanRec.vendor__c AND Marketing_Plan__c=:marketingPlanRec.Id and status__c='Accepted']){
            
            programdetail = '';
            if(apvListElt.MDF_Program__r.Program_Type__c == 'Headcount') {
               programdetail = apvListElt.MDF_Program__r.Detailed_Job_Description__c;
            }
            //Rev 1.0 change -- End
            
            if(apvListElt.Budgeted_Price__c > 0){
                budgetpricesum=budgetpricesum+apvListElt.Budgeted_Price__c;
            }  
            APVList.add(apvListElt);   
//            businessSeg=apvListElt.MDF_Program__r.Business_Segment__c;
//            programName=apvListElt.MDF_Program__r.name;
                      
        }
        
        if(marketingPlanRec.Term__c !=Null){   
             budgetprice=budgetpricesum*HCTerm;
             quaterlybudgetprice=budgetpricesum/HCTerm; 
        }     
 
    }

    public MDF_Contact__c getmdfContact(){
        return mdfContact ;
    } 
    
    public Decimal getbudgetprice(){
        return budgetprice;
    }   
    public Decimal getbudgetpricesum(){
        return budgetpricesum;
    }    
    
    public Decimal getquaterlybudgetprice(){
        return quaterlybudgetprice;
    } 
        
    public List<Associated_Programs_Vendors__c> getAPVList(){
        return APVList;
    }     
    
    public String getprogramdetail(){
        return programdetail;
    } 

/*    public String getprogramName(){
        return programName;
    }         
    public String getbusinessSeg(){
        return businessSeg;
    }
*/    
}