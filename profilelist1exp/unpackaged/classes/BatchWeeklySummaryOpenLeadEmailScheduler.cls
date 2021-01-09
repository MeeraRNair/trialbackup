/*
 * Author   : Azwanti
 * Purpose  : The scheduler class to call BatchWeeklySummaryOpenLeadEmail batch class.
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 11840    MAJ16.10    18-Aug-2015     Azwanti         scheduler class to call BatchWeeklySummaryOpenLeadEmail batch class
 * 2.0		CR 13068	FY17-DCS-0502	19-Apr-2016	Azwanti			added custom label to configure the batch size as config step.
*/ 

global class BatchWeeklySummaryOpenLeadEmailScheduler implements schedulable{
    global void execute (SchedulableContext SC){
        BatchWeeklySummaryOpenLeadEmail batchLeadEmail = new BatchWeeklySummaryOpenLeadEmail();         
        database.executebatch(batchLeadEmail, Integer.valueOf(System.Label.LM2_BatchJobSize));
    }
}