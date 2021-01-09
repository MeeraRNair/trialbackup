/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/
@isTest(seeAlldata=false)
public class RebateRequestProductTriggerHandlerAITest {
    
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
        system.debug('listAllianceRebReqTdf>>>'+listAllianceRebReqTdf);
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
    //insert Custom Setting for test classes - Afiq FY180203 8 Feb 2018 - END
    
    private static testMethod void testAfterInsert() {
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Rebate_Request_Product__c", "Class_Name__c": "RebateRequestProductTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
       // Opportunity opp = AllianceRebateRequestTriggerAUTest.createOpportunityInfo();
        Alliance_STF_Price__c stfPrice = new Alliance_STF_Price__c(Net_Price__c = 10,Name= '123456');
        insert stfPrice;
        Alliance_Rebate_Request__c arReq = [select id,Sales_Force_Deal_ID__c,Partner_BDM_Name__c,Dell_Standard_CPU__c,Business_Case_Information__c,Finance_Contact__c,Dell_Standard_CPU_Currency__c,System_Partner_Name__c,Part_Requested__c,Client_Enterprise__c from Alliance_Rebate_Request__c Limit 1];
        
        /*Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
arReq.Sales_Force_Deal_ID__c = opp.id;
arReq.System_Partner_Name__c ='Intel';
arReq.Part_Requested__c ='CPU';
arReq.Client_Enterprise__c ='Enterprise';
arReq.Dell_Standard_CPU_Currency__c = 123.45;
arReq.Finance_Contact__c = 'xxx@dell.com';
arReq.Business_Case_Information__c = 'test';
arReq.Dell_Standard_CPU__c  =stfPrice.id;
arReq.Partner_BDM_Name__c='test';
insert arReq ;
*/
        //Rebate_Request_Product__c productObj = [select id,Quantity__c,Price_Requested__c,Alliance_Rebate_Request__c,Dell_System_Model_type__c,Part_Name_Part_Number__c from Rebate_Request_Product__c Limit 1];
        list<Rebate_Request_Product__c> listRebReqProd=TestDataFactory.createNRebateRequestProducts(1);
        listRebReqProd[0].Alliance_Rebate_Request__c=arReq.id;
        insert listRebReqProd;
        system.assertEquals(listRebReqProd[0].Status__c,'Active');
            // system.debug('listRebReqProdTdf>>'+listRebReqProdTdf);
            /*  Rebate_Request_Product__c productObj = new Rebate_Request_Product__c();
productObj.Quantity__c=2;
productObj.Price_Requested__c = 25.00;
productObj.Part_Name_Part_Number__c='test';
productObj.Dell_System_Model_type__c='testing';
productObj.Alliance_Rebate_Request__c= arReq.id;

insert productObj ;
*/
            
            // list<Alliance_Rebate_Request__c> listAllRebReq=[select id,Client_Enterprise__c,Partner_BDM_Name__c,Total_Intel_discount_requested__c,Business_Case_Information__c,Dell_Standard_CPU_Currency__c,Sales_Force_Deal_ID__c,Finance_Contact__c,System_Partner_Name__c,Part_Requested__c,Dell_Standard_CPU__c from Alliance_Rebate_Request__c Limit 1];
            //list<Rebate_Request_Product__c> listRebReqProd=[select id,Quantity__c,Status__c,Part_Name_Part_Number__c,Dell_System_Model_type__c,Price_Requested__c,Alliance_Rebate_Request__c from Rebate_Request_Product__c ];
            //system.assertEquals(listRebReqProd[0].Status__c,'Active');
            // Alliance_Rebate_Request__c updatedAR = [SELECT Dell_Standard_CPU_Currency__c, Total_Intel_discount_requested__c FROM Alliance_Rebate_Request__c WHERE Id = :listAllRebReq[0].Id];
            // System.assertEquals(Integer.valueOf(listAllRebReq[0].Dell_Standard_CPU_Currency__c - (listRebReqProd[0].Price_Requested__c * listRebReqProd[0].Quantity__c)), listAllRebReq[0].Total_Intel_discount_requested__c);
            }
}