/*
History:
Version     Date            Modified By     CR          Description     
--------------------------------------------------------------------------------------
1.0         11-November-2019     TTI               Scheduler class to empty Recycle Bin for System_Behavior_Bypasser__c
*/

global class BatchEmptyRecycleBinBypasserSchedule implements schedulable{
    global void execute (SchedulableContext SC){
        string strquery;
        //1.0 - Added Column Account Owner ID
        strquery = 'select id from System_Behavior_Bypasser__c where isDeleted = true all rows';        
                 
                 
                 BatchEmptyRecycleBinBypasser Batchbypasser = new BatchEmptyRecycleBinBypasser();                    
                 Batchbypasser.strquery= strquery; 
                 database.executebatch(Batchbypasser,200);  
    } 
  
}