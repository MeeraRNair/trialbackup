/*
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities which are related to Campaign object. 
*          Please create separate classes and use it for complex logics.
*        
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      10084       16.03       19-Sep-2014     CJ              Campaign Field History Tracking.
* 2.0      11480       16.07       15-May-2015     Ragu            This logic is separated from afterInsertUpdateCampaignTrigger trigger and rewritten as part of trigger redesign.
* 3.0      11931       16.10       07-Sep-2015     Dipin Raju      Logic to Cancel leads when its Campaign 2.0 is Aborted.
* 3.1      11962       16.10       17-Sep-2015     Dipin Raju      Logic to populate campaign's Next Steps and Support Information to all of its leads
* 4.0	   12491	   16.12	   23-Dec-2015	   Ragu			   LM3_13_4- Fix SOQL error in campaign update
* 5.0      14545       FY18-0702   14-Jun-2017     Sajith          PCM Insert/Update for Campaign from Vistex with a partner related  
*/

public class CampaignUtilities {
    
    // v1.0, v2.0
    public static void fieldHistoryTrackingHelper(list<Campaign> lstNewCampaigns, map<Id, Campaign> mapOldCampaigns, TriggerHandler.TriggerEvent trigEvent) {
        list<Campaign_Field_History__c> campaignFieldHistory = new list<Campaign_Field_History__c>();
        
        // Check if any lookup field needs to be tracked for field changes
        if(CampaignHistoryTracking.CheckLookupRef() == true) {
            // Get reference object name and referenced record ids
            for(Campaign campaignIterator : lstNewCampaigns) {
                if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    CampaignHistoryTracking.GetReferenceObject(campaignIterator, null);
                }
                else {
                    CampaignHistoryTracking.GetReferenceObject(campaignIterator, mapOldCampaigns.get(campaignIterator.Id));
                }
            }
            
            // Do SOQL to get Name field of referenced record
            CampaignHistoryTracking.GetReferenceObjectData();
        }
        
        // Get reference object name and referenced record ids
        for(Campaign campaignIterator : lstNewCampaigns) {
            if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                campaignFieldHistory.addAll(CampaignHistoryTracking.CreateCampHistoryRec(campaignIterator, null));
            }
            else {
                campaignFieldHistory.addAll(CampaignHistoryTracking.CreateCampHistoryRec(campaignIterator, mapOldCampaigns.get(campaignIterator.Id)));
            }
        }
        
        if(!campaignFieldHistory.isEmpty()) {
            insert campaignFieldHistory;
        }
    }
    
    // v4.0 Start: Commented methods AbortedCampaign(), populateCampFields(), updateLeadStatus() - These are migrated to CampaignToLeadUpdater
    /*
// v3.0 : Begin CR 11931 - Logic to Cancel leads when its Campaign is Aborted
public static void AbortedCampaign(list<Campaign> lstNewCampaigns, map<Id, Campaign> mapOldCampaigns, TriggerHandler.TriggerEvent trigEvent) {
Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0');
Set<Id> cIds = new Set<id>();
for(Campaign c: lstNewCampaigns){
Campaign oldCamp = mapOldCampaigns.get(c.Id);
if(c.RecordtypeId==campaign2RTId && oldCamp.Status!='Aborted' && c.Status=='Aborted') {
cIds.add(c.Id);
}
}     
List<Lead> LeadsToUpdate = new List<Lead>();        
for(Lead l: [SELECT Id FROM Lead WHERE Status!='Cancelled' and Campaign__c IN :cIds]) {
l.Status='Cancelled';
LeadsToUpdate.add(l);
}
Update LeadsToUpdate;

} 
// v3.0 : End CR 11931 - Logic to Cancel leads when its Campaign  is Aborted

// v3.1 : Begin CR 11962 - Logic to populate campaign's Next Steps and Support Information to all of its leads
public static void populateCampFields(list<Campaign> lstNewCampaigns, map<Id, Campaign> mapOldCampaigns, TriggerHandler.TriggerEvent trigEvent) {

Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0');
Set<Id> CampIds = new Set<id>();
Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();

for(Campaign c: lstNewCampaigns){
Campaign oldCamp = mapOldCampaigns.get(c.Id);
if(c.RecordtypeId==campaign2RTId && (oldCamp.Next_Steps__c!=c.Next_Steps__c || oldCamp.Supporting_Information__c!=c.Supporting_Information__c)) {
CampIds.add(c.Id);
campaignMap.Put(c.Id, c);
}
}
List<Lead> LeadLists = [SELECT Id, Campaign_Next_Steps__c, Campaign_Support_Info__c, Campaign__c
FROM Lead 
WHERE Campaign__c IN :CampIds AND Status NOT IN ('Marketing Qualified Lead','Sales Qualified Lead')];

List<Lead> UpdatedLeadList = new List<Lead>();

for(Lead lds: LeadLists ){    
lds.Campaign_Next_Steps__c=campaignMap.get(lds.Campaign__c).Next_Steps__c;
lds.Campaign_Support_Info__c=campaignMap.get(lds.Campaign__c).Supporting_Information__c;

UpdatedLeadList.add(lds);
}

Update UpdatedLeadList;
} 
// v3.1 : End CR 11962 - Logic to populate campaign's Next Steps and Support Information to all of its leads

public static void updateLeadStatus(list<Campaign> lstNewCampaigns, map<Id, Campaign> mapOldCampaigns, TriggerHandler.TriggerEvent trigEvent)
{
Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0');
Set<Id> setCampaignIds = new Set<Id>();

for(Campaign objCamp : lstNewCampaigns)
{
if(objCamp.RecordtypeId == campaign2RTId && objCamp.IsActive != mapOldCampaigns.get(objCamp.Id).IsActive)
{
setCampaignIds.add(objCamp.Id);
}
}

if(!setCampaignIds.isEmpty())
{
List<Lead> lstlead = new List<Lead>();

for(Lead objLead : [SELECT Id, Campaign__r.IsActive, Campaign__c, Status FROM Lead WHERE Campaign__c IN : setCampaignIds AND (Status = 'Open' OR Status = 'Cancelled - Campaign Inactive')])
{
if(objLead.Campaign__r.IsActive && objLead.Status == 'Cancelled - Campaign Inactive')
{
objlead.Status = 'Open';
lstlead.add(objlead);
}
else if(!objLead.Campaign__r.IsActive && objLead.Status == 'Open')
{
objlead.Status = 'Cancelled - Campaign Inactive';
lstlead.add(objlead);
}
}

if(!lstlead.isEmpty())
{
update lstlead;
}
}       
}
*/
    // v4.0 End 
    // 5.0 Start
    //This Method will insert respective PartnerCampaignManagement record for the campaigns with valid 'MDF Partner ID'    
    public static void mapPartnerCampaignManagement(list<Campaign> lstNewCampaigns){
        list<Partner_Campaign_Management__c> lstPCM = new list<Partner_Campaign_Management__c>();
        list<Campaign> lstCampaignsToProcess = new list<Campaign>();
        set<String> strAffinityIdsFromMaSCot = new set<String>();
        map<string,Account> mapMDFAffinity = new map<string,Account>();
        //filter the campaigns for which Partner Campaign Management need to be inserted
        for(Campaign objCampaign:lstNewCampaigns){
            system.debug(Logginglevel.INFO,'@@@ List of input Campaigns :' +  objCampaign.ID +'   ' +objCampaign.Name);
            system.debug(Logginglevel.INFO,'@@@ MDF Partner ID  :' +  objCampaign.MDF_Partner_ID__c);
            if(objCampaign.MDF_Partner_ID__c !=null)
            {
                system.debug(Logginglevel.INFO,'@@@ This Campaign is getting processed  :' +  objCampaign.Id);
                //Collect the MDF Partner IDs to run a check against the salesforce accounts
                strAffinityIdsFromMaSCot.add(objCampaign.MDF_Partner_ID__c);
                //Collect the list of campaigns with MDF Partner IDs for further processing
                lstCampaignsToProcess.add(objCampaign);
            }
        }
        if(strAffinityIdsFromMaSCot.size()>0){
            //Query Account to find the valid affinity IDs matching the MDF Partner IDs received from vistex
            List<Account> lstAccount = [SELECT Account_ID__c FROM Account WHERE Account_ID__c in :strAffinityIdsFromMaSCot AND Type='Partner' AND RecordTypeID='012A0000000TR6YIAW'];
            system.debug(Logginglevel.INFO,'@@@ Matching Affinity IDs  :' +  lstAccount);
            //Copy the values to set for the ease of searching
            for(Account objAccount:lstAccount){
                system.debug(Logginglevel.INFO,'@@@ Matching Affinity IDs  :' +  objAccount.Account_ID__c);
                mapMDFAffinity.put(objAccount.Account_ID__c,objAccount);
            }
        }	
        for(Campaign objCampaign:lstCampaignsToProcess){
            //verify if the MDF Partner ID received is a valid Affinity ID in salesforce
            if(mapMDFAffinity.containsKey(objCampaign.MDF_Partner_ID__c)){
                //for valid affinity IDs create a new Partner Campaign Management record and add to the list to insert
                Partner_Campaign_Management__c ObjPCM = new Partner_Campaign_Management__c();
                ObjPCM.Campaign__c = objCampaign.Id;
                system.debug(Logginglevel.INFO,'@@@ Mapped Account ID to PCM  :' +  mapMDFAffinity.get(objCampaign.MDF_Partner_ID__c).Id);
                ObjPCM.Partner_Account__c=mapMDFAffinity.get(objCampaign.MDF_Partner_ID__c).Id;
                objPCM.Primary_Partner__c=true;
                lstPCM.add(ObjPCM);
            }
        }	
        if(lstPCM.size()>0){
            system.debug(Logginglevel.INFO,'@@@ List of PCM to be inserted  :' +  lstPCM);
            insert lstPCM;
        }
    }
    
    //This Method will insert respective PartnerCampaignManagement record for the campaigns with valid 'MDF Partner ID'    
    public static void mapPartnerCampaignManagement(list<Campaign> lstNewCampaigns, map<Id, Campaign> mapOldCampaigns){
        list<Partner_Campaign_Management__c> lstPCMtoCreate = new list<Partner_Campaign_Management__c>();
        list<Partner_Campaign_Management__c> lstPCMtoUpdate = new list<Partner_Campaign_Management__c>();
        list<Partner_Campaign_Management__c> lstPCMtoDelete = new list<Partner_Campaign_Management__c>();
        list<Campaign> lstCampaignsToProcess = new list<Campaign>();
        list<String> lstCampaignIdsToProcess = new list<String>();
        set<String> strAffinityIdsFromMaSCot = new set<String>();
        set<String> strOldAffinityIdsFromMaSCot = new set<String>();
        map<string,Account> mapMDFAffinity = new map<string,Account>();
        map<string,Partner_Campaign_Management__c> mapPCRCampaign = new map<string,Partner_Campaign_Management__c>();
        //filter the campaigns for which Partner Campaign Management need to be inserted
        for(Campaign objCampaign:lstNewCampaigns){
            system.debug(Logginglevel.INFO,'@@@ List of input Campaigns :' +  objCampaign.ID +'   ' +objCampaign.Name);
            system.debug(Logginglevel.INFO,'@@@ New MDF Partner ID  :' +  objCampaign.MDF_Partner_ID__c + ' Old : '+ mapOldCampaigns.get(objCampaign.Id).MDF_Partner_ID__c);
            if(objCampaign.MDF_Partner_ID__c != mapOldCampaigns.get(objCampaign.Id).MDF_Partner_ID__c)
            {
                system.debug(Logginglevel.INFO,'@@@ This Campaign is getting processed  :' +  objCampaign.Id);
                if(mapOldCampaigns.get(objCampaign.Id).MDF_Partner_ID__c!=null){
                    strOldAffinityIdsFromMaSCot.add(mapOldCampaigns.get(objCampaign.Id).MDF_Partner_ID__c);
                }
                //Collect the MDF Partner IDs to run a check against the salesforce accounts
                if(objCampaign.MDF_Partner_ID__c !=null){
                    strAffinityIdsFromMaSCot.add(objCampaign.MDF_Partner_ID__c);
                }
                //Collect the list of campaigns with MDF Partner IDs for further processing
                lstCampaignsToProcess.add(objCampaign);
            }
        }
        if(strAffinityIdsFromMaSCot.size()>0){
            //Query Account to find the valid affinity IDs matching the MDF Partner IDs received from vistex
            List<Account> lstAccount = [SELECT Account_ID__c FROM Account WHERE Account_ID__c in :strAffinityIdsFromMaSCot AND Type='Partner' AND RecordTypeID='012A0000000TR6YIAW'];
            system.debug(Logginglevel.INFO,'@@@ Matching Affinity IDs  :' +  lstAccount);
            //Copy the values to set for the ease of searching
            for(Account objAccount:lstAccount){
                system.debug(Logginglevel.INFO,'@@@ Matching Affinity IDs  :' +  objAccount.Account_ID__c);
                mapMDFAffinity.put(objAccount.Account_ID__c,objAccount);
            }
        }
        if (strOldAffinityIdsFromMaSCot.size()>0){
            //Query Partner_Campaign_Management to find the available PCM records for update
            list<Partner_Campaign_Management__c> lstPCMPotential= [SELECT Id,Campaign__c FROM Partner_Campaign_Management__c WHERE Affinity_Account_ID__c in :strOldAffinityIdsFromMaSCot AND Campaign__c in :lstCampaignsToProcess ];
            system.debug(Logginglevel.INFO,'@@@ Potential PCRs to be updated  :' +  lstPCMPotential);
            for(Partner_Campaign_Management__c objPCM:lstPCMPotential){
                system.debug('@@@ Campagins related to PCM :' + objPCM.Campaign__c);
                mapPCRCampaign.put(objPCM.Campaign__c,objPCM);
            }
        }	
        for(Campaign objCampaign:lstCampaignsToProcess){
            //Scenario 1 : Old MDF_Partner_ID is null and new MDF_Partner_ID got a value => Insert new PCM record if MDF_Partner_ID is valid
            if (objCampaign.MDF_Partner_ID__c != null &&  mapOldCampaigns.get(objCampaign.Id).MDF_Partner_ID__c ==null){
                system.debug(Logginglevel.INFO,'@@@ Scenario 1 :' +  objCampaign.Id + ' ' +objCampaign.Name);
                if(mapMDFAffinity.containsKey(objCampaign.MDF_Partner_ID__c) ){
                    system.debug(Logginglevel.INFO,'@@@ Scenario 1 : Valid MDF Partner ID');
                    Partner_Campaign_Management__c ObjPCM = new Partner_Campaign_Management__c();
                    ObjPCM.Campaign__c = objCampaign.Id;
                    system.debug(Logginglevel.INFO,'@@@ Mapped Account ID to PCM  :' +  mapMDFAffinity.get(objCampaign.MDF_Partner_ID__c).Id);
                    ObjPCM.Partner_Account__c=mapMDFAffinity.get(objCampaign.MDF_Partner_ID__c).Id;
                    objPCM.Primary_Partner__c=true;
                    lstPCMtoCreate.add(ObjPCM);
                }
                // If MDF_Partner_ID is not present in salesforce, then delete the PCM record which is associated with old MDF_Partner_ID
                else{
                    system.debug(Logginglevel.INFO,'@@@ Scenario 1 : Invalid MDF Partner ID');
                    Partner_Campaign_Management__c ObjPCM = new Partner_Campaign_Management__c();
                    if(mapPCRCampaign.containsKey(objCampaign.Id)){
                        ObjPCM.Id = mapPCRCampaign.get(objCampaign.Id).Id;
                    }
                    //If there exists a PCM record with old MDF_Partner_ID value, then delete 
                    if(ObjPCM.Id!=null){
                        lstPCMtoDelete.add(ObjPCM);
                    }
                }
            }
            //Scenario 2 : Old MDF_Partner_ID is not null and new MDF_Partner_ID got a value not equal to Old value=> Update the existing PCM record if MDF_Partner_ID is valid
            else if (objCampaign.MDF_Partner_ID__c != null &&  mapOldCampaigns.get(objCampaign.Id).MDF_Partner_ID__c !=null){
                system.debug(Logginglevel.INFO,'@@@ Scenario 2 :' +  objCampaign.Id + ' ' +objCampaign.Name);
                if(mapMDFAffinity.containsKey(objCampaign.MDF_Partner_ID__c) ){
                    system.debug(Logginglevel.INFO,'@@@ Scenario 2 : Valid MDF Partner ID');
                    //for valid affinity IDs update the existing Partner Campaign Management record and add to the list to update
                    Partner_Campaign_Management__c ObjPCM = new Partner_Campaign_Management__c();
                    system.debug(Logginglevel.INFO,'@@@ Mapped Account ID to PCM  :' +  mapMDFAffinity.get(objCampaign.MDF_Partner_ID__c).Id);
                    if(mapPCRCampaign.containsKey(objCampaign.Id)){
                        system.debug(Logginglevel.INFO,'@@@ Existing PCM record found for Update  :' +  mapMDFAffinity.get(objCampaign.MDF_Partner_ID__c).Id);
                        ObjPCM.Id = mapPCRCampaign.get(objCampaign.Id).Id;
                        ObjPCM.Partner_Account__c=mapMDFAffinity.get(objCampaign.MDF_Partner_ID__c).Id;
                        lstPCMtoUpdate.add(ObjPCM);
                    }
                    else{
                        system.debug(Logginglevel.INFO,'@@@ PCM record does not exist with old MDF_Partner_ID, Create a new one  :');
                        ObjPCM.Campaign__c=objCampaign.Id;
                        ObjPCM.Partner_Account__c=mapMDFAffinity.get(objCampaign.MDF_Partner_ID__c).Id;
                        objPCM.Primary_Partner__c=true;
                        lstPCMtoCreate.add(ObjPCM);
                    }                   
                }
                else{
                    system.debug(Logginglevel.INFO,'@@@ Scenario 2 : Invalid MDF Partner ID');
                    Partner_Campaign_Management__c ObjPCM = new Partner_Campaign_Management__c();
                    if(mapPCRCampaign.containsKey(objCampaign.Id)){
                        ObjPCM.Id = mapPCRCampaign.get(objCampaign.Id).Id;
                    }
                    else{
                        
                        system.debug(Logginglevel.INFO,'@@@ Scenario 2 : Invalid MDF Partner ID : No records found to delete');
                    }
                    //If there exists a PCM record with old MDF_Partner_ID value, then delete 
                    if(ObjPCM.Id!=null){
                        lstPCMtoDelete.add(ObjPCM);
                    }
                }
                
            }
            //Scenario 3 : Old MDF_Partner_ID is not null and new MDF_Partner_ID is null=> Delete the existing PCM record if exists
            else {
                system.debug(Logginglevel.INFO,'@@@ Scenario 3 :' +  objCampaign.Id + ' ' +objCampaign.Name);
                Partner_Campaign_Management__c ObjPCM = new Partner_Campaign_Management__c();
                if(mapPCRCampaign.containsKey(objCampaign.Id)){
                    ObjPCM.Id = mapPCRCampaign.get(objCampaign.Id).Id;
                }
                //If there exists a PCM record with old MDF_Partner_ID value, then delete 
                if(ObjPCM.Id!=null){
                    system.debug(Logginglevel.INFO,'@@@ Scenario 3 : Valid PCM record to delete');
                    lstPCMtoDelete.add(ObjPCM);
                }
            }            
        }	
        if(lstPCMtoCreate.size()>0){
            system.debug(Logginglevel.INFO,'@@@ List of PCM to be inserted  :' +  lstPCMtoCreate);
            insert lstPCMtoCreate;
        }
        if(lstPCMtoUpdate.size()>0){
            system.debug(Logginglevel.INFO,'@@@ List of PCM to be updated  :' +  lstPCMtoUpdate);
            database.update(lstPCMtoUpdate,false);
        }
        if(lstPCMtoDelete.size()>0){
            system.debug(Logginglevel.INFO,'@@@ List of PCM to be deleted  :' +  lstPCMtoDelete);
            delete lstPCMtoDelete;
        }
        
    }
    //5.0 End
}