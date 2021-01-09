/***********************************************************
* Revision       Release                   Name           Date                  Description   
* 1.0       0202             Vikas KH      08-Dec-2019      Impelemented TDF
***************************************************************/
@isTest
//(seeAllData=false)
private class AccntHandoverKeyContactsCtrlTest {
    Static list<Account> listAcc;
    static Account_Handover__c testAccountHandover;    
    @testSetup Static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Master Account');
        insert listAccTDF;
    }    
    static testMethod void displayTopTenAccntHandoverKeyContacts() {
        createTestData();
        Test.startTest();    
        AccntHandoverKeyContactsCtrl controller = new AccntHandoverKeyContactsCtrl (new ApexPages.StandardController(testAccountHandover)); 
        controller.getContacts();
        Account_Handover__c retrievedAccHandover = controller.accHandover;
        List<Contact> listretrievedContacts = controller.contacts ;
    system.assertNotEquals(null, retrievedAccHandover.name);        
        Test.stopTest();          
    }
    static testMethod void displayAllAccntHandoverKeyContacts() {
        createTestData();
        Test.startTest();    
        AccntHandoverKeyContactsCtrl controller = new AccntHandoverKeyContactsCtrl (new ApexPages.StandardController(testAccountHandover)); 
        controller.getAllContacts();
        controller.handleError(new TestException('This is test exception'));
        system.assertNotEquals(null, Account_Handover__c.name);        
        Test.stopTest();  
    }
    public class testException extends Exception {}
    static void createTestData() {
        //insert Account record
        //     Account testAccount = new Account(name='testAccount' + System.currentTimeMillis());        
        //     insert testAccount;
        listAcc = [select id,name from Account limit 1];  
        //insert Account Handover records
        system.assertNotEquals(null, listAcc[0].Name);
        testAccountHandover = new Account_Handover__c(Account__c=listAcc[0].Id, Tier_Level__c ='White Glove', 
                                                      Step_1__c ='Test 1', Step_2__c ='Test 2', Step_3__c ='Test 3', 
                                                      Step_4__c ='Test 4', Step_5__c ='Test 5', Step_6__c ='Test 6',
                                                      Step_7__c ='Test 7', Step_8__c ='Test 8', Status01__c ='Not Started',
                                                      Status02__c ='Not Started', Status03__c ='Not Started',
                                                      Status04__c ='Not Started', Status05__c ='Not Started',
                                                      Status06__c ='Not Started', Status07__c ='Not Started',
                                                      Status08__c ='Not Started'); 
        insert testAccountHandover ;          
    }    
}