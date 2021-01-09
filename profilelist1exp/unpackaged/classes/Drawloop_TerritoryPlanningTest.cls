@IsTest
public class Drawloop_TerritoryPlanningTest {
    private static testMethod void testDrawloop_TerritoryPlanning() {
        User u = createTestData();
        
        Test.startTest();
        
        Drawloop_TerritoryPlanning territoryPlanning = new Drawloop_TerritoryPlanning();
        
        Set<string> territoryPlanningObjects = territoryPlanning.getGlobalDescribe();
        system.assertEquals(9, territoryPlanningObjects.size());
        
        List<Loop.ExternalData.DataObject> dataObjects = territoryPlanning.describeObjects(new List<string>(territoryPlanningObjects));
        system.assertEquals(0, territoryPlanning.getChildRelationships('bob').size());
        
        Loop.ExternalData.QueryRequestInfo requestInfo = new Loop.ExternalData.QueryRequestInfo();
        requestInfo.Relationships = new List<Loop.ExternalData.Relationship>();
        
        for (string objName : territoryPlanningObjects) {
            Loop.ExternalData.Relationship relationship = new Loop.ExternalData.Relationship();
            relationship.Name = objName;
            requestInfo.Relationships.add(relationship);
        }
        
        Loop.ExternalData.QueryResultSet qrsEnUs;
        Loop.ExternalData.QueryResultSet qrsDeDe;
        system.runAs(u) {
            qrsEnUs = territoryPlanning.query(requestInfo);
        }
        u.LocaleSidKey = 'de_DE';
        update u;
        system.runAs(u) {
            qrsDeDe = territoryPlanning.query(requestInfo);
        }
        
        Test.stopTest();
        
        for (Loop.ExternalData.QueryResultSet qrs : new List<Loop.ExternalData.QueryResultSet>{ qrsEnUs, qrsDeDe }) {
            system.assertNotEquals(null, qrs);
            system.assertNotEquals(null, qrs.results);
            system.assert(!qrs.results.isEmpty());
            for (Loop.ExternalData.QueryResult qr : qrs.results) {
                system.assertNotEquals(null, qr);
                system.assertNotEquals(null, qr.rows);
                system.assertNotEquals(null, qr.columns);
                if (qr.objectName == Drawloop_TerritoryPlanning.territoryPlanningObjectName) {
                    system.assertEquals(1, qr.rows.size());
                    system.assertEquals(5, qr.rows[0].size());
                    system.assertEquals(5, qr.columns.size());
                    for (integer i = 0; i < qr.columns.size(); i++) {
                        string value = qr.rows[0][i];
                        string field = qr.columns[i];
                        if (field == 'CFYQ') {
                            system.assert(Pattern.compile('FY\\d{4} Q0\\d').matcher(value).matches(), value + ' did not pass regex validation.');
                        }
                        else if (field == 'CFY') {
                            system.assert(Pattern.compile('FY\\d{2}').matcher(value).matches(), value + ' did not pass regex validation.');
                        }
                    }
                }
            }
        }
    }
    
    public static User createTestData() {
        TriggerExecutionController.setSkipAlltriggers(true);
        
        List<Account> accounts = new List<Account>();
        for (integer i = 0; i < 21; i++) {
            accounts.add(new Account(name = 'test1', Focus_Account__c = 'Direct Account Plan'));
        }
        insert accounts;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
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
        
        FiscalYearSettings fy = TP_Utilities.getCurrentFiscalYearSettings();
        
        List<string> currentQuarters = TP_Utilities.getCurrentFYQuarters(fy.EndDate.year());
        List<string> previousQuarters = TP_Utilities.getPreviousQuarters(fy.EndDate.year(), fy.StartDate);
        
        Set<string> allQuarters = new Set<string>(currentQuarters);
        allQuarters.addAll(previousQuarters);
        
        List<Revenue__c> revenueRecords = new List<Revenue__c>();
        for (Account a : accounts) {
            for (string quarter : allQuarters) {
                List<string> fyParts = quarter.split('Q');
                Revenue__c r = new Revenue__c(
                    Account__c = a.Id,
                    Fiscal_Year__c = fyParts[0],
                    Fiscal_Quarter__c = 'Q' + fyParts[1],
                    Total_QTR_Rev__c = 9,
                    Total_QTR_Margin__c = 8,
                    Desktop_QTR_Rev__c = 7,
                    Notebook_QTR_Rev__c = 6,
                    Server_QTR_Rev__c = 5,
                    Storage_QTR_Rev__c = 4,
                    Networking_QTR_Rev__c = 3,
                    Partner_QTR_Rev__c = 2,
                    Direct_QTR_Rev__c = 1
                );
                revenueRecords.addAll(new List<Revenue__c>{ r, r.clone() });
            }
        }
        insert revenueRecords;
        
        accounts.remove(0);
        string fiscalYear = 'FY' + string.valueOf(fy.EndDate.year()).substring(2);
        List<SFDC_Acct_Plan__c> focusPlans = new List<SFDC_Acct_Plan__c>();
        for (Account a : accounts) {
            focusPlans.add(new SFDC_Acct_Plan__c(Account__c = a.Id, Plan_Starting_Fiscal_Year__c = fiscalYear));
        }
        insert focusPlans;
        
        return users[0];
    }
}