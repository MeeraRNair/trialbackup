/* 
Author: Bianca Huit
History:
Version    Date           Modified By     Description     
1.0        29-Jan-2013    Bianca Huit    
*/
@isTest(SeeAllData=true)
private class CMAP_GroupBatchTest {
    static testMethod void CMAP_GroupBatchTest() {
        CMAP_Helper.skipinsert = true;
       TriggerExecutionController.setSkipAllTriggers(true); 

        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User AdminUser = new User(FirstName='CMAP Group Batch', 
                                  LastName='Test Admin', 
                                  Title='CEO', 
                                  UserName='CMAP_GroupBatchTestAdmin@test.com',
                                  Email='CMAP_GroupBatchTestAdmin@dell.com', Alias='cmapgba', 
                                  CommunityNickName='cmapgbta', ProfileId = AdminProfile.Id,
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  EmailEncodingKey='UTF-8', 
                                  TimeZoneSidKey='Asia/Kuala_Lumpur',
                                  Badge_Number__c='cmapgbta');
        insert AdminUser;
        
        List<User> testUserList = new List<User>();
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Account Transitions Batch Profile%' LIMIT 1];
        Map<Id, Account> accMap = new Map <Id, Account>();  
        Id PartnerAccountRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
        //testUserList.add(AdminUser);
        
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
       	//testData.getAccount(True);
        
        Account acc= new Account(name='SMA1', Type = 'Partner', RecordTypeId = PartnerAccountRTId, OwnerId = UserInfo.getUserId());
		insert acc;
        
        Set<Id> accountset= new set<Id>();
        accountset.add(acc.Id);
        Id accid=acc.Id;
        
        Map<Id, Account> acctMap= new Map <Id, Account>();
        acctMap.put(acc.Id,acc);
        System.debug('acctMap'+acctMap);
        Map<ID,List<user>> mapUserIdSalesMotion = new Map<id,list<user>>();
        AccountTeamMember atmObj = new AccountTeamMember(accountId = acc.Id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Sales Rep');
        insert atmObj;
		system.debug('Account Team member account id'+atmObj.accountId);        
         system.debug('acctMap account id values'+acctMap.get(atmObj.AccountId));  
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        
        //Insert list of Contacts
        List<Contact>contactList = new List<Contact>();
        for(Integer count=1;count<=3;count++){
            Contact c = new Contact(AccountId=acc.id, 
                                    FirstName='CMAP Contact',
                                    LastName='CMAP Contact'+count, 
                                    Status__c = 'Marketing Suspect',
                                    Email='CMAP_GroupBatchTestContact'+count+'@dell.com');
            contactList.add(c);
        }
        insert contactList;
        //Insert list of Lead super users          
        for(Integer count=0;count<3;count++){  
            User partnerUser = new User(FirstName='CMAP Group Batch', 
                                        LastName='Test User '+count,
                                        UserName='CMAP_GroupBatchTestUser'+count+'@test.com',
                                        Alias='cmapgb'+count,
                                        Email='CMAP_GroupBatchTestUser'+count+'@dell.com', 
                                        ProfileId = partnerProfiles.get(0).Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='cmapgbtu'+count, 
                                        Enable_Partner_Deal_Registration__c = TRUE,
                                        Enable_Partner_Lead_Management__c = TRUE,
                                        Enable_As_Partner_Lead_Super_User__c = TRUE,
                                        IsActive =TRUE,
                                        //UserRoleId = testUserRole.Id,
                                        ContactId = contactList[count].Id);
            testUserList.add(partnerUser);
        } 
        insert testUserList;
        
        System.runAs(AdminUser){
            
            //Insert CMAP Process queue Records
            List<CMAP_ProcessQueue__c> cmapProcessRec = new List<CMAP_ProcessQueue__c>();
            List<CMAP_ProcessQueue__c> cmapProcessRecDel = new List<CMAP_ProcessQueue__c>();
            
            //For Group
            CMAP_ProcessQueue__c groupQueue = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue',
                                                                       operation__c = 'Insert',
                                                                       Type__c ='Group',
                                                                       Partner_Account__c =acc.Id);
            insert groupQueue;
             CMAP_ProcessQueue__c TeamgroupQueue = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue',
                                                                       operation__c = 'Insert',
                                                                       Type__c ='TeamGroup',
                                                                       Partner_Account__c = acc.Id);
            insert TeamgroupQueue;
            //For Group
        
            //For Group Member - Insert
            for(Integer count=0;count<3;count++){
                CMAP_ProcessQueue__c groupMem_Insert = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue ',
                                                                           Type__c ='GroupMember',
                                                                           GroupId__c=groupQueue.Id, 
                                                                           Partner_Account__c = acc.Id,
                                                                           Super_User_Id__c = testUserList[count].Id,
                                                                           operation__c = 'Insert');
                cmapProcessRec.add(groupMem_Insert);
            }                                                                       
             //For Group Member - Delete
             for(Integer count=0;count<3;count++){
                CMAP_ProcessQueue__c groupMem_Delete = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue ',
                                                                           Type__c ='GroupMember',
                                                                           GroupId__c=groupQueue.Id, 
                                                                           Partner_Account__c = acc.Id,
                                                                           Super_User_Id__c = testUserList[count].Id,
                                                                           operation__c = 'Delete');
                                                                                                                                     
                cmapProcessRec.add(groupMem_Delete);
            }
            Test.startTest();
            insert cmapProcessRec;
           
            System.Debug('-----cmapProcessRec---'+cmapProcessRec);
            
            Database.QueryLocator QL;
            Database.BatchableContext BC; 
            CMAP_GroupBatch batchObj = new CMAP_GroupBatch();
            batchObj.query = 'SELECT Id, Channel_Lead__c, Partner_Account__c,Type__c,operation__c,Super_User_Id__c,GroupId__c FROM CMAP_ProcessQueue__c Where OwnerId=\''+AdminUser.Id+'\' Limit 10';
            system.Debug('----query----'+batchObj.query);
            Id batchprocessid = database.executebatch(batchObj,200);
            CMAP_LeadShareScheduler schJob = new CMAP_LeadShareScheduler();   
            datetime TodayDate = datetime.now();
            string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
            system.schedule('CMAP_LeadShareBatch' +String.valueOf(TodayDate), schTime, schJob);
            /*String CRON_EXP = '0 0 0 * * ?';
            CMAP_GroupScheduler sch = new CMAP_GroupScheduler();
            String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            //Verify the expressions are the same
            System.assertEquals(CRON_EXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);*/
            Test.stopTest();
           
        }
    }
    static testMethod void CMAP_GroupBatchTestOEM() {
        CMAP_Helper.skipinsert = true;
       TriggerExecutionController.setSkipAllTriggers(true); 

        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User AdminUser = new User(FirstName='CMAP Group Batch', 
                                  LastName='Test Admin', 
                                  Title='CEO', 
                                  UserName='CMAP_GroupBatchTestAdmin@test.com',
                                  Email='CMAP_GroupBatchTestAdmin@dell.com', Alias='cmapgba', 
                                  CommunityNickName='cmapgbta', ProfileId = AdminProfile.Id,
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  EmailEncodingKey='UTF-8', 
                                  TimeZoneSidKey='Asia/Kuala_Lumpur',
                                  Badge_Number__c='cmapgbta');
        insert AdminUser;
        
        List<User> testUserList = new List<User>();
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Account Transitions Batch Profile%' LIMIT 1];
        Map<Id, Account> accMap = new Map <Id, Account>();  
        Id PartnerAccountRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
        //testUserList.add(AdminUser);
        Id EndUserRTId= IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
       	//testData.getAccount(True);
       	
        Sales_Channel_Group__c saleschlgrp= new Sales_Channel_Group__c(Name='Test OEM');
        
        Account acc= new Account(name='SMA1', Type = 'OEM', RecordTypeId = EndUserRTId, OwnerId = UserInfo.getUserId(),Sales_channel__c=saleschlgrp.Id);
		insert acc;
        
        Set<Id> accountset= new set<Id>();
        accountset.add(acc.Id);
        Id accid=acc.Id;
        
        Map<Id, Account> acctMap= new Map <Id, Account>();
        acctMap.put(acc.Id,acc);
        System.debug('acctMap'+acctMap);
        Map<ID,List<user>> mapUserIdSalesMotion = new Map<id,list<user>>();
        AccountTeamMember atmObj = new AccountTeamMember(accountId = acc.Id ,UserId = UserInfo.getUserId(), TeamMemberRole = 'Sales Rep');
        insert atmObj;
		system.debug('Account Team member account id'+atmObj.accountId);        
         system.debug('acctMap account id values'+acctMap.get(atmObj.AccountId));  
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        
        //Insert list of Contacts
        List<Contact>contactList = new List<Contact>();
        for(Integer count=1;count<=3;count++){
            Contact c = new Contact(AccountId=acc.id, 
                                    FirstName='CMAP Contact',
                                    LastName='CMAP Contact'+count, 
                                    Status__c = 'Marketing Suspect',
                                    Email='CMAP_GroupBatchTestContact'+count+'@dell.com');
            contactList.add(c);
        }
        insert contactList;
        //Insert list of Lead super users          
        for(Integer count=0;count<3;count++){  
            User partnerUser = new User(FirstName='CMAP Group Batch', 
                                        LastName='Test User '+count,
                                        UserName='CMAP_GroupBatchTestUser'+count+'@test.com',
                                        Alias='cmapgb'+count,
                                        Email='CMAP_GroupBatchTestUser'+count+'@dell.com', 
                                        ProfileId = partnerProfiles.get(0).Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='cmapgbtu'+count, 
                                        Enable_Partner_Deal_Registration__c = TRUE,
                                        Enable_Partner_Lead_Management__c = TRUE,
                                        Enable_As_Partner_Lead_Super_User__c = TRUE,
                                        IsActive =TRUE,
                                        //UserRoleId = testUserRole.Id,
                                        ContactId = contactList[count].Id);
            testUserList.add(partnerUser);
        } 
        insert testUserList;
        
        System.runAs(AdminUser){
            
            //Insert CMAP Process queue Records
            List<CMAP_ProcessQueue__c> cmapProcessRec = new List<CMAP_ProcessQueue__c>();
            List<CMAP_ProcessQueue__c> cmapProcessRecDel = new List<CMAP_ProcessQueue__c>();
            
            //For Group
            CMAP_ProcessQueue__c groupQueue = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue',
                                                                       operation__c = 'Insert',
                                                                       Type__c ='Group',
                                                                       Partner_Account__c =acc.Id);
            insert groupQueue;
             CMAP_ProcessQueue__c TeamgroupQueue = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue',
                                                                       operation__c = 'Insert',
                                                                       Type__c ='TeamGroup',
                                                                       Partner_Account__c = acc.Id);
            insert TeamgroupQueue;
            //For Group
        
            //For Group Member - Insert
            for(Integer count=0;count<3;count++){
                CMAP_ProcessQueue__c groupMem_Insert = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue ',
                                                                           Type__c ='GroupMember',
                                                                           GroupId__c=groupQueue.Id, 
                                                                           Partner_Account__c = acc.Id,
                                                                           Super_User_Id__c = testUserList[count].Id,
                                                                           operation__c = 'Insert');
                cmapProcessRec.add(groupMem_Insert);
            }                                                                       
             //For Group Member - Delete
             for(Integer count=0;count<3;count++){
                CMAP_ProcessQueue__c groupMem_Delete = new CMAP_ProcessQueue__c(Name='CMAP_ProcessQueue ',
                                                                           Type__c ='GroupMember',
                                                                           GroupId__c=groupQueue.Id, 
                                                                           Partner_Account__c = acc.Id,
                                                                           Super_User_Id__c = testUserList[count].Id,
                                                                           operation__c = 'Delete');
                                                                                                                                     
                cmapProcessRec.add(groupMem_Delete);
            }
            Test.startTest();
            insert cmapProcessRec;
           
            System.Debug('-----cmapProcessRec---'+cmapProcessRec);
            
            Database.QueryLocator QL;
            Database.BatchableContext BC; 
            CMAP_GroupBatch batchObj = new CMAP_GroupBatch();
            batchObj.query = 'SELECT Id, Channel_Lead__c, Partner_Account__c,Type__c,operation__c,Super_User_Id__c,GroupId__c FROM CMAP_ProcessQueue__c Where OwnerId=\''+AdminUser.Id+'\' Limit 10';
            system.Debug('----query----'+batchObj.query);
            Id batchprocessid = database.executebatch(batchObj,200);
            CMAP_LeadShareScheduler schJob = new CMAP_LeadShareScheduler();   
            datetime TodayDate = datetime.now();
            string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
            system.schedule('CMAP_LeadShareBatch' +String.valueOf(TodayDate), schTime, schJob);
            /*String CRON_EXP = '0 0 0 * * ?';
            CMAP_GroupScheduler sch = new CMAP_GroupScheduler();
            String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            //Verify the expressions are the same
            System.assertEquals(CRON_EXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);*/
            Test.stopTest();
           
        }
    }
    static testMethod void CMAP_GroupScheduler() {
        Test.startTest();
        String CRON_EXP = '0 0 0 * * ?';
        CMAP_GroupScheduler sch = new CMAP_GroupScheduler();
        String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
}