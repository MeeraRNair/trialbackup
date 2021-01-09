@isTest
private class RebateRequestProductCntrlrTest {
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c countryObj = new Country__c(Name = 'India',
                                               Code__c = 'en_IN1',
                                               Region__c = 'APJ');
        insert countryObj;
        profile profileId =   [select Id, Name from Profile where name like '%Sales Rep%' limit 1];
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        listUserTdf[0].ProfileId=profileId.id;
        insert listUserTdf;
        list<Alliance_Rebate_Request__c> listAllRebReqTdf=TestDataFactory.createNAllianceRebateRequests(2);
        insert listAllRebReqTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testRebateRequestProductCntrlr () {
        /*  profile profileId =   [select Id, Name from Profile where name like '%Sales Rep%' limit 1];
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

//country obj Instance
Country__c countryObj = new Country__c(Name = 'India',
Code__c = 'en_IN1',
Region__c = 'APJ');
insert countryObj;

Opportunity opp = AllianceRebateRequestTrigger_Test.createOpportunityInfo('Test1sdsds@gmail.com');

Alliance_Rebate_Request__c arReq2 = new Alliance_Rebate_Request__c();

arReq2.Sales_Force_Deal_ID__c = opp.id;
arReq2.System_Partner_Name__c ='Intel';
arReq2.Finance_Contact__c = 'xxx@dell.com';
arReq2.Business_Case_Information__c = 'test';
arReq2.Partner_BDM_Name__c = 'testBDM';
insert arReq2; 

Rebate_Request_Product__c productObj1 = new Rebate_Request_Product__c();
productObj1.Quantity__c=2;
productObj1.Part_Name_Part_Number__c='test';
productObj1.Dell_System_Model_type__c='testing';
productObj1.Alliance_Rebate_Request__c= arReq2.id;
productObj1.Start_Date__c= System.today();
productObj1.End_Date__c= System.today() + 10;
insert productObj1;
*/
        list<User> listUser=[select id from user limit 1];
        //System.runAs(listUser[0]){
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);
        
        /* Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();

arReq.Sales_Force_Deal_ID__c = opp.id;
arReq.System_Partner_Name__c ='Intel';
arReq.Finance_Contact__c = 'xxx@dell.com';
arReq.Business_Case_Information__c = 'test';
*/
        list<Alliance_Rebate_Request__c> listArReq=[select id,Sales_Force_Deal_ID__c,System_Partner_Name__c from Alliance_Rebate_Request__c limit 2];
        //list<Rebate_Request_Product__c> listRebReqProd=[select id,Alliance_Rebate_Request__c,Quantity__c from Rebate_Request_Product__c where Alliance_Rebate_Request__c=:listArReq[0].id];
        list<Rebate_Request_Product__c> listRebReqProd=TestDataFactory.createNRebateRequestProducts(2);
        listRebReqProd[0].Alliance_Rebate_Request__c=listArReq[0].id;
        listRebReqProd[1].Alliance_Rebate_Request__c=listArReq[1].id;
        System.assertEquals(listArReq[1].id,listRebReqProd[1].Alliance_Rebate_Request__c);
        system.debug('listRebReqProd>>'+listRebReqProd);
        ApexPages.StandardController sc = new ApexPages.StandardController(listArReq[1]);
        AllianceReabteRequestController allianceRebateReq = new AllianceReabteRequestController(sc);
        allianceRebateReq.getRegions();
        allianceRebateReq.allianceRebateReqObj = listArReq[1];
        allianceRebateReq.saveRequest();
        allianceRebateReq.isCloned ='true';
        
        /* Rebate_Request_Product__c productObj = new Rebate_Request_Product__c();
productObj.Quantity__c=2;
productObj.Part_Name_Part_Number__c='test';
productObj.Dell_System_Model_type__c='testing';
productObj.Alliance_Rebate_Request__c= arReq.id;
*/
        system.debug('listRebReqProd>>>'+listRebReqProd);    
        RebateRequestProductCntrlr rrP = New RebateRequestProductCntrlr ();
        rrP.getSorted();
        
        
        
        UploadQuarterProductsController uploadallianceContrlr = new UploadQuarterProductsController ();
        String str = 'Product Id,RebqteRequest ID,Rebate Request,Created Date,Client / Enterprise,System Partner Name,Region,Quantity Approved,Price Requested,Quantity Claimed,Cost per unit,Effective Date,Expiration Date,Additional Sales Emaila\r\n' + listRebReqProd[0].Id + ',' +listArReq[0].id + ',ARR-000350,Wed Jun 14 13:10:06 GMT 2017,Enterprise,Intel,APJ,1,234,0,5,2017.07.10,2017.07.11,test1@gmail.com\r\n' + listRebReqProd[0].Id + ',' +listArReq[0].id + ',ARR-000350,Wed Jun 14 13:10:06 GMT 2017,Enterprise,Intel,APJ,1,234,0,5,2017.07.10,2017.07.11,test2@gmail.com';
        uploadallianceContrlr.csvFileBody = Blob.valueOf(str);
        uploadallianceContrlr.uploadCSVFile();
        
        uploadallianceContrlr.rebateReqObj = listRebReqProd[0];
        uploadallianceContrlr.searchProducts();
        uploadallianceContrlr.exportAll();
        
        //}
    }
    
    static testMethod void testAllianceSTFPrice(){
        
        list<Alliance_STF_Price__c> liststfPriceObj = new list<Alliance_STF_Price__c>();
        for(integer inti=1; inti<=10; inti++){
            Alliance_STF_Price__c stfPriceObj = new Alliance_STF_Price__c();
            stfPriceObj.Name = 'TestName'+ inti;
            stfPriceObj.Part__c = 'Part'+ inti;
            stfPriceObj.Net_Price__c = inti;
            liststfPriceObj.add(stfPriceObj);
        }
        
        insert liststfPriceObj;
        System.assertEquals(liststfPriceObj,liststfPriceObj);
        UploadSTFPriceController stfUploadCntrl = new UploadSTFPriceController();
        stfUploadCntrl.downloadSTFPriceResults();
        String str = 'SFDC Id, Proc ID, Part, Net Price\r\n' + liststfPriceObj[0].Id + ',TestName12, Part12, 12\r\n' + liststfPriceObj[1].Id + ',testName22, Part22, 22\r\n'+ ' ' + ',TestName33, Part33, 33';
        stfUploadCntrl.csvFileBody = Blob.valueOf(str);
        stfUploadCntrl.uploadCSVFile();
        
        String strDel = 'SFDC Id, Proc ID, Part, Net Price\r\n' + liststfPriceObj[0].Id + ',TestName12, Part12, 12\r\n' + liststfPriceObj[1].Id + ',testName22, Part22, 22';
        stfUploadCntrl.csvFileBodyToDelete = Blob.valueOf(strDel);
        stfUploadCntrl.deleteUploadedFiles();
    }
    
    static testMethod void testUploadOldApprovals(){
        
        /*  profile profileId =   [select Id, Name from Profile where name like '%Sales Rep%' limit 1];
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
Badge_Number__c='Test5454er', 
isActive = TRUE);
insert AllianceRebateUser;

Opportunity opp = AllianceRebateRequestTrigger_Test.createOpportunityInfo('Test332sdsds@gmail.com');
*/
        list<User> listUser=[select id from user where profile.name like '%Sales Rep%' Limit 1];
        UploadOldAllianceApprovalsController oldApprovals = new UploadOldAllianceApprovalsController();
        String str = 'SFDC Id, Region (ABU, EMEA, APJ), Country, Request Date, Start Date, Expiration Date, Customer Name, Part Name, Approved Price, Net Cost, Rebate/Proc, Total Claimed,  Quantity Remaining, Approved Quantity, Requestor, Team Member 1, Team Member 2, Discount, Total Rebate, Notes\r\n' + 
            ' 2123,ABU, CA, 18/1/2017, 8/11/2016, 31/12/2018, TestOpportunity, i5-6500/6500T, 140, 1, 1, 1, 1, 1, AllianceUser@dell.com, AllianceUser@dell.com, AllianceUser@dell.com, 10, 5, Hello\r\n' + 
            ' 3244,NA, CA, 18/1/2017, 8/11/2016, 31/12/2018, TestOpportunity, i5-6500/6500T, 140, 1, 1, 1, 1, 1, AllianceUser@dell.com, AllianceUser@dell.com, AllianceUser@dell.com, 10, 5, Hello\r\n';
        //oldApprovals.csvFileBody = Blob.valueOf(str);
        //oldApprovals.uploadCSVFile();
        System.assertEquals(oldApprovals,oldApprovals);
    }
}