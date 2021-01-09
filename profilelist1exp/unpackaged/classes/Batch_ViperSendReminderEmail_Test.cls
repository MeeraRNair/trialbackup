@isTest 

private class Batch_ViperSendReminderEmail_Test{
      
   public static testmethod void testViperWeeklyReminderEmailScheduler() {
      User user =[select id,name, email from user where IsActive= true limit 1];
      String strEmail = user.email+',test@test.com';
      String strVendor = user.name+',test@test.com';
      Test.startTest();
      Marketing_Plan__c mPlan = new Marketing_Plan__c(Name ='mPlan_weekly',Fiscal_Quarter__c='FY12Q1',Region__c='Americas',
                                                      Contract_Type__c='Ala Carte',Contract_Status__c='Submitted for Review',
                                                      Send_Review_Reminder__c='Weekly',Review_Sent_To_Email__c=strEmail, 
                                                      Review_Sent_To_Vendor__c=strVendor);
      insert mPlan;
      
      String strSch = '0 0 23 * * ?';
      ViperWeeklyReminderEmailScheduler schedulable = new ViperWeeklyReminderEmailScheduler();
      System.schedule('Test Schedule Class', strSch, schedulable);
      Test.stopTest();
      System.assert(True);

    } 
    
    public static testmethod void testViperDailyReminderEmailScheduler() {
      User user =[select id,name, email from user where IsActive= true limit 1];
      String strEmail = user.email+',test@test.com';
      String strVendor = user.name+',test@test.com';
      Test.startTest();
      Marketing_Plan__c mPlan = new Marketing_Plan__c(Name ='mPlan_daily',Fiscal_Quarter__c='FY12Q1',Region__c='Americas',
                                                      Contract_Type__c='Ala Carte',Contract_Status__c='Submitted for Review',
                                                      Send_Review_Reminder__c='Daily',Review_Sent_To_Email__c=strEmail, 
                                                      Review_Sent_To_Vendor__c=strVendor);
      insert mPlan;
      
      String strSch = '0 0 23 * * ?';
      ViperDailyReminderEmailScheduler schedulable = new ViperDailyReminderEmailScheduler();
      System.schedule('Test Schedule Class', strSch, schedulable);
      Test.stopTest();
      System.assert(True);

    } 
}