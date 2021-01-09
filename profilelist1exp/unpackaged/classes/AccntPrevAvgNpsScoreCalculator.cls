/***********************************************************
    * Name          : AccntPrevAvgNpsScoreCalculator 
    * Description   : Class to query and retrieve the average previous NPS Score for all contacts for a list of accountClass 
    * ---------------------------------------------------------
    * Revision  Name             Date         Description
    * 1.0       Jessie Tan       24-Apr-2014  CR 9548  - Class to query and retrieve the average previous NPS Score for all 
    *                                                    contacts for a list of accountClass
    * 1.1       Kokilavani D     08-Aug-2014  CR 9548  - CRQ 0980 Changed the date range to reflect dates instead of number of days                                                                                                                                                             
************************************************************/

global class AccntPrevAvgNpsScoreCalculator extends AccntAvgNpsScoreCalculator {

    public override AggregateResult[] querySourceData(Set<Id> accountIdSet){
        
        Date_Range__c prevNPSDate = Date_Range__c.getValues('Previous_NPS_Data_Date_Range'); //v1.1
    
        //it includes 181 -360 ago. Day 181th and 360th ago is included as well.
        return [SELECT Contact__r.AccountId accountId , Contact__c, AVG(NPS_Score__c) avgScore FROM NPS_Data__c 
                    where Contact__r.AccountId in :accountIdSet
                    and (NPS_Score__c <> null and NPS_Score__c <> 0)
                    //v1.1 - Start
                    //and (Survey_Date__c = LAST_N_DAYS:360 and Survey_Date__c < LAST_N_DAYS:180 )
                    and (Survey_Date__c >= :prevNPSDate.Start_Date__c and Survey_Date__c <= :prevNPSDate.End_Date__c) //v1.1 - End
                    group by Contact__r.AccountId, Contact__c 
                    ];
         
         /*         
         return [SELECT Contact__r.AccountId accountId , Contact__c, AVG(NPS_Score__c) avgScore FROM NPS_Data__c 
                    where Contact__r.AccountId in :accountIdSet
                    and (NPS_Score__c <> null and NPS_Score__c <> 0)
                    and (Survey_Date__c = LAST_N_QUARTERS:4 and Survey_Date__c < LAST_N_QUARTERS:2 )
                    group by Contact__r.AccountId, Contact__c 
                    ];
                    
                    */
    }

}