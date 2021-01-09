/* 
Created By:Shivam Singh
Date:18-05-2015
Description: Currently DSA & SFDC does not have a product total price sync because discount is not mapped properly.
User Story 162265: Correct revenue calculation in SFDC for the DSA received data
*/
public class DSAUtils{   
    //Method to apply the discount to unit price for the quote products updated from DSA
    public static void applyDiscountForDSAOpportunities(List<OpportunityLineItem> lstOpportunity){
        for(OpportunityLineItem obj:lstOpportunity){
            System.Debug('obj.Discount_off__c'+obj.Discount_off__c);
            System.Debug('obj.DSA_API_Update__c'+obj.DSA_API_Update__c);
            System.Debug('obj.Discount'+obj.Discount);
            if(obj.DSA_API_Update__c){
                if(obj.Discount_off__c != null && obj.Discount_off__c != obj.Discount){
                    obj.Discount = obj.Discount_off__c; 
                    obj.DSA_API_Update__c = false;                    
                }
            }               
        }    
    }
    
    //Method to reset the discount to 0 when product is disconnected from DSA
    public static void resetDiscountForDSAOpportunities(List<OpportunityLineItem> lstNewOpportunityLineItem,Map<Id,OpportunityLineItem> mapOldOpportunity){
        for(OpportunityLineItem obj:lstNewOpportunityLineItem){
            if(obj.DSA_API_Update__c){
                if(mapOldOpportunity.get(obj.Id).DPID__c != null && obj.DPID__c == null && mapOldOpportunity.get(obj.Id).Quote__c != null && obj.Quote__c == null){
                    obj.Discount = 0;
                    obj.DSA_API_Update__c = false;                    
                }
            }               
        }    
    }
}