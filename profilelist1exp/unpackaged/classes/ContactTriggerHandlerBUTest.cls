@IsTest
public class ContactTriggerHandlerBUTest {
public static boolean bCreate = true;
    public static integer iNumberOfContacts = 5;
    public static list<Contact> lstContacts;
  
    public static testMethod void updateContact(){
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
     
      Contact con = new Contact();
      con.AccountId = acc.Id;
      con.Email = 'test@test.com';
      con.phone = '6739';
      con.LastName = 'conLastName';
      con.FirstName = 'conFirstName';
      con.Status__c = 'Customer';
      con.Email_Opt_In__c = 'yes';
      con.Survey__c = 'yes';
      con.Decision_Making_Role__c = 'Technical Buyer';
        insert con;
        
        Profile PRMprofile = [select id from profile where name like '%PRM Portal%' Limit 1];
       User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ContactId = con.Id,
                                    ProfileId = PRMprofile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        
        insert testUser;

      Contact con1 = [Select Id,AccountId,FirstName,LastName,Email from Contact Where AccountId =: acc.Id];
        con1.FirstName = 'FirstNameCon';
        con1.Last_Operation_Performed__c = 'Vendor Sync failed';
        con1.Is_Incentives_Updated__c = true;
        update con1;
    }
     
    private static testMethod void populateCommonContactFields() {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Contact", "Class_Name__c": "ContactTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Contact';
        tec.RecursiveCount__c = 2;
        insert tec;
    }
    
}