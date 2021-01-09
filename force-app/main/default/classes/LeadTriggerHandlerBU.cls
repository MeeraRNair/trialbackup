/*
 * Author   : Ragu
 * Purpose  : Gives abstract view of all the business logics / functionalities implemented on Lead.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11555       16.07           28-May-2015     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      11837       16.10           19-Aug-2015     Niveda          Validate users associated in the Dell Lead Follow Up - LM2.0.
 * 2.1      11842       16.10           20-Aug-2015     Syidah          Populate latest reassignment date when lead owner got change
 * 2.2      11874       16.10           25-Aug-2015     Azwanti         Invoke LeadFieldPopulator to populate Lead Owner's Manager before insert and before update
 * 2.3      11925       16.10           03-Sep-2015     Ragu            Implement the identified validation related Lead trigger functionalities for Lead 2.0
 * 2.4      11925       16.10           04-Sep-2015     Ragu            Implement the identified field population Lead trigger functionalities for Lead 2.0
 * 2.5      11967       16.10           17-Sep-2015     Ragu            LM2_1_33-Ability to assign lead owner by following campaign automation
 * 2.6      11976       16.10           18-Sep-2015     Josie           LM2_1_32-Ability to trigger lead owner assignment with campaign assignment logic
 * 2.7      11955       16.10           22-Sep-2015     Azwanti         Added BYPASS_createLeadFromCM validation to skip CM creation if Lead is created from the Create Direct Lead button in Campaign Member page.
 * 2.8      12064       16.10           12-Oct-2015     Ragu            LM2_1_71-Route to Segment Process
 * 3.0      12336       16.12           13-Nov-2015     Ragu            LM2_1_76-Enhance related account change in Direct Lead 2.0
 * 3.1      12369       16.12           01-Dec-2015     Ragu            LM2_1_104-Add RAD account field into Direct Lead 2.0 page
 * 3.2      12494       16.12           30-Dec-2015     Nagendra Singh  LM2_17_8-Enhance in direct Lead 2.0 the field Lead owner's role
 * 4.0      12722       FY17-DCS-0401   10-Mar-2015     Gan             Skip evaluateTrackingFields when execution counter > 1
 * 5.0      13002       FY17-DCS-0502   30-Mar-2016     Azwanti         LM2_17-Add Lead velocity fields and calculation in Direct Lead 2.0 
 * 6.0      13244       FY17-DCS-0703   13-Jun-2016     Jessie          Convert some validation rules to trigger (to reduce the lead limit issues) 
 * 7.0      13693       FY17-DCS-0103   01-Nov-2016     Sajith          LM2 New calculation for number days sales to follow up
 * 8.0      14188       FY18-DCS-0602   18-Apr-2017     Ashok           LM2_17- Analysis to Fix updating close date for leads with accepted status
 * 9.0      16833       FY19-DCS-0101   16-Nov-2018     Yamini          Commented code calling populateFAPLeadData as it is being called from CMAP trigger
 *10.0      16874       FY20-DCS-0202   29-Nov-2018     Sajith          Populate Zift Channel Leads with Partner Account and Partner User 
 *11.0      17549       FY20-0702       24-May-2019     Fenny           LeadTriggerHandler obsolete. Above histories and below methods calls are copied from LeadTriggerHandler
 *12.0      18306       FY20-DCE-0102   16-Nov-2019     Fenny           Make LeadRecordSelector accessible as static variable from LeadTriggerHandler
*/
public class LeadTriggerHandlerBU implements BeforeUpdate{
    
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        system.debug('Entered Lead handleBeforeUpdate');
        
        // VALIDATION BLOCK: ALL YOUR VALIDATION RELATED LOGICS SHOULD BE HERE
        {
            //v1.0 Validate Double byte characters in company and address fields
            LeadValidator.validateDoubleByte(Trigger.New, LeadTriggerHandler.leadRecSelector.mapRelatedCountries);
            
            if(!LeadTriggerHandler.leadRecSelector.lstDirectLeads2.isEmpty()) {
                // v2.0 - Validate users associated in the Dell Lead Follow Up section
                LeadValidator.validateDirectLead2(LeadTriggerHandler.leadRecSelector.lstDirectLeads2);
            }
            
            if(!LeadTriggerHandler.leadRecSelector.lstChannelLeads.isEmpty()) {
                // v2.3 - Validate whether duplicate Channel Lead is being created / it is scored
                LeadValidator.validateDuplicateChannelLeads(LeadTriggerHandler.leadRecSelector.lstChannelLeads, (map<Id, Lead>)Trigger.oldMap);
            }
        }
        
        // FIELD POPULATION BLOCK: ALL YOUR FIELD POPULATION RELATED LOGICS SHOULD BE HERE
        // v3.1 - Updated the order in this section: Moved populateLead2Fields() after Account population
        {
            if(!LeadTriggerHandler.leadRecSelector.lstLeads2.isEmpty()) {
                LeadFieldPopulator.clearRelatedContactOnAccountChange(LeadTriggerHandler.leadRecSelector.lstLeads2, (map<Id, Lead>)Trigger.oldMap, LeadTriggerHandler.leadRecSelector.mapRelatedContacts);
            }
            
            if(!LeadTriggerHandler.leadRecSelector.lstDLsToPopulateAccount.isEmpty()) {
                // v2.4 - Auto populate Account details for Direct Lead 2.0
                LeadFieldPopulator.populateAccountForDirectLeads2(LeadTriggerHandler.leadRecSelector.lstDLsToPopulateAccount, LeadTriggerHandler.leadRecSelector.mapRelatedContacts);
            }
            
            if(!LeadTriggerHandler.leadRecSelector.lstCLsToPopulateAccount.isEmpty()) {
                // v2.4 - Auto populate Account details for Channel Lead 2.0
                LeadFieldPopulator.populateAccountForChannelLeads(LeadTriggerHandler.leadRecSelector.lstCLsToPopulateAccount, LeadTriggerHandler.leadRecSelector.mapRelatedContacts);
            }

            if(!LeadTriggerHandler.leadRecSelector.lstAllLeads2.isEmpty()) {
                // v2.4 - Populate fields for all LM 2.0 Leads
                LeadFieldPopulator.populateLead2Fields(LeadTriggerHandler.leadRecSelector.lstAllLeads2, (map<Id, Lead>)Trigger.oldMap, LeadTriggerHandler.handler);
                //v3.2 - Populate lead owner role for Direct leads 2.0
                LeadFieldPopulator.populateLeadOwnerRole(LeadTriggerHandler.leadRecSelector.lstDirectLeads2, (map<Id, Lead>)Trigger.oldMap);
                //v7.0 - Populate the First Sales Assigned date and time 
                LeadFieldPopulator.populateSalesAssignedDate(LeadTriggerHandler.leadRecSelector.lstDirectLeads2,(map<Id, Lead>)Trigger.oldMap);
                //v5.0 - call method to populate Sales Follow Up Days field
                LeadFieldPopulator.populateSalesFollowUpDays(LeadTriggerHandler.leadRecSelector.lstDirectLeads2,(map<Id, Lead>)Trigger.oldMap);                
            }
            
            if(!LeadTriggerHandler.leadRecSelector.lstUIRoutedCLs.isEmpty()) {
                // v2.8 - Populate fields when Channel Lead is being routed back to Direct Lead 2.0 from Salesforce UI
                LeadRouter.populateFieldsForR2SFromUI(LeadTriggerHandler.leadRecSelector.lstUIRoutedCLs);
            }
            
            if(!LeadTriggerHandler.leadRecSelector.lstBatchRoutedCLs.isEmpty()) {
                // v2.8 - Routes Channel Leads to Direct Lead 2.0 when routing is initiated from batch upload
                LeadRouter.routeToSegmentForBatch(LeadTriggerHandler.leadRecSelector, (map<Id, Lead>)Trigger.oldMap);
            }            
        }

        
        // SPECIAL BLOCK: BELOW BLOCK SHOULD BE THE LAST BLOCK INSIDE THIS FUNCTION - Please add your new method invocations above this block.
        {
            if(!LeadTriggerHandler.leadRecSelector.mapRelatedContacts.isEmpty()) {
                // v3.0 - Start: This is now implemented in validation rules
                // v2.3 - Validate whether Related Contact associated with the Direct Lead is belongs to the Account which is selected in that Direct Lead.
                //LeadValidator.validateRelatedContactForDL(leadRecSelector.lstDirectLeads2, leadRecSelector.mapRelatedContacts);
                // v3.0 - End
                
                // v2.3 - Validate whether Related Contact associated with the Channel Lead is belongs to the Account which is selected in that Channel Lead.
                LeadValidator.validateRelatedContactForCL(LeadTriggerHandler.leadRecSelector.lstChannelLeads, LeadTriggerHandler.leadRecSelector.mapRelatedContacts);
            }

            if(!LeadTriggerHandler.leadRecSelector.lstDirectLeads2.isEmpty()) {
                //4.0
                Integer iExecutionCounter = LeadTriggerHandler.handler.getExecutionCounter();
                System.debug('################### iExecutionCounter : ' + iExecutionCounter);
                if(iExecutionCounter<2)
                {
                    // v2.5 - Reevaluate the tracking fields for Dell Lead Follow-Up section
                    LeadAssignment.evaluateTrackingFields(LeadTriggerHandler.leadRecSelector.lstDirectLeads2, (map<Id, Lead>)Trigger.oldMap);
                }
                
                // v2.6 - Trigger Lead assignment logic if required criterias met
                LeadAssignment.triggerLeadAssignment(LeadTriggerHandler.leadRecSelector.lstDirectLeads2, (map<Id, Lead>)Trigger.oldMap, LeadTriggerHandler.leadRecSelector.mapRelatedCampaigns);
                
                // v2.1 - Populate Last Owner Reassignment Date when Direct Lead 2.0 get updated
                LeadFieldPopulator.populateLastOwnerReassignmentDate(LeadTriggerHandler.leadRecSelector.lstDirectLeads2, (map<Id, Lead>)Trigger.oldMap);
            }

            // v2.4 Start: This logic rewritten in to CMAP_BeforeInsertUpdateLeadTrigger because the order of the execution between LeadTrigger & CMAP_BeforeInsertUpdateLeadTrigger is causing some issues.
            /*
            // v2.2 - Invoke LeadFieldPopulator populate Lead Owner's Manager
            if(!leadRecSelector.lstLeads2.isEmpty()) {
                LeadFieldPopulator.populateLeadOwnerManager(leadRecSelector.lstLeads2, (map<Id, Lead>)Trigger.oldMap);
            }
            */
            // v2.4 End: This logic rewritten in to CMAP_BeforeInsertUpdateLeadTrigger because the order of the execution between LeadTrigger & CMAP_BeforeInsertUpdateLeadTrigger is causing some issues.
        }
        
        //v6.0 - start
        //All these logics copied from validation rules. Therefore it is better to put it end of the 'before update trigger' as validation rules normally executes after 'before trigger'. 
        LeadValidator.validateAccountOwner(Trigger.new, LeadTriggerHandler.leadRecSelector.mapRelatedAccountOwners );
        LeadValidator.validatePostalPhoneNumberNPhysicalPhoneNumber(Trigger.new, LeadTriggerHandler.leadRecSelector.mapRelatedCountries );
        LeadValidator.validateToPreventLeadWithInactiveAccount(Trigger.new, LeadTriggerHandler.leadRecSelector.mapRelatedContacts);
        LeadValidator.validatePartnerAccountNPartnerUser(Trigger.new, LeadTriggerHandler.leadRecSelector.mapRelatedUsers, LeadTriggerHandler.leadRecSelector.mapRelatedAccounts);
        //v6.0 - end
    }

}