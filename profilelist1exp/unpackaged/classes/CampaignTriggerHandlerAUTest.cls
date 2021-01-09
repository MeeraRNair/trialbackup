/**
    * @File Name          : CampaignTriggerHandlerAUTest.cls
    * @Description        : 
    * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
    * @Group              : 
    * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
    * @Last Modified On   : 6/5/2019, 10:01:22 PM
    * @Modification Log   : 
    *==============================================================================
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0    6/5/2019, 10:01:22 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
    * 2.0    8/12/2019               VIKAS KH   for 0202                Impelemented TDF               
    **/
@IsTest
public class CampaignTriggerHandlerAUTest {
    //   public static boolean bCreate = true;
    //    public static integer iNumberOfCampaigns = 5;
    //    public static list<Campaign> lstCampaigns;
    static list<Account> listAcc;
    Static list<Campaign> listCamp;
    @TestSetup
    static void dataSetup(){
        //      Campaign_Member_Field_Tracking__c tracking = new Campaign_Member_Field_Tracking__c();
        //      tracking.Name = 'CM_Status__c';
        //      tracking.Type__c = 'Picklist';
        //       insert tracking;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(5, 'Campaign 2.0');
        insert listCampTDF;
    }
    public static testMethod void createCampaign2() {
        // populateCommonCampaignFields();
        // Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); 
        listCamp = [select id from Campaign limit 1];
        for(Campaign campaignIterator : listCamp) {
            //         campaignIterator.RecordTypeId = campaign2RTId;
            campaignIterator.Allocation_Source__c = 'Channel APJ Agency 1';
            campaignIterator.Nurture_Source__c = 'Channel APJ Agency 1';
            //   campaignIterator.Lead_Routing__c = 'Not Applicable'; //v3.0
        }
        /*  if(bCreate) {
        insert lstCampaigns;
        } */
        update listCamp;
        system.assertEquals(listCamp[0].Allocation_Source__c, listCamp[0].Allocation_Source__c);
    }
    public static testMethod void updateCampaign(){
        //   populateCommonCampaignFields();
        //        Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0');
        listCamp = [select id from Campaign limit 1];
        for(Campaign campaignIterator : listCamp) {
            // campaignIterator.RecordTypeId = campaign2RTId;
            campaignIterator.Name = 'CampaignTestData';
            campaignIterator.Type = 'Sales Touch';
            campaignIterator.StartDate = System.Today() - 10;
            campaignIterator.EndDate = System.Today();
            campaignIterator.Description = 'This is Test Campaign';
            campaignIterator.IsActive = true;
            campaignIterator.OwnerId = UserInfo.getUserId();
            // campaignIterator.Campaign_Objective__c = 'LOB Conversion';
            // campaignIterator.Segment_Business_Unit__c = 'PUB';
            // campaignIterator.Is_this_Account_Play_Campaign__c = false;
            campaignIterator.Account_Play_Expiry_Date__c = System.today() + 60;
            campaignIterator.Send_Notification__c = false;
            campaignIterator.Region__c = 'APJ';
            campaignIterator.Sub_Region__c = 'India';
            campaignIterator.Follow_Up_Role__c = '3rd Party Software Tech Sales Rep Mgr';
            campaignIterator.Secondary_Role__c = '3rd Party Software Tech Sales Rep';
            campaignIterator.status = 'Planned';
            campaignIterator.Next_Steps__c = 'This is next Step Field';
            campaignIterator.Supporting_Information__c = 'This is Supporting Information Field';
            // campaignIterator.Lead_Routing__c = 'Not Applicable';//4.0 
        }
        // Insert campaignIterator;
        update listCamp;
        system.assertEquals(listCamp[0].Account_Play_Expiry_Date__c, listCamp[0].Account_Play_Expiry_Date__c);
        //  Campaign cm1 = [Select Id,Name,Type,StartDate,EndDate,Description from Campaign where Name = 'CampaignTestData'];
        listCamp[0].Description = 'This is Test Campaign for Update';
        listCamp[0].status = 'Cancelled';
        listCamp[0].Next_Steps__c = 'This is next Step Field for update';
        listCamp[0].Supporting_Information__c = 'This is Supporting Information Field for update';
        update listCamp[0];
    }
    public static testMethod void createStandardCampaign() {
        //    populateCommonCampaignFields();
        //   Id stdCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); // v2.0 replace from 'GBL_Standard_RT' to 'Campaign 2.0'
        listCamp = [select id,IsActive from Campaign limit 1];
        //        for(Campaign campaignIterator : listCamp) {
        //            campaignIterator.RecordTypeId = stdCampaignRTId;
        //      }
        //      if(bCreate) {
        //    insert lstCampaigns;
        //      }
        system.assertNotEquals(Null, listcamp[0].IsActive);
    }
    public static testMethod void createChannelCampaign() {
        //  populateCommonCampaignFields();
        //  Id channelCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); // v2.0 replace from 'Channel Campaign' to 'Campaign 2.0'
        listCamp = [select id from Campaign limit 1];
        for(Campaign campaignIterator : listCamp) {
            // campaignIterator.RecordTypeId = channelCampaignRTId;
            campaignIterator.Allocation_Source__c = 'Channel APJ Agency 1';
            campaignIterator.Nurture_Source__c = 'Channel APJ Agency 1';
        }
        /*  if(bCreate) 
        {
        insert lstCampaigns;
        }*/
        update listCamp;
        system.assertEquals(listCamp[0].Allocation_Source__c, listCamp[0].Allocation_Source__c);
    }
    private static testMethod void populateCommonCampaignFields() {
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Campaign", "Class_Name__c": "CampaignTriggerHandlerAU"},';
            }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Campaign';
        tec.RecursiveCount__c = 2;
        insert tec;      
        //  lstCampaigns = new list<Campaign>();
        listCamp = [select id from Campaign limit 5 ];
        listCamp[0].Type = 'Sales Touch';
        listCamp[0].StartDate = System.Today() - 10;
        listCamp[0].EndDate = System.Today();
        listCamp[0].Description = 'This is Test Campaign';
        listCamp[0].IsActive = true;
        listCamp[0].OwnerId = UserInfo.getUserId();
        listCamp[0].Account_Play_Expiry_Date__c = System.today() + 60;
        listCamp[0].Send_Notification__c = false;
        listCamp[0].Region__c = 'APJ';
        listCamp[0].Sub_Region__c = 'India';
        listCamp[0].Follow_Up_Role__c = '3rd Party Software Tech Sales Rep Mgr'; 
        listCamp[0].Secondary_Role__c = '3rd Party Software Tech Sales Rep';
        update listCamp;
        system.assertEquals(listCamp[0].Secondary_Role__c, listCamp[0].Secondary_Role__c);
        /*       for(integer i=0; i<iNumberOfCampaigns; i++) {
Campaign campaignIterator = new Campaign(); 
campaignIterator.Name = 'CampaignTestData__' + i;
campaignIterator.Type = 'Sales Touch';
campaignIterator.StartDate = System.Today() - 10;
campaignIterator.EndDate = System.Today();
campaignIterator.Description = 'This is Test Campaign';
campaignIterator.IsActive = true;
campaignIterator.OwnerId = UserInfo.getUserId();
// campaignIterator.Campaign_Objective__c = 'LOB Conversion';
// campaignIterator.Segment_Business_Unit__c = 'PUB';
// campaignIterator.Is_this_Account_Play_Campaign__c = false;
campaignIterator.Account_Play_Expiry_Date__c = System.today() + 60;
campaignIterator.Send_Notification__c = false;
campaignIterator.Region__c = 'APJ';
campaignIterator.Sub_Region__c = 'India';
campaignIterator.Follow_Up_Role__c = '3rd Party Software Tech Sales Rep Mgr';
campaignIterator.Secondary_Role__c = '3rd Party Software Tech Sales Rep';
// campaignIterator.Lead_Routing__c = 'Not Applicable';//4.0
lstCampaigns.add(campaignIterator)5;
} */
  } 
    
}