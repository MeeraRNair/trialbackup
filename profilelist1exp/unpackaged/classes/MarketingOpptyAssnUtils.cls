/***********************************************************
* Name      : MarketingOpptyAssnUtils 
* Description  : Helper class for associating existing Oppoerunity to Relationship Lead and Sales Play
* ---------------------------------------------------------
* Revision      Name        Date            Description
* 1.0           Meera       17.09.2009      CR #1872 & CR #1875 Opportunity Conversion Process 
* 2.0           Ray         21.12.2010      CR2596 - Primary Campaign Source checkbox
* 3.0           MenMee      03.08.2011      REL12.10 CR6507 Add Opportunity Contact Role when associate RL to an Opportunity
* 4.0           Jessie      15.11.2011      R13.1 Replace Solution ID of opportunity (standard/runrate markerting) associated by RL
* 4.1           Emily       23-Jul-2013     CR8469 - Lattice to SFDC - added new parameter to convertRelnshipLead_AccountPlayToOppty, convertRelnshipLead_AccountPlayToOpptyWithPrimary and updateRelnshipLead_AccountPlayStatus
* 5.0           Meghana     15.08.2013      R14.10 - CR 8577 - new Channel oppty record type should have same functionality as Standard oppty
************************************************************/

public class MarketingOpptyAssnUtils {

	/* 
	This revision history is only applicable to the below associateWithRelationshipLeadAndAccountPlay()
	
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0                                 01-Sep-2009     Raymond         Added code to update Lead Gen and Sales Play status. For Marketing Automation
    2.0         CR2136                  17-Dec-2009     Raymond         Added code to handle Small Opportunity created
    3.0                                 19-Jan-2010                     Rename Small Opportunity to Run Rate Marketing
    4.0         CR5537                  21-Dec-2010                     Account Play conversion for APOS record type
    5.0         CR7198                  22-May-2012                     To create Opportunity Account Play Association when Lattice Play does not exist in SFDC
    6.0         CR7306                  15-Aug-2012     Jagadeesan      Update the status of AP or RL 'Accepted - Completed Follow-Up' after opportunity being created
    7.0         CR8469                  23-Jul-2013                     Lattice to SFDC - added new parameter to convertRelnshipLead_AccountPlayToOppty
    8.0         CR10496     15.10       22-Sep-2014     Ragu            This logic is separated from opportunityTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void associateWithRelationshipLeadAndAccountPlay(list<Opportunity> lstOpportunities) {
        if(lstOpportunities != null && !lstOpportunities.isEmpty()) {
            try {
                // v2.0
                map<String, String> mapRunRateMarketingOpps = new map<String, String>();
                map<String, String> mapAPOSOpps = new map<String, String>();
                map<String, String> mapSMBOpps = new map<String, String>();
                map<String, String> mapOpportunities = new map<String, String>();
                set<String> setLatticePlayOppIds = new set<String>();
                
                Id runrateMarketingRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Run Rate Marketing');
                Id aposRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'APOS');
                Id smbRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'SMB Opportunity');
                
                list<Opportunity_Account_Play_Association__c> lstOppAPAssociations = new list<Opportunity_Account_Play_Association__c>();
                for(Opportunity oppIterator : lstOpportunities) {
                    if(oppIterator.Marketing_Created_Opportunity__c == true) {
                        if(oppIterator.Source_Id__c != null) {
                            // v2.0 - Modifed to break into two
                            if(oppIterator.RecordTypeId == runrateMarketingRTId) {
                                mapRunRateMarketingOpps.put(oppIterator.Id, oppIterator.Source_Id__c);
                            }
                            else if(oppIterator.RecordTypeId == aposRTId) {
                                // v4.0
                                mapAPOSOpps.put(oppIterator.Id, oppIterator.Source_Id__c);
                            } 
                            else if(oppIterator.RecordTypeId == smbRTId) {
                                // v6.0
                                mapSMBOpps.put(oppIterator.Id, oppIterator.Source_Id__c);   
                            } 
                            else {
                                // Additional else loop to chk APOS record type
                                mapOpportunities.put(oppIterator.Id, oppIterator.Source_Id__c);
                            } 
                        }
                        else if(oppIterator.Lattice_Source_Id__c != null && oppIterator.Lattice_PreLead_External_Id__c != null) {
                            // v7.0
                            if(oppIterator.RecordTypeId == runrateMarketingRTId) {
                                mapRunRateMarketingOpps.put(oppIterator.Id, oppIterator.Lattice_Source_Id__c);
                            }
                            else if(oppIterator.RecordTypeId == smbRTId) {
                                mapSMBOpps.put(oppIterator.Id, oppIterator.Lattice_Source_Id__c);   
                            }
                            else {
                                mapOpportunities.put(oppIterator.Id, oppIterator.Lattice_Source_Id__c);
                            }
                            setLatticePlayOppIds.add(oppIterator.Id);
                        } 
                        else if(oppIterator.Lattice_Source_Id__c == null && oppIterator.Lattice_PreLead_External_Id__c != null) {
                            // v4.0
                            Opportunity_Account_Play_Association__c oppAccPlayAssociation = new Opportunity_Account_Play_Association__c();
                            oppAccPlayAssociation.Opportunity__c = oppIterator.Id;
                            oppAccPlayAssociation.preLead_External_Id__c = oppIterator.Lattice_PreLead_External_Id__c;
                            lstOppAPAssociations.add(oppAccPlayAssociation); 
                        }
                    }
                }
                
                // v5.0
                if(!lstOppAPAssociations.isEmpty()) {
                    Database.insert(lstOppAPAssociations);
                }
                
                // v2.0
                if(!mapRunRateMarketingOpps.isEmpty()) {
                    MarketingOpptyAssnUtils.convertRelnshipLead_AccountPlayToOppty(mapRunRateMarketingOpps, null, 'Run Rate Opportunity', setLatticePlayOppIds);
                }
                
                // v4.0
                if(!mapAPOSOpps.isEmpty()) {
                    MarketingOpptyAssnUtils.convertRelnshipLead_AccountPlayToOppty(mapAPOSOpps, null, 'APOS Opportunity', setLatticePlayOppIds);
                }
                
                // v6.0
                if(!mapSMBOpps.isEmpty()) {  
                    MarketingOpptyAssnUtils.convertRelnshipLead_AccountPlayToOppty(mapSMBOpps, null, 'SMB Opportunity', setLatticePlayOppIds);  
                }
                
                if(!mapOpportunities.isEmpty()) {
                    MarketingOpptyAssnUtils.convertRelnshipLead_AccountPlayToOppty(mapOpportunities, null, 'New Opportunity', setLatticePlayOppIds);
                }
            }
            catch(Exception e) {
                emailUtils.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
            }
        }
    }

    //Method getting called from opportunity trigger and VFCntrlr_MarketingExistOppAssociation  
    public static void convertRelnshipLead_AccountPlayToOppty(Map<String, String> opptyToObjMap, Map<String, String> opptyToCampiagnMap, String opptyStatValue, set<String> setLatticePlayOppIds){
        //method call to update Relationship Lead/Account Play status
        updateRelnshipLead_AccountPlayStatus(opptyToObjMap, opptyStatValue, setLatticePlayOppIds);
        //method call to insert opportunity campaign influence
        insertCampaignInfluence(opptyToCampiagnMap);
    }


    //2.0
    //Method getting called from opportunity trigger and VFCntrlr_MarketingExistOppAssociation  
   /* public static void convertRelnshipLead_AccountPlayToOpptyWithPrimary(Map<String, String> opptyToObjMap, Map<String, String> opptyToCampiagnMap, String opptyStatValue, Set<Id> opptyWithPrimarySet, set<String> setLatticePlayOppIds){
        //method call to update Relationship Lead/Account Play status
        updateRelnshipLead_AccountPlayStatus(opptyToObjMap, opptyStatValue, setLatticePlayOppIds);
        //method call to insert opportunity campaign influence
        insertCampaignInfluence(opptyToCampiagnMap, opptyWithPrimarySet);
    }*/
    
    //method to update Relationship Lead/Account Play status
    public static void updateRelnshipLead_AccountPlayStatus(Map<String, String> opptyToObjMap, String opptyStatValue, set<String> setLatticePlayOppIds){
        final string relanshipLeadPrefix = Relationship_Lead__c.sObjectType.getDescribe().getKeyPrefix();
        final string accountPlayPrefix = Account_Play__c.sObjectType.getDescribe().getKeyPrefix();

        List<Relationship_Lead__c> relanshipLeadToUpdateList = new List<Relationship_Lead__c>();
        List<Account_Play__c> accountPlayToUpdateList = new List<Account_Play__c>();        
        Map<String, String> oppIdToObjIdMap = new Map<String, String>();    //Rev 3.0
        
        String objId;
        try{
            for(String oppId : opptyToObjMap.keySet()){         
                objId = opptyToObjMap.get(oppId);
                if(objId.startsWith(relanshipLeadPrefix)){              
                    relanshipLeadToUpdateList.add(new Relationship_Lead__c(
                                                          Id=objId, 
                                                          Opportunity_Status__c=opptyStatValue,
                                                          Status__c = 'Accepted - Completed Follow-Up',
                                                          Opportunity_Created__c = true,
                                                          Opportunity__c = oppId));
                }
                else if(objId.startsWith(accountPlayPrefix)){
                    //4.1
                    if(setLatticePlayOppIds.contains(oppId)) {
                        accountPlayToUpdateList.add(new Account_Play__c(
                                                          Id=objId, 
                                                          Opportunity_Status__c=opptyStatValue,
                                                          Opportunity_Created__c = true,
                                                          Opportunity__c = oppId));
                    }
                    else {
                        accountPlayToUpdateList.add(new Account_Play__c(
                                                          Id=objId, 
                                                          Opportunity_Status__c=opptyStatValue,
                                                          Status__c = 'Accepted - Completed Follow-Up',
                                                          Opportunity_Created__c = true,
                                                          Opportunity__c = oppId));
                    }
                }
            }

            if(relanshipLeadToUpdateList.size()>0){             
                update relanshipLeadToUpdateList;
            }
            if(accountPlayToUpdateList.size()>0){
                update accountPlayToUpdateList;
            }
            
        }catch(Exception e){              
            system.debug('##MN [MarketingOpptyAssnUtils:updateRelnshipLead_AccountPlayStatus] Caught APEX exception ' + e.getMessage());
            emailUtils.sendSupportEmail('[MarketingOpptyAssnUtils:updateRelnshipLead_AccountPlayStatus] '+e.getMessage(), dellConfig.errorEmail);                     
        }//end of catch
    }

    //Method to insert Campaign Influence for LeadGen/SalesPlay
    public static void insertCampaignInfluence(Map<String, String> opptyToCampaignMap){
        insertCampaignInfluence(opptyToCampaignMap, null);
    }
    
    
    //Method to insert Campaign Influence for LeadGen/SalesPlay
    public static void insertCampaignInfluence(Map<String, String> opptyToCampaignMap,Set<Id> opptyWithPrimarySet){
        
        //Rev4.0 - start
        String standard_RecordType = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true); 
        String runrate_marketing_RecordType = IdLookupUtils.getRecordTypeId('Run Rate Marketing', 'Opportunity', true); 
        String smb_RecordType = IdLookupUtils.getRecordTypeId('SMB Opportunity', 'Opportunity', true); 
        //CR8577
        String channel_RecordType = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true); 
             
        //Rev4.0 - end
        System.debug('#### come in insertCampaignInfluence');
        
        Map<String,String> opptyToPrimaryCampaignMap = new Map<String,String>();
        List<Opportunity> oppListToUpdate = new List<Opportunity>();     
        try{
            for(Opportunity opp : [SELECT Id, Name, campaignid
                             FROM Opportunity
                             WHERE Id IN :opptyToCampaignMap.keySet()]){
                if(opp.CampaignId != null){
                    opptyToPrimaryCampaignMap.put(opp.id, opp.CampaignId);
                }
                System.debug('#### opptyToCampaignMap.get(opp.id): '+opptyToCampaignMap.get(opp.id));
                opp.CampaignId = opptyToCampaignMap.get(opp.id);
                
                //Rev4.0 - start
                if(StringUtils.equalsIgnoreCase(opp.RecordTypeId, standard_RecordType)|| StringUtils.equalsIgnoreCase(opp.RecordTypeId, runrate_marketing_RecordType)
                    || StringUtils.equalsIgnoreCase(opp.RecordTypeId, smb_RecordType)
                    || StringUtils.equalsIgnoreCase(opp.RecordTypeId, channel_RecordType))
                    opp.Solution_ID__c = ApexPages.currentPage().getParameters().get('solutionid'); 
                //Rev4.0 - end
                
                oppListToUpdate.add(opp);
            }
            update oppListToUpdate;
            oppListToUpdate.clear();
            for(String oppid : opptyToCampaignMap.keySet()){
                
                //2.0
                if(opptyWithPrimarySet == null || !opptyWithPrimarySet.contains(oppid)) {
                    Opportunity opp = new Opportunity(id =oppid ,campaignid = opptyToPrimaryCampaignMap.get(oppid));
                    oppListToUpdate.add(opp);
                } 
            }
            
            update oppListToUpdate;
        }catch(Exception e){              
        system.debug('##MN Caught APEX exception: ' + e.getMessage() + ' [Code: MarketingOpptyAssnUtils.insertCampaignInfluence()]');
        emailUtils.sendSupportEmail(e.getMessage()+' [Code: MarketingOpptyAssnUtils.insertCampaignInfluence()]', dellConfig.errorEmail);                     
        }//end of catch
    }
    
    //Rev 3.0
    //Method to insert Opportunity Contact Role
    /*public static void insertOpportunityContactRole(Map<Id, List<Id>> oppIdToConIdMap) {        
        List<OpportunityContactRole> newOCRList = new List<OpportunityContactRole>();
        Map<Id, String> conIdToDCRMap = new Map<Id, String>();      
        Map<Id, Set<Id>> oppIdToExistingOCRMap = new Map<Id, Set<Id>> ();
        Set<Id> primaryOppCRIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<String, String> conDMRToOppCRMap = new Map<String, String> {
                                                    'Power Sponsor / Decision Maker' => 'Power Sponsor / Decision Maker',
                                                    'Sponsor/ Champion' => 'Sponsor / Champion',
                                                    'Influencer' => 'Influencer',
                                                    'Business User' => 'Business User',
                                                    'Evaluator' => 'Evaluator',
                                                    'Purchasing / Procurement' => 'Purchasing/Procurement',
                                                    'Financial Buyer' => 'Financial Buyer',
                                                    'Operational Buyer' => 'Operational Buyer',
                                                    'Legal Approver' => 'Legal Approver',
                                                    'Unknown' => 'Unknown'
                                                };
        
        for (String oppId : oppIdToConIdMap.keySet()) {
            for (String conId : oppIdToConIdMap.get(oppId)) {
                contactIdSet.add(conId);
            }
        }
        
        for(Contact con: [SELECT Id, Decision_Making_Role__c FROM Contact WHERE Id in :contactIdSet]) {
            String oppConRole = conDMRToOppCRMap.get(con.Decision_Making_Role__c);
            conIdToDCRMap.put(con.Id, (oppConRole != null? oppConRole:'Unknown'));          
        }
                
        //Get Primary Opportunity Contact Role
        for (OpportunityContactRole ocr: [SELECT id, OpportunityId, isPrimary, ContactId FROM OpportunityContactRole 
                                            WHERE OpportunityId in :oppIdToConIdMap.keySet() ORDER BY OpportunityId, isPrimary]) {
            if (oppIdToExistingOCRMap.isEmpty())
                oppIdToExistingOCRMap.put(ocr.OpportunityId, new Set<Id> {ocr.ContactId});
            else
                oppIdToExistingOCRMap.get(ocr.OpportunityId).add(ocr.ContactId);
                
            if (ocr.IsPrimary) 
                primaryOppCRIdSet.add(ocr.OpportunityId);
        }
        //CR8577
        List<RecordType> oppRTList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity'
                                    AND IsActive = True and Name IN ('Standard Opportunity', 'Run Rate Marketing', 'Run Rate Opportunity', 'Channel Opportunity')];
        
        
        //Exclude APOS and Run Rate Marketing Opp and process to add the remaining opp
        for(Opportunity opp : [SELECT Id FROM Opportunity WHERE Id in :oppIdToConIdMap.keySet() AND RecordTypeId IN :oppRTList]) {
            
            for (String conId : oppIdToConIdMap.get(opp.Id)) {                      
                //Only create Opportunity Contact Role if the contact not yet exists in this Opportunity
                if (oppIdToExistingOCRMap.get(opp.Id) == null ||
                    (oppIdToExistingOCRMap.get(opp.Id) != null && !oppIdToExistingOCRMap.get(opp.Id).contains(conId))
                    ) {
                    OpportunityContactRole newOCR = new OpportunityContactRole(OpportunityId=opp.Id, contactid=conId, 
                                                            role=conIdToDCRMap.get(conId),
                                                            isPrimary=(primaryOppCRIdSet.contains(opp.Id)? false:true)); 
                    newOCRList.add(newOCR);
                }
            }
        }
        
        System.debug('##### Opportunity Contact Role: '+newOCRList);
        if (newOCRList.size() > 0) {
            insert newOCRList;
        }
    }*/
}