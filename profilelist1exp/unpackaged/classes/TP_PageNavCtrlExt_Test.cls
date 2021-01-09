@isTest
public class TP_PageNavCtrlExt_Test {
    
	public static testmethod void testcase1(){
        User u = createTestUser();
        Test.startTest();
        Territory_Plan__c tp_Obj = new Territory_Plan__c(
            name = 'test 101011 planning');
		
        system.runAs(u) {
            string vfPag = TP_PageNavUtils.vfPageNames[0];
            PageReference pageRef = new pageReference('/apex/'+vfPag);//Page.TP_OnYourTeam;
            Test.setCurrentPage(pageRef);
			apexPages.currentPage().getParameters().put('sample', 'false');
            TP_PageNavCtrlExt pagNav = new TP_PageNavCtrlExt(new ApexPages.StandardController(tp_Obj));
            pagNav.goToNextPage();
            insert tp_Obj;
            
            apexPages.currentPage().getParameters().put('id', tp_Obj.id);
            TP_PageNavCtrlExt pagNav1 = new TP_PageNavCtrlExt(new ApexPages.StandardController(tp_Obj));
            pagNav1.saveRecord();
            
            apexPages.currentPage().getParameters().put('id', tp_Obj.id);
            string vfPagLast = TP_PageNavUtils.vfPageNames[TP_PageNavUtils.vfPageNames.size()-1];
            PageReference pageRef2 = new pageReference('/apex/'+vfPagLast);
            Test.setCurrentPage(pageRef2);
            apexPages.currentPage().getParameters().put('id', tp_Obj.Id);
            TP_PageNavCtrlExt pagNav2 = new TP_PageNavCtrlExt(new ApexPages.StandardController(tp_Obj));
            pagNav2.goToNextPage();
            pagNav2.goToPrevPage();
            
            pagNav2.doCancel();
        }
        Test.stopTest();
    } 
    
    private static User createTestUser() {
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
		return testUser;
    } 
}