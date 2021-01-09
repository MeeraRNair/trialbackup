/***********************************************************
* Name          : Partner Request Utility
*  
* ---------------------------------------------------------
* Revision  Name            Date                Description
* 1.0                                           created

************************************************************/
public class PartnerOnboardingPRUtility {
    
    
    public static void sendConfirmationFlagSet(List<Partner_Request__ChangeEvent> listNewPRs){
        List<String> listPRName = new List<String>();
        List<Partner_Request__c> listPRsToUpdate = new List<Partner_Request__c>();
        try{
                for(Partner_Request__ChangeEvent prChange : listNewPRs){
                    if (prChange.ChangeEventHeader.getChangetype()  == 'CREATE') {
                        EventBus.ChangeEventHeader header = prChange.ChangeEventHeader;
                        System.debug('Received change event for ' + header.entityName +' for the ' + header.changeType + ' operation.'); 
                        
                        Map<String,Object> mapEventChanges = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(prChange));
                        system.debug('mapEventChanges*****'+mapEventChanges);
                        if(mapEventChanges.containsKey('RecordTypeId') && mapEventChanges.get('RecordTypeId') == '012700000005cfa' &&
                           mapEventChanges.containsKey('Status__c') && mapEventChanges.get('Status__c') == 'New'){
                               listPRName.add(prChange.Name);
                           }
                        // System.debug('listPRName::'+listPRName);
                        
                    }
                   
                }
                 if(listPRName.size() > 0){
                    for(Partner_Request__c pr: [SELECT Id,Name,Send_Confirmation_Mail__c FROM Partner_Request__c WHERE Name IN: listPRName]){
                    		pr.Send_Confirmation_Mail__c = true;
                        	listPRsToUpdate.add(pr);
                    } 
                    System.debug('listPRsToUpdate::'+listPRsToUpdate[0]);
                     if(listPRsToUpdate.size() > 0){
                         Database.SaveResult[] listSRPRList = Database.update(listPRsToUpdate,false);
               
                     }
                 
                 }
                     
                
            }
    	catch(Exception e){}
    
    }
}