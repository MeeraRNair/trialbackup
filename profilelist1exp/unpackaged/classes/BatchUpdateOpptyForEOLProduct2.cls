/*
Author: Raymond Yip

History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      20-Apr-2010    Raymond         Created for CR2561, R11.5
1.1      06-Sept-2010   Nooryati        CR3366: Enhancements to EOL and RTS Product Handling
1.2		 14-Dec-2010	Nooryati		CR5530: Provision to maintain the separate EOLs and RTSs by region

*/
global class BatchUpdateOpptyForEOLProduct2 implements Database.Batchable<sObject> { 
    Date currentDate;
    DateTime currentDatetime;  
    Date next7Day;
    Date next15Day;
    Date next30Day; 
    public Boolean isTest = false;
    public String testOpptyId = '';
    
    global BatchUpdateOpptyForEOLProduct2(){
                    
        System.debug('###DEBUG### BATCH INITIATE');     
        currentDatetime = system.now();
        System.debug('###DEBUG### currentDatetime =' + currentDatetime);
        currentDate = Date.newInstance(currentDatetime.year(), currentDatetime.month(), currentDatetime.day());
        
        next7Day = currentDate.addDays(7); 
        next15Day = currentDate.addDays(15); 
        next30Day = currentDate.addDays(30);
                    
        System.debug('###DEBUG### BATCH EOLDate == next7Day  ' + next7Day); 
        System.debug('###DEBUG### BATCH EOLDate == next15Day  ' +next15Day);
        System.debug('###DEBUG### BATCH EOLDate == next30Day  ' + next30Day);   
        System.debug('###DEBUG### BATCH EOLDate == currentDate  ' + currentDate);  
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('###DEBUG### BATCH START');        
        
        if(!isTest) {
            return Database.getQueryLocator(
                          [SELECT Id, PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c,PriceBookEntry.Product2.EOL_Date_LATAM__c,
                          			PriceBookEntry.Product2.EOL_Date_EMEA__c,PriceBookEntry.Product2.EOL_Date_APJ__c,
                          			PriceBookEntry.Product2.EOL_Date_OTHER__c,PriceBookEntry.Product2.EOL_Date__c,PriceBookEntry.Product2Id,                            		
                            		Opportunity.EOL_0_Day_Email_Notification__c,OpportunityId, 
                            		Opportunity.StageName, Opportunity.Probability, Opportunity.Primary_Product_Delivery_Address_Region__c
                                FROM OpportunityLineItem
                                //TODO: add for other region's EOLDate!
                                WHERE(((Opportunity.Primary_Product_Delivery_Address_Region__c = 'NORTH AMERICA' AND PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c IN (:next7Day,:next15Day,:next30Day))                               
                                OR (Opportunity.Primary_Product_Delivery_Address_Region__c = 'LATAM' AND PriceBookEntry.Product2.EOL_Date_LATAM__c IN (:next7Day,:next15Day,:next30Day))
                                OR ((Opportunity.Primary_Product_Delivery_Address_Region__c = 'EMEA' OR Opportunity.Primary_Product_Delivery_Address_Region__c = 'EC-EMEA') AND PriceBookEntry.Product2.EOL_Date_EMEA__c IN (:next7Day,:next15Day,:next30Day))
                                OR (Opportunity.Primary_Product_Delivery_Address_Region__c = 'APJ' AND PriceBookEntry.Product2.EOL_Date_APJ__c IN (:next7Day,:next15Day,:next30Day))
                                OR (Opportunity.Primary_Product_Delivery_Address_Region__c = 'Other' AND PriceBookEntry.Product2.EOL_Date_OTHER__c IN (:next7Day,:next15Day,:next30Day))
                                OR (PriceBookEntry.Product2.EOL_Date__c IN (:next7Day,:next15Day,:next30Day))
                                OR PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date_LATAM__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date_EMEA__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date_APJ__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date_OTHER__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date__c <= :currentDate)
                                AND Opportunity.StageName NOT IN ('Win - 100%', 'Lost, Cancelled - 0%')
                                AND (Opportunity.Probability >= 10 AND Opportunity.Probability <= 90))]);                                                          
                                                                            
        } else {
            system.debug('###DEBUG### ++ ' + testOpptyId);
            system.debug('###DEBUG### ++ ' + [SELECT Id, PriceBookEntry.Product2.EOL_Date__c, 
                                    PriceBookEntry.Product2Id,Opportunity.EOL_0_Day_Email_Notification__c,
                                    OpportunityId
                                FROM OpportunityLineItem
                                WHERE OpportunityId = :testOpptyId
                                ]);
            return Database.getQueryLocator(
                            [SELECT Id, PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c,
                            		PriceBookEntry.Product2.EOL_Date_LATAM__c,PriceBookEntry.Product2.EOL_Date_EMEA__c,
                            		PriceBookEntry.Product2.EOL_Date_APJ__c,PriceBookEntry.Product2.EOL_Date_OTHER__c,PriceBookEntry.Product2Id,
                            		Opportunity.EOL_0_Day_Email_Notification__c,OpportunityId,
                            		Opportunity.Probability,Opportunity.Primary_Product_Delivery_Address_Region__c 
                                FROM OpportunityLineItem
                                //TODO: add for other region's EOLDate!
                                WHERE(((Opportunity.Primary_Product_Delivery_Address_Region__c = 'NORTH AMERICA' AND PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c IN (:next7Day,:next15Day,:next30Day))                               
                                OR (Opportunity.Primary_Product_Delivery_Address_Region__c = 'LATAM' AND PriceBookEntry.Product2.EOL_Date_LATAM__c IN (:next7Day,:next15Day,:next30Day))
                                OR ((Opportunity.Primary_Product_Delivery_Address_Region__c = 'EMEA' OR Opportunity.Primary_Product_Delivery_Address_Region__c = 'EC-EMEA') AND PriceBookEntry.Product2.EOL_Date_EMEA__c IN (:next7Day,:next15Day,:next30Day))
                                OR (Opportunity.Primary_Product_Delivery_Address_Region__c = 'APJ' AND PriceBookEntry.Product2.EOL_Date_APJ__c IN (:next7Day,:next15Day,:next30Day))
                                OR (Opportunity.Primary_Product_Delivery_Address_Region__c = 'Other' AND PriceBookEntry.Product2.EOL_Date_OTHER__c IN (:next7Day,:next15Day,:next30Day))
                                OR (PriceBookEntry.Product2.EOL_Date__c IN (:next7Day,:next15Day,:next30Day))
                                OR PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date_LATAM__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date_EMEA__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date_APJ__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date_OTHER__c <= :currentDate
                                OR PriceBookEntry.Product2.EOL_Date__c <= :currentDate)
                                AND OpportunityId = :testOpptyId
                                //AND Opportunity.CreatedDate > :dellConfig.OpportunityEOLStartDate                             
                                AND Opportunity.StageName NOT IN ('Win - 100%', 'Lost, Cancelled - 0%')
                                AND (Opportunity.Probability >= 10 AND Opportunity.Probability <= 90))]);
        }
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('###DEBUG### BATCH EXECUTE');      
        //System.debug('###DEBUG### BATCH scope = ' + scope); 

        Map<Id, Opportunity> opptyToUpdateMap = new Map<Id, Opportunity>();
        
        for(sObject obj : scope) {      
            OpportunityLineItem oli = (OpportunityLineItem)obj;
            System.debug('###DEBUG### BATCH oli = ' + oli + ' ---- ' + oli.OpportunityId); 
            //Date EOLDate = oli.PriceBookEntry.Product2.EOL_Date__c;
            //System.debug('###DEBUG### BATCH EOLDate = ' + EOLDate); 
            Opportunity tempOppty;
            Date EOLDate;
            
            if(opptyToUpdateMap.containsKey(oli.OpportunityId)) {
                tempOppty = opptyToUpdateMap.get(oli.OpportunityId);
            } else {
                tempOppty = new Opportunity(Id=oli.OpportunityId);              
            }
            System.debug('###DEBUG### tempOppty = ' + tempOppty);
            System.debug('###DEBUG### oli.Opportunity.Primary_Product_Delivery_Address_Region__c = ' + oli.Opportunity.Primary_Product_Delivery_Address_Region__c);
            
           if(oli.Opportunity.Primary_Product_Delivery_Address_Region__c == 'NORTH AMERICA') {
				EOLDate = oli.PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c;
				System.debug('###DEBUG### EOLDateNorthAmerica = ' + EOLDate);
			} else if (oli.Opportunity.Primary_Product_Delivery_Address_Region__c == 'LATAM') {
				EOLDate = oli.PriceBookEntry.Product2.EOL_Date_LATAM__c;
				System.debug('###DEBUG### EOLDateLatam = ' + EOLDate);
			} else if (oli.Opportunity.Primary_Product_Delivery_Address_Region__c == 'EMEA' || oli.Opportunity.Primary_Product_Delivery_Address_Region__c == 'EC-EMEA') {
				EOLDate = oli.PriceBookEntry.Product2.EOL_Date_EMEA__c;
				System.debug('###DEBUG### EOLDateEMEA = ' + EOLDate);
			} else if (oli.Opportunity.Primary_Product_Delivery_Address_Region__c == 'APJ') {
				EOLDate = oli.PriceBookEntry.Product2.EOL_Date_APJ__c;
				System.debug('###DEBUG### EOLDateAPJ = ' + EOLDate);
			} else if (oli.Opportunity.Primary_Product_Delivery_Address_Region__c == 'Other') {
				EOLDate = oli.PriceBookEntry.Product2.EOL_Date_OTHER__c;
				System.debug('###DEBUG### EOLDateOther = ' + EOLDate);
            } else {
            	EOLDate = oli.PriceBookEntry.Product2.EOL_Date__c;
				System.debug('###DEBUG### EOLDateGlobal = ' + EOLDate);
			}
            
	        System.debug('###DEBUG### BATCH EOLDate = ' + EOLDate); 
	        System.debug('###DEBUG### oli.Opportunity.EOL_0_Day_Email_Notification__c = ' + oli.Opportunity.EOL_0_Day_Email_Notification__c);
	        
	        if(EOLDate <= currentDate && oli.Opportunity.EOL_0_Day_Email_Notification__c == null && oli.Opportunity.Probability >= 60) {                
	            System.debug('###DEBUG### BATCH currentDate '); 
	            tempOppty.EOL_0_Day_Email_Notification__c = currentDatetime;
	        }
	        
	        System.debug('###DEBUG### BATCH EOLDate == next7Day  ' + EOLDate + '==' + next7Day);
	        if(EOLDate == next7Day && oli.Opportunity.Probability >= 60) {
	            System.debug('###DEBUG### BATCH next7Day ');    
	            tempOppty.EOL_7_Day_Email_Notification__c = currentDatetime;
	        }
	        
	        System.debug('###DEBUG### BATCH EOLDate == next15Day  ' + EOLDate + '==' + next15Day);              
	        if(EOLDate == next15Day) {
	            System.debug('###DEBUG### BATCH next15Day  ');   
	            tempOppty.EOL_15_Day_Email_Notification__c = currentDatetime;
	        }
	        
	        System.debug('###DEBUG### BATCH EOLDate == next30Day  ' + EOLDate + '==' + next30Day);
	        if(EOLDate == next30Day) {
	            System.debug('###DEBUG### BATCH next30Day ');   
	            tempOppty.EOL_30_Day_Email_Notification__c = currentDatetime;
	        }
	        
	        if(!opptyToUpdateMap.containsKey(oli.OpportunityId)) {
	            opptyToUpdateMap.put(tempOppty.Id, tempOppty);
	        }
            
        }
        
        System.debug('###DEBUG### Opportunities to update - ' + opptyToUpdateMap.keyset());
        System.debug('###DEBUG### Opportunities size to update - ' + opptyToUpdateMap.size());
        //update opptyToUpdateMap.values();
         Database.SaveResult[] lsr = Database.update(opptyToUpdateMap.values(),false);
        //processOpptyEOL(scope);
 
        for(Database.SaveResult sr : lsr){ 
            if (!sr.isSuccess()) { 
                System.debug('###DEBUG### BatchUpdateOpptyForEOLProduct update error - ' + sr.getID() + ' -- '+ sr);
            }
        } 
    }

    global void finish(Database.BatchableContext BC){
        System.debug('###DEBUG### Batch END');
    }
}