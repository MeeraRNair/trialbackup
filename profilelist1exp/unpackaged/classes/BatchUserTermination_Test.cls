/*
 * Author  : 
 * Purpose : Test class to cover BatchUserTermination 
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0
 * 2.0      15073       FY18-DCS-0102   07-Dec-2017     Gan                                                                     

 
 */
@isTest
private class BatchUserTermination_Test {
    /*static testMethod void NonInt_UserTerminationTest() {
    //Insert CMAP Batch Apex User
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
         User adminu = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :AdminProfile.Id AND IsActive = TRUE Limit 1];
        
        User userRecords1 = new User(FirstName='Test Batch555 ',IsActive = TRUE,
                               LastName='Test550', Title='CEO', UserName='UT_BatchTestAdmin0@test.com',
                               Email='UT_BatchTestAdmin550@dell.com', 
                               Alias='utgba550', CommunityNickName='utgbta550', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgbta55550', 
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords1;
        Peoplesoft_User_View__c psRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =userRecords1.badge_number__c,
                               Employee_Status__c ='Terminated'
                               );
        insert psRecords;
        System.runAs(adminu){
            Test.startTest();
            BatchUserTermination batchRecord1 = new BatchUserTermination();
            batchRecord1.query = 'SELECT Integrated_User__c, CreatedDate, badge_number__c, direct_manager_badge_number__c,Direct_Manager_Name__c, employee_status__c, terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c, Manager_Changed__c'+
                       ' FROM peoplesoft_user_view__c '+ 
                       ' WHERE (employee_status__c = \'Terminated\' AND terminated_in_sfdc__c = \'No\')';
            Id batchprocessid = database.executebatch(batchRecord1,5);
            Test.stopTest();
        }
    }       
    static testMethod void Int_UserTerminationTest() {
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
         User AdminUser2 = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :AdminProfile.Id AND IsActive = TRUE Limit 1];
        
        User userRecords2 = new User(FirstName='Test Batch222 ',IsActive = TRUE,
                               LastName='Test2222', Title='CEO', UserName='UT_BatchTestAdmin1@test.com',
                               Email='UT_BatchTestAdmin2222@dell.com', 
                               Alias='utgba2222', CommunityNickName='utgbta2222', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgbta2222', Manual_Integrated_User__c = 'Yes',
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords2;
        Peoplesoft_User_View__c psRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =userRecords2.badge_number__c,
                               Employee_Status__c ='Terminated'
                               );
        insert psRecords;
        System.runAs(AdminUser2){
            Test.startTest();
            BatchUserTermination batchRecord2 = new BatchUserTermination();
            batchRecord2.query = 'SELECT Integrated_User__c, CreatedDate, badge_number__c, direct_manager_badge_number__c,Direct_Manager_Name__c, employee_status__c, terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c, Manager_Changed__c'+
                       ' FROM peoplesoft_user_view__c '+ 
                       ' WHERE (employee_status__c = \'Terminated\' AND terminated_in_sfdc__c = \'No\')';
            Id batchprocessid = database.executebatch(batchRecord2,5);
            Test.stopTest();
        }
    }*/
    
    //2.0
    static testMethod void test_UserTermination_freeze() {
        Profile objAdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        
        User objSysadmUser = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :objAdminProfile.Id AND IsActive = TRUE Limit 1];
        
        User objUserRecords4 = new User(FirstName='Test Batch4444 ',IsActive = TRUE,
                               LastName='Test4444', Title='CEO', UserName='UT_BatchTestAdmin4@test.com',
                               Email='UT_BatchTestAdmin4444@dell.com', 
                               Alias='utgba4', CommunityNickName='utgb444', 
                               ProfileId = objAdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='ut44'+System.currentTimeMillis(), 
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert objUserRecords4;
               
        DateTime dtToday = system.Today();
        String strFormatedDts = dtToday.format('yyyy-MM-dd');
        
        Peoplesoft_User_View__c objPsRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =objUserRecords4.badge_number__c,
                               Employee_Status__c ='Terminated',
                               Due_to_Deactivate_SFDC_Access__c = Date.today());
       
        insert objPsRecords ;
        Peoplesoft_User_View__c objPpsv1 = [select Id, terminated_in_sfdc__c,  employee_status__c, Due_to_Deactivate_SFDC_Access__c from Peoplesoft_User_View__c 
                           where id = :objPsRecords .id];
        
        system.debug('+++++++++++++++++++++=== ' + objPpsv1.Terminated_in_SFDC__c + ', ' + objPpsv1.Employee_Status__c + ', ' + objPpsv1.Due_to_Deactivate_SFDC_Access__c); 
        System.runAs(objSysadmUser){
            Test.startTest();
            BatchUserTermination batchRecord3 = new BatchUserTermination();
            batchRecord3.reschedule = false;
            batchRecord3.freezeUser = true;
            batchRecord3.query = 'SELECT Integrated_User__c, CreatedDate, badge_number__c, direct_manager_badge_number__c,Direct_Manager_Name__c, employee_status__c, terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c, Manager_Changed__c'+
                          ' FROM peoplesoft_user_view__c '+ 
                          ' WHERE (employee_status__c = \'Terminated\' AND terminated_in_sfdc__c = \'No\' AND badge_number__c =\'' + objUserRecords4.badge_number__c + '\' AND'+
                          ' ((Integrated_User__c = \'No\' AND Assignment_Flag__c = FALSE ) '+
                          ' OR((Due_to_Deactivate_SFDC_Access__c <= '+strFormatedDts+')'+ 
                          '  AND Due_to_Deactivate_SFDC_Access__c != NULL )))';
            Id idBatchProcess = database.executebatch(batchRecord3,5);
            Test.stopTest();
            
            User objUserToVerify = [Select isactive, Due_to_Deactivate__c from user where id = :objUserRecords4.id];
            system.assertEquals(true, objUserToVerify.isactive);
            system.assertEquals(Date.today(), objUserToVerify.Due_to_Deactivate__c);
        }
    }
    
    //2.0
    static testMethod void test_UserTermination_terminate() {
        Profile objAdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        
        User objSysadmUser = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :objAdminProfile.Id AND IsActive = TRUE Limit 1];
        
        User objUserRecords4 = new User(FirstName='Test Batch4444 ',IsActive = TRUE,
                               LastName='Test4444', Title='CEO', UserName='UT_BatchTestAdmin4@test.com',
                               Email='UT_BatchTestAdmin4444@dell.com', 
                               Alias='utgba4', CommunityNickName='utgb444', 
                               ProfileId = objAdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='ut44'+System.currentTimeMillis(), 
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert objUserRecords4;
               
        DateTime dtToday = system.Today();
        String strFormatedDts = dtToday.format('yyyy-MM-dd');
        
        Peoplesoft_User_View__c objPsRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =objUserRecords4.badge_number__c,
                               Employee_Status__c ='Terminated',
                               Due_to_Deactivate_SFDC_Access__c = Date.today());
       
        insert objPsRecords ;
        Peoplesoft_User_View__c objPpsv1 = [select Id, terminated_in_sfdc__c,  employee_status__c, Due_to_Deactivate_SFDC_Access__c from Peoplesoft_User_View__c 
                           where id = :objPsRecords .id];
        
        system.debug('+++++++++++++++++++++=== ' + objPpsv1.Terminated_in_SFDC__c + ', ' + objPpsv1.Employee_Status__c + ', ' + objPpsv1.Due_to_Deactivate_SFDC_Access__c); 
        System.runAs(objSysadmUser){
            Test.startTest();
            BatchUserTermination batchRecord3 = new BatchUserTermination();
            batchRecord3.reschedule = false;
            batchRecord3.freezeUser = false;
            batchRecord3.query = 'SELECT Integrated_User__c, CreatedDate, badge_number__c, direct_manager_badge_number__c,Direct_Manager_Name__c, employee_status__c, terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c, Manager_Changed__c'+
                          ' FROM peoplesoft_user_view__c '+ 
                          ' WHERE (employee_status__c = \'Terminated\' AND terminated_in_sfdc__c = \'No\' AND badge_number__c =\'' + objUserRecords4.badge_number__c + '\' AND'+
                          ' ((Integrated_User__c = \'No\' AND Assignment_Flag__c = FALSE ) '+
                          ' OR((Due_to_Deactivate_SFDC_Access__c <= '+strFormatedDts+')'+ 
                          '  AND Due_to_Deactivate_SFDC_Access__c != NULL )))';
            Id idBatchProcess = database.executebatch(batchRecord3,5);
            Test.stopTest();
            
            User objUserToVerify = [Select isactive, Due_to_Deactivate__c from user where id = :objUserRecords4.id];
            system.assertEquals(false, objUserToVerify.isactive);
            system.assertEquals(null, objUserToVerify.Due_to_Deactivate__c);
        }
    }
    
    static testMethod void exception_UserTerminationTest() {
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        
        User sysadmUser = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :AdminProfile.Id AND IsActive = TRUE Limit 1];
        
        User userRecords4 = new User(FirstName='Test Batch4444 ',IsActive = TRUE,
                               LastName='Test4444', Title='CEO', UserName='UT_BatchTestAdmin4@test.com',
                               Email='UT_BatchTestAdmin4444@dell.com', 
                               Alias='utgba4', CommunityNickName='utgb444', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgb4444', 
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords4;
        User userRecords3 = new User(FirstName='Test Batch ',IsActive = TRUE,
                               LastName='Test3333', Title='CEO', UserName='UT_BatchTestAdmin3@test.com',
                               Email='UT_BatchTestAdmin3333@dell.com', 
                               Alias='utg33', CommunityNickName='utg33', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', 
                               TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgb333', 
                               Director__c = userRecords4.Id,
                               //Manual_Integrated_User__c = 'Yes',
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords3;
        System.Debug('----gtggggggggg--'+userRecords3);
        Peoplesoft_User_View__c psRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =userRecords4.badge_number__c,
                               Employee_Status__c ='Terminated'
                               );
        insert psRecords;
        DateTime dt = system.Today();
        String formatedDts = dt.format('yyyy-MM-dd');
        System.runAs(sysadmUser){
            Test.startTest();
            BatchUserTermination batchRecord3 = new BatchUserTermination();
            batchRecord3.reschedule = false;
      		batchRecord3.freezeUser = false;
            batchRecord3.query = 'SELECT Integrated_User__c, CreatedDate, badge_number__c, direct_manager_badge_number__c,Direct_Manager_Name__c, employee_status__c, terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c, Manager_Changed__c'+
                          ' FROM peoplesoft_user_view__c '+ 
                		  ' WHERE (employee_status__c = \'Terminated\' AND terminated_in_sfdc__c = \'No\' AND badge_number__c =\'' + userRecords4.badge_number__c + '\' AND'+
                          ' ((Integrated_User__c = \'No\' AND Assignment_Flag__c = FALSE ) '+
                          ' OR((Due_to_Deactivate_SFDC_Access__c <= '+formatedDts+')'+ 
                          '  AND Due_to_Deactivate_SFDC_Access__c != NULL )))';
            Id batchprocessid = database.executebatch(batchRecord3,5);
            Test.stopTest();
            
            User objUserToVerify = [Select isactive from user where id = :userRecords4.id];
            system.assertEquals(true, objUserToVerify.isactive);
        }
    }
    static testMethod void BatchUserTerminationSchedulerTest() {
            Test.startTest();
            String CRON_EXP = '0 0 0 * * ?';
            BatchUserTerminationScheduler  sch = new BatchUserTerminationScheduler ();
            String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            //Verify the expressions are the same
            System.assertEquals(CRON_EXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
    }
    
}