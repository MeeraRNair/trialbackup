/*
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      13668       FY17-DCS-0103   02-Nov-2016     Fenny           Update Opportunity Plan roll up summary in Opportunity by invoke a flow
*/

public class OpportunityPlanUtilities{
    public static boolean isTest = false;
    
    // 1.0: Call this method to invoke the flow that update Opportunity Plan Rollup Summary in Opportunity. 
    // 1.0: To add new rull up summary field(s), no changes would be here, instead, changes might be done to the flow Opportunity_Plan_Roll_Up_To_Opportunity_Flow
    public static void updateRollUpSummaryInOpportunity(Map<Id, SObject> mapOldOpportunityPlans, Map<Id, SObject> mapNewOpportunityPlans){
        // 1.0:
        if((mapOldOpportunityPlans != null) && (mapOldOpportunityPlans.size() > 0)){
            Map<string, object> mapOpportunityId = null;
            Flow.Interview.Opportunity_Plan_Roll_Up_To_Opportunity_Flow flowRUSOpportunity = null;
            
            if (!Test.isrunningTest() || isTest){
                TriggerExecutionController.setSkipAccountTriggers(true);
                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }

            for(SObject sObj : mapOldOpportunityPlans.values()){
                Opportunity_Plan__c plan = (Opportunity_Plan__c)sObj;
                
                mapOpportunityId = new Map<string, object>();
                mapOpportunityId.put('strOpportunityId', plan.Opportunity__c);
                
                flowRUSOpportunity = new Flow.Interview.Opportunity_Plan_Roll_Up_To_Opportunity_Flow(mapOpportunityId);
                flowRUSOpportunity.start();
            }

            if (!Test.isrunningTest()){
                TriggerExecutionController.setSkipAccountTriggers(false);
                TriggerExecutionController.setSkipOpportunityTriggers(false);
            }
        }
    }
}