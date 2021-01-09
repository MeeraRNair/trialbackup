/**
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      14-DEC-2010   Azwanti         Created for CR4117, R12.1
 */
@isTest
private class BatchUpdateAccountTaskTest {
    //Define variables
    static Account testAcc;
    static User userRecord1, userRecord2;
    static List<User> userRecordList = new List<User>();
    static List<Contact> testContactList = new List<Contact>();
    static Task task;

    static testMethod void Test_UpdateAccTaskOwner() {
       TestDataCreation();
       //1. Account Owner transition from userRecord1 to userRecord2
        Account newAccount = [Select Id, OwnerId, Name from Account where Name = 'Account CR4117'];
        ID prevAccountOwner = newAccount.OwnerId;
        newAccount.OwnerId = userRecord2.Id;   
        update newAccount;
        //2. Simulating Acc Work Item Batch Job by manually updating Account WI: Status,New Owner & Prev Owner
        Work_Items__c WI = [Select Id,Status__c,New_Owner__c, Previous_Owner__c,Account__c from Work_Items__c where Account__c =: newAccount.Id];
        WI.Status__c = 'In Progress';
        WI.Previous_Owner__c = userRecord1.Id;
        WI.New_Owner__c = userRecord2.Id;
        update WI;
        
        //3. Execute Account Task batch job
        BatchUpdateAccountTask buAccTask = new BatchUpdateAccountTask();
        buAccTask.isTest = true;
        buAccTask.queryAccTask = 'SELECT WhatId, AccountId, OwnerId '+
                                 'FROM Task WHERE WhatId in (SELECT Account__c FROM Work_Items__c WHERE Id = \''+WI.Id+'\' AND Status__c = \'In Progress\' AND Object_Type__c = \'Account\') AND '+
                                 'IsClosed = false';
        
        Test.startTest();
        database.executeBatch(buAccTask); 
        Test.stopTest();
        
        //check result
        //1. Account New Owner = Account Task Owner
        Task newAccTask = [Select Id, OwnerId from Task where Id =: task.Id];
        system.assertEquals(newAccount.OwnerId, newAccTask.OwnerId);
    }
    
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
        
        //create Task
        task = new Task(WhatId = testAcc.Id, OwnerId = userRecord1.Id);
        insert task;
    }
}