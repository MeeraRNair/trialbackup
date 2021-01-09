@isTest
private class VBRH_CloneWithItems_test{
    
    static Vendor__c parentVendor=new Vendor__c();
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static List<User> users = new List<User>();
    static Volume_Based_Rule_Header__c new_VBHTest=new Volume_Based_Rule_Header__c();
    static Volume_Based_Rule_Header__c new_VBHTest1=new Volume_Based_Rule_Header__c();
    static Volume_Based_Rule_Line_Item__c VBRLI_test= new Volume_Based_Rule_Line_Item__c ();     

    public static void createData(){ 
        Map<String,RecordType> vendorRT=new Map<String,RecordType>();       
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
       
       //Create a test VBH record
        new_VBHTest.Name='Test method';
        new_VBHTest.Vendor__c=vendorList[1].id;
        new_VBHTest.Fiscal_Quarter__c='FY12Q3';
        new_VBHTest.Status__c='Pending';
        new_VBHTest.Region__c='APJ';
     
        //Insert test VBH record
        insert new_VBHTest;
       //Create a test VBH record
        new_VBHTest1.Name='Test method';
        new_VBHTest1.Vendor__c=vendorList[1].id;
        new_VBHTest1.Fiscal_Quarter__c='FY12Q4';
        new_VBHTest1.Status__c='Pending';
        new_VBHTest1.Region__c='APJ';
     
        //Insert test VBH record
        insert new_VBHTest1;
                
        //Create a test VBH line item record
//       VBRLI_test.Vendor__c=vendorList[1].id;
       VBRLI_test.Manufacturer__c='Dell';
       VBRLI_test.Volume_Based_Rule_Header__c=new_VBHTest.id;
       VBRLI_test.Category__c='Class';
     
        //Insert test VBH line item
        Insert VBRLI_test;
    }
  
    static testMethod void VBHCloneControllertest1(){
        createData();
        // setup a reference to the page the controller is expecting with the parameters
        PageReference pref = Page.VolumeBasedRuleClonePage;
        ApexPages.currentPage().getParameters().put('id',new_VBHTest.id);
        Test.setCurrentPage(pref);    
        
        // create the controller
         VBRH_CloneWithItemsVFController ext = new  VBRH_CloneWithItemsVFController(new ApexPages.StandardController(new_VBHTest));
        
        // Switch to test context
        //Test.startTest();
        Volume_Based_Rule_Header__c vbrhElt=ext.getnew_VBH(); 
        vbrhElt.Fiscal_Quarter__c='FY12Q2';
        ext.setnew_VBH(vbrhElt); 
        Boolean bol1=ext.getdisplayerr(); 
        Boolean bol2=ext.getnewfiscalyr();
        Boolean bol3=ext.getfiscalyrerr();  
        Boolean bol4=ext.getduprecordexist();
        // call the cloneWithItems method        
        PageReference ref = ext.VBRCloneWithItems();
        // create the matching page reference
        /*        
        PageReference redir = new PageReference('/'+ext.clonedVBHId+'/e?retURL=%2F'+ext.clonedVBHId);
         // make sure the user is sent to the correct url
        System.assertEquals(ref.getUrl(),redir.getUrl());        
        // check that the new VBH_test was created successfully
        Volume_Based_Rule_Header__c cloned_VBH = [select id from Volume_Based_Rule_Header__c where id = :ext.clonedVBHId];
        System.assertNotEquals(cloned_VBH, null);
        // check that the line item was created
        List<Volume_Based_Rule_Line_Item__c> newItems = [Select Id From Volume_Based_Rule_Line_Item__c where Volume_Based_Rule_Header__c = :cloned_VBH.id];
        System.assertEquals(newItems.size(),1);
        */
        // Switch back to runtime context
       // Test.stopTest();
               
    }
    
   static testMethod void VBHCloneControllertest2(){
        createData();
        // setup a reference to the page the controller is expecting with the parameters
        PageReference pref = Page.VolumeBasedRuleClonePage;
        ApexPages.currentPage().getParameters().put('id',new_VBHTest.id);
        Test.setCurrentPage(pref);    
        
        // create the controller
         VBRH_CloneWithItemsVFController ext = new  VBRH_CloneWithItemsVFController(new ApexPages.StandardController(new_VBHTest));
        
        // Switch to test context
        //Test.startTest();
        Volume_Based_Rule_Header__c vbrhElt=ext.getnew_VBH(); 
        vbrhElt.Fiscal_Quarter__c='FY12Q3';
        ext.setnew_VBH(vbrhElt); 
        Boolean bol1=ext.getdisplayerr(); 
        Boolean bol2=ext.getnewfiscalyr();
        Boolean bol3=ext.getfiscalyrerr();  
        Boolean bol4=ext.getduprecordexist();
        // call the cloneWithItems method        
        PageReference ref = ext.VBRCloneWithItems();              
    }    
    
   static testMethod void VBHCloneControllertest3(){
        createData();
        // setup a reference to the page the controller is expecting with the parameters
        PageReference pref = Page.VolumeBasedRuleClonePage;
        ApexPages.currentPage().getParameters().put('id',new_VBHTest.id);
        Test.setCurrentPage(pref);    
                
        // create the controller
         VBRH_CloneWithItemsVFController ext = new  VBRH_CloneWithItemsVFController(new ApexPages.StandardController(new_VBHTest));
        

        Volume_Based_Rule_Header__c vbrhElt=ext.getnew_VBH(); 
        vbrhElt.Fiscal_Quarter__c='FY12Q4';
        ext.setnew_VBH(vbrhElt); 
        Boolean bol1=ext.getdisplayerr(); 
        Boolean bol2=ext.getnewfiscalyr();
        Boolean bol3=ext.getfiscalyrerr();  
        Boolean bol4=ext.getduprecordexist();
        // call the cloneWithItems method        
        PageReference ref = ext.VBRCloneWithItems();              
    }    
    
    static testMethod void bIUMDFContactTrigger(){
        List<User> userRec = new List<User>();
        Profile profiles=[select id,name from Profile where name like '%MDF Product Manager%' limit 1]; 
        Map<String,RecordType> recordTypeMap=new Map<String,RecordType>();
         
         for(RecordType rtElt:[Select  SobjectType,Name,Id From RecordType 
                                 where Name  IN ('Product Manager Contact', 'Co Marketing Contact') 
                                 And SobjectType='MDF_Contact__c']){
             recordTypeMap.put(rtElt.Name,rtElt);
         }
         for(Integer i = 0; i<3; i++){           
            userRec.add(
                new User(
                    Username='testuser'+i+ System.currentTimeMillis()+'@dell.com',
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
        insert userRec;
           
        MDF_Contact__c mdfContact=new  MDF_Contact__c();
        mdfContact.Name='Test cntct';
        mdfContact.Title__c='Test cntct title';
        mdfContact.phone__c='4563';
        mdfContact.status__c='Active';
        mdfContact.partner_Contact_type__c='Active';
        mdfContact.email__c='test@test.com';
        mdfContact.User__c=userRec[1].Id; 
        mdfContact.recordTypeId=recordTypeMap.get('Product Manager Contact').Id;      
        insert mdfContact; 
    }





}