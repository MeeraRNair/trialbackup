@isTest

private class ContactAfterInsertUpdateTest {
    //Test method for  - Allow for dataloading on Primary Contact - Contact Object
    static testMethod void testContactAfterIU() {
        Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
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
        System.runAs(testUser){
            Account testAccount = new Account(Name='Test Account',Type = 'End User',
                                                OwnerId = testUser.Id);
            insert testAccount;
            Contact testContact = new Contact(FirstName='first', LastName='last', Phone='044223667788',
                                                Email='s@s.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                                Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                                AccountId=testAccount.Id);
            insert testContact;
            testContact.Primary_Contact__c = true;
            update testContact;
            
            Account accObj = [select Name, Primary_Contact__c from Account where Primary_Contact__c =: testContact.Id];
            String primaryContact = accObj.Primary_Contact__c;
            System.assertEquals(testContact.Id,primaryContact);
        }
    }
    
    //Test method for  - Update 2 Lookup fields to Account according to the status of Contact record
    static testMethod void testContactUpdateActiveInactiveLookupFieldsToAccount() {
        Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        
        User testUser = new User(Username='testvaliduser' +'@dell.com',
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
        System.runAs(testUser){
            Account testAccount = new Account(Name='Test Account',Type = 'End User',
                                                OwnerId = testUser.Id);
            insert testAccount;
            Contact testContact = new Contact(FirstName='first', LastName='last', Phone='044223667788',
                                                Email='s@dell.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                                Job_Function_Role__c='Finance Manager', Status__c= 'INTERNAL - Crisis Mgmt', 
                                                AccountId=testAccount.Id);
            insert testContact;
             
            System.debug('### testAccount.Id: ' + testAccount.Id);
            System.debug('### testAccount.status : ' + testAccount.Status__c);
            System.debug('### testContact.Account_Active_Contact__c: ' + testContact.Account_Active_Contact__c);
            //System.assertEquals(testContact.Account_Active_Contact__c, testAccount.Id);
            
            testContact.Status__c = 'Invalid - Bad Email';
            update testContact;
             System.debug('### testAccount.Id: ' + testAccount.Id);
            System.debug('### testAccount.status : ' + testAccount.Status__c);
            System.debug('### testContact.Account_Inactive_Contact__c: ' + testContact.Account_Inactive_Contact__c);
            //System.assertEquals(testContact.Account_Active_Contact__c, testAccount.Id);
            
            //System.assertEquals(testContact.Account_Inactive_Contact__c, testAccount.Id);
        }
    }
}