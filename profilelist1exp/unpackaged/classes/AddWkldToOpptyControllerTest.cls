/*
 ***Author: Ranjith Mergu
 ***Name: AddWkldToOpptyController
 ***Purpose: This Test class using to code cover for AddWkldToOpptyController
*/
@IsTest
public class AddWkldToOpptyControllerTest {
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static list<EMC_General_Settings__c> listEMGS;
    static list<Opportunity_Workload__c> listOppWrkLd;
    static list<Workloads__c> listwrkload;
    static list<Workload_Definition__c> listwrklddef;
        @testsetup 
        static void setup(){
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
            list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Master Account');
            insert listAccTDF;
           /* 
            EMC_General_Settings__c settingData = new EMC_General_Settings__c();
            settingData.ProfilesBypassMyquotesOpptyValidation__c='Boomi Integration API Only;';        
            insert settingData;
            */
            list<EMC_General_Settings__c>listEMCGeneralSettingTDF = TestDataFactory.createNEMCGeneralSetting(1);
            listEMCGeneralSettingTDF[0].ProfilesBypassMyquotesOpptyValidation__c='Boomi Integration API Only;';
            insert listEMCGeneralSettingTDF;
            list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
            listOppTDF[0].AccountID = listAccTDF[0].id;
           TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
            insert listOppTDF;
         }
    static testMethod void createWorkloadsTest(){
        
        //skip all triggers on creation of account and opportunity
        TriggerExecutionController.setSkipAllTriggers(true);
     /*
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        //create account
        Account objAccount = new Account(Name = 'Test Account');
        insert objAccount;
        
        //create Opportunity
        Opportunity objOpp = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                             AccountId=objAccount.Id, 
                                             stagename='Discover - 10%',
                                             Probability=10.0,
                                             RecordTypeId=newOppRecordTypeID,
                                             CloseDate = System.Today() + 30);
        insert objOpp;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        //create Workload Definition
        Workload_Definition__c objWD = new Workload_Definition__c(Name ='Test Workload Definition');
        insert objWD;
        
        List<String> listStrWlkds = new List<String>();
        List<Workloads__c> listWlkds = new List<Workloads__c>();
        //create Workload
        Workloads__c objW = new Workloads__c(
            Account__c = objAccount.Id,
            Workload_Definition__c = objWD.Id
        );
        listStrWlkds.add(objW.Name);
        insert objW;
        
        Opportunity_Workload__c objOppWrkld = new Opportunity_Workload__c(
            Opportunity__c = objOpp.Id,
            Workload__c = objW.Id
        );
        insert objOppWrkld;
        */
        listAcc = [select id,Name from Account limit 1];
        listOpp = [select id from Opportunity limit 1];
        //listOpp[0].stagename='Discover - 10%';
        //listOpp[0].Probability=10.0;
        //update listOpp;
        listEMGS = [select id from EMC_General_Settings__c limit 1];
        list<Workload_Definition__c> listwrklddef = TestDataFactory.createNWorkloadDef(1);
        insert listwrklddef;
        list<Workloads__c> listwrkload = TestDataFactory.createNworkloads (1);
        listwrkload[0].Account__c = listAcc[0].Id;
        listwrkload[0].Workload_Definition__c = listwrklddef[0].id;
        List<String> listStrWlkds = new List<String>();
        listStrWlkds.add(listwrkload[0].Name);
        insert listwrkload;
        list<Opportunity_Workload__c> listOppWrkLd = TestDataFactory.createNOpportunityWorkload(1);
        listOppWrkLd[0].Opportunity__c = listOpp[0].Id;
        listOppWrkLd[0].Workload__c = listwrkload[0].Id;
        insert listOppWrkLd;
        
        ApexPages.StandardController sc = new ApexPages.standardController(listOppWrkLd[0]);
        AddWorkloadstoOpptyExtension controller = new AddWorkloadstoOpptyExtension(sc);
        
        Test.startTest();
        Opportunity_Workload__c oppWrkld = [SELECT Id, Opportunity__c FROM Opportunity_Workload__c WHERE Opportunity__c =: listOpp[0].Id][0];
        system.assertEquals(listOpp[0].Id, oppWrkld.Opportunity__c);
        AddWkldToOpptyController.createWorkloads(listAcc[0], listwrklddef[0]);
        AddWkldToOpptyController.createOpptyWorkloadRecord(listOpp[0].Id, listAcc[0].Id);
        AddWkldToOpptyController.addWorkload(listAcc[0].Id, listStrWlkds);
        AddWkldToOpptyController.getEndCustomer(listAcc[0].Id);
        AddWkldToOpptyController.getAccountList(listAcc[0].Name);
        AddWkldToOpptyController.getWorkloadDefinitionList(listwrklddef[0].Name);
        AddWkldToOpptyController.getWorkloads(listOpp[0].Id, listAcc[0].Id);
        Test.stopTest();
        
    }
    
}