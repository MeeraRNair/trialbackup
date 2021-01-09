/***********************************************************
    * Name        :    AccntCurrAvgNpsScoreCalculator 
    * Description :    Class to query and retrieve the average current NPS Score for all contacts for a list of accountClass 
    * ---------------------------------------------------------
    * Revision  Name             Date         Description
    * 1.0       Jessie Tan       24-Apr-2014  CR 9548  - Class to query and retrieve the average current NPS Score for all 
    *                                                    contacts for a list of accountClass
    * 1.1       Kokilavani D     08-Aug-2014  CR 9548  - CRQ 0980 Changed the date range to reflect dates instead of number of days                                                       
************************************************************/

global class AccntCurrAvgNpsScoreCalculator extends AccntAvgNpsScoreCalculator {

     public override AggregateResult[] querySourceData(Set<Id> accountIdSet){
     
        Date_Range__c currNPSDate = Date_Range__c.getValues('Current_NPS_Data_Date_Range'); //v1.1
    
        //it includes 0-180 ago. today is included. day 180th ago is included as well.
        return [SELECT Contact__r.AccountId accountId , Contact__c, AVG(NPS_Score__c) avgScore FROM NPS_Data__c 
                    where Contact__r.AccountId in :accountIdSet
                    and (NPS_Score__c <> null and NPS_Score__c <> 0)
                    //v1.1 - Start
                    //and (Survey_Date__c = LAST_N_DAYS:180)
                    and (Survey_Date__c >= :currNPSDate.Start_Date__c and Survey_Date__c <= :currNPSDate.End_Date__c) //v1.1 - End
                    group by Contact__r.AccountId, Contact__c 
                    ];
    }

}