/**
 * @File Name          : CampaignTriggerHandlerBUTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/5/2019, 10:01:48 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/5/2019, 10:01:48 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@IsTest
public class CampaignTriggerHandlerBUTest {
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
         //   campaignIterator.Lead_Routing__c = 'Not Applicable'; //v3.0
        }
        if(bCreate) {
        	insert lstCampaigns;
            
        }
    }
    
    public static testMethod void updateCampaign(){
        populateCommonCampaignFields();
        
        Campaign campaignIterator = new Campaign();
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
           // campaignIterator.Lead_Routing__c = 'Not Applicable';//4.0 
           
        Insert campaignIterator;
        
        Campaign cm1 = [Select Id,Name,Type,StartDate,EndDate,Description from Campaign where Name = 'CampaignTestData'];
        cm1.Description = 'This is Test Campaign for Update';
        update cm1;
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
        
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Campaign", "Class_Name__c": "CampaignTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Campaign';
        tec.RecursiveCount__c = 2;
        insert tec;
        
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
            lstCampaigns.add(campaignIterator);
    	}
    }
}