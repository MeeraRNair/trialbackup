@isTest
private class SendInvoiceCtrlExtTest {

    static MDF_Program__c mdfProgram=new MDF_Program__c(); 
    static Vendor__c parentVendor=new Vendor__c();
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c(); 
    static List<User> users = new List<User>();
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
    static Package__c packageObj=new Package__c(); 
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static Marketing_Plan__c marketingPlan=new Marketing_Plan__c(); 
    static Invoice__c invoiceObj=new Invoice__c(); 
    static Attachment attachmentObj=new Attachment(); 
    static Profile profiles;
    static MDF_Contact__c mdfContact = new MDF_Contact__c();
    static MDF_Associated_Contact__c mdfAssocContact = new MDF_Associated_Contact__c();
    static POP_Line_Item__c POPVRecord = new POP_Line_Item__c();
    static Proof_of_Performance_POP__c POPRecord = new Proof_of_Performance_POP__c();
    static String userName='';
    
    public static void createData(){
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();
       
       RecordType marketingPlanRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];

       RecordType mdfContactRT=[Select Name, Id From RecordType where 
       sObjectType='MDF_Contact__c' and name='Partner Contact' limit 1];
       
       profiles=[select id,name from Profile where name like '%mdf%' limit 1];
       
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;
       
       insert parentVendor;
       
       for(Integer i = 0; i<3; i++){
           vendorList.add(
               new Vendor__c(
                   Parent_Vendor__c=parentVendor.Id,
                   //Name='TestSubVendor'+i, // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
                   Name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+i, // Fenny added on 21-Feb-2013
                   Partner_Status__c='Active',
                   Partner_Type__c='Value',
                   Product_Category__c='Networking',
                   Contract_Types_eligible_for__c='Volume Based,Ala Carte',
                   recordTypeId=vendorRT.get('Sub Vendor').Id
               )
           );
       }
       
       insert vendorList; 
       
       invoiceObj.name='Inv-001';
       invoiceObj.Vendor__c=vendorList[0].Id;
       invoiceObj.Fiscal_Quarter__c='FY12Q1';
       invoiceObj.Region__c='Americas';
       invoiceObj.Contract_Type__c='Volume Based, Ala Carte, Headcount'; 
       
       insert invoiceObj;
       
       for(Integer i = 0; i<3; i++){           
           users.add(
               new User(
                   Username='testinguser'+userName+i+'@dell.com',
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
       
       attachmentObj.Name = 'Invoice.Pdf';
       attachmentObj.ParentId = invoiceObj.Id;
       attachmentObj.body= Blob.valueOf('Some Text');
       insert attachmentObj;
       
       mdfContact.Name = 'Mr Tam';
       mdfContact.Status__c = 'Active';
       mdfContact.Region__c = 'GBL';
       mdfContact.recordTypeId = mdfContactRT.Id ;
       mdfContact.Primary_Secondary__c = 'Primary'; 
       mdfContact.Email__c = 'A@b.c'; 
       insert mdfContact;
       
       mdfAssocContact.Vendor__c =vendorList[0].Id;
       mdfAssocContact.mdf_Contact__c=mdfContact.Id;
       
       insert mdfAssocContact;       
    }
    static testMethod void testsendInvoice(){
        createdata();    
        
        List<SendInvoiceCtrlExt.AttachmentWrapperCls> attachmentIteratedList=new List<SendInvoiceCtrlExt.AttachmentWrapperCls>(); 
        SendInvoiceCtrlExt.AttachmentWrapperCls wrapperElt=new SendInvoiceCtrlExt.AttachmentWrapperCls(attachmentObj);
        mdfProgram = [select Id,Name from MDF_Program__c limit 1];
        wrapperElt.selected=true;
        wrapperElt.segment='Large Business'; 
        wrapperElt.program=mdfProgram.Name;
        wrapperElt.status='Approved';      
        attachmentIteratedList.add(wrapperElt);

        PageReference pref = Page.SendInvoice;
        pref.getParameters().put('id',invoiceObj.id);
        Test.setCurrentPage(pref);
        SendInvoiceCtrlExt con = new SendInvoiceCtrlExt(new ApexPages.StandardController(invoiceObj)); 
        List<SendInvoiceCtrlExt.AttachmentWrapperCls> listElt=con.getattachmentIteratedList();
        con.setattachmentIteratedList(attachmentIteratedList); 

        MDF_Associated_Contact__c mdfCntctElt = con.getAssociatedMDFContact();
        con.setAssociatedMDFContact(mdfAssocContact);
        String mailID = con.getEmail();
        con.setEmail('manikandan.raju@ust-global.com');
        pref = con.sendMail();
    }
    
    static testMethod void NoEmailsendInvoice(){
        createdata();    
        
        List<SendInvoiceCtrlExt.AttachmentWrapperCls> attachmentIteratedList=new List<SendInvoiceCtrlExt.AttachmentWrapperCls>(); 
        SendInvoiceCtrlExt.AttachmentWrapperCls wrapperElt=new SendInvoiceCtrlExt.AttachmentWrapperCls(attachmentObj);
        mdfProgram = [select Id,Name from MDF_Program__c limit 1];
        wrapperElt.selected=true;
        wrapperElt.segment='Large Business'; 
        wrapperElt.program=mdfProgram.Name;
        wrapperElt.status='Approved';      
        attachmentIteratedList.add(wrapperElt);

        PageReference pref = Page.SendInvoice;
        pref.getParameters().put('id',invoiceObj.id);
        Test.setCurrentPage(pref);
        SendInvoiceCtrlExt con = new SendInvoiceCtrlExt(new ApexPages.StandardController(invoiceObj)); 
        List<SendInvoiceCtrlExt.AttachmentWrapperCls> listElt=con.getattachmentIteratedList();
        con.setattachmentIteratedList(attachmentIteratedList); 

        MDF_Associated_Contact__c mdfCntctElt = con.getAssociatedMDFContact();
        con.setAssociatedMDFContact(mdfAssocContact);
        String mailID = con.getEmail();
        con.setEmail('');
        pref = con.sendMail();
    }
}