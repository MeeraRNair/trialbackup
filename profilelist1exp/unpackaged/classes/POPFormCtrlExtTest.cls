@isTest
private class POPFormCtrlExtTest {

    static Proof_of_Performance_POP__c POPRcd = new Proof_of_Performance_POP__c();
    static POP_Line_Item__c POPLineRcd = new POP_Line_Item__c();
    //static List<POP_Line_Item__c> POPLineRcd = new List<POP_Line_Item__c>(); 
    static Vendor__c parentVendor=new Vendor__c();    
    static Vendor__c subVendor = new Vendor__c(); 
    
    public static void createData(){
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();
        RecordType mdfRecordRT = [Select Name, Id From RecordType where 
            sObjectType='MDF_Program__c' and name = 'Event' limit 1];
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;
       
       insert parentVendor;

       subVendor.Parent_Vendor__c=parentVendor.Id;
       //subVendor.Name='TestSubVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
       subVendor.Partner_Status__c='Active';
       subVendor.Partner_Type__c='Value';
       subVendor.Product_Category__c='Networking';
       subVendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
       subVendor.recordTypeId=vendorRT.get('Sub Vendor').Id;
       
       insert subVendor;
               
        POPRcd.Name = 'TestPOP';
        //POPRcd.Business_Segment__c = 'Active';
        //POPRcd.Fiscal_Quarter__c = 'Active';
        //POPRcd.MDF_Program__c = mdfRecordRT.Id;
        //POPRcd.MDF_Program__c = '012S00000004Ow2';
       
        insert POPRcd;
       //for(Integer i = 0; i<4; i++){           
       //     POPLineRcd = new POP_Line_Item__c(
       //         Proof_of_Performance_POP__c = POPRcd.id,
       //         Vendor__c = subVendor.Id   
       //    );
        //POPLineRcd.name = 'testPOPLineItem';
        POPLineRcd.Proof_of_Performance_POP__c = POPRcd.id;
        POPLineRcd.Vendor__c = subVendor.Id;
        
        insert POPLineRcd;

    }
    static testMethod void testPOPFormCtrlExt(){
        createdata();
        POPFormCtrlExt con = new POPFormCtrlExt(new ApexPages.StandardController(POPRcd)); 
        con.getPOPRec();
        con.getPOPLineItemList();
        // Mohan 20110606 BRD 8.4.1.3
        con.getApvList();
        // Mohan 20110606 BRD 8.4.1.3
    }
    
    public static testMethod void testVFCntlr_selectSOW(){
        createData();       
        PageReference pageRef = Page.SelectPOPTemplate;
        Test.setCurrentPage(pageRef); 
        SelectPOPTemplateCtrlExt controller = new SelectPOPTemplateCtrlExt(new ApexPages.StandardController(POPRcd));
        PageReference selectedPOP = controller.selectPOPTemplates();           
    }
}