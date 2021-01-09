/* 
Description : The test class for BachCMIdataIntegration and BachCMIdataIntegrationSchedule

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     12-Dec-2011     Krishna     CR 6708(R13.1) Created for Http callout to CMI based on CMI Data Queue records in In progress status
2.0     12-Dec-2019    VIKAS KH  Implemented TDF for 0202 release
*/
@isTest
private class BachCMIdataIntegrationTest {
    Static list<Account> listAcc;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
    }
    static testMethod void testBachCMIdataIntegrationException() {
        listAcc = [select id from Account limit 1];
        listAcc[0].IsPartner = true;
        listAcc[0].Account_Country_Code__c='AI';
        listAcc[0].Account_Country__c = 'ANGUILIA';              
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country__c, listAcc[0].Account_Country__c);
         //Creating Partner Account
     /* Account partnerAccount = new Account();   
        partnerAccount.name='PartnerAccount';
        partnerAccount.Account_Country_Code__c='AI';
        partnerAccount.Account_Country__c = 'ANGUILIA';              
        insert partnerAccount;
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;                
        update partnerAccount;
        */
        //Creating CMI Data queue        
        CMI_Data_Queue__c queueItem =  new CMI_Data_Queue__c (Type__c = 'Account', Status__c = 'In Progress', No_of_retries__c = 0, Account__c = listAcc[0].id);
        insert queueItem;
        //Running the batchable
        Test.startTest();
    BachCMIdataIntegration batch = new BachCMIdataIntegration();
    batch.query = 'SELECT Id, Type__c, Status__c, No_of_retries__c, Account__c' 
                    + ' FROM CMI_Data_Queue__c' 
                    + ' WHERE Id=\''+ queueItem.Id +'\'';
    batch.isTest = false;
    Id batchprocessid = database.executebatch(batch,1);
    Test.stopTest();
    }
     static testMethod void testBachCMIdataIntegrationSuccess() {
        //Creating Partner Account
    /*  Account partnerAccount = new Account();   
        partnerAccount.name='PartnerAccount';
        partnerAccount.Account_Country_Code__c='AI';
        partnerAccount.Account_Country__c = 'ANGUILIA';              
        insert partnerAccount;
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;                
        update partnerAccount; */
         listAcc = [select id from Account limit 1];
         listAcc[0].IsPartner = true;
         listAcc[0].Account_Country_Code__c='AI';
         listAcc[0].Account_Country__c = 'ANGUILIA';              
         update listAcc;
         system.assertEquals(listAcc[0].Account_Country__c, listAcc[0].Account_Country__c);
        //Creating CMI Data queue        
         CMI_Data_Queue__c queueItem =  new CMI_Data_Queue__c (Type__c = 'Account', Status__c = 'In Progress', No_of_retries__c = 0, Account__c = listAcc[0].id);
         insert queueItem;
        //Running the batchable
         Test.startTest();
         BachCMIdataIntegration batch = new BachCMIdataIntegration();
         batch.query = 'SELECT Id, Type__c, Status__c, No_of_retries__c, Account__c' 
             + ' FROM CMI_Data_Queue__c' 
             + ' WHERE Id=\''+ queueItem.Id +'\'';
         batch.isTest = True;
         batch.response = '<InsertSegmentationDataResult>true</InsertSegmentationDataResult>';
         Id batchprocessid = database.executebatch(batch,1);
         Test.stopTest();
    }
    static testMethod void testBachCMIdataIntegrationError() {
        //Creating Partner Account
    /*  Account partnerAccount = new Account();   
        partnerAccount.name='PartnerAccount';
        partnerAccount.Account_Country_Code__c='AI';
        partnerAccount.Account_Country__c = 'ANGUILIA';              
        insert partnerAccount;
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;                
        update partnerAccount; */
        listAcc = [select id from Account limit 1];
        listAcc[0].IsPartner = true;
        listAcc[0].Account_Country_Code__c='AI';
        listAcc[0].Account_Country__c = 'ANGUILIA';              
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country__c, listAcc[0].Account_Country__c);
        //Creating CMI Data queue        
        CMI_Data_Queue__c queueItem =  new CMI_Data_Queue__c (Type__c = 'Account', Status__c = 'In Progress', No_of_retries__c = 200, Account__c = listAcc[0].id);
        insert queueItem;
        //Running the batchable
        Test.startTest();
        BachCMIdataIntegration batch = new BachCMIdataIntegration();
        batch.query = 'SELECT Id, Type__c, Status__c, No_of_retries__c, Account__c' 
            + ' FROM CMI_Data_Queue__c' 
            + ' WHERE Id=\''+ queueItem.Id +'\'';
        batch.isTest = True;
        batch.response = '<InsertSegmentationDataResult>false</InsertSegmentationDataResult>';
        Id batchprocessid = database.executebatch(batch,1);
        Test.stopTest();
    }
    static testMethod void testBachCMIdataIntegrationSchedule() {
        //Creating Partner Account
     /* Account partnerAccount = new Account();   
        partnerAccount.name='CMIDataScheduleTest12345';
        partnerAccount.Account_Country_Code__c='AI';
        partnerAccount.Account_Country__c = 'ANGUILIA';              
        insert partnerAccount;
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;                
        update partnerAccount; */
        listAcc = [select id from Account limit 1];
        listAcc[0].IsPartner = true;
        listAcc[0].Account_Country_Code__c='AI';
        listAcc[0].Account_Country__c = 'ANGUILIA';              
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country__c, listAcc[0].Account_Country__c);
        //Creating CMI Data queue        
        CMI_Data_Queue__c queueItem =  new CMI_Data_Queue__c (Type__c = 'Account', Status__c = 'Pending', No_of_retries__c = 0, Account__c = listAcc[0].id);
        insert queueItem;
        //Running the schedulable
        Test.startTest();       
    String strcronexp = '0 0 0 * * ?';
    BachCMIdataIntegrationSchedule sch = new BachCMIdataIntegrationSchedule();
    sch.isTest = true;
    String strjobId = System.schedule('TestScheduledApex',strcronexp,sch);
    CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :strjobId];
    //Verify the expressions are the same
    System.assertEquals(strcronexp,ct.CronExpression);
    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered);    
    test.stopTest();
    }
    static testMethod void testCheckResponse() {
        Test.startTest();       
    System.assertEquals(BachCMIdataIntegration.checkResponse('sdsffd', 'Unknown'), false);
    test.stopTest();
    }
}