/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      17-June-2010   Azwanti         Created for CR2246, R11.7
2.0      08-Jan-2018    Kokila          FY20-DCE-0202 - Lead 2.0 - Campaign Status enhancements - "Aborted" status renamed to "Cancelled" 
--------------------------------------------------------------------------------------
*/

global class BatchUpdateCampaignMemberExecute implements Schedulable{
    
    global void execute(SchedulableContext sc) {
    
        BatchUpdateCampaignMember batchCampaignMemberUpd = new BatchUpdateCampaignMember ();
       /* batchCampaignMemberUpd.queryCampaignMember = 'Select c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, c.Campaign.Proceed_with_cancellation__c, '+
                                                     'c.CM_Status__c From CampaignMember c '+
                                                     'Where c.Campaign.Status = \'Aborted\' OR '+
                                                     '(c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\') OR '+
                                                     '(c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\')'; */
                                                 
       //v2.0 - Start
       /*batchCampaignMemberUpd.queryCampaignMember = 'SELECT c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, c.Campaign.Proceed_with_cancellation__c, '+
                                                     'c.CM_Status__c FROM CampaignMember c '+
                                                     'WHERE (c.Campaign.Status = \'Aborted\' AND c.Campaign.Proceed_with_cancellation__c = \'Yes\' AND c.CM_Status__c != \'Cancelled\') '+
                                                     'OR (c.Campaign.Proceed_with_cancellation__c != \'Yes\' AND ((c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\') '+
                                                     'OR (c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\') ))' ;*/
      
       batchCampaignMemberUpd.strQueryCampaignMember = 'SELECT c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, '+
                                                     'c.CM_Status__c FROM CampaignMember c '+
                                                     'WHERE (c.Campaign.Status = \'Cancelled\' AND c.CM_Status__c != \'Cancelled\') '+
                                                     'AND ((c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\') '+
                                                     'OR (c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\') )' ;
                                                    
      //v2.0 - End                                                       
        ID batchprocessid1 = Database.executeBatch(batchCampaignMemberUpd,200);  
    }   
}