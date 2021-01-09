/*
History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0         04-Nov-2019         Abhinav             CR#18325        User's persona assignment
*/
public class PersonaRoleCodeTriggerHandlerAU implements AfterUpdate {

    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld) {
        System.debug('Entered PersonaRMRole handleAfterUpdate');
		PersonaUtilTriggerHelper.personaRoleCodeAssignment('ISUPDATE', Trigger.new, (map<Id, Role_Code__c>)Trigger.oldMap);
	}
}