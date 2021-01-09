/*
REVISION HISTORY
======================================================================================================================
Version    Author    Date            Release#       CR#     Description
-------    ------    ----            --------    ---    -----------
1.0                                                     created
2.0         Azwanti 15-March-2016   FY17-DCS-0401   12720   replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.0         Sui Yee 2-June-2016     FY17-DCS-0701   13200   skip all trigger at ValidationTest_1.@isTest(SeeAllData=true)
*/
@isTest
private class CMAP_RouteDirectLeadsController_Test {
    
   //v3.0 Setup test data for queue
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }


   static testMethod void routeDLToChannel() {
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        //v3.0 
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); 
        /*Account newCMAPAcc = new Account(name='MyTestAccountCMAP');
        insert newCMAPAcc;
                
        Contact newCMAPCont = new Contact(FirstName='MyTestContactCMAP',
                 LastName='MyTestContactCMAP',
                 accountId=newCMAPAcc.Id,
                 Email='MyTestCMAPContactEmail_3@ust-global.com',
                 fax='9876543',
                 MobilePhone='536389097',
                 Last_Operation_Performed__c = 'testing',
                 Phone='245678');
        insert newCMAPCont;*/
       //v3.0 start
           Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
           Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
           insert newAcc;
        
           Contact newCont = new Contact(FirstName='TestContactFN9'+system.now().millisecond(), //v3.1
                 LastName='TestContactLN9'+system.now().millisecond(), //v3.1 
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='TestContactEmail9'+system.now().millisecond()+'@ust-global.com', //v3.1
                 fax='01987645',
                 MobilePhone = String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond(), //v3.1
                 Last_Operation_Performed__c = 'testing',
                 Phone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond()); //v3.1
           insert newCont;
        
           final List<Profile> partnerProfiles = [select id,name 
                                                   from Profile 
                                                   where UserType = 'PowerPartner' and name like '%PRM%' 
                                                   limit 1];
                                                   
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
                        Enable_Partner_Lead_Management__c = true,
                        Enable_Partner_Deal_Registration__c = true,
                        Badge_Number__c='909', 
                        isActive = TRUE,
                        ContactId = newCont.id
                    );
           User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];   
           System.runAs ( thisUser ) {
           insert partnerUser;
            }
       //v3.0 end
        
        Campaign CMAP_dir_camp= new Campaign(Name='TestCampaign_Direct',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                //Allocation_Source__c = 'Dell Allocation ABU'
                //Nurture_Source__c = 'Dell Nurturing'
                IsActive = true,
                RecordTypeId = campRTId,                            
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',//v3.0
                Partner_Campaign_Contact__c=partnerUser.Id,//3.0
                Total_Value_Opportunities_Planned__c = 1);
         insert  CMAP_dir_camp;
         Lead SegleadObj = new Lead(lastName = 'Test Dir Lead1',
                firstName = 'CMAP',
                Salutation = 'Mr.',
                MobilePhone = '098645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                City = 'Test City',
                State = 'Test State',
                PostalCode = '9876545',
                Dell_can_contact_me_in_the_future__c='Yes',
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  CMAP_dir_camp.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                LeadSource = 'Web',//v3.0 - added since its required field
                Lead_Type__c = 'Inbound',//v3.0
                Company = 'Test Company');
        insert SegleadObj;
        PageReference pref = new PageReference('/apex/CMAP_RouteDirectLead?dirlId ='+SegleadObj.Id);
        
        Test.setCurrentPage(pref);
        CMAP_RouteDirectLeadsController leadDirRoutingCntrlr = new CMAP_RouteDirectLeadsController(new ApexPages.StandardController(new Lead()));
        leadDirRoutingCntrlr.dirlRecord = SegleadObj;
        leadDirRoutingCntrlr.dirlId = SegleadObj.Id;
        Test.startTest();
        leadDirRoutingCntrlr.redirect();
        //leadDirRoutingCntrlr.saveButton();
        //leadDirRoutingCntrlr.cancelButton();
        TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest(); 
   }
   static testMethod void CommentsPLInChannel() {
       TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        Id leadDirRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        Id CampRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        
        /*Account newCMAPAcc1 = new Account(name='MyTestAccountCMAP1');
        insert newCMAPAcc1;
                
        Contact newCMAPCont1 = new Contact(FirstName='MyTestContactCMAP1',
                 LastName='MyTestContactCMAP1',
                 accountId=newCMAPAcc1.Id,
                 Email='MyTestCMAPContactEmail_111@ust-global.com',
                 fax='9876543',
                 MobilePhone='42353567',
                 Last_Operation_Performed__c = 'testing',
                 Phone='6587698879');
        insert newCMAPCont1;
        */
        Campaign CMAP_Channel_camp= new Campaign(Name='TestCampaign_CL',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',
                Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                IsActive = true,
                RecordTypeId = CampRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
         insert  CMAP_Channel_camp;
         Campaign CMAP_dir_camp= new Campaign(Name='TestCampaign_Direct',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                RecordTypeId = CampRTId,                              
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
         insert  CMAP_dir_camp;
         Lead SegleadObj = new Lead(lastName = 'Test Dir Lead1',
                firstName = 'CMAP',
                Salutation = 'Mr.',
                MobilePhone = '098645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                City = 'Test City',
                State = 'Test State',
                PostalCode = '9876545',
                Dell_can_contact_me_in_the_future__c='Yes',
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  CMAP_dir_camp.Id,
                recordTypeId = leadDirRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                LeadSource = 'Web',//v3.0 - added since its required field
                Lead_Type__c = 'Inbound',//v3.0
                Company = 'Test Company');
        insert SegleadObj;
         Lead CLleadObj = new Lead(lastName = 'Test CL Lead1',
                firstName = 'CMAP CL',
                Salutation = 'Mr.',
                MobilePhone = '098645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                City = 'Test City',
                State = 'Test State',
                PostalCode = '9876545',
                //Segment_Lead__c = SegleadObj.Id,
                Country ='US',
                Dell_can_contact_me_in_the_future__c='Yes',
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                Campaign__c  =  CMAP_Channel_camp.Id,//v3.0
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');
        insert CLleadObj ;
        Id newId;
        PageReference pref = new PageReference('/apex/CMAP_RouteDirectLead?newId ='+CLleadObj.Id+'&retURL = '+CLleadObj.Id);
        Test.setCurrentPage(pref);
        system.debug('---ffff---'+pref);
        CMAP_RouteDirectLeadsController leadDirRoutingCntrlr = new CMAP_RouteDirectLeadsController(new ApexPages.StandardController(new Lead()));
        leadDirRoutingCntrlr.clRecord = CLleadObj;
        leadDirRoutingCntrlr.newId= CLleadObj.Id;
        Test.startTest();
        //leadDirRoutingCntrlr.redirect();
        leadDirRoutingCntrlr.saveButton();
        //leadDirRoutingCntrlr.cancelButton();
        TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest(); 
   }
}