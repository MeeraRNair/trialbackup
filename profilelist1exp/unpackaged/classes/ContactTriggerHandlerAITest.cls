/**
 * @File Name          : ContactTriggerHandlerAITest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/8/2019, 12:58:42 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/8/2019, 12:58:42 AM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@IsTest
public class ContactTriggerHandlerAITest {
    public static boolean bCreate = true;
    public static integer iNumberOfContacts = 5;
    public static list<Contact> lstContacts;
  
    public static testMethod void createContact() {
        populateCommonContactFields();
        if(bCreate) {
            insert lstContacts;
        }
    }
    
    private static testMethod void populateCommonContactFields() {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Contact", "Class_Name__c": "ContactTriggerHandlerAI"},';
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
    
    static testMethod void TestDecNPSqualifiedcontact(){
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Contact", "Class_Name__c": "ContactTriggerHandlerAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Contact';
        tec.RecursiveCount__c = 2;
        insert tec;
      Account acc = new Account();
      acc.Name = 'testAccount';
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
      //con.NPS_Criteria_Met__c = False; //v2.0
      update con;
    }
}