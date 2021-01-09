/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@ISTEST
public class OppEditRedirectController_Test{
    @testSetup static void setup() { 
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
        listOppTdf[0].Probability = 10;
        listOppTdf[0].Amount = 1000;
        listOppTdf[0].Competitor_Lost_To__c='Unknown';
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
    static testMethod void oppEditRedirectControllerTest() {
        /*  Account testAccount = new Account(Name='Test');
Insert testAccount;

Opportunity opp = New Opportunity(Name= 'Test Opp',AccountId = testAccount.Id, 
Probability = 10,
Amount = 1000,
StageName='Discover - 10%',CloseDate = Date.TODAY());
Insert opp;                      
*/
        test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOpp=[select id,StageName,Competitor_Lost_To__c from Opportunity Limit 1];
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(listOpp[0]);
        OppEditRedirectController oppR = New OppEditRedirectController(sc);
        oppR.redirectToVF();
        
        listOpp[0].StageName='Propose - 60%';
        listOpp[0].Primary_Competitor_Product_Type__c='Client';
        update listOpp;
        ApexPages.StandardController sc1 = new ApexPages.StandardController(listOpp[0]);
        OppEditRedirectController oppR1 = New OppEditRedirectController(sc);
        oppR1.redirectToVF();
        
        listOpp[0].StageName='Plan - 1%';
        update listOpp;
        ApexPages.StandardController sc2 = new ApexPages.StandardController(listOpp[0]);
        OppEditRedirectController oppR2 = New OppEditRedirectController(sc);
        oppR2.redirectToVF();
        
        listOpp[0].StageName='Qualify - 30%';
        update listOpp;
        ApexPages.StandardController sc3 = new ApexPages.StandardController(listOpp[0]);
        OppEditRedirectController oppR3 = New OppEditRedirectController(sc);
        oppR3.redirectToVF();
        
        listOpp[0].StageName='Commit - 90%';
        update listOpp;
        ApexPages.StandardController sc4 = new ApexPages.StandardController(listOpp[0]);
        OppEditRedirectController oppR4= New OppEditRedirectController(sc);
        oppR4.redirectToVF();
        system.assertNotEquals(listOpp[0].id, null);
        TriggerExecutionController.setSkipAllTriggers(false);
        test.stopTest();
    }
}