@isTest
public class Batch_TRTUpdateonPT_SchedulerTest {
@isTest static void executeTest(){ 
SchedulableContext sc = null;
           Test.StartTest();
    Batch_TRTUpdateonPT_Scheduler sch1 = new Batch_TRTUpdateonPT_Scheduler();     
     Batch_TRTUpdateonPT bat = new Batch_TRTUpdateonPT();
     DataBase.executeBatch(bat,20);
     sch1.execute(sc);
     Test.stopTest();
}
}