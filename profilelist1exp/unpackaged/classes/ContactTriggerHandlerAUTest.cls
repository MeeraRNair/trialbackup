@IsTest
public class ContactTriggerHandlerAUTest {
	public static boolean bCreate = true;
    public static integer iNumberOfContacts = 5;
    public static list<Contact> lstContacts;
  
    public static testMethod void updateContact(){
        populateCommonContactFields();
        
      Account acc = new Account();
      acc.Name = 'testAccount123';
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
        
      Contact con1 = [Select Id,AccountId,FirstName,LastName,Email from Contact Where AccountId =: acc.Id LIMIT 1];
        con1.FirstName = 'FirstNameCon';
        update con1;
    }
     
    private static testMethod void populateCommonContactFields() {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Contact", "Class_Name__c": "ContactTriggerHandlerAU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Contact';
        tec.RecursiveCount__c = 2;
        insert tec;

      Account accInstance = new Account();
      accInstance.Name = 'testAccount';
      insert accInstance;
      
      lstContacts = new list<Contact>();
        for(integer i=0; i<iNumberOfContacts; i++) {
          Contact con = new Contact();
          con.AccountId = accInstance.Id;
          con.Email = 'test@test.com';
          con.phone = '6739';
          con.LastName = 'conLastName';
          con.FirstName = 'conFirstName';
          con.Status__c = 'Customer';
          con.Email_Opt_In__c = 'yes';
          con.Survey__c = 'yes';
          con.Decision_Making_Role__c = 'Technical Buyer';
          //con.NPS_Criteria_Met__c = True; //v2.0
      
          lstContacts.add(con);
        }
    }
    
    /*static testMethod void TestDecNPSqualifiedcontact(){
      Account acc = new Account();
      acc.Name = 'testAccount1';
      acc.NPS_Qualified_Contacts__c = 1;
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
      //con.NPS_Criteria_Met__c = True; //v2.0
        
      insert con;
      con.Email = Null;
      con.Phone = '1234';
      //con.NPS_Criteria_Met__c = False; //v2.0
      update con;
    }*/
}