@isTest
public class AttachPartnerRepliesToCaseTest{
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
        
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1,'Deal Registration-Submitted');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        list<Case> listCaseTdf=TestDataFactory.createNCases(1);
        listCaseTdf[0].AccountId=listAccTdf[0].id;
        listCaseTdf[0].Opportunity_Title__c=listOppTdf[0].id;
        listCaseTdf[0].Enterprise_Approve_Rejected_Date__c = system.today();
        insert listCaseTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    public static testmethod void attachPartnerRepliesToCaseTest1(){ 
        TriggerExecutionController.setSkipAllTriggers(true);
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        /* Account Acc = new Account(Name = 'Test');
insert acc;
Contact con = new Contact(Lastname = 'Test', 
Accountid = acc.id, 
Email = 'test@dell.com',
Phone = '123123123');
insert con;
String caseDelRegistratnRT = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration'); 
Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
Opportunity opp = new Opportunity(AccountId = Acc.Id,
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

Case caseObj = new Case(ContactId = con.id,
AccountId = acc.id,
Opportunity_Title__c = opp.id,
Enterprise_Approve_Rejected_Date__c = system.today(),
RecordTypeID = caseDelRegistratnRT,
Status = 'Open', 
Priority = 'High', 
Subject = 'Sandbox: APPROVAL REQUEST: DealID# End User Account Name: Data Load 1004;  Distributor /Reseller Account Name',
Description = 'test' );
/* Case caseObj = new Case();
caseObj = [SELECT Id, CaseNumber,Referrence_Id__c , Deal_Id__c from Case Limit 1];*/
        list<Case> listCase=[select id,Status from Case Limit 1];
        TriggerExecutionController.setSkipAllTriggers(true);
        // insert caseObj;
        System.assertequals(listCase[0].Status, 'Open');
        Case caseobj = [SELECT Id, CaseNumber,Referrence_Id__c , Deal_Id__c from Case WHERE id =: listCase[0].id];
        // System.assertnotequals(Caseobj.Deal_Id__c, null);
        caseobj.status = 'Completed';
        update caseobj;
        TriggerExecutionController.setSkipAllTriggers(false);
        String[] liststr = new String[]{'test@dell.com'};     
            String strTextBody = 'test';
        String strHtmlBody = 'test';
        
        EmailMessage[] listNewEmail = new EmailMessage[0];
        listNewEmail.add(new EmailMessage(FromAddress = 'test@Dell.com', FromName = 'test', ToAddress = 'test@Dell.com.com',
                                          Subject = 'Sandbox: APPROVAL REQUEST: Deal ID#'+caseObj.Deal_Id__c+'; End User Account Name: Data Load 1004;  Distributor /Reseller Account Name', TextBody = strTextBody, HtmlBody = strHtmlBody, ParentId = caseObj.id, 
                                          Status = '0')); 
        insert listNewEmail;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inboundAttachment = new Messaging.InboundEmail.BinaryAttachment();
        email.subject = '[ '+caseObj.Referrence_Id__c+' ]'+'Sandbox: APPROVAL REQUEST: Deal ID#'+caseObj.Deal_Id__c+'; End User Account Name: Data Load 1004;  Distributor /Reseller Account Name';
        env.fromAddress = 'dell@test.com';
        // set the body of the attachment
        inboundAttachment.body = blob.valueOf('test');
        inboundAttachment.fileName = 'Email_Attachment.txt';
        inboundAttachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { inboundAttachment }; 
            Test.startTest();
        System.assertequals(email.subject.length() > 8, true);
        AttachPartnerRepliesToCase csobj = new AttachPartnerRepliesToCase();
        try {
            Messaging.InboundEmailResult result = csobj.handleInboundEmail(email, env);
        }
        catch (System.Dmlexception e) {
        }
        Test.stopTest();
    }
}