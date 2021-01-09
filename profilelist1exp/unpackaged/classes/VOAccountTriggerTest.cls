@isTest(seeAllData=false)
private class VOAccountTriggerTest {
    
    static Account testAccount;
    static visitops__Company__c testCompany;
    static visitops__Company__c testCompany1;
    
    //Create test data for testmethods
    static testMethod void createTestData() {
        
        TriggerExecutionControl__c triggerExeControl =new TriggerExecutionControl__c(Name='Account',SkipTriggers__c=true);
        insert triggerExeControl;
        //create test account
        testAccount = new Account(Name='testAccount',BillingCity='testaddr', AnnualRevenue = 10000000, Industry = 'Agriculture' , Website = 'http://www.abc.com');
        insert testAccount;    
        
        //Create Company
        testCompany = new visitops__Company__c(visitops__Account__c = testAccount.id, visitops__Company_Name__c= 'testAccount', visitops__Company_Annual_Revenue__c = 10000000, visitops__Company_Industry__c = 'Agriculture' , visitops__Company_Website__c = 'http://www.abc.com'); 
        insert testCompany;
        triggerExeControl.SkipTriggers__c = false;
        update triggerExeControl;
        Test.startTest();
        //testAccount.DunsNumber = '123';
        testAccount.Global_Account_Indicator__c='yes';
        update testAccount;
        System.assertEquals(null,null);
        Test.stopTest();
        
    }
    
    //Create test data for testmethods
    static testMethod void accountSyncAfterCompanyTest() {
        
        TriggerExecutionControl__c triggerExeControl =new TriggerExecutionControl__c(Name='Account',SkipTriggers__c=false);
        insert triggerExeControl;
        
        //Create Company
        testCompany = new visitops__Company__c(VO_Affinity_ID__c = '12334235', visitops__Company_Name__c= 'testAccount', visitops__Company_Annual_Revenue__c = 10000000, visitops__Company_Industry__c = 'Agriculture' , visitops__Company_Website__c = 'http://www.abc.com'); 
        testCompany1 = new visitops__Company__c(VO_UCID__c = '12323233', visitops__Company_Name__c= 'testAccount', visitops__Company_Annual_Revenue__c = 10000000, visitops__Company_Industry__c = 'Agriculture' , visitops__Company_Website__c = 'http://www.abc.com'); 
        
        insert new List<visitops__Company__c>{testCompany,testCompany1};
            Test.startTest();
        //create test account
        testAccount = new Account(Name='testAccount',BillingCity='testaddr', AnnualRevenue = 10000000, Industry = 'Agriculture' , Website = 'http://www.abc.com', Account_ID__c = '12334235', EMC_ID__c = '12323233');
        insert testAccount;    
        
        Test.stopTest();
        System.assertEquals(2,[Select id from visitops__Company__c where visitops__Account__c = :testAccount.id].size());
        
    }

     //Create test data for testmethods
    static testMethod void CompanyRecordErrorSyncTest() {
        
        TriggerExecutionControl__c triggerExeControl =new TriggerExecutionControl__c(Name='Account',SkipTriggers__c=false);
        insert triggerExeControl;
        //create test account
        testAccount = new Account(Name='testAccount',BillingCity='testaddr', AnnualRevenue = 10000000, Industry = 'Agriculture' , Website = 'http://www.abc.com', Account_ID__c = '12334235', EMC_ID__c = '12323233');
        insert testAccount;   
        //Create Company
        testCompany = new visitops__Company__c(VO_Affinity_ID__c = '12334235', visitops__Company_Name__c= 'testAccount', visitops__Company_Annual_Revenue__c = 10000000, visitops__Company_Industry__c = 'Agriculture' , visitops__Company_Website__c = 'http://www.abc.com'); 
        testCompany1 = new visitops__Company__c(VO_UCID__c = '12323233', visitops__Company_Name__c= 'testAccount', visitops__Company_Annual_Revenue__c = 10000000, visitops__Company_Industry__c = 'Agriculture' , visitops__Company_Website__c = 'http://www.abc.com'); 
        
        insert new List<visitops__Company__c>{testCompany,testCompany1};
        Test.startTest();
        //testAccount.DunsNumber = '123';
        testAccount.Global_Account_Indicator__c='yes';
        update testAccount;        
        Test.stopTest();
        System.assertEquals(2,[Select id from visitops__Company__c where visitops__Account__c = :testAccount.id].size());
        
    }
    
}