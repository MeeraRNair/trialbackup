@isTest
private class CustomerPortal_VB_AC_Test {
    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static Marketing_Plan__c mp = new Marketing_Plan__c();
    public static Marketing_Plan__c mp_noncogs = new Marketing_Plan__c();
    public static List <Associated_Programs_Vendors__c> apvList = new List <Associated_Programs_Vendors__c>();
     public static List <Package__c> packgList = new List <Package__c>();
    public static List <MDF_Program__c> mdfpgmlist = new List <MDF_Program__c>{};
    public static List <Marketing_Plan__c> mplist = new List <Marketing_Plan__c>{};
    public static Map <String,RecordType> vendorRTmap = new Map <String,RecordType>();
   public static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like'%MDF Program Owners%' limit 1];
    public static User u1 = new User();
    public static Map <String,RecordType> mpRTmap = new Map <String,RecordType>();
    
    public static void createdata(){
    TriggerExecutionController.setSkipAllTriggers(true);
        
        for(RecordType rtElt:[Select Name,Id From RecordType where sObjectType='Vendor__c']){   
                     vendorRTmap.put(rtElt.Name,rtElt);            
        }
        
        for(RecordType rtElt:[Select Name,Id From RecordType where sObjectType='Marketing_Plan__c']){   
                     mpRTmap.put(rtElt.Name,rtElt);            
        }
        
        u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
        insert u1;
        
        //creating parent vendor
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
        parentVendor.Partner_Status__c='Active';
        parentVendor.recordTypeId=vendorRTmap.get('Vendor').Id;       
        insert parentVendor;
        
        // creating a sub vendor
        subvendor.Parent_Vendor__c=parentVendor.Id;
       //subvendor.Name='TestSubVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subvendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
        subvendor.Partner_Status__c='Active';
        subvendor.Partner_Type__c='Value';
        subvendor.Product_Category__c='Networking';
        subvendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
        subvendor.recordTypeId= vendorRTmap.get('Sub Vendor').Id;     
        insert subvendor;
        
        // creating an MP
        mp.name='MP-001';
        mp.Vendor__c=subvendor.Id;
        mp.Fiscal_Quarter__c='FY12Q1';
        mp.Region__c='EMEA';
        mp.Contract_Type__c='Volume Based';
        mp.RecordTypeId=mpRTmap.get('Volume Based Marketing Plan').Id;
        mplist.add(mp);      
        
        mp_noncogs.name='MP-002';
        mp_noncogs.Vendor__c=subvendor.Id;
        mp_noncogs.Fiscal_Quarter__c='FY12Q1';
        mp_noncogs.Region__c='EMEA';
        mp_noncogs.Contract_Type__c='Ala Carte';
        mp_noncogs.RecordTypeId=mpRTmap.get('Ala Carte Marketing Plan').Id; 
        mplist.add(mp_noncogs);     
        insert mplist;
        
         for(Integer i=0;i<4;i++){
            MDF_Program__c pgm = new MDF_Program__c();
            pgm.Name = 'Name'+i;
            pgm.Program_Owner__c=u1.Id;
            pgm.POP_Owner__c=u1.Id;
            pgm.Fiscal_Quarter__c='FY12Q1';
            mdfpgmlist.add(pgm);
        }
        insert mdfpgmlist;
        
        //creating packages
        //The first package is related to Marketing Plan with Record Type - Volume based &
        //The secocnd package is related to Marketing Plan with Record Type - Ala Carte
        for(Integer i=0;i<2;i++){
            Package__c pkg = new Package__c();
            pkg.Name = 'pkg'+i;
            pkg.Marketing_Plan__c = mplist[i].Id;
            pkg.Package_Price_del__c = 1234;
            pkg.Status__c = 'Submitted for Review';
            //insert pkg;
            packgList.add(pkg);         
         }
         insert packgList;
         
        for(Integer i=0;i<1;i++){
            Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
            apv.Marketing_Plan__c = mpList[0].Id;
            apv.MDF_Program__c = mdfpgmlist[0].Id;      
            apv.Status__c = 'Submitted for Review';     
            apv.Accounting_Treatment__c = 'COGS Offset';
            apv.Vendor__c = subvendor.Id; 
            //mpapvList.add(apv);         
            apvList.add(apv);
        }
          for(Integer i=0;i<1;i++){
            Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
            apv.Marketing_Plan__c = mpList[1].Id;
            apv.MDF_Program__c = mdfpgmlist[1].Id;     
            apv.Status__c = 'Submitted for Review';     
            apv.Accounting_Treatment__c = 'COGS Offset';
            apv.Vendor__c = subvendor.Id; 
            //noncogsapvList.add(apv);         
            apvList.add(apv); 
        }
         
         for(Integer i=0;i<1;i++){
            Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
            apv.Marketing_Plan__c = mpList[0].Id;
            apv.MDF_Program__c = mdfpgmlist[2].Id;     
            apv.Status__c = 'Submitted for Review';     
            apv.Accounting_Treatment__c = 'COGS Offset';
            apv.Vendor__c = subvendor.Id; 
            apv.Package__c= packgList[0].Id;
            //mpapvListpkg.add(apv); 
            apvList.add(apv); 
         }
         for(Integer i=0;i<1;i++){
            Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
            apv.Marketing_Plan__c = mpList[1].Id;
            apv.MDF_Program__c = mdfpgmlist[3].Id;     
            apv.Status__c = 'Submitted for Review';     
            apv.Accounting_Treatment__c = 'COGS Offset';
            apv.Vendor__c = subvendor.Id; 
            apv.Package__c= packgList[1].Id;
            apvList.add(apv); 
         }
         insert apvList;
    }
    static testMethod void myUnitTest1() {
       createdata();
       
       //Cogs MP
       PageReference  pr=new PageReference('apex/CustomerPortal_MarketingPlan?id='+mpList[0].Id);
       Test.setCurrentPage(pr);
       VFCntrlr_CustomerPortal_MarketingPlan mpcntrlr = new VFCntrlr_CustomerPortal_MarketingPlan(new ApexPages.StandardController(mpList[0]));
       Test.startTest();
       mpcntrlr.addBillingContact();
       mpcntrlr.addPrimaryContact();
       mpcntrlr.addpurchaseorder();
       mpcntrlr.savepruchaseorder();
       
       mpcntrlr.accept_decline_APV();
       
       mpList[0].Primary_Marketing_Contact_Name__c='hi';
       mpList[0].Billing_Contact_Name__c='hi';
       update mpList[0];
       for(Associated_Programs_Vendors__c apvs:mpcntrlr.apvList){
        apvs.APV_Status__c='Accept';
       }
       
       mpcntrlr.accept_decline_APV();
       for(Package__c pkg:mpcntrlr.pkgList){
        pkg.PKG_Status__c='Decline';
       }
       
       mpcntrlr.savePKG();
       System.debug('hi->'+mpcntrlr.apvbuttonlist);
       mpcntrlr.acceptallapv();
       //mpcntrlr.rejectallapv();
       mpcntrlr.cancelfn();
       mpcntrlr.getApvList();
       mpcntrlr.getPkgList();
       mpcntrlr.getVBHLineItemList();
       Test.stopTest();
       TriggerExecutionController.setSkipAllTriggers(false);
    }
    
       
    static testMethod void myUnitTest2() {
         TriggerExecutionController.setSkipAllTriggers(true);
        createdata();  
       //AC MP
      PageReference  pr2=new PageReference('apex/CustomerPortal_MarketingPlan?id='+mpList[1].Id);
       Test.setCurrentPage(pr2);
       VFCntrlr_CustomerPortal_MP_AlaCarte mpcntrlr2 = new VFCntrlr_CustomerPortal_MP_AlaCarte(new ApexPages.StandardController(+mpList[1]));
       Test.startTest();
       mpcntrlr2.addBillingContact();
       mpcntrlr2.addPrimaryContact();
       mpcntrlr2.addpurchaseorder();
       mpcntrlr2.savepruchaseorder();
       
       mpList[1].Primary_Marketing_Contact_Name__c='hi';
       mpList[1].Billing_Contact_Name__c='hi';
       update mpList[1];
       
       for(Associated_Programs_Vendors__c apvs:mpcntrlr2.apvList){
        apvs.APV_Status__c='Accept';
       }
       mpcntrlr2.saveAPV();
       for(Package__c pkg:mpcntrlr2.pkgList){
        pkg.PKG_Status__c='Decline';
       }
       mpcntrlr2.savePKG();
      System.debug('hi2->'+mpcntrlr2.apvListbutton);
       mpcntrlr2.rejectallapv();
       mpcntrlr2.cancelfn();
       mpcntrlr2.getApvList();
       mpcntrlr2.getpkgList();
       Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
     }
     
}