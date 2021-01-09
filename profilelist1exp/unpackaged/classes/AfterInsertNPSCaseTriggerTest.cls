@isTest(seeAllData =  true)
public class AfterInsertNPSCaseTriggerTest{
    
    
    static testmethod void testLoadData(){
      RecordType RecType= [SELECT ID, Name from RecordType WHERE NAme= 'NPS Cases' LIMIT 1];
        // Harry commented [1-Aug-2014]: returned account in MOCK sandbox does not have any contact, thus System.QueryException: List has no rows for assignment to SObject happened during mock validation
        //Account acc = [Select Id,Account_ID__c from Account WHERE Account_ID__c != null Limit 1];
        //Contact cnct = [SELECT ID,AccountID,Name from Contact WHERE AccountID =: acc.Id AND Phone != null LIMIT 1];
        // Harry added [1-Aug-2014]: To create test data instead
        //Test.startTest();
        //Account acc = new Account(Name = 'Test Account');
        //insert acc;
        string email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        
         Id recTypeId = [Select Id From RecordType Where SObjectType ='Account' Limit 1][0].Id;

         Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
         User u = new User(LastName = 'Test', isActive = true, Badge_Number__c = 'BADGE101',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
         insert u;
         System.assert(u != null);
         //This asserts that prior to adding the account, there are no accountteammembers
         list<AccountTeamMember> atms = [Select Id From AccountTeamMember limit 1];
         //system.assertEquals(0, atms.size());
        
         Account acc = new account(name='test',Type='Partner', BillingCountry = 'United Kingdom', OwnerId = u.Id, RecordTypeId = recTypeId);
         TriggerExecutionController.setSkipAccountTriggers(true);
         insert acc;
         TriggerExecutionController.setSkipAccountTriggers(false);
        
        Contact con = new Contact(AccountId = acc.Id, Email = email, Lastname = 'UT');
        TriggerExecutionController.setSkipAccountTriggers(true);
        insert con;
        TriggerExecutionController.setSkipAccountTriggers(false);
        //Test.stopTest();
        Contact cnct = [SELECT ID,AccountID,Name from Contact WHERE Id=:con.Id];
        
         //Shows that after your trigger fires, there is now a team member in the system
         atms = [Select Id From AccountTeamMember limit 1];
        // system.assertEquals(1, atms.size());
        
        //AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Sales Manager',AccountId = acc.Id,UserId = u.id);
        //insert atbr;

         //Asserts that the team member that was added was your test user, on your test account, and the role that is specified in your trigger
         //AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :acc.Id And userId = :u.Id];
        
        //system.assertEquals(atm.TeamMemberRole, 'Sales Manager');
                
        
        
    
        Case c = new Case();
        c.RecordTypeId = RecType.Id;
        c.NPS_Category__c ='Detractor';
        c.Status = 'Not Started';
        c.Priority = 'High';
        c.Account_Affinity_id__c = acc.Account_ID__c;
     //   c.ContactId = cnct.Id;
        c.Country__c = 'Australia';
        c.Segment__c = 'SB';
        c.Sub_Segment__c = '';
        c.Subject ='Detractor';
        c.Client_solution__c = '1';
        c.Online__c ='5';
        c.Tech_support__c='2';
        //c.Enterprise_Solution__c = '2';
        //c.S_P__c = '9';
        c.software__c='3';
        c.Order_Support__c = '7';
        c.Services__c ='1';
        c.Owner_ID__c = '576957';
        c.Description = 'd';
      //  c.AccountId = acc.Id;
        Test.startTest();
        insert c;
        Test.stopTest();
        
    }
    
    
    static testmethod void testOne(){
        RecordType RecType= [SELECT ID, Name from RecordType WHERE NAme= 'NPS Cases' LIMIT 1];
        string email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        
        Id recTypeId = [Select Id From RecordType Where SObjectType ='Account' Limit 1][0].Id;

        Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
        User u = new User(LastName = 'Test', Badge_Number__c = 'BADGE101', isActive = true, email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
        insert u;
        System.assert(u != null);
        
        //This asserts that prior to adding the account, there are no accountteammembers
        list<AccountTeamMember> atms = [Select Id From AccountTeamMember limit 1];
         //system.assertEquals(0, atms.size());
        
        Account acc = new account(name='test',Type='Partner', BillingCountry = 'United Kingdom', OwnerId = u.Id, RecordTypeId = recTypeId);
        TriggerExecutionController.setSkipAccountTriggers(true);
        insert acc;
        TriggerExecutionController.setSkipAccountTriggers(false);
        
        Contact con = new Contact(AccountId = acc.Id, Email = email, Lastname = 'UT');
        TriggerExecutionController.setSkipAccountTriggers(true);
        insert con;
        TriggerExecutionController.setSkipAccountTriggers(false);
        //Test.stopTest();
        Contact cnct = [SELECT ID,AccountID,Name from Contact WHERE Id=:con.Id];
        
         //Shows that after your trigger fires, there is now a team member in the system
         atms = [Select Id From AccountTeamMember limit 1];
        // system.assertEquals(1, atms.size());
        
        //AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Sales Manager',AccountId = acc.Id,UserId = u.id);
        //insert atbr;

         //Asserts that the team member that was added was your test user, on your test account, and the role that is specified in your trigger
         //AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :acc.Id And userId = :u.Id];
        
        //system.assertEquals(atm.TeamMemberRole, 'Sales Manager');

        NSS_Category__c n = new NSS_Category__c ();
        n.Name ='SERVICES';
        insert n;
        
        
        List<NSS_Category__c> lnss = [SELECT ID, NAme from NSS_Category__c WHERE id =:n.id];
        NSS_Category__c nss = new NSS_Category__c();
        if(lnss!= null)
            nss = lnss[0];
            //system.debug('aaaaa'+nss);
        
        Cross_Functional_Matrix__c CFMXobj = new Cross_Functional_Matrix__c ();
        if([SELECT Count() from Cross_Functional_Matrix__c LIMIT 1] > 0)
            CFMXobj = [SELECT country__c ,NSS_Category__r.Name, Sub_Segment__c ,Segment__c ,Owner__c,OwnerId,Functional_Call_to_Action__c  from Cross_Functional_Matrix__c LIMIT 1];
        
        
        Case c = new Case();
        c.RecordTypeId = RecType.Id;
        c.NPS_Category__c ='Detractor';
        c.Status = 'Not Started';
        c.Priority = 'High';
        c.Account_Affinity_id__c = acc.Account_ID__c;
     //   c.ContactId = cnct.Id;
        c.Country__c = 'CHINA';
        c.Segment__c = 'PAD';
        c.Sub_Segment__c = '';
        c.Subject ='Detractor';
        c.Client_solution__c = '1';
        c.Online__c ='5';
        c.Tech_support__c='2';
        c.Enterprise_Solution__c = '2';
        c.S_P__c = '9';
        c.software__c='3';
        c.Order_Support__c = '7';
        c.Services__c ='1';
        c.Owner_ID__c = u.Badge_Number__c;
        c.Description = 'd';
        
        c.Marketing_Support__c = '1';
        c.Training_Certification__c = '1';
        c.Program_Management__c = '1';
        c.Solution_ROI__c = '1';
        c.Customization_Services__c = '1';
        c.AccountId = acc.id;
      //  c.AccountId = acc.Id;
        Test.startTest();
        insert c;
        Test.stopTest();
        
    }
}