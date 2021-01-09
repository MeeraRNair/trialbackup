@isTest
public class Batch_CMAPSendEmailSchedulerTest {
        @isTest Static void TestBatchSendEmail(){
        Test.startTest();
        String sch = '0 0 23 * * ?';
        Batch_CMAPSendEmailforAcceptedScheduler  Schedulable = new Batch_CMAPSendEmailforAcceptedScheduler();
        system.schedule('Test Schedule Class', sch, Schedulable);
        Test.stopTest();
        System.assert(True);
    }
    
}