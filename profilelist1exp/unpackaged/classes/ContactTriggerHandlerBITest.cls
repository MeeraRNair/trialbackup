@IsTest
public class ContactTriggerHandlerBITest {
    
	public static boolean bCreate = true;
    public static integer iNumberOfContacts = 5;
    public static list<Contact> lstContacts;
  
    public static testMethod void createContact() {
        populateCommonContactFields();
      
      Country__c country = new Country__c();
      country.Name = 'India';
      country.Code__c = 'IN';
      country.Region__c = 'APJ';
      country.Inc_Vendor_Name__c = 'Partner Advantage';
      country.Inc_Vendor_End_Point__c = 'https://www.dellpartnerincentives.com/UserManagement/UserManagementService.svc/Process';
      insert country;
      
      Account acc = new Account();
      acc.Name = 'testAccount123';
      acc.Type = 'Partner';
      acc.RecordTypeId = System.Label.RecType_Partner_Account;
      acc.Account_Country_Code__c = 'IN';
      insert acc;
      
      Id leadQualRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Lead Qualification');
      Lead l = new Lead();
      l.RecordTypeId = leadQualRTId;
      l.Status = 'New';
      l.Phone = '215125315325';
      l.Email = 'abc@dell.com';
      l.LastName = 'Lead Last Name';
      l.Company = 'Lead Company';
      insert l;
     
      Contact con = new Contact();
      con.AccountId = acc.Id;
      con.Email = 'test@test.com';
      con.phone = '6739';
      con.LastName = 'conLastName';
      con.FirstName = 'conFirstName';
      con.Status__c = 'Customer';
      con.Survey__c = 'yes';
      con.Decision_Making_Role__c = 'Technical Buyer';
      con.Source_Id__c = l.Id;
        insert con;
    }
    
    private static testMethod void populateCommonContactFields() {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Contact", "Class_Name__c": "ContactTriggerHandlerBI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Contact';
        tec.RecursiveCount__c = 2;
        insert tec;
    }
    
}