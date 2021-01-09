/************************************************************************
Name: RebateRequestProductCntrlr  
Author: Subramanyam

Test Class for code coverage: RebateRequestProductCntrlrTest


************************************************************/


public class RebateRequestProductCntrlr {
    
    public Id thisAllianceId {get;set;}
    
    public List<Rebate_Request_Product__c> Sorted = new List<Rebate_Request_Product__c>();
    
    public boolean hideLabel {get;set;}
    
    
    public List<Rebate_Request_Product__c> getSorted() {
    
        hideLabel = false;
    
        

        
         Sorted = [SELECT Id,Part_Requested__c, Part_Name_Part_Number__c, Quantity__c,Price_Requested__c, Competitor_Name_Competitor_Part__c,Dell_System_Model_type__c,Quantity_Approved__c, 
                 Approved_Price_per_unit__c,Rebate_Per_Units__c, Start_Date__c, End_Date__c, Quantity_Claimed__c, Quantity_Remaining__c, Alliance_Rebate_Request__r.Status__c FROM Rebate_Request_Product__c
                 WHERE Alliance_Rebate_Request__r.Id =: thisAllianceId]; 
        
       /*for(Rebate_Request_Product__c rebProd: Sorted){
            If( Alliance_Rebate_Request__c.Client_Enterprise__c== 'Enterprise' && Alliance_Rebate_Request__c.System_Partner_Name__c == 'Intel' ){
                hideLabel = true;
            }
        }*/
          
        return Sorted;    
    }
}