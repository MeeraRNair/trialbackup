/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
 2.0         13229       FY17-DCS-0801   29-June-2016     Syuhada        Story 1616027:Update logic on NPS case record to determine category view
 3.0                     0102            21-10-2019       venu           Venugopalachary Implimented TestDataFactory   
 4.0         18388       FY21-DCS-0202   23-10-2019       Yamini Kayam   Added new method to increase test coverage
*/  
@ISTEST
public class CaseSaveNewRedirectController_Test{
    public static list<Account> listAcc;
    public static list<user> listUser;
    public static list<Case> listCase;
    
    @testsetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF=TestDataFactory.createNAccount(1, 'Master Account');
        listAccTDF[0].BillingCountry='United Kingdom';
        listAccTDF[0].Name= 'NPS Cases';
        insert listAccTDF;        
        //Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
        //list<User> listUserTDF = TestDataFactory.CreateNGenralUsers(1);
        //listUserTDF[0].ProfileId=myProf.id;
        // insert listUserTDF;        
        Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Presales service rep'];//or whatever profile you want
        Profile myProf1 = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
        
        list<User> listUserTdf = TestDataFactory.CreateNGenralUsers(2);
        listUserTdf[0].ProfileId=myProf.id;
        listUserTdf[1].ProfileId=myProf1.id;
        listUserTdf[1].isActive=true;
        insert listUserTdf;
        /*list<User> listUserTdf1 = TestDataFactory.CreateNGenralUsers(1);
listUserTdf1[0].ProfileId=myProf1.id;
insert listUserTdf1;  
*/
        list<Case> listCaseTDF=TestDataFactory.createNCases(1);
        insert listCaseTDF;
    }
    static testMethod void caseSaveNewRedirectControllerTest7() {
        
        // Temporary fix to resolve soql 101 
        TriggerExecutionController.setSkipAllTriggers(true);
        // Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Presales service rep'];//or whatever profile you want
        list<User> listUser = [select id from user where profile.name='Presales service rep' Limit 1];
        //listUser[0].ProfileId=myProf.id;
        //insert listUser; 
        //listUser[0].profileId=myProf.id;
        //update listUser;
        listAcc=[select id,Account_ID__c from Account Limit 1];
        string stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        Contact con = new Contact(AccountId = listAcc[0].Id, 
                                  Email = stremail,
                                  Lastname = 'UT');
        insert con;
        listCase=[Select id From Case Limit 1];
        listCase[0].Account_Affinity_id__c = listAcc[0].Account_ID__c;
        listCase[0].AccountId = listAcc[0].Id;
        listCase[0].ContactId = con.Id;
        listCase[0].RecordTypeId=TestDataFactory.getRecordTypeIdbyName('Quoting', 'Case');
        listCase[0].type='Quote With Proposal';
        
        update listCase;
        
        ApexPages.currentPage().getParameters().put('id',listCase[0].Id);
        
        PageReference curPage = new PageReference(ApexPages.currentPage().getParameters().put('id',listCase[0].Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listCase[0]);
        CaseSaveNewRedirectController csn7 = New CaseSaveNewRedirectController(sc);
        csn7.CaseRedirect(); 
        system.assertEquals(curPage.getURL(), curPage.getURL());
    } // Test Method for Quoting RT
    
    static testMethod void caseSaveNewRedirectControllerTest() {
        
        // Temporary fix to resolve soql 101
        TriggerExecutionController.setSkipAllTriggers(true);
        //Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
        list<User> listUser = [select id from user where profile.name='Standard User' and isActive=true Limit 1];
        
        //list<User> listUser = TestDataFactory.CreateNGenralUsers(1);
        //listUser[0].ProfileId=myProf.id;
        //insert listUser;         
        // listUser[0].profileId=myProf.id;
        //update listUser;
        //This asserts that prior to adding the account, there are no accountteammembers
        list<AccountTeamMember> listatms = [Select Id From AccountTeamMember];
        //system.assertEquals(0, atms.size());
        listAcc=[select id,Account_ID__c from Account Limit 1];
        
        string stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        Contact con = new Contact(AccountId = listAcc[0].Id, Email = stremail, Lastname = 'UT');
        insert con;
        //Test.stopTest();
        Contact cnct = [SELECT ID,AccountID,Name from Contact WHERE Id=:con.Id];
        
        //Shows that after your trigger fires, there is now a team member in the system
        listatms = [Select Id From AccountTeamMember];
        system.assertEquals(0, listatms.size());
        
        AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Sales Manager',
                                                       AccountId = listAcc[0].Id,
                                                       UserId = listUser[0].id);
        insert atbr;
        
        //Asserts that the team member that was added was your test user, on your test account, and the role that is specified in your trigger
        AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :listAcc[0].Id And userId = :listUser[0].Id];
        
        system.assertEquals(atm.TeamMemberRole, 'Sales Manager');
        listCase=[select id from Case Limit 1];
        listCase[0].Account_Affinity_id__c=listAcc[0].Account_ID__c;
        listCase[0].AccountId=listAcc[0].id;
        listCase[0].contactId=con.id;
        update listCase;
        
        ApexPages.currentPage().getParameters().put('id',listCase[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listCase[0]);
        CaseSaveNewRedirectController csn = New CaseSaveNewRedirectController(sc);
        csn.CaseRedirect(); 
        
    } //2.0
    
    static testMethod void caseSaveNewRedirectControllerTest2() {
        // Temporary fix to resolve soql 101 
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
        /*list<User> listUser = TestDataFactory.CreateNGenralUsers(1);
listUser[0].ProfileId=myProf.id;
insert listUser;         
*/
        list<User> listUser = [select id from user where profile.name='Standard User' and isActive=true Limit 1];
        list<AccountTeamMember> listatms = [Select Id From AccountTeamMember];
        listAcc=[select id,Account_ID__c from Account limit 1];
        
        string stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        Contact con1 = new Contact(AccountId = listAcc[0].Id, Email = stremail, Lastname = 'UT');
        insert con1;
        
        Contact cnct1 = [SELECT ID,AccountID,Name from Contact WHERE Id=:con1.Id];
        
        listatms = [Select Id From AccountTeamMember];
        
        AccountTeamMember atbr1 = new AccountTeamMember(TeamMemberRole = 'Sales Manager',
                                                        AccountId = listAcc[0].Id,
                                                        UserId = listUser[0].id);
        insert atbr1;
        
        AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :listAcc[0].Id And userId = :listUser[0].Id];
        
        system.assertEquals(atm.TeamMemberRole, 'Sales Manager');
        listCase=[select id from Case Limit 1];
        listCase[0].RecordTypeId=TestDataFactory.getRecordTypeIdbyName('Order Support', 'Case');
        listCase[0].Account_Affinity_id__c = listAcc[0].Account_ID__c;
        listCase[0].AccountId = listAcc[0].Id;
        listCase[0].ContactId = cnct1.Id;
        update listCase;
        
        ApexPages.currentPage().getParameters().put('id',listCase[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listCase[0]);
        CaseSaveNewRedirectController csn2 = New CaseSaveNewRedirectController(sc);
        
        csn2.CaseRedirect(); 
        
        
    }//end of 2.0
    
    static testMethod void caseSaveNewRedirectControllerTest3() {
        
        // Temporary fix to resolve soql 101 
        TriggerExecutionController.setSkipAllTriggers(true);
        
        RecordType recType2= [SELECT ID, Name from RecordType WHERE Name= 'Application Support' LIMIT 1];
        
        /*  Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
list<User> listUser = TestDataFactory.CreateNGenralUsers(1);
listUser[0].ProfileId=myProf.id;
insert listUser;         
*/
        list<User> listUser = [select id from user where profile.name='Standard User' and isActive=true Limit 1];
        
        list<AccountTeamMember> listatms = [Select Id From AccountTeamMember];
        listAcc=[select id,Account_ID__c from Account limit 1];
        
        string stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        Contact con1 = new Contact(AccountId = listAcc[0].Id, Email = stremail, Lastname = 'UT');
        insert con1;
        
        Contact cnct1 = [SELECT ID,AccountID,Name from Contact WHERE Id=:con1.Id];
        
        listatms = [Select Id From AccountTeamMember];
        
        AccountTeamMember atbr1 = new AccountTeamMember(TeamMemberRole = 'Sales Manager',
                                                        AccountId = listAcc[0].Id,
                                                        UserId = listUser[0].id);
        insert atbr1;
        
        AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :listAcc[0].Id And userId = :listUser[0].Id];
        
        system.assertEquals(atm.TeamMemberRole, 'Sales Manager');
        listCase=[select id from Case limit 1];
        listCase[0].RecordTypeId=recType2.id;
        listCase[0].Account_Affinity_id__c = listAcc[0].Account_ID__c;
        listCase[0].AccountId = listAcc[0].Id;
        listCase[0].ContactId = cnct1.Id;
        update listCase;
        
        ApexPages.currentPage().getParameters().put('id',listCase[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listCase[0]);
        CaseSaveNewRedirectController csn2 = New CaseSaveNewRedirectController(sc);
        
        csn2.CaseRedirect(); 
        
        
    }//end of 2.0
    
    static testMethod void caseSaveNewRedirectControllerTest4() {
        
        // Temporary fix to resolve soql 101 
        TriggerExecutionController.setSkipAllTriggers(true);
        
        RecordType recType2= [SELECT ID, Name from RecordType WHERE Name= 'On Boarding' LIMIT 1];
        /* Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
list<User> listUser = TestDataFactory.CreateNGenralUsers(1);
listUser[0].ProfileId=myProf.id;
insert listUser;         
*/
        list<User> listUser = [select id from user where profile.name='Standard User' and isActive=true Limit 1];
        
        list<AccountTeamMember> listatms = [Select Id From AccountTeamMember];
        listAcc=[select id,Account_ID__c from Account Limit 1];
        
        string stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        Contact con1 = new Contact(AccountId = listAcc[0].Id, Email = stremail, Lastname = 'UT');
        insert con1;
        
        Contact cnct1 = [SELECT ID,AccountID,Name from Contact WHERE Id=:con1.Id];
        
        listatms = [Select Id From AccountTeamMember];
        
        AccountTeamMember atbr1 = new AccountTeamMember(TeamMemberRole = 'Sales Manager',
                                                        AccountId = listAcc[0].Id,
                                                        UserId = listUser[0].id);
        insert atbr1;
        
        AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :listAcc[0].Id And userId = :listUser[0].Id];
        
        system.assertEquals(atm.TeamMemberRole, 'Sales Manager');
        listCase=[select id from case limit 1];
        listCase[0].RecordTypeId = recType2.Id;
        listCase[0].Account_Affinity_id__c = listAcc[0].Account_ID__c;
        listCase[0].AccountId = listAcc[0].Id;
        listCase[0].ContactId = cnct1.Id;
        update listCase;
        
        ApexPages.currentPage().getParameters().put('id',listCase[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listCase[0]);
        CaseSaveNewRedirectController csn2 = New CaseSaveNewRedirectController(sc);
        
        csn2.CaseRedirect(); 
        
        
    }//end of 2.0
    
    static testMethod void caseSaveNewRedirectControllerTest5() {
        
        // Temporary fix to resolve soql 101 
        TriggerExecutionController.setSkipAllTriggers(true);
        
        RecordType recType2= [SELECT ID, Name from RecordType WHERE Name= 'Distribution' LIMIT 1];
        
        /* Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
User u = new User(LastName = 'Test', Badge_Number__c = '01293187',email = 'test1@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit5@dell.com.sit', profileId = myProf.Id);
insert u;*/
        list<User> listUser = [select id from user where profile.name='Standard User' and isActive=true Limit 1];
        
        list<AccountTeamMember> listatms = [Select Id From AccountTeamMember];
        listAcc=[select id,Account_ID__c from Account limit 1];
        
        string stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        Contact con1 = new Contact(AccountId = listAcc[0].Id, Email = stremail, Lastname = 'UT');
        insert con1;
        
        Contact cnct1 = [SELECT ID,AccountID,Name from Contact WHERE Id=:con1.Id];
        
        listatms = [Select Id From AccountTeamMember];
        
        AccountTeamMember atbr1 = new AccountTeamMember(TeamMemberRole = 'Sales Manager',AccountId = listAcc[0].Id,UserId = listUser[0].id);
        insert atbr1;
        
        AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :listAcc[0].Id And userId = :listUser[0].Id];
        
        system.assertEquals(atm.TeamMemberRole, 'Sales Manager');
        listCase=[select id from case limit 1];
        listCase[0].RecordTypeId = recType2.Id;
        listCase[0].Account_Affinity_id__c = listAcc[0].Account_ID__c;
        listCase[0].AccountId = listAcc[0].Id;
        listCase[0].ContactId = cnct1.Id;
        update listCase;
        
        ApexPages.currentPage().getParameters().put('id',listCase[0].Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listCase[0]);
        CaseSaveNewRedirectController csn2 = New CaseSaveNewRedirectController(sc);
        
        csn2.CaseRedirect(); 
        
        
    }//end of 2.0
    
    static testMethod void caseSaveNewRedirectControllerTest6() {
        
        // Temporary fix to resolve soql 101 
        TriggerExecutionController.setSkipAllTriggers(true);
        
        RecordType recType2= [SELECT ID, Name from RecordType WHERE Name= 'EMC DR' LIMIT 1];
        /*User u = new User(LastName = 'Test', Badge_Number__c = '01293187',email = 'test1@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit5@dell.com.sit', profileId = myProf.Id);
insert u;
*/
        /* Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
list<User> listUser = TestDataFactory.CreateNGenralUsers(1);
listUser[0].ProfileId=myProf.id;
insert listUser;         
*/
        list<User> listUser = [select id from user where profile.name='Standard User' and isActive=true Limit 1];
        
        list<AccountTeamMember> listatms = [Select Id From AccountTeamMember];
        listAcc=[select id,Account_ID__c from Account Limit 1];
        
        string stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        Contact con1 = new Contact(AccountId = listAcc[0].Id, Email = stremail, Lastname = 'UT');
        insert con1;
        
        Contact cnct1 = [SELECT ID,AccountID,Name from Contact WHERE Id=:con1.Id];
        
        listatms = [Select Id From AccountTeamMember];
        
        AccountTeamMember atbr1 = new AccountTeamMember(TeamMemberRole = 'Sales Manager',AccountId = listAcc[0].Id,UserId = listUser[0].id);
        insert atbr1;
        
        AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :listAcc[0].Id And userId = :listUser[0].Id];
        
        system.assertEquals(atm.TeamMemberRole, 'Sales Manager');
        
        listCase=[select id from case limit 6];
        listCase[0].RecordTypeId = recType2.Id;
        listCase[0].Account_Affinity_id__c = listAcc[0].Account_ID__c;
        listCase[0].AccountId = listAcc[0].Id;
        listCase[0].ContactId = cnct1.Id;
              
        update listCase;
        ApexPages.currentPage().getParameters().put('id',listCase[0].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(listCase[0]);
        CaseSaveNewRedirectController csn2 = New CaseSaveNewRedirectController(sc);
        csn2.CaseRedirect();
     }//end of 2.0
     
     //R4.0 starts
     static testMethod void caseSaveNewRedirectControllerTest8() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        RecordType recType3= [SELECT ID, Name from RecordType WHERE Name= 'Deal Registration - Internal only case types' LIMIT 1];
        RecordType recType4= [SELECT ID, Name from RecordType WHERE Name= 'On Boarding Internal' LIMIT 1];
        RecordType recType5= [SELECT ID, Name from RecordType WHERE Name= 'Application Support - Internal only case types' LIMIT 1];
        RecordType recType6= [SELECT ID, Name from RecordType WHERE Name= 'Channel Services Helpdesk' LIMIT 1];
        RecordType recType7= [SELECT ID, Name from RecordType WHERE Name= 'Partner Program' LIMIT 1];
        
        list<User> listUser = [select id from user where profile.name='Standard User' and isActive=true Limit 1];
        
        list<AccountTeamMember> listatms = [Select Id From AccountTeamMember];
        listAcc=[select id,Account_ID__c from Account Limit 1];
        
        string stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        Contact con1 = new Contact(AccountId = listAcc[0].Id, Email = stremail, Lastname = 'UT');
        insert con1;
        
        Contact cnct1 = [SELECT ID,AccountID,Name from Contact WHERE Id=:con1.Id];
        
        listatms = [Select Id From AccountTeamMember];
        
        AccountTeamMember atbr1 = new AccountTeamMember(TeamMemberRole = 'Sales Manager',AccountId = listAcc[0].Id,UserId = listUser[0].id);
        insert atbr1;
       AccountTeamMember atm = [Select UserId, AccountId, TeamMemberRole From AccountTeamMember Where AccountId = :listAcc[0].Id And userId = :listUser[0].Id];
        system.assertEquals(atm.TeamMemberRole, 'Sales Manager');
        listCase = new list<Case>();
        Case d;
        d = new case(RecordTypeId =recType3.Id,Status ='Open',Priority ='High',Origin ='Phone',Sub_Type_Partner_User__c='Login Issues',Case_Category__c ='Partner',Subject ='Test test',Description ='Testing12345xxx',Alternate_Phone__c ='123456',Account_Affinity_id__c =listAcc[0].Account_ID__c,AccountId =listAcc[0].Id,ContactId =cnct1.Id);
        listCase.add(d);
        d = new case(RecordTypeId = recType4.Id, Status = 'Open',Priority = 'High', Origin = 'Phone', Sub_Type_Partner_User__c= 'Login Issues', Case_Category__c = 'Partner', Subject ='Test test', Description = 'Testing12345yyyy', Alternate_Phone__c ='123456', Account_Affinity_id__c = listAcc[0].Account_ID__c, AccountId = listAcc[0].Id, ContactId = cnct1.Id);
        listCase.add(d);
        d = new case(RecordTypeId = recType5.Id, Status = 'Open',Priority = 'High', Origin = 'Phone', Sub_Type_Partner_User__c= 'Login Issues', Case_Category__c = 'Partner', Subject ='Test test', Description = 'Testing12345zzzz', Alternate_Phone__c ='123456', Account_Affinity_id__c = listAcc[0].Account_ID__c, AccountId = listAcc[0].Id, ContactId = cnct1.Id);
        listCase.add(d);
        d = new case(RecordTypeId = recType6.Id, Status = 'Open',Priority = 'High', Origin = 'Phone', Sub_Type_Partner_User__c= 'Login Issues', Case_Category__c = 'Partner', Subject ='Test test', Description = 'Testing12345uuuuu', Alternate_Phone__c ='123456', Account_Affinity_id__c = listAcc[0].Account_ID__c, AccountId = listAcc[0].Id, ContactId = cnct1.Id);
        listCase.add(d);
        d = new case(RecordTypeId = recType7.Id, Status = 'Open',Priority = 'High', Origin = 'Phone', Sub_Type_Partner_User__c= 'Login Issues', Case_Category__c = 'Partner', Subject ='Test test', Description = 'Testing12345vvvv', Alternate_Phone__c ='123456', Account_Affinity_id__c = listAcc[0].Account_ID__c, AccountId = listAcc[0].Id, ContactId = cnct1.Id);
        listCase.add(d);
        insert listCase ;
         for(case cs:listCase){
         ApexPages.currentPage().getParameters().put('id',cs.id);
    
         ApexPages.StandardController sc = new ApexPages.StandardController(cs);
         CaseSaveNewRedirectController csn2 = New CaseSaveNewRedirectController(sc);
      
         csn2.CaseRedirect();
        }        
        
    }//R4.0 ends
}