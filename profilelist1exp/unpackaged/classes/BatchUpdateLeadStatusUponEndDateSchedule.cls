/* ------------------------------------------------------------------------------------------------------------------------
Version   Date             CR     	By                Purpose
1.0       18 Aug 2015      11856    Dipin Raju    Auto close all open direct leads based on Campaign field  Close Date for Leads
2.0		  30-June-2016	   13216	Azwanti			LM3_13- Fix CR11856 close date default value not updating existing leads after change	
--------------------------------------------------------------------------------------------------------------------------- */

global class BatchUpdateLeadStatusUponEndDateSchedule implements schedulable{
    global void execute (SchedulableContext SC){      
        
        BatchUpdateLeadStatusUponEndDate batchCloseLead = new BatchUpdateLeadStatusUponEndDate();          
        ID batchprocessid = Database.executeBatch(batchCloseLead,200);
        
    }
}