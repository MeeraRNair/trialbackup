@isTest(SeeAllData=true)
private class LoginHourChangesTestClass{

  public static String CRON_EXP = '0 0 0 15 3 ? 2022';
  static testmethod void testLoadData(){ 
      Test.startTest(); 
      String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP,new LoginHourChangeMailScheduler()); 
      LoginHourChangeReporter callLoginMethod = new LoginHourChangeReporter();
      Test.stopTest();
           
  }
}