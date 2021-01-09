/* 
* Test Class logic related to LinkedPartnerTracksControllerTest
* Revision CR Number   Release No        Date            Modified By               Description
* -------- ---------   ----------     -----------       ------------               -----------
*                                  26-Sep-2018      Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
Public Class EngageChannelParnterTest{
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert oWDsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccfromFactory;
        
        List<Opportunity> listOppFromFactory=TestDataFactory.CreateNOpportunities(2, 'Channel Opportunity');
        insert listOppFromFactory;
    }   
    
    Static TestMethod void engagePartnerApproved(){
        TriggerExecutionController.setSkipAllTriggers(true);
        boolean bdisplayPopup = true;
        test.startTest();
        Account acc = new Account();
        acc.Name = 'TestAccount';
        insert acc;
        listOpp=[SELECT id from Opportunity Limit 1];
        listOpp[0].AccountId=acc.id;
        update listOpp;
        
        Test.StopTest();
        PageReference myVfPage = Page.EngageChannelParnterApproval;
        Test.setCurrentPageReference(myVfPage); // use setCurrentPageReference, 
        
        ApexPages.currentPage().getParameters().put('Id',listOpp[0].Id);
        String strid = ApexPages.currentPage().getParameters().get('Id');
        system.assertEquals(true,strid!=null);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listOpp[0]);
        EngageChannelParnterApproval ac = new EngageChannelParnterApproval(sc);
        ac.showpopup();
        ac.SaveOpp();
        ac.cancelOppAction();
        ac.addDealAccess();    
        try {
            
        } catch (Exception ex) {
            
            System.assert(ex.getMessage().contains('expected message'), 'message=' + ex.getMessage());
        }
    }
    static testmethod void engagePartnerRejection(){
        test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        Account acc = new Account();
        acc.Name = 'TestAccount';
        insert acc;
        listOpp=[SELECT id from Opportunity];
        for(Opportunity opp : listOpp){
            opp.AccountId = acc.Id;
            opp.Primary_competitor__c = 'Absolute';
            opp.Partner_Competitor_Lost_To__c = 'parnter';
            opp.Competitor_Lost_To__c ='3i-Infotech';
            opp.Region__c = 'All';
        }
        listOpp[1].Associated_Opportunity__c = listOpp[0].Id;
        update listOpp;
        
        Test.StopTest();
        PageReference myVfPage = Page.EngageChannelRejectionVF;
        Test.setCurrentPageReference(myVfPage);  
        ApexPages.currentPage().getParameters().put('Id',listOpp[0].Id);
        String strid1 = ApexPages.currentPage().getParameters().get('Id');
        system.assertEquals(true,strid1!=null);
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(listOpp[0]);
        EngageChannelParnterRejection ac1 = new EngageChannelParnterRejection(sc1);
        ac1.SaveOpp();
        
        ApexPages.currentPage().getParameters().put('Id',listOpp[1].Id);
        String strid = ApexPages.currentPage().getParameters().get('Id');
        system.assertEquals(true,strid!=null);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listOpp[1]);
        EngageChannelParnterRejection ac = new EngageChannelParnterRejection(sc);
        ac.strdata='test';
        ac.SaveOpp();
        
    }
}