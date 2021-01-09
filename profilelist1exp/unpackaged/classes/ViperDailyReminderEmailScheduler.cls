/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 17969    FY20-1002   20/08/2019      Niveda        Created - Scheduler class to send reminder mails - VIPER
 * 
 */
 
global class ViperDailyReminderEmailScheduler implements Schedulable{
    //execute method for scheduler
    global void execute(SchedulableContext sc) {
       
        Batch_ViperSendReminderEmail batchCls= new Batch_ViperSendReminderEmail();
        //Define query for batch
        String strStatus = 'Submitted for Review';
        String strFrequency= 'Daily';
        String strQuery = 'select Id, Contract_Status__c , Product_Manager__c ,Vendor__r.name,Review_Sent_To_Vendor__c,Fiscal_Quarter__c,Review_Sent_To_Email__c, Vendor__c, Name,Owner.name from Marketing_Plan__c where Review_Sent_To_Vendor__c != null  AND Contract_Status__c = \''+strStatus+ '\' AND Send_Review_Reminder__c = \''+strFrequency+'\'';
        System.debug('**strQuery **'+strQuery );
        batchCls.strQuery = strQuery;
        Database.executeBatch(batchCls, 100);
    }

}