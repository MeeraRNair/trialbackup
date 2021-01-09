global class BatchUserManagerUpdateScheduler implements Schedulable{
   global void execute(SchedulableContext SC) {
      BatchUserManagerUpdate userBatchRecord = new BatchUserManagerUpdate ();
      DateTime dt = system.Today();
      String formatedDt = dt.format('yyyy-MM-dd\'T\'HH:mm:Ss\'Z\'');
      
      userBatchRecord.query = 'SELECT Integrated_User__c, CreatedDate,'+
                              ' badge_number__c, direct_manager_badge_number__c,'+
                              ' Direct_Manager_Name__c,employee_status__c, '+
                              ' terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c , '+
                              ' Manager_Changed__c'+
                              ' FROM peoplesoft_user_view__c'+ 
                              ' WHERE ((Manager_Changed__c = TRUE OR '+
                              ' CreatedDate >= '+formatedDt+')'+ 
                              ' AND Badge_Number__c != NULL AND ' +
                              ' Direct_Manager_Badge_Number__c  != NULL)';
                             
      system.debug('###userBatchRecord.query####' +userBatchRecord.query);
      //database.executebatch(userBatchRecord,5); 
      integer recordCount  = integer.ValueOf(System.Label.UserTerminationBatchSize);
      database.executebatch(userBatchRecord,recordCount); 
   }
}