/*
History:
Version     Date            Modified By     CR          Description     
--------------------------------------------------------------------------------------
1.0         11-November-2019     TTI               Batch class to empty Recycle Bin for System_Behavior_Bypasser__c
*/
global class BatchEmptyRecycleBinBypasser implements Database.Batchable<sObject>{
    
    public String strquery;
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //query to return all expired Case Share records        
        return Database.getQueryLocator(strquery);
    } 
       
    global void execute(Database.BatchableContext BC, list<sObject> scope)
    {     
      System.debug('## deleting '+scope.size()+' bypasser records'); 
        try{
            Database.emptyRecycleBin(scope);
        }
        catch(Exception exp){
            System.debug('Exception occured while removing records from Recycle Bin'+exp.getMessage());
        }
        
    }
        
    global void finish(Database.BatchableContext BC) 
    {
        System.debug('## Batch Job Finished ##');     
     }
}