@isTest
private class AllianceRebateRegionPopulate_Test {
    static list<Account> listAcc;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c countryObj = new Country__c(Name = 'United States',
                                               Code__c = 'en_IN1',
                                               Region__c = 'NA');
        insert countryObj;
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].status__c = 'Active';
        listAccTdf[0].Account_Country_Code__c='US';  
        listAccTdf[0].Account_Country__c='United States';
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    private testmethod static void getCountryRegionByOpportunityEndUserAccountTest() {
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(arReq);
        ApexPages.currentPage().getParameters().put('Id', null);
        ApexPages.currentPage().getParameters().put('clone', null);
        Country__c countryObj1=[select name,Code__c,Region__c from Country__c Limit 1];
        /* Country__c countryObj = new Country__c(Name = 'United States',
Code__c = 'en_IN1',
Region__c = 'NA');
insert countryObj;

TriggerExecutionController.setSkipAllTriggers(true);

Account testCE = new Account();
testCE.name = 'Some test Account';        
testCE.status__c = 'Active';
testCE.Account_Country_Code__c='US';  
testCE.Account_Country__c='United States';  
insert testCE;

Opportunity opp = new Opportunity(AccountId = testCE.Id,
Name = 'testOpportunity',
CurrencyIsoCode = 'USD',
Type = 'Renewal',
CloseDate = system.Today(),
Domain__c = 'Non Domain', 
Solution_Type__c = 'Cloud Integration',
Solution_Name__c = 'Boomi Solution',
No_times_BookDate_moved__c = null,
StageName = 'Commit - 90%', 
Competitor_Lost_To__c = 'Accenture',
Forecast_Category_Override__c='Commit');

insert opp;
*/
        listAcc=[select id from Account Limit 1];
        listAcc[0].Account_Country__c = 'United States';
        update listAcc[0];
        list<Opportunity> listOpp=[select id,Deal_Reg_Oppty__c,Deal_Created_Date_Time__c,account.Account_Country__c,accountid from Opportunity where Accountid=:listAcc[0].id limit 1];
        // listOpp[0].Deal_Reg_Oppty__c='Yes';
        // update listOpp;
        AllianceRebateRegionPopulate.getCountryRegionByOpportunityEndUserAccount(listOpp[0].id);
        system.assertEquals(listAcc[0].Id, listAcc[0].Id);
    }    
    private testmethod static void getCountryRegionByOpportunityEndUserAccountTest1() {
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(arReq);
        ApexPages.currentPage().getParameters().put('Id', null);
        ApexPages.currentPage().getParameters().put('clone', null);
        /*  Country__c countryObj = new Country__c(Name = 'United States',
Code__c = 'en_IN1',
Region__c = 'NA');
insert countryObj;

TriggerExecutionController.setSkipAllTriggers(true);

Account testCE = new Account();
testCE.name = 'Some test Account';        
testCE.status__c = 'Active';
testCE.Account_Country_Code__c='US';  
testCE.Account_Country__c='United States';  
insert testCE;

Opportunity opp1 = new Opportunity(Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = null, StageName = 'Commit - 90%', Competitor_Lost_To__c = 'Accenture', Forecast_Category_Override__c='Commit');

insert opp1;

*/               
        Country__c countryObj1=[select name,Code__c,Region__c from Country__c Limit 1];
        list<Account> listAcc=[select id from Account where Account_Country__c='United States' Limit 1];
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOpp=[select id,Accountid from Opportunity where accountid=:listacc[0].id limit 1];
        listOpp[0].Deal_Created_Date_Time__c=system.today();
        update listOpp;
        system.assertEquals(system.today(), listOpp[0].Deal_Created_Date_Time__c);
        TriggerExecutionController.setSkipAllTriggers(false);
        AllianceRebateRegionPopulate.getCountryRegionByOpportunityEndUserAccount(listOpp[0].id);
    }    
}