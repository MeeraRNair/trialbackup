/*
History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0         04-Nov-2019         Abhinav             CR#18325        User's persona assignment
1.1         30-Dec-2019         Abhinav             CR#18414        User's profile assignment
*/

public class PersonaUtilTriggerHelper {
    
    public static void personaUserAssignment(String strTrigEvent, List<User> listUser, Map<Id, User> mapOld) {
        Set<String> setRoleName = new Set<String>();
        try {
            for(User u : listUser) {
                System.debug('PersonaUtilTriggerHelper ~ personaUserAssignment ~ User ~ BeforeUpdate ~ ' + u);
                if(u.isActive == true && u.Resource_Manager_Role__c != '' && (u.Persona_Override__c == false || u.Profile_Override__c == false)) {
                    //Persona assignment
                    if(isChangedUserPersona(strTrigEvent, u, mapOld)) {
                        setRoleName.add(u.Resource_Manager_Role__c);
                    }
                    //Profile assignment
                    if(isChangedUserProfile(strTrigEvent, u, mapOld)) {
                        setRoleName.add(u.Resource_Manager_Role__c);
                    }
                }
            }

            RoleNameWrap rnWrap = new RoleNameWrap(setRoleName);

            for(User u : listUser) {
                if(u.isActive == true && u.Resource_Manager_Role__c != '' && (u.Persona_Override__c == false || u.Profile_Override__c == false)) {
                    //Persona assignment
                    if(rnWrap.mapPersona.containsKey(u.Resource_Manager_Role__c) && isChangedUserPersona(strTrigEvent, u, mapOld)) {
                        u.User_Persona__c = rnWrap.mapPersona.get(u.Resource_Manager_Role__c);
                        System.debug('PersonaUtilTriggerHelper ~ personaUserAssignment ~ Resource_Manager_Role__c ~ Persona ~ ' + u.Resource_Manager_Role__c);
                    }
                    //Profile assignment
                    if(rnWrap.mapProfile.containsKey(u.Resource_Manager_Role__c) && isChangedUserProfile(strTrigEvent, u, mapOld)) {
                        u.ProfileId = (Id) rnWrap.mapProfile.get(u.Resource_Manager_Role__c);
                        System.debug('PersonaUtilTriggerHelper ~ personaUserAssignment ~ Resource_Manager_Role__c ~ Profile ~ ' + u.Resource_Manager_Role__c);
                    }
                }
                System.debug('PersonaUtilTriggerHelper ~ personaUserAssignment ~ User ~ AfterUpdate ~ ' + u);
            }
        } catch(Exception e) {
            System.debug('PersonaUtilTriggerHelper ~ personaUserAssignment ~ Exception' + e.getMessage());
        }
    }

    public static void personaRoleCodeAssignment(String strTrigEvent, List<Role_Code__c> listRoleCode, Map<Id, Role_Code__c> mapOld) {
        Set<String> setRoleName = new Set<String>();
        Map<String, String> mapPersona = new Map<String, String>();
        Map<String, String> mapProfile = new Map<String, String>();
        try {
            for(Role_Code__c rmRole : listRoleCode) {
                System.debug('PersonaUtilTriggerHelper ~ personaRMRoleAssignment ~ Role_Code__c' + rmRole);
				if(rmRole.Active__c == true && rmRole.Role_Name__c != '' && (rmRole.Persona__c != '' || rmRole.Profile_ID__c != '')) {
                    //Persona Assignment
					if(isChangedRoleCodePersona(strTrigEvent, rmRole, mapOld)) {
                        setRoleName.add(rmRole.Role_Name__c);
                        mapPersona.put(rmRole.Role_Name__c, rmRole.Persona__c);
                    }
					//Profile Assignment
					if(isChangedRoleCodeProfile(strTrigEvent, rmRole, mapOld)) {
                        setRoleName.add(rmRole.Role_Name__c);
                        mapProfile.put(rmRole.Role_Name__c, rmRole.Profile_ID__c);
					}
                }
            }
            updateUsers(setRoleName, mapPersona, mapProfile);
        } catch (Exception e) {
            System.debug('PersonaUtilTriggerHelper ~ personaRoleCodeAssignment ~ Exception' + e.getMessage());
        }
    }

	@future
    public static void updateUsers(Set<String> setRoleName, Map<String, String> mapPersona, Map<String, String> mapProfile) {
        List<User> listUserList = [SELECT Id, Resource_Manager_Role__c, User_Persona__c, ProfileId, Persona_Override__c, Profile_Override__c FROM User WHERE isActive = true AND Resource_Manager_Role__c IN : setRoleName ORDER BY Resource_Manager_Role__c];

        List<User> listUserUpdate = new List<User>();
        for(User u : listUserList) {
			boolean bIsupdate = false;
			//Persona Assignment
			if(u.Persona_Override__c == false && mapPersona.containsKey(u.Resource_Manager_Role__c) && u.User_Persona__c != mapPersona.get(u.Resource_Manager_Role__c)) {
                u.User_Persona__c = mapPersona.get(u.Resource_Manager_Role__c);
				bIsupdate = true;
			}
			//Profile Assignment
			if(u.Profile_Override__c == false && mapProfile.containsKey(u.Resource_Manager_Role__c) && u.ProfileId != mapProfile.get(u.Resource_Manager_Role__c)) {
                u.ProfileId = (Id) mapProfile.get(u.Resource_Manager_Role__c);
				bIsupdate = true;
			}
			if(bIsupdate == true) {
                listUserUpdate.add(u);
			}
			if(
				(listUserUpdate.size() > 0 && (listUserUpdate.size() * 100 / Limits.getLimitDMLRows()) >= 50) || 
				(Test.isRunningTest() && listUserUpdate.size() >= 5)
			) {
				performUsersDML(listUserUpdate);
				System.debug('PersonaUtilTriggerHelper ~ updateUsers ~ InsideFor ~ listUserUpdate ~ ' + listUserUpdate.size());
				listUserUpdate.clear();
			}
        }
		if(listUserUpdate.size() > 0) {
			performUsersDML(listUserUpdate);
			System.debug('PersonaUtilTriggerHelper ~ updateUsers ~ AfterFor ~ listUserUpdate ~ ' + listUserUpdate.size());
		}
    }

    public static boolean isChangedUserPersona(String strTrigEvent, User u, Map<Id, User> mapOld) {
        boolean bIschanged = false;
        if(u.Persona_Override__c == false) {
            if(
                (strTrigEvent == 'ISINSERT') || 
                (strTrigEvent == 'ISUPDATE' && (
                    u.isActive != mapOld.get(u.Id).isActive || 
                    u.Persona_Override__c != mapOld.get(u.Id).Persona_Override__c || 
                    !u.Resource_Manager_Role__c.equals(mapOld.get(u.Id).Resource_Manager_Role__c) || 
                    !u.User_Persona__c.equals(mapOld.get(u.Id).User_Persona__c)
                ))
            ) {
                bIschanged = true;
            }
        }
        return bIschanged;
    }

    public static boolean isChangedUserProfile(String strTrigEvent, User u, Map<Id, User> mapOld) {
        boolean bIschanged = false;
        if(u.Profile_Override__c == false) {
            if(
                (strTrigEvent == 'ISINSERT') || 
                (strTrigEvent == 'ISUPDATE' && (
                    u.isActive != mapOld.get(u.Id).isActive || 
                    u.Profile_Override__c != mapOld.get(u.Id).Profile_Override__c || 
                    !u.Resource_Manager_Role__c.equals(mapOld.get(u.Id).Resource_Manager_Role__c) || 
                    !u.ProfileId.equals(mapOld.get(u.Id).ProfileId)
                ))
            ) {
                bIschanged = true;
            }
        }
        return bIschanged;
    }

    public class RoleNameWrap {
        Map<String, String> mapPersona = new Map<String, String>();
        Map<String, String> mapProfile = new Map<String, String>();
        public RoleNameWrap(Set<String> setRoleName) {
            List<Role_Code__c> listRoleName = [SELECT Role_Name__c, Persona__c, Profile_ID__c FROM Role_Code__c WHERE Active__c = true AND Role_Name__c IN : setRoleName ORDER BY Role_Name__c];
            for(Role_Code__c rn : listRoleName) {
                if(String.isNotBlank(rn.Persona__c)) {
                    mapPersona.put(rn.Role_Name__c, rn.Persona__c);
                }
                if(String.isNotBlank(rn.Profile_ID__c)) {
                    mapProfile.put(rn.Role_Name__c, rn.Profile_ID__c);
                }
            }
        }
    }

    public static boolean isChangedRoleCodePersona(String strTrigEvent, Role_Code__c rmRole, Map<Id, Role_Code__c> mapOld) {
        boolean bIschanged = false;
        if(String.isNotBlank(rmRole.Persona__c)) {
            if(
                (strTrigEvent == 'ISINSERT') || 
                (strTrigEvent == 'ISUPDATE' && (
                    rmRole.Active__c != mapOld.get(rmRole.Id).Active__c || 
					!rmRole.Role_Name__c.equals(mapOld.get(rmRole.Id).Role_Name__c) || 
					!rmRole.Persona__c.equals(mapOld.get(rmRole.Id).Persona__c)
                ))
            ) {
                bIschanged = true;
            }
        }
        return bIschanged;
    }

    public static boolean isChangedRoleCodeProfile(String strTrigEvent, Role_Code__c rmRole, Map<Id, Role_Code__c> mapOld) {
        boolean bIschanged = false;
        if(String.isNotBlank(rmRole.Profile_ID__c)) {
            if(
                (strTrigEvent == 'ISINSERT') || 
                (strTrigEvent == 'ISUPDATE' && (
                    rmRole.Active__c != mapOld.get(rmRole.Id).Active__c || 
					!rmRole.Role_Name__c.equals(mapOld.get(rmRole.Id).Role_Name__c) || 
					!rmRole.Profile_ID__c.equals(mapOld.get(rmRole.Id).Profile_ID__c)
                ))
            ) {
                bIschanged = true;
            }
        }
        return bIschanged;
    }

	public static void performUsersDML(List<User> listUserUpdate) {
		TriggerExecutionController.setSkipUserTriggers(true);
        List<Database.SaveResult> listSR = Database.update(listUserUpdate, false);
		TriggerExecutionController.setSkipUserTriggers(false);
        System.debug('PersonaUtilTriggerHelper ~ performUsersDML ~ listUserUpdate' + listUserUpdate);
        for(Integer intI=0; intI<listSR.size(); intI++) {
            if (!listSR.get(intI).isSuccess()) {
                // DML operation failed
                Database.Error error = listSR.get(intI).getErrors().get(0);
                System.debug('PersonaUtilTriggerHelper ~ performUsersDML ~ listUserUpdate ~ Exception ~ Failed ID #' + listUserUpdate.get(intI).Id + ' ~ Error ' + error.getMessage());
            }
        }
	}
}