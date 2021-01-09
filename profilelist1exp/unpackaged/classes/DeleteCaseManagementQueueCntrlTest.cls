/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
public class DeleteCaseManagementQueueCntrlTest{
    @testSetup static void setup() {
        list<Case_Management_Queue__c> listCaseMagQueTdf=TestDataFactory.createNCaseManagementQueues(1);
        insert listCaseMagQueTdf;
    }
    static testmethod void testLoadData(){
        /* Case_Management_Queue__c c = new Case_Management_Queue__c ();
c.Name= 'EMEA';
c.Country__c ='INDIA';
c.Segment__c ='ES';
insert c;
*/
        Case_Management_Queue__c caseMangQue=[select id,Name,Country__c,Segment__c From Case_Management_Queue__c where Name= 'EMEA' Limit 1];
        system.assertNotEquals(caseMangQue.id, null);
        ApexPages.StandardController sc = new ApexPages.standardController([SELECT Id,Name FROM Case_Management_Queue__c LIMIT 1]);
        DeleteCaseManagementQueueCntrl obj = new DeleteCaseManagementQueueCntrl(sc);
        obj.allow=false;
        Pagereference p = obj.deleteQueue();
        DeleteCaseManagementQueueCntrl.execute =false;         
        obj.allow=true;
        p = obj.deleteQueue();
    }
}