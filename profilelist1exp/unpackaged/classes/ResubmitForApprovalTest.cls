@isTest
public class ResubmitForApprovalTest
{
  static testMethod void testResubmit()
  {
      
       TriggerExecutionController.setSkipAccountTriggers(true);
       TriggerExecutionController.setSkipOpportunityTriggers(true);
       TriggerExecutionController.setSkipUserTriggers(true);
       TriggerExecutionController.setSkipAlltriggers(true);

        account acc1= new account();
        acc1.name='test1';
        insert acc1;
        
        opportunity opp= new opportunity();
        opp.name='test';
        opp.accountId=acc1.id;
        opp.closedate=date.today() + 10;
        opp.StageName='Plan - 1%';
        opp.ForecastCategoryName='Omitted';
        opp.Forecast_Category_Override__c='Omitted';
        opp.Probability=0.01;
        opp.Amount=5;
        opp.VisitOps__MainCompetitors__c='test';
        opp.Competitor_Lost_To__c = 'Acando';
        opp.Primary_Competitor_Product_Type__c = 'Client';
        opp.Name = 'Changed Opp Name';
        opp.Primary_Competitor__c = 'Unknown';       
        opp.EMC_Opportunity_Number__c = 'OP-0001';
        insert opp;
        ResubmitForApproval resub = new ResubmitForApproval();
        ResubmitForApproval.callApproval(opp.id);
       
       System.assertEquals(opp.name, 'Changed Opp Name');
  }
}