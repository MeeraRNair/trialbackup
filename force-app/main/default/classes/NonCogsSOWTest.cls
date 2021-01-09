@isTest
private class NonCogsSOWTest { 
   /* public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static Marketing_Plan__c mp_noncogs = new Marketing_Plan__c();
    public static RecordType mpRTAC = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Ala Carte Marketing Plan'];
    public static List <MDF_Program__c> mdfpgmlist = new List <MDF_Program__c>{};
    //public static List <Associated_Programs_Vendors__c> mpapvList = new List <Associated_Programs_Vendors__c>();
    public static RecordType vendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Vendor'];
    public static RecordType subvendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Sub Vendor'];
    public static List <Package__c> pkgnoncogsList = new List <Package__c>();
    public static List <Associated_Programs_Vendors__c> noncogsapvListpkg = new List <Associated_Programs_Vendors__c>();
    public static List <MDF_Program__c> mdfpgmlist4 = new List <MDF_Program__c>{};
    public static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like'%MDF Program Owners%' limit 1];
    public static User u1 = new User();
    
    public static void createdata(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
        insert u1;
        
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
        parentVendor.Partner_Status__c='Active';
        parentVendor.recordTypeId=vendorRT.Id;
        
        insert parentVendor;
        
        // creating a sub vendor
        subvendor.Parent_Vendor__c=parentVendor.Id;
       //subvendor.Name='TestSubVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subvendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
        subvendor.Partner_Status__c='Active';
        subvendor.Partner_Type__c='Value';
        subvendor.Product_Category__c='Networking';
        subvendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
        subvendor.recordTypeId= subvendorRT.Id;
        subvendor.Ala_Carte_SOW_Template__c='Default';
        
        insert subvendor;
        
        mp_noncogs.name='MP-002';
        mp_noncogs.Vendor__c=subvendor.Id;
        mp_noncogs.Fiscal_Quarter__c='FY12Q1';
        mp_noncogs.Region__c='EMEA';
        mp_noncogs.Contract_Type__c='Ala Carte';
        mp_noncogs.RecordTypeId=mpRTAC.Id;  
           
        insert mp_noncogs; 
        
        for(Integer i=0;i<2;i++){
            MDF_Program__c pgm = new MDF_Program__c();
            pgm.Name = 'Name'+i;
            pgm.Program_Owner__c=u1.Id;
            pgm.POP_Owner__c=u1.Id;
            mdfpgmlist.add(pgm);
        }
        insert mdfpgmlist;
        
         for(Integer i=0;i<2;i++){
            MDF_Program__c pgm = new MDF_Program__c();
            pgm.Name = 'Name'+i+i+i+i;
            pgm.Program_Owner__c=u1.Id;
            pgm.POP_Owner__c=u1.Id;
            mdfpgmlist4.add(pgm);
        }
        insert mdfpgmlist4;
          
        for(Integer i=0;i<2;i++){
            Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
            apv.Marketing_Plan__c = mp_noncogs.Id;
            apv.MDF_Program__c = mdfpgmlist[i].Id;      
            apv.Status__c = 'Accepted';     
            apv.Accounting_Treatment__c = 'COGS Offset';
            apv.Vendor__c = subvendor.Id; 
            apv.LE__c=i;
            apv.CSMR__c=i;
            apv.SMB__c=i;
            apv.PUB__c=i;
            mpapvList.add(apv);         
        
        }
        insert mpapvList;
         
        for(Integer i=0;i<2;i++){
            Package__c pkg = new Package__c();
            pkg.Name = 'pkg'+i;
            pkg.Marketing_Plan__c = mp_noncogs.Id;
            pkg.Package_Price_del__c = 1234;
            pkg.Status__c = 'Accepted';
            //insert pkg;
            pkgnoncogsList.add(pkg);            
         }
         insert pkgnoncogsList;
         
         
        for(Integer i=0;i<2;i++){
            noncogsapvListpkg.add(new Associated_Programs_Vendors__c(Marketing_Plan__c = mp_noncogs.Id,
            MDF_Program__c = mdfpgmlist4[i].Id,
            Status__c = 'Accepted',
            Accounting_Treatment__c = 'COGS Offset',
            Vendor__c = subvendor.Id));     
         }insert noncogsapvListpkg;
         
    }
    
    static testMethod void myUnitTest() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
        createdata();
        PageReference  pr=new PageReference('apex/SOW_AlaCarte_OEM');
        Test.setCurrentPage(pr);
        VFCntrlr_SOWAlaCarteOEM cntrlr = new VFCntrlr_SOWAlaCarteOEM(new ApexPages.StandardController(mp_noncogs));
        cntrlr.getAPVList();
        cntrlr.getDisplayDetails();
        cntrlr.getmdfContact();
        
        PageReference  pr2=new PageReference('apex/SOWNonCogs');
        Test.setCurrentPage(pr2);
       
        PageReference pageRef = Page.SOWAlaCarteIngramMicro;
        Test.setCurrentPage(pageRef);
        VFCntlr_SOWAlaCarteIngramMicro controller1 = new VFCntlr_SOWAlaCarteIngramMicro(new ApexPages.StandardController(mp_noncogs));
        controller1.getApvList();
        controller1.getDisplayDetails();
        controller1.getbudgetPrice();       
    }*/
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
       RecordType marketingPlanRT=[Select Name, Id From RecordType where sObjectType='Marketing_Plan__c' and name='Ala Carte Marketing Plan' limit 1];
       
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
        MarketingPlanRec.Contract_Type__c='Ala Carte';
        MarketingPlanRec.RecordTypeId=marketingPlanRT.Id;
        MarketingPlanRec.invoice__c=invoiceObj.Id;
        MarketingPlanRec.Contract_Status__c='Signed';
        insert MarketingPlanRec;
        
        
        
                   
        //for(Integer i = 0; i<3; i++){        
           apvList.add(
               new Associated_Programs_Vendors__c(
                   MDF_Program__c=mdfProgram.Id,
                   Vendor__c=vendorList[0].Id,
                   Marketing_Plan__c=MarketingPlanRec.Id,
                   
                   Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
                   Budgeted_Price__c=mdfProgram.Rate_Card_Price__c,
                   Invoice_Amount__c=98980,
                    Status__c='Accepted',
                    POP_Status__C='Executed'
                 )
              );
       //}              
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
       
       createdata();
        PageReference  pr=new PageReference('apex/SOW_AlaCarte_OEM');
        Test.setCurrentPage(pr);
        VFCntrlr_SOWAlaCarteOEM cntrlr = new VFCntrlr_SOWAlaCarteOEM(new ApexPages.StandardController(MarketingPlanRec));
        cntrlr.getAPVList();
        cntrlr.getDisplayDetails();
        cntrlr.getmdfContact();
        
        PageReference  pr2=new PageReference('apex/SOWNonCogs');
        Test.setCurrentPage(pr2);
   }
}