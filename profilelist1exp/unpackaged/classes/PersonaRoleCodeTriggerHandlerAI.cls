/*
History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0         04-Nov-2019         Abhinav             CR#18325        User's persona assignment
*/
public class PersonaRoleCodeTriggerHandlerAI implements AfterInsert {

	public void handleAfterInsert(List<sObject> listNew) {
        System.debug('Entered PersonaRMRole handleAfterInsert');
		PersonaUtilTriggerHelper.personaRoleCodeAssignment('ISINSERT', Trigger.new, null);
	}
}