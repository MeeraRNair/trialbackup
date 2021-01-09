@isTest(seeAlldata = FALSE)
public class Dealreg_AcceptExtension_test {
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert oWDsetting;
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(2, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
        List<Opportunity> listOppFromFactory=TestDataFactory.createNOpportunities(1, 'Deal Registration-Submitted');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listOppFromFactory;
    }   
    static testMethod void approveRejectDealTest(){
        TriggerExecutionController.setSkipAllTriggers(true);
         List<String> lstObjAPINames = new List<String>{'Opportunity'};
        SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);

        listAcc=[select id from account];
        listAcc[0].NPS_Qualified_Contacts__c = 1;
        listAcc[1].type='Partner';
        update listAcc;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].Id;
        listOpp[0].Deal_Registration_Status__c= 'Submitted';
        listOpp[0].Deal_Type__c ='Agent';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Request_Status__c = 'Submitted';
        listOpp[0].Engagement_Type__c='Public Tender';
        listOpp[0].Distributor_Name__c='Direct Fulfilment';
        
        update listOpp;        
       
        system.assertNotEquals(listOpp[0].id, null);
        PageReference pageRef = Page.Dealreg_Accept;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        Dealreg_AcceptExtension con = new Dealreg_AcceptExtension(new ApexPages.StandardController(listOpp[0]));
        con.saveOpp();
    }
}