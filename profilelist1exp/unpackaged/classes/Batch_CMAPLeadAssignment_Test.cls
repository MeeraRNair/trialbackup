/* 
History:
Version    Date           Modified By     Description     
1.0        
2.0         15-March-2016   Azwanti         replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.0         22-Nov-2016     Naga            specify data in test class in order to look for see all data.
*/
@isTest 
private class Batch_CMAPLeadAssignment_Test {

    static testMethod void TestAsignmentforPartnerUser() {
        Id leadRTId = IdLookupUtils.getRecordTypeId('Channel Lead 2.0', 'Lead', true);
        Id leadRTId2 = IdLookupUtils.getRecordTypeId('Channel Lead - Submission', 'Lead', true);
        Id leadcleansingRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete', 'Lead', true);
        //CMAP_Queue_Settings__c assQueueId = CMAP_Queue_Settings__c.getValues('Partner Assignment Queue');
        Id CampRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0', 'Campaign', true); //v2.0
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getAccount(true); // Get Account
        
        final list<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate DESC limit 1];
    
        Contact c = new Contact(AccountId = testData.accountObj.id, 
                                FirstName = 'CMAP Contact1',
                                LastName = 'CMAP Contact1', 
                                Status__c = 'Marketing suspect',
                                Email = 'CMAP_GroupBatchTestContact111@dell.com');
        insert c;
        TriggerExecutionController.setSkipUserTriggers(true);
        User partnerUser = new User(FirstName = 'CMAP Assignment Batch', 
                                    LastName = 'Test User ',
                                    UserName = 'CMAP_GroupBatchTestUser@test.com',
                                    Alias = '99CMAP',
                                    Email = 'CMAP_GroupBatchTestUser5465476457@dell.com', 
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey = 'en_US', 
                                    LocaleSidKey = 'en_US', 
                                    EmailEncodingKey = 'UTF-8', 
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    Badge_Number__c = 'TESTASS1', 
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    Enable_As_Partner_Lead_Super_User__c = true,
                                    IsActive = true,
                                    //UserRoleId = testUserRole.Id,
                                    ContactId = c.Id);
        insert partnerUser;
        TriggerExecutionController.setSkipUserTriggers(false);
        
        Campaign CMAP_Channel_camp = new Campaign(Name = 'TestCampaign_CL',
            Campaign_Objective__c = 'Acquisition/Site Development',
            Type = 'Advisory Councils',Segment_Business_Unit__c = 'SMB',
            Region__c = 'ABU',                        
            Follow_Up_Role__c = 'Account Executive',
            Description = 'Test',StartDate = system.today(),EndDate = system.today(),
            status = 'In Progress',
            Partner_Campaign_Contact__c = UserInfo.getUserId(),
            Partner_Campaign_Contact_Email__c = 'Test@dell.com',
            Country_Code__c = 'BR - Brazil',
            Partner_Event_or_Campaign__c = true,
            Allocation_Source__c = 'Dell Allocation ABU',
            Nurture_Source__c = 'Dell Nurturing',
            Lead_Routing__c = 'Dell Standard',
            IsActive = true,
            RecordTypeId = CampRTId,
            Total_Campaign_Targets_Planned__c = 1,
            Total_Value_Won_Opportunities_Planned__c = 1,
            Total_Value_Opportunities_Planned__c = 1);
        insert  CMAP_Channel_camp;
        
        Test.startTest();
        //CMAP_Helper.skipinsert = true;
        
        //Ver 3.0 starts
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        
        CMAP_Queue_Settings__c objCust1 = new CMAP_Queue_Settings__c();
        objCust1.Queue_Id__c = '00GA0000002y6hl';
        objCust1.Queue_Name__c = 'Partner_Assignment_Queue__c';
        objCust1.Name ='Partner Assignment Queue';
        insert objCust1;
        //Ver 3.0 ends
        
        list<Lead> lstLeads = new list<Lead>();
        Lead leadObj1 = new Lead(lastName = 'Test Lead',
            email = 'testcmap@cmaptest.com',
            status = 'Open - Channel Lead',
            Phone = '88967544',
            RecordTypeId = leadRTId,
            Country = 'US',
            Partner_Account__c = testdata.accountObj.Id,
            LeadSource = 'web',
            Lead_Type__c = 'Inbound',  
            Dell_Partner_can_contact_me__c = true,
            Campaign__c  = CMAP_Channel_camp.Id,
            Company = 'Test Company',
            Partner_User__c = partnerUser.Id,
            Ready_For_Scoring__C = true,
            BANT_Qualified__c = true,                     
            //ownerid = assQueueId.Queue_Id__c,
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)'
                                
        );
        lstLeads.add(leadObj1);
        
        Lead leadObj2 = new Lead(lastName = 'Test Lead',
            email = 'testcmap@cmaptest.com',
            status = 'Open - Channel Lead',
            Phone = '88967544',
            RecordTypeId = leadRTId,
            Country = 'US',
            Partner_Account__c = testdata.accountObj.Id,
            LeadSource = 'web',
            Lead_Type__c = 'Inbound',  
            Dell_Partner_can_contact_me__c = true,      
            Campaign__c  = CMAP_Channel_camp.Id,
            Company = 'Test Company',
            Partner_Admin__c = PartnerUser.Id,
            Ready_For_Scoring__C = true,
            BANT_Qualified__c = false,                       
            //ownerid = assQueueId.Queue_Id__c,
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)'
        );
        
        lstLeads.add(leadObj2);
        insert lstLeads;
        
        String CRON_EXP = '0 0 0 * * ?'; 
        Batch_CMAPLeadAssignmentScheduler sch = new Batch_CMAPLeadAssignmentScheduler();
        String jobId = System.schedule('TestScheduledApex', CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        
    }
    
    static testMethod void TestAsignmentforPartnerRunAsUser() {
        final list<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate DESC limit 1];
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getAccount(true); // Get Account
        contact c = new Contact(AccountId = testData.accountObj.id, 
                                FirstName = 'CMAP Contact1',
                                LastName = 'CMAP Contact1', 
                                Status__c = 'Marketing suspect',
                                Email = 'CMAP_GroupBatchTestContact111@dell.com');
        insert c;
        TriggerExecutionController.setSkipUserTriggers(true);     
        user partnerUser = new User(FirstName = 'CMAP Assignment Batch', 
                                    LastName = 'Test User ',
                                    UserName = 'CMAP_GroupBatchTestUser@test.com',
                                    Alias = '99CMAP',
                                    Email = 'CMAP_GroupBatchTestUser5465476457@dell.com', 
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey = 'en_US', 
                                    LocaleSidKey = 'en_US', 
                                    EmailEncodingKey = 'UTF-8', 
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    Badge_Number__c = 'TESTASS1', 
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    Enable_As_Partner_Lead_Super_User__c = true,
                                    IsActive = true,
                                    CommunityNickname = 'testUser123',
                                    ContactId = c.Id);
        insert partnerUser;
        TriggerExecutionController.setSkipUserTriggers(false);
        Test.startTest();
        System.runAs(partnerUser) {
            Id leadRTId2 = IdLookupUtils.getRecordTypeId('Channel Lead 2.0', 'Lead', true);
            Id CampRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0', 'Campaign', true); //v2.0
            
            //Ver 3.0 starts
            CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
            objCust.Queue_Id__c = '00GA0000002y6hl';
            objCust.Queue_Name__c = 'Channel_eClerx';
            objCust.Name ='Channel_eClerx';
            insert objCust ;
            
            CMAP_Queue_Settings__c objCust1 = new CMAP_Queue_Settings__c();
            objCust1.Queue_Id__c = '00GA0000002y6hl';
            objCust1.Queue_Name__c = 'Partner_Assignment_Queue__c';
            objCust1.Name ='Partner Assignment Queue';
            insert objCust1;
            
            //CMAP_TestDataGenerator testData1 = new CMAP_TestDataGenerator();
            //testData1.getAccount(true); // Get Account
        
            Campaign CMAP_Channel_camp1 = new Campaign(Name = 'TestCampaign_CL1',
            Campaign_Objective__c = 'Acquisition/Site Development',
            Type = 'Advisory Councils',Segment_Business_Unit__c = 'SMB',
            Region__c = 'ABU',                        
            Follow_Up_Role__c = 'Account Executive',
            Description = 'Test',StartDate = system.today(),EndDate = system.today(),
            status = 'In Progress',
            Partner_Campaign_Contact__c = UserInfo.getUserId(),
            Partner_Campaign_Contact_Email__c = 'Test@dell.com',
            Country_Code__c = 'BR - Brazil',
            Allocation_Source__c = 'Dell Allocation ABU',
            Nurture_Source__c = 'Dell Nurturing',
            Lead_Routing__c = 'Dell Standard',
            IsActive = true,
            Partner_Event_or_Campaign__c = true,                                           
            RecordTypeId = CampRTId,
            Total_Campaign_Targets_Planned__c = 1,
            Total_Value_Won_Opportunities_Planned__c = 1,
            Total_Value_Opportunities_Planned__c = 1);
            insert  CMAP_Channel_camp1;
            
            Lead leadObj = new Lead(lastName = 'Test Lead',
                email = 'testcmap@cmaptest322323.com',
                status = 'Open - Channel Lead',
                Phone = '88967544',
                RecordTypeId = leadRTId2,
                Country = 'US',
                LeadSource = 'web',
                Lead_Type__c = 'Inbound',  
                //Account__c = testData1.accountObj.Id,
                Dell_Partner_can_contact_me__c = true,                
                //Partner_Account__c = testData1.accountObj.Id,
                Campaign__c  = CMAP_Channel_camp1.Id,
                Company = 'Test Company',
                Partner_Admin__c = PartnerUser.Id,
                Ready_For_Scoring__C = true,
                BANT_Qualified__c = true, 
                Unqualified_Lead_Reason__c = '',                     
                //ownerid = assQueueId.Queue_Id__c,
                Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)'
            );
            INSERT leadObj;
            
        }
        
        String CRON_EXP = '0 0 0 * * ?'; 
        Batch_CMAPLeadAssignmentScheduler sch1 = new Batch_CMAPLeadAssignmentScheduler();
        String jobId1 = System.schedule('TestScheduledApex1', CRON_EXP, sch1); 
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId1];
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        
    }
}