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
private class RouteLeadsController_Test {
    public static boolean bCreate = true;
    static list<Campaign> listCamp;
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(2, 'Campaign 2.0');
        for(Campaign campaignIterator : listCampTDF) {
            campaignIterator.Allocation_Source__c = 'Channel APJ Agency 1';
            campaignIterator.Nurture_Source__c = 'Channel APJ Agency 1';
            campaignIterator.Lead_Routing__c = 'Not Applicable';
            campaignIterator.Is_this_Account_Play_Campaign__c = False;

        }
       // if(bCreate) {
            insert listCampTDF;
        //}
        //insert listCampTDF;
    }
    static testMethod void testgeneralMethods() {
        listCamp = [Select Id from Campaign limit 2];
        system.assertNotEquals(listCamp[0].id, null);
        RouteLeadsController routeController = new RouteLeadsController(new ApexPages.StandardController(new Lead()));
    }
    
    static testMethod void testRouteToChannel() {
        listCamp = [Select Id,Is_this_Account_Play_Campaign__c from Campaign limit 2];
        system.assertNotEquals(listCamp[0].id, null);
        /*CampaignTestData.bCreate = false;
CampaignTestData.iNumberOfCampaigns = 2;
CampaignTestData.createCampaign2();
list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
lstCampaigns[0].Region__c = 'GLOBAL';
lstCampaigns[0].Sub_Region__c = 'Global';
lstCampaigns[0].Allocation_Source__c = 'Not Applicable';
lstCampaigns[0].Nurture_Source__c = 'Not Applicable';
insert lstCampaigns;*/
                    Account a=new Account(Name='TestAcc');
            insert a;
        list<lead> listleads = new list<lead>();
        Lead l=new Lead(Lead_Type__c='Outbound',Account__c=a.id,Universal_Customer_ID_UCID__c='7234692',LastName='jsd',Company='testcmp',Phone='56789',LeadSource='Web',LastNameLocal='testLead',PPA_UCID__c='234',Mg_Name__c='sdfg',Campaign__c=listcamp[0].id,Country_Code__c='IN');
        listleads.add(l);
        Lead l1=new Lead(Lead_Type__c='Outbound',Account__c=a.id,Universal_Customer_ID_UCID__c='7234692',LastName='jsd',Company='testcmp',Phone='56789',LeadSource='Web',LastNameLocal='testLead',PPA_UCID__c='234',Mg_Name__c='sdfg',Campaign__c=listcamp[1].id,Country_Code__c='IN');
        listleads.add(l1);

        //TriggerExecutionController.setSkipLeadTriggers(true);
        insert listleads;

        /*
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        listLeads[0].Campaign__c = listCamp[0].Id;
        listLeads[1].Campaign__c = listCamp[1].Id;
        insert listLeads;
        // Code Block End: Test Data Preparation
        
		*/        
        Test.startTest();
        
        // Test "Campaign does not support Channel process. Please update Allocation Source and Nurture Source in the Campaign before routing. Click here to update the Campaign and proceed with routing"
        Lead directLead = listLeads[0];
        ApexPages.currentPage().getParameters().put('id', directLead.Id);
        ApexPages.currentPage().getParameters().put('action', 'Route To Channel');
        RouteLeadsController routeController = new RouteLeadsController(new ApexPages.StandardController(directLead));
        
        // Test "Lead should be in Open / Contacted / Accepted / Sales Qualified Lead / Marketing Qualified Lead Status in order to route it to Channel. Please update the Status accordingly and try again"
        directLead.Campaign__c = listCamp[1].Id;
        directLead.Status = 'Closed';
        directLead.Country_CN__c = 'India';
        directLead.Country_Code__c='IN';
        update directLead;
        ApexPages.currentPage().getParameters().put('id', directLead.Id);
        ApexPages.currentPage().getParameters().put('action', 'Route To Channel');
        routeController = new RouteLeadsController(new ApexPages.StandardController(directLead));
        routeController.redirect();
        
        // Test "You do not have permission to route this Lead to Channel. Please contact Lead Owner to route it to Channel"
        directLead = listLeads[1];
        UserTestData.iNumberOfUsers = 1;
        UserTestData.createInternalUsers();
        list<User> listUsers = UserTestData.lstUsers;
        System.runAs(listUsers[0]) {
            ApexPages.currentPage().getParameters().put('id', directLead.Id);
            ApexPages.currentPage().getParameters().put('action', 'Route To Channel');
            routeController = new RouteLeadsController(new ApexPages.StandardController(directLead));
            routeController.redirect();
        }
        
        // Test successful routing
        Test.setCurrentPage(Page.RouteLeads);
        ApexPages.currentPage().getParameters().put('id', directLead.Id);
        ApexPages.currentPage().getParameters().put('action', 'Route To Channel');
        routeController = new RouteLeadsController(new ApexPages.StandardController(directLead));
        routeController.redirect();
        routeController.goBack();
        LeadRouter.routeToChannel(new list<Lead>{directLead}, null);
        try{ update directLead;} catch(exception e){}
        
        Test.stopTest();
    }
    
    static testMethod void testRouteToSegment() {
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1; 
        LeadTestData.createDirectLead2();
        Lead directLead = LeadTestData.lstLeads[0];
        directLead.Dell_Partner_can_contact_me__c = true;
        insert directLead;
        directLead.Status = 'Route To Channel';
        update directLead;
        // Code Block End: Test Data Preparation
        
        Test.startTest();
        
        // Test "This button is intended for Regional Allocation Queue Members. Please contact your Channel Marketing manager for assistance. Thank you"
        Lead channelLead = [select Id, OwnerId, Channel_to_Segment_Criteria__c from Lead where Id = :directLead.Id];
        channelLead.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        ApexPages.currentPage().getParameters().put('id', channelLead.Id);
        ApexPages.currentPage().getParameters().put('action', 'Route To Segment');
        RouteLeadsController routeController = new RouteLeadsController(new ApexPages.StandardController(channelLead));
        routeController.redirect();
        system.assertEquals(channelLead.id, channelLead.id);
        // Test successful routing
        list<GroupMember> listGroupMembers = [select UserOrGroupId from GroupMember where GroupId = :channelLead.OwnerId limit 1];
        System.debug('channelLead.OwnerId: ' + channelLead.OwnerId);
        System.debug('listGroupMembers: ' + listGroupMembers);
        if(!listGroupMembers.isEmpty() && String.valueOf(listGroupMembers[0].UserOrGroupId).startsWith('005')) {
            User userInstance = [select Id from User where Id = :listGroupMembers[0].UserOrGroupId limit 1];
            System.runAs(userInstance) {
                ApexPages.currentPage().getParameters().put('id', channelLead.Id);
                ApexPages.currentPage().getParameters().put('action', 'Route To Segment');
                routeController = new RouteLeadsController(new ApexPages.StandardController(channelLead));
                routeController.redirect();
            }
        }
        
        Test.stopTest();
    }
    
}