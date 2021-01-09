/* 
Author: Manju Thomas
History:
Version    	Date           	Modified By     Description     
1.0        	13-Feb-2014    	Manju Thomas    Test class for Batch_CMAPChannelLead
2.0			15-March-2016	Azwanti			replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
*/
@isTest(SeeAllData=true)
private class Batch_CMAPChannelLeadTest {
    static testMethod void Batch_CMAPChannelLeadTest1() {
    	Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
    	Id CampRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
    	Id leadcleansingRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete', 'Lead', true);
    	Lead leadObj1;
    	Campaign CMAP_Channel_camp;
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User AdminUser = new User(FirstName='Channel Lead Batch', 
                                  LastName='Test Admin', 
                                  Title='CEO', 
                                  UserName='CMAP_ChannelLeadTestAdmin@test.com',
                                  Email='CMAP_ChannelLeadTestAdmin@dell.com', Alias='cmapcla', 
                                  CommunityNickName='cmapgcla', ProfileId = AdminProfile.Id,
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  EmailEncodingKey='UTF-8', 
                                  TimeZoneSidKey='Asia/Kuala_Lumpur',
                                  Badge_Number__c='cmapgcla');
        insert AdminUser;
        
        CMAP_Channel_camp= new Campaign(Name='TestCampaign_CL',
        		Vertical__c='PTG',
        		status='In Progress',
        		StartDate=system.today(),EndDate=system.today(),
        		Segment_Business_Unit__c='CSB',
        		Campaign_Objective__c='Action',
        		Region__c='ABU',
        		Business_Unit__c = 'CSB - Direct',
        		Parent_Vehicle__c='Digital',
        		Campaign_Vehicle__c='Search',
        		Sub_Region__c='ABU',
        		Follow_Up_Role__c='Inside Sales Rep',
        		Line_Of_Business__c='Desktop',
        		Partner_Event_or_Campaign__c = false,
        		Solution__c='Application Services',
        		Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                Description='Test',
        		IsActive = false,
                RecordTypeId = CampRTId);
        insert  CMAP_Channel_camp;
        leadObj1 = new Lead(lastName = 'Test Lead',
            email ='testcmap@cmaptest.com',
            status = 'Open - Channel Lead',
            Phone='88967544',
            RecordTypeId = leadRTId,
            Country = 'US',
            Campaign__c  = CMAP_Channel_camp.Id,
            Company = 'Test Company',
            Ready_For_Scoring__c = true,
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');
        insert leadObj1; 
        System.runAs(AdminUser){
            Test.startTest();
            Batch_CMAPChannelLead batchObj = new Batch_CMAPChannelLead();
            if(Test.isRunningTest()){
     			batchObj.query = 'SELECT l.Campaign__r.IsActive, l.Campaign__r.Status, l.Campaign__c, l.Status  '+
							 		'FROM Lead l '+
							 		'WHERE l.RecordTypeId = \''+leadcleansingRTId+'\' ' +
							 		'AND(l.Campaign__r.IsActive = false AND l.Status = \'Qualified - Channel Ready\') limit 200' ;
            }else{
            	batchObj.query = 'SELECT l.Campaign__r.IsActive, l.Campaign__r.Status, l.Campaign__c, l.Status  '+
							 		'FROM Lead l '+
							 		'WHERE l.RecordTypeId = \''+leadcleansingRTId+'\' ' +
							 		'AND(l.Campaign__r.IsActive = false AND l.Status = \'Qualified - Channel Ready\')' ;
            }
            Id batchprocessid = database.executebatch(batchObj,200);
            /*Campaign c = [select Id, Name, isActive from Campaign where Id =: CMAP_Channel_camp.Id];
            c.isActive=true;
            update c;
            Batch_CMAPChannelLead batchObj1 = new Batch_CMAPChannelLead();
     		batchObj1.query = 'SELECT l.Campaign__r.IsActive, l.Campaign__r.Status, l.Campaign__c, l.Status  '+
							 'FROM Lead l '+
							 'WHERE l.RecordTypeId = \''+leadcleansingRTId+'\' ' +
							 'AND(l.Campaign__r.IsActive = true AND l.Status = \'Inactive\') ' ;
        	Id batchprocessid1 = database.executebatch(batchObj1,200);*/
            Test.stopTest();
           
        }
    }
    
    static testMethod void Batch_CMAPChannelLeadScheduler() {
        Test.startTest();
        String CRON_EXP = '0 0 0 * * ?';
        Batch_CMAPChannelLeadScheduler sch = new Batch_CMAPChannelLeadScheduler();
        String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId limit 200];
        //Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        System.abortJob(jobId);
        Test.stopTest();
        
    }
}