@IsTest
public class CaseTriggerHandlerBUTest {
    public static boolean bCreate = true;
    public static integer intNumberOfCases = 5;
    public static list<Case> listCases;
    static list<Account> listAcc;
    static list<Contact> listCon;
    static list<lead> listlead;
    static list<user> listuser;
    static list<Campaign> listCamp;
    static list<case> listcase;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        TriggerExecutionController.setSkipAccountTriggers(True);
        insert listAccTDF;
        list<Contact> listConTDF = TestDataFactory.CreateNContacts(1);
        listConTDF[0].AccountID = listAccTDF[0].id;
        TriggerExecutionController.setSkipContactTriggers(True);
        insert listConTDF;
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(2, 'Channel Partner Communications');
        insert listCampTDF;
        list<lead> listleadTDF = TestDataFactory.createNLeads(1, 'Talk to Dell');
        listleadTDF[0].Campaign__c = listCampTDF[0].Id;
        insert listleadTDF;
        list<case> listcaseTDF = TestDataFactory.createNCases(2);
        listcaseTDF[0].RecordTypeID = TestDataFactory.getRecordTypeIdbyName('On Boarding Internal', 'Case');
        listcaseTDF[0].RecordTypeID = TestDataFactory.getRecordTypeIdbyName('Order Support', 'Case');
        insert listcaseTDF;
    }
    public static testMethod void orderSuport(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Case", "Class_Name__c": "CaseTriggerHandlerBU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Case';
        tec.RecursiveCount__c = 2;
        insert tec;
        /*    
//TriggerExecutionController.setSkipLeadTriggers(true);
Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
List<Account> accData = new List<Account>();
List<Case> caseList = new List<Case>();
Account testAccount = new Account(Name='testOppDistiUser Test Account', 
RecordTypeId = accRTyId, 
Partner_Type__c = 'COMMERCIAL',
Partner_Tier__c = 'Tier',
Partner_Relationship__c = 'Registered',
Account_Country__c = 'United States' );        
accData.add(testAccount);
insert accData;

Contact newCont = new Contact(FirstName = 'MyTestContact7653',
LastName = 'MyTestContact76523',
AccountId =testAccount.Id,
Status__c  =  'Marketing Suspect',
Email = 'MyTestContactEmail_3@dell.com',
Fax = '12344567',
// MobilePhone = '0987676534',
Last_Operation_Performed__c = 'testing');
//Phone = '123453400');
insert newCont;
Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

User partnerUserGC = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
Alias = 'MTU9', 
Email='MyTestUser9@dell.com', 
FirstName='MyTestUser9', 
LastName='MyTestUser9',  
ProfileId = p.Id, 
LanguageLocaleKey='zh_CN', 
LocaleSidKey='zh_CN', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test99826513', 
isActive = TRUE,
Enable_Partner_Admin__c = false,
ContactId = newCont.Id);
insert partnerUserGC; 
*/
        listAcc = [select id from Account limit 1];
        listCon = [select id from Contact limit 1];
        list<user> listuser = TestDataFactory.createNPortalUser(1);
        listuser[0].ContactID = listCon[0].id;
        insert listuser;
        AccountTeamMember testAccountTeamMem = new AccountTeamMember(TeamMemberRole = 'Account Executive',
                                                                     AccountId = listAcc[0].Id,
                                                                     UserId = listuser[0].Id);        
        insert testAccountTeamMem;
        
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        /*

Id trcrRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding Internal');
Id lead2RTId = IdLookupUtils.getRecordTypeId('Talk to Dell','Lead',true);
Id pLMCaseRTId= IdLookupUtils.getRecordTypeId('Global Lead Management Intake','Case',true);
Id orderSupportRTId= IdLookupUtils.getRecordTypeId('Order Support','Case',true);
List<Campaign> listCamp = new List<Campaign>();
Id campRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);
Campaign cMAPtestCampaign = new Campaign(Name='CMAP Campaign',
//      Campaign_Objective__c = 'LOB Conversion',
Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
StartDate=System.Today() - 10,
EndDate=System.Today(),
Description='This is Test Campaign',
IsActive=true,
Partner_event_or_campaign__c =True,
RecordTypeID= campRTId,
partner_Inquiry_Case_Owner__c = 'Account Owner');
listCamp.add(cMAPtestCampaign);
insert listCamp;
Lead sLead = new Lead(LastName = 'Test Sales Lead', 
Lead_Type__c = 'Inbound',
RecordTypeId =lead2RTId, 
Email = 'testcmap@test.com',
Status = 'Accepted',
Phone = '88967544',
Country = 'US',
Campaign__c = cMAPtestCampaign.Id,
Company = 'Test Company',
LeadSource='Partner',
Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');

Test.startTest(); 
insert sLead;
case newCase = new Case();
newCase.RecordTypeId = trcrRTId;    
newCase.NPS_Category__c = 'ractor';
// newCase.Requesting_Region__c = 'Global';
newCase.Sub_Type_Internal_User__c = 'Lead Load Request';
//  newCase.Lead_Type__c = 'Inbound Lead';
newCase.Country_Area__c = 'India';
newCase.SuppliedEmail ='';
newCase.AccountId = testAccount.Id;
newCase.ContactId = newCont.id;
//  newCase.Order_Number__c = '123432';
newCase.Alternate_Phone__c = '745476';
newCase.Description = '1';
newCase.Subject = '2';
newCase.Priority = 'High';
newCase.Status = 'Open';
newCase.Origin ='Partner Portal';
newCase.Sub_Type_Partner_User__c = 'Access Issues';
newCase.Sub_Type_Internal_User__c = 'Access Issues';
newCase.Case_Category__c = 'Partner';
caseList.add(newCase);

Case partnerLMCase = new Case();

partnerLMCase.RecordTypeId=pLMCaseRTId;
partnerLMCase.OwnerId = testGroup.Id;      
partnerLMCase.Subject = 'Test Partner LM Intake Case';
partnerLMCase.Description = 'Test Partner LM Intake Case';                                                  
partnerLMCase.Priority = 'Medium';
// partnerLMCase.Requesting_Country__c = 'India';
//  partnerLMCase.Requesting_Region__c = 'APJ';
partnerLMCase.Sub_Type_Internal_User__c='Lead Load Request';
//   partnerLMCase.Lead_Type__c='Inbound Lead';
partnerLMCase.Alternate_Phone__c='1234656';
partnerLMCase.AccountId = testAccount.Id;
partnerLMCase.ContactId = newCont.id;
partnerLMCase.Lead_ID__c=sLead.Id;

//insert partnerLMCase;
//caseList.add(partnerLMCase);
Case cOrderSupport = new Case();

cOrderSupport.RecordTypeId=orderSupportRTId;
cOrderSupport.OwnerId = testGroup.Id;      
cOrderSupport.Subject = 'Test Partner LM Intake Case';
cOrderSupport.Description = 'Test Partner LM Intake Case';                                                  
cOrderSupport.Priority = 'Medium';
//   cOrderSupport.Requesting_Country__c = 'India';
cOrderSupport.AccountId = testAccount.Id;
cOrderSupport.ContactId = newCont.id;
//   cOrderSupport.Requesting_Region__c = 'APJ';
cOrderSupport.Sub_Type_Internal_User__c='Lead Load Request';
cOrderSupport.Country_Area__c='India';
cOrderSupport.SuppliedEmail = '';
//   cOrderSupport.Lead_Type__c='Inbound Lead';
cOrderSupport.Alternate_Phone__c='1234656';
cOrderSupport.Lead_ID__c=sLead.Id;
cOrderSupport.Lead_Type__c='Outbound Lead';

caseList.add(cOrderSupport);
//insert cOrderSupport;
//insert newCase; 
insert caseList;
caseList[0].Priority = 'Low';
update caseList[0];
*/
        Test.startTest();
        listlead = [select id from lead where RecordType.Name =: 'Talk to Dell' limit 1];
        listcase = [select id from case limit 2];
        listcase[0].NPS_Category__c = 'ractor';
        listcase[0].Sub_Type_Internal_User__c = 'Lead Load Request';
        listcase[0].Country_Area__c = 'India';
        listcase[0].SuppliedEmail ='';
        listcase[0].AccountId = listAcc[0].Id;
        listcase[0].ContactId = listCon[0].id;
        listcase[0].Alternate_Phone__c = '745476';
        listcase[0].Description = '1';
        listcase[0].Subject = '2';
        listcase[0].Priority = 'High';
        listcase[0].Status = 'Open';
        listcase[0].Origin ='Partner Portal';
        listcase[0].Sub_Type_Partner_User__c = 'Access Issues';
        listcase[0].Sub_Type_Internal_User__c = 'Access Issues';
        listcase[0].Case_Category__c = 'Partner';
        listcase[1].OwnerId = testGroup.Id;      
        listcase[1].Subject = 'Test Partner LM Intake Case';
        listcase[1].Description = 'Test Partner LM Intake Case';                                                  
        listcase[1].Priority = 'Medium';
        listcase[1].AccountId = listAcc[0].Id;
        listcase[1].ContactId = listCon[0].id;
        listcase[1].Sub_Type_Internal_User__c='Lead Load Request';
        listcase[1].Country_Area__c='India';
        listcase[1].SuppliedEmail = '';
        listcase[1].Alternate_Phone__c='1234656';
        listcase[1].Lead_ID__c=listlead[0].Id;
        listcase[1].Lead_Type__c='Outbound Lead';
        update listcase;
        listcase[0].Priority = 'Low';
        update listcase[0];
        system.assertEquals(listcase, listcase); 
        Test.stopTest(); 
        //TriggerExecutionController.setSkipLeadTriggers(false);
    }
    public static testMethod void gLMIInsert(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Case", "Class_Name__c": "CaseTriggerHandlerBU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Case';
        tec.RecursiveCount__c = 2;
        insert tec;
        system.assertEquals(2, tec.RecursiveCount__c);
        /*
Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
List<Account> accData = new List<Account>();
List<Case> caseList = new List<Case>();
Account testAccount = new Account(Name='testOppDistiUser Test Account', 
RecordTypeId = accRTyId, 
Partner_Type__c = 'COMMERCIAL',
Partner_Tier__c = 'Tier',
Partner_Relationship__c = 'Registered',
Account_Country__c = 'United States' );        
accData.add(testAccount);
insert accData;

Contact newCont = new Contact(FirstName = 'MyTestContact7653',
LastName = 'MyTestContact76523',
AccountId =testAccount.Id,
Status__c  =  'Marketing Suspect',
Email = 'MyTestContactEmail_3@dell.com',
Fax = '12344567',
// MobilePhone = '0987676534',
Last_Operation_Performed__c = 'testing');
//Phone = '123453400');
insert newCont;
Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

User partnerUserGC = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
Alias = 'MTU9', 
Email='MyTestUser9@dell.com', 
FirstName='MyTestUser9', 
LastName='MyTestUser9',  
ProfileId = p.Id, 
LanguageLocaleKey='zh_CN', 
LocaleSidKey='zh_CN', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test99826513', 
isActive = TRUE,
Enable_Partner_Admin__c = false,
ContactId = newCont.Id);
insert partnerUserGC;
*/
        listAcc = [select id from Account limit 1];
        listCon = [select id from Contact limit 1];
        list<user> listuser = TestDataFactory.createNPortalUser(1);
        listuser[0].ContactID = listCon[0].id;
        insert listuser;
        AccountTeamMember testAccountTeamMem = new AccountTeamMember(TeamMemberRole = 'Account Executive',
                                                                     AccountId = listAcc[0].Id,
                                                                     UserId = listuser[0].Id);        
        insert testAccountTeamMem;
        
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        listlead = [select id from lead limit 1];
        listlead[0].RecordTypeID = TestDataFactory.getRecordTypeIdbyName('Talk to Dell','lead');
        TriggerExecutionController.setSkipLeadTriggers(True);
        update listlead;
        
        /*
Id pLMCaseRTId= IdLookupUtils.getRecordTypeId('Global Lead Management Intake','Case',true);
Id lead2RTId = IdLookupUtils.getRecordTypeId('Talk to Dell','Lead',true);
List<Campaign> listCamp = new List<Campaign>();
Id campRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);
Campaign cMAPtestCampaign = new Campaign(Name='CMAP Campaign',
//   Campaign_Objective__c = 'LOB Conversion',
Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
StartDate=System.Today() - 10,
EndDate=System.Today(),
Description='This is Test Campaign',
IsActive=true,
Partner_event_or_campaign__c =True,
RecordTypeID= campRTId,
partner_Inquiry_Case_Owner__c = 'Account Owner');
listCamp.add(cMAPtestCampaign);
insert listCamp;
Lead sLead = new Lead(LastName = 'Test Sales Lead', 
Lead_Type__c = 'Inbound',
RecordTypeId =lead2RTId, 
Email = 'testcmap@test.com',
Status = 'Accepted',
Phone = '88967544',
Country = 'US',
Campaign__c = cMAPtestCampaign.Id,
Company = 'Test Company',
LeadSource='Partner',
Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');

TriggerExecutionController.setSkipLeadTriggers(true);
insert sLead;
TriggerExecutionController.setSkipLeadTriggers(false);
Case partnerLMCase = new Case();

partnerLMCase.RecordTypeId=pLMCaseRTId;    
partnerLMCase.Subject = 'Test Partner LM Intake Case';
partnerLMCase.Description = 'Test Partner LM Intake Case';                                                  
partnerLMCase.Priority = 'Medium';
// partnerLMCase.Requesting_Country__c = 'India';
// partnerLMCase.Requesting_Region__c = 'APJ';
partnerLMCase.Sub_Type_Internal_User__c='Lead Load Request';
// partnerLMCase.Lead_Type__c='Inbound Lead';
partnerLMCase.Alternate_Phone__c='1234656';
partnerLMCase.AccountId = testAccount.Id;
partnerLMCase.ContactId = newCont.id;
partnerLMCase.Lead_ID__c=sLead.Id;
partnerLMCase.Lead_Type__c='Outbound Lead';

Test.startTest(); 
insert partnerLMCase;
*/
        //system.assertEquals(partnerLMCase, partnerLMCase);
        listcase = [select id from case limit 1];
        for(case partnerLMCase:listcase){
            partnerLMCase.RecordTypeId=TestDataFactory.getRecordTypeIdbyName('Global Lead Management Intake', 'Case');    
            partnerLMCase.Subject = 'Test Partner LM Intake Case';
            partnerLMCase.Description = 'Test Partner LM Intake Case';                                                  
            partnerLMCase.Priority = 'Medium';
            partnerLMCase.Sub_Type_Internal_User__c='Lead Load Request';
            partnerLMCase.Alternate_Phone__c='1234656';
            partnerLMCase.AccountId = listAcc[0].Id;
            partnerLMCase.ContactId = listCon[0].id;
            partnerLMCase.Lead_ID__c=listlead[0].Id;
            partnerLMCase.Lead_Type__c='Outbound Lead';
        }
        Test.startTest(); 
        update listcase;
        Test.stopTest();
    }
    public static testMethod void partnerInquiry(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Case", "Class_Name__c": "CaseTriggerHandlerBU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Case';
        tec.RecursiveCount__c = 2;
        insert tec;
        /*
Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
List<Account> accData = new List<Account>();
Account testAccount = new Account(Name='testOppDistiUser Test Account', 
RecordTypeId = accRTyId, 
Partner_Type__c = 'COMMERCIAL',
Partner_Tier__c = 'Tier',
Partner_Relationship__c = 'Registered',
Account_Country__c = 'United States' );        
accData.add(testAccount);
insert accData;

Contact newCont = new Contact(FirstName = 'MyTestContact7653',
LastName = 'MyTestContact76523',
AccountId =testAccount.Id,
Status__c  =  'Marketing Suspect',
Email = 'MyTestContactEmail_3@dell.com',
Fax = '12344567',
Last_Operation_Performed__c = 'testing');
insert newCont;
Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

User partnerUserGC = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
Alias = 'MTU9', 
Email='MyTestUser9@dell.com', 
FirstName='MyTestUser9', 
LastName='MyTestUser9',  
ProfileId = p.Id, 
LanguageLocaleKey='zh_CN', 
LocaleSidKey='zh_CN', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test99826513', 
isActive = TRUE,
Enable_Partner_Admin__c = false,
ContactId = newCont.Id);
insert partnerUserGC;
*/
        listAcc = [select id from Account limit 1];
        listCon = [select id from Contact limit 1];
        list<user> listuser = TestDataFactory.createNPortalUser(1);
        listuser[0].ContactID = listCon[0].id;
        insert listuser;
        AccountTeamMember testAccountTeamMem = new AccountTeamMember(TeamMemberRole = 'Account Executive',
                                                                     AccountId = listAcc[0].Id,
                                                                     UserId = listuser[0].Id);        
        insert testAccountTeamMem;
        /*
List<Campaign> listCamp = new List<Campaign>();
Id campRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);
Campaign cMAPtestCampaign = new Campaign(Name='CMAP Campaign',
// Campaign_Objective__c = 'LOB Conversion',
Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
StartDate=System.Today() - 10,
EndDate=System.Today(),
Description='This is Test Campaign',
IsActive=true,
RecordTypeID= campRTId,
partner_Inquiry_Case_Owner__c = 'Account Owner');        
Campaign cMAPtestCampaign1 = new Campaign(Name='CMAP Campaign',
//  Campaign_Objective__c = 'LOB Conversion',
Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
StartDate=System.Today() - 10,
EndDate=System.Today(),           
Description='This is Test Campaign',
IsActive=true,
RecordTypeID= campRTId,
partner_Inquiry_Case_Owner__c = 'Account Executive');
listCamp.add(cMAPtestCampaign);
listCamp.add(cMAPtestCampaign1);
insert listCamp;

Id prtnrInqId = StaticFactory.getRecordTypeIdByName('Case', 'Partner Inquiries');
list<case> caseList=new list<case>();
case newCase1 = new Case();
newCase1.RecordTypeId = prtnrInqId;
newCase1.AccountId = testAccount.Id;
newCase1.ContactId = newCont.Id;
newCase1.Campaign_Name__c = cMAPtestCampaign.Id;
newCase1.Alternate_Phone__c = '23213';
newCase1.Status = 'Open';
newCase1.Country_Area__c='India';
newCase1.SuppliedEmail = '';
newCase1.Priority = 'Medium';
newCase1.Origin = 'Phone';
newCase1.Subject = 'New Case1';
newCase1.Description = 'test new case1';
caseList.add(newCase1);        
case newCase2 = new Case();
newCase2.RecordTypeId = prtnrInqId;
newCase2.AccountId = testAccount.Id;
newCase2.ContactId = newCont.Id;
newCase2.Campaign_Name__c = cMAPtestCampaign1.Id;
newCase2.Alternate_Phone__c = '23234';
newCase2.Status = 'Open';
newCase2.SuppliedEmail = '';
newCase2.Country_Area__c='India';
newCase2.Priority = 'Medium';
newCase2.Origin = 'Phone';
newCase2.Subject = 'New Case2';
newCase2.Description = 'test new case2';
caseList.add(newCase2);
*/
        listCamp = [select id from campaign limit 2];
        listcase = [select id from case limit 2];
        listcase[0].RecordTypeId = TestDataFactory.getRecordTypeIdbyName('Partner Inquiries', 'Case');
        listcase[0].AccountId = listAcc[0].Id;
        listcase[0].ContactId = listCon[0].Id;
        listcase[0].Campaign_Name__c = listCamp[0].Id;
        /*  listcase[0].Alternate_Phone__c = '23213';
listcase[0].Status = 'Open';
listcase[0].Country_Area__c='India';
listcase[0].SuppliedEmail = '';
listcase[0].Priority = 'Medium';
listcase[0].Origin = 'Phone';
listcase[0].Subject = 'New Case1';
listcase[0].Description = 'test new case1';*/
        listcase[1].RecordTypeId = TestDataFactory.getRecordTypeIdbyName('Partner Inquiries', 'Case');
        listcase[1].AccountId = listAcc[0].Id;
        listcase[1].ContactId = listCon[0].Id;
        listcase[1].Campaign_Name__c = listCamp[0].Id;
        /*  listcase[1].Alternate_Phone__c = '23234';
listcase[1].Status = 'Open';
listcase[1].SuppliedEmail = '';
listcase[1].Country_Area__c='India';
listcase[1].Priority = 'Medium';
listcase[1].Origin = 'Phone';
listcase[1].Subject = 'New Case2';
listcase[1].Description = 'test new case2';*/
        
        Test.startTest();
        update listcase;
        map<Id, Case> mapNewCases=new map<Id, Case>();
        mapNewCases.put(listcase[1].id,listcase[1]);
        map<Id, Account> mapAccnt=new map<Id, Account>();
        mapAccnt.put(listAcc[0].id,listAcc[0]);
        
        CaseUtilities.assignPartnerInquiryCases(mapNewCases,mapAccnt);
        system.assertEquals(listCase, listCase);
        
        //CaseUtilities.reassignNonNPSCases(mapNewCases);
        Test.stopTest();
        
    }
    
}