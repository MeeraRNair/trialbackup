/*
 * Author   : Ragu
 * Purpose  : Contains static members to control the execution of the trigger for any object. 
 *          By default all the objects trigger will run. If you want to skip any of the object trigger, set corresponding member value to true.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      10496       15.10           05-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      10751       16.03           03-Dec-2014     Ragu            Introduced variables for skipping Account, Contact, Case, User, Task, Idea, Attachment, Campaign and Contract triggers.
 * 3.0      11555       16.07           28-May-2015     Ragu            Introduced variables for skipping Lead, CampaignMember triggers.
 * 4.0      11414       16.06           30-Apr-2015     Kokila          Introduced variables for skipping Product2 trigger.
 * 5.0      12500       16.12           30-Dec-2015     Niveda          Created a variable to Skip CampaignValidator
 * 5.1      12451       16.12           11-Jan-2016     Ragu            Added method to skip the ActivateAccount integration call from Opportunity trigger.
 * 6.0      13668       FY17-DCS-0103   02-Nov-2016     Fenny           Introduced variables for skipping Opportunity Plan triggers
 * 6.1      13796       FY17-DCS-0103   09-Dec-2016     Fenny           Introduced variables for skipping Install Base triggers
 * 8.0      13902       FY18-DCS-0202   13-Jan-2017     Fenny           Introduced variables for skipping S&P Vendor triggers
 * 9.0      14068       FY18-DCS-0502   14-Mar-2017     Gan             Introduced variables for skipping GDM_Request Trigger
 * 10.0     15108       FY18-DCS-0203   09-Nov-2017     Krishna         Introduced variables for skipping Files related Triggers
 * 11.0     15172       FY18-DCS-0102   11-Nov-2018     Harsha          Introduced variables for skipping Territory Plan related Triggers
 * 12.0     5805649     FY18-           20-Nov-2018     Kshipra         Introduced variable for skipping the account trigger for partner accoount owner update
 * 12.0     XXXXXXX     FY20-           01-Dec-2019     Urvish          Introduced variable for skipping the opty Split
 * 13.0     7216521     FY20-0102       18-Nov-2019     Sarbjeet        Introduced variable for skipping the SupportRequest trigger. 
 * 14.0     CR#18325    FY20-0102       21-Nov-2019     Abhinav         Introduced variable for skipping the Role_Code__c trigger. 
 
*/

public class TriggerExecutionController {

    //skip Account trigger for partner owner change
    private static boolean skipAccountForQEProcess = false;
    public static void setSkipAccountForQEProcess(boolean bSkip) {
        skipAccountForQEProcess = bSkip;
    }
    
    public static boolean getSkipAccountForQEProcess() {
        return skipAccountForQEProcess;
    }
    // Skip all triggers
    private static boolean skipAllTriggers = false;
    public static void setSkipAllTriggers(boolean bSkip) {
        skipAllTriggers = bSkip;
    }
    public static boolean skipAllTriggers() {
        return skipAllTriggers;
    }
    
    // Skip Campaign triggers
    private static boolean skipCampaignTriggers = false;
    public static void setSkipCampaignTriggers(boolean bSkip) {
        skipCampaignTriggers = bSkip;
    }
    public static boolean skipCampaignTriggers() {
        return skipCampaignTriggers;
    }
    
    //Skip Campaign Validators in triggers 
    private static boolean skipCampaignValidator = false;
    public static void setSkipCampaignValidator(boolean bSkip) {
        skipCampaignValidator = bSkip;
    }
    public static boolean skipCampaignValidator() {
        return skipCampaignValidator;
    }
    
    // Skip Lead triggers
    private static boolean skipLeadTriggers = false;
    public static void setSkipLeadTriggers(boolean bSkip) {
        skipLeadTriggers = bSkip;
    }
    public static boolean skipLeadTriggers() {
        return skipLeadTriggers;
    }
    
    // Skip CampaignMember triggers
    private static boolean skipCampaignMemberTriggers = false;
    public static void setSkipCampaignMemberTriggers(boolean bSkip) {
        skipCampaignMemberTriggers = bSkip;
    }
    public static boolean skipCampaignMemberTriggers() {
        return skipCampaignMemberTriggers;
    }
    
    // Skip Account triggers
    private static boolean skipAccountTriggers = false;
    public static void setSkipAccountTriggers(boolean bSkip) {
        skipAccountTriggers = bSkip;
    }
    public static boolean skipAccountTriggers() {
        return skipAccountTriggers;
    }
    
    // Skip Contact triggers
    private static boolean skipContactTriggers = false;
    public static void setSkipContactTriggers(boolean bSkip) {
        skipContactTriggers = bSkip;
    }
    public static boolean skipContactTriggers() {
        return skipContactTriggers;
    }
    
    // Skip Opportunity triggers
    private static boolean skipOpportunityTriggers = false;
    public static void setSkipOpportunityTriggers(boolean bSkip) {
        if(bSkip){system.debug('>>>>>>>>>> - setSkipOpportunityTriggers - ' + bSkip);}
        skipOpportunityTriggers = bSkip;
    }
    public static boolean skipOpportunityTriggers() {
        return skipOpportunityTriggers;
    }
    
    // Skip OpportunitySplit triggers
    private static boolean skipOpportunitySplitTriggers = false;
    public static void setSkipOpportunitySplitTriggers(boolean bSkip) {
        if(bSkip){system.debug('>>>>>>>>>> - setSkipOpportunitySplitTriggers - ' + bSkip);}
        skipOpportunitySplitTriggers = bSkip;
    }
    public static boolean skipOpportunitySplitTriggers() {
        return skipOpportunitySplitTriggers;
    }
    
    // Skip Inventory Request triggers
    private static boolean bskipInventoryRequestTriggers = false;
    public static void setSkipInventoryRequestTriggers(boolean bSkip) {
        if(bSkip){system.debug('>>>>>>>>>> - setSkipOpportunityTriggers - ' + bSkip);}
        bskipInventoryRequestTriggers = bSkip;
    }
    public static boolean skipInventoryRequestTriggers() {
        return bskipInventoryRequestTriggers ;
    }
        
    // Skip Opportunity Validators in triggers 
    private static boolean skipOpportunityValidator = false;
    public static void setSkipOpportunityValidator(boolean bSkip) {
        skipOpportunityValidator = bSkip;
    }
    public static boolean skipOpportunityValidator() {
        return skipOpportunityValidator;
    }
    
    // v5.1 - Start
    // Skip activate account integration call
    private static boolean skipActivateAccount = false;
    public static void setSkipActivateAccount(boolean bSkip) {
        skipActivateAccount = bSkip;
    }
    public static boolean skipActivateAccount() {
        return skipActivateAccount;
    }
    // v5.1 - End
    
    // Skip OpportunityLineItem triggers
    private static boolean skipOpportunityLineItemTriggers = false;
    public static void setSkipOpportunityLineItemTriggers(boolean bSkip) {
        skipOpportunityLineItemTriggers = bSkip;
    }
    public static boolean skipOpportunityLineItemTriggers() {
        return skipOpportunityLineItemTriggers;
    }
    // Skip OpportunityTeamTriggers
    private static boolean bskipOpportunityTeamTriggers = false;
    public static void setskipOpportunityTeamTriggers(boolean bSkip) {
        bskipOpportunityTeamTriggers = bSkip;
    }
    public static boolean skipOpportunityTeamTriggers() {
        return bskipOpportunityTeamTriggers;
    }    
    // Skip BlacklistWordFilterOnComments triggers
    private static boolean bskipBlackListTriggers = false;
    public static void setSkipblacklistCommentsTriggers(boolean bSkip) {
        bskipBlackListTriggers = bSkip;
    }   
    public static boolean bskipBlackListTriggers() {
        return bskipBlackListTriggers;
    }
    // Skip BlacklistWordFilterOnUserStatus Swap triggers
    private static boolean bskipBlacklistuserstatusTriggers = false;
    public static void setskipBlacklistuserstatusTriggers (boolean bSkip) {
        bskipBlacklistuserstatusTriggers = bSkip;
    }
     public static boolean bskipBlacklistuserstatusTriggers () {
        return bskipBlacklistuserstatusTriggers;
    }
     // Skip BlacklistWordFilterOnPost triggers
    private static boolean bskipBlacklistWordFilterOnPostTriggers = false;
    public static void setskipBlacklistWordFilterOnPostTriggers (boolean bSkip) {
        bskipBlacklistWordFilterOnPostTriggers = bSkip;
    }
     public static boolean bskipBlacklistWordFilterOnPostTriggers() {
        return bskipBlacklistWordFilterOnPostTriggers;
    }
    // Skip Case triggers
    private static boolean skipCaseTriggers = false;
    public static void setSkipCaseTriggers(boolean bSkip) {
        skipCaseTriggers = bSkip;
    }
    public static boolean skipCaseTriggers() {
        return skipCaseTriggers;
    }
    
    // Skip User triggers
    private static boolean skipUserTriggers = false;
    public static void setSkipUserTriggers(boolean bSkip) {
        skipUserTriggers = bSkip;
    }
    public static boolean skipUserTriggers() {
        return skipUserTriggers;
    }
    
    // Skip Task triggers
    private static boolean skipTaskTriggers = false;
    public static void setSkipTaskTriggers(boolean bSkip) {
        skipTaskTriggers = bSkip;
    }
    public static boolean skipTaskTriggers() {
        return skipTaskTriggers;
    }
    
    // Skip Idea triggers
    private static boolean skipIdeaTriggers = false;
    public static void setSkipIdeaTriggers(boolean bSkip) {
        skipIdeaTriggers = bSkip;
    }
    public static boolean skipIdeaTriggers() {
        return skipIdeaTriggers;
    }
    
    // Skip Attachment triggers
    private static boolean skipAttachmentTriggers = false;
    public static void setSkipAttachmentTriggers(boolean bSkip) {
        skipAttachmentTriggers = bSkip;
    }
    public static boolean skipAttachmentTriggers() {
        return skipAttachmentTriggers;
    }
    
    // Skip Contract triggers
    private static boolean skipContractTriggers = false;
    public static void setSkipContractTriggers(boolean bSkip) {
        skipContractTriggers = bSkip;
    }
    public static boolean skipContractTriggers() {
        return skipContractTriggers;
    }
    
    // Skip Product2 triggers    
    private static boolean skipProduct2Triggers = false;    
    public static void setSkipProduct2Triggers(boolean bSkip) {        
        skipProduct2Triggers = bSkip;    
    }    

    public static boolean skipProduct2Triggers() {        
        return skipProduct2Triggers;    
    }
    
    // 6.0: Skip Opportunity Plan triggers    
    private static boolean skipOpportunityPlanTriggers = false;    
    public static void setSkipOpportunityPlanTriggers(boolean bSkip) {        
        skipOpportunityPlanTriggers = bSkip;    
    }    

    public static boolean skipOpportunityPlanTriggers() {        
        return skipOpportunityPlanTriggers;    
    }
    
    // 6.1: Skip Install Base triggers    
    private static boolean skipInstallBaseTriggers = false;    
    public static void setSkipInstallBaseTriggers(boolean bSkip) {        
        skipInstallBaseTriggers = bSkip;    
    }    

    public static boolean skipInstallBaseTriggers() {        
        return skipInstallBaseTriggers;    
    }
    
    // 7.0: Skip End Customer triggers    
    private static boolean skipEndCustomerTriggers = false;    
    public static void setskipEndCustomerTriggers(boolean bSkip) {        
        skipEndCustomerTriggers = bSkip;    
    }    

    public static boolean skipEndCustomerTriggers() {        
        return skipEndCustomerTriggers;    
    }
    
    // 8.0: Skip S&P Vendor triggers    
    private static boolean skipSnPVendorTriggers = false;    
    public static void setskipSnPVendorTriggers(boolean bSkip) {        
        skipSnPVendorTriggers = bSkip;    
    }    

    public static boolean skipSnPVendorTriggers() {        
        return skipSnPVendorTriggers;    
    }
    
    // 9.0: Skip GDM Request triggers    
    private static boolean skipGDMRequestTriggers = false;    
    public static void setskipGDMRequestTriggers(boolean bSkip) {        
        skipGDMRequestTriggers = bSkip;    
    }    

    public static boolean skipGDMRequestTriggers() {        
        return skipGDMRequestTriggers;    
    }
    
    // 10.0: Skip Files Related triggers    
    private static boolean skipContentVersionTriggers = false;    
    public static void setskipContentVersionTriggers(boolean bSkip) {        
        skipContentVersionTriggers = bSkip;    
    }    

    public static boolean skipContentVersionTriggers() {        
        return skipContentVersionTriggers;    
    }

    private static boolean skipContentDocLinkTriggers = false;    
    public static void setskipContentDocLinkTriggers(boolean bSkip) {        
        skipContentDocLinkTriggers = bSkip;    
    }    

    public static boolean skipContentDocLinkTriggers() {        
        return skipContentDocLinkTriggers;    
    }

    private static boolean skipContentDocTriggers = false;    
    public static void setskipContentDocTriggers(boolean bSkip) {        
        skipContentDocTriggers = bSkip;    
    }    

    public static boolean skipContentDocTriggers() {        
        return skipContentDocTriggers;    
    }
    
    //11.0 Skip Territory plan related triggers
    private static boolean skipTerritoryPlanTriggers = false;    
    public static void setskipTerritoryPlanTriggers(boolean bSkip) {        
        skipTerritoryPlanTriggers = bSkip;    
    }    

    public static boolean skipTerritoryPlanTriggers() {        
        return skipTerritoryPlanTriggers;    
    }
    
    // Skip Support Request triggers
    Private Static Boolean bskipSupportRequestTriggers = False;
    Public Static void setSkipSupportRequestTriggers(Boolean bSkip) {
        bskipSupportRequestTriggers = bSkip;
    }
    public Static Boolean skipSupportRequestTriggers() {
        Return bskipSupportRequestTriggers;
    }
    
    //14.0 Skip Role_Code__c triggers
    private static boolean bskipRoleCodeTriggers = false;
    public static void setSkipRoleCodeTriggers(boolean bSkip) {
        bskipRoleCodeTriggers = bSkip;
    }
    public static boolean skipRoleCodeTriggers() {
        return bskipRoleCodeTriggers;
    }
}