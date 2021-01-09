@isTest
private class TestMarketingPlan {

    static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like 'MDF Program Owners' limit 1];
    static User usr1 = new User(alias = 'newUser1', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
    static RecordType vendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Vendor'];
    static RecordType mpRT = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Volume Based Marketing Plan'];
    static Vendor__c vendor = new Vendor__c();
    static Marketing_Plan__c mp = new Marketing_Plan__c();
    static echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
    static Contact ct = new Contact();
    static Account acct = new Account();

    static testMethod void TestAfterUpdateAgreementCancelled() {
        Test.startTest();
        
        insert usr1; //program owner

        //create vendor  
        vendor.Name = 'TestVendor' + string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A';
        vendor.Partner_Status__c='Active';        
        vendor.recordTypeId=vendorRT.Id;
        insert vendor;
        
        //insert custom settings 
        Fiscal_Years__c fs = new Fiscal_Years__c(Start_Date__c=system.today(),End_Date__c=system.today()+90,Name='FY16Q1');
        insert fs;
        
        Fiscal_Years__c fs2 = new Fiscal_Years__c(Start_Date__c=system.today(),End_Date__c=system.today()+90,Name='FY16Q2');
        insert fs2;
        
        //create marketing plan
        mp.name='TestMarketingPlan' + string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A';  
        mp.Vendor__c=vendor.Id;  
        mp.Fiscal_Quarter__c='FY16Q1';  
        mp.Region__c='Americas';  
        mp.Contract_Type__c='Volume Based';  
        mp.RecordTypeId=mpRT.Id;
        mp.Term__c = '1';  
        insert mp; 
        
        mp.Term__c = '2';
        update mp;
        
        //create agreement  
        acct.Name = 'TestAccount' + string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A';
        insert acct;
        ct.FirstName = 'Fname';  
        ct.LastName = 'Lname';  
        ct.Status__c = 'Customer';  
        ct.Phone = '234532452349';  
        ct.Job_Function__c ='H/R';  
        ct.Job_Function_Role__c = 'HR Manager';  
        ct.Purchaser_Influence_Over__c = 'Client - Notebooks';  
        ct.Decision_Making_Role__c = 'Business User';  
        ct.AccountId =acct.Id;
        insert ct;
        agreement.Marketing_Plan__c = mp.Id;  
        agreement.Name = 'TestAgreement' + string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A';  
        agreement.echosign_dev1__Recipient__c = ct.Id;  
        insert agreement;  
  
        //update agreement  
        agreement.echosign_dev1__Status__c = 'Cancelled / Declined';
        update agreement;

        //query marketing plan and check contract status
        mp = [SELECT Id, Contract_Status__c FROM Marketing_Plan__c WHERE Id = :mp.Id];
        System.assertNotEquals('Cancelled / Declined', mp.Contract_Status__c);
  
        Test.stopTest();  
    }
}