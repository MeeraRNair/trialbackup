/*********************************************************************************************
Author: Emily Chiong

History:
Revision CR Number   Release No      Date            Modified By     Description
----------------------------------------------------------------------------------------------
1.0      CR13165     FY17-DCS-0701   26-May-2016     Emily           Batch job to delete Mobile records older than 90 days or created by test users

**********************************************************************************************/

global class BatchDeleteSF1AdoptionScheduler implements Schedulable{
    public integer intLastDays = Integer.ValueOf(System.Label.SF1_Adoption_Data_Retention);        
            
    public String strSQL = 'SELECT ID '+
                            'FROM SF1_Adoption__c '+
                            'WHERE (Source__c = \'Mobile\' AND User_Edited_Date__c < last_n_days:' + intLastDays +') '+
                            'OR (User_Name__r.Alias = \'x1d3g433\') LIMIT 10000';  
                            
    global void execute(SchedulableContext SC){         
        
        integer intBatchSize = Integer.ValueOf(System.Label.SF1_Adoption_Batch_Size);
        date dtStartDate = Date.today().addDays(-intLastDays);        
        
        system.debug('###DEBUG### intLastDays: ' + intLastDays);
        system.debug('###DEBUG### intBatchSize: ' + intBatchSize);
        system.debug('###DEBUG### dtStartDate: ' + dtStartDate);        
        
        integer intRecordCount = [SELECT count() FROM SF1_Adoption__c
                                    WHERE  (Source__c = 'Mobile' AND User_Edited_Date__c <: dtStartDate) 
                                    OR (User_Name__r.Alias = 'x1d3g433')];        
        
        BatchDeleteSF1Adoption batchRecord = new BatchDeleteSF1Adoption();
        batchRecord.strQuery = strSQL;  
        
        if(intRecordCount > 10000){
            batchRecord.bReRun = true;
        }
        else
        {
            batchRecord.bReRun = false;
        }
                                  
        system.debug('###DEBUG### batchRecord.strQuery: ' + batchRecord.strQuery);
          
        database.executebatch(batchRecord, intBatchSize);     
    }
}