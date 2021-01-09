@isTest
public class populatecaseFeed_Test{


       public static testmethod void testcase1() {
         TriggerExecutionController.setSkipAllTriggers(true);
         
         Id recTypeId = [Select Id From RecordType Where SObjectType ='Account' Limit 1][0].Id;
         RecordType RecType= [SELECT ID, Name from RecordType WHERE Name= 'NPS Cases' LIMIT 1];
         
         Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
         User u = new User(LastName = 'Test', Badge_Number__c = '01293107',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
         insert u;
        
         //This asserts that prior to adding the account, there are no accountteammembers
         list<AccountTeamMember> atms = [Select Id From AccountTeamMember];
         //system.assertEquals(0, atms.size());
        
         Account acc = new account(name='test', BillingCountry = 'United Kingdom', OwnerId = u.Id, RecordTypeId = recTypeId);
         insert acc;
         
         string email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
         Contact con = new Contact(AccountId = acc.Id, Email = email, Lastname = 'UT');
         insert con;
         //Test.stopTest();
         Contact cnct = [SELECT ID,AccountID,Name from Contact WHERE Id=:con.Id];
        
         //Shows that after your trigger fires, there is now a team member in the system
         atms = [Select Id From AccountTeamMember];
         //system.assertEquals(1, atms.size());
        
         AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Sales Manager',AccountId = acc.Id,UserId = u.id);
         insert atbr;

         //Asserts that the team member that was added was your test user, on your test account, and the role that is specified in your trigger
         AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :acc.Id And userId = :u.Id];
        
         system.assertEquals(atm.TeamMemberRole, 'Sales Manager');
                
         // CaseTeamMember csmbr1 = new CaseTeamMember(ParentId = acc.Id,MemberId = atm.UserId);
         // insert csmbr1; 
    
        Case c = new Case();
        //c.RecordTypeId = RecType.Id;
        c.RecordTypeId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration');
        c.NPS_Category__c ='Detractor';
        c.Status = 'OPen';
        //sazleen added
        //c.Due_Date__c = '2016-06-30';
        c.Origin = 'NPS Survey Response'; 
        //sazleen added end
        c.Priority = 'High';
        c.Account_Affinity_id__c = acc.Account_ID__c;
        c.Account_Tier__c = 'TestAccount1234';
        c.NPS__c = 1234578;
        c.ContactId = cnct.Id;
        c.Country__c = 'Unknown';
        c.Segment__c = 'Channel';
        c.Sub_Segment__c = 'Unknown';
        c.Subject ='Detractor';

        //Start 2.0
        c.Account_Relationship__c ='1'; 
        c.Client_solution__c = '1'; //old
        c.Online__c ='5'; //old
        c.Enterprise_Solution__c = '2'; //old
        c.Order_Support__c = '7'; //old
        c.S_P__c = '9';   //old
        c.Services__c ='1';  //old
        c.Tech_support__c='2';  //old
        c.software__c='3'; //old
        c.Marketing_Support__c='1';
        c.Training_Certification__c='1';
        c.Program_Management__c='2'; 
        c.Solution_ROI__c='1';   
        c.Customization_Services__c ='2'; 
        
        c.Account_Relationship_Comment__c ='Test1';
        c.Client_Solution_Comment__c ='Test1';
        c.Online_Comment__c ='Test1';
        c.Enterprise_Solution_Comment__c ='Test1';
        c.Order_Support_Comment__c ='Test1';
        c.S_P_Comment__c ='Test1';
        c.Services_Comment__c ='Test1';
        c.Tech_Support_Comment__c ='Test1';
        c.Software_Comment__c ='Test1';
        c.Marketing_Support_Comment__c ='Test1';
        c.Training_Certification_Comment__c ='Test1';
        c.Program_Management_Comment__c ='Test1';
        c.Solution_ROI_Comment__c ='Test1';
        c.Customization_Services_Comment__c ='Test1';
        //end of 2.0
        
        c.Owner_ID__c = '069561';
        c.Description = 'Testing123';
        c.AccountId = acc.Id;
        
        insert c;
            String filecontent='This is a test attachment'; 
            Attachment a =new Attachment(name = 'Testa att', parentId = c.Id, body = Blob.valueOf(filecontent));
           // aList.add(a);
            //aList.add(b);
            //aList.add(c);
           TriggerExecutionController.setSkipAllTriggers(false);
       
            insert a;
        
     
    
    }
}