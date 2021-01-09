@isTest
Public Class AfterInsertUpdateDeleteStrategy_Test {
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<SFDC_Acct_Plan__c> listSfdcAccPlanTdf=TestDataFactory.createNSFDCAccPlan(1,'Account Plan Lite');
        listSfdcAccPlanTdf[0].Account__c=listAccTdf[0].id;
        insert listSfdcAccPlanTdf;
        list<SFDC_Strategy__c> listSfdcStrategyTdf=TestDataFactory.createNSfdcStrategy(1);
        listSfdcStrategyTdf[0].SFDC_Acct_Plan__c=listSfdcAccPlanTdf[0].id;
        insert listSfdcStrategyTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    Public Static testMethod void testStrategy() {
        /* Account acc = new Account(name = 'Test Account');
insert acc;
SFDC_Acct_Plan__c accPlan = new SFDC_Acct_Plan__c(Name='Test AccPlan',Account__c=acc.id,Virtustream__c='N',VMware__c='N',Storage_Strategy__c='N',Services__c='N',Pivotal__c='N',Networking_Strategy__c='N',Enterprise_Infrastructure__c='N',Boomi__c='N',Client_S_P__c='N',
Compute_Servers__c='N',Client_Strategy__c='N',CS__c='N',ESG__c='N',RSA__c='N',SecureWorks__c='N',DPS__c='N');
insert accPlan;
SFDC_Strategy__c strategy = new SFDC_Strategy__c(Name='Test Strategy',When_do_you_plan_to_realize_Strategy__c='FY20 Q3',SFDC_Acct_Plan__c=accPlan.id, What_BU_s_are_involved__c='Client; Compute (Servers); Enterprise Infrastructure; Networking; Pivotal; Services; Storage; Virtustream; VMware; Boomi; Client S&P; CS; ESG; RSA; SecureWorks; DPS; UDS; Unified Workspace');
insert strategy;
*/
        Account acc=[select id from account where recordtype.name='Partner Account'];
        SFDC_Acct_Plan__c accPlan=[select id,Account__c,Virtustream__c from SFDC_Acct_Plan__c where Account__c=:acc.id Limit 1]; 
        SFDC_Strategy__c strategy=[select id,When_do_you_plan_to_realize_Strategy__c,SFDC_Acct_Plan__c,What_BU_s_are_involved__c from SFDC_Strategy__c where SFDC_Acct_Plan__c=:accPlan.id Limit 1];
        Test.startTest();
        SFDC_Strategy__c strategies = [select When_do_you_plan_to_realize_Strategy__c,SFDC_Acct_Plan__c from SFDC_Strategy__c where When_do_you_plan_to_realize_Strategy__c='FY20 Q3' AND SFDC_Acct_Plan__c = :strategy.SFDC_Acct_Plan__c];
        List<SFDC_Strategy__c> listStrategy1 = [select When_do_you_plan_to_realize_Strategy__c,SFDC_Acct_Plan__c from SFDC_Strategy__c where When_do_you_plan_to_realize_Strategy__c='FY20 Q3' AND SFDC_Acct_Plan__c = :strategy.SFDC_Acct_Plan__c];
        afterInsertUpdateDeleteStrategy.noOfStrategies(listStrategy1,listStrategy1);
        if(strategies.When_do_you_plan_to_realize_Strategy__c != null){
            integer intCount = [select Count() from SFDC_Strategy__c where When_do_you_plan_to_realize_Strategy__c='FY20 Q3' AND SFDC_Acct_Plan__c = :strategy.SFDC_Acct_Plan__c];
            accPlan.No_of_Strategies_by_Current_Next_FY__c = String.valueOf(intCount);
        }
        Integer intClient = 0;
        Integer intCompute = 0;
        Integer intEI = 0;
        Integer intNetworking = 0;
        Integer intPivotal = 0;
        Integer intServices = 0;
        Integer intStorage = 0;
        Integer intVirtustream = 0;
        Integer intVMware = 0;
        Integer intBoomi = 0;
        Integer intCs = 0;
        Integer intClientSp = 0;
        Integer intEsg = 0;
        Integer intSecureWork = 0;
        Integer intRsa = 0;
        Integer intDps = 0;
        Integer intUds = 0;
        Integer intUw = 0;
        
        SFDC_Strategy__c strategies2 = [Select What_BU_s_are_involved__c, Which_LOB_will_you_offer__c, SFDC_Acct_Plan__c from SFDC_Strategy__c where SFDC_Acct_Plan__c = :strategy.SFDC_Acct_Plan__c];   
        String[] listWhatBuInv;
        String[] listWhatBuOffer;
        set<string> setStr = new set<string>();
        if(strategies2.What_BU_s_are_involved__c != null){
            listWhatBuInv = strategies2.What_BU_s_are_involved__c.split(';');
            setStr.addAll(listWhatBuInv);
        }
        //String listWhatBuInv = strategies.What_BU_s_are_involved__c;
        if(strategies2.Which_LOB_will_you_offer__c != null){
            listWhatBuOffer = strategies2.Which_LOB_will_you_offer__c.split(';');
            setStr.addAll(listWhatBuOffer);
        }
        
        if(setStr.contains('Client')){
            intClient++;
            accPlan.Client_Strategy__c = string.valueOf(intClient)+'Y';
        }
        if(setStr.contains('Compute (Servers)')){
            intCompute++;
            accPlan.Compute_Servers__c = string.valueOf(intCompute)+'Y';
        }
        
        if(setStr.contains('Enterprise Infrastructure')){
            intEI++;
            accPlan.Enterprise_Infrastructure__c = string.valueOf(intEI)+'Y';
        }
        
        if(setStr.contains('Networking')){
            intNetworking++;
            accPlan.Networking_Strategy__c = string.valueOf(intNetworking)+'Y';
        }
        
        if(setStr.contains('Pivotal')){
            intPivotal++;
            accPlan.Pivotal__c = string.valueOf(intPivotal)+'Y';
        }
        
        if(setStr.contains('Services')){
            intServices++;
            accPlan.Services__c = string.valueOf(intServices)+'Y';
        }
        
        if(setStr.contains('Storage')){
            intStorage++;
            accPlan.Storage_Strategy__c = string.valueOf(intStorage)+'Y';
        }
        
        if(setStr.contains('Virtustream')){
            intVirtustream++;
            accPlan.Virtustream__c = string.valueOf(intVirtustream)+'Y';
        }
        
        if(setStr.contains('VMware')){
            intVMware++;
            accPlan.VMware__c = string.valueOf(intVMware)+'Y';
        }
        if(setStr.contains('Boomi')){
            intBoomi++;
            accPlan.Boomi__c = string.valueOf(intBoomi)+'Y';
        }
        if(setStr.contains('Client S&P')){
            intClientSp++;
            accPlan.Client_S_P__c = string.valueOf(intClientSp)+'Y';
        }
        if(setStr.contains('CS')){
            intCs++;
            accPlan.CS__c = string.valueOf(intCs)+'Y';
        }
        if(setStr.contains('ESG')){
            intEsg++;
            accPlan.ESG__c = string.valueOf(intEsg)+'Y';
        }
        if(setStr.contains('RSA')){
            intRsa++;
            accPlan.RSA__c = string.valueOf(intRsa)+'Y';
        }
        if(setStr.contains('SecureWorks')){
            intSecureWork++;
            accPlan.SecureWorks__c = string.valueOf(intSecureWork)+'Y';
        }
        if(setStr.contains('UDS')){
            intUds++;
            accPlan.UDS__c = string.valueOf(intUds)+'Y';
        }
        if(setStr.contains('DPS')){
            intDps++;
            accPlan.DPS__c = string.valueOf(intDps)+'Y';
        }
        if(setStr.contains('Unified Workspace')){
            intUw++;
            accPlan.Unified_Workspace__c = string.valueOf(intUw)+'Y';
        }
        update accPlan;
        System.assertEquals('1', accPlan.No_of_Strategies_by_Current_Next_FY__c);
        System.assertEquals('1Y', accPlan.Client_Strategy__c);
        System.assertEquals('1Y', accPlan.Compute_Servers__c);
        System.assertEquals('1Y', accPlan.Enterprise_Infrastructure__c);
        System.assertEquals('1Y', accPlan.Networking_Strategy__c);
        System.assertEquals('1Y', accPlan.Pivotal__c);
        System.assertEquals('1Y', accPlan.Services__c);
        System.assertEquals('1Y', accPlan.Storage_Strategy__c);
        System.assertEquals('1Y', accPlan.Virtustream__c);
        System.assertEquals('1Y', accPlan.VMware__c);
        System.assertEquals('1Y', accPlan.Boomi__c);
        System.assertEquals('1Y', accPlan.Client_S_P__c);
        System.assertEquals('1Y', accPlan.CS__c);
        System.assertEquals('1Y', accPlan.ESG__c);
        System.assertEquals('1Y', accPlan.RSA__c);
        System.assertEquals('1Y', accPlan.SecureWorks__c);
        System.assertEquals('1Y', accPlan.DPS__c);
        System.assertEquals('1Y', accPlan.UDS__c);
        System.assertEquals('1Y', accPlan.Unified_Workspace__c);
        Test.StopTest();
    }
}