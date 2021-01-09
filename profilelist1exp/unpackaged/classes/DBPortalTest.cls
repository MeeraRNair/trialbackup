/*====================================================================================================================+
|  HISTORY |                                                                 
|                                                                           
| DATE         Modified              Story           DESCRIPTION                               
| ===========  =========           =========          =========== 
| 06-Dec-2019  Venu K 				  0102			   Implemented TDF
+====================================================================================================================*/

@isTest
private class DBPortalTest {
    static PageReference dbPortalPref;   
    static PageReference dbPortalPref2; 
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    //Added custom settings to populate StageName values. -SinLin due deployment validation error
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
    }
    private static testMethod void testSearchOpportunityRegion(){
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[Select id from Account Limit 1];
        Contact newcon = new Contact(FirstName='Test Contact54', LastName='Lastname13', AccountId=listAcc[0].Id, Phone='12345',Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops');
        insert newcon;
        listOpp=[Select id from Opportunity Limit 1];
        system.assertEquals(listAcc[0].id, newcon.AccountId);
        Test.startTest();        
        dbPortalPref=Page.DBPortalPage;
        dbPortalPref.getParameters().put('id',listOpp[0].id);
        dbPortalPref.getParameters().put('obj','Opportunity');
        Test.SetCurrentPage(dbPortalPref);
        DBPortal myDBTest = new DBPortal();
        myDBTest.getOpportunityRegion();
        myDBTest.redirect();
        dbPortalPref2=Page.DBPortalPage;
        dbPortalPref2.getParameters().put('id',listAcc[0].id);
        dbPortalPref2.getParameters().put('obj','Account');
        Test.SetCurrentPage(dbPortalPref2);
        DBPortal myDBTest2 = new DBPortal();
        myDBTest2.getAccountRegion();
        myDBTest2.redirect();
        Test.stopTest();               
    } 
}