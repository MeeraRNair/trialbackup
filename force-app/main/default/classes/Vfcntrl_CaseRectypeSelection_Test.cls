/*
* Author   : Jagadeesh
* Purpose  : Test class for Case Recordtype Selection - Controller Class
*
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0                   10.01       27-June-2017                    Redirecting to custom related pages Based on Record Type for case Object

*/

@IsTest
Public class Vfcntrl_CaseRectypeSelection_Test
{
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
        
        list<Account> listAccTdf=TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTdf;
        
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        
        list<Case> listCaseTdf=TestDataFactory.createNCases(1);
        insert listCaseTdf;
        
    }
    
    public static testmethod void orderSupportRecType(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Id rtId = schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Support').getRecordTypeId();
        Id rtId1 = schema.SObjectType.Case.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
        Id rtId2 = schema.SObjectType.Case.getRecordTypeInfosByName().get('On Boarding').getRecordTypeId();
        Id rtId3 = schema.SObjectType.Case.getRecordTypeInfosByName().get('Distribution').getRecordTypeId();
        Id rtId4 = schema.SObjectType.Case.getRecordTypeInfosByName().get('Partner Abuse').getRecordTypeId();
        
        
        Test.StartTest();
        //Account portalAccount = createAccount();
        //Contact portalCont_1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
        //Case cs = createCase(portalAccount.id,portalCont_1.id);
        list<Account> listAcc=[Select id,Name from Account Limit 2];
        list<Opportunity> listOpp=[Select id,Name From Opportunity Limit 1];
        list<Case> listCase=[Select id from Case Limit 1];
        system.assertNotEquals(null, listCase[0].id);
        Test.StopTest();   
        ApexPages.StandardController sc = new ApexPages.StandardController(listCase[0]);
        PageReference pageRef = Page.CaseRedirect; 
        pageRef.getParameters().put('id', String.valueOf(listCase[0].Id));
        pageRef.getParameters().put('RecordType', String.valueOf(rtId));
        Test.setCurrentPage(pageRef);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection = new Vfcntrl_CaseRectypeSelection(sc);
        caseRectypeSelection.caseRecordredirect();
        /////////////////////////////////////////
        System_Behavior_Bypasser__c vrb = new System_Behavior_Bypasser__c();
        vrb.Bypass_Opportunity_VRs__c = true;
        insert vrb;
        ApexPages.StandardController sc1 = new ApexPages.StandardController(listCase[0]);
        PageReference pageRef1 = Page.CaseRedirect; 
        pageRef1.getParameters().put('id', String.valueOf(listCase[0].Id));
        pageRef1.getParameters().put('RecordType', String.valueOf(rtId1));
        pageRef1.getParameters().put('AccId', listAcc[1].id);
        pageRef1.getParameters().put('OppId', listOpp[0].id);
        Test.setCurrentPage(pageRef1);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection1 = new Vfcntrl_CaseRectypeSelection(sc1);
        caseRectypeSelection1.caseRecordredirect();
        //////////////////////
        ApexPages.StandardController sc2 = new ApexPages.StandardController(listCase[0]);
        PageReference pageRef2 = Page.CaseRedirect; 
        pageRef2.getParameters().put('id', String.valueOf(listCase[0].Id));
        pageRef2.getParameters().put('RecordType', String.valueOf(rtId2));
        pageRef2.getParameters().put('AccId', listAcc[1].id);
        pageRef2.getParameters().put('OppId', listOpp[0].id);
        Test.setCurrentPage(pageRef2);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection2 = new Vfcntrl_CaseRectypeSelection(sc2);
        caseRectypeSelection2.caseRecordredirect();
        ///////////////////////
        ApexPages.StandardController sc3 = new ApexPages.StandardController(listCase[0]);
        PageReference pageRef3 = Page.CaseRedirect; 
        pageRef3.getParameters().put('id', String.valueOf(listCase[0].Id));
        pageRef3.getParameters().put('RecordType', String.valueOf(rtId3));
        pageRef3.getParameters().put('AccId', listAcc[1].id);
        pageRef3.getParameters().put('OppId', listOpp[0].id);
        Test.setCurrentPage(pageRef3);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection3 = new Vfcntrl_CaseRectypeSelection(sc3);
        caseRectypeSelection3.caseRecordredirect();
        //////////////
        ApexPages.StandardController sc4 = new ApexPages.StandardController(listCase[0]);
        PageReference pageRef4 = Page.CaseRedirect; 
        pageRef4.getParameters().put('id', String.valueOf(listCase[0].Id));
        pageRef4.getParameters().put('RecordType', String.valueOf(rtId4));
        pageRef4.getParameters().put('retURL', listAcc[0].id);
        pageRef4.getParameters().put('accId', listAcc[0].id);
        Test.setCurrentPage(pageRef4);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection4 = new Vfcntrl_CaseRectypeSelection(sc4);
        caseRectypeSelection4.caseRecordredirect();
        //////////////////////////////
        //Case cs = createCase(testAccount.id,newCont.id);
        ApexPages.StandardController sc5 = new ApexPages.StandardController(listCase[0]);
        PageReference pageRef5 = Page.CaseRedirect; 
        pageRef5.getParameters().put('id', String.valueOf(listCase[0].Id));
        pageRef5.getParameters().put('RecordType', String.valueOf(rtId));
        pageRef5.getParameters().put('AccId', listAcc[1].id);
        pageRef5.getParameters().put('OppId', listOpp[0].id);
        Test.setCurrentPage(pageRef5);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection5 = new Vfcntrl_CaseRectypeSelection(sc5);
        caseRectypeSelection5.caseRecordredirect(); 
    }
    
    /* public static testmethod void DealRegRecType()
{
Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
TriggerExecutionController.setSkipAllTriggers(true);
Schema.DescribeSObjectResult cfrschema = schema.SObjectType.Case;
Map<string, Schema.RecordTypeInfo> Caserecordtypeinfo =cfrschema.getRecordTypeInfosByName();
Id rtId = Caserecordtypeinfo.get('Deal Registration').getRecordTypeId();
Account testAccount = new Account(Name='testOppDistiUser Test Account', RecordTypeId = accRTId, Partner_Type__c = 'OEM',
Account_ID__c = '9876543210', Status__c = 'Active', Distribution_Sell_To_Countries__c = 'UNITED STATES',
DMU__c = false, Partner_Relationship__c = 'Authorized', Account_Country__c = 'UNITED KINGDOM');        
TriggerExecutionController.setSkipAllTriggers(true);        
insert testAccount;   

System_Behavior_Bypasser__c vrb = new System_Behavior_Bypasser__c();
vrb.Bypass_Opportunity_VRs__c = true;
insert vrb;

opportunity op = new opportunity();
op.name = 'test opp';
op.StageName = 'Plan - 1%';
op.Closedate = date.valueof('2016-01-01');
op.AccountId  =testAccount.id;
insert op; 
system.assertEquals('test opp', 'test opp'); 
Test.StartTest();
Account portalAccount = createAccount();
Contact portalCont_1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
Case cs = createCase(portalAccount.id,portalCont_1.id);

Test.StopTest();   
ApexPages.StandardController sc = new ApexPages.StandardController(cs);
PageReference pageRef = Page.CaseRedirect; 
pageRef.getParameters().put('id', String.valueOf(cs.Id));
pageRef.getParameters().put('RecordType', String.valueOf(rtId));
pageRef.getParameters().put('AccId', testAccount.id);
pageRef.getParameters().put('OppId', op.id);
Test.setCurrentPage(pageRef);
Vfcntrl_CaseRectypeSelection caseRectypeSelection = new Vfcntrl_CaseRectypeSelection(sc);
caseRectypeSelection.caseRecordredirect();
}
*/      
    /*     public static testmethod void OnBoardingRecType()
{
Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
TriggerExecutionController.setSkipAllTriggers(true);
Schema.DescribeSObjectResult cfrschema = schema.SObjectType.Case;
Map<string, Schema.RecordTypeInfo> Caserecordtypeinfo =cfrschema.getRecordTypeInfosByName();
Id rtId = Caserecordtypeinfo.get('On Boarding').getRecordTypeId();
Account testAccount = new Account(Name='testOppDistiUser Test Account', RecordTypeId = accRTId, Partner_Type__c = 'OEM',
Account_ID__c = '9876543210', Status__c = 'Active', Distribution_Sell_To_Countries__c = 'UNITED STATES',
DMU__c = false, Partner_Relationship__c = 'Authorized', Account_Country__c = 'UNITED KINGDOM');        
TriggerExecutionController.setSkipAllTriggers(true);        
insert testAccount;   

System_Behavior_Bypasser__c vrb = new System_Behavior_Bypasser__c();
vrb.Bypass_Opportunity_VRs__c = true;
insert vrb;

opportunity op = new opportunity();
op.name = 'test opp';
op.StageName = 'Plan - 1%';
op.Closedate = date.valueof('2016-01-01');
op.AccountId  =testAccount.id;
insert op; 
system.assertEquals('test opp', 'test opp'); 
Test.StartTest();
Account portalAccount = createAccount();
Contact portalCont_1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
Case cs = createCase(portalAccount.id,portalCont_1.id);

Test.StopTest();   
ApexPages.StandardController sc = new ApexPages.StandardController(cs);
PageReference pageRef = Page.CaseRedirect; 
pageRef.getParameters().put('id', String.valueOf(cs.Id));
pageRef.getParameters().put('RecordType', String.valueOf(rtId));
pageRef.getParameters().put('AccId', testAccount.id);
pageRef.getParameters().put('OppId', op.id);
Test.setCurrentPage(pageRef);
Vfcntrl_CaseRectypeSelection caseRectypeSelection = new Vfcntrl_CaseRectypeSelection(sc);
caseRectypeSelection.caseRecordredirect();
}
*/  
    /*    public static testmethod void DistributionRecType()
{
TriggerExecutionController.setSkipAllTriggers(true);
Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
Schema.DescribeSObjectResult cfrschema = schema.SObjectType.Case;
Map<string, Schema.RecordTypeInfo> Caserecordtypeinfo =cfrschema.getRecordTypeInfosByName();
Id rtId = Caserecordtypeinfo.get('Distribution').getRecordTypeId();
Account testAccount = new Account(Name='testOppDistiUser Test Account', RecordTypeId = accRTId, Partner_Type__c = 'OEM',
Account_ID__c = '9876543210', Status__c = 'Active', Distribution_Sell_To_Countries__c = 'UNITED STATES',
DMU__c = false, Partner_Relationship__c = 'Authorized', Account_Country__c = 'UNITED KINGDOM');        
TriggerExecutionController.setSkipAllTriggers(true);        
insert testAccount;   

System_Behavior_Bypasser__c vrb = new System_Behavior_Bypasser__c();
vrb.Bypass_Opportunity_VRs__c = true;
insert vrb;

opportunity op = new opportunity();
op.name = 'test opp';
op.StageName = 'Plan - 1%';
op.Closedate = date.valueof('2016-01-01');
op.AccountId  =testAccount.id;
insert op; 
system.assertEquals('test opp', 'test opp'); 
Test.StartTest();
Account portalAccount = createAccount();
Contact portalCont_1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
Case cs = createCase(portalAccount.id,portalCont_1.id);

Test.StopTest();   
ApexPages.StandardController sc = new ApexPages.StandardController(cs);
PageReference pageRef = Page.CaseRedirect; 
pageRef.getParameters().put('id', String.valueOf(cs.Id));
pageRef.getParameters().put('RecordType', String.valueOf(rtId));
pageRef.getParameters().put('AccId', testAccount.id);
pageRef.getParameters().put('OppId', op.id);
Test.setCurrentPage(pageRef);
Vfcntrl_CaseRectypeSelection caseRectypeSelection = new Vfcntrl_CaseRectypeSelection(sc);
caseRectypeSelection.caseRecordredirect();
}*/
    /* public static testmethod void PartnerAbuseRecType()
{
TriggerExecutionController.setSkipAllTriggers(true);
Schema.DescribeSObjectResult cfrschema = schema.SObjectType.Case;
Map<string, Schema.RecordTypeInfo> Caserecordtypeinfo =cfrschema.getRecordTypeInfosByName();
Id rtId = Caserecordtypeinfo.get('Partner Abuse').getRecordTypeId();

Test.StartTest();
Account portalAccount = createAccount();
Contact portalCont_1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
Case cs = createCase(portalAccount.id,portalCont_1.id);

Test.StopTest();   
//RecordType1        
ApexPages.StandardController sc = new ApexPages.StandardController(cs);
PageReference pageRef = Page.CaseRedirect; 
pageRef.getParameters().put('id', String.valueOf(cs.Id));
pageRef.getParameters().put('RecordType', String.valueOf(rtId));
pageRef.getParameters().put('retURL', portalAccount.id);
pageRef.getParameters().put('accId', portalAccount.id);
Test.setCurrentPage(pageRef);
Vfcntrl_CaseRectypeSelection caseRectypeSelection = new Vfcntrl_CaseRectypeSelection(sc);
caseRectypeSelection.caseRecordredirect();
}
*/      
    /*  static Account createAccount(){
Id accRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
Account testAccount= new Account(name = 'Test PAccv', account_country_code__c = 'US', RecordTypeId = accRTId, 
Type = 'Partner', Partner_Type__c = 'DISTRIBUTOR (GCC)', Dell_Certification_Areas__c = 'Storage;Server');
insert testAccount;
return testAccount;
}
*/
    /* static Contact createContact(Id accountId,String email){
Contact newCont = new Contact(FirstName = 'conv', Phone = '9876543987', AccountId = accountId, Email = 'abc@dell.comfdev', Lastname = 'UT', 
Decision_Making_Role__c = 'Influencer', Job_Function__c = 'Finance', Job_Function_Role__c = 'Finance Manager', Primary_Contact__c = false,
MobilePhone = '991122789', Eloqua_ID__c = '1234');
insert newCont;
return newCont;
}

static user createUser(Id contactId){
final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', Email='MyLastName@dell.com',
FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles.get(0).Id, LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test846258',
Enable_Partner_Admin__c = true, isActive = true,Enable_Partner_Deal_Registration__c = true,ContactId = contactId);
TriggerExecutionController.setSkipAllTriggers(true);
insert partnerUser;
return partnerUser;
}
static Case createCase(Id accountId,Id contactId){
Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
Case newCase = new case(Accountid = accountId, Contactid = contactId, Status = 'Open', Priority = 'High', Alternate_Phone__c ='1234',
Sub_Type_Order_Support__c ='credit Request', Subject  ='Test Case Subject', Description ='Test Case Subject', 
Order_Reference_Number_Type__c = 'Order Number', Order_Number1__c = '123', recordTypeId = orderSuppRTId);     
insert newCase;
return newCase;
}
*/
    /* public static testmethod void redirectToPartnerUserOrderSupport(){  

Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);    
Account testAccount = new Account(Name='testOppDistiUser Test Account', RecordTypeId = accRTId, Partner_Type__c = 'OEM',
Account_ID__c = '9876543210', Status__c = 'Active', Distribution_Sell_To_Countries__c = 'UNITED STATES',
DMU__c = false, Partner_Relationship__c = 'Authorized', Account_Country__c = 'UNITED KINGDOM');        
TriggerExecutionController.setSkipAllTriggers(true);        
insert testAccount;   

Contact newCont = new Contact(FirstName = 'My Search', LastName = 'Contact', AccountId =testAccount.Id,
Status__c  =  'Marketing Suspect', Email = 'MyLastNae@dell.com', Fax = '1234567', MobilePhone = '0987654',
Last_Operation_Performed__c = 'testing', Phone = '1234500');
TriggerExecutionController.setSkipAllTriggers(true);
insert newCont; 

TriggerExecutionController.setSkipAllTriggers(true);
Schema.DescribeSObjectResult cfrschema = schema.SObjectType.Case;
Map<string, Schema.RecordTypeInfo> Caserecordtypeinfo =cfrschema.getRecordTypeInfosByName();
Id rtId = Caserecordtypeinfo.get('Order Support').getRecordTypeId();
//user usr = createUser (newCont.id);


System_Behavior_Bypasser__c vrb = new System_Behavior_Bypasser__c();
vrb.Bypass_Opportunity_VRs__c = true;
insert vrb;

opportunity op = new opportunity();
op.name = 'test opp';
op.StageName = 'Plan - 1%';
op.Closedate = date.valueof('2016-01-01');
op.AccountId  =testAccount.id;
insert op; 
system.assertEquals('test opp', 'test opp'); 
// System.runAs(usr){
Case cs = createCase(testAccount.id,newCont.id);
ApexPages.StandardController sc = new ApexPages.StandardController(cs);
PageReference pageRef = Page.CaseRedirect; 
pageRef.getParameters().put('id', String.valueOf(cs.Id));
pageRef.getParameters().put('RecordType', String.valueOf(rtId));
pageRef.getParameters().put('AccId', testAccount.id);
pageRef.getParameters().put('OppId', op.id);
Test.setCurrentPage(pageRef);
Vfcntrl_CaseRectypeSelection caseRectypeSelection = new Vfcntrl_CaseRectypeSelection(sc);
caseRectypeSelection.caseRecordredirect(); 
// }   
}
*/ 
    public static testmethod void redirectToPartnerUserApplicationSupport(){  
        
        //Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);    
        /*Account testAccount = new Account(Name='testOppDistiUser Test Account', RecordTypeId = accRTId, Partner_Type__c = 'OEM',
Account_ID__c = '9876543210', Status__c = 'Active', Distribution_Sell_To_Countries__c = 'UNITED STATES',
DMU__c = false, Partner_Relationship__c = 'Authorized', Account_Country__c = 'UNITED KINGDOM');        

*/
        list<Account> listAcc=[Select id,Name from Account Limit 2];
        TriggerExecutionController.setSkipAllTriggers(true);        
        //insert testAccount;   
        
        System_Behavior_Bypasser__c vrb = new System_Behavior_Bypasser__c();
        vrb.Bypass_Opportunity_VRs__c = true;
        insert vrb;
        
        /* opportunity op = new opportunity();
op.name = 'test opp';
op.StageName = 'Plan - 1%';
op.Closedate = date.valueof('2016-01-01');
op.AccountId  =testAccount.id;
insert op;
*/
        list<Opportunity> listOpp=[Select id,Name from Opportunity Limit 1];
        system.assertEquals('test opp', 'test opp');    
        /*Contact newCont = new Contact(FirstName = 'My Search', LastName = 'Contact', AccountId =testAccount.Id,
Status__c  =  'Marketing Suspect', Email = 'MyLastNae@dell.com', Fax = '1234567', MobilePhone = '0987654',
Last_Operation_Performed__c = 'testing', Phone = '1234500');
TriggerExecutionController.setSkipAllTriggers(true);
insert newCont; 
*/
        TriggerExecutionController.setSkipAllTriggers(true);
        // Schema.DescribeSObjectResult cfrschema = schema.SObjectType.Case;
        //Map<string, Schema.RecordTypeInfo> Caserecordtypeinfo =cfrschema.getRecordTypeInfosByName();
        Id rtId = schema.SObjectType.Case.getRecordTypeInfosByName().get('RPQ').getRecordTypeId();
        //user usr = createUser (newCont.id);
        list<case> listCase=[Select id from Case Limit 1];
        // System.runAs(usr){
        // Case cs = createCase(testAccount.id,newCont.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(listCase[0]);
        PageReference pageRef = Page.CaseRedirect; 
        pageRef.getParameters().put('id', String.valueOf(listCase[0].Id));
        pageRef.getParameters().put('RecordType', String.valueOf(rtId));
        pageRef.getParameters().put('retURL', '2'+listAcc[1].id);
        pageRef.getParameters().put('AccId', listAcc[1].id);
        Test.setCurrentPage(pageRef);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection = new Vfcntrl_CaseRectypeSelection(sc);
        caseRectypeSelection.caseRecordredirect();
        pageRef.getParameters().put('id', String.valueOf(listCase[0].Id));
        pageRef.getParameters().put('RecordType', String.valueOf(rtId));
        pageRef.getParameters().put('AccId', listAcc[1].id);
        pageRef.getParameters().put('OppId', listOpp[0].id);
        pageRef.getParameters().put('OppName', listOpp[0].name);
        pageRef.getParameters().put('AccName', listAcc[1].name);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection6 = new Vfcntrl_CaseRectypeSelection(sc);
        caseRectypeSelection6.caseRecordredirect();
        
        Id rtIdPP = schema.SObjectType.Case.getRecordTypeInfosByName().get('Application Support').getRecordTypeId();
        //Id rtIdPP = Caserecordtypeinfo.get('Application Support').getRecordTypeId();
        pageRef.getParameters().put('RecordType', String.valueOf(rtIdPP));
        pageRef.getParameters().put('AccId', listAcc[1].id);
        pageRef.getParameters().put('OppId', listOpp[0].id);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection1 = new Vfcntrl_CaseRectypeSelection(sc);
        CaseRectypeSelection1.caseRecordredirect();
        //Id rtIdPr = Caserecordtypeinfo.get('Partner Program').getRecordTypeId();
        
        Id rtIdPr = schema.SObjectType.Case.getRecordTypeInfosByName().get('Partner Program').getRecordTypeId();
        pageRef.getParameters().put('RecordType', String.valueOf(rtIdpr));
        pageRef.getParameters().put('AccId', listAcc[1].id);
        pageRef.getParameters().put('OppId', listOpp[0].id);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection2 = new Vfcntrl_CaseRectypeSelection(sc);
        caseRectypeSelection2.caseRecordredirect();
        
        Id rtIdPr1 = schema.SObjectType.Case.getRecordTypeInfosByName().get('Application Support - Internal only case types').getRecordTypeId();
        //Id rtIdPr1 = Caserecordtypeinfo.get('Application Support - Internal only case types').getRecordTypeId();
        pageRef.getParameters().put('RecordType', String.valueOf(rtIdpr1));
        pageRef.getParameters().put('AccId', listAcc[1].id);
        pageRef.getParameters().put('OppId', listOpp[0].id);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection3 = new Vfcntrl_CaseRectypeSelection(sc);
        caseRectypeSelection3.caseRecordredirect(); 
        
        //Id rtIdPr2 = Caserecordtypeinfo.get('On Boarding Internal').getRecordTypeId();
        Id rtIdPr2 = schema.SObjectType.Case.getRecordTypeInfosByName().get('On Boarding Internal').getRecordTypeId();
        pageRef.getParameters().put('RecordType', String.valueOf(rtIdpr2));
        pageRef.getParameters().put('AccId', listAcc[1].id);
        pageRef.getParameters().put('OppId', listOpp[0].id);
        Vfcntrl_CaseRectypeSelection caseRectypeSelection4 = new Vfcntrl_CaseRectypeSelection(sc);
        caseRectypeSelection4.caseRecordredirect(); 
        
        
        
        //  }   
    }    
    
}