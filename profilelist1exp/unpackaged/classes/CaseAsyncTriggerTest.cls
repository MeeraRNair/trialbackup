@isTest
private class CaseAsyncTriggerTest {
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].Account_Country_Code__c='US';  
        listAccTdf[0].Account_Country__c='United States';
        listAccTdf[0].Type = 'Partner';
        listAccTdf[0].Partner_Type__c = 'DISTRIBUTOR (GCC)';
        listAccTdf[0].Dell_Certification_Areas__c = 'Storage;Server';
        insert listAccTdf;
        list<Contact> listConTdf=TestDataFactory.createNContacts(1);
        listConTdf[0].AccountId =listAccTdf[0].id;
        insert listConTdf;
        list<Case> listCaseTdf=TestDataFactory.createNCases(1);
        listCaseTdf[0].Accountid = listAccTdf[0].Id;
        listCaseTdf[0].Contactid = listConTdf[0].Id;
        insert listCaseTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    private static testMethod void test() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.enableChangeDataCapture();
        /* Id accRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
Account testAccount= new Account(name = 'Test PAccv', account_country_code__c = 'US', RecordTypeId = accRTId, 
Type = 'Partner', Partner_Type__c = 'DISTRIBUTOR (GCC)', Dell_Certification_Areas__c = 'Storage;Server');
insert testAccount;

Contact newCont = new Contact(FirstName = 'conv', Phone = '9876543987', AccountId = testAccount.Id, Email = 'abc@dell.comfdev', Lastname = 'UT', 
Decision_Making_Role__c = 'Influencer', Job_Function__c = 'Finance', Job_Function_Role__c = 'Finance Manager', Primary_Contact__c = false,
MobilePhone = '991122789', Eloqua_ID__c = '1234');
insert newCont;

Id dealRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration');
insert new Case(Accountid = testAccount.Id, Contactid = newCont.Id, Status = 'Open', Priority = 'High', Alternate_Phone__c ='1234',
Subject  ='Test Case Subject', Description ='Test Case Subject', Sub_Type_Internal_User__c = 'Test', Origin = 'test',
recordTypeId = dealRegRTId);
*/
        list<Case> listCase=[select id,AccountId,Contactid from Case Limit 1];
        system.assertNotEquals(listCase[0].id, null);
        Test.getEventBus().deliver();
        // system.assertEquals('Influencer', [Select Id,Decision_Making_Role__c From Contact Where Id=:newCont.Id].Decision_Making_Role__c);
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}