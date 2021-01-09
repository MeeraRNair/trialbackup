/*
* REVISION HISTORY
* ================

* Revision#        Author      Date        Release#        CR#     Description
* ---------        ------      ----        --------        ---     -----------
* 1.0              Fenny       1-Oct-2015  CSM1102         12015   Create OEM Communication Plan records when click on [Add] button on Communication Plan related list on OEM Requirement page
*/
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest(SeeAllData=false)
private class OEMCommunicationPlanCntrlTest{
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true); 
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        OEM_Requirement__c req1 = new OEM_Requirement__c(Opportunity__c=listOppTdf[0].Id);
        insert req1;
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
    private static testmethod void testContructor(){
        TriggerExecutionController.setSkipAllTriggers(true);
        /*  Account acc = new Account(Name='testAccount');
insert acc;
Opportunity opp = new Opportunity(Name='testOppty',
AccountId=acc.Id,
StageName='Plan - 1%', 
CloseDate=Date.today().addMonths(1));
insert opp;
OEM_Requirement__c req = new OEM_Requirement__c(Opportunity__c=opp.Id);
insert req;
*/
        OEM_Requirement__c req=[select id from OEM_Requirement__c Limit 1]; 
        OEM_Communication_Plan__c plan = new OEM_Communication_Plan__c(OEM_Requirement__c=req.Id, Type__c='Test Type');
        insert plan;
        TriggerExecutionController.setSkipAllTriggers(false);
        PageReference pr = new PageReference('/apex/OEMCommunicationPlan?retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        OEMCommunicationPlanCntrl controller = new OEMCommunicationPlanCntrl(new ApexPages.StandardController(new OEM_Communication_Plan__c()));
        system.assert(controller.comPlan.Type__c == null);
        system.assert(!controller.getHasError());
        
        pr = new PageReference('/apex/OEMCommunicationPlan');
        Test.setCurrentPage(pr);
        
        controller = new OEMCommunicationPlanCntrl(new ApexPages.StandardController(new OEM_Communication_Plan__c()));
        system.assert(controller.getHasError());
        
        pr = new PageReference('/apex/OEMCommunicationPlan?retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        
        controller = new OEMCommunicationPlanCntrl(new ApexPages.StandardController(plan));
        system.assert(controller.comPlan.Type__c == 'Test Type');
    }
    
    private static testmethod void testSave(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        /* Account acc = new Account(Name='testAccount');
insert acc;
Opportunity opp = new Opportunity(Name='testOppty',
AccountId=acc.Id,
StageName='Plan - 1%',
CloseDate=Date.today().addMonths(1));
insert opp;
OEM_Requirement__c req = new OEM_Requirement__c(Opportunity__c=opp.Id);
insert req;
*/
        OEM_Requirement__c req=[select id from OEM_Requirement__c Limit 1]; 
        OEM_Communication_Plan__c plan = new OEM_Communication_Plan__c(OEM_Requirement__c=req.Id, Type__c='Test Type');
        insert plan;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        PageReference pr = new PageReference('/apex/OEMCommunicationPlan?retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        
        Test.startTest();
        
        OEMCommunicationPlanCntrl controller = new OEMCommunicationPlanCntrl(new ApexPages.StandardController(new OEM_Communication_Plan__c()));
        controller.comPlan.Type__c = 'inserting comPlan';
        system.assert(controller.save().getUrl() == '/'+req.Id);
        OEM_Communication_Plan__c insertedPlan = [SELECT Type__c FROM OEM_Communication_Plan__c WHERE Id = :controller.comPlan.Id];
        system.assert(insertedPlan.Type__c == 'inserting comPlan');
        
        pr = new PageReference('/apex/OEMCommunicationPlan?Id='+plan.Id+'&retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        
        controller = new OEMCommunicationPlanCntrl(new ApexPages.StandardController(plan));
        system.assert(controller.comPlan.Type__c == 'Test Type');
        controller.comPlan.Type__c = 'updating comPlan';
        controller.save();
        OEM_Communication_Plan__c updatedPlan = [SELECT Type__c FROM OEM_Communication_Plan__c WHERE Id = :plan.Id];
        system.assert(updatedPlan.Type__c == 'updating comPlan');
        
        Test.stopTest();
    }
    
    private static testmethod void testCancel(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        /* Account acc = new Account(Name='testAccount');
insert acc;
Opportunity opp = new Opportunity(Name='testOppty', 
AccountId=acc.Id,
StageName='Plan - 1%',
CloseDate=Date.today().addMonths(1));
insert opp;
OEM_Requirement__c req = new OEM_Requirement__c(Opportunity__c=opp.Id);
insert req;
*/
        OEM_Requirement__c req=[select id from OEM_Requirement__c Limit 1]; 
        TriggerExecutionController.setSkipAllTriggers(false);
        
        PageReference pr = new PageReference('/apex/OEMCommunicationPlan?retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        OEMCommunicationPlanCntrl controller = new OEMCommunicationPlanCntrl(new ApexPages.StandardController(new OEM_Communication_Plan__c()));
        system.assert(controller.cancel().getUrl() == '/'+req.Id);
    }
}