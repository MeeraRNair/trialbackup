/* 
History:
Version     Date                Modified By                     CR          Description     
--------------------------------------------------------------------------------------
1.0         16-May-2016         Noorul Syuhada                  13094       Story 1120079:Update HR email changes automatically in SFDC
*/


@isTest
private class BatchUserEmailUpdateTest {
    static testMethod void UserEmailUpdateTest() {


        Profile AdminProfile = [select Id, Name from Profile where Name LIKE 'System Administrator' Limit 1];
        User AdminUser1 = [select Id from User where System_Admin_or_Delegated_User_Admin__c = TRUE AND ProfileId = :AdminProfile.Id AND IsActive = TRUE Limit 1];

        User userRecords1 = new User(FirstName='Test',IsActive = TRUE,
                               LastName='TestUser1', Title='CEO', UserName='TU_BatchTestAdmin1@test.com',
                               Is_SSO_User__c = TRUE,
                               Is_Integrated_User__c = TRUE,
                               Email='TU_BatchTestAdmin1@dell.com', 
                               Old_Email__c='TU_BatchTestAdmin_old1@dell.com', 
                               Alias='tBatch1', CommunityNickName='tBatch1', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='tBatch1', 
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords1;
        User userRecords2 = new User(FirstName='Test2',IsActive = TRUE,
                               LastName='TestUser2', Title='CEO', UserName='TU_BatchTestAdmin2@test.com',
                               Is_SSO_User__c = TRUE,
                               Is_Integrated_User__c = TRUE,
                               Email='TU_BatchTestAdmin2@dell.com', 
                               Old_Email__c='TU_BatchTestAdmin_old2@dell.com', 
                               Alias='tBatch2', CommunityNickName='tBatch2', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='tBatch2', 
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords2;
        User userRecords3 = new User(FirstName='Test3',IsActive = TRUE,
                               LastName='TestUser3', Title='CEO', UserName='TU_BatchTestAdmin3@test.com',
                               Is_SSO_User__c = TRUE,
                               Is_Integrated_User__c = TRUE,
                               Email='TU_BatchTestAdmin3@dell.com', 
                               Old_Email__c='TU_BatchTestAdmin_old3@dell.com', 
                               Alias='tBatch3', CommunityNickName='tBatch3', 
                               ProfileId = AdminProfile.Id,
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='tBatch3', 
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords3;
        Peoplesoft_User_View__c psRecords = new Peoplesoft_User_View__c(
                                            Badge_Number__c =userRecords1.badge_number__c,
                                            email_address__c =userRecords1.email,
                                            Employee_Status__c ='Active');
                         
        insert psRecords;
        Peoplesoft_User_View__c psRecords2 = new Peoplesoft_User_View__c(
                                            Badge_Number__c =userRecords2.badge_number__c,
                                            email_address__c =userRecords2.Old_Email__c,
                                            Employee_Status__c ='Active');
                         
        insert psRecords2;
        
        System.debug('----testtesttest-----'+psRecords);
        /*
        PermissionSet ssoPS = [SELECT ID From PermissionSet WHERE Name = 'SSO_Enabled_Permission'];
                                
        List<PermissionSetAssignment> lstPSAssignment = new List<PermissionSetAssignment>();
            
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
        psa1.AssigneeId = userRecords1.Id;
        psa1.PermissionSetId = ssoPS.Id;
        lstPSAssignment.add(psa1);
                
        PermissionSetAssignment psa2 = new PermissionSetAssignment();
        psa2.AssigneeId = userRecords2.Id;
        psa2.PermissionSetId = ssoPS.Id;
        lstPSAssignment.add(psa2);
        
        PermissionSetAssignment psa3 = new PermissionSetAssignment();
        psa3.AssigneeId = userRecords3.Id;
        psa3.PermissionSetId = ssoPS.Id;
        lstPSAssignment.add(psa3);
        
        insert lstPSAssignment;
                */
                
        System.runAs(AdminUser1){
            Test.startTest();
            
            BatchUserEmailUpdate userBatchRecord = new BatchUserEmailUpdate();
            Datetime theDate=System.today().addDays(-365);
            Id batchprocessid = database.executebatch(userBatchRecord,200);
            Test.stopTest();
        }
    }       
   
    static testMethod void ErrorFuncTest(){
    
        Test.startTest();
            
        BatchUserEmailUpdate userBatchRecord = new BatchUserEmailUpdate();
        userBatchRecord.handleError(new CustomException('Test Exception Desc'));
        
        Test.stopTest();
                
    }
    
    public class CustomException extends Exception {}

    static testMethod void BatchUserEmailUpdateSchedulerTest() {
            Test.startTest();
            String CRON_EXP = '0 0 0 * * ?';
            BatchUserEmailUpdateScheduler sch = new BatchUserEmailUpdateScheduler();
            String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            //Verify the expressions are the same
            System.assertEquals(CRON_EXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
    }
    
}