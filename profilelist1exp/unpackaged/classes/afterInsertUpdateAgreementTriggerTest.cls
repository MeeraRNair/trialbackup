@isTest
private class afterInsertUpdateAgreementTriggerTest {

    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static Marketing_Plan__c mp = new Marketing_Plan__c();
    public static echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
    //public static List <Associated_Programs_Vendors__c> apvlist = new List <Associated_Programs_Vendors__c> ();
    public static Contact cnt = new Contact ();
    public static Account accnt = new Account();
    public static Marketing_Plan__c updatedMP = new Marketing_Plan__c();
    public static echosign_dev1__SIGN_Agreement__c updatedagreement = new echosign_dev1__SIGN_Agreement__c();
    public static List <Associated_Programs_Vendors__c> apvList = new List <Associated_Programs_Vendors__c>();
    public static List <Associated_Programs_Vendors__c> apvListdeclined = new List <Associated_Programs_Vendors__c>();
    public static List <Associated_Programs_Vendors__c> apvListUpdated = new List <Associated_Programs_Vendors__c>();
    public static List <Associated_Programs_Vendors__c> apvListdeclinedupdated = new List <Associated_Programs_Vendors__c>();
    public static RecordType vendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Vendor'];
    public static RecordType subvendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Sub Vendor'];
    public static RecordType mpRT = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Volume Based Marketing Plan'];
    public static List <MDF_Program__c> pgmlist1 =  new List <MDF_Program__c>{};
    public static List <MDF_Program__c> pgmlist2 =  new List <MDF_Program__c>{};
    public static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like'MDF%' limit 1];
    public static User u1 = new User();
    
    public static void createvendor(){
    	 u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
        insert u1;
        
        // creating a parent vendor
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
        
       mp.name='MP-001';
       mp.Vendor__c=subvendor.Id;
       mp.Fiscal_Quarter__c='FY12Q1';
       mp.Region__c='Americas';
       mp.Contract_Type__c='Volume Based';
       mp.RecordTypeId=mpRT.Id;
        
        insert mp;    	
    }
    
    public static void createdata(){
       for(Integer i=0;i<3;i++){
        MDF_Program__c pgm = new MDF_Program__c();
        pgm.Name = 'Name'+i;
        pgm.Program_Owner__c=u1.Id;
        pgm.POP_Owner__c=u1.Id;
        pgmlist1.add(pgm);
       }insert pgmlist1;
        
        for(Integer i=0;i<3;i++){
        Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
        apv.Vendor__c = subvendor.Id;
        apv.Marketing_Plan__c = mp.Id;
        apv.Status__c = 'Accepted';
        apv.MDF_Program__c = pgmlist1[i].Id;
        //insert apv;           
        apvList.add(apv);       
       }insert apvList;
       
       for(Integer i=0;i<3;i++){
        MDF_Program__c pgm = new MDF_Program__c();
        pgm.Name = 'Name'+i+1;
        pgm.Program_Owner__c=u1.Id;
        pgm.POP_Owner__c=u1.Id;
        pgmlist2.add(pgm);
       }insert pgmlist2;
        
         for(Integer i=0;i<3;i++){
        Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
        apv.Vendor__c = subvendor.Id;
        apv.Marketing_Plan__c = mp.Id;
        apv.Status__c = 'Declined';
        apv.MDF_Program__c = pgmlist2[i].Id;
        apvListdeclined.add(apv);
        
       }insert apvListdeclined;
       
       accnt.Name = 'testaccnt';
       insert accnt;
       
       cnt.FirstName = 'Fname';
       cnt.LastName = 'Lname';
       cnt.Status__c = 'Customer';
       cnt.Phone = '234532452345';
       cnt.Job_Function__c ='H/R';
       cnt.Job_Function_Role__c = 'HR Manager';
       cnt.Purchaser_Influence_Over__c = 'Client - Notebooks';
       cnt.Decision_Making_Role__c = 'Business User';
       cnt.AccountId =accnt.Id;
       
       insert cnt;
       
       agreement.Marketing_Plan__c = mp.Id;
       agreement.Name = 'test agreement';
       agreement.echosign_dev1__Recipient__c = cnt.Id;
       agreement.echosign_dev1__Status__c = 'Signed';
       insert agreement;
       
       //update agreement;
        
        /* Fenny moved this block of code to test method
        updatedagreement = [select Id,Marketing_Plan__c from echosign_dev1__SIGN_Agreement__c where Id=:agreement.Id];
  
        updatedMP = [Select Id,Contract_Status__c from Marketing_Plan__c where Id=:updatedagreement.Marketing_Plan__c];
        
        apvListUpdated = [Select Id,Status__c,RecordTypeId from Associated_Programs_Vendors__c where Id in :apvList];
        
        apvListdeclinedupdated = [Select Id,Status__c,RecordTypeId from Associated_Programs_Vendors__c where Id in :apvListdeclined];
        */
    }
    
    static testMethod void myUnitTest() {
        
        // Emily added these to resolve 'Too many SOQL queries: 101' issue
        createvendor();        
        Test.startTest();
        createdata();
        Test.stopTest();
        
        // Fenny added these to resolve 'Too many SOQL queries: 101' issue
        updatedagreement = [select Id,Marketing_Plan__c from echosign_dev1__SIGN_Agreement__c where Id=:agreement.Id];  
        updatedMP = [Select Id,Contract_Status__c from Marketing_Plan__c where Id=:updatedagreement.Marketing_Plan__c];        
        apvListUpdated = [Select Id,Status__c,RecordTypeId from Associated_Programs_Vendors__c where Id in :apvList];        
        apvListdeclinedupdated = [Select Id,Status__c,RecordTypeId from Associated_Programs_Vendors__c where Id in :apvListdeclined];
        
        system.assertEquals(updatedMP.Contract_Status__c,'Signed');
        
        for(Associated_Programs_Vendors__c apv:apvListUpdated){
            system.assertEquals(apv.Status__c,'Signed');
            //system.assertEquals(apv.RecordTypeId ,'012T0000000D6Et');
        }
        
        for(Associated_Programs_Vendors__c apv:apvListdeclinedupdated){
            system.assertNotEquals(apv.Status__c, 'Signed');
            //system.assertEquals(apv.RecordTypeId ,'012T0000000D6Et');
        }
               
        
         agreement.echosign_dev1__Status__c = 'Cancelled / Declined';
         update agreement;
        
         
        
    }
}