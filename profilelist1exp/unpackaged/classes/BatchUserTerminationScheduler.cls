global class BatchUserTerminationScheduler implements Schedulable{
	public Boolean reschedule = true;
	public Boolean freezeUser = true;
	public String sql = ' SELECT Integrated_User__c, Employee_Profile__c, CreatedDate, badge_number__c, direct_manager_badge_number__c,Direct_Manager_Name__c, employee_status__c, terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c, Manager_Changed__c'+
                          ' FROM peoplesoft_user_view__c '+
                          ' WHERE (employee_status__c = \'Terminated\' AND terminated_in_sfdc__c = \'No\' AND '+
                          ' ((Integrated_User__c = \'No\' AND Assignment_Flag__c = FALSE ) '+
                          ' OR (Due_to_Deactivate_SFDC_Access__c <= TODAY '+                           
					      ' AND Due_to_Deactivate_SFDC_Access__c != NULL )))'+
					      ' ORDER BY Integrated_User__c, Employee_Profile__c';	
					      
					      
   global void execute(SchedulableContext SC) {
      BatchUserTermination batchRecord = new BatchUserTermination ();
      DateTime dt = system.Today();
      String formatedDts = dt.format('yyyy-MM-dd');
      system.debug('###formatedDt####' +formatedDts);      
           
      batchRecord.reschedule = reschedule;
      batchRecord.freezeUser = freezeUser;
      batchRecord.query = sql;      
      system.debug('###batchRecord.query####' +batchRecord.query);
      
      if (reschedule && freezeUser){
	  	batchRecord.nextQuery = ' SELECT Integrated_User__c, Employee_Profile__c, CreatedDate, badge_number__c, direct_manager_badge_number__c,Direct_Manager_Name__c, employee_status__c, terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c, Manager_Changed__c'+
                          ' FROM peoplesoft_user_view__c '+
                          ' WHERE (employee_status__c = \'Terminated\' AND terminated_in_sfdc__c = \'No\' AND '+
                          ' ((Integrated_User__c = \'No\' AND Assignment_Flag__c = FALSE ) '+
                          ' OR((Due_to_Deactivate_SFDC_Access__c <= '+formatedDts+') AND Due_to_Deactivate_SFDC_Access__c != NULL )) '+
					      ' AND (Integrated_User__c = \'No\' AND Employee_Profile__c like \'%Chatter%\'))';		
	  }
	  	  
	  if (reschedule && !freezeUser){
	  	batchRecord.nextQuery = ' SELECT Integrated_User__c, Employee_Profile__c, CreatedDate, badge_number__c, direct_manager_badge_number__c,Direct_Manager_Name__c, employee_status__c, terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c, Manager_Changed__c'+                          
					        ' FROM peoplesoft_user_view__c '+                           
					        // Add Check for Assignment Flag                          
					        /*                          
					        ' WHERE (employee_status__c = \'Terminated\' AND terminated_in_sfdc__c = \'No\' AND '+                          
					        ' (Integrated_User__c = \'No\' OR (Integrated_User__c = \'Yes\' AND '+                          
					        ' (Due_to_Deactivate_SFDC_Access__c <= '+formatedDts+')'+                           
					        '  AND Due_to_Deactivate_SFDC_Access__c != NULL )))';*/                          
					        ' WHERE (employee_status__c = \'Terminated\' AND terminated_in_sfdc__c = \'No\' AND '+                          
					        ' ((Integrated_User__c = \'No\' AND Assignment_Flag__c = FALSE ) '+                          
					        //' OR (Integrated_User__c = \'Yes\' AND '+                          
					        ' OR((Due_to_Deactivate_SFDC_Access__c <= '+formatedDts+') AND Due_to_Deactivate_SFDC_Access__c != NULL ))'+                           
					        ' AND ((Integrated_User__c = \'No\' AND (NOT Employee_Profile__c like \'%Chatter%\') AND (NOT Employee_Profile__c like \'%Dell Integration UNKNOWN%\'))'+
					        ' OR (Integrated_User__c = \'Yes\' AND (NOT Employee_Profile__c like \'%Dell Integration UNKNOWN%\'))))' +
					        ' ORDER BY Integrated_User__c, Employee_Profile__c';
	  }	
      
      //database.executebatch(batchRecord,5); 
      integer recordCount  = integer.ValueOf(System.Label.UserTerminationBatchSize);
      database.executebatch(batchRecord,recordCount);
   }
}