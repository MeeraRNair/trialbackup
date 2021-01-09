@isTest(seealldata = false)
private class Test_Batch_UpdateStatusOnIdeaIntake{
    static list<Idea_Intake__c> listIdeaInt;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Idea_Intake__c> listIdeaIntTdf=TestDataFactory.createNIdeaIntake(1,'Idea');
        insert listIdeaIntTdf;
        
    }
    static testMethod void batchUpdateStatusOnIdeaIntake() {
        listIdeaInt = [Select Id from Idea_Intake__c limit 1];
        listIdeaInt[0].PMO_CR__c = '12345';
        update listIdeaInt;
        system.assertNotEquals(listIdeaInt[0].id, null);
        /*
List<Idea_Intake__c> ideaIntakeList = new List<Idea_Intake__c>();
Idea_Intake__c ideaIntakeRecord = new Idea_Intake__c (RecordTypeId = ideaRecordType,Regions_Impacted__c ='testRegion',Requesting_organization__c='testReqOrg',
Requesting_region__c  ='testReqReg',Business_Challenge__c = 'testBusCha',Business_Justification__c ='testBusJus',
Business_Objective__c ='testBusObj',Name = 'testIdea',PMO_CR__c = '12345');

insert ideaIntakeRecord;*/
        Test.StartTest(); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());         
        Batch_UpdateStatusOnIdeaIntake updateStatusBatch = new Batch_UpdateStatusOnIdeaIntake();            
        Id batchprocessid = database.executebatch(updateStatusBatch,1);
        Test.StopTest();
        
    }
    
    static testMethod void testBatchUpdateStatusOnIdeaIntakeScheduler() {
        listIdeaInt = [Select Id from Idea_Intake__c limit 1];
        listIdeaInt[0].PMO_CR__c = '1232';
        update listIdeaInt;
        system.assertNotEquals(listIdeaInt[0].id, null);
        /*
Idea_Intake__c ideaIntakeRecord = new Idea_Intake__c (RecordTypeId = ideaRecordType,Regions_Impacted__c ='testRegion',Requesting_organization__c='testReqOrg',
Requesting_region__c  ='testReqReg',Business_Challenge__c = 'testBusCha',Business_Justification__c ='testBusJus',
Business_Objective__c ='testBusObj',Name = 'testIdea213',PMO_CR__c = '1232');

insert ideaIntakeRecord;*/
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());           
        String strCRONEXP = '0 0 0 * * ?';
        Batch_UpdateStatusOnIdeaIntakeSchedule sch = new Batch_UpdateStatusOnIdeaIntakeSchedule();
        String strjobId = System.schedule('TestScheduledApex',strCRONEXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :strjobId];
        //Verify the expressions are the same
        System.assertEquals(strCRONEXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
}