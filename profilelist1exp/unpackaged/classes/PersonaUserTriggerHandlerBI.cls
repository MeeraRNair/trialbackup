/*
History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0         04-Nov-2019         Abhinav             CR#18325        User's persona assignment
*/
public class PersonaUserTriggerHandlerBI implements BeforeInsert {

	public void handleBeforeInsert(List<sObject> listNew) {
        System.debug('Entered PersonaUser handleBeforeInsert');
		PersonaUtilTriggerHelper.personaUserAssignment('ISINSERT', Trigger.new, null);
	}
}