/*
Author: Natesh Alagiri

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     11-Jul-2011     Natesh Alagiri  Created for CR6236 and CR6238
*/
@isTest
private class GAMbatchJobUtilsTest {
    static testMethod void myUnitTest() {
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User AdminUser = new User(FirstName='Test Admin', LastName='BatchGAMSharing Admin Test', Title='OEM_SR',UserName='AdminTest'+ System.currentTimeMillis() + '@test.com',Email='AdminTest@dell.com',Alias='admtst0',CommunityNickName='AdminTest',ProfileId = AdminProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='admintest');
        insert AdminUser;
        System.runAs(AdminUser){
            
            List<User> testUserList = new List<User>();
            Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Sales Rep%' LIMIT 1];
            for(Integer count=1;count<=30;count++){
                User testUser1 = new User(FirstName='Test '+count, LastName='BatchGAMSharing Test', Title='OEM_SR',UserName='TestU'+count + System.currentTimeMillis() +'@test.com',Email='TestU'+count+'@dell.com',Alias='test0'+count,CommunityNickName='Test0'+count,ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest'+count);
                testUserList.add(testUser1);
            }
            insert testUserList;
            List<Group> GAGroupList = new List<Group>();
            Group GAGroup = new Group(Name = 'GAM:Test123456789');
            GAGroupList.add(GAGroup);
            GAGroup = new Group(Name = 'GAM:Test987654321');
            GAGroupList.add(GAGroup);
            insert GAGroupList;
            
            List<GroupMember> groupMemberListToDelete = new List<GroupMember>();
            
            for(Integer count=20;count<30;count++){
                GroupMember groupMemberItem = new GroupMember(GroupId = GAGroupList[1].Id, UserOrGroupId= testUserList[count].Id);
                groupMemberListToDelete.add(groupMemberItem);
            }
            insert groupMemberListToDelete;
            delete groupMemberListToDelete;     
            
            String message='';
            List<GroupMember> groupMemberInsertList = new List<GroupMember>();
            for(Integer count=0;count<10;count++){
                GroupMember groupMemberItem = new GroupMember(GroupId = '00G000000000000', UserOrGroupId='005000000000000');
                groupMemberInsertList.add(groupMemberItem);
                
            }
            database.SaveResult[] insertResults = database.insert(groupMemberInsertList, false);
            Database.DeleteResult[] deleteResults = database.delete(groupMemberListToDelete, false);
            message = GAMbatchJobUtils.prepareNotificationMessage(groupMemberInsertList, insertResults, 'Insert');
            message += '\n---------------------\n' + GAMbatchJobUtils.prepareNotificationMessage(groupMemberListToDelete, deleteResults, 'Delete');
            GAMbatchJobUtils.sendOptionalNotification('GAM Group Member recalculation process result',message);
        }
    }
}