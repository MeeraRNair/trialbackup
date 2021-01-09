/*
 * Author  : Gan
 * Purpose : BatchUserTerminationWeekly_Test created base on the BatchUserTermination_Test 
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      15073       FY18-DCS-0102   22-Dec-2017     Gan                                                                     
 * 2.0		15610		FY19-DCS-0502	10-Apr-2018		Gan				restructure the query for unit test to pass
 
 */

@isTest
public class BatchUserTerminationWeekly_Test {

    static testMethod void test_UserTermination_terminate() {
        DateTime dtToday = system.Today();
        String strFormatedDts = dtToday.format('yyyy-MM-dd');
        
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
                               System_Admin_or_Delegated_User_Admin__c = TRUE,
                               Due_to_Deactivate__c = Date.today(),
                               Integration_User_Flag__c = 'Y'
                                );
                                                                                                                                     
        insert objUserRecords4;
		TriggerExecutionController.setSkipAccountTriggers(True);
        Account objAcc = new Account();
    	objAcc.Name = 'testAccount';
    	insert objAcc;
        
        AccountShare objAccShare = new AccountShare();
        objAccShare.UserOrGroupId = objUserRecords4.Id;
        objAccShare.RowCause = 'Manual';
        objAccShare.AccountAccessLevel = 'Read';
        objAccShare.OpportunityAccessLevel = 'Read';
        objAccShare.CaseAccessLevel = 'Read';
        objAccShare.AccountId = objAcc.Id;
        insert objAccShare;
        TriggerExecutionController.setSkipAccountTriggers(False);
        
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
            BatchUserTerminationWeekly  batchRecord3 = new BatchUserTerminationWeekly();
            batchRecord3.strQuery = 'select License_Used__c, Badge_Number__c,email,username, Title, userRoleId, IsActive, Due_to_Deactivate__c'+
                              ' FROM user'+ 
                              ' WHERE id = \''+ objUserRecords4.id + '\' AND Due_to_Deactivate__c <= ' + strFormatedDts +
                              ' and IsActive = TRUE AND License_Used__c != \'Guest User License\' ';
            Id idBatchProcess = database.executebatch(batchRecord3,1);
            Test.stopTest();
            
            User objUserToVerify = [Select isactive, Due_to_Deactivate__c from user where id = :objUserRecords4.id];
            system.assertEquals(false, objUserToVerify.isactive);
            system.assertEquals(null, objUserToVerify.Due_to_Deactivate__c);
        }
    }
    
    static testMethod void test_UserTerminationWithSameTermUsername() {
        DateTime dtToday = system.Today();
        String strFormatedDts = dtToday.format('yyyy-MM-dd');
        
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
                               System_Admin_or_Delegated_User_Admin__c = TRUE,
                               Due_to_Deactivate__c = Date.today(),
                               Integration_User_Flag__c = 'Y'
                                );
                                                                                                                                     
        insert objUserRecords4;
        
        User objUserRecords5 = new User(FirstName='Test Batch5555 ',IsActive = FALSE,
                               LastName='Test5555', Title='CEO', UserName='UT_BatchTestAdmin4@test.com.terminated',
                               Email='UT_BatchTestAdmin555@dell.com', 
                               Alias='utgba5', CommunityNickName='utgb555', 
                               ProfileId = objAdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='ut55'+System.currentTimeMillis(), 
                               System_Admin_or_Delegated_User_Admin__c = TRUE
                               );
                                                                                                                                     
        insert objUserRecords5;

        
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
            BatchUserTerminationWeekly  batchRecord3 = new BatchUserTerminationWeekly();
            batchRecord3.strQuery = 'select License_Used__c, Badge_Number__c,email,username, Title, userRoleId, IsActive, Due_to_Deactivate__c'+
                              ' FROM user'+ 
                              ' WHERE id = \''+ objUserRecords4.id + '\' AND Due_to_Deactivate__c <= ' + strFormatedDts +
                              ' and IsActive = TRUE AND License_Used__c != \'Guest User License\' ';
            Id idBatchProcess = database.executebatch(batchRecord3,5);
            Test.stopTest();
            
            User objUserToVerify = [Select isactive, Due_to_Deactivate__c from user where id = :objUserRecords4.id];
            system.assertEquals(false, objUserToVerify.isactive);
            system.assertEquals(null, objUserToVerify.Due_to_Deactivate__c);
        }
    }
    static testMethod void exception_UserTerminationTest() {
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
                               System_Admin_or_Delegated_User_Admin__c = TRUE,
                               Due_to_Deactivate__c = Date.today());
                                                                                                                                     
        insert objUserRecords4;
        User objUserRecords3 = new User(FirstName='Test Batch ',IsActive = TRUE,
                               LastName='Test3333', Title='CEO', UserName='UT_BatchTestAdmin3@test.com',
                               Email='UT_BatchTestAdmin3333@dell.com', 
                               Alias='utg33', CommunityNickName='utg33', 
                               ProfileId = objAdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', 
                               TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='ut33'+System.currentTimeMillis(), 
                               Director__c = objUserRecords4.Id,
                               //Manual_Integrated_User__c = 'Yes',
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert objUserRecords3;
        System.Debug('----gtggggggggg--'+objUserRecords3);
        
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
            BatchUserTerminationWeekly  batchRecord3 = new BatchUserTerminationWeekly();
            batchRecord3.strQuery = 'select License_Used__c, Badge_Number__c,email,username, Title, userRoleId, IsActive, Due_to_Deactivate__c'+
                              ' FROM user'+ 
                			  ' WHERE id = \''+ objUserRecords4.id + '\' AND Due_to_Deactivate__c <= ' + strFormatedDts +
                              ' and IsActive = TRUE AND License_Used__c != \'Guest User License\' ';
            Id idBatchProcess = database.executebatch(batchRecord3,5);
            Test.stopTest();
            
            User objUserToVerify = [Select isactive, Due_to_Deactivate__c from user where id = :objUserRecords4.id];
            system.assertEquals(true, objUserToVerify.isactive);
            system.assertEquals(dtToday, objUserToVerify.Due_to_Deactivate__c);
        }
    }
    
    static testMethod void testBatchUserTerminationWeeklyScheduler() {
            Test.startTest();
            String CRON_EXP = '0 0 0 * * ?';
            BatchUserTerminationWeeklyScheduler  sch = new BatchUserTerminationWeeklyScheduler();
        	//2.0
        	sch.strSql = 'select License_Used__c, Badge_Number__c,email,username, Title, userRoleId, IsActive, Due_to_Deactivate__c FROM user WHERE Due_to_Deactivate__c != null AND IsActive = TRUE AND License_Used__c != \'Guest User License\' limit 1 ';
            String strJobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :strJobId];
            //Verify the expressions are the same
            System.assertEquals(CRON_EXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
    }
}