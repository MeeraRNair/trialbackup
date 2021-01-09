/***********************************************************
* Name          : BatchConvertAccountTest
* Description   : Convert End User Account to Partner Account and Partner Account to End User if Partner Users > 15
* ---------------------------------------------------------
* Revision     Name    Date            Description
* 1.0         Bikram   19.07.2016      Convert End User Account to Partner Account and Partner Account to End User if Partner Users > 15 using Batch Apex
* 2.0         VIKAS KH					Implemented TDF for 0202 Release
***********************************************************/
@isTest 
private class BatchConvertAccountPAtoEATest{
    static list<Account> listAcc;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
    }
    static testMethod void batchConvertAccountPatoEATest1() {
        TriggerExecutioncontroller.setskipAllTriggers(True);
                    test.startTest();
        Id p = [select id from profile where name='R16.10 APJ PRM Portal User (MOSS)'].id;
//        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
//        Account act = new Account(Name='TestAccount',RecordTypeID = devRecordTypeId, Type = 'End User');
//        insert act;
        listAcc = [select id from Account limit 1];
        listAcc[0].Type = 'End User';
        update listAcc;
		system.assertEquals(listAcc[0].Type, listAcc[0].Type);
        List<Contact> listcons = new List<Contact>();
        Contact con = new Contact(LastName ='testCon',FirstName='First',AccountId = listAcc[0].Id,Email='test123@mail.com');     
        
        for (Integer intj=0;intj<=20;intj++){
            // For each account just inserted, add contacts
            listcons.add(new Contact(firstname='Test'+intj, lastname='Test'+intj, email='test'+intj+'@test.com', AccountId=listAcc[0].Id));
        }
        
        // Insert all contacts for all accounts
        listcons.add(con);
        insert listcons;
                  
        User user = new User(alias = 'test123', email='tester@mymail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,Badge_Number__c='testtest111',
                timezonesidkey='America/Los_Angeles', username='tester@mymail.com');
       
        insert user;
        
        system.runAs(user){
            BatchConvertAccountPAtoEA batch = new BatchConvertAccountPAtoEA();
            Database.executeBatch(batch);
            test.stopTest();
        }
   }
      
}