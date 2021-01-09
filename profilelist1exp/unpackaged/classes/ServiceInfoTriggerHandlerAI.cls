/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0
 * 2.0      17936       FY20-1002       20-Aug-2019     Fenny           Refactoring trigger framework. Below code copied from ServiceInfoTriggerHandler
 * 
 */ 
public class ServiceInfoTriggerHandlerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){
        
        if(trigger.isAfter && trigger.isinsert){
            Map<ID, Partner_Track__c> mappartner = new Map<ID, Partner_Track__c>(); 
            List<Id> listIds = new List<Id>();

            for (Service_Information__c c : (List<Service_Information__c>)listNew) {
                listIds.add(c.Partner_Track__c);
            }

            mappartner = new Map<Id, Partner_Track__c>([SELECT id, Enabled_for_Services__c,(SELECT ID, Velocity_Services__c , Velocity_Services_Managed__c , Velocity_Services_Implement__c  FROM Service_Information__r) FROM Partner_Track__c WHERE ID IN :listIds]);

            for ( Service_Information__c s: (List<Service_Information__c>)listNew){
                Partner_Track__c partnertrack = mappartner.get(s.Partner_Track__c);
                if(s.Velocity_Services__c =='yes' || s.Velocity_Services_Managed__c=='yes' || s.Velocity_Services_Implement__c=='yes'){
                    partnertrack.Enabled_for_Services__c=true;
                
                }else{
                    partnertrack.Enabled_for_Services__c=false;
                }
            }
            update mappartner.values();
 
        }
    }
}