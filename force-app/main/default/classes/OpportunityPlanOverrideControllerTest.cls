/***********************************************************
* Name          : OpportunityPlanOverrideController Test
* Description   : Test Class for OpportunityPlanOverrideController
* ---------------------------------------------------------
* Revision      Release     Name            Date            Description
* 1.0           13.1        Raymond Yip     08.11.2011      CR6884
* 1.1           5/12/       Noraiman        1/12/2015       CR12361 - Adding lines of codes to fix test class SOQL error
*
************************************************************/
@isTest
private class OpportunityPlanOverrideControllerTest {
     static list<Account> listAcc;
    static list<Opportunity> listOpp;
    
     @testSetup static void setup(){
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
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
               insert listAccTdf;
          list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(3, 'Standard Opportunity');
         listOppTdf[0].AccountId=listAccTdf[0].id;
               insert listOppTdf;
        
    }
   
     static testMethod void testResetFieldSetIndexes() {
        //Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');
        //insert testAccount;
        
        
        //Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', AccountId=testAccount.Id, StageName='10%',CloseDate = System.Today() + 30 );
        //insert testOppty;
    listOpp=[select id from Opportunity Limit 1];
        Opportunity_Plan__c testOpptyPlan = new Opportunity_Plan__c(Name='testOpportunityPlanRedirectPage Oppty Plan ', Opportunity__c = listOpp[0].Id);

        OpportunityPlanOverrideController controller = new OpportunityPlanOverrideController(new ApexPages.StandardController(testOpptyPlan));

        controller.resetFieldSetIndexes();
    system.assertNotEquals(listOpp[0].id, null);
        
    }
/*
     static testMethod void testOpportunityPlanAddMoreFields() {


    test.startTest();
                TriggerExecutionController.setSkipAllTriggers(true);

       // Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');
        //insert testAccount;

        //Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', AccountId=testAccount.Id, StageName='10%',CloseDate = System.Today() + 30 );
        //insert testOppty;
    listOpp=[select id from Opportunity Limit 1];
//listOpp[0].StageName='10%';
  //      update listOpp;
        Opportunity_Plan__c testOpptyPlan = new Opportunity_Plan__c(Name='testOpportunityPlanRedirectPage Oppty Plan ', Opportunity__c = listOpp[0].Id);

        insert testOpptyPlan;
    


        OpportunityPlanOverrideController controller = new OpportunityPlanOverrideController(new ApexPages.StandardController(testOpptyPlan));
        Test.setCurrentPage(Page.OpportunityPlanEditOverride);

        System.assertEquals(controller.IssueMaxIndex,1);
        System.assertEquals(controller.DecisionMaxIndex,1);
        System.assertEquals(controller.PeopleInvolvedMaxIndex,1);
        System.assertEquals(controller.CompetitiveConsiderationMaxIndex,1);

        controller.showMoreIssuesFieldSet();
        System.assertEquals(controller.IssueMaxIndex,2);


        controller.showMoreDecisionFieldSet();
        controller.showMoreDecisionFieldSet();
        System.assertEquals(controller.DecisionMaxIndex,3);


        controller.showMorePeopleInvolvedFieldSet();
        System.assertEquals(controller.PeopleInvolvedMaxIndex,2);

        controller.showMoreCompetitiveConsiderationFieldSet();
        controller.showMoreCompetitiveConsiderationFieldSet();
        controller.showMoreCompetitiveConsiderationFieldSet();
        controller.showMoreCompetitiveConsiderationFieldSet();
        controller.showMoreCompetitiveConsiderationFieldSet();
        System.assertEquals(controller.CompetitiveConsiderationMaxIndex,6);
        test.stopTest();

    }
*/

    static testMethod void testResetFieldSets() {
    
        //skip all triggers during data creation
    TriggerExecutionController.setSkipAllTriggers(true);

        //Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');
        //insert testAccount;

        //Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', AccountId=testAccount.Id, StageName='10%',CloseDate = System.Today() + 30 );
        //insert testOppty;

        //Opportunity testOppty2 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty2', AccountId=testAccount.Id, StageName='10%',CloseDate = System.Today() + 30 );
        //insert testOppty2;
        test.startTest();
listOpp=[Select id from Opportunity Limit 3];
       // for(Opportunity opp : listOpp){
         //   opp.StageName='10%';
        //}
        listOpp[0].StageName='10%';
        
        update listOpp;
        Opportunity_Plan__c testOpptyPlan = new Opportunity_Plan__c(Name='testOpportunityPlanRedirectPage Oppty Plan ', Opportunity__c = listOpp[0].Id);

        insert testOpptyPlan;
    
    //activate back trigger
    //TriggerExecutionController.setSkipAllTriggers(false);   
   // OpportunityPlanOverrideController controller3= new OpportunityPlanOverrideController(new ApexPages.StandardController(testOpptyPlan));

     //   controller3.resetFieldSetIndexes();

        OpportunityPlanOverrideController controller2 = new OpportunityPlanOverrideController(new ApexPages.StandardController(testOpptyPlan));
        Test.setCurrentPage(Page.OpportunityPlanEditOverride);

        System.assertEquals(controller2.IssueMaxIndex,1);
        System.assertEquals(controller2.DecisionMaxIndex,1);
        System.assertEquals(controller2.PeopleInvolvedMaxIndex,1);
        System.assertEquals(controller2.CompetitiveConsiderationMaxIndex,1);

        controller2.showMoreIssuesFieldSet();
        System.assertEquals(controller2.IssueMaxIndex,2);


        controller2.showMoreDecisionFieldSet();
        controller2.showMoreDecisionFieldSet();
        System.assertEquals(controller2.DecisionMaxIndex,3);


        controller2.showMorePeopleInvolvedFieldSet();
        System.assertEquals(controller2.PeopleInvolvedMaxIndex,2);

        controller2.showMoreCompetitiveConsiderationFieldSet();
        controller2.showMoreCompetitiveConsiderationFieldSet();
        controller2.showMoreCompetitiveConsiderationFieldSet();
        controller2.showMoreCompetitiveConsiderationFieldSet();
        controller2.showMoreCompetitiveConsiderationFieldSet();
        System.assertEquals(controller2.CompetitiveConsiderationMaxIndex,6);
        OpportunityPlanOverrideController controllerForNull = new OpportunityPlanOverrideController(new ApexPages.StandardController(testOpptyPlan));
        controllerForNull.resetFieldSetIndexes();

        System.assertEquals(controllerForNull.IssueMaxIndex,1);
        System.assertEquals(controllerForNull.DecisionMaxIndex,1);
        System.assertEquals(controllerForNull.PeopleInvolvedMaxIndex,1);
        System.assertEquals(controllerForNull.CompetitiveConsiderationMaxIndex,1);
        //Test.startTest();
        Opportunity_Plan__c testOpptyPlan2 = new Opportunity_Plan__c(
                        Name='testOpportunityPlanRedirectPage Oppty Plan ',
                        Opportunity__c = listOpp[1].Id,
                        Customer_Problem_10__c = 'Test',
                        Problem_Evidence_1__c = 'Test',
                        Criteria_for_deciding_9__c = 'Test',
                        Onboard_Person_8__c = 'Test',
                        Primary_Competitor_B__c = 'Test',
                        Competitor_B_Weakness_3__c = 'Test'
        );

        insert testOpptyPlan2;

        OpportunityPlanOverrideController controller = new OpportunityPlanOverrideController(new ApexPages.StandardController(testOpptyPlan2));

        controller.resetFieldSetIndexes();
        System.assertEquals(controller.IssueMaxIndex,10);
        System.assertEquals(controller.DecisionMaxIndex,9);
        System.assertEquals(controller.PeopleInvolvedMaxIndex,8);
        System.assertEquals(controller.CompetitiveConsiderationMaxIndex,3);

        testOpptyPlan2.Customer_Problem_10__c = null;
        testOpptyPlan2.Customer_Problem_7__c = 'Test';
        testOpptyPlan2.Criteria_for_deciding_9__c = null;
        testOpptyPlan2.Criteria_for_deciding_6__c = 'Test';
        testOpptyPlan2.Onboard_Person_8__c = null;
        testOpptyPlan2.Onboard_Person_10__c = 'Test';
        testOpptyPlan2.Primary_Competitor_B__c = null;
        testOpptyPlan2.Competitor_B_Weakness_3__c = null;

        update testOpptyPlan2;

        controller.resetFieldSetIndexes();
        System.assertEquals(controller.IssueMaxIndex,7);
        System.assertEquals(controller.DecisionMaxIndex,6);
        System.assertEquals(controller.PeopleInvolvedMaxIndex,10);
        System.assertEquals(controller.CompetitiveConsiderationMaxIndex,1);


        testOpptyPlan2.Customer_Problem_7__c = null;
        testOpptyPlan2.Customer_Problem_3__c = 'Test';
        testOpptyPlan2.Criteria_for_deciding_6__c = null;
        testOpptyPlan2.Criteria_for_deciding_2__c = 'Test';
        testOpptyPlan2.Onboard_Person_10__c = null;
        testOpptyPlan2.Onboard_Person_3__c = 'Test';
        testOpptyPlan2.Primary_Competitor_a__c = null;
        testOpptyPlan2.Competitor_a_Weakness_2__c = null;

        update testOpptyPlan2;

        controller.resetFieldSetIndexes();
        System.assertEquals(controller.IssueMaxIndex,3);
        System.assertEquals(controller.DecisionMaxIndex,2);
        System.assertEquals(controller.PeopleInvolvedMaxIndex,3);
        System.assertEquals(controller.CompetitiveConsiderationMaxIndex,1);

        //Opportunity testOppty3 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty2', AccountId=testAccount.Id, StageName='10%',CloseDate = System.Today() + 30 );
        //insert testOppty3;

        Opportunity_Plan__c testOpptyPlan3 = new Opportunity_Plan__c(
                        Name='testOpportunityPlanRedirectPage Oppty Plan 3',
                        Opportunity__c = listOpp[2].Id
        );

        insert testOpptyPlan3;
        OpportunityPlanOverrideController controller1 = new OpportunityPlanOverrideController(new ApexPages.StandardController(testOpptyPlan2));

        testOpptyPlan3.Customer_Problem_1__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_1__c = 'Test';
        testOpptyPlan3.Onboard_Person_1__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();

        testOpptyPlan3.Customer_Problem_2__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_2__c = 'Test';
        testOpptyPlan3.Onboard_Person_2__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();

        testOpptyPlan3.Customer_Problem_3__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_3__c = 'Test';
        testOpptyPlan3.Onboard_Person_3__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();

        testOpptyPlan3.Customer_Problem_4__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_4__c = 'Test';
        testOpptyPlan3.Onboard_Person_4__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();

        testOpptyPlan3.Customer_Problem_5__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_5__c = 'Test';
        testOpptyPlan3.Onboard_Person_5__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();

        testOpptyPlan3.Customer_Problem_6__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_6__c = 'Test';
        testOpptyPlan3.Onboard_Person_6__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();

        testOpptyPlan3.Customer_Problem_7__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_7__c = 'Test';
        testOpptyPlan3.Onboard_Person_7__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();

        testOpptyPlan3.Customer_Problem_8__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_8__c = 'Test';
        testOpptyPlan3.Onboard_Person_8__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();

        testOpptyPlan3.Customer_Problem_9__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_9__c = 'Test';
        testOpptyPlan3.Onboard_Person_9__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();

        testOpptyPlan3.Customer_Problem_10__c = 'Test';
        testOpptyPlan3.Criteria_for_deciding_10__c = 'Test';
        testOpptyPlan3.Onboard_Person_10__c = 'Test';

        update testOpptyPlan3;
        controller1.resetFieldSetIndexes();
       Test.stoptest();
    }
}