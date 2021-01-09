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
public class LeadTriggerHandlerAUD implements AfterUndelete{
    
    public void handleAfterUndelete(List<sObject> listNew){
        System.debug('Entered Lead handleAfterUndelete');
        
    	if(!LeadTriggerHandler.leadRecSelector.lstAllLeads2.isEmpty()) {
            // v2.4 - Populate Total Leads and Total Contacts for a Campaign.
            LeadUtilities.rollupLeadsAndContactsForCampaign(LeadTriggerHandler.leadRecSelector.lstAllLeads2, null, LeadTriggerHandler.handler);
        }
    }

}