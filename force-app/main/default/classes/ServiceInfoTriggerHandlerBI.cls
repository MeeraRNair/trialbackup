/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0
 * 2.0      17936       FY20-1002       20-Aug-2019     Fenny           Refactoring trigger framework. Below code copied from ServiceInfoTriggerHandler
 * 
 */ 
public class ServiceInfoTriggerHandlerBI implements BeforeInsert {
    
    public void handleBeforeInsert(List<sObject> listNew){
         
        Set<ID> setservInfo = new Set<ID>();
         
        for(Service_Information__c servInf : (List<Service_Information__c>)listNew)
        { 
            system.debug('>>>setservInfo '+setservInfo );
            if(servInf.Partner_Track__c!= null)
            {
                setservInfo.add(servInf.Partner_Track__c);
            }
        }

        if(setservInfo !=null && !setservInfo.isempty()){
         
            List<Service_Information__c> listexstServInfo = [select name,id from service_information__C where Partner_Track__c in :setservInfo ];
                
            for(Service_Information__c servInf : (List<Service_Information__c>)listNew)
            { 
                if(listexstServInfo.size()>0){
                    system.debug('<<<<setservInfo '+listexstServInfo);
                    servInf.addError('Service information already exists for this partner. Please view or edit the existing record');
                }
            }
        }
    }
}