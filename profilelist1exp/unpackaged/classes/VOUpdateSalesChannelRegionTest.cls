@isTest(seeAllData=false)
public class VOUpdateSalesChannelRegionTest {
    static Account testAccount;
    static visitops__Company__c testCompany;
    @testSetup static void setup() {
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
    static testMethod void createTestData() {            
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Region_Name__c = 'EMEA');
        insert salesChannel;
        
        list<Account> listAcc=[Select id from Account Limit 1];
        listAcc[0].Sales_Channel__c = salesChannel.Id;
        update listacc;
        list<Opportunity> listOpp=[Select id from Opportunity Limit 1];
        //Create Company
        testCompany = new visitops__Company__c(visitops__Account__c = listAcc[0].id, visitops__Company_Name__c= 'testAccount', visitops__Company_Annual_Revenue__c = 10000000, visitops__Company_Industry__c = 'Agriculture' , visitops__Company_Website__c = 'http://www.abc.com'); 
        insert testCompany;
        system.assertNotEquals(listOpp[0].id, null);
        VisitOps__VisitBundle__c bundle= new VisitOps__VisitBundle__c();
        bundle.VisitOps__Opportunity__c=listOpp[0].id;
        //insert bundle;
        Test.startTest();
        List<ID> listSalesChannel = new List<ID>();
        listSalesChannel.add(salesChannel.id);
        VOUpdateSalesChannelRegion.updateCompanyRegion(listSalesChannel);
        Test.stopTest();
    }
}