@isTest
private class AllianceRebateProductExpired_Test {
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        profile profileId =   [select Id, Name from Profile where name like '%R16.10 GBL Sales Rep%' limit 1];
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        listUserTdf[0].ProfileId=profileId.id;
        insert listUserTdf;
        list<Alliance_Rebate_Request__c> listAllianceRebReqTdf=TestDataFactory.createNAllianceRebateRequests(1);
        insert listAllianceRebReqTdf;
        list<Rebate_Request_Product__c> listRebReqProdTdf=TestDataFactory.createNRebateRequestProducts(1);
        listRebReqProdTdf[0].Alliance_Rebate_Request__c=listAllianceRebReqTdf[0].id;
        insert listRebReqProdTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    private testmethod static void changeAllianceStatus() {
        
        //Logged In User
        /*  profile profileId =   [select Id, Name from Profile where name like '%R16.10 GBL Sales Rep%' limit 1];
User AllianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
Alias = 'MTU9', 
Email='AllianceUser@dell.com', 
FirstName='Alliance', 
LastName='Sales23',  
ProfileId = profileId.id,
LanguageLocaleKey='zh_CN',
country = 'en_IN1',
LocaleSidKey='zh_CN', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test99826513usi2', 
isActive = TRUE);
insert AllianceRebateUser;

Opportunity opp = AllianceRebateRequestTrigger_Test.createOpportunityInfo('Test1sdsds@gmail.com');

TriggerExecutionController.setSkipAllTriggers(True);

Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
arReq.Sales_Force_Deal_ID__c = opp.id;
arReq.System_Partner_Name__c ='Intel';
arReq.Finance_Contact__c = 'xxx@dell.com';
arReq.Business_Case_Information__c = 'test';
arReq.Status__c ='Draft';
arReq.Partner_BDM_Name__c='test';
insert arReq;

Rebate_Request_Product__c productObj1 = new Rebate_Request_Product__c();
productObj1.Quantity__c=2;
productObj1.Part_Name_Part_Number__c='test';
productObj1.Dell_System_Model_type__c='testing';
productObj1.Status__c= 'Expired';
productObj1.Alliance_Rebate_Request__c= arReq.id;

insert productObj1;

Rebate_Request_Product__c productObj2 = new Rebate_Request_Product__c();
productObj2.Quantity__c=2;
productObj2.Part_Name_Part_Number__c='test';
productObj2.Dell_System_Model_type__c='testing';
productObj2.Status__c= 'Expired';
productObj2.Alliance_Rebate_Request__c= arReq.id;
insert productObj2;

List<id> ids = new List<id>();
ids.add(productObj1.id);
ids.add(productObj2.Id);
*/
        list<Rebate_Request_Product__c> listRebReqProd=[select id,Status__c from Rebate_Request_Product__c ];
        listRebReqProd[0].Status__c= 'Expired';
        update listRebReqProd;
        system.assertEquals('Expired', listRebReqProd[0].Status__c);
        List<id> listIds = new List<id>();
        for(Rebate_Request_Product__c reb : listRebReqProd){
            listIds.add(reb.id);
        }
        AllianceRebateProductExpired allianceProductExpired = new AllianceRebateProductExpired();
        AllianceRebateProductExpired.changeAllianceStatus(listIds);
        AllianceRebateProductStatus allianceProductStatusChange = new AllianceRebateProductStatus();
        AllianceRebateProductStatus.changeAllianceStatusChange(listIds);
        //TriggerExecutionController.setSkipAllTriggers(false);
    }
}