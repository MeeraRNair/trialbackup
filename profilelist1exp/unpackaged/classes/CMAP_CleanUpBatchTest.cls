/* 
Version    Date           Modified By     Description     
1.0        01-Feb-2013    Bianca Huit    
*/
@isTest
private class CMAP_CleanUpBatchTest {
    static list<user> listuser;
    static list<Account> listAcc;
    /*    @testSetup static void setup(){
list<user> listuserTDF = TestDataFactory.CreateNGenralUsers(1);
insert listuserTDF;
list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
listAccTDF[0].Type = 'Partner';
insert listAccTDF;
} */
    static testMethod voId cMAPCleanUpBatch() {
        // Insert CMAP Batch Apex User
        /*        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
User AdminUser = new User(FirstName = 'CMAP Group Batch', LastName = 'Test Admin', Title = 'CEO', UserName = 'CMAP_GroupBatchTestAdmin@test.com',
Email = 'CMAP_GroupBatchTestAdmin@dell.com', Alias = 'cmapgba', CommunityNickName = 'cmapgbta', ProfileId = AdminProfile.Id,
LanguageLocaleKey = 'en_US', LocaleSIdKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSIdKey = 'Asia/Kuala_Lumpur',Badge_Number__c = 'cmapgbta');
insert AdminUser;
*/
        // listuser = [select id from user limit 1];
        TriggerExecutionController.setSkipAllTriggers(true);
        list<user> listuser = TestDataFactory.CreateNGenralUsers(1);
        insert listuser;
        System.runAs(listuser[0]) {
            List<User> listtestUser = new List<User>();
            Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Account Transitions Batch Profile%' LIMIT 1];
            // Insert list of Lead Super users
            for(Integer intcount=0;intcount<5;intcount++){
                User testUser = new User(FirstName = 'CMAP Group Batch', LastName = 'Test User '+intcount, Title = 'OEM_SR', UserName = 'CMAP_GroupBatchTestUser'+intcount+'@test.com', 
                                         Email = 'CMAP_GroupBatchTestUser'+intcount+'@dell.com', Alias = 'cmapgb'+intcount, CommunityNickName = 'cmapgbtu'+intcount, ProfileId = testProfile.Id, 
                                         LanguageLocaleKey = 'en_US', LocaleSIdKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSIdKey = 'Asia/Kuala_Lumpur',Badge_Number__c = 'cmapgbtu'+intcount);
                listtestUser.add(testUser);
            }
            insert listtestUser;
            
            CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
            //testData.getContact(true); //Get Account
            
            // Insert Partner Account
            /*     Id accRTId = IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
Account accountObj = new Account(Name = 'Test', RecordtypeId = accRTId,Type = 'Partner' );
insert accountObj;
accountObj.IsPartner = true;
accountObj.Type = 'Partner';
update accountObj; */
            //listAcc = [select id from Account limit 1];
            listAcc = TestDataFactory.createNAccount(1, 'Partner Account');
            listAcc[0].Type = 'Partner';
            insert listAcc;
            listAcc[0].Ispartner = True;
            update listAcc;
            system.assertEquals(True, listAcc[0].Ispartner);
            // Insert Group
            Group groupRec = new Group(Name = 'CMAP:'+listAcc[0].Id,DoesIncludeBosses = false);
            insert groupRec;
            
            // Insert Group members for same Partner Account
            List<groupMember>listgroupMember = new List<groupMember>();
            for(Integer intcount=0;intcount<5;intcount++){
                groupMember groupMem = new groupMember(GroupId = groupRec.Id, UserOrGroupId = listtestUser[intcount].Id);
                listgroupMember.add(groupMem);
            }
            insert listgroupMember;
            
            // Insert CMAP Process queue Records
            List<CMAP_ProcessQueue__c> listcmapProcess = new List<CMAP_ProcessQueue__c>();
            
            // For Group - Insert
            for(Integer intcount=0;intcount<5;intcount++){
                CMAP_ProcessQueue__c groupInsert = new CMAP_ProcessQueue__c(Name = 'CMAP_ProcessQueue ',
                                                                            Type__c = 'Group',
                                                                            GroupId__c = groupRec.Id, 
                                                                            Partner_Account__c = listAcc[0].Id,
                                                                            Super_User_Id__c = listtestUser[intcount].Id,
                                                                            operation__c = 'Insert');
                listcmapProcess.add(groupInsert);
            }
            
            // For Group - Delete
            for(Integer intcount=0;intcount<5;intcount++){
                CMAP_ProcessQueue__c groupDelete = new CMAP_ProcessQueue__c(Name = 'CMAP_ProcessQueue ',
                                                                            Type__c = 'Group',
                                                                            GroupId__c = groupRec.Id, 
                                                                            Partner_Account__c = listAcc[0].Id,
                                                                            Super_User_Id__c = listtestUser[intcount].Id,
                                                                            operation__c = 'Delete');
                listcmapProcess.add(groupDelete);
            }
            
            // For groupMember - Insert
            for(Integer intcount=0;intcount<5;intcount++){
                CMAP_ProcessQueue__c groupMemberInsert = new CMAP_ProcessQueue__c(Name = 'CMAP_ProcessQueue ',
                                                                                  Type__c = 'groupMember',
                                                                                  GroupId__c = groupRec.Id, 
                                                                                  Partner_Account__c = listAcc[0].Id,
                                                                                  Super_User_Id__c = listtestUser[intcount].Id,
                                                                                  operation__c = 'Insert');
                listcmapProcess.add(groupMemberInsert);
            }
            
            // For groupMember - Delete
            for(Integer intcount=0;intcount<5;intcount++){
                CMAP_ProcessQueue__c groupMemberDelete = new CMAP_ProcessQueue__c(Name = 'CMAP_ProcessQueue ',
                                                                                  Type__c = 'groupMember',
                                                                                  GroupId__c = groupRec.Id, 
                                                                                  Partner_Account__c = listAcc[0].Id,
                                                                                  Super_User_Id__c = listtestUser[intcount].Id,
                                                                                  operation__c = 'Delete');
                listcmapProcess.add(groupMemberDelete);
            }
            
            // For Share - Insert
            for(Integer intcount=0;intcount<5;intcount++){
                CMAP_ProcessQueue__c shareInsert = new CMAP_ProcessQueue__c(Name = 'CMAP_ProcessQueue ',
                                                                            Type__c = 'Share',
                                                                            GroupId__c = groupRec.Id, 
                                                                            Partner_Account__c = listAcc[0].Id,
                                                                            Super_User_Id__c = listtestUser[intcount].Id,
                                                                            operation__c = 'Insert');
                listcmapProcess.add(shareInsert);
            }
            
            // For Team Group - Insert
            for(Integer intcount=0;intcount<5;intcount++){
                CMAP_ProcessQueue__c teamGroupInsert = new CMAP_ProcessQueue__c(Name = 'CMAP_ProcessQueue ',
                                                                                Type__c = 'TeamGroup',
                                                                                Partner_Account__c = listAcc[0].Id,
                                                                                operation__c = 'Insert');
                listcmapProcess.add(teamGroupInsert);
            }
            
            // For Team Share - Insert
            for(Integer intcount=0;intcount<5;intcount++){
                CMAP_ProcessQueue__c teamGroupInsert = new CMAP_ProcessQueue__c(Name = 'CMAP_ProcessQueue ',
                                                                                Type__c = 'TeamShare',
                                                                                Partner_Account__c = listAcc[0].Id,
                                                                                GroupId__c = groupRec.Id,
                                                                                operation__c = 'Insert');
                listcmapProcess.add(teamGroupInsert);
            }
            
            // For Share - Delete
            for(Integer intcount=0;intcount<5;intcount++){
                CMAP_ProcessQueue__c shareDelete = new CMAP_ProcessQueue__c(Name = 'CMAP_ProcessQueue ',
                                                                            Type__c = 'Share',
                                                                            GroupId__c = groupRec.Id, 
                                                                            Partner_Account__c = listAcc[0].Id,
                                                                            Super_User_Id__c = listtestUser[intcount].Id,
                                                                            operation__c = 'Delete');
                listcmapProcess.add(shareDelete);
            }
            insert listcmapProcess;
            
            //System.AssertEquals(40, database.countquery('SELECT intcount() FROM CMAP_ProcessQueue__c Where OwnerId = \''+AdminUser.Id+'\''));
            Test.startTest();
            CMAP_CleanUpBatch batchObj = new CMAP_CleanUpBatch();
            batchObj.query = 'SELECT Id, Channel_Lead__c, Partner_Account__c,Type__c,operation__c,Super_User_Id__c,GroupId__c,CreatedDate FROM CMAP_ProcessQueue__c Where OwnerId = \''+listUser[0].Id+'\'';
            Id batchprocessId = database.executebatch(batchObj, 200);
            TriggerExecutionController.setSkipAllTriggers(false);
            Test.stopTest();
            //System.AssertEquals(20, database.countquery('SELECT count() FROM CMAP_ProcessQueue__c Where OwnerId = \''+AdminUser.Id+'\''));
        }
    }
    
    static testMethod voId cMAPCleanUpScheduler() {
        TriggerExecutionController.setSkipAllTriggers(true);
        String strCRONEXP = '0 0 0 * * ?';
        CMAP_CleanUpScheduler sch = new CMAP_CleanUpScheduler();
        String strjobId = System.schedule('TestScheduledApex', strCRONEXP, sch);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :strjobId];
        // Verify the expressions are the same
        System.assertEquals(strCRONEXP, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
}