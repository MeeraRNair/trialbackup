/**
 
* Name          : VFCntrlr_NewAccountHandOverTest
* Description   : Test method for New Account handover VF controller 
* ---------------------------------------------------------
* Revision  Name     Date        Description
* 1.0       Krishna  09.01.2010  Creation
* 2.0    VIKAS KH 08-12-2019  Impelmented TDF for 0202

 */
  
@isTest
private class VFCntrlr_NewAccountHandOverTest {
    static list<Account> listAcc;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
    }
    static testMethod void testNewAccountHandoverForFreshAccount() {
       // system.debug('##KP: Start test_NewAccountHandoverForFreshAccount');
        /*    Account testAccount = new Account (Name='testAccount123', NumberOfEmployees = 841019);
    Insert testAccount; */
        listAcc = [select id from Account limit 1];
        listAcc[0].NumberOfEmployees = 841019;
        update listAcc;
        PageReference pageRef = Page.NewAccountHandOver;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', listAcc[0].id);
        Test.startTest();
        ApexPages.StandardController con = new ApexPages.StandardController(listAcc[0]);
        VFCntrlr_NewAccountHandOver controller = new VFCntrlr_NewAccountHandOver(con);
        String strretURLActual = controller.navigate().getURL();
        Test.stopTest();
        System.assert(strretURLActual.contains('nooverride=1&retURL') && strretURLActual.contains('841019'));
        //system.debug('##KP: End test_NewAccountHandoverForFreshAccount');
    }    
    static testMethod void testNewAccountHandoverForAccountWithOpenAHO() {
        //system.debug('##KP: Start test_NewAccountHandoverForAccountWithOpenAHO');
        
        /*   Account testAccount = new Account (Name='testAccount123', NumberOfEmployees = 841019);
    Insert testAccount; */
        listAcc = [select id from Account limit 1];
        listAcc[0].NumberOfEmployees = 841019;
        update listAcc;
        system.assertEquals(listAcc[0].NumberOfEmployees, listAcc[0].NumberOfEmployees);
        Account_Handover__c accHandover = new Account_Handover__c(Outgoing_rep__c=Userinfo.getUserId(), 
                                                                  Account__c=listAcc[0].Id,Outgoing_Handover_Tasks_Completed__c=true); 
        insert accHandover;
        PageReference pageRef = Page.NewAccountHandOver;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', listAcc[0].id);    
        Test.startTest();            
        ApexPages.StandardController con = new ApexPages.StandardController(listAcc[0]);
        VFCntrlr_NewAccountHandOver controller = new VFCntrlr_NewAccountHandOver(con);
        Test.stopTest();    
        /*System.assertEquals(controller.navigate(),null); */
        //system.debug('##KP: End test_NewAccountHandoverForAccountWithOpenAHO'); 
    }
    
    static testMethod void testNewAccountHandoverError() {
        //system.debug('##KP: Start test_NewAccountHandoverError');
        /*     Account testAccount = new Account (Name='testAccount123', NumberOfEmployees = 841019);
    Insert testAccount;
    */
        listAcc = [select id from Account limit 1];
        listAcc[0].NumberOfEmployees = 841019;
        update listAcc;
        PageReference pageRef = Page.NewAccountHandOver;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', listAcc[0].id);    
        ApexPages.StandardController con = new ApexPages.StandardController(listAcc[0]);
        delete listAcc[0];
        VFCntrlr_NewAccountHandOver controller = new VFCntrlr_NewAccountHandOver(con);
        System.assertEquals(controller.navigate(),null);
        System.assertEquals(controller.Error,true);
        //system.debug('##KP: End test_NewAccountHandoverError');
    }    
}