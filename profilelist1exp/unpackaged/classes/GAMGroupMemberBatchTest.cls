/* 
Author: Natesh Alagiri

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     11-Jul-2011     Natesh Alagiri  Created for CR6236 and CR6238
*/
@isTest
private class GAMGroupMemberBatchTest {
    static testMethod void myUnitTest() {
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User AdminUser = new User(FirstName='Test Admin', LastName='BatchGAMSharing Admin Test', Title='OEM_SR',UserName='AdminTest'+ System.currentTimeMillis() + '@test.com',Email='AdminTest@dell.com',Alias='admtst0',CommunityNickName='AdminTest',ProfileId = AdminProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='admintest');
        insert AdminUser;
        System.runAs(AdminUser){
            List<User> testUserList = new List<User>();
            Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Mgr' LIMIT 1];
            for(Integer count=1;count<=30;count++){
                User testUser1 = new User(FirstName='Test '+count, LastName='BatchGAMSharing Test', Title='OEM_SR',UserName='TestU'+count+ System.currentTimeMillis() +'@test.com',Email='TestU'+count+'@dell.com',Alias='test0'+count,CommunityNickName='Test0'+count,ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest'+count);
                testUserList.add(testUser1);
            }
            insert testUserList;
            List<Group> GAGroupList = new List<Group>();
            Group GAGroup = new Group(Name = 'GAM:Test123456789');
            GAGroupList.add(GAGroup);
            GAGroup = new Group(Name = 'GAM:Test987654321');
            GAGroupList.add(GAGroup);
            insert GAGroupList;
            
            
            List<GroupMember> groupMemberList = new List<GroupMember>();
            for(Integer count=20;count<30;count++){
                GroupMember groupMemberItem = new GroupMember(GroupId = GAGroupList[1].Id, UserOrGroupId= testUserList[count].Id);
                groupMemberList.add(groupMemberItem);
            }
            insert groupMemberList;
                
            List<Group_Member_Queue__c> groupMemberQueueList = new List<Group_Member_Queue__c>();
            for(Integer count=0;count<20;count++){
                Integer ItemNo = Math.mod(count,2);
                Group_Member_Queue__c groupMemberQueueRecord = new Group_Member_Queue__c(Group_ID__c = GAGroupList[ItemNo].Id,GAM_User__c = testUserList[count].Id,Operation__c = 'Insert');
                groupMemberQueueList.add(groupMemberQueueRecord);
            }
            for(Integer count=20;count<25;count++){
                Integer ItemNo = Math.mod(count,2);
                Group_Member_Queue__c groupMemberQueueRecord = new Group_Member_Queue__c(Group_ID__c = GAGroupList[1].Id,GAM_User__c = testUserList[count].Id,Operation__c = 'Delete');
                groupMemberQueueList.add(groupMemberQueueRecord);
            }
            
            insert groupMemberQueueList;
            
            System.AssertEquals(database.countquery('SELECT count() FROM GroupMember Where GroupId=\''+GAGroupList[1].Id+'\''), 10);
            Test.startTest();
            GAMGroupMemberBatch batchObj = new GAMGroupMemberBatch();
            batchObj.query = 'SELECT Id,Group_ID__c,GAM_User__c,Operation__c,Child_Group_Id__c '+
                             'FROM Group_Member_Queue__c ' +
                             'WHERE CreatedDate = LAST_N_DAYS:3 ' +
                             'ORDER BY Operation__c';
            Id batchprocessid = database.executebatch(batchObj,400);
            Test.stopTest();
            System.AssertEquals(database.countquery('SELECT count() FROM GroupMember Where GroupId=\''+GAGroupList[1].Id+'\''), 15);
        }
    }
    static testMethod void scheduleBatchTest() {
        Test.startTest();
        String CRON_EXP = '0 0 0 * * ?';
        GAMGroupMemberSchedule sch = new GAMGroupMemberSchedule();
        String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
}