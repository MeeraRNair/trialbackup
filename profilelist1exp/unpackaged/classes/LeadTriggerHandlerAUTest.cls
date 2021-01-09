@IsTest
public class LeadTriggerHandlerAUTest {
	public static boolean bCreate = true;
    public static integer iNumberOfLeads = 5;
    public static list<Lead> lstLeads;
    
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }
    
    public static testMethod void UpdateLeadTest(){
        populateCommonLeadFields();
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        Id channelLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');

		Campaign cam = new Campaign();
        cam.Name = 'Test Cam';
        cam.StartDate = Date.Today().addDays(5);
        cam.EndDate = Date.Today().addDays(15);
		cam.IsActive = true;
        insert cam;
        
        TriggerExecutionController.setSkipLeadTriggers(true);
    	Lead leadIterator = new Lead();
        leadIterator.RecordTypeId = directLead2RTId;
        leadIterator.FirstName = 'Direct';
        leadIterator.LastName = 'Lead_';
        leadIterator.Email = '123456@test.com';
        leadIterator.Phone = '123456789';
        leadIterator.LeadSource = 'Web';
        leadIterator.Company = 'Dell Internal';
        leadIterator.Lead_Type__c = 'Inbound';
        leadIterator.Country = 'India';
        leadIterator.Status = 'Open';
		leadIterator.Campaign__c = cam.Id;
		leadIterator.Country_Code__c = 'AD';
        insert leadIterator;
        TriggerExecutionController.setSkipLeadTriggers(false);
        
        Lead l1 = [Select Id,Email,Status,Campaign__c,Country from Lead Where Id = :leadIterator.Id];
        l1.Email = 'email@test.com';
        l1.Status = 'Accepted';
        l1.RecordTypeId = channelLead2RTId;
        l1.Country = 'India';
        update l1;
    }

    /*public static testMethod void testLeadAfterUpdate() {
        populateCommonLeadFields();
      
      Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
      Lead l = new Lead();
      l.RecordTypeId = directLead2RTId;
      l.Status = 'New';
      l.Phone = '215125315325';
      l.Email = 'abc@dell.com';
      l.LastName = 'Lead Last Name';
      l.Company = 'Lead Company';
      insert l;
      
      Lead insertedLead = [SELECT Status FROM Lead WHERE Id = :l.Id];
      insertedLead.Status = 'Qualified';
      update insertedLead;
    }*/
    
    private static testMethod void populateCommonLeadFields() {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Lead", "Class_Name__c": "LeadTriggerHandlerAU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Lead';
        tec.RecursiveCount__c = 2;
        insert tec;
    }
}