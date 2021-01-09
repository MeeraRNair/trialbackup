/*
 * Author   : Ragu
 * Purpose  : Centralize the record selection process for Opportunity.
 *          Defines the methods which iterate and segregate the Opportunity records for further use.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10496     15.10       10-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR10827     16.03       19-Jan-2015     Manju           Auto-renewal for Opportinities whose DSG_Renewal_Request flag is True.
 * 3.0      CR11576     16.07       16-Jun-2016     Devika          Update the code to include multi LOB functionality
 * 4.0      CR          FY17 S-10    06-June-2016    Meera           Include Disti related fields in query for mapRelatedRecords
 * 5.0      CR13964                 06-Feb-2017     Vasavi.M        Comment populating lstOfOpptysToBeAutoApprvd, as this is related to DSG renewal request functionality
 * 6.0      CR15574     FY190502    28-March-2018   Vivek           Added 'Primary_SE__c' in existing account query
 * 7.0      D-5078728   FY190602    15-may-2018     Krishna         Added VisitOps in related records.
            CR          FY20O2O2    12-Dec-2018     Hari A           STORY 5907651 Removed reference for the fields lob_registration_id__c
                                    06-Mar-2019     ShyamB        6259094 Add 'Product2.Selling_Entity_Required__c' field in soql query
 * 8.0      CR17974	FY20-DCE-1002   04-Sept-2019	Shubham B	  added fields(type,Source_System__c,recordtypeid) in opportunity query in getRelatedRecords  
   
 */

public class OpportunityRecordSelector extends RecordSelector {
    
    private OpportunityTriggerHandler oppTriggerHandler;
    public set<Id> setAccountIds = new set<Id>();
    public set<Id> setPartnerAccountIds = new set<Id>();
    public set<Id> setOppCreatedByIds = new set<Id>();
    public map<Id, Opportunity> mapRelatedRecords = new map<Id, Opportunity>();
    public map<Id, Account> mapRelatedAccounts = new map<Id, Account>();
    
    // Used in OpportunityFieldPopulator.validateAndPopulateLOBRegistrationDetails()
    public set<Id> setLOBRegistrationIds = new set<Id>();
    public map<Id, Opportunity> mapCreateDealFromLOBOpps = new map<Id, Opportunity>();
    
    // Used in OpportunityUtilities.updateRSSSupportRequest()
    public set<Id> setClosedOppIds = new set<Id>();
    
    // Used in OpportunityValidator.validateSolutionAssociation()
    public set<String> setOSCSolutionIds = new set<String>();
    
    // CR6925: Logic from opptyBeforeInsertUpdateTrigger
    public set<Id> setOppIdsToDisableSnPNotification = new set<Id>();
    
    // Used in OpportunityUtilities.updateRelatedSnPVendors()
    public set<Id> setCloseDateStageNameUpdatedOppIds = new set<Id>();
    
    // Used in OpportunityUtilities.createSolutionCertificate()
    public set<Id> setOppIdsForSolCert = new set<Id>();
    public map<Id, Opportunity> mapOppsForSolCert = new map<Id, Opportunity>();
    
    // Used in OpportunityValidator.validateCloseDate() and OpportunityFieldPopulator.populatePrimaryCampaignSource()
    public set<Id> setChannelLeadIds = new set<Id>();
    public list<Opportunity> lstChannelLeadOpps = new list<Opportunity>();
    
    // Used in OpportunityUtilities.linkToAccountPlay()
    public set<String> setLatticePreLeadIds = new set<String>();
    public list<Opportunity> lstLatticePreLeadOpps = new list<Opportunity>();
    
    // Used in OpportunityFieldPopulator.populateRegionForSMBOpportunities()
    public list<Opportunity> lstSMBOpportunities = new list<Opportunity>();
    
    // Used in OpportunityTriggerHandler.onAfterInsert()
    public list<Id> lstDealRegUpdatedOppIds = new list<Id>();
    
    // Used in OpportunityUtilities.createOpportunityDescriptionHistory()
    public list<Opportunity> lstDescChangedOpps = new list<Opportunity>();
    
    // Used in OpportunityUtilities.sendEmailNotificationOnStageChange()
    public map<Id, Opportunity> mapOppsForNotification = new map<Id, Opportunity>();
    
    // Used in OpportunityUtilities.associateToPartnerOpportunitiesRelatedList()
    public map<Id, Id> mapOppIdPartnerAccountId = new map<Id, Id>();
    
    // Used in OpportunityUtilities.associateDistiAccountToPartnerOpportunitiesRelatedList()
    public map<Id, Id> mapOppIdDistiAccountId = new map<Id, Id>();
    
    
    //CR10827 - Used in OpportunityFieldPopulator.populateForAutoApproval();
    //v5.0 public list<Opportunity> lstOfOpptysToBeAutoApprvd = new list<Opportunity>();
    
    //Used in AccountSuggestionIntegration
    public set<Id> setOppIdsChangeProbability = new set<Id>();
    public set<Id> setActivateAccIds = new set<Id>();

    public OpportunityRecordSelector(list<sObject> lstOpportunities, map<Id, sObject> mapOldOpportunities, OpportunityTriggerHandler oppTriggerHandler) {
        this.oppTriggerHandler = oppTriggerHandler;
        
        this.getRecords(lstOpportunities, mapOldOpportunities);
        
        if(lstOpportunities != null) {
            this.getRelatedRecords(lstOpportunities);
        }
        else if(mapOldOpportunities != null) {
            this.getRelatedRecords(mapOldOpportunities.values());
        }
        
        removeNulls();
    }
    // * 8.0      CR17974	FY20-DCE-1002   04-Sept-2019	Shubham B	  added fields(type,Source_System__c,recordtypeid) in opportunity query in getRelatedRecords  
    protected override void getRelatedRecords(list<sObject> lstOpportunities) {
        if(Utility.isIdAvailable(lstOpportunities)) {
        //[ShyamB-6259094] Add 'Product2.Selling_Entity_Required__c' field in soql query
            mapRelatedRecords = new map<Id, Opportunity>([select Id,source_system__c,type,recordtypeid,Primary_Product_Delivery_Address_Country__c,Primary_Product_Delivery_Address_Region__c,Regional_Parent_Name__c,Sales_Channel_Region__c,Pricebook2Id,Name,StageName,AccountId, Account.Account_ID__c, CreatedBy.Profile.Name, OwnerId, Owner.Name, Owner.FirstName, Owner.LastName, Owner.Email, 
                                                            Owner.Contact.Email, Owner.Contact.AccountId, Owner.Contact.Phone, Owner.Contact.Account.Partner_Relationship__c, Owner.Profile.Name,Distributor_Reseller_Name__c,Distributor_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,Distributor_Reseller_Name__r.Dell_Certification_Areas__c,
                                                            (select Id, OpportunityId,PricebookEntryId,Quantity,Ocean_Indicator__c,LOT_Indicator__c, Active_Wyse_Product__c, Product_Line_Desc__c, Description, Product2.Selling_Entity_Required__c from OpportunityLineItems), (select id,VisitOps__Opportunity__c,VisitOps__visit__r.Owner.Email,VisitOps__Opportunity__r.StageName from VisitOps__VisitBundles__r)
                                                          from Opportunity where Id in :Utility.getIds(lstOpportunities)]);
        }
        
        setAccountIds.addAll(setPartnerAccountIds);
        if(!setAccountIds.isEmpty()) {
            mapRelatedAccounts = new map<Id, Account>([select Id, Name, Primary_SE__c, Dell_Services_Industry__c, Owner.FirstName, Owner.LastName,BillingCountry,BillingStreet,BillingCity,BillingPostalCode,BillingState,Suggestion_ID__c,Billing_Address_CN__c,Account_Classification__c,Account_Country__c,Segment_Name__c,Segment_Desc__c,Segment_Business_Unit_Name__c, Segment_Name_lookup__c
                                                       from Account where Id in :setAccountIds]);
        }
         system.debug('#####*********mapRelatedAccounts**********######'+ mapRelatedAccounts);
    }
    
    protected override void getRecords(list<sObject> lstOpportunities, map<Id, sObject> mapOldOpportunities) {
        
       // Id createDealFromLOBRTId = StaticDataUtils.getRecordTypeIdByName('Opportunity', 'Create New Deal From LOB');
        Id createDealFromLOBRTId = StaticFactory.getRecordTypeIdByDevName('Opportunity', 'Create_New_Deal_From_LOB');
        
        Id SMBOpportunityRTId = StaticDataUtils.getRecordTypeIdByName('Opportunity', 'SMB Opportunity');
        set<Id> setRTIdsForNotification = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set<string>{'Standard Opportunity', 'SMB Opportunity', 'Run Rate Opportunity','Channel Opportunity'});
        set<Id> setStdAndChannelRTIds = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set<string>{'Standard Opportunity', 'Channel Opportunity'});
        System.Debug('----Test RecordType Name --'+createDealFromLOBRTId);
        if(lstOpportunities != null) {
            for(Opportunity newOpportunity : (list<Opportunity>)lstOpportunities) {             
                Opportunity oldOpportunity;
                if(mapOldOpportunities != null && !mapOldOpportunities.isEmpty()) {
                    oldOpportunity = (Opportunity)mapOldOpportunities.get(newOpportunity.Id);
                }
                
                setAccountIds.add(newOpportunity.AccountId);
                setPartnerAccountIds.add(newOpportunity.PartnerAccountId);
                
                setOppCreatedByIds.add(newOpportunity.CreatedById);
                System.Debug('----Test RecordType Name --'+newOpportunity.RecordTypeId);
                if(newOpportunity.RecordTypeId == createDealFromLOBRTId) {
                    /**** v3.0 Starts *****/
                    /*if(newOpportunity.LOB_Registration_ID__c != null){
                      List<Id> lobList = newOpportunity.LOB_Registration_ID__c.split(';');
                      setLOBRegistrationIds.addAll(lobList);
                    }*/
                    //setLOBRegistrationIds.add(newOpportunity.LOB_Registration_ID__c);
                    mapCreateDealFromLOBOpps.put(newOpportunity.Id, newOpportunity);
                    /**** v3.0 Ends *****/
                }
                
                if(newOpportunity.RecordTypeId == SMBOpportunityRTId && newOpportunity.Region__c == null) {
                    lstSMBOpportunities.add(newOpportunity);
                }
                
                if(newOpportunity.OSC_Solution_ID__c != null) {             
                    setOSCSolutionIds.add(newOpportunity.OSC_Solution_ID__c);
                }
                
                
                // Only if related old record is available
                if(oldOpportunity != null) {
                    if(setRTIdsForNotification.contains(newOpportunity.RecordTypeId) && oldOpportunity.StageName != newOpportunity.StageName) {
                        mapOppsForNotification.put(newOpportunity.Id, newOpportunity);
                    }
                    
                    if(newOpportunity.StageName != oldOpportunity.StageName && (newOpportunity.StageName == 'Win - 100%' || newOpportunity.StageName == 'Lost, Cancelled - 0%')) {
                        setClosedOppIds.add(newOpportunity.Id);
                    }
                    
                    if(setStdAndChannelRTIds.contains(newOpportunity.RecordTypeId) && oldOpportunity.Description != newOpportunity.Description) {
                        lstDescChangedOpps.add(oldOpportunity);
                    }
                }
                
                
                // Trigger context based filtering - Add your selection logics here, if it needs to be tightly coupled with trigger context
                if(oppTriggerHandler != null) {
                    if(oppTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                        if(oppTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                            if(newOpportunity.Marketing_Created_Opportunity__c == true && newOpportunity.Lattice_PreLead_External_Id__c != null) {
                                setLatticePreLeadIds.add(newOpportunity.Lattice_PreLead_External_Id__c);
                                lstLatticePreLeadOpps.add(newOpportunity);
                            }
                            
                            if(newOpportunity.Channel_Lead_Id__c != null) {
                                setChannelLeadIds.add(newOpportunity.Channel_Lead_Id__c);
                                lstChannelLeadOpps.add(newOpportunity);
                            }
                                                     
                        }
                        else if(oppTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                            if(newOpportunity.StageName != oldOpportunity.StageName && (newOpportunity.StageName == 'Win - 100%' || newOpportunity.StageName == 'Lost, Cancelled - 0%')) {
                                setOppIdsToDisableSnPNotification.add(newOpportunity.Id);
                            }
                            
                            if(newOpportunity.Channel_Lead_Id__c != oldOpportunity.Channel_Lead_Id__c && newOpportunity.Channel_Lead_Id__c != null) {
                                setChannelLeadIds.add(newOpportunity.Channel_Lead_Id__c);
                                lstChannelLeadOpps.add(newOpportunity);
                            }
                            //CR10827 - Auto-renewal for Opportinities whose DSG_Renewal_Request flag is True
                            /*v5.0 Start
                            if(oldOpportunity.DSG_Renewal_request__c == false && newOpportunity.DSG_Renewal_request__c == true){
                               lstOfOpptysToBeAutoApprvd.add(newOpportunity);
                            }
                            v5.0 End*/
                            
                        }
                    }
                    else if(oppTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                        if(oppTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                            if(newOpportunity.Deal_Registration_Status__c != null) {
                                lstDealRegUpdatedOppIds.add(newOpportunity.Id);
                            }
                            if(newOpportunity.Probability >= 30){
                             
                              setActivateAccIds.add(newOpportunity.id);
                            } 
                        }
                        else if(oppTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                            if(newOpportunity.Deal_Registration_Status__c != oldOpportunity.Deal_Registration_Status__c && newOpportunity.Deal_Registration_Status__c == 'Approved') {                  
                                lstDealRegUpdatedOppIds.add(newOpportunity.Id);
                            }
                            
                            if(newOpportunity.StageName != oldOpportunity.StageName || newOpportunity.CloseDate != oldOpportunity.CloseDate) {
                                setCloseDateStageNameUpdatedOppIds.add(newOpportunity.Id);
                            }
                            
                            if(newOpportunity.Number_of_Line_Items__c > 0 && !GlobalVariables.SKIP_SOLUTION_CERT_FUNCTIONALITY) {
                                setOppIdsForSolCert.add(newOpportunity.Id);
                                mapOppsForSolCert.put(newOpportunity.Id, newOpportunity);
                            }
                            if(newOpportunity.Probability!= oldOpportunity.Probability && newOpportunity.Probability >= 30 && oldOpportunity.Probability < 30  ) {
                                setActivateAccIds.add(newOpportunity.id);
                            }
                        }
                        
                        if(!GlobalVariables.SKIP_OPP_PARTNER_ADDITION && newOpportunity.Deal_Registration_Status__c == 'Approved' 
                            && newOpportunity.PartnerAccountId != null && newOpportunity.PartnerAccountId != newOpportunity.AccountId) {
                            mapOppIdPartnerAccountId.put(newOpportunity.Id, newOpportunity.PartnerAccountId);
                        }
                        if(!GlobalVariables.SKIP_OPP_PARTNER_ADDITION && newOpportunity.Deal_Registration_Status__c == 'Approved' 
                            && newOpportunity.Distributor_Reseller_Name__c != null && newOpportunity.Distributor_Reseller_Name__c != newOpportunity.AccountId) {
                            mapOppIdDistiAccountId.put(newOpportunity.Id, newOpportunity.Distributor_Reseller_Name__c);
                        }
                    }
                }
            }
        }
        else if(mapOldOpportunities != null) { // Handling delete events
            for(Opportunity oppIterator : (list<Opportunity>)mapOldOpportunities.values()) {
                setAccountIds.add(oppIterator.AccountId);
                setPartnerAccountIds.add(oppIterator.PartnerAccountId);
                
                setOppCreatedByIds.add(oppIterator.CreatedById);
            }
        }
    }
    
    // Remove nulls from the Set / List / Map.
    private void removeNulls() {
        setAccountIds.remove(null);
        setPartnerAccountIds.remove(null);
    }
    
}