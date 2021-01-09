/*
 * Revision CR Number   Release No      Date            Modified By           Description
 * -------- ---------   ----------      -----------     ------------          -----------
 * 1.0      CR 15625    FY19-DCE-0502   19-Apr-2018     Subramani Ramamurthy  Channel Lead Status Field
 * 1.1      CR 15625    FY19-DCE-0502   07-May-2018     Kokila                DEFECT 5039288: Wunderkind :SDET: For Channel Lead partner status is not sync to lead status when lead status is Closed- worked.

 */
@isTest
public class CloseChannelLeadExtension_Test {
    public static Testmethod void TestCloseChannel(){
        
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        
        List<Lead> FinalLead=new List<Lead>();
        Lead ThisLead = new Lead();
        ThisLead.FirstName = 'testMethod';
        ThisLead.LastName = 'Test Lead';
        ThisLead.Email = '123456@test.com';
        ThisLead.Phone = '123456789';
        ThisLead.Status = 'Open';
        
        ThisLead.LeadSource = 'Web';
        ThisLead.Company = 'Dell Internal';//1.1 Start
        ThisLead.Partner_Lead_Status__c = 'Closed';  //1.1 End
        ThisLead.Lead_Type__c = 'Inbound';
        ThisLead.RecordTypeId = directLead2RTId;
        ThisLead.Campaign__c = lstCampaigns[0].Id;   
        ThisLead.Country_Code__c='MY';
        FinalLead.add(ThisLead);
        TriggerExecutionController.setSkipLeadTriggers(true);
        insert FinalLead;
        TriggerExecutionController.setSkipLeadTriggers(true);
        
        Apexpages.StandardSetController FinalController=new Apexpages.StandardSetController(FinalLead);
        CloseChannelLeadExtension UpdateLeadExtension=new CloseChannelLeadExtension(FinalController);
        UpdateLeadExtension.PerformMassLeadUpdate();
    }
    public static Testmethod void TestCloseChannelNegative(){
        
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        
        List<Lead> FinalLead=new List<Lead>();
        Lead objLead = new Lead();
        objLead.FirstName = 'testMethod';
        objLead.LastName = 'Test Lead';
        objLead.Email = '123456@test.com';
        objLead.Phone = '123456789';
        objLead.Status = 'Open';
        //1.1 Start
        objLead.Partner_Lead_Status__c = 'Closed';  //1.1 End
        objLead.LeadSource = 'Web';
        objLead.Company = 'Dell Internal';
        objLead.Lead_Type__c = 'Inbound';
        objLead.RecordTypeId = directLead2RTId;
        objLead.Campaign__c = lstCampaigns[0].Id;   
        objLead.Country_Code__c='MY';
        Test.startTest();
        FinalLead.add(objLead);
        TriggerExecutionController.setSkipLeadTriggers(true);
        insert FinalLead;
        TriggerExecutionController.setSkipLeadTriggers(true);
        
        Test.setCurrentPage(Page.Close_Channel_Lead_Page);
        ApexPages.StandardsetController stdSetController  = new ApexPages.StandardSetController(FinalLead);
        CloseChannelLeadExtension CloseLeadExtension=new CloseChannelLeadExtension(stdSetController);
        CloseLeadExtension.PerformMassLeadUpdate();
        Test.stopTest();
    }
    
    private static ApexPages.StandardSetController init(){
        String query= 'SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = \'TestLeadLName\'';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(query));
        return setCtrl;
    }
    static testMethod void PerformMassLeadUpdate(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        stdController.PerformMassLeadUpdate();
        test.stopTest();
    }
    static testMethod void PerformMassLeadUpdate1(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        controller.setFilterID('00BA0000004VZtx');
        list<Lead> lstLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName' limit 1];
        controller.setSelected(lstLeads);
        // now pass it to the extension
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        stdController.PerformMassLeadUpdate();
        test.stopTest();
    }
    static testMethod void PerformMassLeadUpdate2(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        controller.setFilterID('00BA0000004VZtx');
        list<Lead> lstLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName' limit 1];
        
        // now pass it to the extension
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        List<User> lstUser = [SELECT Id FROM User WHERE Profile.Name Like '%PRM%' AND Profile.Name Like '%Portal%' AND isActive = true limit 1];
        if(!lstUser.isempty())
        {
            system.runAs(lstUser[0])
            {
                stdController.PerformMassLeadUpdate();
                controller.setSelected(lstLeads);
                stdController.PerformMassLeadUpdate();
            }
        }
        test.stopTest();
    }
    static testMethod void PerformMassLeadUpdate3(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        list<Lead> lstLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName' limit 1] ;
        controller.setFilterID('00BA0000008Taqu');
        // now pass it to the extension
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        List<User> lstUser = [SELECT Id FROM User WHERE Profile.Name Like '%PRM%' AND Profile.Name Like '%Portal%' AND isActive = true limit 1];
        if(!lstUser.isempty())
        {
            system.runAs(lstUser[0])
            {
                stdController.PerformMassLeadUpdate();
            }
        }
        test.stopTest();
    }
    /*==================================Dummy Data=============================*/
    
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
                                Status = 'blank',
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
    private static ApexPages.StandardSetController init1(){
        String query= 'SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = \'TestLeadLName\'';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(query));
        return setCtrl;
    }
    
    static testMethod void AcceptChannelLeadExtensionCancel(){
        test.startTest();
        ApexPages.StandardSetController controller = init1();
        // now pass it to the extension
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        //  stdController.cancel();
        test.stopTest();
    }
    
    static testMethod void AcceptChannelLeadExtensionYes(){
        test.startTest();
        ApexPages.StandardSetController controller = init1();
        // now pass it to the extension
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        // stdController.Yes();
        // stdController.No();
        test.stopTest();
    }
    
    
    static testMethod void PerformMassLeadUpdate12(){
        test.startTest();
        ApexPages.StandardSetController controller = init1();
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        stdController.PerformMassLeadUpdate();
        test.stopTest();
    }
    
    static testMethod void PerformMassLeadUpdate11(){
        test.startTest();
        ApexPages.StandardSetController controller = init1();
        controller.setFilterID('00BA0000004VZtx');
        list<Lead> lstLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName' limit 1];
        controller.setSelected(lstLeads);
        // now pass it to the extension
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        stdController.PerformMassLeadUpdate();
        test.stopTest();
    }
    
    static testMethod void PerformMassLeadUpdate21(){
        test.startTest();
        ApexPages.StandardSetController controller = init1();
        controller.setFilterID('00BA0000004VZtx');
        list<Lead> lstLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName' limit 1];
        
        // now pass it to the extension
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        List<User> lstUser = [SELECT Id FROM User WHERE Profile.Name Like '%PRM%' AND Profile.Name Like '%Portal%' AND isActive = true limit 1];
        if(!lstUser.isempty())
        {
            system.runAs(lstUser[0])
            {
                stdController.PerformMassLeadUpdate();
                controller.setSelected(lstLeads);
                stdController.PerformMassLeadUpdate();
            }
        }
        test.stopTest();
    }
    
    static testMethod void PerformMassLeadUpdate31(){
        test.startTest();
        ApexPages.StandardSetController controller = init1();
        
        list<Lead> lstLeads = [SELECT id,LastName,Lead_Type__c,Status, LeadSource,Company  FROM Lead Where LastName = 'TestLeadLName' limit 1] ;
        controller.setFilterID('00BA0000008Taqu');
        // now pass it to the extension
        CloseChannelLeadExtension stdController = new CloseChannelLeadExtension(controller);
        List<User> lstUser = [SELECT Id FROM User WHERE Profile.Name Like '%PRM%' AND Profile.Name Like '%Portal%' AND isActive = true limit 1];
        if(!lstUser.isempty())
        {
            system.runAs(lstUser[0])
            {
                stdController.PerformMassLeadUpdate();
                
            }
        }
        test.stopTest();
    }
}