/* 
Description : test class for BatchUpdateCMIDataQueueSchedule and BatchUpdateCMIDataQueue

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     12-Dec-2011   	Krishna     CR 6708(R13.1) Created for testing the job for updating the CMI Data Queue status from Pending to In progress 
*/

@isTest
private class BatchUpdateCMIdataQueueTest {

    static testMethod void testBatchUpdateCMIdataQueue() {
                
        //Creating Partner Account
        Account partnerAccount = new Account();   
        partnerAccount.name='PartnerAccount';
        partnerAccount.Account_Country_Code__c='AI';
        partnerAccount.Account_Country__c = 'ANGUILIA';              
        insert partnerAccount;
        
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;                
        update partnerAccount;
        
        //Creating CMI Data queue        
        CMI_Data_Queue__c queueItem =  new CMI_Data_Queue__c (Type__c = 'Account', Status__c = 'Pending', No_of_retries__c = 0, Account__c = partnerAccount.id);
        insert queueItem;
        
        //Running the batchable
        Test.startTest();
		BatchUpdateCMIDataQueue updateCMIDataQueueBatch = new BatchUpdateCMIDataQueue();
		updateCMIDataQueueBatch.query = 'SELECT Id,Status__c' 
										+ ' FROM CMI_Data_Queue__c' 
										+ ' WHERE Id=\''+ queueItem.Id +'\'';
		updateCMIDataQueueBatch.isTest = True;
		Id batchprocessid = database.executebatch(updateCMIDataQueueBatch,10);
		Test.stopTest();
		queueItem = [SELECT Id,Status__c FROM CMI_Data_Queue__c WHERE Id= :queueItem.Id];
		System.AssertEquals(queueItem.Status__c,'In Progress');
    }
    
    static testMethod void testBatchUpdateCMIdataQueueSchedule() {
                
        //Creating Partner Account
        Account partnerAccount = new Account();   
        partnerAccount.name='CMIDataScheduleTest12345';
        partnerAccount.Account_Country_Code__c='AI';
        partnerAccount.Account_Country__c = 'ANGUILIA';              
        insert partnerAccount;
        
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;                
        update partnerAccount;
        
        //Creating CMI Data queue        
        CMI_Data_Queue__c queueItem =  new CMI_Data_Queue__c (Type__c = 'Account', Status__c = 'Pending', No_of_retries__c = 0, Account__c = partnerAccount.id);
        insert queueItem;
        
        //Running the schedulable
        Test.startTest();       
		String CRON_EXP = '0 0 0 * * ?';
		BatchUpdateCMIDataQueueSchedule sch = new BatchUpdateCMIDataQueueSchedule();
		sch.isTest = true;
		String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		//Verify the expressions are the same
		System.assertEquals(CRON_EXP,ct.CronExpression);
		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
		test.stopTest();
    }
    
    
}