/*
 * Author   : Gan
 * Purpose  : Centralize the record selection process for GDM Request.
 *          Defines the methods which iterate and segregate the GDM Request records for further use.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      14068		FY18-DCS-0502   14-Mar-2017     Gan            Created for implementing "Centralized by Org" trigger architecture - Best practices
 */

public class GDMRequestRecordSelector extends RecordSelector{
	private TriggerHandler gdmTrigHandler;
    public map<id, GDM_Request__c> mapBuddyAccessToUpdateComments = new map<id, GDM_Request__c>();
    public GDMRequestRecordSelector(list<sObject> listGDMRequest, map<Id, sObject> mapOldGDMRequest, TriggerHandler gdmReqTrigHandler) {
        this.gdmTrigHandler = gdmReqTrigHandler;
        
        this.getRecords(listGDMRequest, mapOldGDMRequest);
        
        if(listGDMRequest != null) {
            this.getRelatedRecords(listGDMRequest);
        }
        else if(mapOldGDMRequest != null) {
            this.getRelatedRecords(mapOldGDMRequest.values());
        }
    }
    
    protected override void getRecords(list<sObject> listGDMRequest, map<Id, sObject> mapOldGDMRequest) {
    	Id idBuddyAccessRT = StaticFactory.getRecordTypeIdByName('GDM_Request__c', 'Buddy Access');
        
        if(listGDMRequest != null) { 
            for(GDM_Request__c newGDMReq : (list<GDM_Request__c>)listGDMRequest) {
                GDM_Request__c oldGDMReq;
                if(mapOldGDMRequest != null && !mapOldGDMRequest.isEmpty()) {
                    oldGDMReq = (GDM_Request__c)mapOldGDMRequest.get(newGDMReq.Id);
                }
                
                if(newGDMReq.RecordTypeId == idBuddyAccessRT && newGDMReq.Buddy_Access_Status__c != oldGDMReq.Buddy_Access_Status__c
                   && (newGDMReq.Buddy_Access_Status__c == 'Approved and scheduled' || newGDMReq.Buddy_Access_Status__c == 'Rejected' )) {
                    mapBuddyAccessToUpdateComments.put(newGDMReq.id, newGDMReq);
                }
            }
        }
    }
               
    protected override void getRelatedRecords(list<sObject> listGDMRequest) {
    
    }
}