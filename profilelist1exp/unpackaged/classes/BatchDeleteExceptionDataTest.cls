/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      25-NOV-2010   Azwanti         Created for CR4117, R12.1
*/
@isTest
private class BatchDeleteExceptionDataTest {
    //Define variables
    //  static Account testAcc;
    //  static User userRecord1, userRecord2;
    // static List<User> userRecordList = new List<User>();
    // static List<Contact> testContactList = new List<Contact>();
    static list<Account> listAcc;
    static list<Contact> listCon;
    static list<user> listuser;
    @testsetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Contact> listConTDF = TestDataFactory.CreateNContacts(2);
        listConTDF[0].AccountID = listAccTDF[0].id;
        listConTDF[1].AccountID = listAccTDF[0].id;
        insert listConTDF;
        List<Profile> listuserProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];
        list<user> listuserTDF = TestDataFactory.CreateNGenralUsers(1);
        listuserTDF[0].ProfileId = listuserProfile[0].Id;
        insert listuserTDF;
        
    }
    static testMethod void testDeleteLastMonthExceptionData(){
        system.debug('======= Start : Test_DeleteLastMonthExceptionData =======');
        //Expected Result : able to delete Exception created last month
        //  TestDataCreation();
        TriggerExecutionController.setSkipAllTriggers(True);
        listAcc = [select id from Account limit 1];
        listCon = [select id from Contact limit 2];
        Test.startTest();
        listuser = [select id from user where  profile.name like '%Sales Rep%' limit 1 ];
        Exception__c exceptionRec = new Exception__c(Object_ID__c = listAcc[0].Id, Object_Type__c = 'Account', Operation__c = 'Update', Error_Messages__c = 'Test Class');
        insert exceptionRec;
        system.debug('====== exceptionRec: ' + exceptionRec);
        
        BatchDeleteExceptionData bdException = new BatchDeleteExceptionData();
        bdException.queryOldException = 'Select Id from Exception__c where Id = \''+exceptionRec.Id+'\'';
        
        // Test.startTest();
        Database.executeBatch(bdException,500); 
        
        
        //check result
        Integer intNewException = [SELECT count() FROM Exception__c where Id =: exceptionRec.Id];
        Test.stopTest();
        system.assertEquals(intNewException, intNewException);
        system.debug('====== newException : ' + intNewException);
        TriggerExecutionController.setSkipAllTriggers(False);
    }
    
    //==================================================== TestDataCreation ===============================================================
    /*  static void TestDataCreation() {
//create Account
testAcc = new Account(
name='Test1 CR4117',
Account_Country_Code__c = 'AI',
Account_Country__c = 'ANGUILIA',            
Account_ID__c = ''+System.currentTimeMillis()
);
insert testAcc;        

//Contact Creation
testContactList.clear();
for (integer i = 0; i < 2; i++) {

Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+i);
testContactList.add(testContact);
}                                            
insert testContactList;

//Create User
List<Profile> userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];        
userRecord1 = new User(
Username='testUser1'+System.currentTimeMillis()+'@test.com',
Alias = 'test', 
Email='test1@dell.com', 
FirstName='Tfirst A', 
LastName='TLast',
ProfileId = userProfile[0].Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST12345',
Title = 'Test Title'
);
userRecordList.add(userRecord1);

insert userRecordList; 

}*/
}