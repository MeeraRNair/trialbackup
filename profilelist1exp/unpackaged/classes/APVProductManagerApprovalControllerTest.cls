@isTest
private class APVProductManagerApprovalControllerTest{     
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
    
    
    
    public static void createData(){ 
       /*       
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();    
          
       RecordType marketingPlanRT=[Select Name, Id From RecordType where sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       
       RecordType partnerCntctRT=[Select Name, Id From RecordType where sObjectType='MDF_Contact__c' and name='Partner Contact' limit 1];

       
       RecordType apvRT=[Select Name, Id From RecordType where sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];
       
       profiles=[select id,name from Profile where name like  'MDF Program Owners' limit 1];
       
       RecordType pdctMgrContact=[Select Name, Id From RecordType where sObjectType='MDF_Contact__c' and name='Product Manager Contact' limit 1];
        
               
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }
       
       */
       
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();              
       RecordType marketingPlanRT=null;       
       RecordType partnerCntctRT = null;       
       RecordType apvRT = null;       
       RecordType pdctMgrContact= null;
                     
       List<RecordType> recordTypes = [Select Name, Id, sObjectType From RecordType where 
           (sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan') OR
           (sObjectType='MDF_Contact__c' and name='Partner Contact') OR
           (sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP') OR
           (sObjectType='MDF_Contact__c' and name='Product Manager Contact') OR
           (sObjectType='vendor__c')];
       
       for(RecordType recordType: recordTypes ){
           
           if(recordType.sObjectType=='Marketing_Plan__c' && recordType.name=='Volume Based Marketing Plan')           
               marketingPlanRT = recordType;
           else if(recordType.sObjectType=='MDF_Contact__c' && recordType.name=='Partner Contact')
               partnerCntctRT = recordType;
           else if(recordType.sObjectType=='Associated_Programs_Vendors__c' && recordType.name=='Vendor Association MP')
               apvRT = recordType;
           else if(recordType.sObjectType=='MDF_Contact__c' && recordType.name=='Product Manager Contact')
               pdctMgrContact = recordType;
           else 
               vendorRT.put(recordType.Name,recordType);         
               
       }
       
       
       profiles=[select id,name from Profile where name like  'MDF Program Owners' limit 1];
       
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;       
       insert parentVendor;
       
       for(Integer i = 0; i<3; i++){
           vendorList.add(
               new Vendor__c(
                   Parent_Vendor__c=parentVendor.Id,
                   Name='TestSubVendor'+i,
                   Partner_Status__c='Active',
                   Partner_Type__c='Value',
                   Product_Category__c='Networking',
                   Contract_Types_eligible_for__c='Volume Based,Ala Carte,Rebates',
                   recordTypeId=vendorRT.get('Sub Vendor').Id
               )
           );
       }
       
       insert vendorList;
       
       subVendor.Parent_Vendor__c=parentVendor.Id;
       //subVendor.Name='TestSubVendorXX'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
       subVendor.Partner_Status__c='Active';
       subVendor.Partner_Type__c='Value';
       subVendor.Product_Category__c='Networking';
       subVendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte,Rebates';
       subVendor.recordTypeId=vendorRT.get('Sub Vendor').Id;
       insert subVendor;      
             

               
        for(Integer i = 0; i<3; i++){           
            users.add(
                new User(
                    Username='testuser'+i + System.currentTimeMillis()+'@dell.com',
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
        mdfProgram.Program_Status__c='Pending';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q1';
        mdfProgram.OwnerId=users[2].id;
        mdfProgram.Rate_Card_Price__c=12356;
        mdfProgram.Region__c='Americas';        
        insert mdfProgram;         
                
        
        MarketingPlanRec.name='MP-001';
        MarketingPlanRec.Vendor__c=vendorList[0].Id;
        MarketingPlanRec.Fiscal_Quarter__c='FY12Q2';
        MarketingPlanRec.Region__c='APJ';
        MarketingPlanRec.Contract_Type__c='Volume Based';
        MarketingPlanRec.RecordTypeId=marketingPlanRT.Id;
        MarketingPlanRec.invoice__c=invoiceObj.Id;
        MarketingPlanRec.Contract_Status__c='Pending';
        MarketingPlanRec.Product_Manager_Approval_Status__c='Submitted for product manager review';
        insert MarketingPlanRec;

        Associated_Programs_Vendors__c apvElt;


    for(Integer i = 0; i<3; i++){  
        apvElt=new Associated_Programs_Vendors__c(
            Status__c='Pending',
            MDF_Program__c=mdfProgram.Id,
            Package__c=packageObj.Id,
            Vendor__c=vendorList[i].Id,
            Marketing_Plan__c=marketingPlanRec.Id,
            recordTypeId=apvRT.Id,
            Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
            Budgeted_Price__c=mdfProgram.Rate_Card_Price__c,
            Invoice_Amount__c=98980,
            Product_Manager_Approval__c='none'
        );
        if(i==2){
            apvElt.Product_Manager_Approval__c='Approved by product Manager';
        }
        apvList.add(apvElt);
    }              
    insert apvList;        

        
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
          
      }
      
      

    
    public static testMethod void testConctructor(){ 
       createData();
       PageReference pr=new PageReference('/apexAPVProductManagerApproval?Id='+MarketingPlanRec.id);
       Test.setCurrentPage(pr);       
       APVProductManagerApprovalController controller = new APVProductManagerApprovalController(new ApexPages.StandardController(MarketingPlanRec)); 
       controller.getReviewedAPVRecs();
       controller.getToBReviwedList();
       controller.setToBReviwedList(apvList);
//controller.getMessage(); 
       controller.getNoAPVErr();
        controller.getToBReviewed();                
        Controller.getMplanErr();      
    
    } 
    
    public static testMethod void testActionMethods(){  
           createData();
           Associated_Programs_Vendors__c apv=new Associated_Programs_Vendors__c();
           List<Associated_Programs_Vendors__c> apvList2=new List<Associated_Programs_Vendors__c>();
           for(integer i=0;i<apvList.size();i++){
               apv=apvList[i];
               apv.Product_Manager_Approval__c='Approved by product manager';
               apvList2.add(apv);
           }
       PageReference pr=new PageReference('/apexAPVProductManagerApproval?Id='+MarketingPlanRec.id);
       Test.setCurrentPage(pr);       
       APVProductManagerApprovalController controller = new APVProductManagerApprovalController(new ApexPages.StandardController(MarketingPlanRec)); 
       controller.getReviewedAPVRecs();
       controller.getToBReviwedList(); 
       
       controller.setToBReviwedList(apvList2);
 
       controller.getNoAPVErr();
        controller.getToBReviewed();                
        Controller.getMplanErr();      
Controller.updateAPVs();

        
    }
    
    public static testMethod void testActionMethods2(){  
           createData();
           Associated_Programs_Vendors__c apv=new Associated_Programs_Vendors__c();
           List<Associated_Programs_Vendors__c> apvList2=new List<Associated_Programs_Vendors__c>();
           for(integer i=0;i<apvList.size();i++){
               apv=apvList[i];
               apv.Product_Manager_Approval__c='Approved by product manager';
               apvList2.add(apv);
           }
       PageReference pr=new PageReference('/apexAPVProductManagerApproval?Id='+MarketingPlanRec.id);
       Test.setCurrentPage(pr);       
       APVProductManagerApprovalController controller = new APVProductManagerApprovalController(new ApexPages.StandardController(MarketingPlanRec)); 
       controller.getReviewedAPVRecs();
       controller.getToBReviwedList(); 
       
       controller.setToBReviwedList(apvList2);
 
       controller.getNoAPVErr();
        controller.getToBReviewed();                
        Controller.getMplanErr();      

Controller.AcceptAll();

        
    }
    
    public static testMethod void testActionMethods3(){  
           createData();
           Associated_Programs_Vendors__c apv=new Associated_Programs_Vendors__c();
           List<Associated_Programs_Vendors__c> apvList2=new List<Associated_Programs_Vendors__c>();
           for(integer i=0;i<apvList.size();i++){
               apv=apvList[i];
               apv.Product_Manager_Approval__c='Approved by product manager';
               apvList2.add(apv);
           }
       PageReference pr=new PageReference('/apexAPVProductManagerApproval?Id='+MarketingPlanRec.id);
       Test.setCurrentPage(pr);       
       APVProductManagerApprovalController controller = new APVProductManagerApprovalController(new ApexPages.StandardController(MarketingPlanRec)); 
       controller.getReviewedAPVRecs();
       controller.getToBReviwedList(); 
       
       controller.setToBReviwedList(apvList2);
 
       controller.getNoAPVErr();
        controller.getToBReviewed();                
        Controller.getMplanErr();      

COntroller.DeclineAll();
        
    }
    
}