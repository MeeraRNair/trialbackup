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
*/
public class OpportunityTriggerHandlerBU implements BeforeUpdate{
    
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        system.debug('Entered Opportunity handleBeforeUpdate');
        
        system.debug('@#debug TriggerExecutionController.skipOpportunityValidator()'+ TriggerExecutionController.skipOpportunityValidator());
        
        if(!TriggerExecutionController.skipOpportunityValidator()) {
               //To verify if edit is dont valid user after unlock
            OpportunityValidator.validateUnlockEdit(Trigger.new);
            
            // v2.0 Check to see whether Credit Card information is in the opportunity fields
            OpportunityValidator.validateCreditCardInformation(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);            
            
            // Check to see whether Opportunity is qualified for DGR Control Panel
            OpportunityValidator.validateOpportunities(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
            
            // Validate Opportunity CloseDate
            //OpportunityValidator.validateCloseDate((map<Id, Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap);
    
            // Validate Channel_Lead_Id__c associated with the Opportunity and Populate CampaignId
            OpportunityValidator.validateChannelLeads(OpportunityTriggerHandler.oppRecordSelector.lstChannelLeadOpps, OpportunityTriggerHandler.oppRecordSelector.setChannelLeadIds);
            
            // Validate Stage change for Cloud Client Computing Opportunities
            OpportunityValidator.validateStageChangeForCloudClientComputingOpps(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, OpportunityTriggerHandler.oppRecordSelector.mapRelatedRecords);
            
             // Validate Opportunity CloseDate
            OpportunityValidator.validateCloseDate((map<Id, Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap);
            
             // Check to see whether Opportunity Fullfilment Path is Distribution or not - CR 12704
            OpportunityValidator.validateFulfilmentPathForDistributor(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
            
            // Check to see whether Opportunity Team Mail Box Email domain with loggedin User Domain
            OpportunityValidator.validateTeamMailboxDomain(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
            
            //Make Distributor/Reseller Account Name Blank when Fulfilment Path is updated to Direct Fulfilment
            OpportunityValidator.checkOnFulfilmentPath(Trigger.new,(map<Id, Opportunity>)Trigger.oldMap);
            
            OpportunityValidator.validateActiveEndCustomer(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
            
            // 08219 – Auto-Populate fields when closed by MyQuotes
            //OpportunityFieldPopulator.OpportunityUpdateList(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, oppTrigHandler.trigEvent);
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
        OpportunityFieldPopulator.autoPopulateFields(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, OpportunityTriggerHandler.handler.trigEvent, OpportunityTriggerHandler.oppRecordSelector.mapRelatedAccounts);
        
        // Populate primary campaign source in Opportunity
        OpportunityFieldPopulator.populatePrimaryCampaignSource(OpportunityTriggerHandler.oppRecordSelector.lstChannelLeadOpps, OpportunityTriggerHandler.oppRecordSelector.setChannelLeadIds, OpportunityTriggerHandler.handler.trigEvent);
        
        // Validate the LOB Registration ID field and Update the hidden LOB Registration related fields
        OpportunityFieldPopulator.validateAndPopulateLOBRegistrationDetails(OpportunityTriggerHandler.oppRecordSelector.mapCreateDealFromLOBOpps, OpportunityTriggerHandler.oppRecordSelector.setLOBRegistrationIds, OpportunityTriggerHandler.handler);
        
        // Populate SOC_Solution_Name_Console__c field based on the Solution_Name__c field
        OpportunityFieldPopulator.populateSOCSolutionNameConsole(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // CR8276: Mohammad - Partner Account Owner Email Auto Populate
        (new AutoPopulateCustomerNumber()).updatePartnerAccountEmail(Trigger.new);
        
        // (CR10468) Mini Sprint16.03: Mohammad - update Order Compliance Product field of Oppty, Quote requried for 60% 
        OpportunityFieldPopulator.populateOrderComplianceproduct(Trigger.new);
        
        // CR8681, Monthly Sprint 3: To update the PUSHED DEALS field when close date changes.
        OpportunityWrapper.calculatePushedDeals(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Send email notification to SOC_Engagement@Dell.com whenever Stage changed for the Opportunities which has Support Requests which is not in "New" Status
        OpportunityEmailUtilities.sendEmailNotificationOnStageChange(OpportunityTriggerHandler.oppRecordSelector.mapOppsForNotification);
        
        // Create End Customer, End Customer Contact, Partner Request and populate details in the Opportunity
        OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Set Send_Notification__c field in S_P_Vendor__c object to false to disable notifications when an Opportunity is closed
        SnPUtilities.updateSnPNotificationField(OpportunityTriggerHandler.oppRecordSelector.setOppIdsToDisableSnPNotification);
        
        // Auto populate Partner Sales Rep Name, Emai and Phone when owner is changed.
        OpportunityUtilities.updatePartnerSalesRepDetails(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, OpportunityTriggerHandler.oppRecordSelector.mapRelatedRecords);
        
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
        /*v15.0
        if(oppRecordSelector.lstOfOpptysToBeAutoApprvd.size() > 0){
            OpportunityFieldPopulator.populateForAutoApproval(oppRecordSelector.lstOfOpptysToBeAutoApprvd);
        }v15.0*/
        
        //v12.0 - start: *** [IMPORTANT] PLEASE KEEP THIS METHOD AT THE END, because the logics are from workflow rule which suppose to be executed after all triggers execution ***
        OpportunityFieldPopulator.workflowFieldUpdate (OpportunityTriggerHandler.handler.trigEvent, Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        //v12.0 - end: *** [IMPORTANT] PLEASE KEEP THIS METHOD AT THE END, because the logics are from workflow rule which suppose to be executed after all triggers execution ***
        
        OpportunityFieldPopulator.populateDistiResellerAccName(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        //V12.0 
        OpportunityFieldPopulator.populatePartnerNotificationEmail(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
      //  OpportunityFieldPopulator.populateAccountName(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
         AutoPopulateAccountNameFromEndCustomer.populateAccountName(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
         //7386950 : SyncStageValuesOnDeals RE138- Dev Fix 1-1003 
       //  SyncStageValuesOnDeals.SyncStageValues(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);

     
         
     // V1.0 Deal registration cancellation within 90 day protection
   // if(Userinfo.getProfileId()=='00eA0000000hNqF' ? TRUE : !(System_Behavior_Bypasser__c.getInstance(userinfo.getUserId()).Bypass_Opportunity_VRs__c))
    if(Userinfo.getProfileId()== System.Label.Boomiprofile ? TRUE : ( !(System_Behavior_Bypasser__c.getInstance(userinfo.getUserId()).Bypass_Opportunity_VRs__c) && !(Opportunity_lost_cancel_VR_bypass_profil__c.getInstance(userinfo.getUserId()).Bypass_Oppty_Lost_Cancel_VR_Profiles__c)  ))
    {
           OpportunityValidator.validateToChangeDealStage(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
    }
    If (UserInfo.getfirstName()== 'Renewals Core' && UserInfo.getLastName() == 'Integration User'){
            If (listNew!= null){ 
                list<opportunity> listOpty = New list<opportunity> ();
                listOpty = RenewalOpportunity_Utils.checkIfRenewalsOppty(listNew);
                If (!listOpty.isEmpty()){
                    //RenewalOpportunityTriggerHandler.validateEmcOppNumberRenewalbeforeInsert(listOpty);    
                } 
            }
        }       

     //Check and populate 'EMC Opportunity updated' field for 'Lost, Cancelled - 0%'
    OpptyWaitforSyncUpdate_forLostDeals.PopulateEMCOpportunityupdated(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
    // To resolve 101 soql the logic moved to trigger from Work flow.
    OpportunityFieldPopulator.populateResubmittedforApprovalDateTime(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
      // To resolve 101 soql the logic moved to trigger from PB 3 action.
      OpportunityFieldPopulator.appendEndUserAccountNameWithOpptyName(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
      OpportunityFieldPopulator.OpptyDetailsExtraRecUpdate(Trigger.new);
    //V21.0 Populate forecast flag summary
    //OpportunityFieldPopulator.populateforecastflagsummary((map<Id, Opportunity>)Trigger.newMap,(map<Id, Opportunity>)Trigger.oldMap); 
    }

}