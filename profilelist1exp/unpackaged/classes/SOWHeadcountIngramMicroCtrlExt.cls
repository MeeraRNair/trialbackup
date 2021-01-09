public class SOWHeadcountIngramMicroCtrlExt {

    Associated_Programs_Vendors__c apvProgramRcd;
    Marketing_Plan__c marketingPlanRec;
    String fiscalQuater;
    Decimal programPrice = 0;
    
    public SOWHeadcountIngramMicroCtrlExt(ApexPages.StandardController controller) {

        Id marketingPlanId=controller.getId();
        Id subVendorId;
        Integer idx=0;
        String hCFQ1;
        String hCFQ2;
        String hCFQ3;
        String hCFQ4;
        
        marketingPlanRec = [select id,Contract_Status__c,Contract_Type__c,Fiscal_Quarter__c,
        Invoice__c,Invoice_Amount__c,Purchase_Order__c,Rebate_Rule_Header__c,Region__c,
        Term__c,Vendor__c,Vendor__r.name,Volume_Based_Rule_Header__c,Vendor__r.Budgeted_Discount__c,
        Vendor__r.Program_Detail_Only_for_Headcount__c,
        Sub_Region__c,OwnerId from Marketing_Plan__c where id=:marketingPlanId];        
        
        subVendorId=marketingPlanRec.Vendor__c;
        
        try{
            apvProgramRcd = [select id,name,vendor__c,Status__c,Budgeted_Price__c,Program_Notes__c,
                             MDF_Program__r.Business_Segment__c,MDF_Program__r.name from Associated_Programs_Vendors__c 
                                where vendor__c =: subVendorId and Marketing_Plan__c =: marketingPlanRec.Id and status__c='Accepted'];
        }catch(queryexception e){apvProgramRcd = null;}

        Schema.DescribeFieldResult F = Marketing_Plan__c.Fiscal_Quarter__c.getDescribe();
        List<Schema.PicklistEntry> pLE = F.getPicklistValues();
        
        for(integer i=0;i<pLE.size();i++){
            if(marketingPlanRec.Fiscal_Quarter__c == pLE[i].getLabel()){   
                idx=i;
                break;
            }                   
        } 
        if(marketingPlanRec.Term__c=='1' && idx<(pLE.size())){
            hCFQ1=pLE[idx].getLabel();
            if(apvProgramRcd == NULL){programPrice = NULL;}else{programPrice = 1 * apvProgramRcd.Budgeted_Price__c;}
            fiscalQuater = hCFQ1;
        } 
        if(marketingPlanRec.Term__c=='2' && idx<(pLE.size()-1)){
            hCFQ1=pLE[idx].getLabel();
            hCFQ2=pLE[idx+1].getLabel();
            if(apvProgramRcd == NULL){programPrice = NULL;}else{programPrice = 2 * apvProgramRcd.Budgeted_Price__c;}
            fiscalQuater = hCFQ1+'-'+hCFQ2;
        } 
        if(marketingPlanRec.Term__c=='3' && idx<(pLE.size()-2)){
            hCFQ1=pLE[idx].getLabel();
            hCFQ2=pLE[idx+1].getLabel();
            hCFQ3=pLE[idx+2].getLabel();
            if(apvProgramRcd == NULL){programPrice = NULL;}else{programPrice = 3 * apvProgramRcd.Budgeted_Price__c;}
            fiscalQuater = hCFQ1+'-'+hCFQ3;
        }
        if(marketingPlanRec.Term__c=='4' && idx<(pLE.size()-3)){
            hCFQ1=pLE[idx].getLabel();
            hCFQ2=pLE[idx+1].getLabel();
            hCFQ3=pLE[idx+2].getLabel();
            hCFQ4=pLE[idx+3].getLabel();
            if(apvProgramRcd == NULL){programPrice = NULL;}else{programPrice = 4 * apvProgramRcd.Budgeted_Price__c;}
            fiscalQuater = hCFQ1+'-'+hCFQ4;
        }
    }

    public Associated_Programs_Vendors__c getapvProgramRcd(){
        return apvProgramRcd;
    }
    public Marketing_Plan__c getmarketingPlanRec(){
        return marketingPlanRec;
    }
    public String getfiscalQuater(){
        return fiscalQuater;
    }
    public Decimal getprogramPrice(){
        return programPrice;
    }
}