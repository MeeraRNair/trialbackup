@isTest
public class TP_NewContinuePrintCtrlExt_Test {
    
    public static testmethod void testcase1(){
        User u1 = createTestData();
        Test.startTest();
        Territory_Plan__c territory_plan_Obj = new Territory_Plan__c();
        User u2 = Drawloop_TerritoryPlanningTest.createTestData();
        //PageReference pageRef = Page.TP_NewAndContinue;
         //   Test.setCurrentPage(pageRef);
        system.runAs(u2) {
            TP_NewContinuePrintCtrlExt newAndCont = new TP_NewContinuePrintCtrlExt(new ApexPages.StandardController(territory_plan_Obj));
            newAndCont.redirectToPage();
            
        }
        
        system.runAs(u1) {
            
            TP_NewContinuePrintCtrlExt newAndCont = new TP_NewContinuePrintCtrlExt(new ApexPages.StandardController(territory_plan_Obj));
            newAndCont.redirectToPage();
            Account acc = new Account(name = 'test1', Focus_Account__c = 'Direct Account Plan');
            insert acc;
        
            AccountTeamMember teamMembers = new AccountTeamMember(
                    AccountId = acc.Id,
                    UserId = u1.Id,
                    TeamMemberRole = 'Account Executive'
                );
            insert teamMembers;
            territory_plan_Obj.name ='test1';
            insert territory_plan_Obj;
        }
        
        system.runas(u2){
            
            apexPages.currentPage().getParameters().put('id', territory_plan_Obj.id);
            TP_NewContinuePrintCtrlExt newAndCont1 = new TP_NewContinuePrintCtrlExt(new ApexPages.StandardController(territory_plan_Obj));
            
        }
        Test.stopTest();
    }
    
    public static testmethod void testcase2(){
        User u1 = Drawloop_TerritoryPlanningTest.createTestData();
        Test.startTest();
        system.runAs(u1) {
            Territory_Plan__c territory_plan_Obj = new Territory_Plan__c(name = 'test1', continue_to_page__c = 'TP_Ob3Goals');
            insert territory_plan_Obj;
            TP_NewContinuePrintCtrlExt newAndCont = new TP_NewContinuePrintCtrlExt(new ApexPages.StandardController(territory_plan_Obj));
           // PageReference pageRef = Page.TP_NewAndContinue;
           // Test.setCurrentPage(pageRef);
            newAndCont.redirectToPage();
            
            apexPages.currentPage().getParameters().put('id', territory_plan_Obj.id);
            TP_NewContinuePrintCtrlExt newAndCont1 = new TP_NewContinuePrintCtrlExt(new ApexPages.StandardController(territory_plan_Obj));
            newAndCont1.redirectToPage();
            newAndCont1.redirectPreviousPage();
            
            pageReference pgRef = new pageReference('/apex/TP_PrintRDownloadTP');
            test.setCurrentPage(pgRef);
            
            apexPages.currentPage().getParameters().put('id', territory_plan_Obj.id);
            TP_NewContinuePrintCtrlExt newAndCont2 = new TP_NewContinuePrintCtrlExt(new ApexPages.StandardController(territory_plan_Obj));
            system.debug('------- 2nd-----------');
            newAndCont2.redirectToPage();
        }
        Test.stopTest();
    }
    
    private static User createTestData() {
        TriggerExecutionController.setSkipAlltriggers(true);

        Profile p = [SELECT Id FROM Profile WHERE Name = 'system Administrator' LIMIT 1];
        
        User testUser = new User(
            Alias = 'alias',
            Email = 'test@dell.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Tester ',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'user_Dloop'+System.currentTimeMillis()+'@dell.com',
            Badge_Number__c = 'Test' + System.currentTimeMillis()
        );
        insert testUser;
        TriggerExecutionController.setSkipAlltriggers(false);
        return testUser;
    }
}