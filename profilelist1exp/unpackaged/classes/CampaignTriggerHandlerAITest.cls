/*
 * Author   : Ragu
 * Purpose  : Utility test class for creating Campaign related data. 
 *
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11480    16.07           18-May-2015     Ragu            Created.
 * 2.0      12720       FY17-DCS-0401   15-March-2016   Azwanti         replace Campaign RT from 'GBL_Standard_RT' and 'Channel Campaign' to 'Campaign 2.0'
 * 3.0    13386    FY17-DCS-1002   08-Sept-2016    Azwanti         add value to the Lead Routing field (mandatory)
 * 4.0    13805     FY17-DCS-0103  07-Dec-2016    Sajith      Updated the mandatory field Lead_Routing__c
 * 5.0                  0202       08-Dec-2016    Vikas KH      Implemetned TDF
 */
@isTest
public class CampaignTriggerHandlerAITest {
    //   public static boolean bCreate = true;
    // public static integer iNumberOfCampaigns = 5;
    // public static list<Campaign> lstCampaigns;
    static list<Account> listAcc;
    Static list<Campaign> listCamp;
    public static testMethod void createCampaign2() {
  /*      populateCommonCampaignFields();
        Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); 
        for(Campaign campaignIterator : lstCampaigns) {
            campaignIterator.RecordTypeId = campaign2RTId;
            campaignIterator.Allocation_Source__c = 'Channel APJ Agency 1';
            campaignIterator.Nurture_Source__c = 'Channel APJ Agency 1';
            //campaignIterator.Lead_Routing__c = 'Not Applicable'; //v3.0
        }
        if(bCreate) {
            insert lstCampaigns;
        }  */
        listCamp = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        listCamp[0].Allocation_Source__c = 'Channel APJ Agency 1';
        listCamp[0].Nurture_Source__c = 'Channel APJ Agency 1';
        insert listCamp;
        system.assertEquals(listCamp[0].Nurture_Source__c, listCamp[0].Nurture_Source__c);
    }
    public static testMethod void createStandardCampaign() {
    /*    populateCommonCampaignFields();
        Id stdCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); // v2.0 replace from 'GBL_Standard_RT' to 'Campaign 2.0'
        for(Campaign campaignIterator : lstCampaigns) {
            campaignIterator.RecordTypeId = stdCampaignRTId;
        }
        if(bCreate) {
            insert lstCampaigns;
        } */
        listCamp = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCamp;
        system.assertEquals(listCamp[0].Nurture_Source__c, listCamp[0].Nurture_Source__c);
    }
    public static testMethod void createChannelCampaign() {
     /*   populateCommonCampaignFields();
        Id channelCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); // v2.0 replace from 'Channel Campaign' to 'Campaign 2.0'
        for(Campaign campaignIterator : lstCampaigns) {
            campaignIterator.RecordTypeId = channelCampaignRTId;
            campaignIterator.Allocation_Source__c = 'Channel APJ Agency 1';
            campaignIterator.Nurture_Source__c = 'Channel APJ Agency 1';
        }
        if(bCreate) {
            insert lstCampaigns;
        } */
        listCamp = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        listCamp[0].Allocation_Source__c = 'Channel APJ Agency 1';
        listCamp[0].Nurture_Source__c = 'Channel APJ Agency 1';
        insert listCamp; 
        system.assertEquals(listCamp[0].Nurture_Source__c, listCamp[0].Nurture_Source__c);
    }
    
    private static testMethod void populateCommonCampaignFields() {
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Campaign", "Class_Name__c": "CampaignTriggerHandlerAI"},';
            }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Campaign';
        tec.RecursiveCount__c = 2;
        insert tec;
        listCamp = TestDataFactory.createNCampaign(5, 'Campaign 2.0');
        listCamp[0].OwnerId = UserInfo.getUserId();
        listCamp[0].IsActive = true;
        listCamp[1].OwnerId = UserInfo.getUserId();
        listCamp[1].IsActive = true;
        listCamp[2].OwnerId = UserInfo.getUserId();
        listCamp[2].IsActive = true;
        listCamp[3].OwnerId = UserInfo.getUserId();
        listCamp[3].IsActive = true;
        listCamp[4].OwnerId = UserInfo.getUserId();
        listCamp[4].IsActive = true;
        listCamp[4].Type = 'Sales Touch';
        insert listCamp;
        system.assertEquals(listCamp[4].Type, listCamp[4].Type);
     /* lstCampaigns = new list<Campaign>();
        for(integer i=0; i<iNumberOfCampaigns; i++) {
            Campaign campaignIterator = new Campaign();
            campaignIterator.Name = 'CampaignTestData__' + i;
            campaignIterator.Type = 'Sales Touch';
            campaignIterator.StartDate = System.Today() - 10; 
            campaignIterator.EndDate = System.Today();
            campaignIterator.Description = 'This is Test Campaign';
            campaignIterator.IsActive = true;
            campaignIterator.OwnerId = UserInfo.getUserId();
            //campaignIterator.Campaign_Objective__c = 'LOB Conversion';
            //campaignIterator.Segment_Business_Unit__c = 'PUB';
            //campaignIterator.Is_this_Account_Play_Campaign__c = false;
            campaignIterator.Account_Play_Expiry_Date__c = System.today() + 60;
            campaignIterator.Send_Notification__c = false;
            campaignIterator.Region__c = 'APJ';
            campaignIterator.Sub_Region__c = 'India';
            campaignIterator.Follow_Up_Role__c = '3rd Party Software Tech Sales Rep Mgr';
            campaignIterator.Secondary_Role__c = '3rd Party Software Tech Sales Rep';
            //campaignIterator.Lead_Routing__c = 'Not Applicable';//4.0
            lstCampaigns.add(campaignIterator);
        }
        */
    }
}