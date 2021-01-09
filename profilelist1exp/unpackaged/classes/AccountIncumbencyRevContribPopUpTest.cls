@isTest(seeAllData = false)
private class AccountIncumbencyRevContribPopUpTest {
    @isTest static void testMethod1() {
        Test.startTest();

        TriggerExecutionController.setSkipAllTriggers(True);
        Account testAccount = new Account(Account_ID__c = 'TESTIN-234567', name = 'Test-1', Account_Country_Code__c = 'IN', Account_Country__c = 'INDIA', Rating = 'T2A HIGH BP ACQ', CSG__c = False, Networking__c = false, Server__c = false, Storage__c = false);
        insert testAccount;

        TriggerExecutionController.setSkipAllTriggers(True);
        update new Account(ID = testAccount.ID, CSG_Timestamp__c = NULL, Networking_Timestamp__c = NULL, Server_Timestamp__c = NULL, Storage_Timestamp__c = NULL);
        insert new LOBi_Order_Revenue__c(Affinity_ID__c = 'TESTIN-234567');

        PageReference pageRef = Page.AccountIncumbencyRevContribPopUp;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testAccount);
        ApexPages.currentPage().getParameters().put('id', testAccount.ID);
        ApexPages.currentPage().getParameters().put('incumbencytype', 'Client');
        ApexPages.currentPage().getParameters().put('AffinityID', testAccount.Account_ID__c);

        AccountIncumbencyRevContribPopUp_Ctrl testOpp = new AccountIncumbencyRevContribPopUp_Ctrl(stdCon);
        ApexPages.currentPage().getParameters().put('incumbencytype', 'Networking');
        AccountIncumbencyRevContribPopUp_Ctrl testOpp2 = new AccountIncumbencyRevContribPopUp_Ctrl(stdCon);

        ApexPages.currentPage().getParameters().put('incumbencytype', 'Server');
        AccountIncumbencyRevContribPopUp_Ctrl testOpp3 = new AccountIncumbencyRevContribPopUp_Ctrl(stdCon);

        ApexPages.currentPage().getParameters().put('incumbencytype', 'Storage');
        AccountIncumbencyRevContribPopUp_Ctrl testOpp4 = new AccountIncumbencyRevContribPopUp_Ctrl(stdCon);

        testOpp4.closePopup();

        Test.stopTest();
    }
}