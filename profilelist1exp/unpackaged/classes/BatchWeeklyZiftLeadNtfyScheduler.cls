/*
 * Author   : Ismail
 * Purpose  : The scheduler class to call  BatchWeeklyZiftLeadNotifification batch class.
 *        
 * Revision    CR-No       Release-No    Date            Modified By     Description
 * --------  ---------   ------------   ----------     ------------    -----------
 * 1.0        16838        FY20-0202     9/1/2019
 * 
*/

global class BatchWeeklyZiftLeadNtfyScheduler implements schedulable{
    global void execute (SchedulableContext sc){
        BatchWeeklyZiftLeadNotifification batchLeadEmail = new BatchWeeklyZiftLeadNotifification();         
        database.executebatch(batchLeadEmail, 200);
    }
}