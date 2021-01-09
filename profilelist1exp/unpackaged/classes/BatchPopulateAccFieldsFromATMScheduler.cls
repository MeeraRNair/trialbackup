/*
 * Author   : Anuj Shah
 * Purpose  : Scheduler class for BatchPopulateAccFieldsFromATM
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      6742302     0802      12-JUN-2019     Anuj Shah        Scheduler class for BatchPopulateAccFieldsFromATM           

*/ 
global class BatchPopulateAccFieldsFromATMScheduler implements Schedulable
{
	global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new BatchPopulateAccFieldsFromATM(),Integer.ValueOf(Label.BatchPopulateAccFieldsFromATM_Batch_Size));
    }
}