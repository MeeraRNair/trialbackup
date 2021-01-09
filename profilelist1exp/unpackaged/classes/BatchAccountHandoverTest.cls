/*====================================================================================================================+
|  HISTORY |                                                                 
|                                                                           
| DATE         Modified              Story           DESCRIPTION                               
| ===========  =========           =========          =========== 
| 06-Dec-2019  Venu K 				  0102			   Implemented TDF
+====================================================================================================================*/

@isTest(seealldata=false)                           
private class BatchAccountHandoverTest {
    @testSetup static void setup() {
        Profile p = [select id from profile where name='System Administrator'];
        //String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
        User u = new User(alias = 'test123', email='testcr10089@dell.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id, country='United States',            
                          timezonesidkey='America/Los_Angeles', username='testusercr10091@dell.com',isActive=true, Badge_Number__c = '111222');
        insert u;
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
    }
    static testmethod void testMethod1() {
        //String query = 'SELECT Id, Account__c, Incoming_rep__c, Outgoing_rep__c, Transition_Start_date__c, Account_Access_Share__c, Incoming_rep__r.Email, Account_ID__c FROM Account_Handover__c Where Account_Access_Share__c = false AND Incoming_rep__c != null AND Transition_Start_date__c <= Today';
        /*  Profile p = [select id from profile where name='System Administrator'];
//String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
User u = new User(alias = 'test123', email='testcr10089@dell.com',
emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
localesidkey='en_US', profileid = p.Id, country='United States',            
timezonesidkey='America/Los_Angeles', username='testusercr10091@dell.com', Badge_Number__c = '111222');
insert u;

//Account ac = [SELECT Id FROM Account limit 1];

Account ac = new Account();
ac.Name = 'TestAccount 10091';
insert ac;
*/
        User usr=[select id from User where Profile.Name='System Administrator' and isActive=true limit 1];
        list<Account> listAcc=[Select id from Account Limit 1];
        Account_Handover__c ah = new Account_Handover__c();
        ah.Account__c = listAcc[0].Id;
        ah.Outgoing_rep__c = usr.Id;
        ah.Incoming_rep__c = usr.Id;
        ah.Transition_Start_date__c = Date.Today();
        ah.Account_Access_Share__c = false;
        insert ah;
        AccountShare accshare = new AccountShare();
        accshare.AccountId = listAcc[0].Id;
        accshare.AccountAccessLevel = 'Read';
        accshare.OpportunityAccessLevel = 'Read';
        accshare.UserOrGroupId  = ah.Incoming_rep__c;
        insert accshare;
        system.assertEquals(ah.Incoming_rep__c, usr.Id);
        system.assertEquals(ah.Account__c, listAcc[0].Id);
        system.assertEquals(ah.Account_Access_Share__c, false);
        Test.startTest();
        String strsch = '0 0 8 * * ?';
        BatchAccountHandoverSchedule rlBatch = new BatchAccountHandoverSchedule ();
        String strjobId = system.schedule('BatchAccountHandoverSchedule',strsch , rlBatch);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :strjobId];
        // Verify the expressions are the same
        System.assertEquals(strsch,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();          
    }
    static testmethod void testMethod2() {
        //String query = 'SELECT Id, Account__c, Incoming_rep__c, Outgoing_rep__c, Transition_Start_date__c, Account_Access_Share__c, Incoming_rep__r.Email, Account_ID__c FROM Account_Handover__c Where Account_Access_Share__c = false AND Incoming_rep__c != null AND Transition_Start_date__c <= Today';
        /*   Profile p = [select id from profile where name='System Administrator'];
//String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
User u = new User(alias = 'test123', email='testcr10089@dell.com',
emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
localesidkey='en_US', profileid = p.Id, country='United States',            
timezonesidkey='America/Los_Angeles', username='testusercr10091@dell.com', Badge_Number__c = '111222');
insert u;

//Account ac = [SELECT Id FROM Account limit 1]; 

Account ac = new Account();
ac.Name = 'TestAccount 10091';
insert ac;
*/ 
        User usr=[select id from User where Profile.Name='System Administrator' and isActive=true Limit 1];
        list<Account> listAcc=[Select id from Account Limit 1];
        AccountTeamMember atm = New AccountTeamMember();
        atm.AccountId = listAcc[0].id;
        atm.UserId = usr.id;
        atm.TeamMemberRole = 'Inside Sales Rep';
        atm.CaseAccessLevel='Read';
        atm.OpportunityAccessLevel='Read';
        Insert atm;
        Account_Handover__c ah = new Account_Handover__c();
        ah.Account__c = listAcc[0].Id;
        ah.Outgoing_rep__c = usr.Id;
        ah.Incoming_rep__c = usr.Id;
        ah.Transition_Start_date__c = Date.Today();
        ah.Account_Access_Share__c = false;
        insert ah;
        AccountShare accshare = new AccountShare();
        accshare.AccountId = listAcc[0].Id;
        accshare.AccountAccessLevel = 'Read';
        accshare.OpportunityAccessLevel = 'Read';
        accshare.UserOrGroupId  = ah.Incoming_rep__c;
        insert accshare;
        system.assertEquals(ah.Incoming_rep__c, usr.Id);
        system.assertEquals(ah.Account__c, listAcc[0].Id);
        system.assertEquals(ah.Account_Access_Share__c, false);
        Test.startTest();
        String strsch = '0 0 8 * * ?';
        BatchAccountHandoverSchedule rlBatch = new BatchAccountHandoverSchedule ();
        String strjobId = system.schedule('BatchAccountHandoverSchedule',strsch , rlBatch);
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :strjobId];
        // Verify the expressions are the same
        System.assertEquals(strsch,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();          
    }
}