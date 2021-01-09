@isTest(seeAlldata=false)
public class RebateRequestProductTriggerHandlerAUTest {
    
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
        list<Alliance_Rebate_Request__c> listAllianceRebReqTdf=TestDataFactory.createNAllianceRebateRequests(1);
        insert listAllianceRebReqTdf;
        list<Rebate_Request_Product__c> listRebReqProdTdf=TestDataFactory.createNRebateRequestProducts(1);
        listRebReqProdTdf[0].Alliance_Rebate_Request__c=listAllianceRebReqTdf[0].id;
        insert listRebReqProdTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
    //insert Custom Setting for test classes - Afiq FY180203 8 Feb 2018 - END
    
    private static testMethod void testAfterUpdate() {
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Rebate_Request_Product__c", "Class_Name__c": "RebateRequestProductTriggerHandlerAU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        /*  Opportunity opp1 = AllianceRebateRequestTriggerAUTest.createOpportunityInfo();

Alliance_STF_Price__c stfPrice1 = new Alliance_STF_Price__c(Net_Price__c = 10,Name= '123456');
insert stfPrice1 ;

list<Alliance_Rebate_Request__c> listARR = new list<Alliance_Rebate_Request__c>();
for(integer intLoop = 0; intLoop < 1; intLoop++){
listARR.add(new Alliance_Rebate_Request__c(System_Partner_Name__c = 'Intel',
Part_Requested__c ='CPU',
Client_Enterprise__c ='Enterprise',
Dell_Standard_CPU_Currency__c = 123.45,
Partner_BDM_Name__c='test',
Sales_Force_Deal_ID__c = opp1 .id,
Dell_Standard_CPU__c  = stfPrice1 .id,
Finance_Contact__c = 'abc@gmail.com'));
}
insert listARR;

list<Rebate_Request_Product__c> listRRP = new list<Rebate_Request_Product__c>();
for(Alliance_Rebate_Request__c ar : listARR){
listRRP.add(new Rebate_Request_Product__c(Alliance_Rebate_Request__c = ar.id,
Price_Requested__c = 10,
Quantity__c = 2,Status__c = 'Active'));
}
insert listRRP;

Alliance_Rebate_Request__c newARR = new Alliance_Rebate_Request__c(System_Partner_Name__c = 'Intel',
Part_Requested__c ='CPU',
Client_Enterprise__c ='Enterprise',
Dell_Standard_CPU_Currency__c = 555.45,
Partner_BDM_Name__c='test',
Sales_Force_Deal_ID__c = opp1 .id,
Dell_Standard_CPU__c  = stfPrice1 .id,
Finance_Contact__c = 'abc@gmail.com');
insert newARR;
*/
        list<Alliance_Rebate_Request__c> listAllRebReq=[select id from Alliance_Rebate_Request__c Limit 1];
        list<Rebate_Request_Product__c> listRebReqProd=[select id,Status__c from Rebate_Request_Product__c ];
        listRebReqProd[0].Status__c= 'Expired';
        update listRebReqProd;
        Rebate_Request_Product__c insertedRRP = [SELECT Alliance_Rebate_Request__c FROM Rebate_Request_Product__c WHERE Id = :listRebReqProd[0].Id];
        insertedRRP.Alliance_Rebate_Request__c = listAllRebReq[0].Id;
        update insertedRRP;
        System.assertEquals(listRebReqProd[0].Status__c, 'Expired');
    }
    
}