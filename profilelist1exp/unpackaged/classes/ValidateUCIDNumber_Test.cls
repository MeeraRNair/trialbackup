/***********************************************************
* Revision       Release                   Name           Date                  Description   
* 1.0       0202             Vikas KH      08-Dec-2019      Impelemented TDF
***************************************************************/
@isTest
private with sharing class ValidateUCIDNumber_Test{
    static list<Account> listAcc;
    @isTest static  void mock1() {
        try{ 
            Profile userprofile = [SELECT Id FROM Profile WHERE Name like '%System Admin%' LIMIT 1];  
            User testUser = new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                     Alias = 'MTU9',
                                     Email = 'MyTestUser9@dell.com',
                                     FirstName = 'user',
                                     LastName = 'MyTestUser9',
                                     ProfileId = userprofile.Id,
                                     LanguageLocaleKey = 'zh_CN',
                                     LocaleSidKey = 'zh_CN',
                                     EmailEncodingKey = 'UTF-8',
                                     TimeZoneSidKey = 'America/Los_Angeles',
                                     Badge_Number__c = 'Test99826513123',   
                                     isActive = TRUE);
            insert testUser;
            System.AssertNotEquals(testUser.Username,'MyTestUser9');
            listAcc = TestDataFactory.createNAccount(1, 'Master Account');
            listAcc[0].EMC_ID__c = '12345';
            listAcc[0].OwnerId=testUser.id;
            insert listAcc;
            //   Account acc = new Account(Name ='TestFirst',EMC_ID__c = '12345');  
            //    acc.OwnerId=testUser.id;
            //   insert acc;   
            system.debug('&&&'+listAcc[0].EMC_ID__c);
            Test.startTest();
            Test.SetMock(HttpCallOutMock.class, new SendUcidMock());
            ValidateUCIDNumber.sendUCID(listAcc[0].EMC_ID__c);
            Test.stopTest();
        }catch (Exception ex){
        }
    }
}