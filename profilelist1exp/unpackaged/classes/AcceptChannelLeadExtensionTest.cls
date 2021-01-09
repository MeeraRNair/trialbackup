/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
* 1.0        0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
private class AcceptChannelLeadExtensionTest {
    @testSetup static void createTestData() {
        /*  Campaign objCampaign = new Campaign(Name='Campaign_CMAP',
Follow_Up_Role__c='Account Executive',
Secondary_Role__c='Affiliates Technical Sales Rep',
Description='Test',StartDate=system.today(),EndDate=system.today(),
status='In Progress',
IsActive = true,
//MDF_Partner_ID__c='1122334477',
//MDF_Partner_ID__c=lstAccount[0].Account_ID__c,
Total_Campaign_Targets_Planned__c = 1,
Aprimo_Activity_Id__c ='12345',
Lead_Routing__c = 'Not Applicable');
insert objCampaign;

Lead objLead = new Lead(LastName = 'TestLeadLName',
Lead_Type__c = 'Inbound',
Email = 'testcmap@cmaptest.com',
Status = 'Cancelled',
Phone = '88967544',
Country = 'US',
Campaign__c = objCampaign.Id, 
Company = 'Test Company',
LeadSource='Partner',
Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)',
Country_Code__c = 'US');
*/
        list<Campaign> listCampTdf=TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        listCampTdf[0].status='In Progress';
        listCampTdf[0].IsActive = true;
        listCampTdf[0].Follow_Up_Role__c='Account Executive';
        listCampTdf[0].Secondary_Role__c='Affiliates Technical Sales Rep';
        listCampTdf[0].Description='Test';
        listCampTdf[0].StartDate=system.today();
        listCampTdf[0].EndDate=system.today();
        listCampTdf[0].Total_Campaign_Targets_Planned__c = 1;
        listCampTdf[0].Aprimo_Activity_Id__c ='12345';
        listCampTdf[0].Lead_Routing__c = 'Not Applicable';
        insert listCampTdf;
        list<Lead> listLeadTdf=TestDataFactory.createNLeads(1, 'Direct Lead 2.0');
        listLeadTdf[0].Campaign__c=listCampTdf[0].id;
        listLeadTdf[0].Status = 'Cancelled';
        listLeadTdf[0].LeadSource='Partner';
        listLeadTdf[0].Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)';
        listLeadTdf[0].LastName = 'TestLeadLName';
        listLeadTdf[0].Lead_Type__c = 'Inbound';
        listLeadTdf[0].Email = 'testcmap@cmaptest.com';
        listLeadTdf[0].Phone = '88967544';
        listLeadTdf[0].Country = 'US';
        listLeadTdf[0].Company = 'Test Company';
        listLeadTdf[0].Country_Code__c = 'US';
        TriggerExecutionController.setSkipLeadTriggers(true);
        
        insert listLeadTdf;
        
        TriggerExecutionController.setSkipLeadTriggers(false);
    }
    private static ApexPages.StandardSetController init(){
        
        String strquery= 'SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = \'TestLeadLName\'';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(strquery));
        
        return setCtrl;
    }
    
    static testMethod void acceptChannelLeadExtensionCancel(){
        test.startTest();
        list<Campaign> listCamp=[select id from Campaign Limit 1];
        system.assertNotEquals(listCamp[0].id, null);
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        AcceptChannelLeadExtension stdController = new AcceptChannelLeadExtension(controller);
        stdController.cancel();
        test.stopTest();
    }
    
    static testMethod void acceptChannelLeadExtensionYes(){
        test.startTest();
        list<Campaign> listCamp=[select id from Campaign Limit 1];
        system.assertNotEquals(listCamp[0].id, null);
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        AcceptChannelLeadExtension stdController = new AcceptChannelLeadExtension(controller);
        stdController.Yes();
        stdController.No();
        test.stopTest();
    }
    
    static testMethod void performMassLeadUpdate(){
        test.startTest();
        list<Campaign> listCamp=[select id from Campaign Limit 1];
        system.assertNotEquals(listCamp[0].id, null);
        ApexPages.StandardSetController controller = init();
        AcceptChannelLeadExtension stdController = new AcceptChannelLeadExtension(controller);
        stdController.PerformMassLeadUpdate();
        test.stopTest();
    }
    
    static testMethod void performMassLeadUpdate1(){
        test.startTest();
        list<Campaign> listCamp=[select id from Campaign Limit 1];
        system.assertNotEquals(listCamp[0].id, null);
        ApexPages.StandardSetController controller = init();
        controller.setFilterID('00BA0000004VZtx');
        list<Lead> listLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName' limit 1];
        controller.setSelected(listLeads);
        // now pass it to the extension
        AcceptChannelLeadExtension stdController = new AcceptChannelLeadExtension(controller);
        
        stdController.PerformMassLeadUpdate();
        
        test.stopTest();
    }
    
    static testMethod void performMassLeadUpdate2(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        controller.setFilterID('00BA0000004VZtx');
        list<Lead> listLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName' limit 1];
        
        // now pass it to the extension
        AcceptChannelLeadExtension stdController = new AcceptChannelLeadExtension(controller);
        
        List<User> listUser = [SELECT Id FROM User WHERE Profile.Name Like '%PRM%' AND Profile.Name Like '%Portal%' AND isActive = true limit 1];
        system.assertNotEquals(listUser[0].id, null);
        if(!listUser.isempty())
        {
            system.runAs(listUser[0])
            {
                stdController.PerformMassLeadUpdate();
                controller.setSelected(listLeads);
                stdController.PerformMassLeadUpdate();
            }
        }
        test.stopTest();
    }
    
    static testMethod void performMassLeadUpdate3(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        
        list<Lead> listLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName' limit 1] ;
        system.assertNotEquals(listLeads[0].id, null);
        controller.setFilterID('00BA0000008Taqu');
        // now pass it to the extension
        AcceptChannelLeadExtension stdController = new AcceptChannelLeadExtension(controller);
        
        List<User> listUser = [SELECT Id FROM User WHERE Profile.Name Like '%PRM%' AND Profile.Name Like '%Portal%' AND isActive = true limit 1];
        if(!listUser.isempty())
        {
            system.runAs(listUser[0])
            {
                stdController.PerformMassLeadUpdate();
            }
        }
        test.stopTest();
    }
}