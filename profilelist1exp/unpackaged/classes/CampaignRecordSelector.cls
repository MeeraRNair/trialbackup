/*
 * Author   : Ragu
 * Purpose  : Centralize the record selection process for Campaign.
 *          Defines the methods which iterate and segregate the Campaign records for further use.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11480       16.07           15-May-2015     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      12693       FY17-DCS-0303   02-Mar-2016     Gan             Used batch to process the lead update when changes in campaign field next_step__c or Supporting_Information__c
 * 3.0                  FY20-DCE-0202   08-Jan-2018     Kokila          Lead 2.0 - Campaign Status enhancements - "Aborted" status renamed to "Cancelled" 
 */

public class CampaignRecordSelector extends RecordSelector {

    private TriggerHandler campaignTriggerHandler;
    
    //2.0
    public set<Id> setAbortedCampaignIds = new set<Id>();
    public set<Id> setNSUpdatedCampaignIds = new set<Id>();
    public set<Id> setActivatedCampaignIds = new set<Id>();
    public set<Id> setDeactivatedCampaignIds = new set<Id>();
    
    
    public CampaignRecordSelector(list<sObject> lstCampaigns, map<Id, sObject> mapOldCampaigns, TriggerHandler campaignTriggerHandler) {
        this.campaignTriggerHandler = campaignTriggerHandler;
        
        this.getRecords(lstCampaigns, mapOldCampaigns);
        
        if(lstCampaigns != null) {
            this.getRelatedRecords(lstCampaigns);
        }
        else if(mapOldCampaigns != null) {
            this.getRelatedRecords(mapOldCampaigns.values());
        }
        
        removeNulls();
    }
    
    protected override void getRecords(list<sObject> lstCampaigns, map<Id, sObject> mapOldCampaigns) {
        //2.0
        Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0');
        
        if(lstCampaigns != null) {
            for(Campaign newCampaign : (list<Campaign>)lstCampaigns) {
                Campaign oldCampaign;
                if(mapOldCampaigns != null && !mapOldCampaigns.isEmpty()) {
                    oldCampaign = (Campaign)mapOldCampaigns.get(newCampaign.Id);
                }
                
                //2.0
                if(newCampaign.RecordTypeId == campaign2RTId) {
                    if(oldCampaign != null) {
                        if(newCampaign.Next_Steps__c != oldCampaign.Next_Steps__c || newCampaign.Supporting_Information__c != oldCampaign.Supporting_Information__c) {
                            setNSUpdatedCampaignIds.add(newCampaign.Id);
                        }
                     
                        //v3.0 - Start
                        //if(newCampaign.Status == 'Aborted' && oldCampaign.Status != 'Aborted') {
                        if(newCampaign.Status == 'Cancelled' && oldCampaign.Status != 'Cancelled') { //v3.0 - End
                            setAbortedCampaignIds.add(newCampaign.Id);
                        }   
                        else if(newCampaign.IsActive != oldCampaign.IsActive) {
                            if(newCampaign.IsActive) {
                                setActivatedCampaignIds.add(newCampaign.Id);
                            }
                            else {
                                setDeactivatedCampaignIds.add(newCampaign.Id);
                            }
                        }
                    }
                }
        
            }
        }
        else if(mapOldCampaigns != null) { // Handling delete events
            for(Campaign accIterator : (list<Campaign>)mapOldCampaigns.values()) {
                
            }
        }
    }
    
    protected override void getRelatedRecords(list<sObject> lstCampaigns) {
        
    }
    
    // Remove nulls from the Set / List / Map.
    private void removeNulls() {
        
    }

}