/**
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      14-DEC-2010   Azwanti         Created for CR4117, R12.1
*/
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
private class BatchUpdateContactTest {
    //Define variables
    // static Account testAcc;
    //static User userRecord1, userRecord2;
    //static List<User> userRecordList = new List<User>();
    //static List<Contact> testContactList = new List<Contact>();
    //static Contact testContact;
    @testSetup static void setUpConversionTestData() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].Name='Account CR4117';
        insert listAccTdf;
        Work_Items__c wor = new Work_Items__c(Account__c = listAccTdf[0].Id, Object_Type__c = 'Account', Status__c = 'Completed');
        insert wor;
        list<Contact> listConTdf=TestDataFactory.createNContacts(2);
        listConTdf[0].Accountid=listAccTdf[0].id;
        listConTdf[1].Accountid=listAccTdf[0].id;
        insert listConTdf;
        List<Profile> listUserProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];        
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(2);
        listUserTdf[0].ProfileID=listUserProfile[0].id;
        listUserTdf[1].ProfileID=listUserProfile[1].id;
        insert listUserTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void testbuContact() {
        TriggerExecutionController.setSkipAllTriggers(true);
        // TestDataCreation();
        //1. Account Owner transition from userRecord1 to userRecord2
        Account newAccount = [Select Id, OwnerId, Name from Account where Name = 'Account CR4117'];
        list<User> listUser=[select id from User where Profile.name like '%Sales Rep%'Limit 2];
        list<Contact> listCon=[select id,AccountId from Contact where AccountId=:newAccount.id Limit 1];
        ID prevAccountOwner = newAccount.OwnerId;
        newAccount.OwnerId = listUser[1].Id;   
        update newAccount;
        //2. Simulating Acc Work Item Batch Job by manually updating Account WI: Status,New Owner & Prev Owner
        // Work_Items__c WI = [Select Id,Status__c,New_Owner__c, Previous_Owner__c,Account__c from Work_Items__c where Account__c =: newAccount.Id];
        Work_Items__c wor = [select id,Status__c,New_Owner__c,Previous_Owner__c,Account__c from Work_Items__c where Account__c =: newAccount.Id Limit 1];
        
        wor.Status__c = 'In Progress';
        wor.Previous_Owner__c = listUser[0].Id;
        wor.New_Owner__c = listUser[1].Id;
        update wor;
        
        //3. Execute Contact batch job
        BatchUpdateContact buContact = new BatchUpdateContact();
        buContact.isTest = true;
        buContact.queryContact = 'SELECT Id, AccountId FROM Contact '+ 
            'WHERE AccountId in (select Account__c FROM Work_Items__c where Id = \''+wor.Id+'\' AND Status__c = \'In Progress\' AND ' +
            'Object_Type__c = \'Account\')';
        
        Test.startTest();
        database.executeBatch(buContact); 
        Test.stopTest();
        
        //check result
        //1. New Work Item created| Object Type = Contact, Contact__c = Contact Id 
        Integer intnewContactWI = [SELECT count() FROM Work_Items__c where Contact__c =: listCon[0].Id];
        system.assertEquals(1, intnewContactWI);
        Work_Items__c newWI = [Select Id, Object_Type__c, Contact__c, Status__c from Work_Items__c where Contact__c =: listCon[0].Id Limit 1];
        system.debug('#### Contact New WI: ' + newWI);
        
        BatchUpdateContact buContact1 = new BatchUpdateContact();
        buContact1.isTest = false;
        buContact1.queryContact = 'SELECT Id, AccountId FROM Contact '+ 
            'WHERE AccountId in (select Account__c FROM Work_Items__c where Id = \''+wor.Id+'\' AND Status__c = \'In Progress\' AND ' +
            'Object_Type__c = \'Account\')';
        database.executeBatch(buContact1);
    }
    
    /*  //==================================================== TestDataCreation ===============================================================
static void TestDataCreation() {
//create Account
testAcc = new Account(
name='Account CR4117',
Account_Country_Code__c = 'AI',
Account_Country__c = 'ANGUILIA',            
Account_ID__c = ''+System.currentTimeMillis()
);
insert testAcc;        

//Contact Creation
testContactList.clear();
for (integer i = 0; i < 2; i++) {

testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
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

userRecord2 = new User(
Username='testUser2'+System.currentTimeMillis()+'@test.com',
Alias = 'test', 
Email='test2@dell.com', 
FirstName='Tfirst B', 
LastName='TLast',
ProfileId = userProfile[1].Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST56789',
Title = 'Test Title'
);
userRecordList.add(userRecord2);

insert userRecordList; 
}*/
}