/*

Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         CR 15814    FY18-DCS-0102   30-Nov-2017     Emily           To query Opportunity record using the Id passed from Lightning component
*/   

public class ltng_OpportunityAlertTextCtrl{
    
    @AuraEnabled
    public static Opportunity serverEcho(Id recordId){
        system.debug('Emily: '+recordId);
        return [Select Id, Name, StageName, Total_Margin__c, Amount, SOC_Solution_Name_Console__c, SOC_Qualify_Temp__c, ServiceProductCount__c 
                From Opportunity 
                Where Id = :recordId];
    }
}