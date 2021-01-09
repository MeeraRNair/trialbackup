/**
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      04-DEC-2019   Vikas kh          Implemented TDF
*/

@isTest
public class CaseUpdateEmailHandlerTest{
    static list<Opportunity> listOpp = new List<Opportunity> ();
    Static list<case> listcase = new list<Case>();
    @testSetup static void setup() {
        list<opportunity> listoppfromfactory = TestDataFactory.createNOpportunities(1, 'Channel Opportunity');
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listoppfromfactory;
        list<case> listcasefromTDF=TestDataFactory.createNCases(1);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listcasefromTDF;
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
    } 
    public static testmethod void caseUpdateEmailHandlerTestt(){ 
        TriggerExecutionController.setSkipAllTriggers(true);
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        list<Opportunity> listOpp = [Select id from Opportunity];
        for(Opportunity op:listOpp ){
            op.closedate = System.today().addDays(90);
            op.CurrencyIsoCode = 'EUR';
            op.Domain__c = 'EUC';
            op.Competitor_Lost_To__c = '3i-Infotech';
            op.Solution_Type__c = 'Mobility Solutions';
            op.Solution_Name__c = 'Tablet Solutions';
            op.Competitor_Lost_To__c = 'Unknown';
            op.Type = 'Run Rate';
            op.Deal_Created_Date_Time__c = System.today();
            op.Customer_consent_to_engage_partner__c = true;
        }
        update listOpp;
        list<case> listcase = [select id,status,AccountId,ContactId from case limit 1 ];
        for(case cs :listcase )
        {
            cs.recordtypeId = TestDatafactory.getRecordTypeIdbyName('EMC DR', 'Case');
            cs.Opportunity_Title__c = listOpp[0].id;
            cs.Enterprise_Approve_Rejected_Date__c = system.today();
        }
        update listCase;
        System.assertequals(listCase[0].Status, 'Open');
        listcase = [SELECT Id, CaseNumber, Deal_Id__c from Case WHERE id =: listCase[0].id];
        System.assertnotequals(listCase[0].Deal_Id__c, null);
        String[] liststr = new String[]{'test@dell.com'};      
            String strtextBody = 'test';
        String strhtmlBody = 'test';
        EmailMessage[] listnewEmail = new EmailMessage[0];
        listnewEmail.add(new EmailMessage(FromAddress = 'test@Dell.com', FromName = 'test', ToAddress = 'test@Dell.com.com',
                                          Subject = 'Sandbox: APPROVAL REQUEST: Deal ID#'+listCase[0].Deal_Id__c+'; End User Account Name: Data Load 1004;  Distributor /Reseller Account Name', TextBody = strtextBody, HtmlBody = strhtmlBody, ParentId = listCase[0].id, 
                                          Status = '0')); 
        insert listnewEmail;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        email.subject = 'Sandbox: APPROVAL REQUEST: Deal ID#'+listCase[0].Deal_Id__c+'; End User Account Name: Data Load 1004;  Distributor /Reseller Account Name';
        email.plainTextBody = 'test';
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            envelope.fromAddress = 'dell@test.com';
        attachmenttext.fileName = 'testfile.txt';
        System.assertequals(email.subject.length() > 8, true);  
        CaseUpdateEmailHandler csobj = new CaseUpdateEmailHandler();
        Messaging.InboundEmailResult result = csobj.handleInboundEmail(email, envelope);
        System.assertEquals( result.success , true); 
    }   
}