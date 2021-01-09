/********************************************
Name   : VOOpportunityTriggerTest
Description   : test class for VOOpportunityTrigger trigger
Author   : Priyanka Challa, VisitOps

*********************************************/
@isTest
private class VOOpportunityTriggerTest {

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
    }

    private static testMethod void test() {
    TriggerExecutionController.setSkipAccountTriggers(true);
    TriggerExecutionController.setSkipOpportunityTriggers(true);
    TriggerExecutionController.setSkipUserTriggers(true);
        
     account acc= new account();
     acc.name='test';
     insert acc;
     
     account acc1= new account();
     acc1.name='test';
     insert acc1;
    
     test.startTest();
     
     opportunity opp= new opportunity();
     opp.name='test';
     opp.accountId=acc.id;
     opp.closedate=date.today();
     opp.StageName='Plan - 1%';
     opp.ForecastCategoryName='Omitted';
     opp.Forecast_Category_Override__c='Omitted';
     //opp.Probability=0.01;
     opp.Amount=5;
     opp.VisitOps__MainCompetitors__c='test';
     insert opp;
     
     VisitOps__VisitBundle__c bundle= new VisitOps__VisitBundle__c();
     bundle.VisitOps__Opportunity__c=opp.id;
     insert bundle;
     
     opp.name='test1';
     opp.accountId=acc1.id;
     opp.closedate=date.today()+1;
     opp.StageName='Plan - 1%';
     //opp.ForecastCategoryName='Omitted';
     opp.Forecast_Category_Override__c='Omitted';
     //opp.Probability=0.01;
     opp.Amount=5;
     opp.VisitOps__MainCompetitors__c='test';
     update opp;
     
     System.assertEquals(opp.StageName,'Plan - 1%');
     
     opp.name='test';
     opp.accountId=acc.id;
     opp.closedate=date.today();
     opp.StageName='Plan - 1%';
     opp.ForecastCategoryName='Omitted';
     opp.Forecast_Category_Override__c='Omitted';
     //opp.Probability=0.01;
     opp.Amount=5;
     opp.VisitOps__MainCompetitors__c='test';
     update opp;

     System.assertEquals(opp.StageName,'Plan - 1%');
     
     test.stopTest();
    }
}