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
 * 4.0      CR11602     16.06(MIN-S-10) 12-June-2015    Anwar           Sending syncthe email to Campaign owner when the changed Opportunity campaign
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
public class OpportunityTriggerHandlerAI implements AfterInsert{
    
    public void handleAFterInsert(List<sObject> listNew){
        system.debug('Entered Opportunity handleAfterInsert');
        
        // Copy Partner Account's AccountTeamMembers to the LOB Opportunities OpportunityTeamMember
        OpportunityFieldPopulator.populateOpportunityTeamMembers(OpportunityTriggerHandler.oppRecordSelector.mapCreateDealFromLOBOpps);
        
        // Create Solution__c record for newly created Opportunity if OSC_Solution_ID__c is not null
        OpportunityUtilities.createSolutions(Trigger.new, OpportunityTriggerHandler.oppRecordSelector.mapRelatedAccounts);
        
        // Recalculate Open / Closed Opportunity Values in SFDC_Strategy__c if Related_Strategy__c and Amount is not null
        OpportunityUtilities.recalculateStrategyValues(Trigger.new, null, OpportunityTriggerHandler.handler.trigEvent);
        
        // Create Deal_Summary__c for newly created Opportunity - Logic is separated from DealSummaryOppty trigger
        if(!GlobalVariables.BYPASS_FUTURE_CALLS) {
            DealSummary.optyAdd(Trigger.newMap.keySet());
        }
        
        // CR8966 - 27-Dec-2013: Update OpportunityLineItems Dell_Business_Model__c based on the Deal_Registration_Status__c of Opportunity and Dell_Business_Model__c of Product 
        (new OpportunityLineItemUpdateController()).UpdateOLI(OpportunityTriggerHandler.oppRecordSelector.lstDealRegUpdatedOppIds);
        
        // Associate Partner Account to the Opportunity related list
         PartnerAccountAddition.associateToPartnerOpportunitiesRelatedList(OpportunityTriggerHandler.oppRecordSelector.mapOppIdPartnerAccountId);
        
        // Associate Disti/Reseller Account to the Opportunity related list
         PartnerAccountAddition.associateDistiAccountToPartnerOpportunitiesRelatedList(OpportunityTriggerHandler.oppRecordSelector.mapOppIdDistiAccountId);
        
        // Recalculate and update Quest Software Unweighted Rev and Quest Software Unweighted Margin Rev fields
        OpportunityUtilities.recalculateQuestRevenues(Trigger.new, null, OpportunityTriggerHandler.handler.trigEvent);
        
        // Added on 20-Aug-2008
        SalesTeamUtil.setDefaultSalesTeam(Trigger.new);
        
        // Associate Opportunities with Relationship Lead and Account Play
        MarketingOpptyAssnUtils.associateWithRelationshipLeadAndAccountPlay(Trigger.new);

        // Update associated Channel Lead details and create Relationship_Lead__c as necessary 
        ChannelLeadUtilities.updateChannelLead(Trigger.new, null, OpportunityTriggerHandler.handler.trigEvent);
        
        // 10068 - delete Campaign Share for opportunity owners
        CampaignSharingUtilities.deleteCampaignShare(Trigger.new, null, OpportunityTriggerHandler.handler.trigEvent);
        
        // Update supportability indicator on Account
        // 13.0 Start - To comment this method
        //OpportunityUtilities.updateSupportabilityIndicator(this.trigEvent, Trigger.new, null);
        // 13.0 End     
        
       //Add Engage Channel Deals Account Team Members
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnInserttoEngageChannelDeals(Trigger.new,null);
       
        // CR12020 add PartnerAccountTeamMember to DSG Opportunity
        /* v15.0 - Comment DSG related code, SEAHAWK
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnInsert(Trigger.new);
        v15.0*/
        
                        
        if(!TriggerExecutionController.skipOpportunityValidator()) {
            // v7.0 - Display an error message if the address information is missing
            OpportunityValidator.validateEndUserMailingAddress(Trigger.new, null);
        }
        
        OpportunityUtilities.updateCTICallLog(OpportunityTriggerHandler.handler.trigEvent, Trigger.new, null);
        
        // v10.0 Call a webservice method to activate account when opportunity stage is greater than 30%
       // if(System.Label.AccountSuggestionIntegration == 'CIL') {
       //16.0
       /*TriggerExecutionController.setSkipActivateAccount(true);
           AccountSuggestionIntegrationCIL.activateAccountInAffinity(oppRecordSelector.setActivateAccIds);
      //  }
       // else {
      //      AccountSuggestionIntegration.activateAccountInAffinity(oppRecordSelector.setActivateAccIds);
      //  } 
      TriggerExecutionController.setSkipActivateAccount(false);
      */ //16.0 End  
       
        //wanti - 
        String strURL= '/p/opp/SelectSearch?addTo='+Trigger.new[0].Id;//+OpptyId;
        system.debug('----URL-- wanti : '+strURL);
        pagereference page = new pagereference(strURL);
        page.setRedirect(TRUE);
        //return page;
      //CR Distributor or reseller account related Contacts
         DistributorResellerInsert.DistributorResellerInserts(Trigger.new, null);  
         
         
         
         //Populate or sync the standard and custom stage names on Deals before insert
         //Moved to OpportunityTriggerHandlerBI : 7386950 : SyncStageValuesOnDeals RE138- Dev Fix 1-1003 
         SyncStageValuesOnDeals.SyncStageValues(Trigger.new, null);  
         OpportunityFieldPopulator.OpptyDetailsExtraRecCreation(trigger.new);

         Dell_Asset_RMA.Mib_Opportunity_Handler.triggerReplica(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap); 
    }

}