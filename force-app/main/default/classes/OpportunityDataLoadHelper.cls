public class OpportunityDataLoadHelper{
    public static void execute(List<Opportunity> opportunities){
        try{
            if(opportunities != null && opportunities.size() > 0){
                for(Opportunity opp : opportunities){
                    opp.Opportunity_Plan_Roll_up_Summary_Temp__c    = opp.Opportunity_Plan_Roll_up_Summary__c;
                    opp.Scheduled_Product_Count_Temp__c             = opp.Scheduled_Product_Count__c;
                    opp.Scheduled_Service_Products_Temp__c          = opp.Scheduled_Service_Products__c;
                    opp.SOC_Qualify_Temp__c                         = opp.SOC_Qualify__c;
                    opp.Unweighted_Rev_Financing_Only_Temp__c       = opp.Unweighted_Rev_Financing_Only__c;
                    opp.Unweighted_Rev_For_Sort_Temp__c             = opp.Unweighted_Rev_For_Sort__c;
                    opp.Qualified_Vendor_Count_Temp__c              = opp.Qualified_Vendor_Count__c;
                    opp.Total_Product_Quantity_Temp__c              = opp.Total_Product_Quantity__c;
                    opp.Renewal_Extension_Total_Price_Temp__c       = opp.Renewal_Extension_Total_Price__c;
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}