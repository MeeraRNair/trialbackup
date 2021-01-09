@isTest
public class TP_OnYourTeamCtrlExt_Test {
    
    public static testmethod void testcase1(){
        User u = createTestData();
        Test.startTest();
        system.runAs(u) {
            Territory_Plan__c territory_plan_Obj = new Territory_Plan__c();
            TP_OnYourTeamCtrlExt onYourTeam = new TP_OnYourTeamCtrlExt(new ApexPages.StandardController(territory_plan_Obj));
            territory_plan__c tp_Obj = [Select id from territory_plan__c limit 1];
            apexPages.currentPage().getParameters().put('id', tp_Obj.id);
            TP_OnYourTeamCtrlExt onYourTeam1 = new TP_OnYourTeamCtrlExt(new ApexPages.StandardController(territory_plan_Obj));
        }
        Test.stopTest();
    }

    private static User createTestData() {
        TriggerExecutionController.setSkipAlltriggers(true);
        TriggerExecutionController.setSkipAccounttriggers(true);
        List<Account> accounts = new List<Account>();
        for (integer i = 0; i < 21; i++) {
            accounts.add(new Account(name = 'test1', Focus_Account__c = 'Direct Account Plan'));
        }
        insert accounts;
        TriggerExecutionController.setSkipAccounttriggers(false);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'system Administrator' LIMIT 1];
        
        List<string> teamRoles = new List<string>{ 'Account Executive' };
        teamRoles.addAll(Drawloop_TerritoryPlanning.teamRoles);
        
        List<User> users = new List<User>();
        for (integer i = 0; i < teamRoles.size(); i++) {
            users.add(new User(
                Alias = 'alias',
                Email = 'test@dell.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Tester '+i,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = 'user_Dloop'+i+System.currentTimeMillis()+'@dell.com',
                Badge_Number__c = 'Test' + i + System.currentTimeMillis()
            ));
        }
        insert users;
        
        List<AccountTeamMember> teamMembers = new List<AccountTeamMember>();
        for (Account a : accounts) {
            for (integer i = 0; i < teamRoles.size(); i++) {
                teamMembers.add(new AccountTeamMember(
                    AccountId = a.Id,
                    UserId = users[i].Id,
                    TeamMemberRole = teamRoles[i]
                ));
            }
        }
        insert teamMembers;
        
        Territory_plan__c tp = new territory_plan__c(name = 'test user');
        insert tp;
        return users[0];
    }
}