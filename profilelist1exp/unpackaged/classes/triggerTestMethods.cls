/*
 * Author   : 
 * Purpose  : 
 *
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      
 * 2.0      CR12722     FY17-DCS-0401   15-Mar-2015     Gan             Added test methods to cover the TriggerHandler class      
 */

public class triggerTestMethods {
    static testMethod void contactTrigger() {
        Account at = new Account();
        at.name = 'Account Name';
        insert at;
        
        Contact ct = new Contact();
        ct.LastName = 'lastname';
        ct.AccountId = at.id;
        ct.Phone = '555-555-5555';
        ct.external_ref_id__c = '12345';
        insert ct;
        
        ct.MailingCity = 'city';
        Test.startTest();
        try {
            update(ct);
        } catch(Exception e) {
            //Do Nothing
        }
        Test.stopTest();
        //System.assertEquals('', ct.external_ref_id__c);
    }
    
    //2.0
    static testMethod void test_deleteUndeleteLead() {
        TriggerExecutionController.setSkipAllTriggers(true);
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.bCreate = true;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads2 = LeadTestData.lstLeads;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        integer intCountRecord = [Select count() from lead where id in (:listDirectLeads2[0].id, :listDirectLeads2[1].id)];
        
        Test.startTest();
        system.assertEquals(2, intCountRecord);
        delete listDirectLeads2;
        intCountRecord = [Select count() from lead where id in (:listDirectLeads2[0].id, :listDirectLeads2[1].id)];
        system.assertEquals(0, intCountRecord);
        undelete listDirectLeads2;
        intCountRecord = [Select count() from lead where id in (:listDirectLeads2[0].id, :listDirectLeads2[1].id)];
        system.assertEquals(2, intCountRecord);
        Test.stopTest();

    }

    //2.0
    static testMethod void test_deleteUndeleteContract() {
        Profile SSIprofile = [select id from profile where name like '%SSI Integration Connector API%' Limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = SSIprofile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        
        insert testUser;
        Account testAcc = new Account(name='testaccount');
        insert testAcc;
        system.Test.startTest();
        contract con = new Contract(accountId=testAcc.Id,Status='Pending',Completed__c=false,ownerid=testUser.id,Accounting__c=testUser.id);
        insert con;
        integer intCountRecord = [Select count() from contract where id = :con.id];
        system.assertEquals(1, intCountRecord);
        delete con;
        intCountRecord = [Select count() from contract where id = :con.id];
        system.assertEquals(0, intCountRecord);
        undelete con;
        intCountRecord = [Select count() from contract where id = :con.id];
        system.assertEquals(1, intCountRecord);
        system.Test.stopTest();
    }
   
   //2.0
   static testMethod void test_ExecutionCounter() {
        //TriggerHandler th = new TriggerHandler();
        TriggerHandler.ExecutionCounter th = new TriggerHandler.ExecutionCounter(1);
        th.isValid();
        th.incrementCounter();
        new TriggerHandler().skipTriggersOnObject('Contact');
        new TriggerHandler().getExecutionCounter();
        
   }
}