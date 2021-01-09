/*
* Author  : Harsha Chadalavada
* Purpose : To display Account Revenue Trends Information.
* 
* Revision   CR Number     Release No  Date            Modified By     Description
* --------   ---------     ----------  -----------     ------------    -----------
*  1.0       CR16317       FY19-0902   7-Aug-2018     Harsha          Created class to calculate schudeled quarter revenue from OpportunityLineItemSchedule
*  1.1       CR16563       FY19-1101   27-Sep-2018    Harsha          Batch size to execute can be changed from custom metadata.
*/
global class BatchOLIScheduleRevenueQtrCalc_Scheduler  implements schedulable {

    global void execute (SchedulableContext SC){
        Schedule_Revenue_Batch_Setting__mdt srbs = [select id,BatchSize__c from Schedule_Revenue_Batch_Setting__mdt limit 1];
        integer batchSize = integer.valueof(srbs.BatchSize__c);
        BatchOLIScheduleRevenueQtrCalc oliSchRevExcecute = new BatchOLIScheduleRevenueQtrCalc();
        Id batchinstanceid = database.executeBatch(oliSchRevExcecute,batchSize);
        System.debug('###DEBUG### batchinstanceid ' + batchinstanceid);
    }
    
}