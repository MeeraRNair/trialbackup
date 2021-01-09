public class ViewMyEligiblePartnerTracksCtrl {
    
    public Id contactId;
    public Contact conObj;
    public list<Partner_Track__c> listtotalPT{get;set;}
    
    public ViewMyEligiblePartnerTracksCtrl(){
        contactId = [SELECT Id,contactId FROM User WHERE Id =: UserInfo.getUserId()].contactId;
    If(contactID!=null){
          conObj = [SELECT id,EligibleTracks__c FROM Contact WHERE id = :contactID];
        } 
        List<String> listeligibleTracksId = new List<String>();
        if(conObj!=null){
            if(conObj.EligibleTracks__c != null){
                List<String> listeligibleTracksIds = conObj.EligibleTracks__c.split(';');
                
                system.debug('listeligibleTracksIds '+listeligibleTracksIds);
                for(String stregTrackId: listeligibleTracksIds){
                    listeligibleTracksId.add(stregTrackId);    
                } 
            }       
        }
        
        if(listeligibleTracksId !=null){
           listtotalPT = [SELECT Id,Track_Name__c,Primary_Sales_Motion_Affinity_ID__c FROM Partner_Track__c WHERE Id IN: listeligibleTracksId];
        } 
    }

}