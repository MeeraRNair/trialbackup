/*
History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0         04-Nov-2019         Abhinav             CR#18325        Persona User TriggerHandler TestClass
*/ 
@isTest
private class PersonaRoleCodeTriggerHandlerTest {

	@isTest
	static void personaRoleCodeTriggerHandlerAITest() {
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, true, false, false, false}
        };
        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Role_Code__c", "Class_Name__c": "PersonaRoleCodeTriggerHandlerAI"},'; 
        }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Role_Code__c';
        tec.RecursiveCount__c = 2;
        insert tec;

		List<Profile> listProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'R16.10 GBL %' ORDER BY Name DESC LIMIT 10];
		Test.startTest();
			List<String> listPersona = getPersonaPickListValues();
			List<Role_Code__c> listRoleCode = new List<Role_Code__c>();
			Integer intPer = 0;
			for(Integer intk = 6; intk < 8; intk++) {
				Role_Code__c rcIterator = new Role_Code__c();
				rcIterator.Role_Code__c = 'RC ' + intk;
				rcIterator.Role_Name__c = 'RN ' + intk;
				//rcIterator.Persona__c = 'RN ' + intk;
				rcIterator.Persona__c = listPersona.get(intPer);
				//rcIterator.Profile_ID__c = 'PID ' + intk;
				//rcIterator.Profile__c = 'P ' + intk;
				rcIterator.Profile_ID__c = listProfile.get(intk).Id;
				rcIterator.Profile__c = listProfile.get(intk).Id;
				rcIterator.Forecast_Group__c = 'FG ' + intk;
				rcIterator.Active__c = true;
				listRoleCode.add(rcIterator);
				intPer++;
			}
			insert listRoleCode;
		Test.stopTest();
		Integer  intCountRoleCode = Database.countQuery('SELECT COUNT() FROM Role_Code__c');
		System.assert(intCountRoleCode > 5, 'Insertion Failed');
	}

	@isTest
	static void personaRoleCodeTriggerHandlerAUTest() {
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Role_Code__c", "Class_Name__c": "PersonaRoleCodeTriggerHandlerAU"},'; 
        }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Role_Code__c';
        tec.RecursiveCount__c = 2;
        insert tec;

		Test.startTest();
		List<Role_Code__c> listRoleCode = [SELECT Id, Role_Name__c, Persona__c FROM Role_Code__c LIMIT 3];
		Integer intCnt = 6;
		for(Role_Code__c rc : listRoleCode) {
			rc.Role_Name__c = 'RN ' + intCnt;
			intCnt++;
		}
		update listRoleCode;
		Test.stopTest();
		Integer  intCountRoleCode = Database.countQuery('SELECT COUNT() FROM Role_Code__c WHERE Role_Name__c LIKE \'RN %\'');
		System.assert(intCountRoleCode > 0, 'Updation failed');
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
            uIterator.Resource_Manager_Role__c = 'RN ' + intI;
            listUser.add(uIterator);
        }
		insert listUser;

		List<String> listPersona = getPersonaPickListValues();
		List<Profile> listProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'R16.10 GBL %' ORDER BY Name ASC LIMIT 10];
		List<Role_Code__c> listRoleCode = new List<Role_Code__c>();
        for(Integer intJ = 0; intJ < 5; intJ++) {
            Role_Code__c rcIterator = new Role_Code__c();
			rcIterator.Role_Code__c = 'RC ' + intJ;
			rcIterator.Role_Name__c = 'RN ' + intJ;
			//rcIterator.Persona__c = 'RN ' + intJ;
			rcIterator.Persona__c = listPersona.get(intJ);
			//rcIterator.Profile_ID__c = 'PID ' + intJ;
            //rcIterator.Profile__c = 'P ' + intJ;
			rcIterator.Profile_ID__c = listProfile.get(intJ).Id;
            rcIterator.Profile__c = listProfile.get(intJ).Name;
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