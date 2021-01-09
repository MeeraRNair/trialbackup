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
public class OpportunityTriggerHandlerAU implements AfterUpdate {
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        system.debug('Entered Opportunity handleAfterUpdate');
        
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
        OpportunityUtilities.updateRSSSupportRequest(OpportunityTriggerHandler.oppRecordSelector.setClosedOppIds);
        
        // Recalculate Open / Closed Opportunity Values in SFDC_Strategy__c whenever Related_Strategy__c / Amount / StageName / ClosedDate is changed
        OpportunityUtilities.recalculateStrategyValues(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, OpportunityTriggerHandler.handler.trigEvent);
        
        // Update Deal_Summary__c whenever StageName / CloseDate / Opportunity_Plan__c / Related_Strategy__c / Scheduled_Opportunity__c is changed
        OpportunityUtilities.updateDealSummary((map<Id, Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Create Oppt_Description_History__c for Standard and Channel Opportunities whenever Description is changed
         If(OpportunityTriggerHandler.oppRecordSelector.lstDescChangedOpps.size() > 0){
            OpportunityUtilities.createOpportunityDescriptionHistory(JSON.serialize(OpportunityTriggerHandler.oppRecordSelector.lstDescChangedOpps));
        } 
        // Create SOM_Boomi_Log__c whenever Opportunity OwnerId / Services_Sales_Owner__c is changed and Services_Project_Count__c > 0
        OpportunityUtilities.createSOMBoomiLogs(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, OpportunityTriggerHandler.oppRecordSelector.mapRelatedRecords);
        
        // CR8966 - 27-Dec-2013: Update OpportunityLineItems Dell_Business_Model__c based on the Deal_Registration_Status__c of Opportunity and Dell_Business_Model__c of Product 
        (new OpportunityLineItemUpdateController()).UpdateOLI(OpportunityTriggerHandler.oppRecordSelector.lstDealRegUpdatedOppIds);
        
        // Update the Last Modified Date and Last Modified By field in the related S_P_Vendors__c record
        SnPUtilities.updateRelatedSnPVendors(OpportunityTriggerHandler.oppRecordSelector.setCloseDateStageNameUpdatedOppIds);
        
        // Create Solution Certificate for all applicable Opportunities 
        OpportunityUtilities.createSolutionCertificate(OpportunityTriggerHandler.oppRecordSelector.setOppIdsForSolCert, OpportunityTriggerHandler.oppRecordSelector.mapOppsForSolCert);
        
        // Associate Partner Account to the Opportunity related list
        PartnerAccountAddition.associateToPartnerOpportunitiesRelatedList(OpportunityTriggerHandler.oppRecordSelector.mapOppIdPartnerAccountId);
        
        // Associate Disti/Reseller Account to the Opportunity related list
        PartnerAccountAddition.associateDistiAccountToPartnerOpportunitiesRelatedList(OpportunityTriggerHandler.oppRecordSelector.mapOppIdDistiAccountId);
        
        // Recalculate and update Quest Software Unweighted Rev and Quest Software Unweighted Margin Rev fields
        OpportunityUtilities.recalculateQuestRevenues(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, OpportunityTriggerHandler.handler.trigEvent);
        
        // Identify Opportunities and pass Deal_Id__c & StageName for Goal Deal integration
        GoalIntegrationUtils.processGoalIntegration(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
        // Update associated Channel Lead details and create Relationship_Lead__c as necessary 
        ChannelLeadUtilities.updateChannelLead(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, OpportunityTriggerHandler.handler.trigEvent);
        
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
         OpportunityUtilities.updateCustomerReqDate(trigger.new, (map<Id, Opportunity>)Trigger.oldMap, OpportunityTriggerHandler.handler.trigEvent);
        
        // v10.0 Call a webservice method to activate account when opportunity stage is greater than 30%
        // Included skip variable to avoid recursive calls
        //16.0 - commented by Ashok 
        /*
        if(!TriggerExecutionController.skipActivateAccount()) {
           // if(System.Label.AccountSuggestionIntegration == 'CIL') {
                AccountSuggestionIntegrationCIL.activateAccountInAffinity(oppRecordSelector.setActivateAccIds);
           // }
            //else{
           //     AccountSuggestionIntegration.activateAccountInAffinity(oppRecordSelector.setActivateAccIds);
           // }
            TriggerExecutionController.setSkipActivateAccount(true);
        }
        */
        // Update LOT indicator on Opportunity Product 
         OpportunityLineItemUtilities.updateLOTIndicator(OpportunityTriggerHandler.handler.trigEvent, OpportunityTriggerHandler.oppRecordSelector.mapRelatedRecords);
        
        
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
        //OpportunityUtilities.updateVisitOpsDetails((map<Id,Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap, oppTrigHandler.oppRecordSelector.mapRelatedAccounts, oppTrigHandler.oppRecordSelector.mapRelatedRecords);
        //moved the VO ligic to asyn job to overcome 101 issue
        //Edit: Rajiv Ranjan : Added the toggle logic to handle the VB sync feature using Opportunity change event trigger
        ToggleFeature__c vbToggle = ToggleFeature__c.getValues('VISIT_BUNDLE_SYNC_PLATFORM');
        if(vbToggle == null || vbToggle.Enable_Feature__c != true)
        {
        	System.enqueueJob(new OpportunityUtilities.VisitBundleAsyncExecution((map<Id,Opportunity>)Trigger.newMap, (map<Id, Opportunity>)Trigger.oldMap, OpportunityTriggerHandler.oppRecordSelector.mapRelatedAccounts, OpportunityTriggerHandler.oppRecordSelector.mapRelatedRecords));   
        } 
        

        //Populate or sync the standard and custom stage names on Deals
        SyncStageValuesOnDeals.SyncStageValues(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        //OpportunityFieldPopulator.autoPopulateFieldsafterupdate(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap, trigEvent, oppRecordSelector.mapRelatedAccounts);
        //Dell_Asset_RMA.Mib_Rules_Opportunity_Handler.triggerReplica(trigger.new,trigger.oldMap); 
        // OpportunityFieldPopulator.OpptyDetailsExtraRecCreation(trigger.new);

        Dell_Asset_RMA.Mib_Opportunity_Handler.triggerReplica(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        
       
    }

}