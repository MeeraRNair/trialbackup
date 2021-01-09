@istest(seeAllData=true)
public class DashboardUsageTrackerTest {
    
    private static testmethod void dashboardTrackTest(){
        Dashboard_Tracker__c trackObj = new Dashboard_Tracker__c();
        trackObj.Name = 'Test Dashboard';
        trackObj.Dashboard_ID__c = '01ZA0000000W00M';
        trackObj.ReportIds__c = '00OA00000063eMj,00OA00000063eMo,00OA00000063eN3,00OA00000063eMt';
        insert trackObj;
        Test.startTest();
        
        String jobId = System.schedule('dashboardTrackTest','0 0 * * * ?',new DashboardUsageTracker());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(DashboardUsageTracker.CRON_EXP,ct.CronExpression);
        Test.stopTest();
    }
}