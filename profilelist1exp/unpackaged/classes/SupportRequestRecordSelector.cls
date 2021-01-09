/*
 * Author   : Sarbjeet
 * Purpose  : Centralize the record selection process for Support Request.
 *             Defines the methods which iterate and segregate the GDM Request records for further use.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      7216521     FY20-0102      18-Nov-2019       Sarbjeet     Created for implementing "Centralized by Org" trigger architecture - Best practices
 */

public class SupportRequestRecordSelector extends RecordSelector{
    
    private TriggerHandler supportRequestTrigHandler;
    
    public Map<Id, OpportunityTeamMember> mapOppTeamMembers = new Map<Id, OpportunityTeamMember>();
    
    public SupportRequestRecordSelector(list<sObject> listSupportRequest, map<Id, sObject> mapOldSupportRequest, TriggerHandler supportReqTrigHandler) {
        this.supportRequestTrigHandler = supportReqTrigHandler;
        
        this.getRecords(listSupportRequest, mapOldSupportRequest);
        
        if(listSupportRequest != null) {
            this.getRelatedRecords(listSupportRequest);
        }
        else if(mapOldSupportRequest != null) {
            this.getRelatedRecords(mapOldSupportRequest.values());
        }
    }
    
    protected override void getRecords(list<sObject> listSupportRequest, map<Id, sObject> mapOldGDMRequest) {
      
    }
               
    protected override void getRelatedRecords(list<sObject> listSupportRequest) {
        
        set<Id> setOppIds = new set<Id>();
        
        for(Support_Request__c objSupportRequest : (list<Support_Request__c>)listSupportRequest){
            setOppIds.add(objSupportRequest.Opportunity__c);
        }
        
        
        for(OpportunityTeamMember objOppTeamMember:[SELECT OpportunityId,Id,user.email,TeamMemberRole,lastmodifieddate
                                                FROM OpportunityTeamMember 
                                                WHERE opportunityId IN :setOppIds
                                                ORDER BY OpportunityId,lastmodifieddate DESC]){
                                                
            if(!mapOppTeamMembers.containsKey(objOppTeamMember.Id)){
                mapOppTeamMembers.put(objOppTeamMember.Id,objOppTeamMember);
            }
        }       

        
        
    }
}