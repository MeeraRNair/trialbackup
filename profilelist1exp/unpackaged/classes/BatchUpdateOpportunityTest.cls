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
private class BatchUpdateOpportunityTest {
    //Define variables
    // static Account testAcc;
    //static User userRecord1, userRecord2;
    //static List<User> userRecordList = new List<User>();
    //static List<Contact> testContactList = new List<Contact>();
    //static Opportunity OpptyA;
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
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountID=listAccTdf[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testUpdateOpptyOwner() {
        system.debug('====== Start :  Test_UpdateOpptyOwner =======');
        Account newAccount = [Select Id, OwnerId, Name from Account where Name = 'Account CR4117'];
        list<User> listUser=[select id from User where Profile.name like '%Sales Rep%'Limit 2];
        list<Contact> listCon=[select id,AccountId from Contact where AccountId=:newAccount.id Limit 1];
        list<Opportunity> listOpp=[select id,OwnerId from Opportunity where accountId=:newAccount.id Limit 1];
        listOpp[0].OwnerId=listUser[0].id;
        TriggerExecutionController.setSkipAllTriggers(true);
        update listOpp;
        TriggerExecutionController.setSkipAllTriggers(false);
        system.assertNotEquals(newAccount.id, null);
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
        Test.startTest(); 
        
        //3. Run Batch Process
        BatchUpdateOpportunity buOppty = new BatchUpdateOpportunity();
        buOppty.isTest = true;
        buOppty.QueryForOpp = 'SELECT Id FROM Opportunity '+ 
            'WHERE AccountId in (select Account__c FROM Work_Items__c where Id = \''+wor.Id+'\' AND Status__c = \'In Progress\' AND Object_Type__c = \'Account\')';
        system.debug('### QueryForOpp : ' + buOppty.QueryForOpp);
        
        database.executeBatch(buOppty); 
        system.debug('====== After OpptyA.OwnerId : ' + listOpp[0].OwnerId);
        system.debug('====== After newAccount.OwnerId : ' + newAccount.OwnerId);
        Test.stopTest(); 
        
        //Check result
        //1. Account New Owner = Oppty Owner
        Opportunity newOppty = [Select Id, Name, OwnerId from Opportunity where Id =: listOpp[0].Id];
        //system.debug('CHECK RESULT --> newOppty.OwnerId: ' + listOpp[0].OwnerId + '; newAccount.OwnerId: ' + newAccount.OwnerId);
        //system.assertEquals(newAccount.OwnerId, newOppty.OwnerId);    
        //2. New Work Item created| Object Type = Opportunity, Opportunity__c = Oppty Id
        Work_Items__c newWI = [Select Id,Status__c,Opportunity__c,Object_Type__c from Work_Items__c where Opportunity__c =: listOpp[0].Id];
        //system.debug('#### newWI: ' + newWI);
        //system.assertEquals(OpptyA.Id, newWI.Opportunity__c);    
        //
        BatchUpdateOpportunity buOppty1 = new BatchUpdateOpportunity();
        buOppty1.isTest = false;
        buOppty1.QueryForOpp = 'SELECT Id FROM Opportunity '+ 
            'WHERE AccountId in (select Account__c FROM Work_Items__c where Id = \''+wor.Id+'\' AND Status__c = \'In Progress\' AND Object_Type__c = \'Account\')';
        //system.debug('### QueryForOpp : ' + buOppty1.QueryForOpp);
        
        database.executeBatch(buOppty1); 
    }
    /*
//==================================================== TestDataCreation ===============================================================
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

//Create OpptyA for Account Account CR4117
OpptyA = new Opportunity(Name = 'Oppty CR4117', AccountId = testAcc.Id, Type = 'Deal/Bid - Direct', 
Solution_Type__c = 'Client Hardware Only', StageName = 'Discover - 10%', CloseDate = date.today().addDays(20), OwnerId = userRecord1.Id);
insert OpptyA;
system.debug('====== Before OpptyA.OwnerId : ' + OpptyA.OwnerId);
}*/
}