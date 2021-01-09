/*
 * Author   : Ragu
 * Purpose  : Test TriggerExecutionController class
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      10496       15.10           05-Sep-2014     Ragu           
 * 2.0      14068		FY18-DCS-0502	14-Mar-2017		Gan				Introduced variables for skipping GDM_Request Trigger
 * 3.0      15108       FY18-DCS-0201   08-Nov-2017     Krishna         Introduced variables for skipping Files related Triggers
 * 4.0		15172		FY18-DCS-0102   27-Nov-2017     Harsha 			Introduced variables for skipping Territory Plan related Triggers
 */
 
@isTest
public class TriggerExecutionController_Test {

    static testMethod void testUserDetails() {
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.skipAllTriggers();
        
        TriggerExecutionController.setSkipCampaignTriggers(false);
        TriggerExecutionController.skipCampaignTriggers();
        
        TriggerExecutionController.setSkipCampaignValidator(false);
        TriggerExecutionController.skipCampaignValidator();
        
        TriggerExecutionController.setSkipLeadTriggers(false);
        TriggerExecutionController.skipLeadTriggers();
        
        TriggerExecutionController.setSkipCampaignMemberTriggers(false);
        TriggerExecutionController.skipCampaignMemberTriggers();
        
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.skipAccountTriggers();
        
        TriggerExecutionController.setSkipContactTriggers(false);
        TriggerExecutionController.skipContactTriggers();
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.skipOpportunityTriggers();
        
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.skipOpportunityLineItemTriggers();
        
        TriggerExecutionController.setSkipCaseTriggers(false);
        TriggerExecutionController.skipCaseTriggers();
        
        TriggerExecutionController.setSkipUserTriggers(false);
        TriggerExecutionController.skipUserTriggers();
        
        TriggerExecutionController.setSkipTaskTriggers(false);
        TriggerExecutionController.skipTaskTriggers();
        
        TriggerExecutionController.setSkipIdeaTriggers(false);
        TriggerExecutionController.skipIdeaTriggers();
        
        TriggerExecutionController.setSkipAttachmentTriggers(false);
        TriggerExecutionController.skipAttachmentTriggers();
        
        TriggerExecutionController.setSkipContractTriggers(false);
        TriggerExecutionController.skipContractTriggers();
        
        TriggerExecutionController.setSkipProduct2Triggers(false);
        TriggerExecutionController.skipProduct2Triggers();
        
        TriggerExecutionController.setSkipOpportunityValidator(false);
        TriggerExecutionController.skipOpportunityValidator();
        
        TriggerExecutionController.setSkipActivateAccount(false);
        TriggerExecutionController.skipActivateAccount();
        
        TriggerExecutionController.setSkipOpportunityPlanTriggers(false);
        TriggerExecutionController.skipOpportunityPlanTriggers();
        
        TriggerExecutionController.setSkipInstallBaseTriggers(false);
        TriggerExecutionController.skipInstallBaseTriggers();
        
        TriggerExecutionController.setSkipSnPVendorTriggers(false);
        TriggerExecutionController.skipSnPVendorTriggers();
        
        //2.0
        TriggerExecutionController.setskipGDMRequestTriggers(false);
        TriggerExecutionController.skipGDMRequestTriggers();

        //3.0
        TriggerExecutionController.setskipContentVersionTriggers(false);
        TriggerExecutionController.skipContentVersionTriggers();
        TriggerExecutionController.setskipContentDocLinkTriggers(false);
        TriggerExecutionController.skipContentDocLinkTriggers();
        TriggerExecutionController.setskipContentDocTriggers(false);
        TriggerExecutionController.skipContentDocTriggers();
        
        //4.0
        TriggerExecutionController.setskipTerritoryPlanTriggers(false);
        TriggerExecutionController.skipTerritoryPlanTriggers();
    }

}