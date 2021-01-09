/***********************************************************
* Name          : VFCntrl_newOppQuickCreateTest
* Description   : Test class for Opportunity Quick Crate
* ---------------------------------------------------------
* Revision  Name               Date             Description
* 1.0       Meera        04.April.2018    Story 4848231:BUCPWFY19LX-00201: Record Quick Create VF Button (Thor)
*        
* 
************************************************************/
@isTest
private class VFCntrl_newOppQuickCreateTest {
     @testSetup static void setup(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
                insert listAccTdf;
        
    }
    static testmethod void testOppSaveSuccess(){
        
        PageReference pageRef = Page.newOppQuickCreate;
        Test.setCurrentPage(pageRef);
      
        //VFCntrl_newOppQuickCreate controller = new VFCntrl_newOppQuickCreate(new List<Opportunity>());
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Opportunity>());        
        VFCntrl_newOppQuickCreate ext = new VFCntrl_newOppQuickCreate(stdSetController);
        //Account acc= new Account(name='Test quick create Account');
        list<Account> listAcc=[Select id from Account Limit 1];
        //TriggerExecutionController.setSkipAccountTriggers(true);
        //insert acc;
         Test.startTest();
         PriceBook2 pb = new PriceBook2 (name='Test pricebok',isActive=true);
         insert pb;
        insert new OWD__c(SetupOwnerId=UserInfo.getOrganizationId(), Oppty_Stage1__c='Plan - 1%');
        ext.opp.name = 'Quick Create Test';
        ext.opp.accountid = listAcc[0].id;
        ext.opp.Type = 'Deal/Bid - Direct';
        ext.opp.Domain__c = 'APOS';
        ext.opp.StageName = 'Plan - 1%';
        ext.opp.Pricebook2Id = pb.id;
        ext.opp.closedate = System.today();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        System.assertEquals(null, ext.oppid);
        ext.save();
        //System.assertNotEquals(null, ext.oppid);
        
        Test.stopTest();
    }
    
    static testmethod void testOppSaveFailure(){
        
        PageReference pageRef = Page.newOppQuickCreate;
        Test.setCurrentPage(pageRef);
      
        //VFCntrl_newOppQuickCreate controller = new VFCntrl_newOppQuickCreate(new List<Opportunity>());
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Opportunity>());        
        VFCntrl_newOppQuickCreate ext = new VFCntrl_newOppQuickCreate(stdSetController);
       // Account acc= new Account(name='Test quick create Account');
        //TriggerExecutionController.setSkipAccountTriggers(true);
        //insert acc;
        list<Account> listAcc=[Select id from Account Limit 1];
         Test.startTest();
        insert new OWD__c(SetupOwnerId=UserInfo.getOrganizationId(), Oppty_Stage1__c='Plan - 1%');
        ext.opp.name = 'Quick Create Test';
        ext.opp.accountid = listAcc[0].id;
        ext.opp.Type = 'Deal/Bid - Direct';
        ext.opp.Domain__c = 'APOS';
        ext.opp.StageName = 'Win - 100%';
        
        ext.opp.closedate = System.today();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        ext.save();
        System.assert(ApexPages.hasMessages());
        Test.stopTest();
    }
    
}