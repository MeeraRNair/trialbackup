/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         CR 14104    FY18-DCS-0403   24-Mar-2017     Sriram          @InvocableMethod for assigning permission set through process flow
2.0         CR 14343    FY18-DCS-0602   15-May-2017     Sriram          Logic Updated for handling the duplication of permissionset Assignment
*/
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
public class AssignSSOPermissionSet_Test{
    @testSetup static void setup() {
        Profile objProfile = [SELECT Id,Name,UserLicenseId FROM Profile 
                              where UserLicenseId  in 
                              (SELECT Id FROM UserLicense where name ='Salesforce') 
                              and  Name='R16.10 GBL Marketing User']; 
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(1);
        listUserTdf[0].ProfileId=objProfile.id;
        listUserTdf[0].UserName='Test0001@dell.com';
        insert listUserTdf;
    }
    static testMethod void testpermissionAssignment() {
        /*    Profile objProfile = [SELECT Id,Name,UserLicenseId FROM Profile 
where UserLicenseId  in 
(SELECT Id FROM UserLicense where name ='Salesforce') 
and  Name='R16.10 GBL Marketing User']; 
User objUser = new User(Alias = 'Test0001', Email='test0002@dell.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = objProfile.Id, Badge_Number__c='Test_0001',
TimeZoneSidKey='America/Los_Angeles', UserName='Test0001@dell.com',Acquisition_Code__c='');
insert objUser;*/
        
        test.starttest(); 
        User objUser=[select id,profileId  from User where UserName='Test0001@dell.com' Limit 1];
        system.assertNotEquals(objUser.id, null);
        AssignSSOPermissionSet.PermissionsetClass objADR= new AssignSSOPermissionSet.PermissionsetClass();
        objADR.userId=objUser.id;
        objADR.Uservalue=1;
        AssignSSOPermissionSet.setPermissionSet(new List<AssignSSOPermissionSet.PermissionsetClass>{objADR});
        PermissionSetAssignment prm =new PermissionSetAssignment(PermissionSetId = AssignSSOPermissionSet.objSSOPermission.id, AssigneeId = objUser.Id);
        insert prm;
        objADR.userId=objUser.id;
        objADR.Uservalue=2;
        AssignSSOPermissionSet.setPermissionSet(new List<AssignSSOPermissionSet.PermissionsetClass>{objADR});
        test.stoptest();   
    }
}