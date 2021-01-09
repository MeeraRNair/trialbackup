public class PartnerAccessContactTriggerHandlerBU implements BeforeUpdate{
    
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
    
        //Sneha:check if Audit track is the subset of Eligible Tracks
        ContactTriggerHelper.updateAuditTracks(Trigger.new, (map<Id, Contact>)Trigger.oldMap);
    }

}