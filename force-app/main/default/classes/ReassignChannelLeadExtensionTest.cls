@isTest
private class ReassignChannelLeadExtensionTest {
   
    @testSetup static void createTestData() {
        
         Campaign objCampaign = new Campaign(Name='Campaign_CMAP',
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
       
        
        TriggerExecutionController.setSkipLeadTriggers(true);
        
        insert objLead;
        
        
        TriggerExecutionController.setSkipLeadTriggers(false);         
        
            
    }
    
        
    private static ApexPages.StandardSetController init(){
        
        String query= 'SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = \'TestLeadLName\'';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(query));
        
        return setCtrl;
    }
    
    static testMethod void ReassignChannelLeadExtensionCancel(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        ReassignChannelLeadExtension stdController = new ReassignChannelLeadExtension(controller);
        stdController.cancel();
        test.stopTest();
    }
    
    static testMethod void AcceptChannelLeadExtensionYes(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        ReassignChannelLeadExtension stdController = new ReassignChannelLeadExtension(controller);
        stdController.Yes();
        test.stopTest();
    }
    
    static testMethod void AcceptChannelLeadExtensionNo(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        ReassignChannelLeadExtension stdController = new ReassignChannelLeadExtension(controller);
        stdController.No();
        test.stopTest();
    }
    
    static testMethod void ReassignChannelLeadExtensionRedirect(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        ReassignChannelLeadExtension stdController = new ReassignChannelLeadExtension(controller);
        stdController.redirectPage();
        test.stopTest();
    }

    static testMethod void ReassignChannelLeadExtensionRedirect02(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        controller.setFilterID('00BA0000008Taqu');
        list<Lead> lstLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName'];
        controller.setSelected(lstLeads);
        // now pass it to the extension
        ReassignChannelLeadExtension stdController = new ReassignChannelLeadExtension(controller);
        
        stdController.redirectPage();
      
        test.stopTest();
    }
}