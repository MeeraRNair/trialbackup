@isTest(seeAlldata=false)
public class ApprovalProcess_Test {
    @testSetup static void setup() {
        OWD__c owdsetting = new OWD__c();
        owdsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdsetting.Oppty_Stage10__c = 'Discover - 10%';
        owdsetting.Oppty_Stage100__c = 'Win - 100%';
        owdsetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdsetting.Oppty_Stage60__c = 'Propose - 60%';
        owdsetting.Oppty_Stage90__c = 'Commit - 90%';
        owdsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert owdsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Alliance_Rebate_Request__c> listAllReqTdf=TestDataFactory.createNAllianceRebateRequests(1);
        insert listAllReqTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }  
    public testmethod static void processinstance(){
        // TriggerExecutionController.setSkipAllTriggers(true);
        
        /* profile profileId1 =   [select Id, Name from Profile where name like '%R16.10 GBL Sales Rep%' limit 1];
User allianceRebateUser2 = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
Alias = 'MTU9', 
Email='AllianceUser2@dell.com', 
FirstName='Alliance', 
LastName='Sales23',  
ProfileId = profileId1.id,
LanguageLocaleKey='zh_CN',
country = 'en_IN1',
LocaleSidKey='zh_CN', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test99856513usi2', 
isActive = TRUE);
insert allianceRebateUser2;

Account testCE = new Account();
testCE.name = 'Some test Account';        
testCE.status__c = 'Active';
testCE.Account_Country_Code__c='US';              
insert testCE;

Opportunity opp = new Opportunity(AccountId = testCE.Id,
Name = 'testOpportunity',
CurrencyIsoCode = 'USD', 
Type = 'Renewal',
CloseDate = system.Today(), 
Domain__c = 'Non Domain',
Solution_Type__c = 'Cloud Integration', 
Solution_Name__c = 'Boomi Solution',
No_times_BookDate_moved__c = 0, 
StageName = 'Plan - 1%' );              
insert opp;

Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
arReq.Sales_Force_Deal_ID__c = opp.id;
arReq.Partner_BDM_Name__c='test';
arReq.System_Partner_Name__c ='Intel';
arReq.Finance_Contact__c = 'xxx@dell.com';
arReq.Client_Enterprise__c ='Client';
arReq.Status__c = 'Draft';
arReq.Additional_Sales_Person_Email__c = '';
arReq.Finance_Contact__c = 'abc@f.com'; 
arReq.Business_Case_Information__c = 'test';
arReq.ownerId =   AllianceRebateUser2.Id;

insert arReq;*/
        Alliance_Rebate_Request__c arReq=[select id from Alliance_Rebate_Request__c Limit 1];
        // TriggerExecutionController.setSkipAllTriggers(false);
        List<ProcessInstance> listprocessInstances = [select Id, Status from ProcessInstance where TargetObjectId = :arReq.id];
        
        System.assertEquals(listprocessInstances.size(),0);
        Alliance_Rebate_Request__c alliance = new Alliance_Rebate_Request__c();
        //ApprovalProcess allaince = new ApprovalProcess();
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();       
        req1.setComments('Submit record for approval');   
        
        req1.setObjectId(arReq.id);      
        req1.setSkipEntryCriteria(false);
        Approval.ProcessResult result = Approval.process(req1);
        ApprovalProcess.processint(new List<Alliance_Rebate_Request__c> {arReq});
    }
}