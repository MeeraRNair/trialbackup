/* 
Version CR Number   Release No      Date           Modified By     Description     
1.0      						    29-Jan-2013    Bianca Huit    
2.0        							12-Jan-2014    Anamika         handling VR exception for field Partner_Campaign_Contact_Email__c
3.0		   							15-March-2016  Azwanti		   CR12720 - replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
4.0		CR16090  	FY19-0802	    04-July-2018   Venkat Sharan   Fixed CMAP_LeadShareBatchTest method failure.	 	
*/
@isTest
private class CMAP_LeadShareBatchTest {
	
    static testMethod void CMAP_LeadShareBatchTest() {
    	// Insert CMAP Batch Apex User
     	Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        
        //Inserted as method is failing dut to 101 SOQL exception
        TriggerExecutionController.setSkipAllTriggers(true);
     
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        
        User AdminUser = new User(FirstName='CMAP Group Batch', LastName='Test Admin', Title='CEO', UserName='CMAP_GroupBatchTestAdmin@test.com',
                        Email='CMAP_GroupBatchTestAdmin@dell.com', Alias='cmapgba', CommunityNickName='cmapgbta', ProfileId = AdminProfile.Id,
                        LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',Badge_Number__c='cmapgbta');
        insert AdminUser;
        System.runAs(AdminUser){
            List<User> testUserList = new List<User>();
            Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Account Transitions Batch Profile%' LIMIT 1];
            // Insert list of Lead Super users
            for(Integer count=1;count<=10;count++){
                User testUser = new User(FirstName='CMAP Group Batch', LastName='Test User '+count, Title='OEM_SR', UserName='CMAP_GroupBatchTestUser'+count+'@test.com', 
                        Email='CMAP_GroupBatchTestUser'+count+'@dell.com', Alias='cmapgb'+count, CommunityNickName='cmapgbtu'+count, ProfileId = testProfile.Id, 
                        LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',Badge_Number__c='cmapgbtu'+count);
                testUserList.add(testUser);
            }
            insert testUserList;
                
            CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
            testData.getContact(true); //Get Account
            
            // Insert Partner Account
          	Account accountObj = new Account(name='Test');
                insert accountObj;
                accountObj.IsPartner = true;
                accountObj.Type = 'Partner';
                update accountObj;
            
            // Insert Group
            Group GroupRec = new Group(Name='CMAP:'+accountObj.Id,DoesIncludeBosses = false);
            insert GroupRec;
            
            // Insert Group members for same Partner Account
            List<GroupMember>groupMemberList = new List<GroupMember>();
            for(Integer count=0;count<10;count++){
              	GroupMember GroupMem = new GroupMember(GroupId = GroupRec.id, UserOrGroupId= testUserList[count].Id);
              	groupMemberList.add(GroupMem);
            }
            insert groupMemberList;
            
            Campaign campObj = new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                RecordTypeId = campRTId,
                Allocation_Source__c = 'Dell Allocation',
                Nurture_Source__c = 'Dell Nurturing',                
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',
                Partner_Campaign_Contact__c = UserInfo.getUserId()); //2.0
            insert campObj;                     
        
            // Insert mlur
            Mass_Upload_Lead_Request__c mlur = new Mass_Upload_Lead_Request__c(
            Campaign__c = campObj.Id);            
            insert mlur;
            
            // Insert CMAP Process queue Records
            List<CMAP_ProcessQueue__c> cmapProcessList = new List<CMAP_ProcessQueue__c>();
            
            // For Share - Insert
            for(Integer count=0;count<10;count++){
                CMAP_ProcessQueue__c shareInsert = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue ',
                                                                           Type__c ='Share',
                                                                           GroupId__c=GroupRec.Id, 
                                                                           Partner_Account__c = accountObj.Id,
                                                                           Super_User_Id__c = testUserList[count].Id,
                                                                           operation__c = 'Insert');
               cmapProcessList.add(shareInsert);
            }
             
            for(Integer count=0;count<5;count++){
                CMAP_ProcessQueue__c shareInsert_mlur = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue_mlur ',
                                                                            Mass_Lead_Upload_Request__c = mlur.Id,
                                                                           Type__c ='MLUR Share',
                                                                           GroupId__c=GroupRec.Id, 
                                                                           Partner_Account__c = accountObj.Id,
                                                                           Super_User_Id__c = testUserList[count].Id,
                                                                           operation__c = 'Insert');
               cmapProcessList.add(shareInsert_mlur);
            }
                          
            // For Share - Delete
            for(Integer count=0;count<10;count++){
            CMAP_ProcessQueue__c shareDelete = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue ',
                                                                           Type__c ='Share',
                                                                           GroupId__c=GroupRec.Id, 
                                                                           Partner_Account__c = accountObj.Id,
                                                                           Super_User_Id__c = testUserList[count].Id,
                                                                           operation__c = 'Delete');
                                                                                                                                     
                cmapProcessList.add(shareDelete);
            }
            for(Integer count=0;count<10;count++){
            CMAP_ProcessQueue__c shareDelete = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue ',
                                                                           Type__c ='TeamShare',
                                                                           GroupId__c=GroupRec.Id, 
                                                                           Partner_Account__c = accountObj.Id,
                                                                           Super_User_Id__c = testUserList[count].Id,
                                                                           operation__c = 'Insert');
                                                                                                                                     
                cmapProcessList.add(shareDelete);
            }
            insert cmapProcessList;
            
            System.AssertEquals(35, database.countquery('SELECT count() FROM CMAP_ProcessQueue__c Where OwnerId=\''+AdminUser.Id+'\''));            
            Test.startTest();
            CMAP_LeadShareBatch batchObj = new CMAP_LeadShareBatch();
            batchObj.query = 'SELECT Id, Channel_Lead__c, Mass_Lead_Upload_Request__c, Partner_Account__c,Type__c,operation__c,Super_User_Id__c,GroupId__c FROM CMAP_ProcessQueue__c Where OwnerId=\''+AdminUser.Id+'\'';
            Id batchprocessid = database.executebatch(batchObj,200);
            Test.stopTest();
            TriggerExecutionController.setSkipAllTriggers(false);
            System.AssertEquals(35, database.countquery('SELECT count() FROM CMAP_ProcessQueue__c Where OwnerId=\''+AdminUser.Id+'\''));            
        }
    }
    
    static testMethod void CMAP_LeadShareScheduler() {
        Test.startTest();
        String CRON_EXP = '0 0 0 * * ?';
        CMAP_LeadShareScheduler sch = new CMAP_LeadShareScheduler();
        String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
    
}