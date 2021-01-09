public class CPSDUpdateOpportunityLineItemstatusAU {
    // Added by Ershad - CPSD integration status Flag to Waiting Sync on Opportunity and Opportunity Product after update
    
    public static void cpsdopportunityFlagAfterUpdate(list<OpportunityLineItem> listLineItems,map<Id, OpportunityLineItem> mapRelatedOppLi){
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE);
	   Set<id> setoppidset = new Set<id>();
       Set<Opportunity> setoppset = new Set<Opportunity>();
	   List<OpportunityLineItem> listolit=new List<OpportunityLineItem>();
       Map<id,Opportunity> mapOppMap;
       for(OpportunityLineItem  oli : listLineItems){
           if(oli.Sales_Configurator_Identifier__c=='ACT'){
            setoppidset.add(oli.OpportunityId);
           }
        }
     mapOppMap = new Map<id,Opportunity>([Select id,AccountId,RecordTypeId,CPSD_Integration_Status__c,Bill_To_Ship_To_Comments__c,Cloned_Parent_Id__c from Opportunity where RecordTypeId=:newOppRecordTypeID and  id IN:setoppidset]);
        if(Recursion_check.bisFirstTime)
         {
           Recursion_check.bisFirstTime = false;
		   for(OpportunityLineItem  oli : listLineItems){
               OpportunityLineItem oliOld=mapRelatedOppLi.get(oli.id);
       if((oli.Sales_Configurator_Identifier__c=='ACT' && mapOppMap.size()>0 && mapOppMap.get(oli.OpportunityId).AccountId !=Null &&
			 mapOppMap.get(oli.OpportunityId).RecordTypeId ==newOppRecordTypeID) && (oli.End_User_Requested_Delivery_Date__c!=oliOld.End_User_Requested_Delivery_Date__c||
             oli.Product_Transaction_Type__c!=oliOld.Product_Transaction_Type__c||oli.Installation_Company_Name__c!=oliOld.Installation_Company_Name__c||oli.Installation_Address__c!=oliOld.Installation_Address__c||
             oli.Installation_City__c!=oliOld.Installation_City__c||oli.Installation_Contact__c!=oliOld.Installation_Contact__c||oli.Installation_Country__c!=oliOld.Installation_Country__c||oli.Installation_Email__c!=oliOld.Installation_Email__c||oli.Installation_Phone__c!=oliOld.Installation_Phone__c||oli.Installation_State_Province__c!=oliOld.Installation_State_Province__c||
             oli.Installation_Theater__c!=oliOld.Installation_Theater__c||oli.Installation_Zip_Postal_Code__c!=oliOld.Installation_Zip_Postal_Code__c||oli.Site_ID__c!=oliOld.Site_ID__c||oli.Ship_To_Company_Name__c!=oliOld.Ship_To_Company_Name__c||oli.Ship_To_Address__c!=oliOld.Ship_To_Address__c||oli.Ship_To_City__c!=oliOld.Ship_To_City__c||oli.Ship_To_Contact__c!=oliOld.Ship_To_Contact__c||oli.Ship_To_Country__c!=oliOld.Ship_To_Country__c||
             oli.Ship_To_Email__c!=oliOld.Ship_To_Email__c||oli.Ship_To_Phone__c!=oliOld.Ship_To_Phone__c||oli.Ship_To_State_Province__c!=oliOld.Ship_To_State_Province__c||oli.Ship_To_Theater__c!=oliOld.Ship_To_Theater__c||oli.Ship_To_Zip_Postal_Code__c!=oliOld.Ship_To_Zip_Postal_Code__c||oli.Special_Pricing_Status__c!=oliOld.Special_Pricing_Status__c||oli.ConfigGroup_ID__c!=oliOld.ConfigGroup_ID__c||
             oli.Dell_Order_ID__c!=oliOld.Dell_Order_ID__c||oli.Dell_Sales_ID__c!=oliOld.Dell_Sales_ID__c||oli.MyQuotes_Cart_Number__c!=oliOld.MyQuotes_Cart_Number__c||oli.Vblock_Material_Procurement_Method__c!=oliOld.Vblock_Material_Procurement_Method__c||oli.Client_Site_Deployment__c!=oliOld.Client_Site_Deployment__c||oli.Vblock_Physical_Assembly_Location__c!=oliOld.Vblock_Physical_Assembly_Location__c||oli.Acquisition_Method__c!=oliOld.Acquisition_Method__c||oli.EMC_Opportunity_Product_ID__c!=oliOld.EMC_Opportunity_Product_ID__c)){ 
                 Opportunity opt=new Opportunity();
                 opt.id=oli.OpportunityId;    
                 opt.CPSD_Integration_Status__c='Waiting Sync';
                 setoppset.add(opt);
                 
                 OpportunityLineItem oltt=new OpportunityLineItem();
                 oltt.Id=oli.Id;
                 oltt.CPSD_Integration_Status__c='Waiting Sync';
                 listolit.add(oltt);
                 system.debug('inside optypro'+listolit);
                 }
               }
             
             if(listolit.size()>0){
                TriggerExecutionController.setSkipAllTriggers(true);   
                Database.update(listolit,False);
                TriggerExecutionController.setSkipAllTriggers(false);    
             }
			 if(setoppset.size()>0){
			    List<Opportunity> listoppset1=new List<Opportunity>(setoppset);
                system.debug('inside optyupdate'+listoppset1); 
			    TriggerExecutionController.setSkipAllTriggers(true);   
                Database.update(listoppset1,False);
                TriggerExecutionController.setSkipAllTriggers(false); 
			 }
        }
    }

}