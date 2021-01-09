/*
 * Revision Ref Number  Release No  	Date            Modified By     Description
 * -------- ----------  ----------  	-----------     ------------    -----------
 * 1.0      			14.10       	01-Oct-2013     Annie            Test class for CMAP_LeadShareCntrlr.
 * 2.0					FY17-DCS-0401	15-March-2016 	Azwanti			12720 - replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
 */
 
@isTest(SeeAllData = true)
private class CMAP_LeadShareCntrlr_Test {

	static testMethod void testShare_StandardUser() {
		Id channelCampRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); //v2.0
		Id leadSubmissionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');

		list<Profile> lstProfiles = [select Id, Name from Profile where Name like '%GBL Channel Marketing%' order by CreatedDate desc limit 1];
		
		User userInstance = new User(Username = 'mkttest@dll.com',
							Alias = 'test1',
							Email = 'test3445@dell.com',
							FirstName = 'John',
							LastName = 'Doe',
							ProfileId = lstProfiles[0].Id,
							LanguageLocaleKey = 'en_US',
							LocaleSidKey = 'en_US',
							EmailEncodingKey = 'UTF-8',
							TimeZoneSidKey = 'America/Los_Angeles',
							Badge_Number__c = 'UATUser',
							IsActive = true);
		insert userInstance;
		
		Campaign channelCampaign = new Campaign(Name = 'TestCampaign_CL',
													Campaign_Objective__c = 'Acquisition/Site Development',
													Type = 'Advisory Councils', Segment_Business_Unit__c = 'SMB',
													Region__c = 'ABU',
													Follow_Up_Role__c = 'Account Executive',
													Description = 'Test', StartDate = system.today(), EndDate = system.today(),
													Status = 'In Progress',
													Country_Code__c = 'BR - Brazil',
													Partner_Event_or_Campaign__c = False,
													Allocation_Source__c = 'Dell Allocation ABU',
													Nurture_Source__c = 'Dell Nurturing',
													IsActive = true,
													RecordTypeId = channelCampRTId,
													Total_Campaign_Targets_Planned__c = 1,
													Total_Value_Won_Opportunities_Planned__c = 1,
													Total_Value_Opportunities_Planned__c = 1);
		insert channelCampaign;

		Lead leadRecs = new Lead();
		leadRecs.lastName = 'Test Lead';
		leadRecs.firstName = 'Share';
		leadRecs.Salutation = 'Mr.';
		leadRecs.status = 'Open - Channel Lead';
		leadRecs.Phone = '88967544';
		leadRecs.RecordTypeId = leadSubmissionRTId;
		leadRecs.Country = 'US';
		leadRecs.Campaign__c = channelCampaign.Id;
		leadRecs.Company = 'Test Company';
		leadRecs.Purchase_Timeframe__c = '3 months';
		leadRecs.Budget__c = 'Yes';
		leadRecs.Ready_For_Scoring__C = TRUE;
		insert leadRecs;
		
		
		Test.startTest();
		
		PageReference pr = new PageReference('/apex/CMAP_LeadShare?Id=' + leadRecs.Id);
		Test.setCurrentPage(pr);
		
		CMAP_LeadShareCntrlr controller = new CMAP_LeadShareCntrlr(new ApexPages.StandardController(leadRecs));
		controller.leadRecord = leadRecs;
		controller.leadId = leadRecs.Id;
		leadRecs.User__c = userInstance.Id;
		controller.save();
		controller.Redirect();
		controller.Cancel();
		
		Test.stopTest();
	}
	
	static testMethod void testShare_PartnerUser() {
		Id channelCampRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); //v2.0
		Id leadSubmissionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');
		Id accRTId = StaticFactory.getRecordTypeIdByName('Account', 'Partner Account');


		Account accountObj;
		accountObj = new Account(name = 'Test', RecordtypeId = accRTId);
		insert accountObj;

		Contact cont = new Contact(FirstName = 'TestContact1',
			LastName = 'TestContactlast1',
			accountId = accountObj.Id,
			Email = 'test@ust-global.com',
			fax = '01987645',
			MobilePhone = '0000019',
			Decision_Making_Role__c = 'Evaluator',
			Job_Function__c = 'IT',
			Job_Function_Role__c = 'Director IT',
			//Last_Operation_Performed__c = 'testing',
			Phone = '0000000');
		insert cont;

		list<Profile> partnerProfiles = [select id, name from Profile where UserType = 'PowerPartner' and name like '%PRM Portal User%' order by CreatedDate DESC limit 1];

		User partnerUser = new User(
			Username = 'testPartnerUser@dll.com',
			Alias = 'test1',
			Email = 'test3445@dell.com',
			FirstName = 'John',
			LastName = 'Doe',
			ProfileId = partnerProfiles[0].Id,
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			TimeZoneSidKey = 'America/Los_Angeles',
			Badge_Number__c = '101010',
			isActive = TRUE,
			//AccountId = accountObj.Id,
			ContactId = cont.id);
		insert partnerUser;

		Campaign channelCampaign = new Campaign(Name = 'TestCampaign_CL',
			Campaign_Objective__c = 'Acquisition/Site Development',
			Type = 'Advisory Councils', Segment_Business_Unit__c = 'SMB',
			Region__c = 'ABU',
			Follow_Up_Role__c = 'Account Executive',
			Description = 'Test', StartDate = system.today(), EndDate = system.today(),
			status = 'In Progress',
			Country_Code__c = 'BR - Brazil',
			Partner_Event_or_Campaign__c = False,
			Allocation_Source__c = 'Dell Allocation ABU',
			Nurture_Source__c = 'Dell Nurturing',
			IsActive = true,
			RecordTypeId = channelCampRTId,
			Total_Campaign_Targets_Planned__c = 1,
			Total_Value_Won_Opportunities_Planned__c = 1,
			Total_Value_Opportunities_Planned__c = 1);
		insert channelCampaign;

		Lead leadRecs = new Lead();
		leadRecs.lastName = 'Test Lead';
		leadRecs.firstName = 'Share';
		leadRecs.Salutation = 'Mr.';
		leadRecs.status = 'Open - Channel Lead';
		leadRecs.Phone = '88967544';
		leadRecs.RecordTypeId = leadSubmissionRTId;
		leadRecs.Country = 'US';
		leadRecs.Campaign__c = channelCampaign.Id;
		leadRecs.Company = 'Test Company';
		leadRecs.Purchase_Timeframe__c = '3 months';
		leadRecs.Budget__c = 'Yes';
		leadRecs.Ready_For_Scoring__C = TRUE;
		insert leadRecs;

		try {
			Test.startTest();
			PageReference pr = new PageReference('/apex/CMAP_LeadShare?Id=' + leadRecs.Id);
			Test.setCurrentPage(pr);
	
			CMAP_LeadShareCntrlr controller = new CMAP_LeadShareCntrlr(new ApexPages.StandardController(new Lead()));
			controller.leadRecord = leadRecs;
			controller.leadId = leadRecs.Id;
			leadRecs.User__c = partnerUser.Id;
			controller.save();
			controller.Cancel();
			Test.stopTest();
		}
		catch (Exception e) {
			e.getmessage();     
		}
	}
	
	static testMethod void testShare_QueueUser() {
		Id channelCampRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); //v2.0
		Id leadSubmissionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');

		list<Profile> lstProfiles = [select Id, Name from Profile where Name like '%GBL Channel Marketing%' order by CreatedDate desc limit 1];

		User userInstance = new User(Username = 'mkttest@dll.com',
							Alias = 'test1',
							Email = 'test3445@dell.com',
							FirstName = 'John',
							LastName = 'Doe',
							ProfileId = lstProfiles[0].Id,
							LanguageLocaleKey = 'en_US',
							LocaleSidKey = 'en_US',
							EmailEncodingKey = 'UTF-8',
							TimeZoneSidKey = 'America/Los_Angeles',
							Badge_Number__c = 'USerUAT11',
							IsActive = true);
		insert userInstance;

		Campaign channelCampaign = new Campaign(Name = 'TestCampaign_CL',
												Campaign_Objective__c = 'Acquisition/Site Development',
												Type = 'Advisory Councils', 
												Segment_Business_Unit__c = 'SMB',
												Region__c = 'APJ',
												Follow_Up_Role__c = 'Account Executive',
												Description = 'Test', 
												StartDate = system.today(), 
												EndDate = system.today(),
												status = 'In Progress',
												Country_Code__c = 'BR - Brazil',
												Partner_Event_or_Campaign__c = False,
												Allocation_Source__c = 'Channel APJ Agency 1',
												Nurture_Source__c = 'Dell Nurturing',
												IsActive = true,
												RecordTypeId = channelCampRTId,
												Total_Campaign_Targets_Planned__c = 1,
												Total_Value_Won_Opportunities_Planned__c = 1,
												Total_Value_Opportunities_Planned__c = 1);
		insert channelCampaign;

		String queueName = 'APJ:Channel APJ Agency 1:A';
		CMAP_Queue_Settings__c QueueId = CMAP_Queue_Settings__c.getValues(queueName);
		
		Lead leadRecs = new Lead();
		leadRecs.lastName = 'Test Lead';
		leadRecs.firstName = 'Share';
		leadRecs.Salutation = 'Mr.';
		leadRecs.status = 'Open - Channel Lead';
		leadRecs.Phone = '88967544';
		leadRecs.RecordTypeId = leadSubmissionRTId;
		leadRecs.Country = 'US';
		leadRecs.Campaign__c = channelCampaign.Id;
		leadRecs.Company = 'Test Company';
		leadRecs.Purchase_Timeframe__c = '3 months';
		leadRecs.Budget__c = 'Yes';
		if(QueueId != NULL) {
			leadRecs.OwnerId = QueueId.Queue_Id__c;
		}
		leadRecs.Ready_For_Scoring__c = true;
		System.runAs(userInstance) {
			insert leadRecs;
		}

		
		Test.startTest();
		PageReference pr = new PageReference('/apex/CMAP_LeadShare?Id=' + leadRecs.Id);
		Test.setCurrentPage(pr);

		CMAP_LeadShareCntrlr controller = new CMAP_LeadShareCntrlr(new ApexPages.StandardController(new Lead()));

		controller.leadRecord = leadRecs;
		controller.leadId = leadRecs.Id;
		leadRecs.User__c = userInstance.Id;

		controller.save();
		controller.Redirect();
		controller.Cancel();
		Test.stopTest();
	}
	
}