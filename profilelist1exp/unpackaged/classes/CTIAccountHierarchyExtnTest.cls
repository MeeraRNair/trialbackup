@isTest

private class CTIAccountHierarchyExtnTest {
    
    static list<Account> listAcc;
    static list<CTI_Call_Log__c> listCtiCL;
    static list<Contact> listCon;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(5,'Partner Account');
        insert listAccTdf;
        list<CTI_Call_Log__c> listCtiCLTdf=TestDataFactory.createNCTIcallLog(1);
        insert listCtiCLTdf;
        list<Contact> listConTdf=TestDataFactory.createNContacts(1);
        insert listConTdf;
    }
    static string strStartTime = '2011-06-15 09:30:15Z';
    static string strEndTime = '2011-06-15 09:50:15Z';
    //private static Account testAcc;
    static testMethod void testAccHierarchy() {
        listAcc = [Select Id from Account limit 5];
        listCon = [Select Id from Contact limit 1];
        listCon[0].AccountId =listAcc[1].id;
        system.assertNotEquals(listAcc[0].id, null);
        TriggerExecutionController.setSkipContactTriggers(True);
        update listCon;
        listCtiCL = [Select Id from CTI_Call_Log__c limit 1];
        listCtiCL[0].Account__c = listAcc[1].Id;
        listCtiCL[0].Contact__c = listCon[0].Id;
        listCtiCL[0].Call_Start_Time__c = datetime.valueOfGMT(strStartTime);
        listCtiCL[0].Call_End_Time__c = datetime.valueOfGMT(strEndTime);
        update listCtiCL;
        listAcc[1].parentid = listAcc[0].id;
        listAcc[2].parentid = listAcc[0].id;
        listAcc[3].parentid = listAcc[1].id;
        listAcc[4].parentid = listAcc[2].id;
        test.startTest();
        update listAcc;
        test.stopTest();
        //CTI_Call_Log__c ctiLog = TestDataCreation();
        ApexPages.StandardController stdCtrl= new ApexPages.StandardController(listCtiCL[0]);
        //ApexPages.StandardController stdCtrl= new ApexPages.StandardController(ctiLog);
        CTIAccountHierarchyExtn ctiExtn = new CTIAccountHierarchyExtn(stdCtrl);
        
        ApexPages.currentPage().getParameters().put('accountId', listAcc[0].Id);
        ctiExtn.save();
        //System.assertEquals(ctiLog.Account__c, listAcc[0].Id, 'Account updated successfully');
    }
    
    /*static CTI_Call_Log__c TestDataCreation() {
listAcc = [Select Id from Account limit 5];
listCon = [Select Id from Contact limit 1];
listCon[0].AccountId =listAcc[1].id;
update listCon;
listCtiCL = [Select Id from CTI_Call_Log__c limit 1];
listCtiCL[0].Account__c = listAcc[1].Id;
listCtiCL[0].Contact__c = listCon[0].Id;
listCtiCL[0].Call_Start_Time__c = datetime.valueOfGMT(sStartTime);
listCtiCL[0].Call_End_Time__c = datetime.valueOfGMT(sEndTime);
update listCtiCL;
listAcc[1].parentid = listAcc[0].id;
listAcc[2].parentid = listAcc[0].id;
listAcc[3].parentid = listAcc[1].id;
listAcc[4].parentid = listAcc[2].id;
test.startTest();
update listAcc;
test.stopTest();
testAcc = new Account(Name = 'Test Parent CTI Account', Account_Id__c = '001233445566');
insert testAcc;

Account testAccChild1 = new Account(Name = 'Test Child1 CTI Account', Account_Id__c = '0012334466', parentid=testAcc.id);
insert testAccChild1;

Account testAccChild2 = new Account(Name = 'Test testAccChild22 CTI Account', Account_Id__c = '0012345566',parentid=testAcc.id);
insert testAccChild2;

Account testAccChild11 = new Account(Name = 'Test Child12 CTI Account', Account_Id__c = '001445566',parentid=testAccChild1.id);
insert testAccChild11;

Account testAccChild21 = new Account(Name = 'Test testAccChild22 CTI Account', Account_Id__c = '00123344556',parentid=testAccChild2.id);
Test.startTest();
insert testAccChild21;
Test.stopTest();
// acc = new Account(Name = 'testAccount');
// insert acc;

Contact testCon = new Contact(AccountId = testAccChild1.Id,Email = 'test@test.com',FirstName = 'conFirstName',LastName = 'conLastName');
TriggerExecutionController.setSkipContactTriggers(True);
insert testCon;

CTI_Call_Log__c testCTILog = new CTI_Call_Log__c(Account__c = testAccChild1.Id, Contact__c = testCon.Id, Call_Start_Time__c = datetime.valueOfGMT(sStartTime), Call_End_Time__c = datetime.valueOfGMT(sEndTime), 
Router_Call_Key__c = '#123456', Router_Call_Day__c = '#098765',Call_Type__c = 'Incoming');
insert testCTILog;  

return testCTILog;
}
*/
}