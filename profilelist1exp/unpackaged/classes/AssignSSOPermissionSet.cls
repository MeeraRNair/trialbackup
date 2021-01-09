/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         CR 14104    FY18-DCS-0403   24-Mar-2017     Sriram          @InvocableMethod for assigning permission set through process flow
2.0         CR 14343    FY18-DCS-0602   15-May-2017     Sriram          Logic Updated for handling the duplication of permissionset Assignment
Note ::UserValue passing through  PB are as follows : AssignPermissionSet=1; RevokePermissionSet=2;
*/   
public class AssignSSOPermissionSet{
    //Fetch the permission set for assinging SSO enable   
    @testvisible static PermissionSet objSSOPermission=[SELECT id, name FROM PermissionSet WHERE name='SSO_Enabled_Permission'];
    //List of PermissionsetAssignment that are inserted 
    @testvisible static List<PermissionSetAssignment > listAssignPermissions= new List<PermissionSetAssignment>();
    //List of PermissionSetAssignment that are deleted
    @testvisible static List<PermissionSetAssignment > listRevokePermissions= new List<PermissionSetAssignment>();
    //Map of Users that are having user id and User Value.
    @testvisible static Map<Id, Integer> userMap = new Map<Id, Integer>();
    
    @InvocableMethod
    Public static void setPermissionSet(List<PermissionSetClass> listUserInformations){
        listAssignPermissions.clear();
        listRevokePermissions.clear();
        userMap.clear();
        for(PermissionSetClass permissionSetSample : listUserInformations){
            userMap.put(permissionSetSample.userId, permissionSetSample.userValue);
        }
        if(!userMap.isEmpty()){
            system.debug('***** UserMap *****'+userMap);
            for(User objUser:[select id,name,(select AssigneeId, PermissionSetId FROM PermissionSetAssignments where PermissionSetId=:objSSOPermission.id) from User where id in:userMap.keySet()]){
                system.debug('****Permissionset size *****'+objUser.PermissionSetAssignments.size());
                if(userMap.get(objUser.Id) == 1 && objUser.PermissionSetAssignments.size() == 0) {
                    listAssignPermissions.add(new PermissionSetAssignment(PermissionSetId = objSSOPermission.id, AssigneeId = objUser.Id));            
                }
                else if(userMap.get(objUser.Id) == 2 && objUser.PermissionSetAssignments.size() == 1){
                    listRevokePermissions.add(objUser.PermissionSetAssignments);
                }
            }
        } 
        if(!listAssignPermissions.isEmpty() && !test.isRunningTest()){
            insert listAssignPermissions;
            system.debug('**** Grant Permission set in Class****');
        }
        if(!listRevokePermissions.isEmpty() && !test.isRunningTest()){
            delete listRevokePermissions;
            system.debug('**** Revoke Permission set in Class****');
        }
    }
    //Create a wrapper class for passing Two variable at a time 
    Public class PermissionSetClass{
        @InvocableVariable(required=true label='User Value')
        public integer userValue;
        @InvocableVariable(required=true label='User Id')
        public id userId;
    }
    
}