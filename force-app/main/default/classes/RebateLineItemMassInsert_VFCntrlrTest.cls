@isTest
private class RebateLineItemMassInsert_VFCntrlrTest {
    
    public static Rebate_Rule_Header__c Rheader = new Rebate_Rule_Header__c();
    public static List <Rebate_Rule_Line_Item__c> RlineItemlist =  new List <Rebate_Rule_Line_Item__c>();
    public static RecordType vendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Vendor'];
    public static RecordType subvendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Sub Vendor'];
    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static Date fromDate =date.newinstance(2011, 3, 17);
    public static Date toDate =date.newinstance(2011, 3, 28);
    
    public static void createdata(){
        
        // creating a parent vendor
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
        parentVendor.Partner_Status__c='Active';
        parentVendor.recordTypeId=vendorRT.Id;          
        insert parentVendor;
        
        // creating a sub vendor
        subvendor.Parent_Vendor__c=parentVendor.Id;
       //subVendor.Name='TestSubVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
        subvendor.Partner_Status__c='Active';
        subvendor.Partner_Type__c='Value';
        subvendor.Product_Category__c='Networking';
        subvendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
        subvendor.recordTypeId= subvendorRT.Id;       
        insert subvendor;
        
        Rheader.Name = 'testRH';
        Rheader.Fiscal_Quarter__c = 'FY12Q1';
        Rheader.Region__c ='APJ';
        Rheader.Sub_Region__c='APJ';        
        Rheader.Vendor__c = subvendor.Id;
//        Rheader.Rebate_Rule_Name__c = 'testRH';
        Rheader.Status__c='Pending';
        insert Rheader;
    }
    
    static testMethod void testMethod1() {
        createdata();
        
        fromDate=date.newinstance(2011, 2, 17);
        toDate =date.newinstance(2011, 2, 28);    
        
        RecordType lnItemRecordType=[select id,name from RecordType where sObjectType='Rebate_Rule_Line_Item__c' and name='Flat Rate'];
              
        Rebate_Rule_Line_Item__c rrLnItem1=new Rebate_Rule_Line_Item__c();
        
          
        PageReference pr = Page.RebateLineItemMassInsertVFPage;
        ApexPages.currentPage().getParameters().put('id',Rheader.Id);
        Test.setCurrentPage(pr);
        RebateLineItemMassInsert_VFCntrlr cntrlr = new RebateLineItemMassInsert_VFCntrlr(new ApexPages.StandardController(Rheader));   
        
        //pagereference pageRefApp=cntrlr.AutoApproveRR();
        
        List<RebateLineItemMassInsert_VFCntrlr.RRLnItemRec>  wrapperList1=cntrlr.getRebateRuleLineItemList();
        
        //cntrlr.setClassSubClass(wrapperList1);
        
        List<RebateLineItemMassInsert_VFCntrlr.RRLnItemRec> wrapperList2=cntrlr.getRebateRuleLineItemList();
        //cntrlr.setFlatRate(wrapperList2);
        
        List<RebateLineItemMassInsert_VFCntrlr.RRLnItemRec> wrapperList3=cntrlr.getRebateRuleLineItemList();
        //cntrlr.setSKUBased(wrapperList3);
        
        List<RecordType> rectypeList=cntrlr.getRecdtypelist();        
        Rebate_Rule_Line_Item__c rrLnItem=cntrlr.getRRLNRecType();
        
        Boolean bol1=cntrlr.getBolClsSubCls();
        cntrlr.setBolClsSubCls(true);
        Boolean bol2=cntrlr.getBolFlatRate();
        cntrlr.setBolFlatRate(true);
        Boolean bol3=cntrlr.getBolSKUBased();
        cntrlr.setBolSKUBased(true);
        Boolean bol4=cntrlr.getBolRecType();
        cntrlr.setBolRecType(true);
        String recName=cntrlr.getRecordTypeName();
        
        rrLnItem1=new Rebate_Rule_Line_Item__c();
        RebateLineItemMassInsert_VFCntrlr.RRLnItemRec wrapeprClsVar1=new RebateLineItemMassInsert_VFCntrlr.RRLnItemRec(false,false,rrLnItem1);
        
        rrLnItem1.recordTypeId=lnItemRecordType.Id;
        rrLnItem1.Effective_Date_From__c=fromDate;
        rrLnItem1.Effective_Date_To__c=toDate;
        rrLnItem1.Business_Segment__c='LE';
        
        wrapperList1.add(wrapeprClsVar1);
        cntrlr.setRebateRuleLineItemList(wrapperList1);
        cntrlr.setRRLNRecType(rrLnItem1);
        Pagereference pageRef1=cntrlr.selectRecordType();
        Pagereference pageRef1a=cntrlr.AddRow();
        Pagereference pageRef1a1=cntrlr.AddRow();
        Pagereference pageRef1a2=cntrlr.AddRow();
        Pagereference pageRef1b=cntrlr.deleteRow();
        Pagereference pageRef1c=cntrlr.insertRebateRuleLnItems();
        
        rrLnItem1=new Rebate_Rule_Line_Item__c();
        RebateLineItemMassInsert_VFCntrlr.RRLnItemRec wrapeprClsVar2=new RebateLineItemMassInsert_VFCntrlr.RRLnItemRec(false,false,rrLnItem1);
        
        lnItemRecordType=[select id,name from RecordType where 
        sObjectType='Rebate_Rule_Line_Item__c' and name='Class / Sub Class'];              
        rrLnItem1.recordTypeId=lnItemRecordType.Id;        
        fromDate=date.newinstance(2011, 2, 19);
        toDate =date.newinstance(2011, 2, 20);
        rrLnItem1.Effective_Date_From__c=fromDate;
        rrLnItem1.Effective_Date_To__c=toDate;
        rrLnItem1.Business_Segment__c='CSMR';
        
        wrapperList2.add(wrapeprClsVar2);
        cntrlr.setRebateRuleLineItemList(wrapperList2);
        cntrlr.setRRLNRecType(rrLnItem1);
        Pagereference pageRef2=cntrlr.selectRecordType();
        Pagereference pageRef2a=cntrlr.AddRow();
        Pagereference pageRef2a1=cntrlr.AddRow();
        Pagereference pageRef2a2=cntrlr.AddRow();
        Pagereference pageRef2b=cntrlr.deleteRow();
        Pagereference pageRef2c=cntrlr.insertRebateRuleLnItems();
        
        rrLnItem1=new Rebate_Rule_Line_Item__c();
        RebateLineItemMassInsert_VFCntrlr.RRLnItemRec wrapeprClsVar3=new RebateLineItemMassInsert_VFCntrlr.RRLnItemRec(false,false,rrLnItem1);
        
        lnItemRecordType=[select id,name from RecordType where 
        sObjectType='Rebate_Rule_Line_Item__c' and name='SKU Based'];              
                
        rrLnItem1.recordTypeId=lnItemRecordType.Id;        
        fromDate=date.newinstance(2011, 2, 20);
        toDate =date.newinstance(2011, 2, 21);
        rrLnItem1.Effective_Date_From__c=fromDate;
        rrLnItem1.Effective_Date_To__c=toDate;
        rrLnItem1.Business_Segment__c='SMB';
        
        wrapperList3.add(wrapeprClsVar3);
        cntrlr.setRebateRuleLineItemList(wrapperList3);
        cntrlr.setRRLNRecType(rrLnItem1);        
        Pagereference pageRef3=cntrlr.selectRecordType();
        Pagereference pageRef3a=cntrlr.AddRow();
        Pagereference pageRef3a1=cntrlr.AddRow();
        Pagereference pageRef3a2=cntrlr.AddRow();
        Pagereference pageRef3b=cntrlr.deleteRow();
        Pagereference pageRef3c=cntrlr.insertRebateRuleLnItems();        
    }
}