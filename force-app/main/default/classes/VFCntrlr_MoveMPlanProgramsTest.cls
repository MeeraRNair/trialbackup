@isTest
Private Class VFCntrlr_MoveMPlanProgramsTest{
    static  MDF_Program__c mdfProgram=new MDF_Program__c(); 
    static Vendor__c parentVendor=new Vendor__c();
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c(); 
    static List<User> users = new List<User>();
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
    static Package__c packageObj=new Package__c(); 
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static Marketing_Plan__c mPlanVB1=new Marketing_Plan__c(); 
    static Marketing_Plan__c mPlanVB2=new Marketing_Plan__c();
    static Marketing_Plan__c mPlanAlaC=new Marketing_Plan__c();
    static Marketing_Plan__c mPlanNew=new Marketing_Plan__c();
    static Invoice__c invoiceObj=new Invoice__c(); 
    static Profile profiles;
    static VFCntrlr_MoveMPlanPrograms.APVWrapper apvWrapperElt;
    
    public static void createData(){
       
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();
       
       Test.StartTest();
       RecordType mPlanVBRT=[Select Name, Id From RecordType where 
           sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       RecordType mPlanACRT=[Select Name, Id From RecordType where 
           sObjectType='Marketing_Plan__c' and name='Ala Carte Marketing Plan' limit 1];
       
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];
       
       profiles=[select id,name from Profile where name like  'MDF Program Owners' limit 1];
       
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }
      // parentVendor.name='TestVendor';
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A';
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
       
       mPlanVB1.name='MPVB-001';
       mPlanVB1.Vendor__c=vendorList[0].Id;
       mPlanVB1.Fiscal_Quarter__c='FY12Q1';
       mPlanVB1.Region__c='Americas';
       mPlanVB1.Contract_Type__c='Volume Based';
       mPlanVB1.RecordTypeId=mPlanVBRT.Id;
       insert mPlanVB1; 
       
       mPlanVB2.name='MPVB-002';
       mPlanVB2.Vendor__c=vendorList[0].Id;
       mPlanVB2.Fiscal_Quarter__c='FY12Q1';
       mPlanVB2.Region__c='APJ';
       mPlanVB2.Contract_Type__c='Volume Based';
       mPlanVB2.RecordTypeId=mPlanVBRT.Id;
       insert mPlanVB2; 
       
       mPlanAlaC.name='MPAC-001';
       mPlanAlaC.Vendor__c=vendorList[0].Id;
       mPlanAlaC.Fiscal_Quarter__c='FY12Q1';
       mPlanAlaC.Region__c='Americas';
       mPlanAlaC.Contract_Type__c='Ala Carte';
       mPlanAlaC.Contract_Status__c='Pending';
       mPlanAlaC.RecordTypeId=mPlanACRT.Id;
       insert mPlanAlaC; 
       
       mPlanNew.name='MPVB-003';
       mPlanNew.Vendor__c=vendorList[0].Id;
       mPlanNew.Fiscal_Quarter__c='FY12Q1';
       mPlanNew.Region__c='EMEA';
       mPlanNew.Contract_Type__c='Volume Based';       
       mPlanNew.RecordTypeId=mPlanVBRT.Id;
       
      
        
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
        mdfProgram.Program_Owner__c=users[0].id;
        mdfProgram.POP_Owner__c=users[1].id;
        mdfProgram.Program_Status__c='Approved';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q3';
        mdfProgram.OwnerId=users[2].id;
        mdfProgram.Rate_Card_Price__c=12356;
        
        insert mdfProgram;
        
        for(Integer i = 0; i<3; i++){
           apvList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Pending',
                   MDF_Program__c=mdfProgram.Id,                  
                   Vendor__c=vendorList[i].Id,
                   Marketing_Plan__c=mPlanVB1.Id,
                   recordTypeId=apvRT.Id,
                   Rate_Card_Price__c=896542,
                   Budgeted_Price__c=56932                   
               )
           );
       }
       
       insert apvList;
       
       //changes by sharad for user story 
       mPlanVB1.Currency_Code__c = 'ZAR';
       mPlanVB1.Contract_Status__c = 'Signed';
       mPlanVB1.Contract_Type__c = 'Ala Carte';
       mPlanVB1.Region__c = 'Americas';
       mPlanVB1.Fiscal_Quarter__c = 'FY12Q1';
       update mPlanVB1;
      
       mPlanVB1.Fiscal_Quarter__c = 'FY12Q4';
       mPlanVB1.Contract_Type__c  = 'Volume Based';
       update mPlanVB1;
       
       Test.StopTest(); 
    }
     
    
     public static testMethod void testVFCtlrMoveMPlanPrograms(){
         createData();       
         
        PageReference pageRef = Page.MoveMPlanPgm;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MoveMPlanPrograms controller = new VFCntrlr_MoveMPlanPrograms(new ApexPages.StandardController(mPlanVB1));
        Boolean mpErr=controller.getMpErr();
        Boolean errorMsg=controller.getErrorMsg();        
        Boolean apvOptionList=controller.getAPVOptionList(); 
        List<VFCntrlr_MoveMPlanPrograms.APVWrapper> aPVWrapper=controller.getAPVWrapper(); 
        controller.setAPVWrapper(aPVWrapper);        
        List<Associated_Programs_Vendors__c> apvRecList=controller.getAPVList();
        List<Marketing_plan__c> mplanRecList=controller.getMarketingPlanList(); 
        Boolean bolMplan=controller.getMPlanOptionList(); 
        Marketing_plan__c mPlanRec=controller.getMarketingPlan(); 
        controller.setMarketingPlan(mPlanRec);
        Boolean bolCreate=controller.getCreateMPlan();
        List<SelectOption> selectOptions=controller.getContractTypeOptions();    
        String cType=controller.getContractType();
        controller.setContractType(cType);
        
    
    }
    
     public static testMethod void testMove2ExistingMPlan(){
         createData(); 
         
         List<VFCntrlr_MoveMPlanPrograms.APVWrapper> aPVWrapperLst=new List<VFCntrlr_MoveMPlanPrograms.APVWrapper>(); 
         
         for(Associated_Programs_Vendors__c apv:apvList){  
            apvWrapperElt=new VFCntrlr_MoveMPlanPrograms.APVWrapper(apv); 
            apvWrapperElt.selected=true;             
            aPVWrapperLst.add(apvWrapperElt);
        }       
        PageReference pageRef = Page.MoveMPlanPgm;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MoveMPlanPrograms controller = new VFCntrlr_MoveMPlanPrograms(new ApexPages.StandardController(mPlanVB1));
        List<VFCntrlr_MoveMPlanPrograms.APVWrapper> aPVWrapper=controller.getAPVWrapper(); 
        controller.setAPVWrapper(aPVWrapperLst);   
        PageReference pageRef2=controller.move2ExistingMPlan();
       
     }     
     /*public static testMethod void testChangeMPlanOfAPV(){
         createData();
         PageReference pageRef =new PageReference('/apex/MoveMPlanPgm?mid='+mPlanAlaC.Id);
         Test.setCurrentPage(pageRef);
        VFCntrlr_MoveMPlanPrograms controller = new VFCntrlr_MoveMPlanPrograms(new ApexPages.StandardController(mPlanVB1));
        //List<Associated_Programs_Vendors__c> selectedApVList=controller.getSelectedAPVs();
        List<Marketing_plan__c> mPlanLst=controller.getMarketingPlanList();
        pageReference pageRef2=controller.changeMPlanOfAPV();
     }*/
     
     public static testMethod void testMove2NewMPlan(){
         createData();
         List<VFCntrlr_MoveMPlanPrograms.APVWrapper> aPVWrapperLst=new List<VFCntrlr_MoveMPlanPrograms.APVWrapper>(); 
         
         for(Associated_Programs_Vendors__c apv:apvList){  
            apvWrapperElt=new VFCntrlr_MoveMPlanPrograms.APVWrapper(apv); 
            apvWrapperElt.selected=true;             
            aPVWrapperLst.add(apvWrapperElt);
        }
                 
        PageReference pageRef = Page.MoveMPlanPgm;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MoveMPlanPrograms controller = new VFCntrlr_MoveMPlanPrograms(new ApexPages.StandardController(mPlanVB1));
        List<VFCntrlr_MoveMPlanPrograms.APVWrapper> aPVWrapper=controller.getAPVWrapper(); 
        controller.setAPVWrapper(aPVWrapperLst);  
        PageReference pageRef2 = controller.move2NewMPlan();
        

     }
     
      public static testMethod void testSaveMPlan(){
          createData();
          
        RecordType mPlanVBRT=[Select Name, Id From RecordType where 
        sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
        Marketing_plan__c marketingPlanRecNew=new Marketing_plan__c(); 
        marketingPlanRecNew.name='MP-001';
        marketingPlanRecNew.Vendor__c=vendorList[0].Id;
        marketingPlanRecNew.Fiscal_Quarter__c='FY12Q1';
        marketingPlanRecNew.Region__c='AmericasX';
        marketingPlanRecNew.Contract_Type__c='Volume Based';
        //marketingPlanRecNew.RecordTypeId=mPlanVBRT.Id;
        
        List<VFCntrlr_MoveMPlanPrograms.APVWrapper> aPVWrapperLst=new List<VFCntrlr_MoveMPlanPrograms.APVWrapper>(); 
         for(Associated_Programs_Vendors__c apv:apvList){  
            apvWrapperElt=new VFCntrlr_MoveMPlanPrograms.APVWrapper(apv); 
            apvWrapperElt.selected=true;             
            aPVWrapperLst.add(apvWrapperElt);
        }
        
        
        PageReference pageRef =Page.MoveMPlanPgm;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MoveMPlanPrograms controller = new 
        VFCntrlr_MoveMPlanPrograms(new ApexPages.StandardController(mPlanVB1));
        
        List<VFCntrlr_MoveMPlanPrograms.APVWrapper> aPVWrapper=controller.getAPVWrapper(); 
        controller.setAPVWrapper(aPVWrapperLst);
         PageReference pageRef2 = controller.move2NewMPlan();
         Marketing_plan__c marketingPlanRec=controller.getMarketingPlan();
        controller.setMarketingPlan(marketingPlanRecNew);
        String cType=controller.getContractType();
        controller.setContractType('Volume Based');
        pageReference pageRef3=controller.saveMPlan();
        
     }
}