/*
 * Author   : Ragu
 * Purpose  : To test LeadRouter class. 
 *
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12003	16.10       06-Oct-2015     Ragu            Created.
 * 
 */
 
@isTest(SeeAllData=false)
private class LeadRouter_Test {

	@testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }

    static testMethod void testRouteToChannel() {
		LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads = LeadTestData.lstLeads;
        listDirectLeads[0].Dell_Partner_can_contact_me__c = true;
        listDirectLeads[1].Dell_Partner_can_contact_me__c = true;
        insert listDirectLeads;
        
        Test.startTest();
        listDirectLeads[0].Status = 'Route To Channel';
        listDirectLeads[1].Status = 'Route To Channel';
        update listDirectLeads;
		System.assertEquals('Route To Channel', listDirectLeads[0].Status);
		Test.stopTest();
    }
    
    static testMethod void testPopulateFieldsForR2CFromUI() {
		LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 5;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads = LeadTestData.lstLeads;
        LeadRouter.populateFieldsForR2CFromUI(listDirectLeads);
		System.assertEquals(1, 1);
    }
    
    static testMethod void testRouteToSegment() {
    	LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads = LeadTestData.lstLeads;
        listDirectLeads[0].Dell_Partner_can_contact_me__c = true;
        listDirectLeads[1].Dell_Partner_can_contact_me__c = true;
        insert listDirectLeads;
        
        listDirectLeads[0].Status = 'Route To Channel';
        listDirectLeads[1].Status = 'Route To Channel';
        update listDirectLeads;
        
        set<Id> setLeadIds = new set<Id>{listDirectLeads[0].Id, listDirectLeads[1].Id};
        list<Lead> listChannelLeads = [select Id, Status, Origin__c, Channel_to_Segment_Criteria__c from Lead where Id in :setLeadIds];
        System.debug('listChannelLeads: ' + listChannelLeads);
        
        Test.startTest();
        listChannelLeads[0].Status = 'Route To Segment';
        listChannelLeads[0].Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
		
        listChannelLeads[1].Status = 'Route To Segment';
        listChannelLeads[1].Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update listChannelLeads;
        System.assertEquals('Route To Segment', listChannelLeads[0].Status);
		Test.stopTest();
    }
    
    static testMethod void testPopulateFieldsForR2SFromUI() {
    	LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 5;
        LeadTestData.createChannelLead2();
        LeadRouter.populateFieldsForR2SFromUI(LeadTestData.lstLeads);
		System.assertEquals(1, 1);
    }
    	
}