@IsTest
private class AccountIntegrationTest {
    
    private static Account testAccount;
    private static List<Lead> testLeadList = new List<Lead>();
    private static List<Partner_Request__c> testPartnerRequestList = new List<Partner_Request__c>();
    private static List<AccountLeadLinkInfo> testData = new List<AccountLeadLinkInfo>(); 
    private static List<String> testLeadIdList = new List<String>();
    
    private static void setupTestData() {
        //Creating test data for partner account. IsPartner=true and recordtype = Partner Account
        Map<String, String> paraMap = new Map<String,String>{};     
        List<Account> validAccount =  (List<Account>)TestDataGenerator.getObject(new Account(), 1, paraMap);
        testAccount = validAccount[0];
        
        for(Integer i=0; i < 200; i++) {            
            testLeadList.add(new Lead(Company='TestCompany ' + i, LastName='TestCompany Contact ' + i,Phone='1234567891' + i));            
        }
        
        insert testLeadList;
        System.debug('###DEBUG### testLeadList=' + testLeadList);
        
        for(Integer i=0; i < testLeadList.size(); i++) {
            
            testPartnerRequestList.add(new Partner_Request__c(
                                                Company__c=testLeadList.get(i).Company, 
                                                Lead__c=testLeadList.get(i).Id));
        }
        
        insert testPartnerRequestList;
        System.debug('###DEBUG### testPartnerRequestList=' + testPartnerRequestList);
        
        for(Integer i=0; i < testLeadList.size(); i++) {
            testLeadList.get(i).Partner_Request__c = testPartnerRequestList.get(i).Id;      
        }
        update testLeadList;
        
        for(Lead tl : testLeadList) {
            AccountLeadLinkInfo temp = new AccountLeadLinkInfo();
            temp.accountId=testAccount.id;
            temp.leadId=tl.Id;
            
            testLeadIdList.add(tl.Id);
            testData.add(temp);
        }
        
        System.debug('###DEBUG### testData=' + testData);
        System.debug('###DEBUG### testLeadIdList=' + testLeadIdList);
    }

     static testMethod void testLinkAccountToPartnerRequest() {
        
        Test.startTest();
        setupTestData();
        AccountIntegration.linkAccountToPartnerRequest(testData);
        
        List<Lead> resultLeadList = [SELECT Id, Name, Account__c, Status
                        FROM Lead
                        WHERE Id IN :testLeadIdList];
        System.debug('###DEBUG### resultLeadList='+resultLeadList);
        System.debug('###DEBUG### Asserting: Lead.Account__C=' + resultLeadList[60].Account__c + ' is Account ' + testAccount.Id);
        System.assertEquals(resultLeadList[60].Account__c, testAccount.Id);                         
        System.assertEquals(resultLeadList[60].Status, 'Account Suggestion Completed'); 
        
        List<Partner_Request__c> resultRequestList = [SELECT Id, Name, Account__c, Status__c, Link_to_Account_Record_Is_Complete_Flag__c
                                                        FROM Partner_Request__c
                                                        WHERE Lead__c IN :testLeadIdList];
        
        System.debug('###DEBUG### Asserting: Partner Request.Account__C=' + resultRequestList[6].Account__c + ' is Account ' + testAccount.Id);                                         
        System.assertEquals(resultRequestList[6].Account__c, testAccount.Id);
        System.assertEquals(resultRequestList[6].Status__c, 'Account Suggestion Completed');
        System.assertEquals(resultRequestList[6].Link_to_Account_Record_Is_Complete_Flag__c, true);
        
        Test.stopTest();    
        
        
     }
     
     static testMethod void testPartnerRequestStatusAvailability() {
        
        Set<String> availableStatusSet = new Set<String>();
        Schema.DescribeFieldResult statusField = Partner_Request__c.Status__c.getDescribe();
            
        List<Schema.PicklistEntry> pickList = statusField .getPicklistValues();
        
        for(Schema.PicklistEntry entry : pickList )
        {
            availableStatusSet.add(entry .getValue());
        } 
        
        system.assert(availableStatusSet.contains('Account Suggestion Completed'));
    }
    
    static testMethod void testLeadStatusAvailability() {
        
        Set<String> availableStatusSet = new Set<String>();
        Schema.DescribeFieldResult statusField = Lead.Status.getDescribe();
            
        List<Schema.PicklistEntry> pickList = statusField .getPicklistValues();
        
        for(Schema.PicklistEntry entry : pickList )
        {
            availableStatusSet.add(entry .getValue());
        } 
        
        system.assert(availableStatusSet.contains('Account Suggestion Completed'));
    }
   
 //===============================================CR5801=================================================
         static testMethod void TestlinkAccountToPRwithResponse_StatusOther() {
        
        Test.startTest();
        
        setupTestData();
                
        for(Integer i=0; i < testLeadList.size(); i++) {
            testLeadList.get(i).Status = 'Account Suggestion Rejected';     
        }
        
        update testLeadList;
                for(Integer i=0; i < testLeadList.size(); i++) {
            
            testPartnerRequestList.get(i).Status__c = 'Account Suggestion Rejected';
        }
        
        update testPartnerRequestList;  
        
        AccountIntegration.linkAccountToPRwithResponse(testData);
        
        List<Lead> resultLeadList = [SELECT Id, Name, Account__c, Status FROM Lead
        WHERE Id IN :testLeadIdList];
        
        System.debug('###DEBUG### resultLeadList='+resultLeadList);
        System.debug('###DEBUG### Asserting: Lead.Account__C=' + resultLeadList[60].Account__c + ' is Account ' + testAccount.Id);
                    
        System.assertEquals(resultLeadList[60].Status, 'Account Suggestion Rejected');  
        
        List<Partner_Request__c> resultRequestList = [SELECT Id, Name, Account__c, Status__c, Link_to_Account_Record_Is_Complete_Flag__c
                                                        FROM Partner_Request__c
                                                        WHERE Lead__c IN :testLeadIdList];
        System.debug('###DEBUG### Asserting: Partner Request.Account__C=' + resultRequestList[60].Account__c + ' is Account ' + testAccount.Id);                                            
        System.assertEquals(resultRequestList[6].Link_to_Account_Record_Is_Complete_Flag__c, false);
        System.assertEquals(resultRequestList[60].Status__c, 'Account Suggestion Rejected');
    
        Test.stopTest();    
        
     }
     
        static testMethod void TestlinkAccountToPRwithResponse_StatusSubmitted() {
        
        Test.startTest();
        
        setupTestData();
                
        for(Integer i=0; i < testLeadList.size(); i++) {
            testLeadList.get(i).Status = 'Account Suggestion Submitted';        
        }
        update testLeadList;
            
        for(Integer i=0; i < testLeadList.size(); i++) {
            
            testPartnerRequestList.get(i).Status__c = 'Account Suggestion Submitted';
        }
        
        update testPartnerRequestList;      
        
        AccountIntegration.linkAccountToPRwithResponse(testData);
        
        List<Lead> resultLeadList = [SELECT Id, Name, Account__c, Status FROM Lead
        WHERE Id IN :testLeadIdList];
        
        System.debug('###DEBUG### resultLeadList='+resultLeadList);
        System.debug('###DEBUG### Asserting: Lead.Account__C=' + resultLeadList[60].Account__c + ' is Account ' + testAccount.Id);
        
        System.assertEquals(resultLeadList[60].Account__c, testAccount.Id);                         
        System.assertEquals(resultLeadList[60].Status, 'Account Suggestion Completed'); 
        
        List<Partner_Request__c> resultRequestList = [SELECT Id, Name, Account__c, Status__c, Link_to_Account_Record_Is_Complete_Flag__c
                                                        FROM Partner_Request__c
                                                        WHERE Lead__c IN :testLeadIdList];
        
        System.debug('###DEBUG### Asserting: Partner Request.Account__C=' + resultRequestList[6].Account__c + ' is Account ' + testAccount.Id);                                         
        System.assertEquals(resultRequestList[60].Status__c, 'Account Suggestion Completed');
        Test.stopTest();    
     
     }

}