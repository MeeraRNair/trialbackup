/*
 * Author   : Nagendra
 * Purpose  : Too many DML rows" error.
 *        
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      #213419     16.12           28-Jan-2016     Nagendra        Defect 213419:User cannot edit campaign 2.0: "Too many DML rows" error
 * 2.0      12693       FY17-DCS-0303   02-Mar-2016     Gan             Refactor: Used batch to process the lead update when changes in campaign field next_step__c or Supporting_Information__c          
 */

global class Batch_CampaignToLeadUpdater implements Database.Batchable<sObject> {
    
    //2.0 set to public
    public set<Id> setAbortedCampaignIds = new set<Id>();
    public set<Id> setNSUpdatedCampaignIds = new set<Id>();
    public set<Id> setActivatedCampaignIds = new set<Id>();
    public set<Id> setDeactivatedCampaignIds = new set<Id>();
    public map<Id, Campaign> mapNewCampaigns = new map<Id, Campaign>();
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
       return DataBase.getQueryLocator([select Id, Status, Campaign__c, RecordTypeId
                    from Lead where IsConverted = false and ((Campaign__c in :setAbortedCampaignIds and Status != 'Cancelled')
                      or (Campaign__c in :setNSUpdatedCampaignIds)
                      or (Campaign__c in :setActivatedCampaignIds and Status = 'Cancelled - Campaign Inactive')
                      or (Campaign__c in :setDeactivatedCampaignIds and Status = 'Open'))]);
            
    }
    
    global void execute(Database.BatchableContext BC, list<sObject> lstLeads) {
                  
        //2.0 reuse the method
        CampaignToLeadUpdater.processLeadRecords(setAbortedCampaignIds, setNSUpdatedCampaignIds, setActivatedCampaignIds, setDeactivatedCampaignIds, mapNewCampaigns, lstLeads);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}