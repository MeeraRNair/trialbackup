@isTest
private class ViperProgramManagementTest{
    static  MDF_Program__c mdfProgram=new MDF_Program__c(); 
    static Vendor__c parentVendor=new Vendor__c();
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c(); 
    static List<User> users = new List<User>();
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
    static Package__c packageObj=new Package__c(); 
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static Marketing_Plan__c marketingPlan=new Marketing_Plan__c(); 
    static Invoice__c invoiceObj=new Invoice__c(); 
    static Profile profiles;
    static  MDF_Program__c mdfProgram2=new MDF_Program__c();
    
     public static testMethod void testViperProgramManagement(){        
        PageReference pageRef = Page.ProgramVendorAssociation;
        Test.setCurrentPage(pageRef);
        ViperProgramManagement controller = new ViperProgramManagement();
        Boolean contactErrorMessageDisplay=controller.getPendingErrorMsg();
        Boolean DisplaySubVendorList=controller.getDisplaySubVendorList();        
        Boolean DisplaySelectedSubVendors=controller.getDisplaySelectedSubVendors();        
    }
    
    public static void createData(){
       
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();
       
       RecordType marketingPlanRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association' limit 1];
       
       profiles=[select id,name from Profile where name like 'MDF Program Owners' limit 1];
       
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
       
       marketingPlan.name='MP-001';
       marketingPlan.Vendor__c=vendorList[0].Id;
       marketingPlan.Fiscal_Quarter__c='FY12Q1';
       marketingPlan.Region__c='Americas';
       marketingPlan.Contract_Type__c='Volume Based';
       marketingPlan.RecordTypeId=marketingPlanRT.Id;
       marketingPlan.invoice__c=invoiceObj.Id;
       insert marketingPlan; 
       
       packageObj.Marketing_Plan__c=marketingPlan.Id;
       packageObj.Status__c='Pending';
       packageObj.name='TestPkg';
       
       insert packageObj;
        
        for(Integer i = 0; i<3; i++){           
            users.add(
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
        insert users;
        
        mdfProgram.Name='testMDF Program';
        mdfProgram.Program_Owner__c=users[2].id;
        mdfProgram.POP_Owner__c=users[2].id;
        mdfProgram.Program_Status__c='Approved';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q3';
        mdfProgram.OwnerId=users[2].id;
        mdfProgram.Rate_Card_Price__c=12356;
        
        insert mdfProgram;
        
        mdfProgram2.Name='testMDF Program';
        mdfProgram2.Program_Owner__c=users[2].id;
        mdfProgram2.POP_Owner__c=users[1].id;
        mdfProgram2.Program_Status__c='Pending';
        mdfProgram2.Pricing_Type__c='Variable';
        mdfProgram2.Fiscal_Quarter__c='FY12Q3';
        mdfProgram2.OwnerId=users[2].id;
        mdfProgram2.Rate_Card_Price__c=12356;
        mdfProgram2.Business_Segment__c='LE';
        mdfProgram2.OwnerId=UserInfo.getUserId();
        insert mdfProgram2;
        
        for(Integer i = 0; i<3; i++){
           apvList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Pending',
                   MDF_Program__c=mdfProgram.Id,
                   Package__c=packageObj.Id,
                   Vendor__c=vendorList[i].Id,
                   Marketing_Plan__c=marketingPlan.Id,
                   recordTypeId=apvRT.Id,
                   Rate_Card_Price__c=896542,
                   Budgeted_Price__c=56932,
                   Invoice_Amount__c=98980
               )
           );
       }
       
       insert apvList;
        
    }
    
    public static testMethod void testAutoApproveProgram(){
        createData();       
       
        PageReference  pr=new PageReference('/apex/AutoApproveProgram?id='+mdfProgram2.id);
        Test.setCurrentPage(pr);
        ViperProgramManagement controller = new ViperProgramManagement();
        PageReference  pageRefExpected=new PageReference('/'+mdfProgram2.id);
        PageReference  pageRefActual=controller.autoApproveAPVRecord();
        //String expected=pageRefExpected.getUrl();
        //String actual=pageRefActual.getUrl();
        //ystem.assertEquals(expected,actual);
    }//EOM
    
    
    public static testMethod void testInsertProgramVendorAssociation(){
        List<ViperProgramManagement.removeSubVendorWrapper> wrapperList=new List<ViperProgramManagement.removeSubVendorWrapper>();    
        List<Associated_Programs_Vendors__c> apvShowList=new List<Associated_Programs_Vendors__c>();
        createData();
        RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association' limit 1];
       
        
        for(Integer i = 0; i<3; i++){
           apvShowList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Pending',
                   MDF_Program__c=mdfProgram.Id,
                   Package__c=packageObj.Id,
                   Vendor__c=vendorList[i].Id,
                   Marketing_Plan__c=marketingPlan.Id,
                   recordTypeId=apvRT.Id,
                   Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
                   Budgeted_Price__c=mdfProgram.Rate_Card_Price__c,
                   Invoice_Amount__c=98980
               )
           );
       }
       for(integer i=0;i<apvList.size();i++){
           if(apvShowList[i].vendor__c==vendorList[i].Id){
               ViperProgramManagement.removeSubVendorWrapper obj=new ViperProgramManagement.removeSubVendorWrapper(apvList[i],vendorList[i]);
               obj.selected=true;
               wrapperList.add(obj);
           }            
        }
        
        PageReference  pr=new PageReference('/apex/ProgramVendorAssociation?id='+mdfProgram.id);
        Test.setCurrentPage(pr);
        ViperProgramManagement controller = new ViperProgramManagement();
        PageReference  pageRefExpected=new PageReference('/'+mdfProgram.id);
        
        List<ViperProgramManagement.removeSubVendorWrapper> rsvwList=controller.getAssociatedProgramsVendorsList();
        controller.setAssociatedProgramsVendorsList(wrapperList);
        Boolean bol=controller.getAuthErrorMsg();
        PageReference  pageRefActual=controller.insertProgramVendorAssociation();
        String expected=pageRefExpected.getUrl();
        String actual=pageRefActual.getUrl();
        System.assertEquals(expected,actual);
        
    }//EOM
    
    
    public static testMethod void testdeleteProgram(){
        createData();
        mdfProgram.Program_Status__c='Pending';
        update mdfProgram; 
        System.runAs(users[2]){
            PageReference  pr=new PageReference('/apex/DeleteMDFProgram?id='+mdfProgram.id);
            Test.setCurrentPage(pr);
            ViperProgramManagement controller = new ViperProgramManagement();
            //PageReference  pageRefExpected=new PageReference('/a1R/o');
            PageReference  pageRefActual=controller.deleteProgram();
            //String expected=pageRefExpected.getUrl();
            //String actual=pageRefActual.getUrl();
            //System.assertEquals(expected,actual);
        }
    }//EOM
    
    
    public static testMethod void  testUpdateBudgetedPrice(){
        
        createData();
        Set<Id> packageIdSet=new Set<Id>(); 
        List<Associated_Programs_Vendors__c> APVUpdateList=new List<Associated_Programs_Vendors__c>(); 
        Map<Id,Associated_Programs_Vendors__c> APVUpdateMap=new Map<Id,Associated_Programs_Vendors__c>(); 
        test.startTest();
		for(Associated_Programs_Vendors__c apv:apvList){
            apv.POP_Status__c='Executed';   
            apv.Status__c='Signed';  
            apv.POP_Status_Reason__c='abcd'; 
            apv.marketing_Plan__c=marketingPlan.Id; 
            //APVUpdateMap.put(apv.Id,apv);
            apvUpdateList.add(apv);
        }         
         update apvUpdateList;         
        //packageIdSet.add(packageObj.Id);
        //ViperProgramManagement.updateBudgetedPrice(packageIdSet,APVUpdateMap); 
        test.stopTest();
        
    }
    
    public static testMethod void  testUpdateInvoiceAmount(){
        
        createData();
        Set<Id> mPlanIdSet=new Set<Id>(); 
        List<Associated_Programs_Vendors__c> apvUpdateList=new List<Associated_Programs_Vendors__c>(); 
        Map<Id,Associated_Programs_Vendors__c> APVUpdateMap=new Map<Id,Associated_Programs_Vendors__c>(); 
                  
        mPlanIdSet.add(marketingPlan.Id);
		test.startTest();
        for(Associated_Programs_Vendors__c apv:apvList){
            apv.POP_Status__c='Executed';   
            apv.Status__c='Signed';  
            apv.POP_Status_Reason__c='abcd'; 
            apv.marketing_Plan__c=marketingPlan.Id; 
            //APVUpdateMap.put(apv.Id,apv);
            apvUpdateList.add(apv);
        }
        update apvUpdateList;
        //ViperProgramManagement.updateInvoiceAmount(mPlanIdSet,APVUpdateMap); 
        test.stopTest();
        
    }//EOM 
    
    
    public static testMethod void testSortByAlphabet(){
       List<ViperProgramManagement.removeSubVendorWrapper> wrapperList=new List<ViperProgramManagement.removeSubVendorWrapper>();
       createData();
       for(integer i=0;i<apvList.size();i++){
           if(apvList[i].vendor__c==vendorList[i].Id){
               ViperProgramManagement.removeSubVendorWrapper obj=new ViperProgramManagement.removeSubVendorWrapper(apvList[i],vendorList[i]);
               obj.selected=true;
               wrapperList.add(obj);
           }            
        }        
        PageReference pr=new PageReference('/apex/ProgramVendorAssociation?id='+mdfProgram.id);
        Test.setCurrentPage(pr);
        ViperProgramManagement controller = new ViperProgramManagement();
        List<ViperProgramManagement.removeSubVendorWrapper> rsvwList=controller.getAssociatedProgramsVendorsList();
        controller.setAssociatedProgramsVendorsList(wrapperList); 
        PageReference pr1=new PageReference('/apex/ProgramVendorAssociation?selected=T'+mdfProgram.id);
        Test.setCurrentPage(pr1);       
        PageReference  pageRefActual=controller.SortByAlphabet();       
        System.assertEquals(null,pageRefActual);
        
    }//EOM
    
    public static testMethod void testDeleteSelectedAPVRecordsFromProgram(){
       List<ViperProgramManagement.APVWrapper> wrapperList=new List<ViperProgramManagement.APVWrapper>();
       createData();
       for(integer i=0;i<apvList.size();i++){
           if(apvList[i].vendor__c==vendorList[i].Id){
               ViperProgramManagement.APVWrapper obj=new ViperProgramManagement.APVWrapper(apvList[i]);
               obj.selected=true;
               wrapperList.add(obj);
           }            
        }        
        PageReference pr=new PageReference('/apex/DeleteAPVFromMDFProgram?Id='+mdfProgram.id);
        Test.setCurrentPage(pr);
        ViperProgramManagement controller = new ViperProgramManagement();
        List<ViperProgramManagement.APVWrapper> apvWrapperList=controller.getAPVWrapperRecs();
        controller.setAPVWrapperRecs(wrapperList);        
        PageReference  pageRefActual=controller.deleteSelectedAPVRecordsFromProgram();       
        //System.assertEquals(null,pageRefActual);
        
    }//EOM
    
    public static testMethod void testDeleteSelectedAPVRecsFromMarketingPlan(){
       List<ViperProgramManagement.APVWrapper> wrapperList=new List<ViperProgramManagement.APVWrapper>();
       createData();
       for(integer i=0;i<apvList.size();i++){
           if(apvList[i].Marketing_Plan__c==marketingPlan.Id){
               ViperProgramManagement.APVWrapper obj=new ViperProgramManagement.APVWrapper(apvList[i]);
               obj.selected=true;
               wrapperList.add(obj);
           }            
        }        
        PageReference pr=new PageReference('/apex/DeleteAPVFromMarketingPlan?MPlanId='+marketingPlan.id);
        Test.setCurrentPage(pr);
        ViperProgramManagement controller = new ViperProgramManagement();
        List<ViperProgramManagement.APVWrapper> apvWrapperList=controller.getAPVWrapperRecs();
        controller.setAPVWrapperRecs(wrapperList);        
        PageReference  pageRefActual=controller.deleteSelectedAPVRecsFromMarketingPlan();       
        //System.assertEquals(null,pageRefActual);
        
    }//EOM
    
    
    public static testMethod void testBeforeAfterAPVTrigger(){    
       
        createData();
        Set<Id> mPlanIdSet=new Set<Id>(); 
        List<Associated_Programs_Vendors__c> apvUpdateList=new List<Associated_Programs_Vendors__c>(); 
        Map<Id,Associated_Programs_Vendors__c> APVUpdateMap=new Map<Id,Associated_Programs_Vendors__c>(); 
        test.startTest();     
        mPlanIdSet.add(marketingPlan.Id);
        for(Associated_Programs_Vendors__c apv:apvList){
            apv.POP_Status__c='Executed';   
            apv.Status__c='Signed';  
            apv.POP_Status_Reason__c='abcd'; 
            apv.marketing_Plan__c=marketingPlan.Id; 
            apv.budgeted_Price__c=3241;
            apvUpdateList.add(apv);
        }
        update apvUpdateList;
        test.stopTest();
        
    }
   
    
    public static testMethod void testAferPOPLnItemTrigger(){    
        createData();
        Proof_of_Performance_POP__c popHeader=new Proof_of_Performance_POP__c();
        popHeader.mdf_Program__c=mdfProgram.Id;
        popHeader.name='Test POP';        
        insert popHeader; 
        
        POP_Line_Item__c popLnItem=new POP_Line_Item__c();
        popLnItem.Proof_of_Performance_POP__c=popHeader.Id;
        popLnItem.Vendor__c=vendorList[1].Id; 
        popLnItem.POP_Submission_Status__c='New';       
        insert popLnItem; 
        
        popLnItem.POP_Submission_Status__c='Approved'; 
        
        Update popLnItem;
         
        
    }
    
     public static testMethod void testBeforeAfterMDFProgramTrigger(){    
        createData();
        
        Map<String,RecordType> mdfPgmRtMap=new Map<String,RecordType>(); 
        
         for(RecordType RTYpe:[Select Name, Id From RecordType where sObjectType='MDF_Program__c']){
             mdfPgmRtMap.put(RTYpe.name,RTYpe);
         }
        MDF_Program__c mdfProgramFQ=new MDF_Program__c();   
        mdfProgramFQ.Name='testMDF Program1';
        mdfProgramFQ.Program_Owner__c=users[2].id;
        mdfProgramFQ.POP_Owner__c=users[1].id;
        mdfProgramFQ.Program_Status__c='Pending';
        mdfProgramFQ.Pricing_Type__c='Variable';
        mdfProgramFQ.Fiscal_Quarter__c='FY12Q3';
        mdfProgramFQ.OwnerId=users[2].id;
        mdfProgramFQ.Rate_Card_Price__c=12356;
        mdfProgramFQ.Business_Segment__c='LE';
        mdfProgramFQ.OwnerId=UserInfo.getUserId();
        mdfProgramFQ.recordTypeId=mdfPgmRtMap.get('Seed Units').Id;
        insert mdfProgramFQ;
        
        MDF_Program__c mdfProgramRT=new MDF_Program__c(); 
         mdfProgramRT.Name='testMDF Program2';
        mdfProgramRT.Program_Owner__c=users[2].id;
        mdfProgramRT.POP_Owner__c=users[1].id;
        mdfProgramRT.Program_Status__c='Pending';
        mdfProgramRT.Pricing_Type__c='Variable';
        mdfProgramRT.Fiscal_Quarter__c='FY12Q3';
        mdfProgramRT.OwnerId=users[2].id;
        mdfProgramRT.Rate_Card_Price__c=12356;
        mdfProgramRT.Business_Segment__c='LXX';
        mdfProgramRT.OwnerId=UserInfo.getUserId();
        mdfProgramRT.recordTypeId=mdfPgmRtMap.get('Contest').Id;
        insert mdfProgramRT;
        
        PageReference  pr=new PageReference('/apex/ProgramVendorAssociation?id='+mdfProgramRT.id);
        Test.setCurrentPage(pr);
        ViperProgramManagement controller = new ViperProgramManagement();
    }
    
    //R12.7 test methods
    public static testMethod void testGetSetMethods(){
        createData();
        ViperProgramManagement controller = new ViperProgramManagement();
        Boolean bol1=controller.getVariablePgm(); 
        controller.setVariablePgm(true);
        Boolean bol2=controller.getProgramOwner();
        controller.setProgramOwner(true); 
        MDF_Program__c mdfPgm=controller.getMDFProgram();       
    }
    
    public static testMethod void testMassUpdateAPVRecrods(){
        createData();
        List<ViperProgramManagement.APVWrapper> wrapperList=new List<ViperProgramManagement.APVWrapper>();
        
         for(integer i=0;i<apvList.size();i++){
           if(apvList[i].vendor__c==vendorList[i].Id){
               ViperProgramManagement.APVWrapper obj=new ViperProgramManagement.APVWrapper(apvList[i]);
               obj.selected=true;
               wrapperList.add(obj);
           }            
        }        
        PageReference pr=new PageReference('/apex/updateAllAPV?Id='+mdfProgram.id);
        Test.setCurrentPage(pr);
        ViperProgramManagement controller = new ViperProgramManagement();
        List<ViperProgramManagement.APVWrapper> apvWrapperList=controller.getAPVShowList(); 
        controller.setAPVShowList(wrapperList);              
        PageReference  pageRefActual=controller.massUpdateAPVRecrods();
    }
    
    public static testMethod void testCancel(){
        createData();
        List<ViperProgramManagement.APVWrapper> wrapperList=new List<ViperProgramManagement.APVWrapper>();
        
         for(integer i=0;i<apvList.size();i++){
           if(apvList[i].vendor__c==vendorList[i].Id){
               ViperProgramManagement.APVWrapper obj=new ViperProgramManagement.APVWrapper(apvList[i]);
               obj.selected=true;
               wrapperList.add(obj);
           }            
        }        
        PageReference pr=new PageReference('/apex/updateAllAPV?Id='+mdfProgram.id);
        Test.setCurrentPage(pr);
        ViperProgramManagement controller = new ViperProgramManagement();                
        PageReference  pageRefActual=controller.CancelAction();
    } 
    
   
}