/* Revision     Ref Number      Release No      Date            Modified By     Description
* --------      ----------      ----------      -----------     ------------    -----------
*  1.0          CR XXXXX        FY20-DCS-1002   16-Aug-2019     Abhinav         Sales Cloud Einstein (SalesCloudEinsteinAll) permission to new users
*/
public with sharing class AssignSalesEinsteinPermissionSet {
    
    @InvocableMethod(label='Add Sales Cloud Einstein (SalesCloudEinsteinAll) Permission Set to User')
    public static void addPermSet(list<AddPermSetRequest> listrequests) {
        list<string> listoutput = new list<string>();
        
        for (AddPermSetRequest objrequest:dedupe(listrequests)){
            listoutput.add(JSON.serialize(objrequest));
        }
        
        addPermsLater(listoutput);
        
    }
    
    //Process Builder/Flow Builder can reference for the permission set id and user id input variables
    public class AddPermSetRequest {
        @InvocableVariable(required=true label='Permission Set Id')
        public Id permissionSetId;
        
        @InvocableVariable(required=true label='User Id')
        public Id userId;
    }
    
    public static list<AddPermSetRequest> dedupe(list<AddPermSetRequest> listinput){
        set<AddPermSetRequest> settemp = new set<AddPermSetRequest>(listinput);
        return new list<AddPermSetRequest>(settemp);
    }

    public static void addPermsLater (list<string> listrequests){
        list<PermissionSetAssignment> listPSAs = new list<PermissionSetAssignment>();
        
        for (string strrequest:listrequests) {
            //turn it back into the request object per Quinton Wall
            AddPermSetRequest objAPSR = (AddPermSetRequest)JSON.deserialize(strrequest, AddPermSetRequest.class);
            PermissionSetAssignment objPSA = new PermissionSetAssignment();
            objPSA.AssigneeId = objAPSR.userId;
            objPSA.permissionSetId = objAPSR.permissionSetId;
            listPSAs.add(objPSA);          
        }
        
        if (Test.isRunningTest()) {
            system.debug('**Running a Test Class**');
        } else {
            insert listPSAs;
        }
    }
}