@isTest
private class AfterInsertUpdateRevenueTriggerTest{
    private static testMethod void AfterInsertUpdateRevenue() {

        Account testAccount  = new Account(Name='Test Account');
        insert testAccount;

        Revenue__c  testRevenue = new Revenue__c();
        testRevenue.Account__c=testAccount.ID;
        testRevenue.Fiscal_Year__c='FY2013';
        testRevenue.Fiscal_Quarter__c='C04'; 
        Insert testRevenue;
        
        testRevenue.Fiscal_Quarter__c='C03'; 
        Update testRevenue;
   
     Revenue__c  testRevenue1 = new Revenue__c();
        testRevenue1.Account__c=testAccount.ID;
        testRevenue1.Fiscal_Year__c='FY2013';
        testRevenue1.Fiscal_Quarter__c='C04'; 
        Insert testRevenue1;
        
        testRevenue1.Fiscal_Quarter__c='C03'; 
        Update testRevenue;
        
        
        Revenue__c  testRevenue2 = new Revenue__c();
        testRevenue2.Account__c=testAccount.ID;
        testRevenue2.Fiscal_Year__c='FY2013';
        testRevenue2.Fiscal_Quarter__c='C02'; 
        Insert testRevenue2;
        
        testRevenue2.Fiscal_Quarter__c='C02'; 
        Update testRevenue2;
   
    }
}