@isTest
public class VOVisitBundleUpdateScheduledTest {
    
	private static testMethod void test() {
		test.startTest();
        //Visit Bundle Sync Job	
        String CRON_EXP = '0 0 * * * ?';
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new VOVisitBundleUpdateScheduled());
        test.stopTest();
    }
}