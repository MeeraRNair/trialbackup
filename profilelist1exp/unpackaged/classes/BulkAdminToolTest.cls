/*-------------------------------------------------------------------------
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         xx          xx              xx              xx              Initial Test Class
2.0         CR 14104    FY18-DCS-0403   28-Mar-2017     Emily           Modified logic by referring to SSO permission set assignment
--------------------------------------------------------------------------*/

@isTest

private class BulkAdminToolTest {
    //Test method for validNewPswdUser
    static testMethod void testBulkAdminTool() {
        Profile profile = [select Id, IsSsoEnabled from profile WHERE IsSsoEnabled = false limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        System.runAs(testUser){
            BulkAdminToolController bulkAdminCtrl = new BulkAdminToolController();
            bulkAdminCtrl.changeMode();
            bulkAdminCtrl.getIsNewPasswordMode();
            bulkAdminCtrl.NewPassword = 'InzpireDell@123';
            bulkAdminCtrl.setUserList('testvaliduser@dell.com');
            bulkAdminCtrl.getUserList();
            bulkAdminCtrl.getuList();
            bulkAdminCtrl.getActionTypeOptions();
            bulkAdminCtrl.Submit();
        }
    }
    
    //Test method for InvalidUser
    static testMethod void testBulkAdminToolForInavlidUser() {
        Profile profile = [select Id, IsSsoEnabled from profile WHERE IsSsoEnabled = false limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        System.runAs(testUser){
            BulkAdminToolController bulkAdminCtrl = new BulkAdminToolController();
            bulkAdminCtrl.changeMode();
            bulkAdminCtrl.getIsNewPasswordMode();
            bulkAdminCtrl.NewPassword = '';
            bulkAdminCtrl.setUserList('Test@dell.com');
            bulkAdminCtrl.getUserList();
            bulkAdminCtrl.getuList();
            bulkAdminCtrl.getActionTypeOptions();
            bulkAdminCtrl.Submit();
        }
    }
    
    //Test method for validResetUser
    static testMethod void testBulkAdminToolForResetPswd() {
        Profile profile = [select Id, IsSsoEnabled from profile WHERE IsSsoEnabled = false limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        System.runAs(testUser){
            BulkAdminToolController bulkAdminCtrl = new BulkAdminToolController();
            bulkAdminCtrl.ActionType = 'MODE_RESET_PASSWORD';
            bulkAdminCtrl.changeMode();
            bulkAdminCtrl.setUserList('testvaliduser@dell.com');
            bulkAdminCtrl.getUserList();
            bulkAdminCtrl.getuList();
            bulkAdminCtrl.getActionTypeOptions();
            bulkAdminCtrl.Submit();
        }
    }
    
    //2.0 Test method for SSO_Enabled_Permission granted
    static testMethod void testBulkAdminToolForSSOPermission() {
      Profile profile = [select Id, IsSsoEnabled from profile WHERE IsSsoEnabled = false limit 1];
      User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        
        PermissionSet objSSOPermission = [SELECT id, name FROM PermissionSet WHERE name='SSO_Enabled_Permission'];
        PermissionSetAssignment newpermission = new PermissionSetAssignment(PermissionSetId = objSSOPermission.id, AssigneeId = testUser.Id);
        insert newpermission;
        
        System.runAs(testUser){
          BulkAdminToolController bulkAdminCtrl = new BulkAdminToolController();
          bulkAdminCtrl.changeMode();
          bulkAdminCtrl.getIsNewPasswordMode();
          bulkAdminCtrl.NewPassword = 'InzpireDell@123';
          bulkAdminCtrl.setUserList('testvaliduser@dell.com');
          bulkAdminCtrl.getUserList();
          bulkAdminCtrl.getuList();
          bulkAdminCtrl.getActionTypeOptions();
          bulkAdminCtrl.Submit();
        }
    }
    
    static testMethod void testGetIsUserPasswordAction(){
        BulkAdminToolController controller = new BulkAdminToolController();
        controller.ActionType = 'NEWPWD';
        system.assertEquals(true, controller.getIsUserPasswordAction());
        controller.ActionType = 'RESETPWD';
        system.assertEquals(true, controller.getIsUserPasswordAction());
    }
    
    static testMethod void testGetIsLinkToMyAccount(){
        BulkAdminToolController controller = new BulkAdminToolController();
        controller.ActionType = 'LINKMYACC';
        system.assertEquals(true, controller.getIsLinkToMyAccount());
    }
}