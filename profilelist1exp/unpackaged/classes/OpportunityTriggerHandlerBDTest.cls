@IsTest
public class OpportunityTriggerHandlerBDTest {
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
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testmethod void deleteOpp(){
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeDelete' => new List<Boolean>{true, false, false, true, false}
        };
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "OpportunityTriggerHandlerBD"},'; 
            }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity';
        tec.RecursiveCount__c = 2;
        insert tec;
        System.assertEquals(2,tec.RecursiveCount__c);
        //TriggerExecutionController.setSkipAllTriggers(true);
        /* Account a = new Account(Name = 'TestAccount');
Insert a;
Opportunity opp = new Opportunity(Name = 'TestOpp1', 
AccountId = a.id,
StageName = 'Plan - 1%',
CloseDate = system.today());
Insert opp;*/
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        // TriggerExecutionController.setSkipAllTriggers(false);
        Delete listOpp;
    }    
}