/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13668       FY17-DCS-0103   02-Nov-2016     Fenny           Update roll up summary in Opportunity when deleting OpportunityPlan  
*/    
@isTest
private class OpportunityPlanUtilitiesTest{
   
    static testMethod void updateRollUpSummaryInOpportunityTest(){
        
        insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
        
        ProcessFlowTriggerController.isTest = true;
        OpportunityPlanUtilities.isTest = true;
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        Test.startTest();
        
        //Account testAccount = new Account(Name='Test Account');  
        //insert testAccount;  
        //list<Account> listAcc=TestDataFactory.createNAccount(1, 'Partner Account');
        //insert listAcc;
        /*Opportunity testOppty = new Opportunity(Name='Test Oppty', AccountId=testAccount.Id, StageName='10%', CloseDate = System.Today() + 30 ); 
        insert testOppty;   
        */
        list<Opportunity> listOpp=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        insert listOpp;
        Opportunity_Plan__c plan = new Opportunity_Plan__c(Name='Test Plan', Opportunity__c=listOpp[0].Id);
        insert plan;
        
        //Opportunity opp = [SELECT Opportunity_Plan_Roll_up_Summary__c FROM Opportunity WHERE Id = :testOppty.Id];
        //system.assertEquals(1.0, opp.Opportunity_Plan_Roll_up_Summary__c);
        
        delete plan;
        Opportunity opp = [SELECT Opportunity_Plan_Roll_up_Summary__c FROM Opportunity WHERE Id = :listOpp[0].Id];
        
        system.assertEquals(0.0, opp.Opportunity_Plan_Roll_up_Summary__c);
        
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
    }

}