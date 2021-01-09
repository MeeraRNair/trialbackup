public class ST_TestData
{
     public static ST_Tiers__c createST_Tiers()
     {
         ST_Tiers__c tiers = new ST_Tiers__c();
         try
         {
             tiers.Product_Categorization_Tier_1__c ='SOFTWARE';
             tiers.Product_Categorization_Tier_2__c = 'APPLICATION';
             tiers.Product_Categorization_Tier_3__c = 'IT SUPPORTED';
             //tiers.Product_Id__c = 'PDC000000016539';
             tiers.Product_Name__c = 'SALESCENTRAL';
             tiers.Status__c = '1';
             tiers.Status_CAT__c = '1';
             tiers.Status_CTA__c = '1';
             //tiers.ST_RemedyProduct_Id = 'OTP000000003321';
             tiers.Service_Categorization_Tier_3__c = 'REPORT';
             tiers.Service_Categorization_Tier_2__c = 'DATA RELATED';
             tiers.Service_Categorization_Tier_1__c = 'FAILURE';
             insert tiers;
             
         }
         catch(Exception Ex)
         {
         
         } 
         return tiers; 
     }
  }