@IsTest
public class LeadTriggerHandlerADTest {
    public static boolean bCreate = true;
    public static integer iNumberOfLeads = 5;
    public static list<Lead> lstLeads;
    public static testMethod void DeleteLeadTest(){
        populateCommonLeadFields();
		Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
		Id channelLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
		
        Campaign cam = new Campaign();
        cam.Name = 'Test Cam';
        cam.StartDate = Date.Today().addDays(5);
        cam.EndDate = Date.Today().addDays(15);
		cam.IsActive = true;
        insert cam;
        
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
        Lead l1 = [Select Id,FirstName,LastName,Email,Status from Lead Where FirstName = 'Direct'];
     
        delete l1;
    }
    private static testMethod void populateCommonLeadFields() {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterDelete' => new List<Boolean>{false, false, false, true, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Lead", "Class_Name__c": "LeadTriggerHandlerAD"},';
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