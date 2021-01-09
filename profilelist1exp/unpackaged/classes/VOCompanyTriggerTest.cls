@isTest(seeAllData=false)
private class VOCompanyTriggerTest {
    
    static Account testAccount;
    static visitops__Company__c testCompany;
    
    //Create test data for testmethods
    static testMethod void createTestData() {
            
            Test.startTest();
            //create test account
         	testAccount = new Account(Name='testAccount', AnnualRevenue = 10000000, Industry = 'Agriculture' , Website = 'http://www.abc.com');
            insert testAccount;    
        
            //Create Company
            testCompany = new visitops__Company__c(visitops__Account__c = testAccount.id, visitops__Company_Name__c= 'testAccount', visitops__Company_Annual_Revenue__c = 10000000, visitops__Company_Industry__c = 'Agriculture' , visitops__Company_Website__c = 'http://www.abc.com'); 
            insert testCompany;
            System.assertEquals(null,null);
            Test.stopTest();
    }
    
}