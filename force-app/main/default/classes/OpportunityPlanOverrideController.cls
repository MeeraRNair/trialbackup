/***********************************************************
* Name          : OpportunityPlanOverrideController
* Description   : Controller class for OpportunityPlanEditOverride and OpportunityPlanViewOverride Page
* ---------------------------------------------------------
* Revision      Release     Name            Date            Description
* 1.0           13.1        Raymond Yip     18.11.2011      CR6884
*
*
************************************************************/
public class OpportunityPlanOverrideController {
	

    private Opportunity_Plan__c targetOpptyPlan;
    private Id opptyPlanId;

    public integer IssueMaxIndex {get; set;}
    public integer DecisionMaxIndex  {get; set;}
    public integer PeopleInvolvedMaxIndex {get; set;}
    public integer CompetitiveConsiderationMaxIndex {get; set;}

    Map<String, String> params = new Map<String, String>();

    public OpportunityPlanOverrideController(ApexPages.StandardController controller) {
        params = ApexPages.currentPage().getParameters();

        targetOpptyPlan= (Opportunity_Plan__c)controller.getRecord();

        resetFieldSetIndexes();


    }


    public PageReference showMoreIssuesFieldSet() {

        IssueMaxIndex  += 1;
    system.debug('###DEBUG### ' + IssueMaxIndex  );
        return null;
    }

    public PageReference showMoreDecisionFieldSet() {
        DecisionMaxIndex  += 1;

        return null;
    }

    public PageReference showMorePeopleInvolvedFieldSet() {
        PeopleInvolvedMaxIndex  += 1;

        return null;
    }

    public PageReference showMoreCompetitiveConsiderationFieldSet() {
        CompetitiveConsiderationMaxIndex += 1;

        return null;
    }

    public void resetFieldSetIndexes() {
        if(targetOpptyPlan.Id == null) {
            IssueMaxIndex = 1;
            DecisionMaxIndex   = 1;
            PeopleInvolvedMaxIndex  = 1;
            CompetitiveConsiderationMaxIndex = 1;
        } else {
            List<Opportunity_Plan__c> opptyPlanFieldsetList ;

            opptyPlanFieldsetList = [SELECT
                                Customer_Problem_1__c,
                                Customer_Problem_2__c,
                                Customer_Problem_3__c,
                                Customer_Problem_4__c,
                                Customer_Problem_5__c,
                                Customer_Problem_6__c,
                                Customer_Problem_7__c,
                                Customer_Problem_8__c,
                                Customer_Problem_9__c,
                                Customer_Problem_10__c,
                                Problem_Evidence_1__c,
                                Problem_Evidence_2__c,
                                Problem_Evidence_3__c,
                                Problem_Evidence_4__c,
                                Problem_Evidence_5__c,
                                Problem_Evidence_6__c,
                                Problem_Evidence_7__c,
                                Problem_Evidence_8__c,
                                Problem_Evidence_9__c,
                                Problem_Evidence_10__c,
                                Problem_Impact_1__c,
                                Problem_Impact_2__c,
                                Problem_Impact_3__c,
                                Problem_Impact_4__c,
                                Problem_Impact_5__c,
                                Problem_Impact_6__c,
                                Problem_Impact_7__c,
                                Problem_Impact_8__c,
                                Problem_Impact_9__c,
                                Problem_Impact_10__c,
                                Quantifiable_Benefit_1__c,
                                Quantifiable_Benefit_2__c,
                                Quantifiable_Benefit_3__c,
                                Quantifiable_Benefit_4__c,
                                Quantifiable_Benefit_5__c,
                                Quantifiable_Benefit_6__c,
                                Quantifiable_Benefit_7__c,
                                Quantifiable_Benefit_8__c,
                                Quantifiable_Benefit_9__c,
                                Quantifiable_Benefit_10__c,
                                Decision_Step_1__c,
                                Decision_Step_2__c,
                                Decision_Step_3__c,
                                Decision_Step_4__c,
                                Decision_Step_5__c,
                                Decision_Step_6__c,
                                Decision_Step_7__c,
                                Decision_Step_8__c,
                                Decision_Step_9__c,
                                Decision_Step_10__c,
                                When_1__c,
                                When_2__c,
                                When_3__c,
                                When_4__c,
                                When_5__c,
                                When_6__c,
                                When_7__c,
                                When_8__c,
                                When_9__c,
                                When_10__c,
                                Who_is_involved_1__c,
                                Who_is_involved_2__c,
                                Who_is_involved_3__c,
                                Who_is_involved_4__c,
                                Who_is_involved_5__c,
                                Who_is_involved_6__c,
                                Who_is_involved_7__c,
                                Who_is_involved_8__c,
                                Who_is_involved_9__c,
                                Who_is_involved_10__c,
                                Criteria_for_deciding_1__c,
                                Criteria_for_deciding_2__c,
                                Criteria_for_deciding_3__c,
                                Criteria_for_deciding_4__c,
                                Criteria_for_deciding_5__c,
                                Criteria_for_deciding_6__c,
                                Criteria_for_deciding_7__c,
                                Criteria_for_deciding_8__c,
                                Criteria_for_deciding_9__c,
                                Criteria_for_deciding_10__c,
                                Actual_Decision_1__c,
                                Actual_Decision_2__c,
                                Actual_Decision_3__c,
                                Actual_Decision_4__c,
                                Actual_Decision_5__c,
                                Actual_Decision_6__c,
                                Actual_Decision_7__c,
                                Actual_Decision_8__c,
                                Actual_Decision_9__c,
                                Actual_Decision_10__c ,
                                Person_1__c,
                                Person_2__c,
                                Person_3__c,
                                Person_4__c,
                                Person_5__c,
                                Person_6__c,
                                Person_7__c,
                                Person_8__c,
                                Person_9__c,
                                Person_10__c,
                                Onboard_Person_1__c,
                                Onboard_Person_2__c,
                                Onboard_Person_3__c,
                                Onboard_Person_4__c,
                                Onboard_Person_5__c,
                                Onboard_Person_6__c,
                                Onboard_Person_7__c,
                                Onboard_Person_8__c,
                                Onboard_Person_9__c,
                                Onboard_Person_10__c,
                                Primary_Competitor_A__c,
                                Competitor_A_Strength_1__c,
                                Competitor_A_Strength_2__c,
                                Strength_3_a__c,
                                Competitor_A_Weakness_1__c,
                                Competitor_A_Weakness_2__c,
                                Competitor_A_Weakness_3__c,
                                Primary_Competitor_B__c,
                                Competitor_B_Strength_1__c,
                                Competitor_B_Strength_2__c,
                                Strength_3_b__c,
                                Competitor_B_Weakness_1__c,
                                Competitor_B_Weakness_2__c,
                                Competitor_B_Weakness_3__c
                            FROM Opportunity_Plan__c
                            WHERE Id = :targetOpptyPlan.Id];

            if(opptyPlanFieldsetList.size() > 0) {
                //set yellow light
                if(targetOpptyPlan.Customer_Problem_10__c != null || targetOpptyPlan.Problem_Evidence_10__c != null || targetOpptyPlan.Problem_Impact_10__c  != null || targetOpptyPlan.Quantifiable_Benefit_10__c != null) {
                    IssueMaxIndex = 10;
                } else if(targetOpptyPlan.Customer_Problem_9__c != null || targetOpptyPlan.Problem_Evidence_9__c != null || targetOpptyPlan.Problem_Impact_9__c != null || targetOpptyPlan.Quantifiable_Benefit_9__c != null) {
                    IssueMaxIndex = 9;
                } else if(targetOpptyPlan.Customer_Problem_8__c != null || targetOpptyPlan.Problem_Evidence_8__c != null || targetOpptyPlan.Problem_Impact_8__c != null || targetOpptyPlan.Quantifiable_Benefit_8__c != null) {
                    IssueMaxIndex = 8;
                } else if(targetOpptyPlan.Customer_Problem_7__c != null || targetOpptyPlan.Problem_Evidence_7__c != null || targetOpptyPlan.Problem_Impact_7__c != null || targetOpptyPlan.Quantifiable_Benefit_7__c != null) {
                    IssueMaxIndex = 7;
                } else if(targetOpptyPlan.Customer_Problem_6__c != null || targetOpptyPlan.Problem_Evidence_6__c != null || targetOpptyPlan.Problem_Impact_6__c != null || targetOpptyPlan.Quantifiable_Benefit_6__c != null) {
                    IssueMaxIndex = 6;
                } else if(targetOpptyPlan.Customer_Problem_5__c != null || targetOpptyPlan.Problem_Evidence_5__c != null || targetOpptyPlan.Problem_Impact_5__c != null || targetOpptyPlan.Quantifiable_Benefit_5__c != null) {
                    IssueMaxIndex = 5;
                } else if(targetOpptyPlan.Customer_Problem_4__c != null || targetOpptyPlan.Problem_Evidence_4__c != null || targetOpptyPlan.Problem_Impact_4__c != null || targetOpptyPlan.Quantifiable_Benefit_4__c != null) {
                    IssueMaxIndex = 4;
                } else if(targetOpptyPlan.Customer_Problem_3__c != null || targetOpptyPlan.Problem_Evidence_3__c != null || targetOpptyPlan.Problem_Impact_3__c != null || targetOpptyPlan.Quantifiable_Benefit_3__c != null) {
                    IssueMaxIndex = 3;
                } else if(targetOpptyPlan.Customer_Problem_2__c != null || targetOpptyPlan.Problem_Evidence_2__c != null || targetOpptyPlan.Problem_Impact_2__c != null || targetOpptyPlan.Quantifiable_Benefit_2__c != null) {
                    IssueMaxIndex = 2;
                } else {
                    IssueMaxIndex = 1;
                }

                //set key belief
               if(targetOpptyPlan.Decision_Step_10__c != null || targetOpptyPlan.When_10__c != null || targetOpptyPlan.Who_is_involved_10__c != null ||  targetOpptyPlan.Criteria_for_deciding_10__c != null ||  targetOpptyPlan.Actual_Decision_10__c != null) {
                   DecisionMaxIndex = 10;
               } else if(targetOpptyPlan.Decision_Step_9__c != null || targetOpptyPlan.When_9__c != null || targetOpptyPlan.Who_is_involved_9__c != null ||  targetOpptyPlan.Criteria_for_deciding_9__c != null ||  targetOpptyPlan.Actual_Decision_9__c != null) {
                   DecisionMaxIndex = 9;
               } else if(targetOpptyPlan.Decision_Step_8__c != null || targetOpptyPlan.When_8__c != null || targetOpptyPlan.Who_is_involved_8__c != null ||  targetOpptyPlan.Criteria_for_deciding_8__c != null ||  targetOpptyPlan.Actual_Decision_8__c != null) {
                   DecisionMaxIndex = 8;
               } else if(targetOpptyPlan.Decision_Step_7__c != null || targetOpptyPlan.When_7__c != null || targetOpptyPlan.Who_is_involved_7__c != null ||  targetOpptyPlan.Criteria_for_deciding_7__c != null ||  targetOpptyPlan.Actual_Decision_7__c != null) {
                   DecisionMaxIndex = 7;
               } else if(targetOpptyPlan.Decision_Step_6__c != null || targetOpptyPlan.When_6__c != null || targetOpptyPlan.Who_is_involved_6__c != null ||  targetOpptyPlan.Criteria_for_deciding_6__c != null ||  targetOpptyPlan.Actual_Decision_6__c != null) {
                   DecisionMaxIndex = 6;
               } else if(targetOpptyPlan.Decision_Step_5__c != null || targetOpptyPlan.When_5__c != null || targetOpptyPlan.Who_is_involved_5__c != null ||  targetOpptyPlan.Criteria_for_deciding_5__c != null ||  targetOpptyPlan.Actual_Decision_5__c != null) {
                   DecisionMaxIndex = 5;
               } else if(targetOpptyPlan.Decision_Step_4__c != null || targetOpptyPlan.When_4__c != null || targetOpptyPlan.Who_is_involved_4__c != null ||  targetOpptyPlan.Criteria_for_deciding_4__c != null ||  targetOpptyPlan.Actual_Decision_4__c != null) {
                   DecisionMaxIndex = 4;
               } else if(targetOpptyPlan.Decision_Step_3__c != null || targetOpptyPlan.When_3__c != null || targetOpptyPlan.Who_is_involved_3__c != null ||  targetOpptyPlan.Criteria_for_deciding_3__c != null ||  targetOpptyPlan.Actual_Decision_3__c != null) {
                   DecisionMaxIndex = 3;
               } else if(targetOpptyPlan.Decision_Step_2__c != null || targetOpptyPlan.When_2__c != null || targetOpptyPlan.Who_is_involved_2__c != null ||  targetOpptyPlan.Criteria_for_deciding_2__c != null ||  targetOpptyPlan.Actual_Decision_2__c != null) {
                   DecisionMaxIndex = 2;
               } else {
                   DecisionMaxIndex = 1;
               }

               //set question max key
               if(targetOpptyPlan.Person_10__c != null || targetOpptyPlan.Onboard_Person_10__c != null) {
                   PeopleInvolvedMaxIndex = 10;
               } else if(targetOpptyPlan.Person_9__c != null || targetOpptyPlan.Onboard_Person_9__c != null) {
                   PeopleInvolvedMaxIndex = 9;
               } else if(targetOpptyPlan.Person_8__c != null || targetOpptyPlan.Onboard_Person_8__c != null) {
                   PeopleInvolvedMaxIndex = 8;
               } else if(targetOpptyPlan.Person_7__c != null || targetOpptyPlan.Onboard_Person_7__c != null) {
                   PeopleInvolvedMaxIndex = 7;
               } else if(targetOpptyPlan.Person_6__c != null || targetOpptyPlan.Onboard_Person_6__c != null) {
                   PeopleInvolvedMaxIndex = 6;
               } else if(targetOpptyPlan.Person_5__c != null || targetOpptyPlan.Onboard_Person_5__c != null) {
                   PeopleInvolvedMaxIndex = 5;
               } else if(targetOpptyPlan.Person_4__c != null || targetOpptyPlan.Onboard_Person_4__c != null) {
                   PeopleInvolvedMaxIndex = 4;
               } else if(targetOpptyPlan.Person_3__c != null || targetOpptyPlan.Onboard_Person_3__c != null) {
                   PeopleInvolvedMaxIndex = 3;
               } else if(targetOpptyPlan.Person_2__c != null || targetOpptyPlan.Onboard_Person_2__c != null) {
                   PeopleInvolvedMaxIndex = 2;
               } else {
                   PeopleInvolvedMaxIndex = 1;
               }
            }

            if(targetOpptyPlan.Primary_Competitor_B__c!= null || targetOpptyPlan.Strength_3_b__c != null || targetOpptyPlan.Competitor_B_Weakness_3__c != null || targetOpptyPlan.Competitor_b_Strength_2__c != null || targetOpptyPlan.Competitor_b_Weakness_2__c != null || targetOpptyPlan.Competitor_b_Strength_1__c != null || targetOpptyPlan.Competitor_b_Weakness_1__c != null) {
                   CompetitiveConsiderationMaxIndex = 3;
            } else if(targetOpptyPlan.Primary_Competitor_A__c!= null || targetOpptyPlan.Strength_3_a__c != null || targetOpptyPlan.Competitor_a_Weakness_3__c != null || targetOpptyPlan.Competitor_a_Strength_2__c != null || targetOpptyPlan.Competitor_a_Weakness_2__c != null || targetOpptyPlan.Competitor_a_Strength_1__c != null || targetOpptyPlan.Competitor_a_Weakness_1__c != null) {
                    CompetitiveConsiderationMaxIndex = 2;
            } else {
                   CompetitiveConsiderationMaxIndex = 1;
            }

        }
    }


}