/*************************************************************************************************************
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Jiji        5-July-2013     14.5        8413    Batch Apex to Update 
                                                            ISM/RSM/Director/Manager 
                                                            Employees Status of 
                                                            Terminated Users
-------------------------------------------------------------------------------------------                               
************************************************************************************************************/
global class BatchEmployeeStatusUpdateScheduler implements Schedulable{
   global void execute(SchedulableContext SC) {
      BatchEmployeeStatusUpdate batchRecord = new BatchEmployeeStatusUpdate ();
      DateTime dt = system.Today();
            
      batchRecord.query = 'SELECT Integrated_User__c, CreatedDate,'+
                          ' badge_number__c, Direct_Manager_Name__c, ' +
                          ' Employee_Name__c,'+
                          ' ISM_Badge__c, Employee_Status__c,' +
                          ' RSM_Badge__c, Director_Badge__c, '+
                          ' Direct_Manager_Badge_Number__c, '+
                          ' Terminated_In_SFDC__c '+
                          ' FROM peoplesoft_user_view__c '+ 
                          ' WHERE (employee_status__c = \'Terminated\' AND'+
                          ' terminated_in_sfdc__c = \'No\' )';
      
      system.debug('###batchRecord.query####' +batchRecord.query);
      //database.executebatch(batchRecord,5); 
      integer recordCount  = integer.ValueOf(System.Label.UserTerminationBatchSize);
      database.executebatch(batchRecord,recordCount);
   }
}