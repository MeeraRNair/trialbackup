@isTest
public class OpportunityPlanTriggerHandlerADTest {
    
    //insert Custom Setting for test classes - Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
    //insert Custom Setting for test classes - Afiq FY180203 8 Feb 2018 - END
    
    static testMethod void updateRollUpSummaryInOpportunityTest(){
        //  insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterDelete' => new List<Boolean>{false, false, false, true, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity_Plan__c", "Class_Name__c": "OpportunityPlanTriggerHandlerAD"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity_Plan__c';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        ProcessFlowTriggerController.isTest = true;
        OpportunityPlanUtilities.isTest = true;
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        Test.startTest();
        
        /*  Account testAccount = new Account(Name='Test Account');  
insert testAccount;  

Opportunity testOppty = new Opportunity(Name='Test Oppty', AccountId=testAccount.Id, StageName='Discover - 10%', CloseDate = System.Today() + 30 ); 
insert testOppty;   
*/
        list<Account> listAcc=[select id from Account Limit 1];
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        Opportunity_Plan__c plan = new Opportunity_Plan__c(Name='Test Plan', Opportunity__c=listOpp[0].Id);
        insert plan;
        
        //Opportunity opp = [SELECT Opportunity_Plan_Roll_up_Summary__c FROM Opportunity WHERE Id = :testOppty.Id];
        //system.assertEquals(1.0, opp.Opportunity_Plan_Roll_up_Summary__c);
        
        delete plan;
        Opportunity opp = [SELECT Opportunity_Plan_Roll_up_Summary__c FROM Opportunity WHERE Id = :listOpp[0].Id];
        
        system.assertEquals(0.0, opp.Opportunity_Plan_Roll_up_Summary__c);
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
    }
}