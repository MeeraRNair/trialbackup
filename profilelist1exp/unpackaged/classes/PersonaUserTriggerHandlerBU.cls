/*
History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0         04-Nov-2019         Abhinav             CR#18325        User's persona assignment
*/
public class PersonaUserTriggerHandlerBU implements BeforeUpdate {

    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld) {
        System.debug('Entered PersonaUser handleBeforeUpdate');
		PersonaUtilTriggerHelper.personaUserAssignment('ISUPDATE', Trigger.new, (map<Id, User>)Trigger.oldMap);
	}
}