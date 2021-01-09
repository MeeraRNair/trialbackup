/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@isTest
private class ChatterAnswersCreateAccountTest {
    static list<User> listUser;
  static testMethod void validateAccountCreation() {
  //  Profile[] p = [SELECT Id FROM Profile WHERE UserType = 'Standard'];
  //  User[] user = [SELECT Id, Firstname, Lastname FROM User WHERE IsActive = true and ProfileId =: p[0].Id];
    // We cannot create account without a user.
   TriggerExecutionController.setSkipAllTriggers(true); 
    listuser = TestDataFactory.CreateNGenralUsers(1);
        insert listuser;
    if (listuser.size() == 0) { return; }
    String strfirstName = listuser[0].FirstName;
    String strlastName = listuser[0].LastName;
    String struserId = listuser[0].Id;
    String straccountId = new ChatterAnswersRegistration().createAccount(strfirstName, strlastName, struserId);
    Account account = [SELECT name, ownerId from Account where Id =: straccountId];
    System.assertEquals(strfirstName + ' ' + strlastName, account.name);
    System.assertEquals(struserId, account.ownerId);
  }
}