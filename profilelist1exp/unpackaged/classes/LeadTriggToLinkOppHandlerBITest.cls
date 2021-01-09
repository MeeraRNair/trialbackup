@IsTest
public class LeadTriggToLinkOppHandlerBITest {  
    
   @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }
    public static testMethod void createDirectLead2() {
       String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Lead", "Class_Name__c": "LeadTriggToLinkOppHandlerBI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);

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
        
        Country__c   testCountryObject = new Country__c(name='Jedi Country', Dell_Online_Country_Code__c='JC',Code__c='JC',Enabled_Auto_Renewal__c=True,Last_Operation_Performed__c='Test Data');
        insert testCountryObject; 
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        
        Account testAccountObj =new Account(name='Renewal Test Account', Account_Country_Code__c = 'JC', Account_Country__c = 'Jedi Country', Approved_for_Partner_Finder__c = false);
        insert testAccountObj; 
        Opportunity testParentOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                                    RecordTypeId= '012A0000000Vjtg',
                                                    Name='TestParentOpportunity',
                                                    Type = 'Run Rate',
                                                    Domain__c='Deal Reg',
                                                    Solution_Type__c = 'Campus',
                                                    Solution_Name__c = 'Wireless Switches',
                                                    StageName='Plan - 1%',
                                                    Deal_Expiration_Timeframe__c='60',                                               
                                                    Request_Status__c='New', 
                                                    CloseDate= System.Now().Date().addDays(180), 
                                                    Forecast_Category_Override__c = 'Omitted',
                                                    Deal_Registration_Status__c = ' Approved');          
        insert testParentOpportunity;
       
        Opportunity oppObj = [Select Deal_Registration_Status__c,Id,Deal_ID__c FROM Opportunity Where Id = :testParentOpportunity.Id];
        
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
            Lead leadIterator = new Lead();
            leadIterator.FirstName = 'Direct';
            leadIterator.LastName = 'Lead_1';
            leadIterator.Email = '123456@test.com';
            leadIterator.Phone = '123456789';
            leadIterator.LeadSource = 'Web';
            leadIterator.Company = 'Dell Internal';
            leadIterator.Lead_Type__c = 'Inbound';
            leadIterator.Country = 'India';
            leadIterator.Status = 'New'; //v5.0
            leadIterator.RecordTypeId = directLead2RTId;
            leadIterator.Campaign__c = campaignIterator.Id;
            leadIterator.Country_Code__c = 'US';
            leadIterator.Deal_1_ID__c = oppObj.Deal_ID__c;
            leadIterator.Deal_2_ID__c = oppObj.Deal_ID__c;
            leadIterator.Deal_3_ID__c = oppObj.Deal_ID__c;
            leadIterator.Deal_4_ID__c = oppObj.Deal_ID__c;
            leadIterator.Deal_5_ID__c = oppObj.Deal_ID__c;
            leadIterator.Deal_6_ID__c = oppObj.Deal_ID__c;
            leadIterator.Channel_Lead_to_Deal__c = true;

            insert leadIterator;
        
          Lead objLead = [SELECT id,Related_Opportunity_1__c FROM Lead WHERE Id = :leadIterator.Id];
    System.assertEquals(objLead.Related_Opportunity_1__c, oppObj.Id);
    }
}