public class CPSDUpdateOpportunityLineItemstatusAD {
    //Added by Ershad for after Delete CPSD Opportunity Product
     public static void backupCPSDOpportunityLineItem(list<OpportunityLineItem> listOppLineItems) {
	    String strBoomiProfile = UserInfo.getProfileId();  
        list<Oppty_Product_Deleted__c> listProductDeleted = new list<Oppty_Product_Deleted__c>();
         if(Recursion_check.bisFirstTime)
         {
           Recursion_check.bisFirstTime = false;
        for(OpportunityLineItem oplineItem : listOppLineItems) {
                if(oplineItem.CPSD_Opportunity_Product_ID__c != null){   
                Oppty_Product_Deleted__c productDeleted = new Oppty_Product_Deleted__c();
				productDeleted.Product_Name__c=oplineItem.Brand_Desc__c;
				productDeleted.Dell_Opportunity_Line_Item_ID__c =oplineItem.Id;
				productDeleted.Dell_Opportunity_ID__c = oplineItem.OpportunityId;
				productDeleted.CPSD_Opportunity_Product_ID__c=oplineItem.CPSD_Opportunity_Product_ID__c;
				If (!(strBoomiProfile.contains('00eA0000000hNqF'))){ 
                    productdeleted.CPSD_Opportunity_Line_Item_Deleted__c='Waiting Sync';
                }
				listProductDeleted.add(productDeleted);
            }
           }
         }       
        if(!listProductDeleted.isEmpty()) {
             try{
            insert listProductDeleted;
             }catch(Exception ex) {
                System.Debug('Error :' + ex.getMessage());
             }     
        }     
    }


}