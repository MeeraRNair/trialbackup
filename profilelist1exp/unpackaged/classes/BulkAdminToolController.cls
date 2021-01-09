/*-------------------------------------------------------------------------
Name            : BulkAdminToolController
Description     : Class  for setting/resetting password for Users
* Revision         Name          Date            Description
----------------------------------------------------------------------------
* R 13.4           Manju         9-Apr-2012      CR #7044
* R 13.7           Manju         18-May-2012     CR #7128 - Included Status for each User record
* R 14.2           Fenny         2-Feb-2013      CR #7949 - Bulk Link to MyAccount
* FY18-DCS-0403    Emily         28-Mar-2017     CR #14104 - SSO_Enabled_Permission
--------------------------------------------------------------------------*/
public class BulkAdminToolController {
    public String errorMessage { get; set; }
    private final string MODE_NEW_PASSWORD = 'NEWPWD';
    private final string MODE_RESET_PASSWORD = 'RESETPWD';
    private final string LINK_TO_MYACCOUNT = 'LINKMYACC'; // Fenny: CR7949
    public String ActionType { get; set; }
    public String NewPassword { get; set; }
    public List<String> usernameList;
    public boolean showResult{get;set;}
    public final string ERROR_NOTARGET = 'Target User List must not be empty.';
    public final string ERROR_NOPWD = 'New Password must be provided.';
    public Map<Id, Profile> mapOfIdAndProfile = new Map<Id, Profile>();
    public List<Profile> profileList = null;
    public final String SUCCESS = 'SUCCESS';
    public final String FAILURE = 'FAILURE';
    public List<Bulk_Admin_Class> lstOfUserRecords {get; set;}
    public Set<String> uList = new Set<String>();
    public Map<Id, PermissionSetAssignment> mapOfIdAndSSOPermissionSet = new Map<Id, PermissionSetAssignment>();
        
    public BulkAdminToolController () {
        this.NewPassword = '';
        ActionType = MODE_NEW_PASSWORD;
        showResult = false;
        errorMessage = null;
        profileList = [SELECT Name, IsSsoEnabled FROM Profile WHERE IsSsoEnabled = false];
        for(Profile p : profileList){
            mapOfIdAndProfile.put(p.Id, p);
        }
    }
    
    public PageReference changeMode() {
        this.NewPassword = '';
        showResult = false;
        errorMessage = null; 
        return null;
    }
    
    public void setUserList(string namelist) {
        if(uList.size() > 0){
            uList.clear();
        }
        usernameList = namelist.split('\n');
        for(String s: usernameList){
            uList.add(s.trim());
        }
    }
    
    public string getUserList() {
        return null;
    }
    
    public Set<String> getuList() {
        return uList;
    }
    
    public PageReference Submit() {
        //Emily: CR14104
        PermissionSet objSSOPermission = [SELECT id, name FROM PermissionSet WHERE name = 'SSO_Enabled_Permission'];        
        for(PermissionSetAssignment psa: [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :objSSOPermission.id AND Assignee.Username IN :uList]){
            mapOfIdAndSSOPermissionSet.put(psa.AssigneeId, psa);        
        }        
    
        lstOfUserRecords = new List<Bulk_Admin_Class>(); 
        errorMessage = null;
        for(User user: [SELECT Id, username, email, name, ProfileId, Profile_Name__c FROM User WHERE Username IN :uList]){
            Bulk_Admin_Class wrapperObj = new Bulk_Admin_Class(user);            
            
            //Emily: CR14104    
            if((!mapOfIdAndProfile.keySet().contains(user.ProfileId)) || mapOfIdAndSSOPermissionSet.keySet().contains(user.Id)){
                wrapperObj.status = FAILURE;
                wrapperObj.reason = 'Cannot Change/Reset password for SSO user';
            }else if(mapOfIdAndProfile.keySet().contains(user.ProfileId) && (!mapOfIdAndSSOPermissionSet.keySet().contains(user.Id))){
                if(ActionType == MODE_NEW_PASSWORD){
                    if(this.NewPassword.length() == 0) {
                        errorMessage = ERROR_NOPWD;
                        showResult = false;
                        return null;
                    }
                    try{
                        System.setPassword(user.Id, NewPassword);
                    }catch(Exception e) {
                        wrapperObj.status = FAILURE;
                        wrapperObj.reason = e.getMessage();
                    }
                }else if(ActionType == MODE_RESET_PASSWORD){
                    try{
                        System.resetPassword(user.Id, true);
                    }catch(Exception e) {
                        wrapperObj.status = FAILURE;
                        wrapperObj.reason = e.getMessage();
                    }
                }
            }
            lstOfUserRecords.add(wrapperObj);
        }
        if(lstOfUserRecords.size() <= 0){
            errorMessage = ERROR_NOTARGET;
            showResult = false;
            return null;
        }
        showResult = true;
        this.NewPassword = '';
        return null;
    }
    
    public List<Bulk_Admin_Class> getUsers(){
        return lstOfUserRecords;
    }
    
    //Wrapper class
    public class Bulk_Admin_Class{
        public User userObj {get; set;}
        public String status {get; set;}
        public String reason {get; set;}
        
        //Constructor for wrapper class
        public Bulk_Admin_Class(User userRec){
            userObj = userRec;
            status = 'SUCCESS';
            reason = 'Transaction completed successfully';
        }
    }
    
    public List<SelectOption> getActionTypeOptions() {
         List<SelectOption> actionTypeOptions = new List<SelectOption>();
         actionTypeOptions.add(new SelectOption(MODE_NEW_PASSWORD, 'New Password'));
         actionTypeOptions.add(new SelectOption(MODE_RESET_PASSWORD, 'Reset Password'));
         actionTypeOptions.add(new SelectOption(LINK_TO_MYACCOUNT, 'Link to MyAccount')); // Fenny: CR7949
         return actionTypeOptions;
    }
    
    // Fenny: CR7949
    public boolean getIsUserPasswordAction(){
        return (ActionType == MODE_NEW_PASSWORD) || (ActionType == MODE_RESET_PASSWORD);
    }
    
    // Fenny: CR7949
    public boolean getIsLinkToMyAccount(){
        return (ActionType == LINK_TO_MYACCOUNT);
    }
    
    public boolean getIsNewPasswordMode() {
        return (ActionType == MODE_NEW_PASSWORD);
    }
    
}