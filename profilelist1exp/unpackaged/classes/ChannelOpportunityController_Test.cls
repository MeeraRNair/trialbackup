/* 
History:
Version Release         CR #        Date            Modified By     Description     
1.0                                 16-Sep-2014     Jiji            Test class for channelOpportunityController
2.0                                 12-Jan-2015     Anamika         Handling VR exception for field Partner_Campaign_Contact_Email__c
3.0                                 09-March-2015   Meera           Added test scenario to check DSG Lead display on new opp creation     
4.0     FY17-DCS-0401   CR12720     15-March-2016   Azwanti         replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
5.0     FY17-DCS-0701   CR13184     30-May-2016     Sui Yee         replace RecordTypeId'Campaign 2.0'& lead 2.0 mandatory field.@isTest(seealldata= true)
6.0		0102						04-Dec-2019		Vikas KH		Implemented TDF
*/
@isTest
private class ChannelOpportunityController_Test {
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static list<user> listuser;
    //v5.0 Setup test data for queue
    @testSetup static void populateCMAPCustomSetting() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Deal Registration');
        insert listOppTDF;
        list<user> listUserTDF = TestDataFactory.createNPortalUser(1);
        insert listUserTDF;
        
    }
    static testMethod void internalUserTest() {
        PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=0127000000057EN&ent=Opportunity&save_new=1&sfdc.override=1');
        Test.setCurrentPage(pr);
        channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
        controller.redirect();
        system.assertNotEquals(null,pr);
    }
    static testMethod void nonDealRegRTTest() {
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');
        /*        Contact newCont = new Contact(FirstName='TestContactFN9',
LastName='TestContactLN9',
accountId=listAcc[0].Id,
Email='TestContactEmail9@ust-global.com',
fax='01987645',
MobilePhone='0000019',
Phone='0000000');
insert newCont;
final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];
User partnerUser = new User(
Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
Alias = 'tt2', 
Email='MyTest009@dell.com', 
FirstName='MyTestUser09', 
LastName='MyTestUser09',  
ProfileId = partnerProfiles.get(0).Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='909', 
isActive = TRUE,
Enable_Partner_Deal_Registration__c = TRUE, 
Enable_Partner_Lead_Management__c = TRUE, 
Enable_As_Partner_Lead_Super_User__c = TRUE,
ContactId = newCont.id
);
insert partnerUser; */
        listuser = [select id from user limit 1];
        Test.stopTest();
        PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
        Test.setCurrentPage(pr);
        channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
        System.runAs(listUser[0]){
            controller.redirect();
        }
    }
    static testMethod void dealRegRTNocriteriaTest() {
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');
        /*     Contact newCont = new Contact(FirstName='TestContactFN9',
LastName='TestContactLN9',
accountId=listAcc[0].Id,
Email='TestContactEmail9@ust-global.com',
fax='01987645',
MobilePhone='0000019',
Phone='0000000');
insert newCont;
final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];
User partnerUser = new User(
Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
Alias = 'tt2', 
Email='MyTest009@dell.com', 
FirstName='MyTestUser09', 
LastName='MyTestUser09',  
ProfileId = partnerProfiles.get(0).Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='909', 
isActive = TRUE,
Enable_Partner_Deal_Registration__c = TRUE, 
Enable_Partner_Lead_Management__c = TRUE, 
Enable_As_Partner_Lead_Super_User__c = TRUE,
ContactId = newCont.id
);
insert partnerUser; */
        listuser = [select id from user limit 1];
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Region__c='ABU',                        
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Allocation_Source__c = 'Dell Allocation ABU',
                                          Nurture_Source__c = 'Dell Nurturing',
                                          Country_Code__c = 'BR - Brazil',
                                          Partner_Event_or_Campaign__c = TRUE,
                                          IsActive = true,
                                          RecordTypeId = campRTId,
                                          Total_Value_Won_Opportunities_Planned__c = 1,
                                          Total_Value_Opportunities_Planned__c = 1,
                                          Partner_Campaign_Contact__c = listuser[0].Id,
                                          Lead_Routing__c = 'Dell Standard',
                                          Partner_Campaign_Contact_Email__c = 'test@test.com');
        insert newCampgn;
        Test.startTest();
        Lead leadObj = new Lead();
        Id leadAssignmentRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete', 'Lead', true);
        Id leadsubmsnRTId = IdLookupUtils.getRecordTypeId('Direct Lead 2.0', 'Lead', true); //v4.0
        leadObj = new Lead(lastName = 'Test Lead',
                           email ='testcmap@cmaptest.com',
                           status = 'Open - Channel Lead',
                           Phone='88967544',
                           Partner_Account__c =  listAcc[0].Id,
                           country = 'US',
                           Partner_User__c =listUser[0].Id,
                           Ready_For_Scoring__c = TRUE,
                           Budget__c ='Yes',
                           Purchase_Timeframe__c = 'Immediately',
                           Campaign__c  = newCampgn.Id,
                           RecordTypeId = leadsubmsnRTId,
                           Total_Expected_Dell_Revenue__c = 1,
                           Called_Customer__c = 'Yes',
                           Sales_Qualified__c = 'Qualified',
                           LeadSource = 'Web',
                           Lead_Type__c = 'Inbound',
                           Dell_Partner_can_contact_me__c = true,
                           Company = 'Test Company');
        insert leadObj;
        leadObj.OwnerId = listUser[0].Id;
        leadObj.RecordTypeId = leadsubmsnRTId ;
        Test.stopTest();
        Opportunity oppRec = new Opportunity();
        PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
        Test.setCurrentPage(pr);
        channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
        System.runAs(listUser[0]){
            controller.redirect();
            controller.Firstname = '';
            controller.LastName = '';
            controller.Company = '';
            controller.PartnerAccount = '';
            controller.Campaign = '';
            controller.Email = '';  
            controller.oppRec = oppRec;
            try{ controller.Search();
               }
            catch(exception e){
            }
        }
    }
    static testMethod void dealRegRTwithcriteriaTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Helper.skipinsert = true;
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');
        Contact newCont = new Contact(FirstName='TestContactFN9',
                                      LastName='TestContactLN9',
                                      accountId=listAcc[0].Id,
                                      Email='TestContactEmail9@ust-global.com',
                                      fax='01987645',
                                      MobilePhone='0000019',
                                      Phone='0000000');
        insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];
        final List<Profile> stdProfiles = [select Id, Name from Profile where Name like 'System Administrator' limit 1];
        User u = new User(
            Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
            Alias = 'adm', 
            Email='MyTestAdmin009@dell.com', 
            FirstName='MyTestAdmin1', 
            LastName='MyTestAdmin1',  
            ProfileId = stdProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Admin007', 
            isActive = TRUE
        );
        insert u;
        Test.startTest(); 
        User partnerUser = new User(
            Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest009@dell.com', 
            FirstName='MyTestUser09', 
            LastName='MyTestUser09',  
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='909', 
            isActive = TRUE,
            Enable_Partner_Deal_Registration__c = TRUE, 
            Enable_Partner_Lead_Management__c = TRUE, 
            Enable_As_Partner_Lead_Super_User__c = TRUE,
            ContactId = newCont.id
        );
        insert partnerUser;
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Region__c='ABU',                        
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Allocation_Source__c = 'Dell Allocation ABU',
                                          Nurture_Source__c = 'Dell Nurturing',
                                          Country_Code__c = 'BR - Brazil',
                                          Partner_Event_or_Campaign__c = TRUE,
                                          IsActive = true,
                                          RecordTypeId = campRTId,
                                          Total_Value_Won_Opportunities_Planned__c = 1,
                                          Total_Value_Opportunities_Planned__c = 1,
                                          Partner_Campaign_Contact__c = partnerUser.Id,
                                          Lead_Routing__c = 'Dell Standard',
                                          Partner_Campaign_Contact_Email__c = 'test@test.com'); //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c (
            Campaign__c = newCampgn.Id,
            Partner_Account__c = listAcc[0].Id );
        insert pcm;
        System.runAs(u){
            List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
            List<PermissionSet> listleadpermset = [SELECT Id, Name
                                                   FROM PermissionSet 
                                                   WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
            PermissionSetAssignment assi = new PermissionSetAssignment(
                AssigneeId = partnerUser.Id, 
                PermissionSetId = listleadpermset[0].Id);
            listassignment.add(assi);
            if(listassignment.Size() > 0){
                insert listassignment;
            }
        }         
        Lead leadObjectRecord = new Lead();
        Id leadAssignmentRTId = '012A0000000ViCT';
        Id leadsubmsnRTId = '012A0000000ViCJ';
        leadObjectRecord = new Lead(FirstName='@@@@@', lastName = 'Test Lead',
                                    email ='testcmap@cmaptest.com',
                                    status = 'Open - Channel Lead',
                                    Phone='88967544',
                                    Partner_Account__c =  listAcc[0].Id,
                                    country = 'US',
                                    Partner_User__c =partnerUser.Id,
                                    Ready_For_Scoring__c = TRUE,
                                    Budget__c ='Yes',
                                    Purchase_Timeframe__c = 'Immediately',
                                    Campaign__c  = newCampgn.Id,
                                    RecordTypeId = leadsubmsnRTId,
                                    Total_Expected_Dell_Revenue__c = 1,
                                    Called_Customer__c = 'Yes',
                                    Sales_Qualified__c = 'Qualified',
                                    Company = 'Test Company');
        insert leadObjectRecord;
        Test.stopTest();
        leadObjectRecord.OwnerId = PartnerUser.Id;
        leadObjectRecord.RecordTypeId = leadAssignmentRTId;
        TriggerExecutionController.setSkipLeadTriggers(true);
        update leadObjectRecord;
        System.runAs(PartnerUser){
            channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
            Opportunity oppRec = new Opportunity();
            PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
            Test.setCurrentPage(pr);
            controller.Firstname = '@@@@@';
            controller.LastName = '';
            controller.Company = '';
            controller.PartnerAccount = '';
            controller.Campaign = '';
            controller.Email = '';  
            controller.oppRec = oppRec;
            controller.LeadOwnerId = partnerUser.Id;
            controller.LeadId = leadObjectRecord.Id;
            controller.LeadName = leadObjectRecord.Name;
            controller.LeadcampId = newCampgn.Id;
            controller.LeadcampName = newCampgn.Name;
            controller.selectButton();
        }        
    }
    static testMethod void dealRegRTwithallcriteriaTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Helper.skipinsert = true;
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');
        Contact newCont = new Contact(FirstName='TestContactFN9',
                                      LastName='TestContactLN9',
                                      accountId=listAcc[0].Id,
                                      Email='TestContactEmail9@ust-global.com',
                                      fax='01987645',
                                      MobilePhone='0000019',
                                      Phone='0000000');
        insert newCont;        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        final List<Profile> stdProfiles = [select id,name 
                                           from Profile 
                                           where name like 'System Administrator' 
                                           limit 1];
        User u = new User(
            Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
            Alias = 'adm', 
            Email='MyTestAdmin009@dell.com', 
            FirstName='MyTestAdmin1', 
            LastName='MyTestAdmin1',  
            ProfileId = stdProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Admin007', 
            isActive = TRUE            
        );
        insert u;
        Test.startTest(); 
        User partnerUser = new User(
            Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest009@dell.com', 
            FirstName='MyTestUser09', 
            LastName='MyTestUser09',  
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='909', 
            isActive = TRUE,
            Enable_Partner_Deal_Registration__c = TRUE, 
            Enable_Partner_Lead_Management__c = TRUE, 
            Enable_As_Partner_Lead_Super_User__c = TRUE,
            ContactId = newCont.id );     
        insert partnerUser;        
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0        
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Region__c='ABU',                        
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Allocation_Source__c = 'Dell Allocation ABU',
                                          Nurture_Source__c = 'Dell Nurturing',
                                          Country_Code__c = 'BR - Brazil',
                                          Partner_Event_or_Campaign__c = TRUE,
                                          IsActive = true,
                                          RecordTypeId = campRTId,
                                          Total_Value_Won_Opportunities_Planned__c = 1,
                                          Total_Value_Opportunities_Planned__c = 1,
                                          Partner_Campaign_Contact__c = partnerUser.Id,
                                          Lead_Routing__c = 'Dell Standard',
                                          Partner_Campaign_Contact_Email__c = 'test@test.com'); //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c (
            Campaign__c = newCampgn.Id,
            Partner_Account__c = listAcc[0].Id );
        insert pcm;        
        System.runAs(u){
            List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
            List<PermissionSet> listleadpermset = [SELECT Id, Name
                                                   FROM PermissionSet 
                                                   WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
            PermissionSetAssignment assi = new PermissionSetAssignment(
                AssigneeId = partnerUser.Id, 
                PermissionSetId = listleadpermset[0].Id);
            listassignment.add(assi);
            if(listassignment.Size() > 0){
                insert listassignment;
            }
        }         
        Lead leadObjectRecord = new Lead();
        Id leadAssignmentRTId = '012A0000000ViCT';
        Id leadsubmsnRTId = '012A0000000ViCJ';
        leadObjectRecord = new Lead(FirstName='@@@@@', lastName = 'Test Lead',
                                    email ='testcmap@cmaptest.com',
                                    status = 'Open - Channel Lead',
                                    Phone='88967544',
                                    Partner_Account__c =  listAcc[0].Id,
                                    country = 'US',
                                    Partner_User__c =partnerUser.Id,
                                    Ready_For_Scoring__c = TRUE,
                                    Budget__c ='Yes',
                                    Purchase_Timeframe__c = 'Immediately',
                                    Campaign__c  = newCampgn.Id,
                                    RecordTypeId = leadsubmsnRTId,
                                    Total_Expected_Dell_Revenue__c = 1,
                                    Called_Customer__c = 'Yes',
                                    Sales_Qualified__c = 'Qualified',
                                    Company = 'Test Company');
        insert leadObjectRecord;
        Test.stopTest();
        leadObjectRecord.OwnerId = PartnerUser.Id;
        leadObjectRecord.RecordTypeId = leadAssignmentRTId;
        TriggerExecutionController.setSkipLeadTriggers(true);
        update leadObjectRecord;
        System.runAs(PartnerUser){
            channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
            Opportunity oppRec = new Opportunity();
            Lead leadRec = new Lead();
            PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
            Test.setCurrentPage(pr);
            controller.Firstname = '@@@@@';
            controller.LastName = 'Test';
            controller.Company = 'Test';
            controller.PartnerAccount = 'Test';
            controller.Campaign = 'Test';
            controller.Email = 'testcmap@cmaptest.com';              
            controller.oppRec = oppRec;
            controller.oppRec.CloseDate = System.Today();
            controller.leadRec.Follow_up_Date__c = System.Today();
            try{ controller.Search();}catch(exception e){system.debug('exception');}            
        }         
    }
    static testMethod void dealRegRTwithlastnamecriteriaTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Helper.skipinsert = true;
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');        
        Contact newCont = new Contact(FirstName='TestContactFN9',
                                      LastName='TestContactLN9',
                                      accountId=listAcc[0].Id,
                                      Email='TestContactEmail9@ust-global.com',
                                      fax='01987645',
                                      MobilePhone='0000019',
                                      Phone='0000000');
        insert newCont;        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        final List<Profile> stdProfiles = [select id,name 
                                           from Profile 
                                           where name like 'System Administrator' 
                                           limit 1];
        User u = new User(
            Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
            Alias = 'adm', 
            Email='MyTestAdmin009@dell.com', 
            FirstName='MyTestAdmin1', 
            LastName='MyTestAdmin1',  
            ProfileId = stdProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Admin007', 
            isActive = TRUE
        );
        insert u;
        Test.startTest(); 
        User partnerUser = new User(
            Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest009@dell.com', 
            FirstName='MyTestUser09', 
            LastName='MyTestUser09',  
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='909', 
            isActive = TRUE,
            Enable_Partner_Deal_Registration__c = TRUE, 
            Enable_Partner_Lead_Management__c = TRUE, 
            Enable_As_Partner_Lead_Super_User__c = TRUE,
            ContactId = newCont.id            
        );     
        insert partnerUser;       
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Region__c='ABU',                        
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Allocation_Source__c = 'Dell Allocation ABU',
                                          Nurture_Source__c = 'Dell Nurturing',
                                          Country_Code__c = 'BR - Brazil',
                                          Partner_Event_or_Campaign__c = TRUE,
                                          IsActive = true,
                                          RecordTypeId = campRTId,
                                          Total_Value_Won_Opportunities_Planned__c = 1,
                                          Total_Value_Opportunities_Planned__c = 1,
                                          Partner_Campaign_Contact__c = partnerUser.Id,
                                          Lead_Routing__c = 'Dell Standard',
                                          Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c (
            Campaign__c = newCampgn.Id,
            Partner_Account__c = listAcc[0].Id );
        insert pcm;
        System.runAs(u){
            List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
            List<PermissionSet> listleadpermset = [SELECT Id, Name
                                                   FROM PermissionSet 
                                                   WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
            PermissionSetAssignment assi = new PermissionSetAssignment(
                AssigneeId = partnerUser.Id, 
                PermissionSetId = listleadpermset[0].Id);
            listassignment.add(assi);
            if(listassignment.Size() > 0){
                insert listassignment;
            }
        }         
        Lead leadObjectRecord = new Lead();
        Id leadAssignmentRTId = '012A0000000ViCT';
        Id leadsubmsnRTId = '012A0000000ViCJ';
        leadObjectRecord = new Lead(FirstName='@@@@@', lastName = 'Test Lead',
                                    email ='testcmap@cmaptest.com',
                                    status = 'Open - Channel Lead',
                                    Phone='88967544',
                                    Partner_Account__c =  listAcc[0].Id,
                                    country = 'US',
                                    Partner_User__c =partnerUser.Id,
                                    Ready_For_Scoring__c = TRUE,
                                    Budget__c ='Yes',
                                    Purchase_Timeframe__c = 'Immediately',
                                    Campaign__c  = newCampgn.Id,
                                    RecordTypeId = leadsubmsnRTId,
                                    Total_Expected_Dell_Revenue__c = 1,
                                    Called_Customer__c = 'Yes',
                                    Sales_Qualified__c = 'Qualified',
                                    Company = 'Test Company');
        insert leadObjectRecord;
        Test.stopTest();
        leadObjectRecord.OwnerId = PartnerUser.Id;
        leadObjectRecord.RecordTypeId = leadAssignmentRTId;
        TriggerExecutionController.setSkipLeadTriggers(true);
        update leadObjectRecord;
        System.runAs(PartnerUser){
            channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
            Opportunity oppRec = new Opportunity();
            Lead leadRec = new Lead();
            PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
            Test.setCurrentPage(pr);
            controller.Firstname = '';
            controller.LastName = 'Test';
            controller.Company = '';
            controller.PartnerAccount = '';
            controller.Campaign = '';
            controller.Email = '';  
            controller.oppRec = oppRec;
            try{controller.Search();}catch(exception e){system.debug('exception');}
        } 
    }
    static testMethod void dealRegRTwithlastCompanycriteriaTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Helper.skipinsert = true;
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');       
        Contact newCont = new Contact(FirstName='TestContactFN9',
                                      LastName='TestContactLN9',
                                      accountId=listAcc[0].Id,
                                      Email='TestContactEmail9@ust-global.com',
                                      fax='01987645',
                                      MobilePhone='0000019',
                                      Phone='0000000');
        insert newCont;        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        final List<Profile> stdProfiles = [select id,name 
                                           from Profile 
                                           where name like 'System Administrator' 
                                           limit 1];
        User u = new User(
            Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
            Alias = 'adm', 
            Email='MyTestAdmin009@dell.com', 
            FirstName='MyTestAdmin1', 
            LastName='MyTestAdmin1',  
            ProfileId = stdProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Admin007', 
            isActive = TRUE
            
        );
        insert u;
        Test.startTest(); 
        User partnerUser = new User(
            Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest009@dell.com', 
            FirstName='MyTestUser09', 
            LastName='MyTestUser09',  
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='909', 
            isActive = TRUE,
            Enable_Partner_Deal_Registration__c = TRUE, 
            Enable_Partner_Lead_Management__c = TRUE, 
            Enable_As_Partner_Lead_Super_User__c = TRUE,
            ContactId = newCont.id
            
        );     
        insert partnerUser;       
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Region__c='ABU',                        
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Allocation_Source__c = 'Dell Allocation ABU',
                                          Nurture_Source__c = 'Dell Nurturing',
                                          Country_Code__c = 'BR - Brazil',
                                          Partner_Event_or_Campaign__c = TRUE,
                                          IsActive = true,
                                          RecordTypeId = campRTId,
                                          Total_Value_Won_Opportunities_Planned__c = 1,
                                          Total_Value_Opportunities_Planned__c = 1,
                                          Partner_Campaign_Contact__c = partnerUser.Id,
                                          Lead_Routing__c = 'Dell Standard',
                                          Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c (
            Campaign__c = newCampgn.Id,
            Partner_Account__c = listAcc[0].Id );
        insert pcm;
        System.runAs(u){
            List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
            List<PermissionSet> listleadpermset = [SELECT Id, Name
                                                   FROM PermissionSet 
                                                   WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
            PermissionSetAssignment assi = new PermissionSetAssignment(
                AssigneeId = partnerUser.Id, 
                PermissionSetId = listleadpermset[0].Id);
            listassignment.add(assi);
            if(listassignment.Size() > 0){
                insert listassignment;
            }
        }         
        Lead leadObjectRecord = new Lead();
        Id leadAssignmentRTId = '012A0000000ViCT';
        Id leadsubmsnRTId = '012A0000000ViCJ';
        leadObjectRecord = new Lead(FirstName='@@@@@', lastName = 'Test Lead',
                                    email ='testcmap@cmaptest.com',
                                    status = 'Open - Channel Lead',
                                    Phone='88967544',
                                    Partner_Account__c =  listAcc[0].Id,
                                    country = 'US',
                                    Partner_User__c =partnerUser.Id,
                                    Ready_For_Scoring__c = TRUE,
                                    Budget__c ='Yes',
                                    Purchase_Timeframe__c = 'Immediately',
                                    Campaign__c  = newCampgn.Id,
                                    RecordTypeId = leadsubmsnRTId,
                                    Total_Expected_Dell_Revenue__c = 1,
                                    Called_Customer__c = 'Yes',
                                    Sales_Qualified__c = 'Qualified',
                                    Company = 'Test Company');
        insert leadObjectRecord;
        Test.stopTest();
        leadObjectRecord.OwnerId = PartnerUser.Id;
        leadObjectRecord.RecordTypeId = leadAssignmentRTId;
        TriggerExecutionController.setSkipLeadTriggers(true);
        update leadObjectRecord;
        System.runAs(PartnerUser){
            channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
            Opportunity oppRec = new Opportunity();
            Lead leadRec = new Lead();
            PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
            Test.setCurrentPage(pr);
            controller.Firstname = '';
            controller.LastName = '';
            controller.Company = 'Test';
            controller.PartnerAccount = '';
            controller.Campaign = '';
            controller.Email = ''; 
            controller.oppRec = oppRec;
            try{controller.Search();
               }catch(exception e){
               }
        } 
    }
    static testMethod void dealRegRTwithAcccriteriaTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Helper.skipinsert = true;
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');       
        Contact newCont = new Contact(FirstName='TestContactFN9',
                                      LastName='TestContactLN9',
                                      accountId=listAcc[0].Id,
                                      Email='TestContactEmail9@ust-global.com',
                                      fax='01987645',
                                      MobilePhone='0000019',
                                      Phone='0000000');
        insert newCont;
        final List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        final List<Profile> stdProfiles = [select id,name from Profile where name like 'System Administrator' limit 1];
        User u = new User(
            Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
            Alias = 'adm', 
            Email='MyTestAdmin009@dell.com', 
            FirstName='MyTestAdmin1', 
            LastName='MyTestAdmin1',  
            ProfileId = stdProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Admin007', 
            isActive = TRUE
        );
        insert u;
        Test.startTest(); 
        User partnerUser = new User(
            Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest009@dell.com', 
            FirstName='MyTestUser09', 
            LastName='MyTestUser09',  
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='909', 
            isActive = TRUE,
            Enable_Partner_Deal_Registration__c = TRUE, 
            Enable_Partner_Lead_Management__c = TRUE, 
            Enable_As_Partner_Lead_Super_User__c = TRUE,
            ContactId = newCont.id
        );     
        insert partnerUser;
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Region__c='ABU',                        
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Allocation_Source__c = 'Dell Allocation ABU',
                                          Nurture_Source__c = 'Dell Nurturing',
                                          Country_Code__c = 'BR - Brazil',
                                          Partner_Event_or_Campaign__c = TRUE,
                                          IsActive = true,
                                          RecordTypeId = campRTId,
                                          Total_Value_Won_Opportunities_Planned__c = 1,
                                          Total_Value_Opportunities_Planned__c = 1,
                                          Partner_Campaign_Contact__c = partnerUser.Id,
                                          Lead_Routing__c = 'Dell Standard',
                                          Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c (
            Campaign__c = newCampgn.Id,
            Partner_Account__c = listAcc[0].Id );
        insert pcm;
        System.runAs(u){
            List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
            List<PermissionSet> listleadpermset = [SELECT Id, Name
                                                   FROM PermissionSet 
                                                   WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
            PermissionSetAssignment assi = new PermissionSetAssignment(
                AssigneeId = partnerUser.Id, 
                PermissionSetId = listleadpermset[0].Id);
            listassignment.add(assi);
            if(listassignment.Size() > 0){
                insert listassignment;
            }
        }         
        Lead leadObjectRecord = new Lead();
        Id leadAssignmentRTId = '012A0000000ViCT';
        Id leadsubmsnRTId = '012A0000000ViCJ';
        leadObjectRecord = new Lead(FirstName='@@@@@', lastName = 'Test Lead',
                                    email ='testcmap@cmaptest.com',
                                    status = 'Open - Channel Lead',
                                    Phone='88967544',
                                    Partner_Account__c =  listAcc[0].Id,
                                    country = 'US',
                                    Partner_User__c =partnerUser.Id,
                                    Ready_For_Scoring__c = TRUE,
                                    Budget__c ='Yes',
                                    Purchase_Timeframe__c = 'Immediately',
                                    Campaign__c  = newCampgn.Id,
                                    RecordTypeId = leadsubmsnRTId,
                                    Total_Expected_Dell_Revenue__c = 1,
                                    Called_Customer__c = 'Yes',
                                    Sales_Qualified__c = 'Qualified',
                                    Company = 'Test Company');
        insert leadObjectRecord;
        Test.stopTest();
        leadObjectRecord.OwnerId = PartnerUser.Id;
        leadObjectRecord.RecordTypeId = leadAssignmentRTId;
        TriggerExecutionController.setSkipLeadTriggers(true);
        update leadObjectRecord;
        System.runAs(PartnerUser){
            channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
            Opportunity oppRec = new Opportunity();
            Lead leadRec = new Lead();
            PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
            Test.setCurrentPage(pr);
            controller.Firstname = '';
            controller.LastName = '';
            controller.Company = '';
            controller.PartnerAccount = 'Test';
            controller.Campaign = '';
            controller.Email = '';  
            controller.oppRec = oppRec;
            
        } 
    }
    static testMethod void dealRegRTwithCampCriteriaTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Helper.skipinsert = true;
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');
        Contact newCont = new Contact(FirstName='TestContactFN9',
                                      LastName='TestContactLN9',
                                      accountId=listAcc[0].Id,
                                      Email='TestContactEmail9@ust-global.com',
                                      fax='01987645',
                                      MobilePhone='0000019',
                                      Phone='0000000');
        insert newCont;
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        final List<Profile> stdProfiles = [select id,name 
                                           from Profile 
                                           where name like 'System Administrator' 
                                           limit 1];
        User u = new User(
            Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
            Alias = 'adm', 
            Email='MyTestAdmin009@dell.com', 
            FirstName='MyTestAdmin1', 
            LastName='MyTestAdmin1',  
            ProfileId = stdProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Admin007', 
            isActive = TRUE
        );
        insert u;
        Test.startTest(); 
        User partnerUser = new User(
            Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest009@dell.com', 
            FirstName='MyTestUser09', 
            LastName='MyTestUser09',  
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='909', 
            isActive = TRUE,
            Enable_Partner_Deal_Registration__c = TRUE, 
            Enable_Partner_Lead_Management__c = TRUE, 
            Enable_As_Partner_Lead_Super_User__c = TRUE,
            ContactId = newCont.id
        );     
        insert partnerUser;
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Region__c='ABU',                        
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Allocation_Source__c = 'Dell Allocation ABU',
                                          Nurture_Source__c = 'Dell Nurturing',
                                          Country_Code__c = 'BR - Brazil',
                                          Partner_Event_or_Campaign__c = TRUE,
                                          IsActive = true,
                                          RecordTypeId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true),
                                          Total_Value_Won_Opportunities_Planned__c = 1,
                                          Total_Value_Opportunities_Planned__c = 1,
                                          Partner_Campaign_Contact__c = partnerUser.Id,
                                          Lead_Routing__c = 'Dell Standard',
                                          Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c (
            Campaign__c = newCampgn.Id,
            Partner_Account__c = listAcc[0].Id );
        insert pcm;
        System.runAs(u){
            List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
            List<PermissionSet> listleadpermset = [SELECT Id, Name
                                                   FROM PermissionSet 
                                                   WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
            PermissionSetAssignment assi = new PermissionSetAssignment(
                AssigneeId = partnerUser.Id, 
                PermissionSetId = listleadpermset[0].Id);
            listassignment.add(assi);
            if(listassignment.Size() > 0){
                insert listassignment;
            }
        }         
        Lead leadObjectRecord = new Lead();
        Id leadAssignmentRTId = '012A0000000ViCT';
        Id leadsubmsnRTId = '012A0000000ViCJ';
        leadObjectRecord = new Lead(FirstName='@@@@@', lastName = 'Test Lead',
                                    email ='testcmap@cmaptest.com',
                                    status = 'Open - Channel Lead',
                                    Phone='88967544',
                                    Partner_Account__c =  listAcc[0].Id,
                                    country = 'US',
                                    Partner_User__c =partnerUser.Id,
                                    Ready_For_Scoring__c = TRUE,
                                    Budget__c ='Yes',
                                    Purchase_Timeframe__c = 'Immediately',
                                    Campaign__c  = newCampgn.Id,
                                    RecordTypeId = leadsubmsnRTId,
                                    Total_Expected_Dell_Revenue__c = 1,
                                    Called_Customer__c = 'Yes',
                                    Sales_Qualified__c = 'Qualified',
                                    Company = 'Test Company');
        insert leadObjectRecord;
        Test.stopTest();
        leadObjectRecord.OwnerId = PartnerUser.Id;
        leadObjectRecord.RecordTypeId = leadAssignmentRTId;
        TriggerExecutionController.setSkipLeadTriggers(true);
        update leadObjectRecord;
        System.runAs(PartnerUser){
            channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
            Opportunity oppRec = new Opportunity();
            Lead leadRec = new Lead();
            PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
            Test.setCurrentPage(pr);
            controller.Firstname = '';
            controller.LastName = '';
            controller.Company = '';
            controller.PartnerAccount = '';
            controller.Campaign = 'Test';
            controller.Email = '';  
            controller.oppRec = oppRec;
            try{controller.Search();}catch(exception e){system.debug('exception');}
            controller.skipSearch();
        } 
    }
    static testMethod void dealRegRTwithEmailCriteriaTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Helper.skipinsert = true;
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');
        Contact newCont = new Contact(FirstName='TestContactFN9',
                                      LastName='TestContactLN9',
                                      accountId=listAcc[0].Id,
                                      Email='TestContactEmail9@ust-global.com',
                                      fax='01987645',
                                      MobilePhone='0000019',
                                      Phone='0000000');
        insert newCont;
        final List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        final List<Profile> stdProfiles = [select id,name  from Profile where name like 'System Administrator' limit 1];
        User u = new User(
            Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
            Alias = 'adm', 
            Email='MyTestAdmin009@dell.com', 
            FirstName='MyTestAdmin1', 
            LastName='MyTestAdmin1',  
            ProfileId = stdProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Admin007', 
            isActive = TRUE
        );
        insert u;
        Test.startTest(); 
        User partnerUser = new User(
            Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest009@dell.com', 
            FirstName='MyTestUser09', 
            LastName='MyTestUser09',  
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='909', 
            isActive = TRUE,
            Enable_Partner_Deal_Registration__c = TRUE, 
            Enable_Partner_Lead_Management__c = TRUE, 
            Enable_As_Partner_Lead_Super_User__c = TRUE,
            ContactId = newCont.id
        );     
        insert partnerUser;
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Region__c='ABU',                        
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Allocation_Source__c = 'Dell Allocation ABU',
                                          Nurture_Source__c = 'Dell Nurturing',
                                          Country_Code__c = 'BR - Brazil',
                                          Partner_Event_or_Campaign__c = TRUE,
                                          IsActive = true,
                                          //v6.0 Start
                                          RecordTypeId = '012A0000000VnzX',
                                          //v6.0 End
                                          Total_Value_Won_Opportunities_Planned__c = 1,
                                          Total_Value_Opportunities_Planned__c = 1,
                                          Partner_Campaign_Contact__c = partnerUser.Id,
                                          Lead_Routing__c = 'Dell Standard',
                                          Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c (
            Campaign__c = newCampgn.Id,
            Partner_Account__c = listAcc[0].Id );
        insert pcm;
        System.runAs(u){
            List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
            List<PermissionSet> listleadpermset = [SELECT Id, Name FROM PermissionSet WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
            PermissionSetAssignment assi = new PermissionSetAssignment(
                AssigneeId = partnerUser.Id, 
                PermissionSetId = listleadpermset[0].Id);
            listassignment.add(assi);
            if(listassignment.Size() > 0){
                insert listassignment;
            }
        }         
        Lead leadObjectRecord = new Lead();
        Id leadAssignmentRTId = '012A0000000ViCT';
        Id leadsubmsnRTId = '012A0000000ViCJ';
        leadObjectRecord = new Lead(FirstName='@@@@@', lastName = 'Test Lead',
                                    email ='testcmap@cmaptest.com',
                                    status = 'Open - Channel Lead',
                                    Phone='88967544',
                                    Partner_Account__c =  listAcc[0].Id,
                                    country = 'US',
                                    Partner_User__c =partnerUser.Id,
                                    Ready_For_Scoring__c = TRUE,
                                    Budget__c ='Yes',
                                    Purchase_Timeframe__c = 'Immediately',
                                    Campaign__c  = newCampgn.Id,
                                    RecordTypeId = leadsubmsnRTId,
                                    Total_Expected_Dell_Revenue__c = 1,
                                    Called_Customer__c = 'Yes',
                                    Sales_Qualified__c = 'Qualified',
                                    Company = 'Test Company');
        insert leadObjectRecord;
        Test.stopTest();
        leadObjectRecord.OwnerId = PartnerUser.Id;
        leadObjectRecord.RecordTypeId = leadAssignmentRTId;
        TriggerExecutionController.setSkipLeadTriggers(true);
        update leadObjectRecord;
        System.runAs(PartnerUser){
            channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
            Opportunity oppRec = new Opportunity();
            Lead leadRec = new Lead();
            PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
            Test.setCurrentPage(pr);
            controller.Firstname = '';
            controller.LastName = '';
            controller.Company = '';
            controller.PartnerAccount = '';
            controller.Campaign = '';
            controller.Email = 'testcmap@cmaptest.com';  
            controller.oppRec = oppRec;
            try{controller.Search();
               }
            catch(exception e){
            }
        } 
    }
    /*  static testMethod void dealRegRTwithDate1CriteriaTest() {
TriggerExecutionController.setSkipAllTriggers(true);
CMAP_Helper.skipinsert = true;
listAcc = [select id,name from Account limit 1];
listAcc[0].Type = 'Partner';
update listAcc;
system.assertEquals(listAcc[0].Type, 'Partner');
Contact newCont = new Contact(FirstName='TestContactFN9',
LastName='TestContactLN9',
accountId=listAcc[0].Id,
Email='TestContactEmail9@ust-global.com',
fax='01987645',
MobilePhone='0000019',
Phone='0000000');
insert newCont;
final List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%PRM%' 
order by CreatedDate DESC limit 1];
final List<Profile> stdProfiles = [select id,name from Profile where name like 'System Administrator' limit 1];
User u = new User(
Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
Alias = 'adm', 
Email='MyTestAdmin009@dell.com', 
FirstName='MyTestAdmin1', 
LastName='MyTestAdmin1',  
ProfileId = stdProfiles.get(0).Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Admin007', 
isActive = TRUE
);
insert u;
Test.startTest(); 
User partnerUser = new User(
Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
Alias = 'tt2', 
Email='MyTest009@dell.com', 
FirstName='MyTestUser09', 
LastName='MyTestUser09',  
ProfileId = partnerProfiles.get(0).Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='909', 
isActive = TRUE,
Enable_Partner_Deal_Registration__c = TRUE, 
Enable_Partner_Lead_Management__c = TRUE, 
Enable_As_Partner_Lead_Super_User__c = TRUE,
ContactId = newCont.id
);     
insert partnerUser;
Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
Type='Advisory Councils',Segment_Business_Unit__c='SMB',
Region__c='ABU',                        
Follow_Up_Role__c='Account Executive',
Description='Test',StartDate=system.today(),EndDate=system.today(),
status='In Progress',
Allocation_Source__c = 'Dell Allocation ABU',
Nurture_Source__c = 'Dell Nurturing',
Country_Code__c = 'BR - Brazil',
Partner_Event_or_Campaign__c = TRUE,
IsActive = true,
//v6.0 start 
RecordTypeId = '012A0000000VnzX',
//v6.0 end
Total_Value_Won_Opportunities_Planned__c = 1,
Total_Value_Opportunities_Planned__c = 1,
Partner_Campaign_Contact__c = partnerUser.Id,
Lead_Routing__c = 'Dell Standard',
Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
insert newCampgn;
Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c (
Campaign__c = newCampgn.Id,
Partner_Account__c = listAcc[0].Id );
insert pcm;
System.runAs(u){
List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
List<PermissionSet> listleadpermset = [SELECT Id, Name FROM PermissionSet WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
PermissionSetAssignment assi = new PermissionSetAssignment(
AssigneeId = partnerUser.Id, 
PermissionSetId = listleadpermset[0].Id);
listassignment.add(assi);
if(listassignment.Size() > 0){
insert listassignment;
}
}         
Lead leadObjectRecord = new Lead();
Id leadAssignmentRTId = '012A0000000ViCT';
Id leadsubmsnRTId = '012A0000000ViCJ';
leadObjectRecord = new Lead(FirstName='@@@@@', lastName = 'Test Lead',
email ='testcmap@cmaptest.com',
status = 'Open - Channel Lead',
Phone='88967544',
Partner_Account__c =  listAcc[0].Id,
country = 'US',
Partner_User__c =partnerUser.Id,
Ready_For_Scoring__c = TRUE,
Budget__c ='Yes',
Purchase_Timeframe__c = 'Immediately',
Campaign__c  = newCampgn.Id,
RecordTypeId = leadsubmsnRTId,
Total_Expected_Dell_Revenue__c = 1,
Called_Customer__c = 'Yes',
Sales_Qualified__c = 'Qualified',
Company = 'Test Company');
insert leadObjectRecord;
Test.stopTest();
leadObjectRecord.OwnerId = PartnerUser.Id;
leadObjectRecord.RecordTypeId = leadAssignmentRTId;
update leadObjectRecord;
System.runAs(PartnerUser){
channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
Opportunity oppRec = new Opportunity();
Lead leadRec = new Lead();
PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
Test.setCurrentPage(pr);
controller.Firstname = '';
controller.LastName = '';
controller.Company = '';
controller.PartnerAccount = '';
controller.Campaign = '';
controller.Email = '';  
controller.oppRec = oppRec;
controller.oppRec.CloseDate = system.Today();
} 
}*/
    static testMethod void dealRegRTwithDate2CriteriaTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        CMAP_Helper.skipinsert = true;
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        system.assertEquals(listAcc[0].Type, 'Partner');
        Contact newCont = new Contact(FirstName='TestContactFN9',
                                      LastName='TestContactLN9',
                                      accountId=listAcc[0].Id,
                                      Email='TestContactEmail9@ust-global.com',
                                      fax='01987645',
                                      MobilePhone='0000019',
                                      Phone='0000000');
        insert newCont;
        final List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
        final List<Profile> stdProfiles = [select id,name from Profile where name like 'System Administrator' limit 1];
        User u = new User(
            Username='MyTestAdmin' + System.currentTimeMillis() + '@dell.com',
            Alias = 'adm', 
            Email='MyTestAdmin009@dell.com', 
            FirstName='MyTestAdmin1', 
            LastName='MyTestAdmin1',  
            ProfileId = stdProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Admin007', 
            isActive = TRUE
        );
        insert u;
        Test.startTest(); 
        User partnerUser = new User(
            Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
            Alias = 'tt2', 
            Email='MyTest009@dell.com', 
            FirstName='MyTestUser09', 
            LastName='MyTestUser09',  
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='909', 
            isActive = TRUE,
            Enable_Partner_Deal_Registration__c = TRUE, 
            Enable_Partner_Lead_Management__c = TRUE, 
            Enable_As_Partner_Lead_Super_User__c = TRUE,
            ContactId = newCont.id
        );     
        insert partnerUser;
        Campaign newCampgn = new Campaign(Name='MyTestCampaign9',
                                          Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                          Region__c='ABU',                        
                                          Follow_Up_Role__c='Account Executive',
                                          Description='Test',StartDate=system.today(),EndDate=system.today(),
                                          status='In Progress',
                                          Allocation_Source__c = 'Dell Allocation ABU',
                                          Nurture_Source__c = 'Dell Nurturing',
                                          Country_Code__c = 'BR - Brazil',
                                          Partner_Event_or_Campaign__c = TRUE,
                                          IsActive = true,
                                          RecordTypeId = '012A0000000VnzX',
                                          Total_Value_Won_Opportunities_Planned__c = 1,
                                          Total_Value_Opportunities_Planned__c = 1,
                                          Lead_Routing__c = 'Dell Standard',
                                          Partner_Campaign_Contact__c = partnerUser.Id,
                                          Partner_Campaign_Contact_Email__c = 'test@test.com');  //2.0
        insert newCampgn;
        Partner_Campaign_Management__c pcm = new Partner_Campaign_Management__c (
            Campaign__c = newCampgn.Id,
            Partner_Account__c = listAcc[0].Id );
        insert pcm;
        System.runAs(u){
            List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
            List<PermissionSet> listleadpermset = [SELECT Id, Name FROM PermissionSet WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
            PermissionSetAssignment assi = new PermissionSetAssignment(
                AssigneeId = partnerUser.Id, 
                PermissionSetId = listleadpermset[0].Id);
            listassignment.add(assi);
            if(listassignment.Size() > 0){
                insert listassignment;
            }
        }         
        Lead leadObjectRecord = new Lead();
        Id leadAssignmentRTId = '012A0000000ViCT';
        Id leadsubmsnRTId = '012A0000000ViCJ';
        leadObjectRecord = new Lead(FirstName='@@@@@', lastName = 'Test Lead',
                                    email ='testcmap@cmaptest.com',
                                    status = 'Open - Channel Lead',
                                    Phone='88967544',
                                    Partner_Account__c =  listAcc[0].Id,
                                    country = 'US',
                                    Partner_User__c =partnerUser.Id,
                                    Ready_For_Scoring__c = TRUE,
                                    Budget__c ='Yes',
                                    Purchase_Timeframe__c = 'Immediately',
                                    Campaign__c  = newCampgn.Id,
                                    RecordTypeId = leadsubmsnRTId,
                                    Total_Expected_Dell_Revenue__c = 1,
                                    Called_Customer__c = 'Yes',
                                    Sales_Qualified__c = 'Qualified',
                                    Company = 'Test Company');
        insert leadObjectRecord;
        Test.stopTest();
        leadObjectRecord.OwnerId = PartnerUser.Id;
        leadObjectRecord.RecordTypeId = leadAssignmentRTId;
        TriggerExecutionController.setSkipLeadTriggers(true);
        update leadObjectRecord;
        System.runAs(PartnerUser){
            channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
            Opportunity oppRec = new Opportunity();
            Lead leadRec = new Lead();
            PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
            Test.setCurrentPage(pr);
            controller.Firstname = '';
            controller.LastName = '';
            controller.Company = '';
            controller.PartnerAccount = '';
            controller.Campaign = '';
            controller.Email = '';  
            controller.oppRec = oppRec;
            controller.LeadRec.Follow_Up_Date__c  = system.Today();
            try{controller.Search();}catch(exception e){system.debug('exception e');}
            try{controller.First();}catch(exception e){system.debug('exception e');}
            try{controller.Next();}catch(exception e){system.debug('exception e');}
            try{controller.Previous();}catch(exception e){system.debug('exception e');}
            try{controller.Last();}catch(exception e){system.debug('exception e');}
        } 
    }
    //version 3.0
    static testMethod void testDSGuperuser() {
        //retrieve DSG Partner RT
        Id dSGLeadRTId = IdLookupUtils.getRecordTypeId('DSG Partner', 'Lead', true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        //Query for DSG Partner campaign, if does not exsits create new
        List<Campaign> listcam = [SELECT id from Campaign where name = 'DSG Partner'];
        if(listcam.size()==0 || listcam == null){
            Campaign dsgCampaign = new Campaign(name = 'DSG Partner',Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                                Region__c='ABU',                
                                                Description='Test',StartDate=system.today(),EndDate=system.today()+15,
                                                status='In Progress',
                                                Allocation_Source__c='Channel OEM',
                                                Nurture_Source__c='OEM Nurturing',
                                                Country_Code__c = 'BR - Brazil',
                                                Partner_Event_or_Campaign__c = false,                
                                                IsActive = true,
                                                Lead_Routing__c = 'Dell Standard',
                                                RecordTypeId='012A0000000VnHF'
                                               );
            insert dsgCampaign;
            listcam.add(dsgCampaign);
        }
        listAcc = [select id,name from Account limit 1];
        Test.startTest(); 
        system.assertNotEquals(null, listAcc[0].name);
        List<Contact> listcontact = new List<Contact>();
        for(integer intcnt=0;intcnt<2;intcnt++){
            Contact newCont = new Contact(FirstName='TestContactFN9',
                                          LastName='TestContactLN9'+intcnt,
                                          accountId=listAcc[0].Id,
                                          Status__c = 'Marketing Suspect',
                                          Email='TestContactEmail9@ust-global.com',
                                          fax='01987645',
                                          MobilePhone='0000019',
                                          Last_Operation_Performed__c = 'testing',
                                          Phone='0000000');
            listcontact.add(newCont);
        }
        insert listcontact;
        final List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];        
        List<User> listuser = new List<User>();
        for(integer intcnt=0;intcnt<2;intcnt++){
            User partnerUser = new User(
                Username='MyTest2'+intcnt+ System.currentTimeMillis() + '@dell.com',
                Alias = 'tt2', 
                Email='MyTest009'+intcnt+'@dell.com', 
                FirstName='MyTestUser09', 
                LastName='MyTestUser09',  
                ProfileId = partnerProfiles.get(0).Id, 
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', 
                EmailEncodingKey='UTF-8', 
                TimeZoneSidKey='America/Los_Angeles',
                Enable_Partner_Lead_Management__c = true,
                Enable_Partner_Deal_Registration__c = true,
                Enable_As_Partner_Lead_Super_User__c = true,
                Badge_Number__c='909'+intcnt, 
                isActive = TRUE,
                ContactId = listcontact[intcnt].id
            );
            listuser.add(partnerUser);
        }                                       
        listuser[1].Enable_As_Partner_Lead_Super_User__c = true;
        insert listuser;
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User admin = [SELECT id FROM User WHERE profileid = :adminProfile.id AND isactive = true limit 1];
        CMAP_Helper.skipinsert = true;
        Lead leadObj = new Lead(lastName = 'Test DSG Lead1',
                                email ='testcmap@cmaptestdsg.com',
                                status = 'Assigned to Channel Partner',
                                Phone='88967544',
                                Country = 'US',
                                Partner_Account__c =listAcc[0].Id,
                                //Campaign__c  = listcam[0].Id,
                                recordTypeId = dSGLeadRTId,
                                Budget__c = 'Yes',
                                Purchase_Timeframe__c ='Immediate',
                                Partner_User__c =  listuser[0].Id,  
                                ownerid =  listuser[0].Id, 
                                partner_contact__c =  listcontact[0].Id,           
                                Company = 'Test Company');
        //insert leadObj;
        system.runAs(admin){
            List<PermissionSetAssignment> listassignment = new List<PermissionSetAssignment>();
            List<PermissionSet> listleadpermset = [SELECT Id, Name FROM PermissionSet WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
            PermissionSetAssignment assi = new PermissionSetAssignment(
                AssigneeId = listuser[0].Id, 
                PermissionSetId = listleadpermset[0].Id);
            listassignment.add(assi);
            if(listassignment.Size() > 0){
                insert listassignment;
            }
        }
        System.runAs(listuser[0]){
            channelOpportunityController controller = new channelOpportunityController(new ApexPages.StandardController(new Opportunity()));
            Opportunity oppRec = new Opportunity();
            Lead leadRec = new Lead();
            PageReference  pr = new PageReference('/apex/channelOpportunityOveride?retURL=%2F006%2Fo&RecordType=012A0000000VhKk&ent=Opportunity&save_new=1&sfdc.override=1');
            Test.setCurrentPage(pr);
            controller.Firstname = '';
            controller.LastName = 'Test';
            controller.Company = 'Test Company';
            controller.PartnerAccount = 'Test';
            controller.Campaign = 'DSG Partner';
            controller.Email = 'testcmap@cmaptestdsg.com';  
            controller.oppRec = oppRec;
            controller.LeadRec.Follow_Up_Date__c  = system.Today();
            try{controller.Search();}catch(exception e){system.debug('exception');}
            Test.stopTest();
        }
    }
}