/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      16169       FY19-0802   13-July-2018    Naga        Deleted duplicated and unused code as part of code clean up
 * 
 */
public class VFCntlr_DefaultSOW {
    //v1.0 Start
    public Id subVendorId;
    public Vendor__c vendorRecord = new Vendor__c();
    public Marketing_Plan__c marketingPlanRec = new Marketing_Plan__c();
    public MDF_Contact__c mdfContact = new MDF_Contact__c();
    public MDF_Associated_Contact__c mdfAssociatedContact = new MDF_Associated_Contact__c();
    public List<Associated_Programs_Vendors__c> apvRecords = new List<Associated_Programs_Vendors__c>();
    public RecordType mdfContactRT = new RecordType();
    public Decimal budgetedPrice = 0;
   //v1.0 End 
    public VFCntlr_DefaultSOW(ApexPages.StandardController controller) {
        
        Id marketingPlanId=controller.getId();
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        
       marketingPlanRec= database.query(ViperSOQLMethod.getQueryMethod1(new Marketing_Plan__c(),'VFCntlr_DefaultSOW') + ' where id=:marketingPlanId');
        
        subVendorId=marketingPlanRec.Vendor__c;
        
        vendorRecord = [select Id,Name,Schedule__c,Terms_Conditions_reference_language__c,Dell_Entity__c
                                    from Vendor__c
                                    where Id =: subVendorId];

        mdfAssociatedContact = [select Id,Name,MDF_Contact__c 
                                from MDF_Associated_Contact__c
                                where   Vendor__c =: vendorRecord.Id limit 1];
                                
        mdfContactRT=[Select Name, Id From RecordType where 
           sObjectType='MDF_Contact__c' and name='Product Manager Contact' limit 1];
        
        mdfContact = [select Id, Name, Status__c, Region__c, recordTypeId, Primary_Secondary__c,Email__c, Phone__c
                        from MDF_Contact__c where recordTypeId =: mdfContactRT.Id and Primary_Secondary__c = 'Primary'
                        and id=:mdfAssociatedContact.MDF_Contact__c limit 1];
                        
        apvRecords = [select Id,Name,Budgeted_Price__c,Marketing_Plan__c
                        from Associated_Programs_Vendors__c
                        where Marketing_Plan__c =: marketingPlanId];

        for(Associated_Programs_Vendors__c iterateAPV : apvRecords){
            if(iterateAPV.Budgeted_Price__c != null){
                budgetedPrice = budgetedPrice + iterateAPV.Budgeted_Price__c;
            }
        }
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
   
}