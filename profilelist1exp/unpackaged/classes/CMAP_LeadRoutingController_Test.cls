/* 
REVISION HISTORY
================
Version     Author      Date            Release#    	CR#     Description
-------     ------      ----            --------    	---     -----------
1.0																created
2.0 		Sui Yee		29-March-2016	FY17-DCS-0401	12720	replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.0			Azwanti		26-May-2016		FY17-DCS-0701	13174	Fix error when replacing the Channel Campaign and GBL Standart Record Type with Campaign 2.0 record type
4.0         Josie       01-June-2016    FY17-DCS-0701   13174   Continue Fixing error when replacing the Channel Campaign and GBL Standart Record Type with Campaign 2.0 record type @isTest(SeeAllData=true)
*/

@isTest
private class CMAP_LeadRoutingController_Test {

    //v4.0 Setup test data for queue
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }

   static testMethod void routeToChannel() {
        TriggerExecutionController.setSkipAllTriggers(true);//v4.0
        //Test.startTest();
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v2.0
		Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); 
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v3.0
		Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        Account newAcc = new Account(name='MyTestAccount3');
        insert newAcc;
                
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id, 
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',              
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
		
        //v2.0 start
		final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               limit 1];
                      
        User partnerUser = new User(
                    Username='JohnDoe001' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'JD1001', 
                    Email='JohnDoe001@dell.com', 
                    FirstName='John001', 
                    LastName='Doe001', 
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Enable_Partner_Lead_Management__c = true,
                    Enable_Partner_Deal_Registration__c = true,
                    Badge_Number__c='001', 
                    isActive = TRUE,
                    //AccountId = accountObj.Id,
                    ContactId = newCont.id
                );
       User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];   
       System.runAs ( thisUser ) {
       insert partnerUser;
       }
		
		//v1.0 end
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Allocation_Source__c = 'Dell Allocation ABU',//v1.0
                Nurture_Source__c = 'Dell Nurturing', //v1.0                    
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
				Partner_Campaign_Contact__c = partnerUser.Id,//v1.0
                Partner_Campaign_Contact_Email__c = 'test@dell.com',//v1.0
                IsActive = true,
				RecordTypeId = campRTId,//v2.0
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
         insert campDirectObj;
       
       //v3.0
		Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Allocation_Source__c = 'Dell Allocation ABU',//v1.0
                Nurture_Source__c = 'Dell Nurturing', //v1.0                    
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
				Partner_Campaign_Contact__c = partnerUser.Id,//v1.0
                Partner_Campaign_Contact_Email__c = 'test@dell.com',//v1.0
                IsActive = true,
				RecordTypeId = campChannelRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
         insert campChannelObj;		
       
         Test.startTest();
         Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Sales_ready_Lead__c = TRUE,
				LeadSource = 'Employee Referral',
                Lead_Type__c = 'Inbound',
                Company = 'Test Company');
        insert leadObj;
              
        Relationship_Lead__c rlObj = new Relationship_Lead__c(
            Contact__c = newCont.Id,
            Lead_ID_Do_Not_Edit__c = leadObj.Id,
            Campaign_ID_LinkTracker__c = campDirectObj.Id,
            Campaign__c = campChannelObj.Id,
            Supporting_Information__c = 'Sample Supporting Info',
            Solution_ID__c = '1234',
            Sales_Comments__c= 'Sample Sales Comments',
            Questions_Comments__c= 'Sample Questions Comments',
            Purchase_Timeframe__c = 'Immediately',
            Purchase_Influence_Over__c= 'Sample Purchase',
            Next_Steps__c= 'Sample next Steps',
            Marketing_Comments__c= 'Sample Marketing Comments',
            Industry_Vertical_Need__c = 'Sample Industry',
            IT_Process_Simplification__c = 'Sample IT Simplification',
            End_user_Productivity__c = 'Sample End User',
            Employee__c = '1 - 99',
            Dell_can_contact_me_in_the_future__c = 'Yes',
            Dell_Existing_Customer__c = 'Yes',
            Decision_Making_Role__c = 'Influencer',
            Data_Center_Optimization__c = 'Sample Data Center'
            );
        insert rlObj;
        TriggerExecutionController.setSkipAllTriggers(false);//v4.0
        PageReference pref = new PageReference('/apex/CMAP_RouteToChannel?rlId='+rlObj.Id);
        Test.setCurrentPage(pref);
        CMAP_LeadRoutingController leadRoutingCntrlr = new CMAP_LeadRoutingController(new ApexPages.StandardController(new Relationship_Lead__c()));
        
        leadRoutingCntrlr.redirect();
        Test.stopTest(); 
                                         
    }
    static testMethod void routeToChannelwithConsentTrue() {
        TriggerExecutionController.setSkipAllTriggers(true);//v4.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v1.0
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
		//Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v4.0
		Id leadRTId= IdLookupUtils.getRecordTypeId('DSG Partner','Lead',true);//v4.0
        Account newAcc = new Account(name='MyTestAccount3');
        insert newAcc;
                
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567', 
                 Status__c = 'Marketing Suspect',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        
        //v2.0
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
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE, 
                    Enable_Partner_Lead_Management__c = TRUE, 
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    ContactId = newCont.id
                );
        insert partnerUser;
        
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                //RecordTypeId = campRTId, //v4.0
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'campaign_CMAP@yahoo.com', //v2.0
                RecordTypeId='012A0000000VnHF', //v3.0 - added since its required field                               
                Partner_Campaign_Contact__c = partnerUser.Id );//v2.0
        insert campDirectObj;
         Test.startTest();
        Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                //Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Sales_ready_Lead__c = TRUE,
                Purchase_Timeframe__c ='Immediate',
				LeadSource = 'Employee Referral',
                Lead_Type__c = 'Inbound',
                Country = 'US', //v4.0
                Company = 'Test Company');
        insert leadObj;
        
        Relationship_Lead__c rlObj = new Relationship_Lead__c(
            
            Contact__c = newCont.Id,
            Lead_ID_Do_Not_Edit__c = leadObj.Id,
            Campaign_ID_LinkTracker__c = campDirectObj.Id,
            Campaign__c = campDirectObj.Id,
            Consent_to_engage_Dell_Channel_Partner__c  = TRUE,
            Supporting_Information__c = 'Sample Supporting Info',
            Solution_ID__c = '1234',
            Sales_Comments__c= 'Sample Sales Comments',
            Questions_Comments__c= 'Sample Questions Comments',
            Purchase_Timeframe__c = 'Immediately',
            Purchase_Influence_Over__c= 'Sample Purchase',
            Next_Steps__c= 'Sample next Steps',
            Marketing_Comments__c= 'Sample Marketing Comments',
            Industry_Vertical_Need__c = 'Sample Industry',
            IT_Process_Simplification__c = 'Sample IT Simplification',
            End_user_Productivity__c = 'Sample End User',
            Employee__c = '1 - 99',
            Dell_can_contact_me_in_the_future__c = 'Yes',
            Dell_Existing_Customer__c = 'Yes',
            Decision_Making_Role__c = 'Influencer',
            Data_Center_Optimization__c = 'Sample Data Center'
            );
        insert rlObj;
        TriggerExecutionController.setSkipAllTriggers(false);//v4.0
        PageReference pref = new PageReference('/apex/CMAP_RouteToChannel?rlId='+rlObj.Id);
        Test.setCurrentPage(pref);
        CMAP_LeadRoutingController leadRoutingCntrlr = new CMAP_LeadRoutingController(new ApexPages.StandardController(new Relationship_Lead__c()));
       
            leadRoutingCntrlr.redirect();
            leadRoutingCntrlr.cancelButton();
        
        Test.stopTest(); 
        
    }

    static testMethod void CommentsPLInChannels() {
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        //Id leadDirRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v1.0
		Id leadDirRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        Id CampRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        
        Account newAcc = new Account(name='MyTestAccount3');
        insert newAcc;
                
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id, 
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;

        
        Campaign CMAP_Channel_camp= new Campaign(Name='TestCampaign_CL',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
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
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
				RecordTypeId = CampRTId,//v2.0
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
                Sales_ready_Lead__c = TRUE,
                Purchase_Timeframe__c ='Immediate',
				LeadSource = 'Employee Referral',
                Lead_Type__c = 'Inbound',
                Company = 'Test Company');
         insert SegleadObj;
         Test.startTest();
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
                //Segment_Lead__c = SegleadObj.Id, v3.0 commented
                Country ='US',
                //Relationship_lead__c = rlObj.Id,
                Dell_can_contact_me_in_the_future__c='Yes',
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                Campaign__c  =  CMAP_Channel_camp.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');
        
        insert CLleadObj ;
        Test.stopTest(); 
        Id newId;
        PageReference pref = new PageReference('/apex/CMAP_RouteToChannel?newId ='+CLleadObj.Id+'&retURL = '+CLleadObj.Id);
        Test.setCurrentPage(pref);
        system.debug('---ffff---'+pref);
        CMAP_LeadRoutingController leadDRoutingCntrlr = new CMAP_LeadRoutingController(new ApexPages.StandardController(new Lead()));
        leadDRoutingCntrlr.clRecord = CLleadObj;
        leadDRoutingCntrlr.newId= CLleadObj.Id;
        
        //leadDirRoutingCntrlr.redirect();
        leadDRoutingCntrlr.saveButton();
        //leadDirRoutingCntrlr.cancelButton();
        
   }
}