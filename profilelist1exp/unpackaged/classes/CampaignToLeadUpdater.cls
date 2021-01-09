/*
 * Author   : Ragu
 * Purpose  : To handle all explicit updates to the child objects of the Campaign.
 *        
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR 12491    16.12           21-Dec-2015     Ragu            LM3_13_4- Fix SOQL error in campaign update
 * 1.1      #213419     16.12           28-Jan-2016     Nagendra        Defect 213419:User cannot edit campaign 2.0: "Too many DML rows" error
 * 2.0      CR 12693    FY17-DCS-0303   02-Mar-2016     Gan             Used batch to process the lead update when changes in campaign field next_step__c or Supporting_Information__c   
 * 3.0      CR 15314    FY18-DCS-0203   06-Dec-2017     Ashok           Marketing LTO - Update campaign cancellation workflow with new status   
 * 4.0      CR 15314    FY18-DCS-0203   22-01-2018      Sazleen         UAT Fix - Lead Status should be updated to Cancelled - Campaign Inactive when Campaign is set to inactive when lead status is New
 * 5.0      CR 16957    FY20-DCS-0202   19 Jan 2019     Shue            DEFECT 6086015: If "Aborted" / "Cancelled" status in Campaign is chosen, all Leads WILL NOT be cancelled
 */

public class CampaignToLeadUpdater {
  

    // 2.0 rewrite this method, for reusability
    public static void updateLeadRecords(set<Id> setAbortedCampaignIds, set<Id> setNSUpdatedCampaignIds, set<Id> setActivatedCampaignIds, set<Id> setDeactivatedCampaignIds, 
            map<Id, Campaign> mapNewCampaigns) {
        
        Integer intMaxLeadCount = Integer.valueOf(System.Label.CampaignToLeadUpdater_MaxLeadCount);

        //exclude count for campaoign with field update 
        list<Lead> listLeads = [select Id, Status, Campaign__c, RecordTypeId
                from Lead where IsConverted = false and ((Campaign__c in :setAbortedCampaignIds and Status != 'Cancelled')
                or (Campaign__c in :setNSUpdatedCampaignIds)
                or (Campaign__c in :setActivatedCampaignIds and Status = 'Cancelled - Campaign Inactive')
                or (Campaign__c in :setDeactivatedCampaignIds and Status = 'New')) limit :intMaxLeadCount]; //4.0
                
        system.debug('######################## listLeads.size() : ' + listLeads.size() + ', intMaxLeadCount: ' + intMaxLeadCount + ',setNSUpdatedCampaignIds size: ' + setNSUpdatedCampaignIds.size());
        // 2.0 there are field changes call the batch directly
        if(!setNSUpdatedCampaignIds.isEmpty() || listLeads.size() == intMaxLeadCount) {
            Batch_CampaignToLeadUpdater batchCampaignToLeadUpdater = new Batch_CampaignToLeadUpdater();
            batchCampaignToLeadUpdater.setAbortedCampaignIds = setAbortedCampaignIds;
            batchCampaignToLeadUpdater.setNSUpdatedCampaignIds = setNSUpdatedCampaignIds;
            batchCampaignToLeadUpdater.setActivatedCampaignIds = setActivatedCampaignIds;
            batchCampaignToLeadUpdater.setDeactivatedCampaignIds = setDeactivatedCampaignIds;
            batchCampaignToLeadUpdater.mapNewCampaigns = mapNewCampaigns;
                
            database.executeBatch(batchCampaignToLeadUpdater, 200);
                
            system.debug('######################## Successfully call the Campaign to Lead Updater batch job');
        }
        else {
            processLeadRecords(setAbortedCampaignIds, setNSUpdatedCampaignIds, setActivatedCampaignIds, setDeactivatedCampaignIds, mapNewCampaigns, listLeads);
        }
    }  
    
    //2.0 new method created so that can call from batch instead of replicate the same code in both files
    public static void processLeadRecords(set<Id> setAbortedCampaignIds, set<Id> setNSUpdatedCampaignIds, set<Id> setActivatedCampaignIds, set<Id> setDeactivatedCampaignIds, 
            map<Id, Campaign> mapNewCampaigns, list<Lead> listLeadToProcess) {
        
        //Start V1.1 added condition mapLeads.size() < 8000
        if(listLeadToProcess != null && listLeadToProcess.size() > 0) {
          map<Id, Lead> mapLeadsForCancelling = new map<Id, Lead>();
          map<Id, Lead> mapLeadsForNSUpdate = new map<Id, Lead>();
          map<Id, Lead> mapLeadsForActivation = new map<Id, Lead>();
          map<Id, Lead> mapLeadsForDeactivation = new map<Id, Lead>();
          
          for(Lead leadIterator : listLeadToProcess) {
                
                if(setNSUpdatedCampaignIds.contains(leadIterator.Campaign__c)) {
                  mapLeadsForNSUpdate.put(leadIterator.Id, leadIterator);
                }
                
                //5.0 Start
                /*
                if(setAbortedCampaignIds.contains(leadIterator.Campaign__c)) {
                  mapLeadsForCancelling.put(leadIterator.Id, leadIterator);
                }
                */
                //5.0 End
                
                else if(setActivatedCampaignIds.contains(leadIterator.Campaign__c)) {
                  mapLeadsForActivation.put(leadIterator.Id, leadIterator);
                }
                //5.0 Start
                /*
                else if(setDeactivatedCampaignIds.contains(leadIterator.Campaign__c)) {
                  mapLeadsForDeactivation.put(leadIterator.Id, leadIterator);
                }
                */
                //5.0 End
              }
          
          //5.0 Start
          /*
          if(!mapLeadsForCancelling.isEmpty()) {
            cancelLeads(mapLeadsForCancelling);
          }
          */
          //5.0 End
          
          if(!mapLeadsForNSUpdate.isEmpty()) {
            copyCampaingInfos(mapLeadsForNSUpdate, mapNewCampaigns);
          }
          if(!mapLeadsForActivation.isEmpty()) {
            activateLeads(mapLeadsForActivation);
          }
          //5.0 Start
          /*
          if(!mapLeadsForDeactivation.isEmpty()) {
            deactivateLeads(mapLeadsForDeactivation);
          }
          */
          //5.0 End
          
          TriggerExecutionController.setSkipLeadTriggers(true);
          update listLeadToProcess;
          TriggerExecutionController.setSkipLeadTriggers(false);
          
          // Perform all necessary post Lead update logics explicilty since we are skipping the Lead trigger
          if(!mapLeadsForCancelling.isEmpty() || !mapLeadsForActivation.isEmpty() || !mapLeadsForDeactivation.isEmpty()) {
            mapLeadsForCancelling.putAll(mapLeadsForActivation);
            mapLeadsForCancelling.putAll(mapLeadsForDeactivation);
            CampaignMember2StatusUtils.recalculateCampaignMember2Status(mapLeadsForCancelling);
          }
        }//Start V1.1 
        
    }
    
    // v3.0 : Begin CR 11931 - Logic to Cancel leads when its Campaign is Aborted
    //5.0 Start
    /*
    public static void cancelLeads(map<Id, Lead> mapLeadsForCancelling) {
        for(Lead leadIterator : mapLeadsForCancelling.values()) {
        leadIterator.Status = 'Rejected by Marketing';//3.0
        leadIterator.Reason__c = 'Cancelled'; //3.0
        }
    }
    */
    //5.0 End
    // v3.0 : End CR 11931 - Logic to Cancel leads when its Campaign  is Aborted

    // v3.1 : Begin CR 11962 - Logic to populate campaign's Next Steps and Support Information to all of its leads
    public static void copyCampaingInfos(map<Id, Lead> mapLeadsForNSUpdate, map<Id, Campaign> mapCampaigns) {
        for(Lead leadIterator : mapLeadsForNSUpdate.values()) {
          Campaign campRecord = mapCampaigns.get(leadIterator.Campaign__c);
          if(campRecord != null) {
              leadIterator.Campaign_Next_Steps__c = campRecord.Next_Steps__c;
              leadIterator.Campaign_Support_Info__c = campRecord.Supporting_Information__c;
             
             }
        }
    }
    // v3.1 : End CR 11962 - Logic to populate campaign's Next Steps and Support Information to all of its leads
    
    public static void activateLeads(map<Id, Lead> mapLeadsForActivation) {
        for(Lead leadIterator : mapLeadsForActivation.values()) {
          leadIterator.Status = 'New'; //4.0
        }       
    }
    
    //5.0 Start
    /*
    public static void deactivateLeads(map<Id, Lead> mapLeadsForDeactivation) {
        for(Lead leadIterator : mapLeadsForDeactivation.values()) {
      leadIterator.Status = 'Cancelled - Campaign Inactive';
        }       
    }
    */
    //5.0 End

}