/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest(SeeAllData=false)
Private Class CountOfOpportunitiesLogic_Test {
    
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
        listOppTdf[0].Fiscal_Year__c = '2020';
        listOppTdf[0].Probability = 1;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void testOpportunity() {
        TriggerExecutionController.setSkipAllTriggers(true);
        OpportunityTriggerForNoOfOppLogicAI ai=new OpportunityTriggerForNoOfOppLogicAI();
        OpportunityTriggerForNoOfOppLogicAU au=new OpportunityTriggerForNoOfOppLogicAu();
        OpportunityTriggerForNoOfOppLogicAD ad=new OpportunityTriggerForNoOfOppLogicAD();
        /* Account acc = new Account(name = 'Test Account');
insert acc;
Opportunity opp=new Opportunity (name='teset opp SR', 
StageName='Plan - 1%',
Fiscal_Year__c = '2020',
Probability = 1, 
AccountId = acc.id,
CloseDate=System.Today());
insert opp;
*/
        list<Account> listAcc=[select id from Account Limit 1];
        list<Opportunity> listOpp=[select id,Fiscal_Year__c,AccountId from Opportunity Limit 1];
        TriggerExecutionController.setSkipAccountTriggers(false);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);        
        Opportunity oppo = [select Fiscal_Year__c, AccountId from Opportunity where Fiscal_Year__c='2020' AND AccountId = :listOpp[0].AccountId];
        Account accnt = [select id, No_of_Opportunities__c from Account where id = :oppo.AccountId];
        listAcc[0].No_of_Opportunities__c = '0';
        List<Opportunity> listOpp1 = [select Fiscal_Year__c, AccountId from Opportunity where Fiscal_Year__c='2020' AND AccountId = :listOpp[0].AccountId];
        Map<ID, Opportunity> mapOpp = new Map<ID, Opportunity>();
        mapOpp.put(oppo.id,oppo);
        CountOfOpportunitiesLogic.noOfOpp(listOpp1);
        au.handleAfterUpdate(listOpp1,mapOpp);
        ai.handleAFterInsert(listOpp1);
        ad.handleAfterDelete(listOpp1); 
        if(Oppo.Fiscal_Year__c != null){
            integer intOppCount = [select Count() from Opportunity where Fiscal_Year__c='2020' AND AccountId = :listOpp[0].AccountId];
            listAcc[0].No_of_Opportunities__c = String.valueOf(intOppCount);
            update listAcc[0];
        }
        System.assertEquals('1', listAcc[0].No_of_Opportunities__c);
        TriggerExecutionController.setSkipAccountTriggers(false);   
        Test.StopTest();
    }
}