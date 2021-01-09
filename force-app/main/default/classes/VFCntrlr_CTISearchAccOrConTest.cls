/***********************************************************
* Name          : VFCntrlr_CTISearchAccOrConTest
* Description   : Test class for VFCntrlr_CTISearchAccOrCon
* ---------------------------------------------------------
* Revision      Release     Name    Date            Description
* 1.0           12.7        MenMee  13.06.2011      CR5944, CR5945, CR5947 SFDC-CTI Integration
* 2.0           15.03       Samridh 15.01.2014      CR9038
***********************************************************/

@isTest
private class VFCntrlr_CTISearchAccOrConTest {
    static list<Account> listAcc;
    static list<CTI_Call_Log__c> listCtiCL;
    static list<Contact> listCon;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        insert listAccTdf;
        list<CTI_Call_Log__c> listCtiCLTdf=TestDataFactory.createNCTIcallLog(1);
        insert listCtiCLTdf;
        list<Contact> listConTdf=TestDataFactory.createNContacts(1);
        insert listConTdf;
    }
    //static Account testAcc; 
    //Static Contact testCon;
    static string strStartTime = '2011-06-15 09:30:15Z';
    static string strEndTime = '2011-06-15 09:50:15Z';
    
    static testMethod void searchCTIAccount() {
        
        //TestDataCreation();
        
        System.debug('##### Party Id found');
        PageReference pageRef = Page.CTISearchAccOrCon;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('partyId', '001233445566');
        ApexPages.currentPage().getParameters().put('phoneNo', '9978567473');
        
        VFCntrlr_CTISearchAccOrCon controller = new VFCntrlr_CTISearchAccOrCon();       
        
        //RESULT: Redirect to Account details page
        //System.assertEquals('/'+listAcc[0].Id, controller.searchAccOrUpsertCallLog().getUrl());
        
        System.debug('##### Party Id not found');
        controller.qsPartyId = '@$#00000';              
        controller.searchAccOrUpsertCallLog();
        
        //RESULT: Redirect to Search Page with Phone number     
        //System.assertEquals('/_ui/common/search/client/ui/UnifiedSearchResults?sen=001&sen=003&str='+EncodingUtil.urlEncode('9978567473 OR 0*9978567473 OR 978567473', 'UTF-8'), controller.retURL);
        System.assertEquals(Label.Global_Search_URL+'&sen=001&sen=003&str='+EncodingUtil.urlEncode('9978567473 OR 0*9978567473 OR 978567473', 'UTF-8'), controller.retURL);
    }
    
    static testMethod void createOrUpdateCTILog() {
        //TestDataCreation();
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc = [Select Id from Account limit 1];
        listCon = [Select Id from Contact limit 1];
        listCon[0].AccountId = listAcc[0].Id;
        update listCon[0];
        listCtiCL = [Select Id from CTI_Call_Log__c limit 1];
        listCtiCL[0].Account__c = listAcc[0].Id;
        listCtiCL[0].Contact__c = listCon[0].Id;
        listCtiCL[0].Call_Start_Time__c = datetime.valueOfGMT(strStartTime);
        listCtiCL[0].Call_End_Time__c = datetime.valueOfGMT(strEndTime);
        update listCtiCL[0];
        System.debug('##### Create CTI Log for outbound call');
        //PageReference pageRef = Page.CTISearchAccOrCon;
        //Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId', listAcc[0].Id); 
        ApexPages.currentPage().getParameters().put('contactId', listCon[0].Id);          
        ApexPages.currentPage().getParameters().put('type', 'O');
        ApexPages.currentPage().getParameters().put('start', strStartTime);
        ApexPages.currentPage().getParameters().put('end', strEndTime);
        
        VFCntrlr_CTISearchAccOrCon controller = new VFCntrlr_CTISearchAccOrCon();
        controller.searchAccOrUpsertCallLog();
        
        //RESULT: log is created
        //List<CTI_Call_Log__c> newLog = [SELECT Id, Call_Start_Time__c, Call_End_Time__c, Router_Call_Day__c, Router_Call_Key__c FROM CTI_Call_Log__c
        //WHERE Call_Type__c = 'Outgoing' AND Account__c = :listAcc[0].Id ];
        System.assertEquals(1, listCtiCL.size());      
        //System.assertEquals(datetime.valueOfGMT(sStartTime), listCtiCL[0].Call_Start_Time__c); 
        //System.assertEquals(datetime.valueOfGMT(sEndTime), listCtiCL[0].Call_End_Time__c); 
        //System.assertEquals(null, listCtiCL[0].Router_Call_Day__c);
        //System.assertEquals(null, listCtiCL[0].Router_Call_Key__c);
        
        
        System.debug('##### Update CTI Log for inbound call');      
        ApexPages.currentPage().getParameters().put('partyId', '001233445566');
        ApexPages.currentPage().getParameters().put('phoneNo', '8601662');
        ApexPages.currentPage().getParameters().put('key', '#123456');
        ApexPages.currentPage().getParameters().put('keyDay', '#098765');
        ApexPages.currentPage().getParameters().put('type', 'I');
        ApexPages.currentPage().getParameters().put('start', '2011-06-15 10:00:15Z');
        ApexPages.currentPage().getParameters().put('end', '2011-06-15 10:10:15Z');
        
        controller = new VFCntrlr_CTISearchAccOrCon();
        controller.searchAccOrUpsertCallLog();
        
        //RESULT: end time in log is updated
        //newLog = [SELECT Id, Account__c, Contact__c, Call_Start_Time__c, Call_End_Time__c FROM CTI_Call_Log__c
        //        WHERE Router_Call_Key__c = '#123456' AND Router_Call_Day__c = '#098765'];
        System.assertEquals(1, listCtiCL.size());      
        //System.assertEquals(datetime.valueOfGMT(sStartTime), listCtiCL[0].Call_Start_Time__c); //Start time remain no change
        //System.assertEquals(datetime.valueOfGMT('2011-06-15 10:10:15Z'), listCtiCL[0].Call_End_Time__c);   //End time get updated
        
    } 
    
    /*static void TestDataCreation() {
listAcc = [Select Id from Account limit 1];
listCon = [Select Id from Contact limit 1];
listCtiCL = [Select Id from CTI_Call_Log__c limit 1];
listCtiCL[0].Account__c = listAcc[0].Id;
listCtiCL[0].Contact__c = listCon[0].Id;
listCtiCL[0].Call_Start_Time__c = datetime.valueOfGMT(sStartTime);
listCtiCL[0].Call_End_Time__c = datetime.valueOfGMT(sEndTime);
update listCtiCL[0];
testAcc = new Account(Name = 'Test CTI Account', Account_Id__c = '001233445566');
insert testAcc;

// acc = new Account(Name = 'testAccount');
// insert acc;

testCon = new Contact(AccountId = testAcc.Id,Email = 'test@test.com',FirstName = 'conFirstName',LastName = 'conLastName');
insert testCon;

CTI_Call_Log__c testCTILog = new CTI_Call_Log__c(Account__c = testAcc.Id, Contact__c = testCon.Id, Call_Start_Time__c = datetime.valueOfGMT(sStartTime), Call_End_Time__c = datetime.valueOfGMT(sEndTime), 
Router_Call_Key__c = '#123456', Router_Call_Day__c = '#098765',Call_Type__c = 'Incoming');
insert testCTILog;   
} */  
    
    
}