/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13668       FY17-DCS-0103   01-Nov-2016     Fenny           Update roll up summary in Opportunity when deleting OpportunityLineItem  
2.0         CR15166     FY18-0203   26-Nov-2017     Krishnakumar    Display Forecasted Units and Quote Numbers in myDeal
3.0         CR17974		FY20-DCE-1002	30-Aug-2019		Shubham B	updated the updateRollUpSummaryInOpportunity(Adding checks to bypass the FLOW for APOS opportunities)
4.0         CR18399     FY21-DCE-0202   14-Dec-2019     Shubham B       relaced the RenewalOpportunity_Utils with RenewalsConstants so that any package classes can be deployed independetly with the help of RenewalsConstants as it presents in Base package
*/   
public class OpportunityLineItemDeleteUtilities{
    
    public static boolean isTest = false; 
    
    // 1.0: Call this method to invoke the flow that update OpportunityLineItem Rollup Summary in Opportunity. 
    // 1.0: To add new rull up summary field(s), no changes would be here, instead, changes might be done to the flow Opportunity_Product_Roll_Up_To_Opportunity_Flow
    // 1.1: CR17974		FY20-DCE-1002	30-Aug-2019		Shubham B	updated the updateRollUpSummaryInOpportunity(Adding checks to bypass the FLOW for APOS opportunities)
    public static void updateRollUpSummaryInOpportunity(Map<Id, SObject> mapOldOpportunityLineItems, Map<Id, SObject> mapNewOpportunity){
        // 1.0:
        if((mapOldOpportunityLineItems != null) && (mapOldOpportunityLineItems.size() > 0)){
            system.debug('>>>>>>>>>> OpportunityLineItemDeleteUtilities | mapOldOpportunityLineItems.size() ' + mapOldOpportunityLineItems.size());
            
            Map<string, object> mapOpportunityId = null;
            //Flow.Interview.Opportunity_Product_Roll_Up_To_Opportunity_Flow flowRUSOpportunity = null;
            Flow.Interview.Opportunity_Product_Line_Item_Quantity_Quote_Roll_Up_To_Opportunity flowQuanQuotOpportunity = null; // 2.0 changes
            if (!Test.isrunningTest() || isTest){
                TriggerExecutionController.setSkipAccountTriggers(true);
                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }
            /*******START**Shubham B*************to avoid calling FLOW for apos opportunities**********************************************/
           
            map<id,opportunity> mapRenewalOptyId = new map<id,opportunity>();
            for(opportunity opp : (list<opportunity>)mapNewOpportunity.values()){
                
                If ((opp.recordtypeid == RenewalsConstants.aposRecordTypeId) && (opp.Source_System__c == RenewalsConstants.strsourceSystemEMCCore || opp.Source_System__c == RenewalsConstants.strsourceSystemRenewalsEBIA ||opp.type == RenewalsConstants.strtypeEMCRenewalsDirect || opp.type == RenewalsConstants.strtypeEMCRenewalsInDirect)){
                    if(!mapRenewalOptyId.containsKey(opp.Id)){
                        mapRenewalOptyId.put(opp.id,opp);
                    }              
                }
            }   
            
            /*******STOP**Shubham B*************to avoid calling FLOW for apos opportunities**********************************************/
            
            for(SObject sObj : mapOldOpportunityLineItems.values()){ 
                OpportunityLineItem item = (OpportunityLineItem)sObj;

                mapOpportunityId = new Map<string, object>();
                mapOpportunityId.put('strOpportunityId', item.OpportunityId);
                mapOpportunityId.put('varOpportunityId', item.OpportunityId);  
                
                
                //flowRUSOpportunity = new Flow.Interview.Opportunity_Product_Roll_Up_To_Opportunity_Flow(mapOpportunityId);
                //flowRUSOpportunity.start();
                
                if(!mapRenewalOptyId.containsKey(item.opportunityid)){ //to avoid calling FLOW for apos opportunities
                    
                    flowQuanQuotOpportunity = new Flow.Interview.Opportunity_Product_Line_Item_Quantity_Quote_Roll_Up_To_Opportunity(mapOpportunityId); // 2.0 changes
                    flowQuanQuotOpportunity.start();
                }
                
            } 
            
            if (!Test.isrunningTest()){
                TriggerExecutionController.setSkipAccountTriggers(false);
                TriggerExecutionController.setSkipOpportunityTriggers(false);
            }
        }
    }
}