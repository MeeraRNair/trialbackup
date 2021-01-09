@isTest
private class BatchUserManagerUpdate_Test {
    static testMethod void managerUpdateTest() {
    //Insert CMAP Batch Apex User
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
         User AdminUser1 = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :AdminProfile.Id AND IsActive = TRUE Limit 1];

        User userRecords1 = new User(FirstName='Test Batch ',IsActive = TRUE,
                               LastName='Test0', Title='CEO', UserName='UT_BatchTestAdmin0@test.com',
                               Email='UT_BatchTestAdmin0@dell.com', 
                               Alias='utgba0', CommunityNickName='utgbta0', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgbta0', 
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords1;
        User userRecords2 = new User(FirstName='Test Batch ',IsActive = TRUE,
                               LastName='Test2', Title='CEO', UserName='UT_BatchTestAdmin1@test.com',
                               Email='UT_BatchTestAdmin2@dell.com', 
                               Alias='utgba2', CommunityNickName='utgbta2', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgbta2', Manual_Integrated_User__c = 'Yes',
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords2;
        Peoplesoft_User_View__c psRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =userRecords1.badge_number__c,
                               Employee_Status__c ='Active',
                               Direct_Manager_Name__c = 'Test2 Test Batch',
                               Direct_Manager_Badge_Number__c = userRecords2.Badge_Number__c
                                                              
                               );
                         
        insert psRecords;
        Peoplesoft_User_View__c dupePsRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =userRecords2.badge_number__c,
                               Employee_Status__c ='Active',
                               Direct_Manager_Name__c = 'Test2 Test Batch',
                               Direct_Manager_Badge_Number__c = userRecords1.badge_number__c
                                                              
                               );
                         
        insert dupePsRecords ;
        System.debug('----jjjjj-----'+psRecords);
        System.runAs(AdminUser1){
            Test.startTest();
            BatchUserManagerUpdate userBatchRecord = new BatchUserManagerUpdate();
            DateTime dt = system.Today();
            String formatedDt = dt.format('yyyy-MM-dd\'T\'HH:mm:Ss\'Z\'');
            userBatchRecord.query = 'SELECT CreatedDate, badge_number__c, direct_manager_badge_number__c,Direct_Manager_Name__c,employee_status__c, terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c, Manager_Changed__c'+
                              ' FROM peoplesoft_user_view__c'+ 
                              ' WHERE (( Manager_Changed__c = TRUE OR '+
                              ' CreatedDate >= '+formatedDt+')'+ 
                              ' AND Badge_Number__c != NULL AND ' +
                              ' Direct_Manager_Badge_Number__c  != NULL)';
            Id batchprocessid = database.executebatch(userBatchRecord,5);
            Test.stopTest();
        }
    }       
   
    static testMethod void BatchUserManagerUpdateSchedulerTest() {
            Test.startTest();
            String CRON_EXP = '0 0 0 * * ?';
            BatchUserManagerUpdateScheduler sch = new BatchUserManagerUpdateScheduler();
            String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            //Verify the expressions are the same
            System.assertEquals(CRON_EXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
    }
    
}