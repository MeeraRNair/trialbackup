/*
Author: Raymond Yip

History:
   Revision   Date      Release No      Modified By     CR Number       Description
 * -------- ---------   ----------      -----------     ------------    -----------
    1.0     ??-???-2010                 Raymond         Created
    2.0    06-Sept-2010                 Nooryati        CR3366         Modified for CR3366
    3.0    17-Sep-2010                  Raymond         CR4381         Skip lot if threshold less than zero
    4.0    14-Dec-2010                  Nooryati        CR5530         Provision to maintain the separate EOLs and RTSs by region
    5.0    17-Dec-2010                  Nooryati        CR5531         Splitting the APJ LOT Threshold
    6.0    02-Oct-2012                  RP              CR7601         R13.10 - To stop blank emails sent to business pertaining to EOL 15 Day     notifications
    7.0    05-Mar-2018                  Emily           CR15486        Field Trip clean up for Opportunity
    8.0    02-Apr-2018  FY19-DCS-0502   Pallavi         CR15591        added Quote__c field as part of Story 4795081
    8.1    04-Apr-2018  FY19-DCS-0502   Pallavi         CR15591        added new method as part of LOTOcean code coverage 
    8.2    10-May-2018  FY19-DCS-0502   Pallavi         CR15591        modified product record to fix duplicate error
	8.3	   22-May-2018  FY19-DCS-0703	Venkat Sharan	CR15845		   Removed the test methods - testGetters,testLOTOppty1,testLOTOppty2 to improve apex code limit		
*/

public with sharing class LOTOceanUtilities {

    public static Map<String,LOT_Segment_Email_Fields__c> segmentEmailFieldMap;
    public static Map<String,Threshold_Region_Field__c> thresholdRegionFieldMap;

    public static Map<String, String> countryToRegionMap;

    public static Map<Id, Product2> productMap;

    public static void setupData(List<Opportunity> opptyList, List<AggregateResult> aggregatedResult ) {

        setSegmentEmailFieldMap();
        setThresholdRegionFieldMap();

        Set<String> countrySet = new Set<String>();
        Set<String> opptyIdSet = new Set<String>();
        for(Opportunity o : opptyList) {
            opptyIdSet.add(o.Id);
            countrySet.add(o.Primary_Product_Delivery_Address_Country__c);
        }

        Set<String> productIdSet = new Set<String>();
        for(AggregateResult ar : aggregatedResult) {
            productIdSet.add((String)ar.get('ProductId'));
        }

        setCountryToRegionMap(opptyIdSet,false);
        setProductMap(productIdSet, false);
    }

    public static void setSegmentEmailFieldMap() {

        if(segmentEmailFieldMap == null) {
            segmentEmailFieldMap = new Map<String,LOT_Segment_Email_Fields__c>();
            segmentEmailFieldMap = LOT_Segment_Email_Fields__c.getAll();
        }
    }

    public static void setThresholdRegionFieldMap() {

        if(thresholdRegionFieldMap == null) {
            thresholdRegionFieldMap = new Map<String,Threshold_Region_Field__c>();
            thresholdRegionFieldMap = Threshold_Region_Field__c.getAll();
        }
    }

    public static void setCountryToRegionMap(Set<String> countryList, Boolean toReset) {

        if(countryToRegionMap == null || toReset) {
            countryToRegionMap = new Map<String, String>();
            List<LOT_Region__c> regionList = [Select l.Threshold_Region__c, l.Region__c, l.Name, l.Id
                                                From LOT_Region__c l
                                                WHERE l.name IN :countryList];

            for(LOT_Region__c lr : regionList) {
                countryToRegionMap.put(lr.Name, lr.Threshold_Region__c);
            }
        }
    }

    public static void setProductMap(Set<String> productIdSet, boolean toReset) {
        
        //Rev 6.0 -- Commented the If statement
        //if(productMap == null || toReset) {
            productMap = new Map<Id, Product2>([SELECT Id, Name,
                                                    APJ_ASIA__c,APJ_China__c,APJ_ICC__c,APJ_HK_JPN_KOR__c,
                                                    LATAM__c,Brazil__c,FED__c,
                                                    AMER__c,EMEA__c, Source__c,
                                                    Container_Volume__c, Pallet_Quantity__c, Volume_to_Dollar_Ratio__c
                                                FROM Product2
                                                WHERE Id IN :productIdSet]);
        //}
    }

    public static Map<Id, Opportunity> getOpptyMap(Set<String> opptyIdSet) {
        Map<Id, Opportunity> tempMap = new Map<Id, Opportunity>( [
                                        SELECT Id, Name, Adjustment_weeks__c, Adjustment_Potential_Cost_Saving__c,
                                                Probability, Primary_Product_Delivery_Address_Country__c,
                                                Primary_Product_Delivery_Address_Region__c,
                                                Account.Sales_Channel__r.Region_Name__c,
                                                Account.Sales_Channel__r.Segment_Business_Unit_Name__c,
                                                Account.Sales_Channel__r.Segment_Desc__c ,LOT_Large_Opportunity__c,
                                                LOT_Large_Opportunity_Potential__c, Delta_bet_Customer_req_n_calculated__c,
                                                Eligible_for_Ocean__c, Potential_Cost_Savings_If_Ocean__c,
                                                Customer_Requested_Delivery_Date__c, Calculated_Delivery_in_Weeks__c,
                                                CloseDate, Ocean_Opportunity_Notification_Pop_Up__c, Confirmed_for_Ocean_by_Finance_Gbl_Ops__c,
                                                Additional_vol_to_team_Quarterly__c,Is_CFI_included__c,
                                                /*7.0 Ocean_Mandatory_Fields__c,*/ LOT_Mandatory_Fields__c, LOT_OCEAN_Email_Notification__c,
                                                Must_Arrive_By_Date__c, Do_you_want_to_pursue_Ocean__c
                                        FROM Opportunity
                                        WHERE Id IN :opptyIdSet]);
        return tempMap;
    }

    public static List<AggregateResult> getAggregatedResult(Set<Id> opptyIdSet) {
        List<AggregateResult> tempResult = [ SELECT
                                            OpportunityId,
                                            PriceBookEntry.Product2Id ProductId,
                                            PriceBookEntry.Product2.Product_Line_Desc__c ProductLineDesc,
                                            PriceBookEntry.Product2.Name ProductName,
                                            SUM(Quantity)totalQty,
                                            SUM(potential_cost_savings_if_ocean__c) totalSaving,
                                            MAX(estimated_delivery_lead_time_week__c) maxLeadTime,
                                            PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c EOL_NORTHAMERICADate,
                                            PriceBookEntry.Product2.EOL_Date_LATAM__c EOL_LATAMDate,
                                            PriceBookEntry.Product2.EOL_Date_EMEA__c EOL_EMEADate,
                                            PriceBookEntry.Product2.EOL_Date_APJ__c EOL_APJDate,
                                            PriceBookEntry.Product2.EOL_Date_OTHER__c EOL_OtherDate,
                                            PriceBookEntry.Product2.EOL_Date__c EOL_GlobalDate,
                                            PriceBookEntry.Product2.Replacing_Platform__c replacePlatform,
                                            Quote__c qouteNumber
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId IN :opptyIdSet
                                        GROUP BY OpportunityId, PriceBookEntry.Product2Id, PriceBookEntry.Product2.Product_Line_Desc__c, PriceBookEntry.Product2.Name,
                                                 PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c,PriceBookEntry.Product2.EOL_Date_LATAM__c,
                                                 PriceBookEntry.Product2.EOL_Date_EMEA__c,PriceBookEntry.Product2.EOL_Date_APJ__c,
                                                 PriceBookEntry.Product2.EOL_Date_OTHER__c,PriceBookEntry.Product2.EOL_Date__c,PriceBookEntry.Product2.Replacing_Platform__c,Quote__c]; //v8.0
        return tempResult;
    }

  
}