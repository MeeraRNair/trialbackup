@IsTest
public class LeadTriggerHandlerBITest {
	
    public static boolean bCreate = true;
    public static integer iNumberOfLeads = 5;
    public static list<Lead> lstLeads;
    
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }
    
    public static testMethod void createDirectLead2() {
        populateCommonLeadFields();
      Campaign campaignIterator = new Campaign();
    		campaignIterator.Name = 'CampaignTestData';
			campaignIterator.Type = 'Sales Touch';
			campaignIterator.StartDate = System.Today() - 10;
            campaignIterator.EndDate = System.Today();
            campaignIterator.Description = 'This is Test Campaign';
            campaignIterator.IsActive = true;
            campaignIterator.OwnerId = UserInfo.getUserId();
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
           
        Insert campaignIterator;
        
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        for(Lead leadIterator : lstLeads) {
            leadIterator.Status = 'New'; //v5.0
            leadIterator.RecordTypeId = directLead2RTId;
            leadIterator.Campaign__c = campaignIterator.Id;
            leadIterator.Country_Code__c = 'AD';
        }
        
        //v3.0
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];        
        if(bCreate) {
            System.runAs(adminusr) { //v3.0
                insert lstLeads;
            }
        }
    }
    
    public static testMethod void createChannelLead2() {
        populateCommonLeadFields();
        Campaign campaignIterator = new Campaign();
        	
    		campaignIterator.Name = 'CampaignTestData';
			campaignIterator.Type = 'Sales Touch';
			campaignIterator.StartDate = System.Today() - 10;
            campaignIterator.EndDate = System.Today();
            campaignIterator.Description = 'This is Test Campaign';
            campaignIterator.IsActive = true;
            campaignIterator.OwnerId = UserInfo.getUserId();
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
           
        Insert campaignIterator;
        
        
        Id channelLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
        for(Lead leadIterator : lstLeads) {
            leadIterator.Status = 'Open - Channel Lead';
            leadIterator.RecordTypeId = channelLead2RTId;
            leadIterator.Campaign__c = campaignIterator.Id;
            leadIterator.Dell_Partner_can_contact_me__c = true;
           // leadIterator.Country_Code__c = ''; //to stop invoking flow make it as blank 
                      
        }
        
        //v3.0
        
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];  
        if(bCreate) {
            System.runAs(adminusr){ //v3.0
                System.debug('######## lstLeads ' +lstLeads);
                insert lstLeads;
            }
        }
        
    }
    
    private static testMethod void populateCommonLeadFields() {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Lead", "Class_Name__c": "LeadTriggerHandlerBI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Lead';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        lstLeads = new list<Lead>();
        //Country__c countryObj = [Select id,code__c,Is_Active_in_Affinity__c from Country__c where Is_Active_in_Affinity__c = true];
        for(integer i=0; i<iNumberOfLeads; i++) {
            Lead leadIterator = new Lead();
            leadIterator.FirstName = 'Direct';
            leadIterator.LastName = 'Lead_' + i;
            leadIterator.Email = '123456@test.com';
            leadIterator.Phone = '123456789';
            leadIterator.LeadSource = 'Web';
            leadIterator.Company = 'Dell Internal';
            leadIterator.Lead_Type__c = 'Inbound';
            leadIterator.Country = 'India';
          //  leadIterator.Marketing_Primary_Solution_Interest__c='Client Solutions';//3.1//6.0
            //leadIterator.Country_Code__c=countryObj.code__c;//4.0
          //  leadIterator.Country_Code__c='GB';//4.0
           // leadIterator.Department__c = 'DepartmentYes';
            lstLeads.add(leadIterator);
        }
    }
}