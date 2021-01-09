/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
2.0         13243      	FY17-DCS-0703  	16-June-2016	Sarah           Adding "Acquisition Code" field in UserBatchrecord.query
3.0         14468       FY18-DCS-1001   29-May-2017     Krishna         Adding "HR Region" field for field extraction and mapping in PeopleSoft User View object
3.1			14595		FY18-DCS-1001	04-Jul-2017		Gan				Adding "EMC Employee Number" field for field extraction and mapping in PeopleSoft User View object
4.0			16956		FY20-DCS-0202   26-Dec-2018		Gan				Adding "HR_Job_Title__c" field
*/   





global class BatchUserHRUpdateScheduler implements Schedulable{
   global void execute(SchedulableContext SC) {
      BatchUserHRUpdate userBatchRecord = new BatchUserHRUpdate ();
      
      // to be use for 365 days 
      Datetime dt=System.today().addDays(-365);
      String formatedDt = dt.format('yyyy-MM-dd\'T\'HH:mm:Ss\'Z\'');
      
      userBatchRecord.query = 'SELECT Integrated_User__c, CreatedDate,'+
                              ' badge_number__c, Acquisition_Code__c, direct_manager_badge_number__c,'+//2.0
                              ' Direct_Manager_Name__c,employee_status__c, '+
                              ' terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c , '+
                              ' HR_Director_Name__c, HR_Job_Function_Desc__c, '+
                              ' HR_Location_City__c, HR_Location_Country_Desc__c, '+
                              ' HR_Location_Long_Desc__c, HR_Location_State_Desc__c, '+
                              ' HR_Manager_Badge__c, HR_Manager_Email__c,'+
                              ' HR_Manager_Name__c, HR_People_Manager__c, '+
                              ' HR_Sales_Indicator__c, HR_Second_Level_Manager_Name__c, '+
                              ' HR_Senior_VP_Name__c, HR_Third_Level_Manager_Name__c, '+
                              ' HR_VP_Name__c,HR_Region__c, EMC_Employee_Number__c, '+ //3.1
                              ' HR_Job_Title__c '+ //4.0
                              ' FROM peoplesoft_user_view__c'+ 
                              ' WHERE ((HR_Info_Updates__c = TRUE OR '+
                              ' CreatedDate >= '+formatedDt+')'+ 
                              ' AND Badge_Number__c != NULL AND ' +
                              ' Direct_Manager_Badge_Number__c  != NULL)';
                              
                              
                              // backup 365 days
                              //' WHERE CreatedDate >= '+formatedDt+''+
                              //' AND Badge_Number__c != NULL';
                              
                             
      system.debug('###userBatchRecord.query####' +userBatchRecord.query);
      //database.executebatch(userBatchRecord,5); 
      integer recordCount  = integer.ValueOf(System.Label.UserTerminationBatchSize);
      database.executebatch(userBatchRecord,recordCount); 
   }
}