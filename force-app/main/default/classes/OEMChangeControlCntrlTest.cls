/*
* REVISION HISTORY
* ================

* Revision#        Author      Date        Release#        CR#     Description
* ---------        ------      ----        --------        ---     -----------
* 1.0              Gan         7-Oct-2015  CSM1102         12034   Create OEM Change Control records when click on [Add] button on Change Control related list on OEM Requirement page
* 2.0              venu        09-12-2019  0202                    Implimented TestDataFactory    
*/

@isTest(SeeAllData=false)
private class OEMChangeControlCntrlTest{
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
        OEM_Change_Control__c changeControl = new OEM_Change_Control__c(OEM_Requirement__c=req1.Id, Revision__c='Test Rev');
        insert changeControl;
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
        OEM_Change_Control__c changeControl = [select id,Revision__c from OEM_Change_Control__c Limit 1];
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        PageReference pr = new PageReference('/apex/OEMChangeControl?retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        
        OEMChangeControlCntrl controller = new OEMChangeControlCntrl(new ApexPages.StandardController(new OEM_Change_Control__c()));
        system.assert(controller.changeControl.Revision__c == null);
        system.assert(!controller.getHasError());
        
        pr = new PageReference('/apex/OEMChangeControl');
        Test.setCurrentPage(pr);
        
        controller = new OEMChangeControlCntrl(new ApexPages.StandardController(new OEM_Change_Control__c()));
        system.assert(controller.getHasError());
        
        pr = new PageReference('/apex/OEMChangeControl?retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        
        controller = new OEMChangeControlCntrl(new ApexPages.StandardController(changeControl));
        system.assert(controller.changeControl.Revision__c == 'Test Rev');
    }
    
    private static testmethod void testSave(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        /*Account acc = new Account(Name='testAccount');
insert acc;
Opportunity opp = new Opportunity(Name='testOppty', AccountId=acc.Id, StageName='Plan - 1%', CloseDate=Date.today().addMonths(1));
insert opp;
OEM_Requirement__c req = new OEM_Requirement__c(Opportunity__c=opp.Id);
insert req;
*/         OEM_Requirement__c req=[select id from OEM_Requirement__c Limit 1]; 
        
        //OEM_Change_Control__c changeControl = new OEM_Change_Control__c(OEM_Requirement__c=req.Id, Revision__c='Test Rev');
        //insert changeControl;
        OEM_Change_Control__c changeControl = [select id,Revision__c from OEM_Change_Control__c Limit 1];
        TriggerExecutionController.setSkipAllTriggers(false);
        
        PageReference pr = new PageReference('/apex/OEMChangeControl?retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        
        Test.startTest();
        
        OEMChangeControlCntrl controller = new OEMChangeControlCntrl(new ApexPages.StandardController(new OEM_Change_Control__c()));
        controller.changeControl.Revision__c = 'ins cc';
        system.assert(controller.save().getUrl() == '/'+req.Id);
        OEM_Change_Control__c insertedChangeControl = [SELECT Revision__c FROM OEM_Change_Control__c WHERE Id = :controller.changeControl.Id];
        system.assert(insertedChangeControl.Revision__c == 'ins cc');
        
        pr = new PageReference('/apex/OEMChangeControl?Id='+changeControl.Id+'&retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        
        controller = new OEMChangeControlCntrl(new ApexPages.StandardController(changeControl));
        system.assert(controller.changeControl.Revision__c == 'Test Rev');
        controller.changeControl.Revision__c = 'upd cc';
        controller.save();
        OEM_Change_Control__c updatedChangeControl = [SELECT Revision__c FROM OEM_Change_Control__c WHERE Id = :changeControl.Id];
        system.assert(updatedChangeControl.Revision__c == 'upd cc');
        
        Test.stopTest();
    }
    
    private static testmethod void testCancel(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        /* Account acc = new Account(Name='testAccount');
insert acc;
Opportunity opp = new Opportunity(Name='testOppty', AccountId=acc.Id, StageName='Plan - 1%', CloseDate=Date.today().addMonths(1));
insert opp;
OEM_Requirement__c req = new OEM_Requirement__c(Opportunity__c=opp.Id);
insert req;
*/
        OEM_Requirement__c req=[select id from OEM_Requirement__c Limit 1]; 
        TriggerExecutionController.setSkipAllTriggers(false);
        
        PageReference pr = new PageReference('/apex/OEMChangeControl?retURL=/'+req.Id);
        Test.setCurrentPage(pr);
        OEMChangeControlCntrl controller = new OEMChangeControlCntrl(new ApexPages.StandardController(new OEM_Change_Control__c()));
        system.assert(controller.cancel().getUrl() == '/'+req.Id);
    }
}