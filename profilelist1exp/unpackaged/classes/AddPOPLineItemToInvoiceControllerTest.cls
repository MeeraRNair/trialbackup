@isTest
private class AddPOPLineItemToInvoiceControllerTest{
    static  MDF_Program__c mdfProgram=new MDF_Program__c();
    static Vendor__c parentVendor=new Vendor__c();
    static Vendor__c subVendor=new Vendor__c();     
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c();     
    static List<User> users = new List<User>();    
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();    
   
    static List<Vendor__c> vendorList=new List<Vendor__c>();     
    static Marketing_Plan__c marketingPlan=new Marketing_Plan__c();     
    static Invoice__c invoiceObj=new Invoice__c();     
    static Profile profiles;    
    static List<MDF_Program__c> mdfList=new List<MDF_Program__c>();    
    static  List<AddPOPLineItemTOInvoiceController.Partner> partnerList=new List<AddPOPLineItemToInvoiceController.Partner>();     
    static Marketing_Plan__c MarketingPlanRec=new Marketing_Plan__c();

    static MDF_Contact__c mdfContact=new  MDF_Contact__c();
    static MDF_Associated_Contact__c mdfAssoCntct=new  MDF_Associated_Contact__c();
    static MDF_Contact__c pdtMgrContact=new  MDF_Contact__c();
    static MDF_Associated_Contact__c mdfPdtAssoCntct=new  MDF_Associated_Contact__c();
    static String userName='';
    
    
    public static void createData(){ 
              
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();       
       RecordType marketingPlanRT=[Select Name, Id From RecordType where sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       RecordType partnerCntctRT=[Select Name, Id From RecordType where sObjectType='MDF_Contact__c'  and name='Partner Contact' limit 1];

       
       RecordType apvRT=[Select Name, Id From RecordType where  sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];
       
       profiles=[select id,name from Profile where name like  'MDF Program Owners' limit 1];
       
       RecordType pdctMgrContact=[Select Name, Id From RecordType where sObjectType='MDF_Contact__c'   and name='Product Manager Contact' limit 1];
        
               
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0)); // Fenny added on 21-Feb-2013
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;       
       insert parentVendor;
       
        string subVendorName = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0)); // Fenny added on 21-Feb-2013
       for(Integer i = 0; i<3; i++){
           vendorList.add(
               new Vendor__c(
                   Parent_Vendor__c=parentVendor.Id,
                   //Name='TestSubVendor'+i, // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
                   Name=subVendorName+i, // Fenny added on 21-Feb-2013
                   Partner_Status__c='Active',
                   Partner_Type__c='Value',
                   Product_Category__c='Networking',
                   Contract_Types_eligible_for__c='Volume Based,Ala Carte,Rebates',
                   recordTypeId=vendorRT.get('Sub Vendor').Id
               )
           );
       }
       
       insert vendorList;
       
       

               
        for(Integer i = 0; i<3; i++){           
            users.add(
                new User(
                    Username='testuser'+userName+i+'@dell.com',
                    Alias = 'test'+i, 
                    Email='testuser'+i+'@dell.com', 
                    FirstName='John', 
                    LastName='Doe'+i, 
                    ProfileId =profiles.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='John.doe'+i
               )
            );
        }
        insert users;
        
     invoiceObj.name='Inv-001';
        invoiceObj.Vendor__c=vendorList[0].Id;
        invoiceObj.Fiscal_Quarter__c='FY12Q1';
        invoiceObj.Region__c='Americas';
        invoiceObj.Contract_Type__c='Volume Based, Ala Carte, Headcount';        
        insert invoiceObj;
         
        mdfProgram.Name='testMDF Program';
        mdfProgram.Program_Owner__c=users[0].id;
        mdfProgram.POP_Owner__c=users[1].id;
        mdfProgram.Program_Status__c='Approved';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q1';
        mdfProgram.OwnerId=users[0].id;
        mdfProgram.Rate_Card_Price__c=12356;
        mdfProgram.Region__c='Americas';
        mdfProgram.Sub_region__c='LE';
        mdfProgram.country__c='LE';
        mdfProgram.Business_Segment__c='LE';
        insert mdfProgram;
        
        
        MarketingPlanRec.name='MP-001';
        MarketingPlanRec.Vendor__c=vendorList[0].Id;
        MarketingPlanRec.Fiscal_Quarter__c='FY12Q2';
        MarketingPlanRec.Region__c='APJ';
        MarketingPlanRec.Contract_Type__c='Volume Based';
        MarketingPlanRec.RecordTypeId=marketingPlanRT.Id;
        MarketingPlanRec.invoice__c=invoiceObj.Id;
        MarketingPlanRec.Contract_Status__c='Signed';
        insert MarketingPlanRec;
        
        
        
                   
        for(Integer i = 0; i<3; i++){        
           apvList.add(
               new Associated_Programs_Vendors__c(
                   MDF_Program__c=mdfProgram.Id,
                   Vendor__c=vendorList[i].Id,
                   Marketing_Plan__c=MarketingPlanRec.Id,
                   
                   Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
                   Budgeted_Price__c=mdfProgram.Rate_Card_Price__c,
                   Invoice_Amount__c=98980,
                    Status__c='Signed',
                    POP_Status__C='Executed'
                 )
              );
       }              
       insert apvList;        
        

        
        mdfContact.Name='Test cntct';
        mdfContact.Title__c='Test cntct title';
        mdfContact.status__c='Active';
        mdfContact.partner_Contact_type__c='Active';
        mdfContact.email__c='test1@dell.com';
        mdfContact.recordTypeId=partnerCntctRT.Id;        
        insert mdfContact; 
        
        mdfAssoCntct.vendor__c=vendorList[0].Id;
        mdfAssoCntct.MDF_Contact__c=mdfContact.Id;
        insert mdfAssoCntct;        
        AddPOPLineItemTOInvoiceController.Partner wrapperObj=new AddPOPLineItemTOInvoiceController.Partner(true,mdfAssoCntct);
        //wrapperObj=new AddPOPLineItemTOInvoiceController.Partner(true,mdfAssoCntct);
        partnerList.add(wrapperObj);            


          
      }
      
      

    
   public static testMethod void testCOnstructor(){ 
        userName='testCOnstructor';
       createData();       
       Proof_of_Performance_POP__c popHeader=new Proof_of_Performance_POP__c();
       popHeader.mdf_Program__c=mdfProgram.Id;
       popHeader.name='Test POP';        
       insert popHeader;        
       POP_Line_Item__c popLnItem=new POP_Line_Item__c();
       popLnItem.Proof_of_Performance_POP__c=popHeader.Id;
       popLnItem.Vendor__c=vendorList[0].Id;
       popLnItem.POP_Submission_Status__c='Approved';       
       insert popLnItem; 
       PageReference pr=new PageReference('/apex/AddPOPLineItemToInvoice?Id='+invoiceObj.id);
       Test.setCurrentPage(pr);       
       AddPOPLineItemToInvoiceController controller = new AddPOPLineItemToInvoiceController(new ApexPages.StandardController(invoiceObj)); 
       controller.AddPOPLineItemToInvoice();
       controller.getPopLineItemList();
       controller.getMessage();    
       controller.getPOPMessage(); 
       controller.getPartner();
       controller.setPartner(partnerList);
       controller.getEmailTxt();
       controller.setEmailTxt('test@dell.com');
       
   }
   
       
   public static testMethod void testActionMethods(){ 
        userName='testActionCall';
       createData();       
       Proof_of_Performance_POP__c popHeader=new Proof_of_Performance_POP__c();
       popHeader.mdf_Program__c=mdfProgram.Id;
       popHeader.name='Test POP';        
       insert popHeader;        
       POP_Line_Item__c popLnItem=new POP_Line_Item__c();
       popLnItem.Proof_of_Performance_POP__c=popHeader.Id;
       popLnItem.Vendor__c=vendorList[0].Id;
       popLnItem.POP_Submission_Status__c='Approved';       
       insert popLnItem; 
       PageReference pr=new PageReference('/apex/AddPOPLineItemToInvoice?Id='+invoiceObj.id);
       Test.setCurrentPage(pr);       
       AddPOPLineItemToInvoiceController controller = new AddPOPLineItemToInvoiceController(new ApexPages.StandardController(invoiceObj)); 
       controller.AddPOPLineItemToInvoice();
       controller.getPopLineItemList();
       controller.getMessage();    
       controller.getPOPMessage(); 
       controller.getPartner();
       controller.setPartner(partnerList);
       controller.getEmailTxt();
       controller.setEmailTxt('test@dell.com;test2@dell.com');
       controller.sendToPartner();
   }   
   
      public static testMethod void testErrors(){ 
        userName='testErrorCall';
       createData();       
       Proof_of_Performance_POP__c popHeader=new Proof_of_Performance_POP__c();
       popHeader.mdf_Program__c=mdfProgram.Id;
       popHeader.name='Test POP';        
       insert popHeader;        
       POP_Line_Item__c popLnItem=new POP_Line_Item__c();
       popLnItem.Proof_of_Performance_POP__c=popHeader.Id;
       popLnItem.Vendor__c=vendorList[0].Id;
       popLnItem.POP_Submission_Status__c='Approved';       
       insert popLnItem; 
       PageReference pr=new PageReference('/apex/AddPOPLineItemToInvoice?Id='+invoiceObj.id);
       Test.setCurrentPage(pr);       
       AddPOPLineItemToInvoiceController controller = new AddPOPLineItemToInvoiceController(new ApexPages.StandardController(invoiceObj)); 
       controller.AddPOPLineItemToInvoice();
       controller.getPopLineItemList();
       controller.getMessage();    
       controller.getPOPMessage(); 
       controller.getPartner();
       //controller.setPartner(partnerList);
       controller.getEmailTxt();
       //controller.setEmailTxt('test@dell.com;test2@dell.com');
       controller.sendToPartner();
   }
}