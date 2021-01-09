//changes done by sharad added test.startTest() or test.stopTest for remove to many sql 

@isTest
private class VFCntrlr_EmailDeleteMarketingPlanTest{
    static  MDF_Program__c mdfProgram=new MDF_Program__c();
    static  MDF_Program__c mdfProgram2=new MDF_Program__c();
    static  MDF_Program__c mdfProgram3=new MDF_Program__c();     
    static Vendor__c parentVendor=new Vendor__c();
    static Vendor__c subVendor=new Vendor__c();     
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c();     
    static List<User> users = new List<User>();    
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();    
    static Package__c packageObj=new Package__c();     
    static List<Vendor__c> vendorList=new List<Vendor__c>();     
    static Marketing_Plan__c marketingPlan=new Marketing_Plan__c();     
    static Invoice__c invoiceObj=new Invoice__c();     
    static Profile profiles;    
    static List<MDF_Program__c> mdfList=new List<MDF_Program__c>();    
    static List<ViperContractManagement.MPWrapper> testObj=new List<ViperContractManagement.MPWrapper>();     
    static Marketing_Plan__c MarketingPlanRec=new Marketing_Plan__c();
    static Volume_Based_Rule_Header__c vbrhObj=new Volume_Based_Rule_Header__c();
    static MDF_Contact__c mdfContact=new  MDF_Contact__c();
    static MDF_Associated_Contact__c mdfAssoCntct=new  MDF_Associated_Contact__c();
    static MDF_Contact__c pdtMgrContact=new  MDF_Contact__c();
    static MDF_Associated_Contact__c mdfPdtAssoCntct=new  MDF_Associated_Contact__c();
    
    static Marketing_Plan__c mPlanAlaC=new Marketing_Plan__c();
    static Marketing_Plan__c mPlanRebates=new Marketing_Plan__c();
    static Rebate_Rule_Header__c rrhObj=new Rebate_Rule_Header__c();
    static echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
    
    public static void createData(){ 
              
       //Test.StartTest();
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();       
       RecordType marketingPlanRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       RecordType mPlanACRT=[Select Name, Id From RecordType where            
       sObjectType='Marketing_Plan__c' and name='Ala Carte Marketing Plan' limit 1];
       
       RecordType mPlanRebatesRT=[Select Name, Id From RecordType where            
       sObjectType='Marketing_Plan__c' and name='Rebates Marketing Plan' limit 1];
       
       RecordType partnerCntctRT=[Select Name, Id From RecordType where sObjectType='MDF_Contact__c' 
        and name='Partner Contact' limit 1];

       
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];
       
       profiles=[select id,name from Profile where name like  'MDF Program Owners' limit 1];
       
       RecordType pdctMgrContact=[Select Name, Id From RecordType where sObjectType='MDF_Contact__c' 
        and name='Product Manager Contact' limit 1];
        
               
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
                   Contract_Types_eligible_for__c='Volume Based,Ala Carte,Rebates',
                   recordTypeId=vendorRT.get('Sub Vendor').Id
               )
           );
       }
       
       insert vendorList;
       
       Test.StartTest();
       subVendor.Parent_Vendor__c=parentVendor.Id;
       //subVendor.Name='TestSubVendorXX'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
       subVendor.Partner_Status__c='Active';
       subVendor.Partner_Type__c='Value';
       subVendor.Product_Category__c='Networking';
       subVendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte,Rebates';
       subVendor.recordTypeId=vendorRT.get('Sub Vendor').Id;
       insert subVendor;            
       
       
       mPlanAlaC.name='MP-Alac';       
       mPlanAlaC.Vendor__c=vendorList[0].Id;       
       mPlanAlaC.Fiscal_Quarter__c='FY12Q1';       
       mPlanAlaC.Region__c='Americas';       
       mPlanAlaC.Contract_Type__c='Ala Carte';       
       mPlanAlaC.Contract_Status__c='Pending';       
       mPlanAlaC.RecordTypeId=mPlanACRT.Id;       
       insert mPlanAlaC;  
       
      UserRole  userRoleRec=[Select  PortalAccountId,Name,Id From UserRole  where  name like '%WW_Exec' Limit 1];
      
      users=[select id,name from user where ProfileId =:profiles.Id and IsActive=true Limit 3];
       /*        
        for(Integer i = 0; i<3; i++){           
            users.add(
                new User(
                    Username='testuser'+i+'@dell.com',
                    Alias = 'test'+i, 
                    Email='testuser'+i+'@dell.com', 
                    FirstName='John', 
                    LastName='Doe'+i, 
                    ProfileId =profiles.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='John.doe'+i,
                    UserRoleId=userRoleRec.Id
               )
            );
        }
        insert users;
        */
        mdfProgram.Name='testMDF Program';
        mdfProgram.Program_Owner__c=users[0].id;
        mdfProgram.POP_Owner__c=users[1].id;
        mdfProgram.Program_Status__c='Pending';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q1';
        mdfProgram.OwnerId=users[2].id;
        mdfProgram.Rate_Card_Price__c=12356;
        mdfProgram.Region__c='Americas';        
        insert mdfProgram;         
                
        for(Integer i = 0; i<3; i++){        
           apvList.add(
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
                   //Business_Segment__c='CSMR'
                 )
              );
       }              
       insert apvList;        
        
        MarketingPlanRec.name='MP-001';
        MarketingPlanRec.Vendor__c=vendorList[0].Id;
        MarketingPlanRec.Fiscal_Quarter__c='FY12Q2';
        MarketingPlanRec.Region__c='APJ';
        MarketingPlanRec.Contract_Type__c='Volume Based';
        MarketingPlanRec.RecordTypeId=marketingPlanRT.Id;
        MarketingPlanRec.invoice__c=invoiceObj.Id;
        MarketingPlanRec.Contract_Status__c='Pending';
        insert MarketingPlanRec;
        
        vbrhObj.Vendor__c=marketingPlanRec.Vendor__c;        
        vbrhObj.Fiscal_Quarter__c=marketingPlanRec.Fiscal_Quarter__c;        
        vbrhObj.Region__c=marketingPlanRec.Region__c;        
        insert vbrhObj; 
        
        mdfContact.Name='Test cntct';
        mdfContact.Title__c='Test cntct title';
        mdfContact.status__c='Active';
        mdfContact.partner_Contact_type__c='Active';
        mdfContact.email__c='test@test.com';
        mdfContact.recordTypeId=partnerCntctRT.Id;        
        insert mdfContact; 
        
        mdfAssoCntct.vendor__c=vendorList[0].Id;
        mdfAssoCntct.MDF_Contact__c=mdfContact.Id;
        insert mdfAssoCntct;        
        
       mPlanRebates.name='MP-001';
       mPlanRebates.Vendor__c=vendorList[0].Id;
       mPlanRebates.Fiscal_Quarter__c='FY12Q1';
       mPlanRebates.Region__c='Americas';
       mPlanRebates.Contract_Type__c='Rebates';
       mPlanRebates.Contract_Status__c='Pending';
       mPlanRebates.RecordTypeId=mPlanRebatesRT.Id;
       insert mPlanRebates;
        
              
        rrhObj.Vendor__c=mPlanRebates.Vendor__c;         
        rrhObj.Fiscal_Quarter__c=mPlanRebates.Fiscal_Quarter__c;         
        rrhObj.Region__c=mPlanRebates.Region__c;         
        rrhObj.name='Test1'; 
        insert rrhObj;
        
        
        mdfProgram2.Name='testMDF Program';
        mdfProgram2.Program_Owner__c=users[0].id;
        mdfProgram2.POP_Owner__c=users[1].id;
        mdfProgram2.Program_Status__c='Pending';
        mdfProgram2.Pricing_Type__c='Variable';
        mdfProgram2.Fiscal_Quarter__c='FY12Q1';
        mdfProgram2.OwnerId=users[2].id;
        mdfProgram2.Rate_Card_Price__c=12356;
        mdfProgram2.Region__c='Americas';        
        insert mdfProgram2;        
        
        pdtMgrContact.Name = 'Mr Tam';
        pdtMgrContact.Status__c = 'Active';
        pdtMgrContact.Region__c = 'Americas';
        pdtMgrContact.Sub_Region__c = 'North America';
        pdtMgrContact.recordTypeId = pdctMgrContact.Id ;
        pdtMgrContact.Primary_Secondary__c = 'Primary';
        pdtMgrContact.Email__c='hanan.justin@ust-global.com';
        pdtMgrContact.user__c=users[0].Id;
        insert pdtMgrContact; 
        
        mdfPdtAssoCntct.vendor__c=vendorList[0].Id;
        mdfPdtAssoCntct.MDF_Contact__c=pdtMgrContact.Id;
        insert mdfPdtAssoCntct; 
       
        Test.StopTest();   
      }
      
      

      //modified for R12.7
      public static testMethod void testVendorApprovalVB(){
           
           List<Associated_Programs_Vendors__c> apvNewLst=new List<Associated_Programs_Vendors__c>(); 
           List<VFCntrlr_EmailDeleteMarketingPlan.productManager> pdctMgrList=new List<VFCntrlr_EmailDeleteMarketingPlan.productManager>(); 
           createData();           
           
           pdctMgrList.add(new VFCntrlr_EmailDeleteMarketingPlan.productManager(true,mdfPdtAssoCntct));                    
           
           PageReference pageRef = new PageReference('/apex/MPlanVendorApprovalPage?id='+MarketingPlanRec.Id);       
           Test.setCurrentPage(pageRef); 
           VFCntrlr_EmailDeleteMarketingPlan controller = new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(MarketingPlanRec));             
           //List<MDF_Associated_Contact__c> mdfAContactList=controller.getMDFContacts();                     
           boolean dispForm=controller.getDisplayForm();
           boolean profileErr=controller.getProfileErr();
           String emailId=controller.getEmailId();
           controller.setEmailId('hanan.justin@ust-global.com');
           //Pagereference selectedContact=controller.selectContact();
           //String selectedCntct=controller.getSelectedContact();
           //Id selectedCntctId=controller.getSelectedContactId();
           boolean vbrhErr=controller.getVBRHError();
           boolean rrhErr2=controller.getRRHError();
           List<VFCntrlr_EmailDeleteMarketingPlan.productManager> pmCntctlist=controller.getProductManagers();
           controller.setProductManagers(pdctMgrList);
           
           PageReference pageRef3=controller.sendForApproval();           
           
       }
       
       public static testMethod void testSendForApprovalAlacMPlan(){
          
           createData();               
           PageReference pageRefNew = Page.MPlanVendorApprovalPage;       
           Test.setCurrentPage(pageRefNew ); 
           VFCntrlr_EmailDeleteMarketingPlan controller = new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(mPlanAlaC));             
           //List<MDF_Associated_Contact__c> mdfAContactList=controller.getMDFContacts(); 
           PageReference pageRef = new PageReference('/apex/MPlanVendorApprovalPage?CntctID='+mdfAssoCntct.Id);       
           Test.setCurrentPage(pageRef);        
           //Pagereference selectedContact=controller.selectContact();
           boolean dispForm=controller.getDisplayForm();
           String emailId=controller.getEmailId();
           controller.setEmailId('hanan.justin@ust-global.com');
           //String selectedCntct=controller.getSelectedContact();
           boolean vbrhErr=controller.getVBRHError();
           boolean rrhErr2=controller.getRRHError();
           PageReference pageRef3=controller.sendForApproval();
           
       }
       
       public static testMethod void testSendForApprovalRebatesMPlan(){
           
           createData();               
           PageReference pageRefNew = Page.MPlanVendorApprovalPage;       
           Test.setCurrentPage(pageRefNew ); 
           VFCntrlr_EmailDeleteMarketingPlan controller = new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(mPlanRebates));             
           PageReference pageRef = new PageReference('/apex/MPlanVendorApprovalPage?CntctID='+mdfAssoCntct.Id);       
           Test.setCurrentPage(pageRef);        
           //List<MDF_Associated_Contact__c> mdfAContactList=controller.getMDFContacts(); 
           boolean dispForm=controller.getDisplayForm();
           //Pagereference selectedContact=controller.selectContact();
           String emailId=controller.getEmailId();
           controller.setEmailId('hanan.justin@ust-global.com');
           //String selectedCntct=controller.getSelectedContact();
           boolean vbrhErr=controller.getVBRHError();
           boolean rrhErr2=controller.getRRHError();
           PageReference pageRef3=controller.sendForApproval();
           
       }
       public static testMethod void testSendForApprovalRebatesMPlanErr(){
           
           createData();               
           PageReference pageRefNew = Page.MPlanVendorApprovalPage;       
           Test.setCurrentPage(pageRefNew ); 
           VFCntrlr_EmailDeleteMarketingPlan controller = new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(mPlanRebates));             
           PageReference pageRef = new PageReference('/apex/MPlanVendorApprovalPage?CntctID='+mdfAssoCntct.Id);       
           Test.setCurrentPage(pageRef);        
           //List<MDF_Associated_Contact__c> mdfAContactList=controller.getMDFContacts(); 
           boolean dispForm=controller.getDisplayForm();
           //Pagereference selectedContact=controller.selectContact();
           //String emailId=controller.getEmailId();
           //controller.setEmailId('hanan.justin@ust-global.com');
           //String selectedCntct=controller.getSelectedContact();
           boolean vbrhErr=controller.getVBRHError();
           boolean rrhErr2=controller.getRRHError();
           PageReference pageRef3=controller.sendForApproval();           
           
       }
       
       public static testMethod void testDeleteMPlan(){
           
        List<Associated_Programs_Vendors__c> apvNewLst=new List<Associated_Programs_Vendors__c>(); 
        
           createData();
           for(Integer i = 0; i<2; i++){        
               apvNewLst.add(
                   new Associated_Programs_Vendors__c(
                       Status__c='Pending',
                       MDF_Program__c=mdfProgram2.Id,
                       Package__c=packageObj.Id,
                       Vendor__c=vendorList[i].Id,
                       Marketing_Plan__c=MarketingPlanRec.Id,                       
                       Rate_Card_Price__c=mdfProgram2.Rate_Card_Price__c,
                       Invoice_Amount__c=98980,
                       //Budgeted_Price__c=mdfProgram.Rate_Card_Price__c,
                       //Modified Bahar, Ariff (20121811) - Budgeted Price must equal to (LE + CSMR + PUB + SMB). To Conform with VR_Distributed_Budgeted_Price_Match validation rule 
                       Budgeted_Price__c=0                      
                     )
                  );
           }              
           insert apvNewLst;  
                    
           PageReference pageRef = Page.marketingPlanDelete;       
           Test.setCurrentPage(pageRef);        
           VFCntrlr_EmailDeleteMarketingPlan controller = new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(MarketingPlanRec));        
           pageReference pageRef2=controller.deleteMPlan();   
           
       }
       
       public static testMethod void testBooleanMethods(){
           createData();
           
           Profile sysAdminProfile=[select id,name from Profile where name like 'System%' limit 1];  
           
           Marketing_Plan__c mplanVol=new Marketing_Plan__c();
           Marketing_Plan__c mplanRbt=new Marketing_Plan__c();  
           Marketing_Plan__c mplanNoAPV=new Marketing_Plan__c(); 
           
           mplanVol.name='mplanVol-001';
           mplanVol.Vendor__c=vendorList[2].Id;
           mplanVol.Fiscal_Quarter__c='FY12Q2';
           mplanVol.Region__c='APJ';
           mplanVol.Contract_Type__c='Volume Based';
           mplanVol.Contract_Status__c='Pending';
           insert mplanVol;
           
           mplanNoAPV.name='mplanNoAPV-001';
           mplanNoAPV.Vendor__c=subVendor.Id;
           mplanNoAPV.Fiscal_Quarter__c='FY12Q2';
           mplanNoAPV.Region__c='APJ';
           mplanNoAPV.Contract_Type__c='Volume Based';
           mplanNoAPV.Contract_Status__c='Pending';
           insert mplanNoAPV;          
           
           mplanRbt.name='mplanRbt-001';
           mplanRbt.Vendor__c=vendorList[2].Id;
           mplanRbt.Fiscal_Quarter__c='FY12Q2';
           mplanRbt.Region__c='APJ';
           mplanRbt.Contract_Type__c='Rebates';
           mplanRbt.Contract_Status__c='Pending';
           insert mplanRbt;
           
           
           User sysAdmin=new User(
                    Username='testuser'+ System.currentTimeMillis()+ '@dell.com',
                    Alias = 'test', 
                    Email='testuser@dell.com', 
                    FirstName='John', 
                    LastName='Doe', 
                    ProfileId =sysAdminProfile.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='John.doe'
               );
               
        
           PageReference pageRef = Page.MPlanVendorApprovalPage;       
           Test.setCurrentPage(pageRef);        
           VFCntrlr_EmailDeleteMarketingPlan controller = new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(mplanVol));        
           
           boolean dispForm=controller.getDisplayForm();
           boolean vbrhErr=controller.getVBRHError();                      
           
           
           
           System.runAs(sysAdmin){
               PageReference pageRef1 = Page.MPlanVendorApprovalPage;       
               Test.setCurrentPage(pageRef1);        
               VFCntrlr_EmailDeleteMarketingPlan controller1 = new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(mplanVol));
               boolean ProfileErr=controller1.getProfileErr();
           }
           
           PageReference pageRef2= Page.MPlanVendorApprovalPage;       
           Test.setCurrentPage(pageRef2);        
           VFCntrlr_EmailDeleteMarketingPlan controller2= new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(mplanRbt));
           boolean rrhErr=controller2.getRRHError();
                      
           System.runAs(sysAdmin){
               PageReference pageRef3= Page.MPlanVendorApprovalPage;       
               Test.setCurrentPage(pageRef3);        
               VFCntrlr_EmailDeleteMarketingPlan controller3= new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(mplanNoAPV));
               boolean NoAPVErr=controller3.getNoAPVErr();               
               boolean NoContactErr=controller3.getNoContactErr();
           }
           
           
            
       }
       
       public static testMethod void testVFCntrlr_VIPERCustomerPortal(){
           createData();
          
           PageReference pageRef = Page.VIPERCustomerPortalPage;       
           Test.setCurrentPage(pageRef);        
           VFCntrlr_VIPERCustomerPortal controllerALac = new VFCntrlr_VIPERCustomerPortal(new ApexPages.StandardController(mPlanAlaC));        
           PageReference pageRef1=controllerALac.actionFn();
           VFCntrlr_VIPERCustomerPortal controllerVolumeBased = new VFCntrlr_VIPERCustomerPortal(new ApexPages.StandardController(MarketingPlanRec));      
           PageReference pageRef2=controllerVolumeBased.actionFn();
           VFCntrlr_VIPERCustomerPortal controllerRebates = new VFCntrlr_VIPERCustomerPortal(new ApexPages.StandardController(mPlanRebates));        
           PageReference pageRef3=controllerRebates.actionFn();
           
       }
       
       //R12.7
       
       public static testMethod void testGetSetMethods(){
           createData();
      
           Task newTask=new Task();
           newTask.OwnerId=UserInfo.getUserId();
           newTask.Type='Internal Email';
           newTask.Status='In Progress';
           newTask.Subject='Product manager approval required';
           newTask.ActivityDate=System.today();
           newTask.Priority='High';
           PageReference pageRef = new PageReference('/apex/MPlanVendorApprovalPage?Id='+MarketingPlanRec.Id);       
           Test.setCurrentPage(pageRef);
           VFCntrlr_EmailDeleteMarketingPlan controller= new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(MarketingPlanRec));
          
           Boolean bol1=controller.getSignSOW();
           controller.setSignSOW(true);
           Boolean bol2=controller.getApproval();
           controller.setApproval(true);
           Task tsk=controller.getTask();
           controller.setTask(tsk);
           
        }
        
        public static testMethod void testSendSignedSOW(){
           createData();
         
           Attachment attachmentObj=new Attachment(); 
           List<VFCntrlr_EmailDeleteMarketingPlan.productManager> pdctMgrList=new List<VFCntrlr_EmailDeleteMarketingPlan.productManager>(); 
           VFCntrlr_EmailDeleteMarketingPlan.productManager pdtMgr=new VFCntrlr_EmailDeleteMarketingPlan.productManager(true,mdfPdtAssoCntct);
           pdtMgr.selected=true;
           pdctMgrList.add(pdtMgr); 
           
           agreement.Marketing_Plan__c = MarketingPlanRec.Id;
           agreement.Name = 'test agreement';
           //agreement.mdf_contact__c = mdfContact.Id;           
           insert agreement;
           
           attachmentObj.Name = 'echosignDoc.Pdf';
           attachmentObj.ParentId = agreement.Id;
           attachmentObj.body= Blob.valueOf('Some Text');
           insert attachmentObj;
           
           
           List<VFCntrlr_EmailDeleteMarketingPlan.AttachmentWrapperCls> attachmentIteratedList=new List<VFCntrlr_EmailDeleteMarketingPlan.AttachmentWrapperCls>(); 
           VFCntrlr_EmailDeleteMarketingPlan.AttachmentWrapperCls wrapperElt=new VFCntrlr_EmailDeleteMarketingPlan.AttachmentWrapperCls(attachmentObj,true);
                  
           attachmentIteratedList.add(wrapperElt);
            
           PageReference pref =new PageReference('/apex/ProductManagerUtilsPage?Id='+MarketingPlanRec.Id+'&param2=signSow');
           
           Test.setCurrentPage(pref);
           
           VFCntrlr_EmailDeleteMarketingPlan controller= new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(MarketingPlanRec)); 
           Boolean sow=controller.getSignSOW();
           controller.setSignSOW(true);
           
           List<VFCntrlr_EmailDeleteMarketingPlan.AttachmentWrapperCls> listElt=controller.getAttachmentList();
           controller.setAttachmentList(attachmentIteratedList); 
           
           List<VFCntrlr_EmailDeleteMarketingPlan.productManager> pmCntctlist=controller.getProductManagers();
           controller.setProductManagers(pdctMgrList);
           
           PageReference pref1=controller.sendSignedSOW();
        
        } 
        
        public static testMethod void testSendForProductManagerApproval(){
            createData();
            List<Associated_Programs_Vendors__c> apvNewLst=new List<Associated_Programs_Vendors__c>(); 
           Task newTask=new Task();
           newTask.OwnerId=UserInfo.getUserId();
           newTask.Type='Internal Email';
           newTask.Status='In Progress';
           newTask.Subject='Product manager approval required';
           newTask.ActivityDate=System.today();
           newTask.Priority='High';
           
           
           for(Integer i = 0; i<1; i++){        
               apvNewLst.add(
                   new Associated_Programs_Vendors__c(
                       Status__c='Pending',
                       MDF_Program__c=mdfProgram2.Id,
                       Package__c=packageObj.Id,
                       Vendor__c=MarketingPlanRec.Vendor__c,
                       Marketing_Plan__c=MarketingPlanRec.Id,
                       //recordTypeId=apvRT.Id,
                       Rate_Card_Price__c=mdfProgram2.Rate_Card_Price__c,
                       Budgeted_Price__c=mdfProgram2.Rate_Card_Price__c,
                       Invoice_Amount__c=98980,
                       Contract_Status_Reason__c='abcd'
                       //Business_Segment__c='CSMR'
                     )
                  );
           }              
           insert apvNewLst;
           
           
           Attachment attachmentObj=new Attachment(); 
           List<VFCntrlr_EmailDeleteMarketingPlan.productManager> pdctMgrList=new List<VFCntrlr_EmailDeleteMarketingPlan.productManager>(); 
           VFCntrlr_EmailDeleteMarketingPlan.productManager pdtMgr=new VFCntrlr_EmailDeleteMarketingPlan.productManager(true,mdfPdtAssoCntct);
           pdtMgr.selected=true;
           pdctMgrList.add(pdtMgr); 
           
           agreement.Marketing_Plan__c = MarketingPlanRec.Id;
           agreement.Name = 'test agreement';
           //agreement.mdf_contact__c = mdfContact.Id;           
           insert agreement;
           
           attachmentObj.Name = 'echosignDoc.Pdf';
           attachmentObj.ParentId = agreement.Id;
           attachmentObj.body= Blob.valueOf('Some Text');
           insert attachmentObj;
           
           
           List<VFCntrlr_EmailDeleteMarketingPlan.AttachmentWrapperCls> attachmentIteratedList=new List<VFCntrlr_EmailDeleteMarketingPlan.AttachmentWrapperCls>(); 
           VFCntrlr_EmailDeleteMarketingPlan.AttachmentWrapperCls wrapperElt=new VFCntrlr_EmailDeleteMarketingPlan.AttachmentWrapperCls(attachmentObj,true);
                  
           attachmentIteratedList.add(wrapperElt);
            
           PageReference pref =new PageReference('/apex/ProductManagerUtilsPage?Id='+MarketingPlanRec.Id+'&param2=approval');
           
           Test.setCurrentPage(pref);
           
           VFCntrlr_EmailDeleteMarketingPlan controller= new VFCntrlr_EmailDeleteMarketingPlan(new ApexPages.StandardController(MarketingPlanRec)); 
           Boolean sow=controller.getApproval();
           controller.setApproval(true);
           Task tsk=controller.getTask();
           controller.setTask(newTask); 
           
           List<VFCntrlr_EmailDeleteMarketingPlan.productManager> pmCntctlist=controller.getProductManagers();
           controller.setProductManagers(pdctMgrList);
           
           
           PageReference pref1=controller.sendForProductManagerApproval();
           
            
        }
       
       
       
}