@isTest
private class BatchEmployeeStatusUpdate_Test {
    static list<user> listuser;
    static testMethod void employeeStatusUpdateTest() {
    //Insert CMAP Batch Apex User
   // listuser = [select id,Badge_Number__c from user where IsActive = TRUE Limit 2 ];
        list<user> listuser = TestDataFactory.CreateNGenralUsers(3);
        listuser[1].Badge_Number__c='empStat22';
        listuser[2].Badge_Number__c='eStatus';
        insert listuser;

   /*     Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User AdminUser1 = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :AdminProfile.Id AND IsActive = TRUE Limit 1];

        User userBatchRecords1 = new User(FirstName='Test Employee Status Batch ',IsActive = TRUE,
                               LastName='emp0', Title='CEO', UserName='UT_emplStatus@test.com',
                               Email='UT_empStatusAdmin0@dell.com', 
                               Alias='empStat', CommunityNickName='empStat0', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='empStat22', 
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userBatchRecords1;
        User userBatchRecords2 = new User(FirstName='Test Status Batch ',IsActive = TRUE,
                               LastName='Testing2', Title='CEO', UserName='UT_EmployeeStatus@test.com',
                               Email='UT_EmployeeStatus@dell.com', 
                               Alias='eStatus', CommunityNickName='eStatus', 
                               ProfileId = AdminProfile.Id,
                               ISM__c = userBatchRecords1.Id, 
                               RSM__c = userBatchRecords1.Id,
                               Director__c = userBatchRecords1.Id,
                               ManagerId = userBatchRecords1.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='eStatus', Manual_Integrated_User__c = 'Yes',
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userBatchRecords2;
		*/
        Peoplesoft_User_View__c psRecords1 = new Peoplesoft_User_View__c(
                               Badge_Number__c =listuser[1].badge_number__c,
                               Employee_Status__c ='Terminated'
                               //Terminated_In_SFDC__c = 'No'                                                              
                               );
                         
        insert psRecords1;
        Peoplesoft_User_View__c dupePsRecords1 = new Peoplesoft_User_View__c(
                               Badge_Number__c =listuser[2].badge_number__c,
                               Employee_Status__c ='Active',
                               Direct_Manager_Name__c = 'Test2 Test Batch',
                               Direct_Manager_Badge_Number__c = listuser[1].badge_number__c
                                                              
                               );
                         
        insert dupePsRecords1 ;
        system.assertEquals(dupePsRecords1.Direct_Manager_Name__c, 'Test2 Test Batch');
        System.debug('----jjjjj-----'+psRecords1);
        System.runAs(listuser[0]){
            Test.startTest();
            
            BatchEmployeeStatusUpdate userBatchRecord = new BatchEmployeeStatusUpdate();
            userBatchRecord.uniqueName = 'test1';
            DateTime dt = system.Today();
            String strformatedDt = dt.format('yyyy-MM-dd\'T\'HH:mm:Ss\'Z\'');
            userBatchRecord.query = 'SELECT Integrated_User__c, CreatedDate,'+
                          ' badge_number__c, Direct_Manager_Name__c, ' +
                          ' Employee_Name__c,'+
                          ' ISM_Badge__c, Employee_Status__c,' +
                          ' RSM_Badge__c, Director_Badge__c, '+
                          ' Direct_Manager_Badge_Number__c, '+
                          ' Terminated_In_SFDC__c '+
                          ' FROM peoplesoft_user_view__c '+ 
                          ' WHERE (employee_status__c = \'Terminated\' AND'+
                          ' terminated_in_sfdc__c = \'No\' )';
            Id batchprocessid = database.executebatch(userBatchRecord,5);
            Test.stopTest();
        }
    }       
   
    static testMethod void batchEmployeeStatusUpdateSchedulerTest() {
            Test.startTest();
            String strCRONEXP = '0 0 0 * * ?';
            BatchEmployeeStatusUpdatescheduler sch = new BatchEmployeeStatusUpdatescheduler();
            String strjobId = System.schedule('TestScheduledApex',strCRONEXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :strjobId];
            //Verify the expressions are the same
            System.assertEquals(strCRONEXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
    }
    
}