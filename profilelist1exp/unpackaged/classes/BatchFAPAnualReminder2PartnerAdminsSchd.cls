/*
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12485    16.12       16 Dec 2015     Dipin Raju      Scheduler class to trigger FAP Annual reminder to Partner Admins
 * 
 */
 
global class BatchFAPAnualReminder2PartnerAdminsSchd implements schedulable{
    global void execute (SchedulableContext SC){
        BatchFAPAnualReminder2PartnerAdmins batchFapReminder = new BatchFAPAnualReminder2PartnerAdmins();         
        database.executebatch(batchFapReminder);
    }
}