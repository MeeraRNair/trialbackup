@isTest(seeAllData = true)
public class CreateTaskManually_CntrlTest{
     static testMethod void testGetInfoMethods () {
         RecordType RecType= [SELECT ID, Name from RecordType WHERE NAme= 'NPS Cases' LIMIT 1];
          // Fenny commented [1-Aug-2014]: returned account in MOCK sandbox does not have any contact, thus System.QueryException: List has no rows for assignment to SObject happened during mock validation
         //Account acc = [Select Id,Account_ID__c from Account WHERE Account_ID__c != null Limit 1];
    //Contact cnct = [SELECT ID,AccountID,Name from Contact WHERE AccountID =: acc.Id AND Phone != null LIMIT 1];
    
    // Fenny added [1-Aug-2014]: To create test data instead
    Test.startTest();
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    
    Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
         User usr = new User(LastName = 'Test', Badge_Number__c = 'BADGE101',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
         insert usr;
         
    AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Sales Manager',AccountId = acc.Id,UserId = usr.id);
        insert atbr;
    
    string email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
    Contact con = new Contact(AccountId = acc.Id, Email = email, Lastname = 'UT');
    insert con;
    Test.stopTest();
    Contact cnct = [SELECT ID,AccountID,Name from Contact WHERE Id=:con.Id];
    
    NSS_Category__c n = new NSS_Category__c ();
    n.Name ='SERVICES';
    insert n;
         List<NSS_Category__c> lnss = [SELECT ID, NAme from NSS_Category__c WHERE id =:n.id];
         NSS_Category__c nss = new NSS_Category__c();
         if(lnss!= null)
             nss = lnss[0];
         system.debug('aaaaa'+nss);
         Cross_Functional_Matrix__c CFMXobj = new Cross_Functional_Matrix__c ();
         if([SELECT Count() from Cross_Functional_Matrix__c LIMIT 1] > 0)
             CFMXobj = [SELECT country__c ,NSS_Category__r.Name, Sub_Segment__c ,Segment__c ,Owner__c,OwnerId,Functional_Call_to_Action__c  from Cross_Functional_Matrix__c LIMIT 1];
        Case c1 = new Case();
        c1.RecordTypeId = RecType.Id;
        c1.NPS_Category__c ='Detractor';
        c1.Status = 'Not Started';
        c1.Priority = 'High';
        c1.Account_Affinity_id__c = acc.Account_ID__c  ;
        c1.ContactId = cnct.Id;
        c1.Country__c = 'Australia';
        c1.Segment__c = 'SB';
        c1.Sub_Segment__c = '';
        c1.Subject ='Passive';
        c1.Client_solution__c = '1';
        c1.Online__c ='5';
        c1.Tech_support__c='2';
        c1.Enterprise_Solution__c = '2';
        c1.S_P__c = '9';
        c1.software__c='3';
        c1.Order_Support__c = '7';
        c1.Services__c ='1';
        c1.Owner_ID__c = '609561';
        c1.Description = 'd';
        insert c1;
        Case c = new Case();
        if([SELECT count() from Case Where RecordType.Name = 'NPS Cases' AND Country__c != 'Unknown' AND Segment__c != 'Unknown' AND Sub_segment__c != 'Unknown' LIMIT 1] >0)
            c = [SELECT Id,Country__c,Segment__c,sub_Segment__c from Case Where RecordType.Name = 'NPS Cases' AND Country__c != 'Unknown' AND Segment__c != 'Unknown' AND Sub_segment__c != 'Unknown' LIMIT 1];         
         else
             c = [SELECT Id,Country__c,Segment__c,sub_Segment__c from Case Where Id=: c1.Id];
         ApexPages.currentPage().getParameters().put('Caseid',c.Id);
         CreateTaskManually_Cntrl obj = new CreateTaskManually_Cntrl ();
         obj.NSSlookup.NSS_Category__c = n.Id;
         Boolean b = obj.CheckCategory();
         PageReference  p = obj.Save();
         p = obj.Cancel();
         c.Country__c = 'INDIA';
         p = obj.Save();         
         //Test for Edit NPS Task
         User u  = [SELECT ID, Name from User WHERE IsActive = true LIMIT 1];         
         Recordtype taskRec = [Select Id from RecordType Where Name ='NPS Task' ];
         Task t1 = new Task();
         t1.OwnerId=u.Id;
         t1.subject ='Detractor'; 
         t1.whatid=c.id; 
         t1.RecordTypeId= taskRec.Id;
         insert t1;
         
         //Task t = [SELECT ID FROM Task WHERE RecordType.Name = 'NPS Task' LIMIT 1];
         ApexPages.StandardController sc = new ApexPages.standardController(t1);
         EditNPSTaskCntrl ob = new EditNPSTaskCntrl(sc);
         p = ob.Save();
         p = ob.cancel();
         ApexPages.StandardController sc1 = new ApexPages.standardController(c);
         CreateTaskManually_Cntrl obj1 = new CreateTaskManually_Cntrl (sc1);
         obj1.NSSlookup.NSS_Category__c = nss.Id;
         Id i = obj1.getC();
         p = obj1.CheckTask();
         ApexPages.currentPage().getParameters().put('inline','1');
         p = obj1.RedirectUrl();
         
     }
}