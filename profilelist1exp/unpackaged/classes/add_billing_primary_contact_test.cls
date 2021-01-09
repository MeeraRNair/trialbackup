@isTest
private class add_billing_primary_contact_test {
    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static Marketing_Plan__c mp = new Marketing_Plan__c();
    public static Marketing_Plan__c mp_noncogs = new Marketing_Plan__c();
    public static Marketing_Plan__c mp_rebates = new Marketing_Plan__c();
    public static Marketing_Plan__c mp_headcount = new Marketing_Plan__c();
    public static MDF_Contact__c mdfcontact_marketing = new MDF_Contact__c();
    public static MDF_Contact__c mdfcontact_billing = new MDF_Contact__c();
    public static List<MDF_Contact__c> mdfcontact_List = new List<MDF_Contact__c>();
    public static MDF_Associated_Contact__c mdfAC_marketing = new MDF_Associated_Contact__c();
    public static MDF_Associated_Contact__c mdfAC_billing = new MDF_Associated_Contact__c();
    public static List<MDF_Associated_Contact__c> mdfAC_List = new List<MDF_Associated_Contact__c>();
    public static RecordType vendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Vendor'];
    public static RecordType subvendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Sub Vendor'];
    public static RecordType mpRT = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Volume Based Marketing Plan'];
    public static RecordType mpRTAC = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Ala Carte Marketing Plan'];
    public static RecordType mpRTRB = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Rebates Marketing Plan'];
    public static RecordType mpRTHC = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Headcount Marketing Plan'];
    public static List <Marketing_Plan__c> mplist = new List <Marketing_Plan__c>();
    public static Account a = new Account();
    public static Contact c = new Contact(); 
  
    public static void createdata(){
        
    TriggerExecutionController.setSkipAllTriggers(true);
        //creating a parent vendor
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
        
        //creating marketing mdf contact        
        mdfcontact_marketing.Name = 'marketing';
        mdfcontact_marketing.Title__c = 'marketing';
        mdfcontact_marketing.Phone__c = '12345678';
        mdfcontact_marketing.Email__c = 'r@r.com';
        mdfcontact_marketing.Partner_Contact_Type__c = 'Marketing';
        mdfcontact_marketing.Status__c = 'Active';
         mdfcontact_List.add(mdfcontact_marketing);
        
        mdfcontact_billing.Name = 'billing';
        mdfcontact_billing.Title__c = 'billing';
        mdfcontact_billing.Phone__c = '12345679';
        mdfcontact_billing.Email__c = 's@s.com';
        mdfcontact_billing.Partner_Contact_Type__c = 'Billing';
        mdfcontact_billing.Status__c = 'Active';
         mdfcontact_List.add(mdfcontact_billing);
        insert mdfcontact_List;
        
        //create MDF Associated contacts
        mdfAC_marketing.Vendor__c = subvendor.Id;
        mdfAC_marketing.MDF_Contact__c = mdfcontact_marketing.Id;
        mdfAC_List.add(mdfAC_marketing);
        
        mdfAC_billing.Vendor__c = subvendor.Id;
        mdfAC_billing.MDF_Contact__c = mdfcontact_billing.Id;
        mdfAC_List.add(mdfAC_billing);
        insert mdfAC_List;
        
        // creating an MP
        mp.name='MP-001';
        mp.Vendor__c=subvendor.Id;
        mp.Fiscal_Quarter__c='FY12Q1';
        mp.Region__c='EMEA';
        mp.Contract_Type__c='Volume Based';
        mp.RecordTypeId=mpRT.Id;      
        mplist.add(mp);
        
        mp_noncogs.name='MP-002';
        mp_noncogs.Vendor__c=subvendor.Id;
        mp_noncogs.Fiscal_Quarter__c='FY12Q1';
        mp_noncogs.Region__c='EMEA';
        mp_noncogs.Contract_Type__c='Ala Carte';
        mp_noncogs.RecordTypeId=mpRTAC.Id;      
        mplist.add(mp_noncogs);
        
        mp_rebates.name='MP-003';
        mp_rebates.Vendor__c=subvendor.Id;
        mp_rebates.Fiscal_Quarter__c='FY12Q1';
        mp_rebates.Region__c='EMEA';
        mp_rebates.Contract_Type__c='Rebates';
        mp_rebates.RecordTypeId=mpRTRB.Id;      
        mplist.add(mp_rebates);
        
        mp_headcount.name='MP-004';
        mp_headcount.Vendor__c=subvendor.Id;
        mp_headcount.Fiscal_Quarter__c='FY12Q1';
        mp_headcount.Region__c='EMEA';
        mp_headcount.Contract_Type__c='Headcount';
        mp_headcount.RecordTypeId=mpRTHC.Id;      
        mplist.add(mp_headcount);
        
        insert mplist;
        a.Name='test account';
        insert a; 
        
        c.FirstName='Fname';
        c.LastName='Lname';
        c.AccountId = a.Id;
        c.Phone = '1224';
        c.Email ='r@r.com';
        insert c;       
        
    }
    
    
    
    static testMethod void myUnitTest() {
        
        createdata(); 
        
        Test.startTest();
        Profile p1 = [SELECT Id,Name FROM profile WHERE name='High Volume Customer Portal User'];  
        User u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com',contactId=c.Id);
        Database.Saveresult sr_Insert= Database.insert(u1,false);
               
            System.debug('profile user --->'+u1);
            System.RunAs(u1){
            for(Marketing_Plan__c mploop:mplist){
                PageReference  pr=new PageReference('apex/add_Primary_Contact?id='+mploop.Id);
                Test.setCurrentPage(pr);
                VFCntrlr_Add_Primary_Contact cntrlr = new VFCntrlr_Add_Primary_Contact(new ApexPages.StandardController(mploop));
                cntrlr.contactId = mdfAC_marketing.Id;              
                PageReference selectpage = cntrlr.select_action();
                PageReference newcontact = cntrlr.new_contact_info_action();
                PageReference editcontact = cntrlr.edit_contact_info_action();
                cntrlr.MPlan.Primary_Marketing_Contact_Name__c = 'primary name';
                cntrlr.MPlan.Primary_Marketing_Contact_Country__c = 'Primary Country';
                cntrlr.MPlan.Primary_Marketing_Contact_E_mail__c = 'W@W.COM';
                cntrlr.MPlan.Primary_Marketing_Contact_Phone__c = '2341234';
                cntrlr.MPlan.Primary_Marketing_Contact_Address__c = 'primary address';
                cntrlr.MPlan.Primary_Marketing_Contact_Cell__c = '234234123';
                cntrlr.MPlan.Primary_Marketing_Contact_City__c = 'primary city';
                cntrlr.MPlan.Primary_Marketing_Contact_State__c = 'primary state';
                cntrlr.MPlan.Primary_Marketing_Contact_Title__c = 'primary title';
                cntrlr.MPlan.Primary_Marketing_Contact_Zip__c = '2341234';
                cntrlr.MPlan.Primary_Marketing_Contact_Fax__c = '21341345';
                PageReference savecontact = cntrlr.savenew_Info();
                System.debug('save urls--->'+savecontact);
                PageReference cancelcontact = cntrlr.cancelinfo();
                cntrlr.getMdfContactList();
                cntrlr.gettempContact();
            }
        }
        Test.stopTest();
        
    TriggerExecutionController.setSkipAllTriggers(false);
   }
   
   static testMethod void myUnitTest2() {
        
        createdata();         
        Test.startTest();
        Profile p1 = [SELECT Id,Name FROM profile WHERE name='High Volume Customer Portal User'];  
        User u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com',contactId=c.Id);
        Database.Saveresult sr_Insert= Database.insert(u1,false);
               
        System.debug('profile user --->'+u1);
        System.RunAs(u1){
          for(Marketing_Plan__c mploop:mplist){
            //Add_Billing_Contact
            PageReference  pr=new PageReference('apex/Add_Billing_Contact?id='+mploop.Id);
            VFCntrlr_Add_Billing_Contact cntrlr = new VFCntrlr_Add_Billing_Contact(new ApexPages.StandardController(mploop));
            cntrlr.billingcontactId = mdfAC_billing.Id;
            cntrlr.select_action();
            cntrlr.new_contact_info_action();
            cntrlr.MPlan.Billing_Contact_Name__c ='name';
            cntrlr.MPlan.Billing_Contact_Email__c = 'r@r.com';
            cntrlr.MPlan.Billing_Contact_Phone__c = '12345';
            cntrlr.MPlan.Billing_Contact_Title__c = 'title';
            cntrlr.edit_contact_info_action();
            cntrlr.savenewInfo();
            cntrlr.cancelinfo();
            cntrlr.getBillingContactList();
          }
        } 
        Test.stopTest();
        
    TriggerExecutionController.setSkipAllTriggers(false);
   }
}