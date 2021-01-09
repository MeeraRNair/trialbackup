/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
2.0         13243       FY17-DCS-0703   16-June-2016	Sarah			Adding Acquisition_Code__c field for testing in userRecords1 and userRecords2
2.0         13243       FY17-DCS-0703   16-June-2016	Sarah			Adding Acquisition_Code__c field in UserBatchRecord.query
3.0         14468       FY18-DCS-1001   29-May-2017     Krishna         Adding "HR Region" field field in UserBatchRecord.query and test record
3.1			14595		FY18-DCS-1001	04-Jul-2017		Gan				Adding "EMC Employee Number" field in UserBatchRecord.query and test record
4.0			16956		FY20-DCS-0202	26-Dec-2018		Gan				Adding "HR_Job_Title__c" field in UserBatchRecord.query and test record
*/   





@isTest
private class BatchUserHRUpdate_Test {
   
    static testMethod void HRUpdateTest() {

        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
         User AdminUser1 = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :AdminProfile.Id AND IsActive = TRUE Limit 1];

        User userRecords1 = new User(FirstName='Test Batch ',IsActive = TRUE,
                               LastName='Test0', Title='CEO', UserName='UT_BatchTestAdmin0@test.com',
                               Email='UT_BatchTestAdmin0@dell.com', 
                               Alias='utgba0', CommunityNickName='utgbta0', 
                               ProfileId = AdminProfile.Id,Acquisition_Code__c ='test1234',//2.0
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgbta0', 
                               HR_Job_Function_Desc__c='Test Federal Contract Services', HR_Location_City__c='Tennessee', HR_Manager_Badge__c='us12345', 
                               HR_Director_Name__c='DirTesting', HR_Location_Country_Desc__c='United States', HR_Location_Long_Desc__c='testGB LN London Office 02', 
                               HR_Location_State_Desc__c='Nashville', HR_Manager_Name__c='Dell, Test', 
                               HR_Second_Level_Manager_Name__c='Dell, Test2', HR_Senior_VP_Name__c='testSenior1', 
                               HR_Third_Level_Manager_Name__c='Dell, Test3', HR_VP_Name__c='testVP1',HR_Region__c = 'testRegion',//3.0
                               EMC_Employee_Number__c = 'EMC Test1', //3.1      
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords1;
        User userRecords2 = new User(FirstName='Test Batch ',IsActive = TRUE,
                               LastName='Test2', Title='CEO', UserName='UT_BatchTestAdmin1@test.com',
                               Email='UT_BatchTestAdmin2@dell.com', 
                               Alias='utgba2', CommunityNickName='utgbta2', 
                               ProfileId = AdminProfile.Id,Acquisition_Code__c ='1234test',//2.0
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgbta2', 
                               Manual_Integrated_User__c = 'Yes',
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
                                                                                                                                     
        insert userRecords2;
        Peoplesoft_User_View__c psRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =userRecords1.badge_number__c,
                               Employee_Status__c ='Active',
                               Direct_Manager_Name__c = 'Test2 Test Batch',
                               Direct_Manager_Badge_Number__c = userRecords2.Badge_Number__c,Acquisition_Code__c =userRecords1.Acquisition_Code__c,//2.0
                               HR_Job_Function_Desc__c='userRecords1.HR_Job_Function_Desc__c', HR_Location_City__c='userRecords1.HR_Location_City__c', HR_Manager_Badge__c='userRecords1.HR_Manager_Badge__c', 
                               HR_Director_Name__c='userRecords1.HR_Director_Name__c', HR_Location_Country_Desc__c='userRecords1.HR_Location_Country_Desc__c', HR_Location_Long_Desc__c='userRecords1.HR_Location_Long_Desc__c', 
                               HR_Location_State_Desc__c='userRecords1. HR_Location_State_Desc__c', HR_Manager_Name__c='userRecords1.HR_Manager_Name__c', 
                               HR_Second_Level_Manager_Name__c='userRecords1.HR_Second_Level_Manager_Name__c', HR_Senior_VP_Name__c='userRecords1.HR_Senior_VP_Name__c', 
                               HR_Third_Level_Manager_Name__c='userRecords1.HR_Third_Level_Manager_Name__c', HR_VP_Name__c='userRecords1.HR_VP_Name__c',HR_Region__c=userRecords1.HR_VP_Name__c, //3.0
            				   EMC_Employee_Number__c =userRecords1.EMC_Employee_Number__c //3.1
                               );
                         
        insert psRecords;
        Peoplesoft_User_View__c dupePsRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =userRecords2.badge_number__c,
                               Employee_Status__c ='Active',
                               Direct_Manager_Name__c = 'Test2 Test Batch',
                               Direct_Manager_Badge_Number__c = userRecords1.badge_number__c
                               );
                         
        insert dupePsRecords ;
        
       
        System.debug('----testtesttest-----'+psRecords);
        System.runAs(AdminUser1){
            Test.startTest();
            BatchUserHRUpdate userBatchRecord = new BatchUserHRUpdate();
            Datetime dt=System.today().addDays(-365);
            String formatedDt = dt.format('yyyy-MM-dd\'T\'HH:mm:Ss\'Z\'');
            userBatchRecord.query = 'SELECT Integrated_User__c, CreatedDate,'+
                              ' badge_number__c,Acquisition_Code__c,direct_manager_badge_number__c,'+//2.0
                              ' Direct_Manager_Name__c,employee_status__c, '+
                              ' terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c , '+
                              ' HR_Director_Name__c, HR_Job_Function_Desc__c, '+
                              ' HR_Location_City__c, HR_Location_Country_Desc__c, '+
                              ' HR_Location_Long_Desc__c, HR_Location_State_Desc__c, '+
                              ' HR_Manager_Badge__c, HR_Manager_Email__c,'+
                              ' HR_Manager_Name__c, HR_People_Manager__c, '+
                              ' HR_Sales_Indicator__c, HR_Second_Level_Manager_Name__c, '+
                              ' HR_Senior_VP_Name__c, HR_Third_Level_Manager_Name__c, '+
                              ' HR_VP_Name__c,HR_Region__c, '+ //3.0
                			  ' EMC_Employee_Number__c, ' + //3.1
                              ' HR_Job_Title__c ' + //4.0
                              ' FROM peoplesoft_user_view__c'+ 
                              ' WHERE ((HR_Info_Updates__c = TRUE OR '+
                              ' CreatedDate >= '+formatedDt+')'+ 
                              ' AND Badge_Number__c != NULL AND ' +
                              ' Direct_Manager_Badge_Number__c  != NULL)';
            Id batchprocessid = database.executebatch(userBatchRecord,5);
            Test.stopTest();
        }
    }
    
    //4.0
    static testMethod void testHRUpdateTitleMoreThan80Character() {
            
		list<User> listUserToInsert = new list<User>();
        list<Peoplesoft_User_View__c> listPPSUV = new list<Peoplesoft_User_View__c>();
        string strTitle = 'this is a long string that has more than 80 characters to test if the title is capped at only 80 characters'; //4.0
        Profile objAdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User objAdminUser1 = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :objAdminProfile.Id AND IsActive = TRUE Limit 1];

        User userRecords1 = new User(FirstName='Test Batch ',IsActive = TRUE,
                               LastName='Test0', Title='CEO', UserName='UT_BatchTestAdmin0@test.com',
                               Email='UT_BatchTestAdmin0@dell.com', 
                               Alias='utgba0', CommunityNickName='utgbta0', 
                               ProfileId = objAdminProfile.Id,Acquisition_Code__c ='test1234',
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgbta0', 
                               HR_Job_Function_Desc__c='Test Federal Contract Services', HR_Location_City__c='Tennessee', HR_Manager_Badge__c='us12345', 
                               HR_Director_Name__c='DirTesting', HR_Location_Country_Desc__c='United States', HR_Location_Long_Desc__c='testGB LN London Office 02', 
                               HR_Location_State_Desc__c='Nashville', HR_Manager_Name__c='Dell, Test', 
                               HR_Second_Level_Manager_Name__c='Dell, Test2', HR_Senior_VP_Name__c='testSenior1', 
                               HR_Third_Level_Manager_Name__c='Dell, Test3', HR_VP_Name__c='testVP1',HR_Region__c = 'testRegion',
                               EMC_Employee_Number__c = 'EMC Test1',     
                               System_Admin_or_Delegated_User_Admin__c = TRUE);        
        listUserToInsert.add(userRecords1);

        User userRecords2 = new User(FirstName='Test Batch ',IsActive = TRUE,
                               LastName='Test2', Title='CEO', UserName='UT_BatchTestAdmin1@test.com',
                               Email='UT_BatchTestAdmin2@dell.com', 
                               Alias='utgba2', CommunityNickName='utgbta2', 
                               ProfileId = objAdminProfile.Id,Acquisition_Code__c ='1234test',
                               LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                               Badge_Number__c='utgbta2', 
                               Manual_Integrated_User__c = 'Yes',
                               System_Admin_or_Delegated_User_Admin__c = TRUE);
        listUserToInsert.add(userRecords2);                                                                                                                            
        
        insert listUserToInsert;
        
        Peoplesoft_User_View__c psRecords = new Peoplesoft_User_View__c(
                               Badge_Number__c =userRecords1.badge_number__c,
                               Employee_Status__c ='Active',
                               Direct_Manager_Name__c = 'Test2 Test Batch',
                               Direct_Manager_Badge_Number__c = userRecords2.Badge_Number__c,Acquisition_Code__c =userRecords1.Acquisition_Code__c,
                               HR_Job_Function_Desc__c='userRecords1.HR_Job_Function_Desc__c', HR_Location_City__c='userRecords1.HR_Location_City__c', HR_Manager_Badge__c='userRecords1.HR_Manager_Badge__c', 
                               HR_Director_Name__c='userRecords1.HR_Director_Name__c', HR_Location_Country_Desc__c='Malaysia', HR_Location_Long_Desc__c='userRecords1.HR_Location_Long_Desc__c', 
                               HR_Location_State_Desc__c='userRecords1. HR_Location_State_Desc__c', HR_Manager_Name__c='userRecords1.HR_Manager_Name__c', 
                               HR_Second_Level_Manager_Name__c='userRecords1.HR_Second_Level_Manager_Name__c', HR_Senior_VP_Name__c='userRecords1.HR_Senior_VP_Name__c', 
                               HR_Third_Level_Manager_Name__c='userRecords1.HR_Third_Level_Manager_Name__c', HR_VP_Name__c='userRecords1.HR_VP_Name__c',HR_Region__c=userRecords1.HR_VP_Name__c, 
            				   EMC_Employee_Number__c =userRecords1.EMC_Employee_Number__c, 
            				   HR_Job_Title__c = strTitle //4.0
                               );                 
        listPPSUV.add(psRecords);     
        
		insert listPPSUV;
 
        System.runAs(objAdminUser1){
            Test.startTest();
            BatchUserHRUpdate userBatchRecord = new BatchUserHRUpdate();
            Datetime dtToday=System.today().addDays(-365);
            String strFormatedDt = dtToday.format('yyyy-MM-dd\'T\'HH:mm:Ss\'Z\'');
            userBatchRecord.query = 'SELECT Integrated_User__c, CreatedDate,'+
                              ' badge_number__c,Acquisition_Code__c,direct_manager_badge_number__c,'+//2.0
                              ' Direct_Manager_Name__c,employee_status__c, '+
                              ' terminated_in_sfdc__c, Due_to_Deactivate_SFDC_Access__c , '+
                              ' HR_Director_Name__c, HR_Job_Function_Desc__c, '+
                              ' HR_Location_City__c, HR_Location_Country_Desc__c, '+
                              ' HR_Location_Long_Desc__c, HR_Location_State_Desc__c, '+
                              ' HR_Manager_Badge__c, HR_Manager_Email__c,'+
                              ' HR_Manager_Name__c, HR_People_Manager__c, '+
                              ' HR_Sales_Indicator__c, HR_Second_Level_Manager_Name__c, '+
                              ' HR_Senior_VP_Name__c, HR_Third_Level_Manager_Name__c, '+
                              ' HR_VP_Name__c,HR_Region__c, '+ //3.0
                			  ' EMC_Employee_Number__c, ' + //3.1
                			  ' HR_Job_Title__c' + //4.0
                              ' FROM peoplesoft_user_view__c'+ 
                              ' WHERE ((HR_Info_Updates__c = TRUE OR '+
                              ' CreatedDate >= '+strFormatedDt+')'+ 
                              ' AND Badge_Number__c != NULL AND ' +
                              ' Direct_Manager_Badge_Number__c  != NULL)';
            Id batchprocessid = database.executebatch(userBatchRecord,5);
            Test.stopTest();
            
            //4.0
            User objUserToVerify = [Select id, title from user where id = :userRecords1.id];
            system.assertEquals(strTitle.left(80), objUserToVerify.Title);
            
        }
    }       
   
    static testMethod void BatchUserHRUpdateSchedulerTest() {
            Test.startTest();
            String strCRON_EXP = '0 0 0 * * ?';
            BatchUserHRUpdateScheduler sch = new BatchUserHRUpdateScheduler();
            String strJobId = System.schedule('TestScheduledApex',strCRON_EXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :strJobId];
            //Verify the expressions are the same
            System.assertEquals(strCRON_EXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
    }
    
}