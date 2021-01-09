/*
 * Author   : Ragu  
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Opportunity.
 *          Calls business logics by passing trigger context variables or corresponding results from OpportunityRecordSelector class.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR10496     15.10           10-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR10582     16.03           08-Jan-2015     Devika          Check for credit card information in Useful Additional Info. For Operations, Next Step & Description field.
 * 2.1      CR10738     16.03           16-Jan-2015     Jiji            Channel lead Validation during opportunity insert, Update Opportunity counter and realted opportunity field while deletion
 * 2.2      CR10827     16.03           19-Jan-2015     Manju           Auto-renewal for opportunities meeting specific criteria.  
 * 3.0      CR11414     16.07(MAJ-S-01) 18-May-2015     Krishnamoorthi  To populate Opportunity fields Product_Group_Hidden and Product_Brand_Hidden when Opportunity Record Type is changed 
 * 4.0      CR11602     16.06(MIN-S-10) 12-June-2015    Anwar           Sending the email to Campaign owner when the changed Opportunity campaign
 * 5.0      CR11721     16.07(MAJ-S-06) 13-Jul-2015     Jiji            To remove the deal reg analyst with Sales Support role upon opportunity Approve/reject.
 * 6.0      CR12020     16.10(MAJ-S-13) 05-Oct-2015     Azwanti         invoke AddPartnerAcctTeamOnDealReg class to add partner Account team as OpportunityTeamMember to DSG Opportunity
 * 7.0      CR12071     16.10(MAJ-S-14) 15-oct-2015     JVSANTOSH       Display an error message if the address information is missing 
 * 8.0      CR12076     CSM1102         19-Oct-2015     Fenny           Redesign the SFDC - MyDeal integration via Boomi to make it real time
 * 9.0      CR12348     16.12           16-Nov-2015     Dipin Raju      Populate Customer Requested Date based on Book Date
 * 10.0     CR12387     16.12           01-Dec-2015     Niveda          Call a webservice method to activate account when opportunity stage is greater than 30%
 * 11.0     CR12683                     07-Mar-2015     Swathi          Call a SF1Adoption class to capture users action(Edit)   
 * 12.0     CR13119                     13-May-2016     Meera           To populate Partner Notification email from Disti_Reseller Account
 * 13.0     CR13437     CSM1002         06-Sep-2016     Afiq            To comment method which will be moved to a process builder
 * 14.0     D2574554    Sprint19        10-Oct-2016     Vasavi.M        Allow deleteion of DSG related Oppty, for profiles other than admin profiles 
                                                                        - to support open oppty, after Cast Iron integration stops
 * 15.0     CR 13964                    01-Feb-2017     Vasavi.M        Comment AddPartnerAcctOnInsert method call, as it is related to DSG
                                                                        - this method will auto assign OTM for child Oppty
                                                                        -Comment populateForAutoApproval - commenting functioality ofextend the Auto-renewal process 
                                                                        to all related open parent/child opportunities          
 * 16.0     CR 14781                     14-AUG-2017     Ashok           LM2_MDM_5-Retire Update Account Web Service
 * 17.0     CR14962    FY18-1101         22-Sep-2017     Venkateswarlu   OpportunityTeamMemUpdate:If a account is re-partented the new team should be added to the opportunity team
                                                                         - and the old team are removed.
 * 18.0    CR14931     DCS-FY18-1101     20-Sep-2017     Naga            Code cleanup for savo functionality, removed all refferences of Product_Group_Hidden__c and Product_Brand_Hidden__c fields from code.
 
 * 19.0    CR15353     FY19-0203         26-Dec-2018     Abhinav         Added method to handle forecast category override feature.
 * 20.0    CR15380     FY19-DCS-0502     12-Mar-2018     Akshita         To stop the deletion of records if the value in EMC Opportunity Number field is null.
 * 21.0    CR          FY19-DCS-0702     1-June-2018     Meera           Poulate Forecast summary flag on opportunity from product       
 * 22.0    CR 15965    FY19-DCS-0703     14-Jun-2018     Sakshi          commented the line that call OpptyTeamAddedfromCSV
 * 23.0     CR 17551    FY20-0702       24-May-2019     Fenny           OpportunityTriggerHandler obsolete
 * 24.0		CR18308		FY20-0102		25-Nov-2019		Fenny			To make Record Selector accessible by many other features packages
*/

public class OpportunityTriggerHandler extends TriggerHandler {

    public static OpportunityRecordSelector oppRecordSelector;
    public static OpportunityTriggerHandler handler;
    public override void getRecordSelector() {
        handler = this;
        oppRecordSelector = new OpportunityRecordSelector(Trigger.new, Trigger.oldMap, this);
    }
    /*
    public override void onBeforeInsert() {
        
        //Populates Partner Account and Opportunity Region for Deal Reg opportunities PAM changes Deal Reg
         OpportunityFieldPopulator.populatePartnerAccOnOppty(Trigger.new);
         // Added for To populate Distributor/Reseller Account Name for Vartopia Deals.
         OpportunityFieldPopulator.populateVartopiaidFromText(Trigger.new,null);
       
        
        if(!TriggerExecutionController.skipOpportunityValidator()) {
            // v2.0 Check to see whether Credit Card information is in the opportunity fields
            OpportunityValidator.validateCreditCardInformation(Trigger.new, null);        
            
            // Check to see whether Opportunity is qualified for DGR Control Panel
            OpportunityValidator.validateOpportunities(Trigger.new, null);
            
            // Validate whether Solution mapped with the Opportunity is already mapped with another deal or not
            OpportunityValidator.validateSolutionAssociation(Trigger.new, oppRecordSelector.setOSCSolutionIds);
        
            // v7.0 - Display an error message if the address information is missing
            //OpportunityValidator.validateEndUserMailingAddress(Trigger.new, null);
         
            // v2.1 - Validate Channel_Lead_Id__c associated with the Opportunity and Populate CampaignId
            OpportunityValidator.validateChannelLeads(oppRecordSelector.lstChannelLeadOpps, oppRecordSelector.setChannelLeadIds);
            
            // Check to see whether Opportunity Fullfilment Path is Distribution or not - CR 12704
            OpportunityValidator.validateFulfilmentPathForDistributor(Trigger.new, null);
            
            // Check to see whether Opportunity Team Mail Box Email domain with loggedin User Domain
            OpportunityValidator.validateTeamMailboxDomain(Trigger.new, null);
            
            OpportunityValidator.validateActiveEndCustomer(Trigger.new, null);
        }
        
        // Default CloseDate to date of nearest quarter end for Run Rate Opportunities, StageName to Commit - 90% and Probability to 90%
        OpportunityUtils.defaultRunRateOppty(Trigger.new);
                
        // Override the Probability based on the Override_Probability__c field
        OpportunityFieldPopulator.overrideProbability(Trigger.new, null);
        
        //19.0 Override the ForecastCategoryName and Probability based on the Forecast_Category_Override__c field
        OpportunityFieldPopulator.overrideForecastCategory(Trigger.new, null);
        
        // Auto populate fields
        OpportunityFieldPopulator.autoPopulateFields(Trigger.new, null, trigEvent, oppRecordSelector.mapRelatedAccounts);
        
        // Populate primary campaign source in Opportunity and update End Customer and End Customer Contact details in the Lead
        OpportunityFieldPopulator.populatePrimaryCampaignSource(oppRecordSelector.lstChannelLeadOpps, oppRecordSelector.setChannelLeadIds, trigEvent);
        
        // Validate the LOB Registration ID field and Update the hidden LOB Registration related fields
        OpportunityFieldPopulator.validateAndPopulateLOBRegistrationDetails(oppRecordSelector.mapCreateDealFromLOBOpps, oppRecordSelector.setLOBRegistrationIds, this);
        
        // Populate Region__c for the newly created Opportunity based on the Country__c field on the Opportunity Owner
        OpportunityFieldPopulator.populateRegionForSMBOpportunities(oppRecordSelector.lstSMBOpportunities);
        
        // Populate SOC_Solution_Name_Console__c field based on the Solution_Name__c field
        OpportunityFieldPopulator.populateSOCSolutionNameConsole(Trigger.new, null);
        
        // CR8276: Mohammad - Auto populate Partner Account Owner Email
        (new AutoPopulateCustomerNumber()).updatePartnerAccountEmail(Trigger.new);
        
        // Create End Customer, End Customer Contact, Partner Request and populate details in the Opportunity
        OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(Trigger.new, null);
        
        // CR 10068 - Create Campaign Share for opportunity owners
        CampaignSharingUtilities.createCampaignShare(Trigger.new, null, trigEvent);
        
        // MARKER - Ragu on 10-Oct-2014 (Valid till 16.03): Below line is commented as part of CR10496 as this doesn't make sense on Opportunity before insert. 
        // Set Send_Notification__c field in S_P_Vendor__c object to false to disable notifications when an Opportunity is closed
        //OpportunityUtilities.updateSnPNotificationField(oppRecordSelector.setOppIdsToDisableSnPNotification);
        
        // Link Opportunity with Account Play based on the Lattice_PreLead_External_Id__c
        OpportunityUtilities.linkToAccountPlay(oppRecordSelector.lstLatticePreLeadOpps, oppRecordSelector.setLatticePreLeadIds);
        
        // Populate LOTOcean related fields
          LOTOcean.populateLOTOceanRelatedDetails(Trigger.new);
        
        // Automatically update on the APOS Renewed Opportunities when it meets certain criterias
        OpportunityFieldPopulator.updateRenewedAPOSOpportunities(Trigger.new);
          
        // When navigating from OSC url contains unwanted %3A, which is causing issue of deal sync. this is to avoid that
        OpportunityFieldPopulator.formatOSCid(Trigger.new,trigEvent); 
        
        //v12.0 - start: *** [IMPORTANT] PLEASE KEEP THIS METHOD AT THE END, because the logics are from workflow rule which suppose to be executed after all triggers execution ***
        OpportunityFieldPopulator.workflowFieldUpdate (trigEvent, Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        //v12.0 - end: *** [IMPORTANT] PLEASE KEEP THIS METHOD AT THE END, because the logics are from workflow rule which suppose to be executed after all triggers execution ***  
        OpportunityFieldPopulator.populateDistiResellerAccName(Trigger.new, null);
        
        
   
        
    }
    
    public override void onBeforeUpdate() {
        system.debug('@#debug TriggerExecutionController.skipOpportunityValidator()'+ TriggerExecutionController.skipOpportunityValidator());
        if(!TriggerExecutionController.skipOpportunityValidator()) { 
      
            // v2.0 Check to see whether Credit Card information is in the opportunity fields
            OpportunityValidator.validateCreditCardInformation(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);            
            
            // Check to see whether Opportunity is qualified for DGR Control Panel
            OpportunityValidator.validateOpportunities(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
            
            // Validate Opportunity CloseDate
            //OpportunityValidator.validateCloseDate((map<Id, Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap);
    
            // Validate Channel_Lead_Id__c associated with the Opportunity and Populate CampaignId
            OpportunityValidator.validateChannelLeads(oppRecordSelector.lstChannelLeadOpps, oppRecordSelector.setChannelLeadIds);
            
            // Validate Stage change for Cloud Client Computing Opportunities
            OpportunityValidator.validateStageChangeForCloudClientComputingOpps(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, oppRecordSelector.mapRelatedRecords);
            
             // Validate Opportunity CloseDate
            OpportunityValidator.validateCloseDate((map<Id, Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap);
            
             // Check to see whether Opportunity Fullfilment Path is Distribution or not - CR 12704
            OpportunityValidator.validateFulfilmentPathForDistributor(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
            
            // Check to see whether Opportunity Team Mail Box Email domain with loggedin User Domain
            OpportunityValidator.validateTeamMailboxDomain(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
            
            //Make Distributor/Reseller Account Name Blank when Fulfilment Path is updated to Direct Fulfilment
            OpportunityValidator.checkOnFulfilmentPath(Trigger.new,(map<Id, Opportunity>)Trigger.oldMap);
            
            OpportunityValidator.validateActiveEndCustomer(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
            
            
            
        }
        //It checks for rejection reason fields when try to reject a deal.
        OpportunityValidator.ValidateRejectionFields(Trigger.new,(map<Id, Opportunity>)Trigger.oldMap);
        // Added for To populate Distributor/Reseller Account Name for Vartopia Deals.
       OpportunityFieldPopulator.populateVartopiaidFromText(Trigger.new,(map<Id, Opportunity>)Trigger.oldMap);
         
        // Override the Probability based on the Override_Probability__c field
        OpportunityFieldPopulator.overrideProbability(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        //19.0 Override the ForecastCategoryName and Probability based on the Forecast_Category_Override__c field
        OpportunityFieldPopulator.overrideForecastCategory(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        
        // Auto populate fields
        OpportunityFieldPopulator.autoPopulateFields(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, trigEvent, oppRecordSelector.mapRelatedAccounts);
        
        // Populate primary campaign source in Opportunity
        OpportunityFieldPopulator.populatePrimaryCampaignSource(oppRecordSelector.lstChannelLeadOpps, oppRecordSelector.setChannelLeadIds, trigEvent);
        
        // Validate the LOB Registration ID field and Update the hidden LOB Registration related fields
        OpportunityFieldPopulator.validateAndPopulateLOBRegistrationDetails(oppRecordSelector.mapCreateDealFromLOBOpps, oppRecordSelector.setLOBRegistrationIds, this);
        
        // Populate SOC_Solution_Name_Console__c field based on the Solution_Name__c field
        OpportunityFieldPopulator.populateSOCSolutionNameConsole(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // CR8276: Mohammad - Partner Account Owner Email Auto Populate
        (new AutoPopulateCustomerNumber()).updatePartnerAccountEmail(Trigger.new);
        
        // (CR10468) Mini Sprint16.03: Mohammad - update Order Compliance Product field of Oppty, Quote requried for 60% 
        OpportunityFieldPopulator.populateOrderComplianceproduct(Trigger.new);
        
        // CR8681, Monthly Sprint 3: To update the PUSHED DEALS field when close date changes.
        OpportunityWrapper.calculatePushedDeals(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Send email notification to SOC_Engagement@Dell.com whenever Stage changed for the Opportunities which has Support Requests which is not in "New" Status
        OpportunityEmailUtilities.sendEmailNotificationOnStageChange(oppRecordSelector.mapOppsForNotification);
        
        // Create End Customer, End Customer Contact, Partner Request and populate details in the Opportunity
        OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Set Send_Notification__c field in S_P_Vendor__c object to false to disable notifications when an Opportunity is closed
        SnPUtilities.updateSnPNotificationField(oppRecordSelector.setOppIdsToDisableSnPNotification);
        
        // Auto populate Partner Sales Rep Name, Emai and Phone when owner is changed.
        OpportunityUtilities.updatePartnerSalesRepDetails(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, oppRecordSelector.mapRelatedRecords);
        
        // Auto populate Deal_Expiration_Timeframe__c & Deal_Expiration_Date__c
        OpportunityFieldPopulator.updateDealExpirationDetails(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Auto populate Deal_Expiration_Timeframe__c & Deal_Expiration_Date__c for Engage Channel
       // UpdateDealExpirationDateforEngageChannel.updateDealExpirationEngageChannel(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Populate LOTOcean related fields
        LOTOcean.populateLOTOceanRelatedDetails(Trigger.new);
        
        // Update LOT indicator on Opportunity Product
        //OpportunityLineItemUtilities.updateLOTIndicator(this.trigEvent, oppRecordSelector.mapRelatedRecords);
        
        // LOTOcean related calculations
        LOTOcean.lotOceanCalculation((map<Id, Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Automatically update on the APOS Renewed Opportunities when it meets certain criterias
        OpportunityFieldPopulator.updateRenewedAPOSOpportunities(Trigger.new);
        
        // CR10827 - Auto-renewal for opportunities meeting specific criteria
        v15.0
        //if(oppRecordSelector.lstOfOpptysToBeAutoApprvd.size() > 0){
            //OpportunityFieldPopulator.populateForAutoApproval(oppRecordSelector.lstOfOpptysToBeAutoApprvd);
        //}v15.0
        
        //v12.0 - start: *** [IMPORTANT] PLEASE KEEP THIS METHOD AT THE END, because the logics are from workflow rule which suppose to be executed after all triggers execution ***
        OpportunityFieldPopulator.workflowFieldUpdate (trigEvent, Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        //v12.0 - end: *** [IMPORTANT] PLEASE KEEP THIS METHOD AT THE END, because the logics are from workflow rule which suppose to be executed after all triggers execution ***
        
        OpportunityFieldPopulator.populateDistiResellerAccName(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        //V12.0 
        OpportunityFieldPopulator.populatePartnerNotificationEmail(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
      //  OpportunityFieldPopulator.populateAccountName(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
         AutoPopulateAccountNameFromEndCustomer.populateAccountName(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
         
     // V1.0 Deal registration cancellation within 90 day protection
   // if(Userinfo.getProfileId()=='00eA0000000hNqF' ? TRUE : !(System_Behavior_Bypasser__c.getInstance(userinfo.getUserId()).Bypass_Opportunity_VRs__c))
    if(Userinfo.getProfileId()== System.Label.Boomiprofile ? TRUE : ( !(System_Behavior_Bypasser__c.getInstance(userinfo.getUserId()).Bypass_Opportunity_VRs__c) && !(Opportunity_lost_cancel_VR_bypass_profil__c.getInstance(userinfo.getUserId()).Bypass_Oppty_Lost_Cancel_VR_Profiles__c)  ))
           OpportunityValidator.validateToChangeDealStage(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
           
           
     //Check and populate 'EMC Opportunity updated' field for 'Lost, Cancelled - 0%'
    OpptyWaitforSyncUpdate_forLostDeals.PopulateEMCOpportunityupdated(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
    
    //V21.0 Populate forecast flag summary
    //OpportunityFieldPopulator.populateforecastflagsummary((map<Id, Opportunity>)Trigger.newMap,(map<Id, Opportunity>)Trigger.oldMap); 
    }
    
    public override void onBeforeDelete() {
        //V14.0 Start
        // Validate deletion of the Opportuntiy
        //OpportunityValidator.validateDeletion(Trigger.old, oppRecordSelector.mapRelatedRecords);
        //V14.0 End
        
        // v2.1 - Update Opportunity counter and realted opportunity field in Lead
        ChannelLeadUtilities.updateCLforOppDelete(Trigger.Old, oppRecordSelector.mapRelatedRecords, trigEvent);
        
        //V20.0 Start
        // Validate deletion of the Opportuntiy
        OpportunityValidator.validateOpportunityEMCNum(Trigger.old);
        //V20.0 End
    }
    
    public override void onAfterInsert() { 
        
        // Copy Partner Account's AccountTeamMembers to the LOB Opportunities OpportunityTeamMember
        OpportunityFieldPopulator.populateOpportunityTeamMembers(oppRecordSelector.mapCreateDealFromLOBOpps);
        
        // Create Solution__c record for newly created Opportunity if OSC_Solution_ID__c is not null
        OpportunityUtilities.createSolutions(Trigger.new, oppRecordSelector.mapRelatedAccounts);
        
        // Recalculate Open / Closed Opportunity Values in SFDC_Strategy__c if Related_Strategy__c and Amount is not null
        OpportunityUtilities.recalculateStrategyValues(Trigger.new, null, trigEvent);
        
        // Create Deal_Summary__c for newly created Opportunity - Logic is separated from DealSummaryOppty trigger
        if(!GlobalVariables.BYPASS_FUTURE_CALLS) {
            DealSummary.optyAdd(Trigger.newMap.keySet());
        }
        
        // CR8966 - 27-Dec-2013: Update OpportunityLineItems Dell_Business_Model__c based on the Deal_Registration_Status__c of Opportunity and Dell_Business_Model__c of Product 
        (new OpportunityLineItemUpdateController()).UpdateOLI(oppRecordSelector.lstDealRegUpdatedOppIds);
        
        // Associate Partner Account to the Opportunity related list
         PartnerAccountAddition.associateToPartnerOpportunitiesRelatedList(oppRecordSelector.mapOppIdPartnerAccountId);
        
        // Associate Disti/Reseller Account to the Opportunity related list
         PartnerAccountAddition.associateDistiAccountToPartnerOpportunitiesRelatedList(oppRecordSelector.mapOppIdDistiAccountId);
        
        // Recalculate and update Quest Software Unweighted Rev and Quest Software Unweighted Margin Rev fields
        OpportunityUtilities.recalculateQuestRevenues(Trigger.new, null, trigEvent);
        
        // Added on 20-Aug-2008
        SalesTeamUtil.setDefaultSalesTeam(Trigger.new);
        
        // Associate Opportunities with Relationship Lead and Account Play
        MarketingOpptyAssnUtils.associateWithRelationshipLeadAndAccountPlay(Trigger.new);

        // Update associated Channel Lead details and create Relationship_Lead__c as necessary 
        ChannelLeadUtilities.updateChannelLead(Trigger.new, null, trigEvent);
        
        // 10068 - delete Campaign Share for opportunity owners
        CampaignSharingUtilities.deleteCampaignShare(Trigger.new, null, trigEvent);
        
        // Update supportability indicator on Account
        // 13.0 Start - To comment this method
        //OpportunityUtilities.updateSupportabilityIndicator(this.trigEvent, Trigger.new, null);
        // 13.0 End     
        
       //Add Engage Channel Deals Account Team Members
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnInserttoEngageChannelDeals(Trigger.new,null);
       
        // CR12020 add PartnerAccountTeamMember to DSG Opportunity
        // v15.0 - Comment DSG related code, SEAHAWK
        //AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnInsert(Trigger.new);
        //v15.0
        
                        
        if(!TriggerExecutionController.skipOpportunityValidator()) {
            // v7.0 - Display an error message if the address information is missing
            OpportunityValidator.validateEndUserMailingAddress(Trigger.new, null);
        }
        
        OpportunityUtilities.updateCTICallLog(this.trigEvent, Trigger.new, null);
        
        // v10.0 Call a webservice method to activate account when opportunity stage is greater than 30%
       // if(System.Label.AccountSuggestionIntegration == 'CIL') {
       //16.0
       //TriggerExecutionController.setSkipActivateAccount(true);
           //AccountSuggestionIntegrationCIL.activateAccountInAffinity(oppRecordSelector.setActivateAccIds);
      //  }
       // else {
      //      AccountSuggestionIntegration.activateAccountInAffinity(oppRecordSelector.setActivateAccIds);
      //  } 
      //TriggerExecutionController.setSkipActivateAccount(false);
       //16.0 End  
       
        //wanti - 
        String URL= '/p/opp/SelectSearch?addTo='+Trigger.new[0].Id;//+OpptyId;
        system.debug('----URL-- wanti : '+URL);
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        //return page;
      //CR Distributor or reseller account related Contacts
         DistributorResellerInsert.DistributorResellerInserts(Trigger.new, null);  
         
         
         
         //Populate or sync the standard and custom stage names on Deals before insert
         SyncStageValuesOnDeals.SyncStageValues(Trigger.new, null);  
         
         Dell_Asset_RMA.Mib_Opportunity_Handler.triggerReplica(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap); 
    }
    
    public override void onAfterUpdate() { 
         
        // v17.0 If an account is re-partented the new team should be added to the opportunity team and the old team are removed.
       OpportunityTeamMemUpdate.updateOppTeamMemWhenEndAccChange((map<Id, Opportunity>)Trigger.oldMap,(map<Id, Opportunity>)Trigger.NewMap);
        
        // EMC Deal Registration :Auto Case Creation
          AutoPopulateAccountNameFromEndCustomer.caseCreation(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // To do realtime update on OSC when fields in opportunity changes
        if(!System.isBatch()){
            OpportunityUtilities.RealtimeSolutionsupdate(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        }
        
           // to add new products to opportunity line item
       //  AddNewProdcutToLineItem.AddNewProductToOptyLineItem(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
    
        //Add Engage Channel Deals Account Team Members
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnInserttoEngageChannelDeals(Trigger.new,(map<Id, Opportunity>)Trigger.oldMap);
        
        // CR - AddPartnerAccTeamOnDealReg
        AddPartnerAcctTeamOnDealReg.AddAcctTeamOnUpdate(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
         // CR - RemoveOpportunityTeamMembers
        AddPartnerAcctTeamOnDealReg.deleteOldOppTeamsOnDistiNameUpdate(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        //Add Distibutor/Reseller Account Team Members on DealReg
          AddPartnerAcctTeamOnDealReg.AddDistiResellerAccTeam(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
                    
        // CR - AddPartnerAccTeamOnDealReg
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnUpdate(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
       
        
        // Update related Support Requests Status to "Engagement complete" whenever Stage is moving to "Win - 100%" / "Lost, Cancelled - 0%"
        OpportunityUtilities.updateRSSSupportRequest(oppRecordSelector.setClosedOppIds);
        
        // Recalculate Open / Closed Opportunity Values in SFDC_Strategy__c whenever Related_Strategy__c / Amount / StageName / ClosedDate is changed
        OpportunityUtilities.recalculateStrategyValues(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, trigEvent);
        
        // Update Deal_Summary__c whenever StageName / CloseDate / Opportunity_Plan__c / Related_Strategy__c / Scheduled_Opportunity__c is changed
        OpportunityUtilities.updateDealSummary((map<Id, Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Create Oppt_Description_History__c for Standard and Channel Opportunities whenever Description is changed
        OpportunityUtilities.createOpportunityDescriptionHistory(oppRecordSelector.lstDescChangedOpps);
        
        // Create SOM_Boomi_Log__c whenever Opportunity OwnerId / Services_Sales_Owner__c is changed and Services_Project_Count__c > 0
        OpportunityUtilities.createSOMBoomiLogs(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, oppRecordSelector.mapRelatedRecords);
        
        // CR8966 - 27-Dec-2013: Update OpportunityLineItems Dell_Business_Model__c based on the Deal_Registration_Status__c of Opportunity and Dell_Business_Model__c of Product 
        (new OpportunityLineItemUpdateController()).UpdateOLI(oppRecordSelector.lstDealRegUpdatedOppIds);
        
        // Update the Last Modified Date and Last Modified By field in the related S_P_Vendors__c record
        SnPUtilities.updateRelatedSnPVendors(oppRecordSelector.setCloseDateStageNameUpdatedOppIds);
        
        // Create Solution Certificate for all applicable Opportunities 
        OpportunityUtilities.createSolutionCertificate(oppRecordSelector.setOppIdsForSolCert, oppRecordSelector.mapOppsForSolCert);
        
        // Associate Partner Account to the Opportunity related list
        PartnerAccountAddition.associateToPartnerOpportunitiesRelatedList(oppRecordSelector.mapOppIdPartnerAccountId);
        
        // Associate Disti/Reseller Account to the Opportunity related list
        PartnerAccountAddition.associateDistiAccountToPartnerOpportunitiesRelatedList(oppRecordSelector.mapOppIdDistiAccountId);
        
        // Recalculate and update Quest Software Unweighted Rev and Quest Software Unweighted Margin Rev fields
        OpportunityUtilities.recalculateQuestRevenues(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, trigEvent);
        
        // Identify Opportunities and pass Deal_Id__c & StageName for Goal Deal integration
        GoalIntegrationUtils.processGoalIntegration(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Update associated Channel Lead details and create Relationship_Lead__c as necessary 
        ChannelLeadUtilities.updateChannelLead(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, trigEvent);
        
        // Update Revenue Schedule for Opportunity Line Item based on Opportunity Contract Term and Book Date
        OpportunityLineItemRevenueSchedule.populateRevenuSchedules(Trigger.new,(map<Id, Opportunity>)Trigger.oldMap,(map<Id, Opportunity>)Trigger.newMap);
        
        // Update supportability indicator on Account
        // 13.0 Start - To comment this method
        //OpportunityUtilities.updateSupportabilityIndicator(this.trigEvent, Trigger.new, Trigger.oldMap);
        // 13.0 End
        
        // 4.0 Sending the email to Campaign owner when the changed Opportunity campaign
        NotifyInitialCampaignOwner.sendEmailTocampaignowner((Map<Id, Opportunity>)Trigger.newMap, (Map<Id, Opportunity>) Trigger.oldMap);
        
        // 5.0: To remove the deal reg analyst with Sales Support role upon opportunity Approve/reject.
        OpportunityUtilities.removeSalesSupportRolefromOppTeam(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // 8.0
        OpportunityUtilities.pushCustomServiceSupportRequestToMyDeal((Map<Id, Opportunity>)Trigger.oldMap, (Map<Id, Opportunity>)Trigger.newMap);
        
        // v7.0 -  Display an error message if the address information is missing 
        OpportunityValidator.validateEndUserMailingAddress(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // v9.0 - Populate Customer Requested Date based on Book Date 
         OpportunityUtilities.updateCustomerReqDate(trigger.new, (map<Id, Opportunity>)Trigger.oldMap, this.trigEvent);
        
        // v10.0 Call a webservice method to activate account when opportunity stage is greater than 30%
        // Included skip variable to avoid recursive calls
        //16.0 - commented by Ashok 
        
        //if(!TriggerExecutionController.skipActivateAccount()) {
           // if(System.Label.AccountSuggestionIntegration == 'CIL') {
                //AccountSuggestionIntegrationCIL.activateAccountInAffinity(oppRecordSelector.setActivateAccIds);
           // }
            //else{
           //     AccountSuggestionIntegration.activateAccountInAffinity(oppRecordSelector.setActivateAccIds);
           // }
            //TriggerExecutionController.setSkipActivateAccount(true);
        //}
        
        // Update LOT indicator on Opportunity Product 
         OpportunityLineItemUtilities.updateLOTIndicator(this.trigEvent, oppRecordSelector.mapRelatedRecords);
        
        
         //v11.0 - Start 
         SF1Adoption.trackSF1Usage(Trigger.new, 'AfterUpdate');
         //v11.0 - End
         
         // class to add the team members to opportunity from csv file when Esg products are added to deal
        //OpptyTeamAddedfromCSV.NotifyOpptyTeamAddedfromCSV(trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
         
           // Class to send notifications to  End user account and partner Account team members
           NotifyPartnerandEndUseracctteams.NotifyOpptyTeam(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
         //Notification for OpptyPartnerAccountTeammembers
         //OpptyPartnerAccountTeamMember.NotifyOpptyPartnerAccountTeamMembers(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
         
         
         // Added by Rajdeep -- class to close cases when opportunity Deal Registration status is approved
         CloseOppCasesWhenDealRegApproved.closeOppCases((map<Id,Opportunity>)Trigger.newMap,(map<Id,Opportunity>)Trigger.oldMap);

         //CR Distributor or reseller account related Contacts
          DistributorResellerInsert.DistributorResellerInserts(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);   
          
          
          //Defect 5078728: SOQL 101 :: Due to Visitops Components on the opportunity
          OpportunityUtilities.updateVisitOpsDetails((map<Id,Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap, oppRecordSelector.mapRelatedAccounts, oppRecordSelector.mapRelatedRecords);
         
        //Populate or sync the standard and custom stage names on Deals
        SyncStageValuesOnDeals.SyncStageValues(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        //OpportunityFieldPopulator.autoPopulateFieldsafterupdate(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, trigEvent, oppRecordSelector.mapRelatedAccounts);
        //Dell_Asset_RMA.Mib_Rules_Opportunity_Handler.triggerReplica(trigger.new,trigger.oldMap); 
        
        Dell_Asset_RMA.Mib_Opportunity_Handler.triggerReplica(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
    }
    
    public override void onAfterDelete() {
        // Store deleated Opportunity details in Partner_Hub_Record_Deleted__c to enable data synchronization with Partner Hub.
        OpportunityUtilities.storeDeletedOpportunityDetailInPartnerHub(Trigger.old);
    }
*/
}