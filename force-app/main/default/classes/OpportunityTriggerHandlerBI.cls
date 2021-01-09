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
 * 23.0     CR 17551    FY20-0702       24-May-2019     Fenny           OpportunityTriggerHandler obsolete. Above histories and below methods calls are copied from OpportunityTriggerHandler
 * 24.0     CR18308     FY20-0102       25-Nov-2019     Fenny           To make Record Selector accessible by many other features packages
 * 25.0     CR18394     FY21-0202       24-Dec-2019     Abhinav         Overwrite Use Case field only for Sales Rep E users
*/
public class OpportunityTriggerHandlerBI implements BeforeInsert{
    
    public void handleBeforeInsert(List<sObject> listNew){
        system.debug('Entered Opportunity handleBeforeInsert');
        
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
            OpportunityValidator.validateSolutionAssociation(Trigger.new, OpportunityTriggerHandler.oppRecordSelector.setOSCSolutionIds);
        
            // v7.0 - Display an error message if the address information is missing
            //OpportunityValidator.validateEndUserMailingAddress(Trigger.new, null);
         
            // v2.1 - Validate Channel_Lead_Id__c associated with the Opportunity and Populate CampaignId
            OpportunityValidator.validateChannelLeads(OpportunityTriggerHandler.oppRecordSelector.lstChannelLeadOpps, OpportunityTriggerHandler.oppRecordSelector.setChannelLeadIds);
            
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
        OpportunityFieldPopulator.autoPopulateFields(Trigger.new, null, OpportunityTriggerHandler.handler.trigEvent, OpportunityTriggerHandler.oppRecordSelector.mapRelatedAccounts);
        
        // Populate primary campaign source in Opportunity and update End Customer and End Customer Contact details in the Lead
        OpportunityFieldPopulator.populatePrimaryCampaignSource(OpportunityTriggerHandler.oppRecordSelector.lstChannelLeadOpps, OpportunityTriggerHandler.oppRecordSelector.setChannelLeadIds, OpportunityTriggerHandler.handler.trigEvent);
        
        // Validate the LOB Registration ID field and Update the hidden LOB Registration related fields
        OpportunityFieldPopulator.validateAndPopulateLOBRegistrationDetails(OpportunityTriggerHandler.oppRecordSelector.mapCreateDealFromLOBOpps, OpportunityTriggerHandler.oppRecordSelector.setLOBRegistrationIds, OpportunityTriggerHandler.handler);
        
        // Populate Region__c for the newly created Opportunity based on the Country__c field on the Opportunity Owner
        OpportunityFieldPopulator.populateRegionForSMBOpportunities(OpportunityTriggerHandler.oppRecordSelector.lstSMBOpportunities);
        
        // Populate SOC_Solution_Name_Console__c field based on the Solution_Name__c field
        OpportunityFieldPopulator.populateSOCSolutionNameConsole(Trigger.new, null);
        
        // CR8276: Mohammad - Auto populate Partner Account Owner Email
        (new AutoPopulateCustomerNumber()).updatePartnerAccountEmail(Trigger.new);
        
        // Create End Customer, End Customer Contact, Partner Request and populate details in the Opportunity
        OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(Trigger.new, null);
        
        // CR 10068 - Create Campaign Share for opportunity owners
        CampaignSharingUtilities.createCampaignShare(Trigger.new, null, OpportunityTriggerHandler.handler.trigEvent);
        
        // MARKER - Ragu on 10-Oct-2014 (Valid till 16.03): Below line is commented as part of CR10496 as this doesn't make sense on Opportunity before insert. 
        // Set Send_Notification__c field in S_P_Vendor__c object to false to disable notifications when an Opportunity is closed
        //OpportunityUtilities.updateSnPNotificationField(oppRecordSelector.setOppIdsToDisableSnPNotification);
        
        // Link Opportunity with Account Play based on the Lattice_PreLead_External_Id__c
        OpportunityUtilities.linkToAccountPlay(OpportunityTriggerHandler.oppRecordSelector.lstLatticePreLeadOpps, OpportunityTriggerHandler.oppRecordSelector.setLatticePreLeadIds);
        
        // Populate LOTOcean related fields
          LOTOcean.populateLOTOceanRelatedDetails(Trigger.new);
        
        // Automatically update on the APOS Renewed Opportunities when it meets certain criterias
        OpportunityFieldPopulator.updateRenewedAPOSOpportunities(Trigger.new);
          
        // When navigating from OSC url contains unwanted %3A, which is causing issue of deal sync. this is to avoid that
        OpportunityFieldPopulator.formatOSCid(Trigger.new, OpportunityTriggerHandler.handler.trigEvent); 
        
        //v12.0 - start: *** [IMPORTANT] PLEASE KEEP THIS METHOD AT THE END, because the logics are from workflow rule which suppose to be executed after all triggers execution ***
        OpportunityFieldPopulator.workflowFieldUpdate (OpportunityTriggerHandler.handler.trigEvent, Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        //v12.0 - end: *** [IMPORTANT] PLEASE KEEP THIS METHOD AT THE END, because the logics are from workflow rule which suppose to be executed after all triggers execution ***  

        OpportunityFieldPopulator.populateDistiResellerAccName(Trigger.new, null);
        
        // 7386950 : SyncStageValuesOnDeals RE138- Dev Fix 1-1003 
       // SyncStageValuesOnDeals.SyncStageValues(Trigger.new, null); 
       // to resolve 101 move PB 3 Actions into Triggers
       OpportunityFieldPopulator.appendEndUserAccountNameWithOpptyName(Trigger.new, null);

		//25.0 Overwrite Use Case field only for Sales Rep E users: Use Case Category (Domain__c) | Basic Hardware/Software Sale, Use Case Sub-category (Solution_Type__c) | Datacenter- Hardware Refresh, Use Case (Solution_Name__c) | Storage based if User's profile is Sales Rep E
       OpportunityFieldPopulator.populateUseCaseFields(OpportunityTriggerHandler.handler.trigEvent, Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
    }
}