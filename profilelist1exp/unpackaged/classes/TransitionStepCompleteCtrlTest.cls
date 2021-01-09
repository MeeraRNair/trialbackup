/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest(seeAllData=false)
private class TransitionStepCompleteCtrlTest {
    // static Account_Handover__c testAccountHandover;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAccountTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        insert listAccTdf;
        list<Account_Handover__c> listAccHandTdf=TestDataFactory.createNAccountHandover(1);
        listAccHandTdf[0].Account__c=listAccTdf[0].id;
        insert listAccHandTdf;
        TriggerExecutionController.setSkipAccountTriggers(false);
    }
    static testMethod void completeTransitionSteps() {
        //createTestData();
        Account_Handover__c testAccountHandover=[select id,Tier_Level__c,Step_1__c from Account_Handover__c Limit 1];
        system.assertNotEquals(testAccountHandover.id, null);
        Test.startTest();    
        TransitionStepCompleteCtrl controller = new TransitionStepCompleteCtrl (new ApexPages.StandardController(testAccountHandover)); 
        controller.doComplete();
        controller.handleError(new TestException('This is test exception'));
        Test.stopTest();  
    }
    public class TestException extends Exception {}
    
    /* static void createTestData() {

//insert Account record
Account testAccount = new Account(name='testAccount' + System.currentTimeMillis()
//,Type = 'End User'
);        
TriggerExecutionController.setSkipAccountTriggers(true);
insert testAccount;
TriggerExecutionController.setSkipAccountTriggers(false);

//insert Account Handover records
testAccountHandover = new Account_Handover__c(Account__c=testAccount.Id, Tier_Level__c ='White Glove', 
Step_1__c ='Test 1', Step_2__c ='Test 2', Step_3__c ='Test 3', 
Step_4__c ='Test 4', Step_5__c ='Test 5', Step_6__c ='Test 6',
Step_7__c ='Test 7', Step_8__c ='Test 8'); 


insert testAccountHandover ;          

}
*/
}