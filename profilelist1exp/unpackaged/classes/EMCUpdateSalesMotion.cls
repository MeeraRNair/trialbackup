public class EMCUpdateSalesMotion {
	
    @InvocableMethod(label='Update EMC Sales Motion' description='')
    public static void updateSalesMotion(List<ID> oppid){
        Opportunity opp = new Opportunity(id= oppid[0]);
        Integer intemc = 0;
        Integer intnonemc = 0;
        List<OpportunityLineItem> listoli = [SELECT Business_Family_Flag__c from OpportunityLineItem WHERE opportunityid=:oppid];
        if(listoli.size() == 0){
            opp.EMC_Sales_Motion__c = '';
        }
        
        else{
            for(OpportunityLineItem item :listoli ){
                if(item.Business_Family_Flag__c == 'EMC'){
                    intemc++;
                }
                else{
                    intnonemc++;
                }
            }
             if(intemc>0 || intnonemc>0){
                  if(intemc>0 && intnonemc>0){
                
                    opp.EMC_Sales_Motion__c = 'Mixed';
                }
                else if(intemc>0){
                    opp.EMC_Sales_Motion__c = 'EMC Only';
                }
                else{
                    opp.EMC_Sales_Motion__c = 'Dell Only';
                }
             }
           
        }
        
        update opp;
    }
}