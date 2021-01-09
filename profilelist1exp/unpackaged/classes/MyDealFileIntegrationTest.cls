/*
* Author   : Krishna
* Purpose  : Test class for MyDealFileIntegration
* 
* Revision CR Number   Release No    Date            Modified By     Description
* -------- ---------   ----------    -----------     ------------    -----------
* 1.0      15108       FY18-0203     09-Nov-2017     Krishnakumar    PSA006 - Files to myDeal - create logic
* 2.0                  0202          09-Dec-2019     venu            Implimented TestDataFactory   
*/
@isTest
public class MyDealFileIntegrationTest{
    
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
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
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        /*Contact con = new Contact(FirstName='test'+System.currentTimeMillis(),LastName='Test2'+System.currentTimeMillis(),Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
MailingCountry='test',AccountId=listAccTdf[0].Id,Phone='12345');
insert con;
*/
        list<contact> listConTdf=TestDataFactory.createNContacts(1);
        listConTdf[0].AccountId=listAccTdf[0].Id;
        insert listConTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        listOppTdf[0].Quest_Software_Contact__c= listConTdf[0].id;
        insert listOppTdf;
        /* String strCSSRECORDTYPEID = schema.SObjectType.Support_Request__c.getRecordTypeInfosByName().get('Request Custom Service Support').getRecordTypeId();
Support_Request__c objSupportReq1= new Support_Request__c(RecordTypeId = strCSSRECORDTYPEID, Receive_Notification__c = 'Yes', Opportunity__c = listOppTdf[0].Id,
Requestor_Comments__c = 'testComment', Specialist_Role__c = 'testRole',Engagement_Time_Frame__c=Date.today(),
Support_Owner__c = UserInfo.getUserId(), Solution_Architect__c = 'Yes', Customer_Contact_InformationName__c = con.Id,
Support_Owner_Team_Role__c = 'Services Intake Manager',Status__c='New',Project_Type__c='CWS',Project_Duration_months__c =1,
Suggested_Delivery_Method__c='Custom',Decision_Date__c=Date.today(),Primary_Work_Delivery_Language__c='Spanish');
ProcessFlowTriggerController.isTest = true;
insert objSupportReq1;
*/
        list<Support_Request__c> listSupReqTdf=TestDataFactory.createNSupportRequests(1,'Request Solution Operation Center Support');
        listSupReqTdf[0].Opportunity__c = listOppTdf[0].Id;
        listSupReqTdf[0].Customer_Contact_InformationName__c =listConTdf[0].Id;
        listSupReqTdf[0].Support_Owner__c = UserInfo.getUserId();
        listSupReqTdf[0].Status__c='New';
        insert listSupReqTdf;
        
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
    
    private static Opportunity objOppty;
    private static Support_Request__c objSupportReq;
    /*private static void init(){
TriggerExecutionController.setSkipAllTriggers(true);
Account acc = new Account(Name='testAccount'); 
insert acc;

Contact con = new Contact(FirstName='test'+System.currentTimeMillis(),LastName='Test2'+System.currentTimeMillis(),Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
MailingCountry='test',AccountId=acc.Id,Phone='12345');
insert con;

objOppty = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', RecordTypeId = '012300000004zf2AAA', CurrencyIsoCode = 'USD', Type = 'Renewal',
CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution',
StageName = 'Plan - 1%',Forecast_Category_Override__c ='Omitted',Quest_Software_Contact__c= con.id);
insert objOppty;
String CSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);
objSupportReq= new Support_Request__c(RecordTypeId = CSS_RECORDTYPEID, Receive_Notification__c = 'Yes', Opportunity__c = objOppty.Id,
Requestor_Comments__c = 'testComment', Specialist_Role__c = 'testRole',Engagement_Time_Frame__c=Date.today(),
Support_Owner__c = UserInfo.getUserId(), Solution_Architect__c = 'Yes', Customer_Contact_InformationName__c = con.Id,
Support_Owner_Team_Role__c = 'Services Intake Manager',Status__c='New',Project_Type__c='CWS',Project_Duration_months__c =1,
Suggested_Delivery_Method__c='Custom',Decision_Date__c=Date.today(),Primary_Work_Delivery_Language__c='Spanish');
ProcessFlowTriggerController.isTest = true;
insert objSupportReq;
TriggerExecutionController.setSkipAllTriggers(false);
}
*/
    static testMethod void myDealFileInsertTest(){
        //init();
        objOppty=[select id from Opportunity Limit 1];
        Support_Request__c objSupportReq=[select id from Support_Request__c Limit 1];
        Test.StartTest();
        SuppReqMyDealIntegration.REQUIRE_CALLOUT = true;
        Blob blbobFile=Blob.valueOf('Unit Test Attachment Body');
        
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.Title = 'TestFile';
        testContentInsert.VersionData =blbobFile;      
        testContentInsert.PathOnClient ='/';     
        testContentInsert.origin = 'H'; 
        insert testContentInsert;     
        
        ContentVersion testContent = [SELECT id,contentdocumentid FROM ContentVersion where id =:testContentInsert.id];
        List<ContentDocumentLink> listDocLinks = new List<ContentDocumentLink>();
        ContentDocumentLink objDocLink1=new ContentDocumentLink();
        objDocLink1.LinkedEntityId=objOppty.id;
        objDocLink1.ShareType= 'V';
        objDocLink1.ContentDocumentId=testContent.contentdocumentid;
        listDocLinks.add(objDocLink1);
        
        ContentDocumentLink objDocLink2=new ContentDocumentLink();
        objDocLink2.LinkedEntityId=objSupportReq.id;
        objDocLink2.ShareType= 'V';
        objDocLink2.ContentDocumentId=testContent.contentdocumentid;
        listDocLinks.add(objDocLink2);
        
        insert listDocLinks;
        Test.StopTest();
        System.assertEquals(true,SuppReqMyDealIntegration.REQUIRE_CALLOUT);
    }
    static testMethod void myDealFileDeleteTest(){
        // init();
        objOppty=[select id from Opportunity Limit 1];
        Support_Request__c objSupportReq=[select id from Support_Request__c Limit 1];
        List<Id> listContentDocId = new List<Id>();
        SuppReqMyDealIntegration.REQUIRE_CALLOUT = false;  
        Blob blbobFile=Blob.valueOf('Unit Test Attachment Body');
        
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.Title = 'TestFile';
        testContentInsert.VersionData =blbobFile;      
        testContentInsert.PathOnClient ='/';     
        testContentInsert.origin = 'H'; 
        insert testContentInsert;     
        
        ContentVersion testContent = [SELECT id,contentdocumentid FROM ContentVersion where id =:testContentInsert.id];
        List<ContentDocumentLink> listDocLinks = new List<ContentDocumentLink>();
        ContentDocumentLink objDocLink1=new ContentDocumentLink();
        objDocLink1.LinkedEntityId=objOppty.id;
        objDocLink1.ShareType= 'V';
        objDocLink1.ContentDocumentId=testContent.contentdocumentid;
        listDocLinks.add(objDocLink1);
        
        insert listDocLinks;
        Test.StartTest();
        SuppReqMyDealIntegration.REQUIRE_CALLOUT = true;  
        ContentDocumentLink objDocLink = [SELECT id,ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:objOppty.id];
        listContentDocId.add(objDocLink.ContentDocumentId);
        List<ContentDocument> listContDoc = [SELECT id FROM ContentDocument where id in :listContentDocId];
        delete objDocLink;
        System.assertEquals(true,SuppReqMyDealIntegration.REQUIRE_CALLOUT);
        SuppReqMyDealIntegration.REQUIRE_CALLOUT = true; 
        delete listContDoc ;
        Test.StopTest();  
    }
    static testMethod void myDealFileRenameTest(){
        //init();
        objOppty=[select id from Opportunity Limit 1];
        Support_Request__c objSupportReq=[select id from Support_Request__c Limit 1];
        List<Id> listContentDocId = new List<Id>();
        SuppReqMyDealIntegration.REQUIRE_CALLOUT = false;  
        Blob blbobFile=Blob.valueOf('Unit Test Attachment Body');
        
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.Title = 'TestFile';
        testContentInsert.VersionData =blbobFile;      
        testContentInsert.PathOnClient ='/';     
        testContentInsert.origin = 'H'; 
        insert testContentInsert;     
        
        Test.StartTest();
        ContentVersion testContent = [SELECT id,contentdocumentid FROM ContentVersion where id =:testContentInsert.id];
        List<ContentDocumentLink> listDocLinks = new List<ContentDocumentLink>();
        ContentDocumentLink objDocLink1=new ContentDocumentLink();
        objDocLink1.LinkedEntityId=objOppty.id;
        objDocLink1.ShareType= 'V';
        objDocLink1.ContentDocumentId=testContent.contentdocumentid;
        listDocLinks.add(objDocLink1);
        insert listDocLinks;
        testContent.Title = 'TestFile123';
        SuppReqMyDealIntegration.REQUIRE_CALLOUT = true; 
        Update testContent;
        Test.StopTest();
        System.assertEquals(true,SuppReqMyDealIntegration.REQUIRE_CALLOUT);
    }
}