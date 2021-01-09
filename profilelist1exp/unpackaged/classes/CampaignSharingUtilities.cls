/*
 * Author   : Jiji
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to CampaignShare.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10068     15.10       13-Oct-2014     Jiji            To create campaign share for partner users
 * 1.1      CR10068     15.10       13-Oct-2014     Jiji            To delete campaign share for partner users
 * 
 */

public class CampaignSharingUtilities {

	// v1.0
    public static void createCampaignShare(list<Opportunity> lstOpportunities, map<Id, Opportunity> mapOldOpportunities, TriggerHandler.TriggerEvent trigEvent) {
        set<Id> setChannelLeadIds = new set<Id>();
        set<Id> ownerIdset = new set<Id>();
        Map<Id, Opportunity> mapChannelOppIdOpp = new map<Id, Opportunity>();
        Map<Id, User> creatorIdtoUserInfoMap = new map<Id, User>();
        Map<String, Id> opptoCampShareMap = new map<String, Id>();
        Map<Id, Lead> clmap = new map<Id, Lead>();
        Map<Id, CampaignShare>  CampaignShareMap = new Map<Id, CampaignShare>();
        List<CampaignShare> cmSharetoInsertList = new List<CampaignShare> ();
        for(Opportunity newOpportunity : lstOpportunities) {
            if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT 
              && newOpportunity.Channel_Lead_Id__c != NULL) {
                setChannelLeadIds.add(newOpportunity.Channel_Lead_Id__c);
                mapChannelOppIdOpp.put(newOpportunity.Id, newOpportunity);
                ownerIdset.add(newOpportunity.ownerId);
            }
        }
        
        if(ownerIdset.size() > 0){
            for(User u : [Select Id, IsportalEnabled, UserType from User where Id IN :ownerIdset]){
                creatorIdtoUserInfoMap.put(u.Id, u);
            }
        }
        
        if(setChannelLeadIds.Size() > 0){
            for(Lead cl :[select Id, Campaign__c, Related_Opportunity__c, Source_Campaign_Id__c, 
                          R2C_source__c, Relationship_Lead__c, Segment_Lead__c, Account_Play__c 
                          from Lead where Id IN :setChannelLeadIds]){
                clmap.put(cl.Id, cl);
            }
        }   
        
        for(Opportunity opp :mapChannelOppIdOpp.Values()){        
            if(creatorIdtoUserInfoMap.get(opp.ownerId) != NULL && 
               creatorIdtoUserInfoMap.get(opp.ownerId).UserType == 'PowerPartner'
            ){
                Lead ld = new Lead();
                ld = clmap.get(opp.Channel_Lead_Id__c);
                if(ld.Campaign__c != NULL ){
                    opptoCampShareMap.put(ld.Campaign__c+':'+opp.Id, opp.Id);
                    CampaignShare cmShare = new CampaignShare();
                    cmShare.CampaignAccessLevel = 'Read';
                    cmShare.CampaignId = ld.Campaign__c;
                    cmShare.UserOrGroupId = opp.OwnerId;
                    //cmShare.UserOrGroupId = opp.CreatedById;
                    cmSharetoInsertList.add(cmShare);
                }
                if(ld.R2C_source__c != NULL ||
                   ld.Relationship_Lead__c != NULL ||
                   ld.Segment_Lead__c != NULL ||
                   ld.Account_Play__c != NULL
                ){
                    opptoCampShareMap.put(ld.Source_Campaign_Id__c+':'+opp.Id, opp.Id);
                    CampaignShare cmShare = new CampaignShare();
                    cmShare.CampaignAccessLevel = 'Read';
                    cmShare.CampaignId = ld.Source_Campaign_Id__c;
                    cmShare.UserOrGroupId = opp.OwnerId;
                    cmSharetoInsertList.add(cmShare);
                }
            }           
        }
        database.SaveResult[] insertResults;
        if(cmSharetoInsertList.Size() > 0){
            insertResults = database.insert(cmSharetoInsertList, false);
            List<String> errorCodeDelList = new List<String>();
            List<String> errorMessageDelList = new List<String>();
            List<Exception__c> listOfException = new List<Exception__c>();
            for(integer i = 0; i< insertResults.size();i++){       
                if(insertResults[i].isSuccess()!=true){
                    Exception__c exceptionVar = new Exception__c();        
                    exceptionVar.Object_type__c = 'CampaignShare';
                    exceptionVar.Object_ID__c = cmSharetoInsertList[i].Id;
                    exceptionVar.Operation__c = 'Insert';
                    exceptionVar.Notes__c = 'Share not created for Campaign with Id = '+cmSharetoInsertList[i].CampaignId;
                    exceptionVar.Process_Name__c = 'CMAP PCM Campaign Share Creation';
                    Database.Error [] errors = insertResults[i].getErrors();
                    errorCodeDelList.clear();
                    errorMessageDelList.clear();
                    // Cycle through the errors
                    for (Database.Error error :errors){
                        errorCodeDelList.add(''+error.getStatusCode());
                        errorMessageDelList.add(''+error.getMessage());
                    }            
                    exceptionVar.Error_Codes__c = StringUtils.joinStrings (errorCodeDelList, ',');
                    string errMsg = StringUtils.joinStrings (errorMessageDelList, ',');
                    if(errMsg.length() > 255) {                       
                        exceptionVar.Error_Messages__c =  errMsg.SubString(0,254);
                    }
                    else{
                        exceptionVar.Error_Messages__c =  errMsg;
                    }listOfException.add(exceptionVar);  
            
                } 
                    
            }
          	
            if(listOfException.size() > 0 ){
                insert listOfException;
            }
        }
    }
    
    // v1.1
    public static void deleteCampaignShare(list<Opportunity> lstOpportunities, map<Id, Opportunity> mapOldOpportunities, TriggerHandler.TriggerEvent trigEvent) {
        set<Id> setOppOwnerIds = new set<Id>();
        set<Id> setCampaignIds= new set<Id>();
        //Set<Id> ownerIdset = new set<Id>();
        Map<Id, User> creatorIdtoUserInfoMap = new map<Id, User>();
        Map<Id, Opportunity> mapChannelOppIdOpp = new map<Id, Opportunity>();
        Map<String, CampaignShare>  CampaignShareMap = new Map<String, CampaignShare>();
        List<CampaignShare> CampaignShareListtoDelete = new List<CampaignShare> ();
        for(Opportunity newOpportunity : lstOpportunities) {
            if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT 
                && newOpportunity.Channel_Lead_Id__c != NULL) {
        
                String s3;
                if(newOpportunity.Channel_Campaign__c != NULL ){
                    String s1 = newOpportunity.Channel_Campaign__c;
                    String s2 = s1.substringAfter('/');
                    s3 = s2.substringBefore('_');
                    setCampaignIds.add(s3);
                
                    if(newOpportunity.CampaignId != NULL && 
                       s3 != newOpportunity.CampaignId
                    ){
                        setCampaignIds.add(newOpportunity.CampaignId);
                    }
                }
                setOppOwnerIds.add(newOpportunity.CreatedById);
                mapChannelOppIdOpp.put(newOpportunity.Id, newOpportunity);
            }
        }
        if(setOppOwnerIds.Size() > 0){
            for(User u : [Select Id, IsportalEnabled, UserType from User where Id IN :setOppOwnerIds]){
                creatorIdtoUserInfoMap.put(u.Id, u);
            }
        }       
        if(setCampaignIds.size() > 0 ){
            for(CampaignShare cmShare : [select Id, UserOrGroupId, CampaignId from CampaignShare
                                        where CampaignId IN :setCampaignIds and UserOrGroupId IN :setOppOwnerIds]){
                string campId = cmShare.CampaignId;
                if(campId.length() > 15){
                    campId = campId.substring(0, 15);
                }
                else if(campId.length() == 15){
                    campId= cmShare.CampaignId;
                }
                String mapUniqureKeyString = cmShare.UserOrGroupId+':'+campId;
                CampaignShareMap.Put(mapUniqureKeyString, cmShare);
            }
        }
                
        for(Opportunity o : mapChannelOppIdOpp.Values()){
            String s1 = o.Channel_Campaign__c;
            String s2 = s1.substringAfter('/');
            String s3 = s2.substringBefore('_');
            if(s3.length() > 15){
                s3 =s3.substring(0, 15);
            }
            
            if(creatorIdtoUserInfoMap.get(o.CreatedById) != NULL &&
                creatorIdtoUserInfoMap.get(o.CreatedById).UserType == 'PowerPartner'){
                if(CampaignShareMap.get(o.CreatedById+':'+s3) != NULL){
                    CampaignShareListtoDelete.add(CampaignShareMap.get(o.CreatedById+':'+s3));
                }
                String s4 = o.CampaignId;
                if(s4.length() > 15){
                    s4 =s4.substring(0, 15);
                }
                if(CampaignShareMap.get(o.CreatedById+':'+s4) != NULL  
                   && s3 != s4
                   ){
                    CampaignShareListtoDelete.add(CampaignShareMap.get(o.CreatedById+':'+s4));
                }
            }
        }
        if(CampaignShareListtoDelete.Size() > 0){
            database.deleteResult[] deleteResults;
            deleteResults = database.delete(CampaignShareListtoDelete, false);
            system.debug('----5555555555----'+deleteResults);
        }
        //modify opp to update check box to false
    }

}