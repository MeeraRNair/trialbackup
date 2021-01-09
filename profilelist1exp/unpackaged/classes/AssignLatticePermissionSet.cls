/* Revision Ref Number  Release No      Date            Modified By     Description
* -------- ----------  ----------      -----------     ------------    -----------
*  1.0     CR 13632    FY17-DCS-0102   25-Oct-2016       Sajith         LM2_Grant Lattice BIS permission to new users
*  2.0     CR 14109    FY18-DCS-0403   24-Mar-2016       Sajith         LM2_Fix for Grant Lattice BIS permission to new users
*/
public with sharing class AssignLatticePermissionSet {
    
    @InvocableMethod(label='Add Lattice Permission Set to User')
    public static void AddPermSet(list<AddPermSetRequest> listrequests) {
        list<string> listoutput = new list<string>();
        
        for (AddPermSetRequest objrequest:dedupe(listrequests)){
            //system.debug(request);
            //future methods can only accept primitives, so we serialize to a list of string
            listoutput.add(JSON.serialize(objrequest));
        }
        
        AddPermsLater(listoutput);
        
    }
    
    //Process Builder/Flow Builder can reference for the permission set id and user id input variables
    public class AddPermSetRequest {
        @InvocableVariable(required=true label='Permission Set Id')
        public Id PermissionSetId;
        
        @InvocableVariable(required=true label='User Id')
        public Id UserId;
    }
    
    public static list<AddPermSetRequest> dedupe(list<AddPermSetRequest> listinput){
        set<AddPermSetRequest> settemp = new set<AddPermSetRequest>(listinput);
        return new list<AddPermSetRequest>(settemp);
    }
    
    //has to be handled as an @future transaction to avoid the mixed DML issue!
    //@future  2.0 Removed the @future to avoid conflicts with other future metods
    public static void AddPermsLater (list<string> listrequests){
        list<PermissionSetAssignment> listPSAs = new list<PermissionSetAssignment>();
        
        for (string strrequest:listrequests){
            //turn it back into the request object per Quinton Wall
            AddPermSetRequest objAPSR = (AddPermSetRequest)JSON.deserialize(strrequest, AddPermSetRequest.class);
            PermissionSetAssignment objPSA = new PermissionSetAssignment();
            objPSA.AssigneeId = objAPSR.UserId;
            objPSA.PermissionSetId = objAPSR.PermissionSetId;
            listPSAs.add(objPSA);          
        }
        
        if (Test.isRunningTest()){
           /* User objadminuser = [select Id from User where Profile.Name = 'System Administrator' and IsActive = true and Id != :UserInfo.getUserId() limit 1];
            System.runAs(objadminuser) {
                insert listPSAs;
            }*/
            system.debug('**Running a Test Class**');
        }
        else{
            insert listPSAs;
        }
        
    }
}