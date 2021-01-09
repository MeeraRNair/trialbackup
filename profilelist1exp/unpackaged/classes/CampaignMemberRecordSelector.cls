/*
 * Author   : Ragu
 * Purpose  : Centralize the record selection process for CampaignMember.
 *          Defines the methods which iterate and segregate the CampaignMember records for further use.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0		11555		16.07		28-May-2015		Ragu			Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 
 * 
 */

public class CampaignMemberRecordSelector extends RecordSelector {

	private TriggerHandler cmTriggerHandler;
	
	public list<CampaignMember> lstCampaignMembers2 = new list<CampaignMember>();
	
	public set<Id> setCampaignIds = new set<Id>();
	public map<Id, Campaign> mapCampaigns = new map<Id, Campaign>();
	
	public set<Id> setLeadIds = new set<Id>();
	public map<Id, Lead> mapLeads = new map<Id, Lead>();
	
	public CampaignMemberRecordSelector(list<sObject> lstCampaignMembers, map<Id, sObject> mapOldCampaignMembers, TriggerHandler cmTriggerHandler) {
        this.cmTriggerHandler = cmTriggerHandler;
        
        this.getRecords(lstCampaignMembers, mapOldCampaignMembers);
		
		if(lstCampaignMembers != null) {
            this.getRelatedRecords(lstCampaignMembers);
        }
        else if(mapOldCampaignMembers != null) {
            this.getRelatedRecords(mapOldCampaignMembers.values());
        }
    }
    
	protected override void getRecords(list<sObject> lstCampaignMembers, map<Id, sObject> mapOldCampaignMembers) {
		if(lstCampaignMembers != null) {
			Id CM2RTId = StaticFactory.getRecordTypeIdByNameDESC('CampaignMember', 'Campaign Member 2.0');
            for(CampaignMember newCampaignMember : (list<CampaignMember>)lstCampaignMembers) {
            	CampaignMember oldCampaignMember;
                if(mapOldCampaignMembers != null && !mapOldCampaignMembers.isEmpty()) {
                    oldCampaignMember = (CampaignMember)mapOldCampaignMembers.get(newCampaignMember.Id);
                }
	            
	            setCampaignIds.add(newCampaignMember.CampaignId);
	            setLeadIds.add(newCampaignMember.LeadId);
	            
	            if(newCampaignMember.RecordTypeId == CM2RTId) {
	            	lstCampaignMembers2.add(newCampaignMember);
	            }
	            
            }
        }
        else if(mapOldCampaignMembers != null) { // Handling delete events
            for(CampaignMember cmIterator : (list<CampaignMember>)mapOldCampaignMembers.values()) {
				
            }
        }
        removeNulls();
	}
	
    protected override void getRelatedRecords(list<sObject> lstCampaignMembers) {
    	// To get base fields which needs to be queried
    	map<String, Campaign_Member_Field_Mapping__c> mapCMFieldMappings = Campaign_Member_Field_Mapping__c.getAll();
    	
    	if(!setCampaignIds.isEmpty()) {
    		// Below initialization of setCampaignFields defines the base fields for CM2, you can add your own fields to the setCampaignFields right after the below line.
    		set<String> setCampaignFields = CampaignMember2CreationUtils.getCampaignFields(mapCMFieldMappings);
    		
			String strCampaignQuery = QueryUtils.formQuery('Campaign', setCampaignFields) + ' where Id in :setCampaignIds';
			for(Campaign campaignIterator : Database.query(strCampaignQuery)) {
				mapCampaigns.put(campaignIterator.Id, campaignIterator);
			}
    	}
    	if(!setLeadIds.isEmpty()) {
    		// Below initialization of setLeadFields defines the base fields for CM2, you can add your own fields to the setLeadFields right after the below line.
    		set<String> setLeadFields = CampaignMember2CreationUtils.getLeadFields(mapCMFieldMappings);
    		setLeadFields.addAll(new set<String>{'RecordTypeId', 'Status', 'Reason__c'});
    		
			String strLeadQuery = QueryUtils.formQuery('Lead', setLeadFields) + ' where Id in :setLeadIds';
			for(Lead leadIterator : Database.query(strLeadQuery)) {
				mapLeads.put(leadIterator.Id, leadIterator);
			}
    	}
    }
    
    // Remove nulls from the Set / List / Map.
    private void removeNulls() {
        setCampaignIds.remove(null);
        setLeadIds.remove(null);
    }

}