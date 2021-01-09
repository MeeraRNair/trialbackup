/*
History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0         04-Nov-2019         Abhinav             CR#18325        Persona User TriggerHandler TestClass
*/
@isTest
private class PersonaUserTriggerHandlerTest {

	@isTest
	static void personaUserTriggerHandlerBITest() {
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeInsert' => new List<Boolean>{false, true, false, false, false}
        };
        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "User", "Class_Name__c": "PersonaUserTriggerHandlerBI"},'; 
        }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'User';
        tec.RecursiveCount__c = 2;
        insert tec;

		Test.startTest();
			String strProfileId = [SELECT id from profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
			User u1 = new User(Alias = 'gblsales', Email='gblsalesmgr@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = strProfileId, TimeZoneSidKey='America/Los_Angeles', UserName='gblsales@dell.com', Badge_Number__c = getUniqueString());
			insert u1;
		Test.stopTest();
		Integer  intCountUser = Database.countQuery('SELECT COUNT() FROM User');
		System.assert(intCountUser > 0, 'Insertion Failed');
	}

	@isTest
	static void personaUserTriggerHandlerBUTest() {
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{false, true, false, false, false}
        };
        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "User", "Class_Name__c": "PersonaUserTriggerHandlerBU"},'; 
        }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'User';
        tec.RecursiveCount__c = 2;
        insert tec;

		Test.startTest();
		/*List<User> listUser = [SELECT Id, Resource_Manager_Role__c, User_Persona__c FROM User LIMIT 1];
		Integer intCnt = 0;
		for(User u : listUser) {
			u.Resource_Manager_Role__c = 'RN ' + intCnt;
			intCnt++;
		}*/
		String strProfileId = [SELECT id from profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
		User u1 = new User(Alias = 'gblsales', Email='gblsalesmgr@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = strProfileId, TimeZoneSidKey='America/Los_Angeles', UserName='gblsales@dell.com', Badge_Number__c = getUniqueString());
		insert u1;
		u1.Resource_Manager_Role__c = 'RN 1';
		update u1;
		Test.stopTest();
		Integer  intCountUser = Database.countQuery('SELECT COUNT() FROM User WHERE Resource_Manager_Role__c LIKE \'RN 1%\'');
		System.assert(intCountUser > 0, 'Updation Failed');
	}
    
    @testSetup static void setup() {
        String strProfileId = [SELECT id from profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
		List<User> listUser = new List<User>();

        for(Integer intI=0; intI<2; intI++) {
            User uIterator = new User();
			uIterator.UserName = 'MyTestUser' + intI + System.currentTimeMillis() + '@dell.com';
            String strRight = String.valueOf(System.currentTimeMillis());
			uIterator.Alias = 'U' + intI + strRight.right(4);
			uIterator.Email = 'MyTestUser' + intI +'@dell.com';
            uIterator.FirstName = 'My Test';
            uIterator.LastName = 'User ' + intI;
            uIterator.LanguageLocaleKey = 'en_US';
			uIterator.LocaleSidKey = 'en_US';
			uIterator.EmailEncodingKey = 'UTF-8';
			uIterator.TimeZoneSidKey = 'America/Los_Angeles';
			uIterator.ProfileId = strProfileId;
			//uIterator.Badge_Number__c = getUniqueString();
            uIterator.Badge_Number__c = String.valueOf(Math.round(Math.random()*1000000000)) + '00' + intI + system.now().millisecond();
            uIterator.IsActive = true;
            listUser.add(uIterator);
        }
		insert listUser;

		List<String> listPersona = getPersonaPickListValues();
		List<Role_Code__c> listRoleCode = new List<Role_Code__c>();
        for(Integer intJ = 0; intJ < 5; intJ++) {
            Role_Code__c rcIterator = new Role_Code__c();
			rcIterator.Role_Code__c = 'RC ' + intJ;
			rcIterator.Role_Name__c = 'RN ' + intJ;
			//rcIterator.Persona__c = 'RN ' + intJ;
			rcIterator.Persona__c = listPersona[intJ];
			rcIterator.Profile_ID__c = 'PID ' + intJ;
            rcIterator.Profile__c = 'P ' + intJ;
            rcIterator.Forecast_Group__c = 'FG ' + intJ;
            rcIterator.Active__c = true;
            listRoleCode.add(rcIterator);
        }
		insert listRoleCode;
    }

	public static List<String> getPersonaPickListValues() {
       List<String> listPickListValues= new List<String>();
		Schema.DescribeFieldResult fieldResult = Role_Code__c.Persona__c.getDescribe();
		List<Schema.PicklistEntry> listPle = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : listPle){
			listPickListValues.add(pickListVal.getLabel());
		}
		return listPickListValues;
    }

    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
}