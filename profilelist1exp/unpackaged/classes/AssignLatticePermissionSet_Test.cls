/* Revision Ref Number  Release No      Date            Modified By     Description
* -------- ----------  ----------      -----------     ------------    -----------
*  1.0       CR 13632    FY17-DCS-0102   25-Oct-2016       Sajith         LM2_Grant Lattice BIS permission to new users
*/
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
Private class AssignLatticePermissionSet_Test{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Marketing User']; 
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        listUserTdf[0].ProfileId=objProfile.Id;
        insert listUserTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testDirectAssignment() {
        //Profile objProfile = [SELECT Id FROM Profile WHERE Name='Marketing User']; 
        PermissionSet objPermissionSet = [SELECT Id FROM PermissionSet WHERE Name='LatticeSalesRepresentative'];
        /* User objUser1 = new User(Alias = 'st0901', Email='st0901@dell.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = objProfile.Id, Badge_Number__c='XXYYZZTT',
TimeZoneSidKey='America/Los_Angeles', UserName='st0901@dell.com');
*/
        User objUser1=[select id from User where Profile.Name='Marketing User' Limit 1];
        system.assertNotEquals(objUser1.id, null);
        test.starttest(); 
        // insert objUser1;
        AssignLatticePermissionSet.AddPermSetRequest objADR = new AssignLatticePermissionSet.AddPermSetRequest();
        objADR.PermissionSetId = objPermissionSet.Id;
        objADR.UserId = objUser1.Id;
        List<AssignLatticePermissionSet.AddPermSetRequest> listReq = new List<AssignLatticePermissionSet.AddPermSetRequest>();
        listReq.add(objADR);
        AssignLatticePermissionSet.AddPermSet(listReq);
        test.stoptest();   
    }
}