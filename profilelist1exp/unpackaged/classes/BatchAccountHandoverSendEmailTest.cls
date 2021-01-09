/* 
History:
Version     Date            Modified By     CR          Description     
--------------------------------------------------------------------------------------
1.0         11-Sep-2015     Shue            11838       Test class created for BatchAccountHandoverSendEmail
2.0         19-May-2016     Rajkumar        14340       scheduled apex classes 
*/

@isTest
private class BatchAccountHandoverSendEmailTest {

    static User uIR1;
    static User uIR2;
    static User uATM1;
    static User uATM2;
    static Account ac;
    static Account_Handover__c ah1;
    static Account_Handover__c ah2;
    static AccountTeamMember atm1; 
    static AccountTeamMember atm2;
    
    static void createTestData(){
        Profile p = [select id from profile where name='System Administrator'];
        //String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
        uIR1 = new User(alias = 'test1', email='uIR1@dell.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',            
        timezonesidkey='America/Los_Angeles', username='uIR1@dell.com', Badge_Number__c = '1xs111');
        insert uIR1;
        
        uIR2 = new User(alias = 'test2', email='uIR2@dell.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',            
        timezonesidkey='America/Los_Angeles', username='uIR2@dell.com', Badge_Number__c = '1xs214');
        insert uIR2;
        
        uAtm1 = new User(alias = 'testATM1', email='testATM1@dell.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',            
        timezonesidkey='America/Los_Angeles', username='testATM1@dell.com', Badge_Number__c = '11xs112');
        insert uAtm1;
        
        uAtm2 = new User(alias = 'uAtm2', email='uAtm2@dell.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='United States',            
        timezonesidkey='America/Los_Angeles', username='uAtm2@dell.com', Badge_Number__c = '11xs13');
        insert uAtm2;
        
        ac = new Account();
        ac.Name = 'Test Account 1';
        insert ac;
        
        ah1 = new Account_Handover__c();
        ah1.Account__c = ac.Id;
        //ah1.Incoming_rep__c = uIR1.Id;
        ah1.Account_Transition_owner__C = uIR1.Id;
        ah1.Transition_Start_date__c = Date.Today();
        //ah.Account_Access_Share__c = false;
        insert ah1;
        
        ah2 = new Account_Handover__c();
        ah2.Account__c = ac.Id;
       // ah2.Incoming_rep__c = uIR2.Id;
        ah2.Account_Transition_owner__C = uIR2.Id;
        ah2.Transition_Start_date__c = Date.Today();
        //ah.Account_Access_Share__c = false;
        insert ah2;
        
        atm1 = new AccountTeamMember();
        atm1.AccountId = ac.Id;
        atm1.UserId = uAtm1.Id;
        atm1.TeamMemberRole = 'Account Executive';
        insert atm1;
        
        atm2 = new AccountTeamMember();
        atm2.AccountId = ac.Id;
        atm2.UserId = uAtm2.Id;
        atm2.TeamMemberRole = 'Account Sales Rep';
        insert atm2;
    }
    
    private static testMethod void test() {
        //createTestData();
        
        Test.startTest();
        
        //String jobId = system.scheduleBatch(new BatchAccountHandoverSendEmail (), 'Send Email to Incoming Reps NOW', 0);
        //2.0 - scheduled apex classes 
        String CRON_EXP = '0 0 0 * * ?';
        String jobId = System.schedule('BatchAccountHandoverSendEmailSchedule test', CRON_EXP, new BatchAccountHandoverSendEmailSchedule());

        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        BatchAccountHandoverSendEmail controller = new BatchAccountHandoverSendEmail(); 
        //controller.execute();
        controller.handleError(new TestException('This is test exception'));
        
        Test.stopTest(); 
    }
    
    //test no IR
    private static testMethod void testNoIR() {
        createTestData();
        
        ah1.Incoming_rep__c = null;
        update ah1;
        ah2.account_transition_owner__c = null;
        update ah2;
        
        Test.startTest();
        //String jobId = system.scheduleBatch(new BatchAccountHandoverSendEmail (), 'Send Email to Incoming Reps NOW', 0);
        //2.0 -- scheduled apex classes
        String CRON_EXP = '0 0 0 * * ?';
        String jobId = System.schedule('BatchAccountHandoverSendEmailSchedule test', CRON_EXP, new BatchAccountHandoverSendEmailSchedule());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        Test.stopTest(); 
        
       // system.assertEquals(null, ah1.Account_Transition_Owner__c);
        system.assertEquals(null, ah2.Account_Transition_Owner__c);
    }
    
    public class TestException extends Exception {}
    
    //test 1IR 1AE
    private static testMethod void test1IR1AE() {
        createTestData();
        
        ah2.Incoming_rep__c = null;
        update ah2;
        
        Test.startTest();
        //String jobId = system.scheduleBatch(new BatchAccountHandoverSendEmail (), 'Send Email to Incoming Reps NOW', 0);
        //2.0 -- scheduled apex classes
        String CRON_EXP = '0 0 0 * * ?';
        String jobId = System.schedule('BatchAccountHandoverSendEmailSchedule test', CRON_EXP, new BatchAccountHandoverSendEmailSchedule());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        Test.stopTest(); 
        
        system.assertEquals(uIR1.Id, ah1.account_Transition_owner__c);
        //system.assertEquals(null, ah2.Account_Transition_Owner__c);
        system.assertEquals(uAtm1.Id, atm1.userId);
        system.assertequals('Account Executive', atm1.TeamMemberRole);
    }
}