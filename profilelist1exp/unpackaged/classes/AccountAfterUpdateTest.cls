@isTest

private class AccountAfterUpdateTest {
    private static User testUser;

    //Test method for  - Allow for dataloading on Primary Contact - Account Object
    static testMethod void testAccountAfterUpdate() {    
        createTestData();
        testUser = [select Id from User where Username = 'testvaliduser@dell.com' limit 1];
        System.runAs(testUser){
            Account testAccount = new Account(Name='Test Account',Type = 'End User',
                                                OwnerId = testUser.Id);
            insert testAccount;
            Contact testContact = new Contact(FirstName='first', LastName='last', Phone='044223667788',
                                                Email='s@s.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                                Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                                AccountId=testAccount.Id);
            insert testContact;
            Test.startTest();
            testAccount.Primary_Contact__c = testContact.Id;
            update testAccount;
            Test.stopTest();
            Contact contObj = [select AccountId, Primary_Contact__c from Contact where AccountId =: testAccount.Id];
            boolean primaryContact = contObj.Primary_Contact__c;
            System.assertEquals(true,primaryContact);            
      
        }
    }
    
    //azwanti R15.03 : separated the test from testAccountAfterUpdate() above
    static testMethod void testAccountAfterUpdate2(){
        createTestData();
        testUser = [select Id from User where Username = 'testvaliduser@dell.com' limit 1];
        System.runAs(testUser){
            Account testAccount = new Account(Name='Test Account',Type = 'End User',
                                                OwnerId = testUser.Id);
            insert testAccount;
            
            Contact testContact1 = new Contact(FirstName='first', LastName='last', Phone='044223667788',
                                                Email='s@s.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                                Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                                AccountId=testAccount.Id);
            insert testContact1;
            Test.startTest();
            testAccount.Primary_Contact__c = testContact1.Id;
            update testAccount;
            Test.stopTest();
            Contact contObj1 = [select AccountId, Primary_Contact__c from Contact where AccountId =: testAccount.Id and
                                Primary_Contact__c = true];
            boolean primaryContact1 = contObj1.Primary_Contact__c;
            System.assertEquals(true,primaryContact1);
        }
    }
    
    //azwanti R15.03 :added for test class fix
    private static void createTestData(){
        Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
    }
}