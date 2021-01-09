/* Revision		Ref Number		Release No      Date            Modified By     Description
* --------		----------		----------      -----------     ------------    -----------
*  1.0			CR XXXXX		FY20-DCS-1002   16-Aug-2019		Abhinav			Sales Cloud Einstein (SalesCloudEinsteinAll) permission to new users
*/
@isTest
Private class AssignSalesEinsteinPermissionSet_Test{
    @testSetup static void setup() {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Marketing User']; 
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(1);
        listUserTdf[0].ProfileId=objProfile.id;
        insert listUserTdf;
    }
    static testMethod void testDirectAssignment() {
       // Profile objProfile = [SELECT Id FROM Profile WHERE Name='Marketing User']; 
        PermissionSet objPermissionSet = [SELECT Id FROM PermissionSet WHERE Name='SalesCloudEinsteinAll'];
        /* User objUser1 = new User(Alias = 'st0901', Email='st0901@dell.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = objProfile.Id, Badge_Number__c='XXYYZZTT',
TimeZoneSidKey='America/Los_Angeles', UserName='st0901@dell.com');
*/
        
        test.starttest(); 
        User objUser1=[select id,profileId  from User where profile.name='Marketing User' Limit 1];
        AssignSalesEinsteinPermissionSet.AddPermSetRequest objADR = new AssignSalesEinsteinPermissionSet.AddPermSetRequest();
        objADR.PermissionSetId = objPermissionSet.Id;
        objADR.UserId = objUser1.Id;
        List<AssignSalesEinsteinPermissionSet.AddPermSetRequest> listReq = new List<AssignSalesEinsteinPermissionSet.AddPermSetRequest>();
        listReq.add(objADR);
        AssignSalesEinsteinPermissionSet.AddPermSet(listReq);
        
        List<PermissionSetAssignment> listPermSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: objUser1.Id];
        System.assert(listPermSet.size()>0);
        test.stoptest();   
    }
}