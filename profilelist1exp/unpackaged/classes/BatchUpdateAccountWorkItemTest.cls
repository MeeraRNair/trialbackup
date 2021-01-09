/**
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      14-DEC-2010   Azwanti         Created for CR4117, R12.1
 */
@isTest
private class BatchUpdateAccountWorkItemTest {
    //Define variables
    static Account testAcc;
    static User userRecord1, userRecord2;
    static List<User> userRecordList = new List<User>();
    static List<Contact> testContactList = new List<Contact>();
    

    static testMethod void Test_AccWorkItem() {
        System.debug('====== Start :  Test_AccWorkItem =======');
        //change Account Owner
        TestDataCreation();
        Account newAccount = [Select Id, OwnerId from Account where Id =: testAcc.Id];
        ID prevAccountOwner = newAccount.OwnerId;
        newAccount.OwnerId = userRecord1.Id;   
        update newAccount;
        
        BatchUpdateAccountWorkItem buAccWorkItem = new BatchUpdateAccountWorkItem();
        buAccWorkItem.isTest = true;
        system.debug('#### isTest : ' + buAccWorkItem.isTest);
        buAccWorkItem.queryAccWorkItem = 'Select Id From Work_Items__c '+
            'Where Account__c = \''+newAccount.Id+'\' AND Status__c = \'Pending\' AND Object_Type__c = \'Account\' AND (Previous_Owner__c != \''+dellConfig.glblDataAdminGUID+'\' AND New_Owner__c != \''+dellConfig.glblDataAdminGUID+'\') '+
            (System.Label.BatchUpdAccWorkItem_Row_Limit != '-'? 'ORDER BY LastModifiedDate LIMIT ' + System.Label.BatchUpdAccWorkItem_Row_Limit : '');
        
        Test.startTest();   
        Database.executeBatch(buAccWorkItem);
        system.debug('#### after isTest : ' + buAccWorkItem.isTest);
        Test.stopTest();
        
        //check result
        Work_Items__c AccountWI = [Select Id, Account__c, Status__c, Object_Type__c, Previous_Owner__c, New_Owner__c 
                                    from Work_Items__c where Account__c =: newAccount.Id];
        system.debug('#### WI Status : ' + AccountWI.Status__c);
        system.assertEquals('In Progress',AccountWI.Status__c);
    }
    
    //==================================================== TestDataCreation ===============================================================
    static void TestDataCreation() {
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
    }
}