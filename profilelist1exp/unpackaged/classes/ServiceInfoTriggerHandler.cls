/*
 * Author   : Bharadwaj
 * Purpose  : this is to restrict service information records to only one per account. 
 *            If user tries to create more than one record the system should throw error.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0
 * 2.0      17936       FY20-1002       20-Aug-2019     Fenny           Refactoring trigger framework 
 * 
 */ 
public class ServiceInfoTriggerHandler extends TriggerHandler { 
/*
     public override void onBeforeInsert() {  
         
         Set<ID> setservInfo = new Set<ID>();
         
        for(Service_Information__c servInf : (List<Service_Information__c>)trigger.new)
        { 
        system.debug('>>>setservInfo '+setservInfo );
            if(servInf.Partner_Track__c!= null){
             setservInfo.add(servInf.Partner_Track__c);}
        }
        if(setservInfo !=null && !setservInfo.isempty()){
         
        List<Service_Information__c> listexstServInfo = [select name,id from service_information__C where Partner_Track__c in :setservInfo ];
            
        for(Service_Information__c servInf : (List<Service_Information__c>)trigger.new)
        { 
         if(listexstServInfo.size()>0){
             system.debug('<<<<setservInfo '+listexstServInfo);
             servInf.addError('Service information already exists for this partner. Please view or edit the existing record');
         }
        }
    }
     }
     public override void onBeforeUpdate(){
     if(trigger.isBefore && trigger.isUpdate){
      System.debug('onBeforeUpdate');
           Set<Id> setservInfo = new Set<Id>();
           for(Service_Information__c servInf : (List<Service_Information__c>)trigger.new)
           { 
             setservInfo.add(servInf.Id);
               Service_Information__c oldServicesInfo =(Service_Information__c)Trigger.oldMap.get(servInf.Id);
               Service_Information__c newServicesInfo =(Service_Information__c)Trigger.NewMap.get(servInf.Id);
               if(oldServicesInfo.Authorized_Exception__c != newServicesInfo.Authorized_Exception__c ||
                  oldServicesInfo.Cisco__c != newServicesInfo.Cisco__c || 
                  oldServicesInfo.Delivery_Type__c != newServicesInfo.Delivery_Type__c ||
                  oldServicesInfo.Inside_DELL_EMC_Logistics_Network__c != newServicesInfo.Inside_DELL_EMC_Logistics_Network__c ||
                  oldServicesInfo.Inside_DELL_EMC_Service_Radius__c != newServicesInfo.Inside_DELL_EMC_Service_Radius__c ||
                  oldServicesInfo.Federation_Program_Tier__c != newServicesInfo.Federation_Program_Tier__c ||
                  oldServicesInfo.Key_Vendor_Relationships__c != newServicesInfo.Key_Vendor_Relationships__c ||
                  oldServicesInfo.Master_Site_ID__c != newServicesInfo.Master_Site_ID__c ||
                  oldServicesInfo.Partner_Track__c!= newServicesInfo.Partner_Track__c||
                  oldServicesInfo.Pivotal__c != newServicesInfo.Pivotal__c ||
                  oldServicesInfo.Provider_ID__c != newServicesInfo.Provider_ID__c ||
                  oldServicesInfo.Provider_Name__c != newServicesInfo.Provider_Name__c ||
                  oldServicesInfo.PS_Subcontracting_Tier__c != newServicesInfo.PS_Subcontracting_Tier__c ||
                  oldServicesInfo.Velocity_Services_Implement__c != newServicesInfo.Velocity_Services_Implement__c ||
                  oldServicesInfo.Services_Deployment_Exception__c != newServicesInfo.Services_Deployment_Exception__c ||
                  oldServicesInfo.Velocity_Services__c != newServicesInfo.Velocity_Services__c ||
                  oldServicesInfo.Services_Onsite_Support_Exception__c != newServicesInfo.Services_Onsite_Support_Exception__c ||
                  oldServicesInfo.Services_Performance_Deploy__c != newServicesInfo.Services_Performance_Deploy__c ||
                  oldServicesInfo.Velocity_Services_Managed__c != newServicesInfo.Velocity_Services_Managed__c ||
                  oldServicesInfo.Services_Remote_Support_Exception__c != newServicesInfo.Services_Remote_Support_Exception__c || 
                  oldServicesInfo.Services_Performance_Support__c != newServicesInfo.Services_Performance_Support__c || 
                  oldServicesInfo.Third_Party_Networking__c != newServicesInfo.Third_Party_Networking__c ||
                  oldServicesInfo.Third_Party_Virtualization__c != newServicesInfo.Third_Party_Virtualization__c ||
                  oldServicesInfo.Vmware__c != newServicesInfo.Vmware__c ){  
                       
                       System.debug('newSIRecord.EMC_Operation__c'+servInf.EMC_Operation__c);
                       servInf.EMC_Operation__c ='Updation';
                       System.debug('New value EMC_Operation__c'+servInf.EMC_Operation__c);
               }  
            }
          
          }
       }
    
    public override void OnAfterUpdate() {
        if(trigger.isAfter && trigger.isUpdate ){
       Map<ID, Partner_Track__c> mappartner = new Map<ID, Partner_Track__c>(); 
  List<Id> listIds = new List<Id>();

        for (Service_Information__c c : (List<Service_Information__c>)Trigger.new) {
            listIds.add(c.Partner_Track__c);
         }

  mappartner = new Map<Id, Partner_Track__c>([SELECT id, Enabled_for_Services__c,(SELECT ID, Velocity_Services__c , Velocity_Services_Managed__c , Velocity_Services_Implement__c  FROM Service_Information__r) FROM Partner_Track__c WHERE ID IN :listIds]);

        for ( Service_Information__c s: (List<Service_Information__c>)Trigger.new){
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
    public override void OnAfterInsert() {
        // OnAfterUpdate();
if(trigger.isAfter && trigger.isinsert){
       Map<ID, Partner_Track__c> mappartner = new Map<ID, Partner_Track__c>(); 
  List<Id> listIds = new List<Id>();

        for (Service_Information__c c : (List<Service_Information__c>)Trigger.new) {
            listIds.add(c.Partner_Track__c);
        }

  mappartner = new Map<Id, Partner_Track__c>([SELECT id, Enabled_for_Services__c,(SELECT ID, Velocity_Services__c , Velocity_Services_Managed__c , Velocity_Services_Implement__c  FROM Service_Information__r) FROM Partner_Track__c WHERE ID IN :listIds]);

        for ( Service_Information__c s: (List<Service_Information__c>)Trigger.new){
            Partner_Track__c partnertrack = mappartner.get(s.Partner_Track__c);
            if(s.Velocity_Services__c =='yes' || s.Velocity_Services_Managed__c=='yes' || s.Velocity_Services_Implement__c=='yes'){
                partnertrack.Enabled_for_Services__c=true;
                
            }else{
            partnertrack.Enabled_for_Services__c=false;
            }
        }
        update mappartner.values();
 
    }
     } */
}