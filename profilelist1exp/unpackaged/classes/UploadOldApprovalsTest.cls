/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest(seeAllData=false)
private class UploadOldApprovalsTest {
    static Opportunity opp = new Opportunity();
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
        profile profileId =   [select Id, Name from Profile where name like '%Sales Rep%' limit 1];
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        listUserTdf[0].ProfileId=profileId.id;
        insert listUserTdf;
        list<Alliance_Rebate_Request__c> listAllRebReqTdf=TestDataFactory.createNAllianceRebateRequests(1);
        insert listAllRebReqTdf;
        list<Rebate_Request_Product__c> listRebReqProdTdf=TestDataFactory.createNRebateRequestProducts(1);
        listRebReqProdTdf[0].Alliance_Rebate_Request__c=listAllRebReqTdf[0].id;
        insert listRebReqProdTdf;
        system.debug('listRebReqProdTdf>>'+listRebReqProdTdf);
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testUploadOldApprovals(){
        /*  profile profileId =   [select Id, Name from Profile where name like '%Sales Rep%' limit 1];
User allianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
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
Badge_Number__c='Test5454er', 
isActive = TRUE);
insert allianceRebateUser;


TriggerExecutionController.setSkipAllTriggers(true);

Account testCE = new Account();
testCE.name = 'Some test Account';        
testCE.status__c = 'Active';
testCE.Account_Country_Code__c='US';              
insert testCE;

Opportunity newOpportunity = new Opportunity(AccountId = testCE.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
insert newOpportunity;
Alliance_Rebate_Request__c arReq2 = new Alliance_Rebate_Request__c();

arReq2.Sales_Force_Deal_ID__c = newOpportunity.id;
//arReq2.Sales_Force_Deal_ID__c = 
arReq2.System_Partner_Name__c ='Intel';
arReq2.Finance_Contact__c = 'xxx@dell.com';
arReq2.Business_Case_Information__c = 'test';
arReq2.Partner_BDM_Name__c = 'testBDM';
insert arReq2;
System.Assert(arReq2.Id != null); 
Rebate_Request_Product__c productObj1 = new Rebate_Request_Product__c();
productObj1.Quantity__c=2;
productObj1.Part_Name_Part_Number__c='test';
productObj1.Dell_System_Model_type__c='testing';
productObj1.Alliance_Rebate_Request__c= arReq2.id;
productObj1.Start_Date__c= System.today();
productObj1.End_Date__c= System.today() + 10;
insert productObj1;
System.Assert(productObj1.Id != null);
TriggerExecutionController.setSkipAllTriggers(false);
*/
        list<Rebate_Request_Product__c> listRebReqProd=[select id,Alliance_Rebate_Request__c,End_Date__c,Start_Date__c,Quantity__c,Dell_System_Model_type__c from Rebate_Request_Product__c Limit 1];
        system.assertNotEquals(listRebReqProd[0].id, null);
        UploadOldAllianceApprovalsController oldApprovals = new UploadOldAllianceApprovalsController();
        String str = 'SFDC Id, Region (ABU, EMEA, APJ), Country, Request Date, Start Date, Expiration Date, Customer Name, Part Name, Approved Price, Net Cost, Rebate/Proc, Total Claimed,  Quantity Remaining, Approved Quantity, Requestor, Team Member 1, Team Member 2, Discount, Total Rebate, Notes\r\n' + 
            ' 2123,ABU, Client, 11/11/2019, 11/11/2020, 12/01/2021, Intel, i5-6500/6500T, 14, 1, 1, 1, 1, 11, global_alliance@dell.com, global_alliance@dell.com, 10, 5, Hello\r\n' + 
            ' 3244,NA, Client, 11/11/2019, 11/11/2020, 12/11/2021, Intel, i5-6500/6500T, 14, 1, 1, 1, 1, 11, global_alliance@dell.com, global_alliance@dell.com, 10, 5, Hello\r\n' +
            ' 3244, APJ, Client, 11/11/2019, 11/11/2020, 12/11/2021, Intel, i5-6500/6500T, 14, 1, 1, 1, 1, 11, global_alliance@dell.com, global_alliance@dell.com, 10, 5, ';
        
        /*String str = 'SFDC Id, Region (ABU, EMEA, APJ), Country, Request Date, Start Date, Expiration Date, Customer Name, Part Name, Approved Price, Net Cost, Rebate/Proc, Total Claimed,  Quantity Remaining, Approved Quantity, Requestor, Team Member 1, Team Member 2, Discount, Total Rebate, Notes\r\n' + 
' 2123,ABU, CA, 18/1/2017, 8/11/2016, 31/12/2018, TestOpportunity, i5-6500/6500T, 140, 1, 1, 1, 1, 1, AllianceUser@dell.com, AllianceUser@dell.com, AllianceUser@dell.com, 10, 5, Hello\r\n' + 
' 3244,NA, CA, 18/1/2017, 8/11/2016, 31/12/2018, TestOpportunity, i5-6500/6500T, 140, 1, 1, 1, 1, 1, AllianceUser@dell.com, AllianceUser@dell.com, AllianceUser@dell.com, 10, 5, Hello\r\n';*/
        oldApprovals.blbcsvFileBody = Blob.valueOf(str);
        oldApprovals.uploadCSVFile();
        //oldApprovals.getOpportunityFromNames();
    }
    
}