@isTest
private class CustomerPortal_HC_Rebate_Test {
    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static Marketing_Plan__c mp_rebates = new Marketing_Plan__c();
    public static Marketing_Plan__c mp_headcount = new Marketing_Plan__c();
    public static List <Marketing_Plan__c> mp_List = new List <Marketing_Plan__c>();
    public static List <Associated_Programs_Vendors__c> hcapvList = new List <Associated_Programs_Vendors__c>();
    public static List <Associated_Programs_Vendors__c> hcapvListpkg = new List <Associated_Programs_Vendors__c>();
    public static List <Associated_Programs_Vendors__c> apv_List = new List <Associated_Programs_Vendors__c>();
    public static List <Package__c> pkghcList = new List <Package__c>();
    public static RecordType vendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Vendor'];
    public static RecordType subvendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Sub Vendor'];
    public static RecordType mpRTRB = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Rebates Marketing Plan'];
    public static RecordType mpRTHC = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Headcount Marketing Plan'];
    public static List <MDF_Program__c> mdfpgmlist5 = new List <MDF_Program__c>{};
    public static List <MDF_Program__c> mdfpgmlist6 = new List <MDF_Program__c>{};
    public static List <MDF_Program__c> mdfpgm_list = new List <MDF_Program__c>{};
    public static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like'%MDF Program Owners%' limit 1];
    public static User u1 = new User();
    
    public static void createdata(){
         TriggerExecutionController.setSkipAllTriggers(true);
        u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
        insert u1;
        
        //creating parent vendor
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
        insert subvendor;
        
        mp_rebates.name='MP-003';
        mp_rebates.Vendor__c=subvendor.Id;
        mp_rebates.Fiscal_Quarter__c='FY12Q1';
        mp_rebates.Region__c='EMEA';
        mp_rebates.Contract_Type__c='Rebates';
        mp_rebates.RecordTypeId=mpRTRB.Id;      
        //insert mp_rebates; 
        mp_List.add(mp_rebates);
        
        mp_headcount.name='MP-004';
        mp_headcount.Vendor__c=subvendor.Id;
        mp_headcount.Fiscal_Quarter__c='FY12Q1';
        mp_headcount.Region__c='EMEA';
        mp_headcount.Contract_Type__c='Headcount';
        mp_headcount.RecordTypeId=mpRTHC.Id;      
        //insert mp_headcount;
        mp_List.add(mp_headcount);
        insert mp_List;
        for(Integer i=0;i<6;i++){
            MDF_Program__c pgm = new MDF_Program__c();
            pgm.Name = 'Name'+i+i+i+i+i;
            mdfpgmlist5.add(pgm);
            pgm.Program_Owner__c=u1.Id;
            pgm.POP_Owner__c=u1.Id;
            pgm.Fiscal_Quarter__c='FY12Q1';
            mdfpgm_list.add(pgm);
        }
        //insert mdfpgmlist5;
        
        insert mdfpgm_list;
        
        
         for(Integer i=0;i<1;i++){
            Package__c pkg = new Package__c();
            pkg.Name = 'pkg'+i;
            pkg.Marketing_Plan__c = mp_List[1].Id;
            pkg.Package_Price_del__c = 1234;
            pkg.Status__c = 'Submitted for Review';
            //insert pkg;
            pkghcList.add(pkg);         
         }
         
         insert pkghcList;
         
         for(Integer i=0;i<1;i++){
            Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
            apv.Marketing_Plan__c = mp_List[1].Id;
            apv.MDF_Program__c = mdfpgm_list[0].Id;     
            apv.Status__c = 'Submitted for Review';     
            apv.Accounting_Treatment__c = 'COGS Offset';
            apv.Vendor__c = subvendor.Id; 
            //hcapvList.add(apv);   
            apv_List.add(apv);  
        
        }//insert hcapvList;
        
         
         for(Integer i=0;i<1;i++){
            Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
            apv.Marketing_Plan__c = mp_List[1].Id;
            apv.MDF_Program__c = mdfpgm_list[3].Id;     
            apv.Status__c = 'Submitted for Review';     
            apv.Accounting_Treatment__c = 'COGS Offset';
            apv.Vendor__c = subvendor.Id; 
            apv.Package__c= pkghcList[i].Id;
            //hcapvListpkg.add(apv);  
            apv_List.add(apv);  
         }//insert hcapvListpkg;
         insert apv_List;
    }
    static testMethod void myUnitTest1() {
       createdata();
       //HeadCount MP
       PageReference  pr4=new PageReference('apex/CustomerPortal_MarketingPlan_HeadCount?id='+mp_List[1].Id);
       Test.setCurrentPage(pr4);
       VFCntrlr_CustomerPortal_MPlan_HeadCount mpcntrlr4 = new VFCntrlr_CustomerPortal_MPlan_HeadCount(new ApexPages.StandardController(mp_List[1]));
       Test.startTest();
       mpcntrlr4.addBillingContact();
       mpcntrlr4.addPrimaryContact();
       mpcntrlr4.addpurchaseorder();
       mpcntrlr4.savepruchaseorder();
       mpcntrlr4.saveAPV();
       
       for(Package__c pkg:mpcntrlr4.pkgList){
        pkg.PKG_Status__c='accept';
       }
       mpcntrlr4.savePKG();
       mpcntrlr4.acceptallAPV();
       mpcntrlr4.rejectallapv();
       
       mp_List[1].Billing_Contact_Name__c='hi';
       mp_List[1].Primary_Marketing_Contact_Name__c='hi';
       update mp_List[1];
       
       //mpcntrlr4.saveAPV();
       
       for(Associated_Programs_Vendors__c apvs:mpcntrlr4.apvList){
        apvs.APV_Status__c='decline';
       }
       mpcntrlr4.saveAPV();
       //mpcntrlr4.savePKG();
       //mpcntrlr4.acceptallAPV();
       mpcntrlr4.rejectallapv();
       mpcntrlr4.getApvList();
       mpcntrlr4.getpkgList();
       mpcntrlr4.cancelfn(); 
       //rebates MP
       Test.StopTest();
       TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void myUnitTest2(){
       
    createdata();
    PageReference  pr3=new PageReference('apex/CustomerPortal_MarketingPlan_Rebates?id='+mp_List[0].Id);
       Test.setCurrentPage(pr3);
       VFCntrlr_CustomerPortal_MPlan_Rebates mpcntrlr3 = new VFCntrlr_CustomerPortal_MPlan_Rebates(new ApexPages.StandardController(mp_List[0]));
       Test.StartTest();
       mpcntrlr3.accept_decline_MP();
       mpcntrlr3.myMPPlan.MP_Status__c='Accept';
       mpcntrlr3.saveStatusrebates();
       mpcntrlr3.addBillingContact();
       mpcntrlr3.addPrimaryContact();
       mpcntrlr3.addpurchaseorder();
       mpcntrlr3.savepruchaseorder();
       mpcntrlr3.getRebateLineItemList();
       mpcntrlr3.cancelfn();
       mpcntrlr3.accept_decline_MP();
       mpcntrlr3.myMPPlan.MP_Status__c='Decline';
       mpcntrlr3.saveStatusrebates();          
       Test.StopTest();  
       TriggerExecutionController.setSkipAllTriggers(false);
    }
}