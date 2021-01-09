/************************
* Test class for processExceptionPE
* **********************/
@isTest
public class processExceptionPETest {
    @isTest static void testprocessPE(){
        Test.startTest();  
        Exception_Log__e pe = new Exception_Log__e();
        pe.Object__c = 'Account';
        pe.Operation__c = 'Account Country Population';
        pe.Exception_Details__c = 'Exception happened during process';
        pe.Record_ID__c = 'accid';
        eventBus.publish(pe);
        Test.stopTest();
        List<Exception__c> ex = [SELECT id from Exception__c where Object__c='Account'];
        System.assert(ex.size()>0);
    }
    
}