@isTest
private class SnP_afterUpdateThresholdTriggerTest{
	static testMethod void SnP_afterUpdateThresholdTriggerTest(){
    
        S_P_Vendor_Product_Threshold__c threshEa = new S_P_Vendor_Product_Threshold__c(Agreement_Level__c = 'A1', 
			Level__c = 'EA', Percentage__c = 10, Threshold_Required__c = TRUE);
        Database.insert(threshEa);
        
        S_P_Vendor_Product_Threshold__c threshProd = new S_P_Vendor_Product_Threshold__c( Level__c = 'Product', 
			Minimum_Revenue__c = 10000, Percentage__c = 10, Product_Description__c = 'Enterprise Desktop w MDOP', 
			Product_Family__c = 'Windows', Threshold_Required__c = TRUE);
        Database.insert(threshProd);
        
        threshEa.Percentage__c = 15;
        Database.update(threshEa);
        
        threshProd.Percentage__c = 15;
        threshProd.Minimum_Revenue__c = 5000;
        Database.update(threshProd);
        
        threshProd.Percentage__c = 10;
        Database.update(threshProd);
        
        threshProd.Minimum_Revenue__c = 10000;
        Database.update(threshProd);
        
    
    }
    
}