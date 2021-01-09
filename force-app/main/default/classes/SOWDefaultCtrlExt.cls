/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      16169       FY19-0802   13-July-2018    Naga        Deleted duplicated and unused code as part of code clean up
 * 
 */
public class SOWDefaultCtrlExt {

    Vendor__c vendorRecord = new Vendor__c();
    Marketing_Plan__c marketingPlanRec = new Marketing_Plan__c();
    MDF_Contact__c mdfContact = new MDF_Contact__c();
    MDF_Associated_Contact__c mdfAssociatedContact = new MDF_Associated_Contact__c();
    List<Associated_Programs_Vendors__c> apvRecords = new List<Associated_Programs_Vendors__c>();
    Decimal budgetedPrice = 0;
    boolean mdfContactboolean;
    List <Rebate_Rule_Line_Item__c> RRLIList = new List<Rebate_Rule_Line_Item__c> ();
    
    
    public SOWDefaultCtrlExt(ApexPages.StandardController controller) {
        //v1.0 Start
        VFCntlr_DefaultSOW  vfCntlrDefaultSOW = new VFCntlr_DefaultSOW(controller);
        Id marketingPlanId=controller.getId();
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        marketingPlanRec = vfCntlrDefaultSOW.marketingPlanRec;
        vendorRecord = vfCntlrDefaultSOW.vendorRecord;
        mdfAssociatedContact = vfCntlrDefaultSOW.mdfAssociatedContact;
        RecordType mdfContactRT=vfCntlrDefaultSOW.mdfContactRT;
        try {
            mdfContact = vfCntlrDefaultSOW.mdfContact;
        } catch (QueryException e) {
            mdfContact = null;        
        }
        apvRecords = vfCntlrDefaultSOW.apvRecords;
        budgetedPrice =vfCntlrDefaultSOW.budgetedPrice;
        //v1.0 End
        RRLIList=[Select id,Name,RecordType.Name,Amount__c,Dell_SKU__c,Mfg_SKU__c,Class__c,Sub_Class__c,Effective_Date_From__c,Effective_Date_To__c 
                    from Rebate_Rule_Line_Item__c where Rebate_Rule_Header__c = :marketingPlanRec.Rebate_Rule_Header__c];
    }
    public Vendor__c getvendorRecord (){
        return vendorRecord;
    }
    public Marketing_Plan__c getMarketingPlanRec(){
        return marketingPlanRec;
    }
    public MDF_Contact__c getmdfContact(){
        return mdfContact ;
    }
    public List<Associated_Programs_Vendors__c> getapvRecords(){
        return apvRecords;
    }
    public Decimal getBudgetedPrice(){
        return budgetedPrice;
    }
    public boolean getmdfContactboolean(){
        return mdfContactboolean;
    }
    public List<Rebate_Rule_Line_Item__c> getRRLIList(){
        return RRLIList;
    }

}