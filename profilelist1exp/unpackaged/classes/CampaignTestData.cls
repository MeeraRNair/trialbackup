/*
 * Author   : Ragu
 * Purpose  : Utility test class for creating Campaign related data. 
 *
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11480       16.07           18-May-2015     Ragu            Created.
 * 2.0      12720       FY17-DCS-0401   15-March-2016   Azwanti         replace Campaign RT from 'GBL_Standard_RT' and 'Channel Campaign' to 'Campaign 2.0'
 * 3.0      13386       FY17-DCS-1002   08-Sept-2016    Azwanti         add value to the Lead Routing field (mandatory)
 * 4.0      13805       FY17-DCS-0103   07-Dec-2016     Sajith          Updated the mandatory field Lead_Routing__c
 */
 
@isTest
public class CampaignTestData {
    
    public static boolean bCreate = true;
    public static integer iNumberOfCampaigns = 5;
    public static list<Campaign> lstCampaigns;
    
    public static testMethod void createCampaign2() {
        populateCommonCampaignFields();
        Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); 
        for(Campaign campaignIterator : lstCampaigns) {
            campaignIterator.RecordTypeId = campaign2RTId;
            campaignIterator.Allocation_Source__c = 'Channel APJ Agency 1';
            campaignIterator.Nurture_Source__c = 'Channel APJ Agency 1';
            campaignIterator.Lead_Routing__c = 'Not Applicable'; //v3.0
        }
        if(bCreate) {
            insert lstCampaigns;
        }
    }
    
    public static testMethod void createStandardCampaign() {
        populateCommonCampaignFields();
        Id stdCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); // v2.0 replace from 'GBL_Standard_RT' to 'Campaign 2.0'
        for(Campaign campaignIterator : lstCampaigns) {
            campaignIterator.RecordTypeId = stdCampaignRTId;
        }
        if(bCreate) {
            insert lstCampaigns;
        }
    }
    
    public static testMethod void createChannelCampaign() {
        populateCommonCampaignFields();
        Id channelCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); // v2.0 replace from 'Channel Campaign' to 'Campaign 2.0'
        for(Campaign campaignIterator : lstCampaigns) {
            campaignIterator.RecordTypeId = channelCampaignRTId;
            campaignIterator.Allocation_Source__c = 'Channel APJ Agency 1';
            campaignIterator.Nurture_Source__c = 'Channel APJ Agency 1';
        }
        if(bCreate) {
            insert lstCampaigns;
        }
    }
    
    private static testMethod void populateCommonCampaignFields() {
        lstCampaigns = new list<Campaign>();
        for(integer i=0; i<iNumberOfCampaigns; i++) {
            Campaign campaignIterator = new Campaign();
            campaignIterator.Name = 'CampaignTestData__' + i;
            campaignIterator.Type = 'Sales Touch';
            campaignIterator.StartDate = System.Today() - 10;
            campaignIterator.EndDate = System.Today();
            campaignIterator.Description = 'This is Test Campaign';
            campaignIterator.IsActive = true;
            campaignIterator.OwnerId = UserInfo.getUserId();
            campaignIterator.Campaign_Objective__c = 'LOB Conversion';
            campaignIterator.Segment_Business_Unit__c = 'PUB';
            campaignIterator.Is_this_Account_Play_Campaign__c = false;
            campaignIterator.Account_Play_Expiry_Date__c = System.today() + 60;
            campaignIterator.Send_Notification__c = false;
            campaignIterator.Region__c = 'APJ';
            campaignIterator.Sub_Region__c = 'India';
            campaignIterator.Follow_Up_Role__c = '3rd Party Software Tech Sales Rep Mgr';
            campaignIterator.Secondary_Role__c = '3rd Party Software Tech Sales Rep';
            campaignIterator.Lead_Routing__c = 'Not Applicable';//4.0
            lstCampaigns.add(campaignIterator);
        }
    }
    
}