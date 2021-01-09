/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13274       Sprint 13       27-July-2016    Syidah          To separate test method in a test class from SalesTeamUtil main class
*/   

@isTest 

private class VFCntrlr_UpdateSalesTeamEdit_Test
{ 
    
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
        list<User> listUserTdf=TestDataFactory.createNPortalUser(1);
        insert listUserTdf;
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
    }   
    public static testMethod void testVFCntrlrUpdateSalesTeamEditSave() {
        TriggerExecutionController.setSkipAllTriggers(true); 
        //Test method for the function Save
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamEditSave()');
        PageReference pageRef = Page.edit_salesteammember;
        Test.setCurrentPage(pageRef);
        //Create Test Data 
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        /* Account account=new Account(name='Test Account');
insert account;

RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
Type='Deal/Bid Direct', CloseDate= system.today(), 
Solution_Type__c='Business Processing', 
StageName='Plan - 1%');     

insert testOpportunity;
*/
        //Create Test User Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%'limit 1 ];
        User testUser =  new User(Username='Test' + System.currentTimeMillis() + '@dell.com',
                                  Alias = 'test', 
                                  Email='test'+'@dell.com', 
                                  FirstName='Tfirst', 
                                  LastName='TLast',
                                  ProfileId = userProfile.Id, 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  EmailEncodingKey='UTF-8', 
                                  TimeZoneSidKey='America/Los_Angeles',
                                  Badge_Number__c='TEST12345');
        
        insert testUser;
        list<User> listUser=[Select id from User Limit 1];
        OpportunityTeamMember oppTeamMemb =new OpportunityTeamMember(userId=testUser.Id,
                                                                     TeamMemberRole='Account Executive',
                                                                     opportunityId = listOpp[0].id);
        
        insert oppTeamMemb;             
        
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', OppTeamMemb.Id);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamEdit controller = new VFCntrlr_UpdateSalesTeamEdit();
        controller.setAccess('Read');
        controller.setOwner(false);
        String strnextPage = controller.save().getUrl();
        
        
        system.debug('#### nextPage = ' + strnextPage);
        
        
        
        List<OpportunityTeamMember> listupdatedTeamMemberTest=[select id,OpportunityId,TeamMemberRole,UserId,OpportunityAccessLevel 
                                                               from OpportunityTeamMember where id=:OppTeamMemb.Id];
        
        //Verify that the success page displays
        System.assertEquals('/apex/Update_Sales_Team_Main?id='+listupdatedTeamMemberTest[0].OpportunityId, strnextPage);
        
        
        system.debug('#### listupdatedTeamMemberTest = ' + listupdatedTeamMemberTest);
        
        //Verify the update made
        System.assertEquals(listupdatedTeamMemberTest[0].OpportunityAccessLevel,'Edit');
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamEditSave()');
        ////////////////////////
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listupdatedTeamMemberTest[0].Id);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamEdit controller1 = new VFCntrlr_UpdateSalesTeamEdit();
        controller1.setOwner(false);
        String strnextPage1 = controller1.cancel().getUrl();
        // Verify that the success page displays
        System.assertEquals('/apex/Update_Sales_Team_Main?id='+listupdatedTeamMemberTest[0].OpportunityId , strnextPage1);
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamEditCancel()');
        //////////////////////////
        VFCntrlr_UpdateSalesTeamEdit controller2 = new VFCntrlr_UpdateSalesTeamEdit();
        controller2.setOwner(false);
        List<SelectOption> listoptions=controller2.getAccessLevels();
        OpportunityTeamMember currentTeamMemberfrmFunction2=controller.getCurrentTeamMember();
        System.assertEquals(currentTeamMemberfrmFunction2.id,listupdatedTeamMemberTest[0].id);
        String straccess=controller.getAccess();
        System.debug(straccess);
        boolean bdataavailable=controller.getDataAvailable();
        //OpportunityShare currentShareTest=controller.getCurrentShare();
        boolean bisOwner=controller.getIsOwner();
        //System.assertEquals(currentShareTest.opportunityId,currentTeamMemberListTest[0].OpportunityId);
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamEditgetMethods()');
        ////////////////////////////////
        PageReference pageRef3 = Page.edit_salesteammember;
        Test.setCurrentPage(pageRef3);
        //List<OpportunityTeamMember> currentTeamMemberListTest=[select id,OpportunityId,TeamMemberRole,UserId,OpportunityAccessLevel 
        // from OpportunityTeamMember limit 1];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listupdatedTeamMemberTest[0].Id);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamEdit controller3 = new VFCntrlr_UpdateSalesTeamEdit();
        controller3.setOwner(false);
        controller3.setDataAvailable(false);
        
        Opportunity tempOpp=[select id from Opportunity where id=:listupdatedTeamMemberTest[0].OpportunityId limit 1];
        delete tempOpp;       
        
        String strnextPage3 = controller3.cancel().getUrl();
        // Verify that the success page displays
        System.assertEquals('/006/o', strnextPage3);
        System.debug('#KP:END of testVFCntrlr_UpdateSalesTeamEditCancelNoDataAvailable()');
        /////////////////////
        //Test method for NoDataAvailable
        
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
    /* public static testMethod void testVFCntrlr_UpdateSalesTeamEditCancel() {
TriggerExecutionController.setSkipAllTriggers(true); 
//Create test data
Account account=new Account(name='Test Account');
insert account;

RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
Type='Deal/Bid Direct', CloseDate= system.today(), 
Solution_Type__c='Business Processing', 
StageName='Plan - 1%');     

insert testOpportunity;

//Create Test User Data  
Profile userProfile= [select id,name from profile where name like '%Sales Rep%'limit 1 ];
User testUser =   new User(Username='Test1' + System.currentTimeMillis() + '@dell.com',
Alias = 'test', 
Email='test'+'@dell.com', 
FirstName='Tfirst', 
LastName='TLast',
ProfileId = userProfile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST12345');

insert testUser;
OpportunityTeamMember OppTeamMemb =new OpportunityTeamMember(userId=testUser.Id,
TeamMemberRole='Account Executive',
opportunityId = testOpportunity.id);

insert OppTeamMemb;             


//Test method for the function Cancel
System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamEditCancel()');
PageReference pageRef = Page.edit_salesteammember;
Test.setCurrentPage(pageRef);
//Create Test Data
List<OpportunityTeamMember> currentTeamMemberListTest=[select id,OpportunityId,TeamMemberRole,UserId,OpportunityAccessLevel 
from OpportunityTeamMember limit 1];
// Add parameters to page URL
ApexPages.currentPage().getParameters().put('id', currentTeamMemberListTest[0].Id);
// Instantiate a new controller with all parameters in the page
VFCntrlr_UpdateSalesTeamEdit controller = new VFCntrlr_UpdateSalesTeamEdit();
controller.setOwner(false);
String nextPage = controller.cancel().getUrl();
// Verify that the success page displays
System.assertEquals('/apex/Update_Sales_Team_Main?id='+currentTeamMemberListTest[0].OpportunityId , nextPage);
System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamEditCancel()');

TriggerExecutionController.setSkipAllTriggers(false); 
}*/
    /* public static testMethod void testVFCntrlr_UpdateSalesTeamEditgetMethods() {
TriggerExecutionController.setSkipAllTriggers(true); 
//Create test data
Account account=new Account(name='Test Account');
insert account;

RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
Type='Deal/Bid Direct', CloseDate= system.today(), 
Solution_Type__c='Business Processing', 
StageName='Plan - 1%');     

insert testOpportunity;

//Create Test User Data  
Profile userProfile= [select id,name from profile where name like '%Sales Rep%'limit 1 ];
User testUser =   new User(Username='Test1' + System.currentTimeMillis() + '@dell.com',
Alias = 'test', 
Email='test'+'@dell.com', 
FirstName='Tfirst', 
LastName='TLast',
ProfileId = userProfile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST12345');

insert testUser;
OpportunityTeamMember OppTeamMemb =new OpportunityTeamMember(userId=testUser.Id,
TeamMemberRole='Account Executive',
opportunityId = testOpportunity.id);

insert OppTeamMemb;             


//Test method for getMethods
System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamEditgetMethods()');
PageReference pageRef = Page.edit_salesteammember;
Test.setCurrentPage(pageRef);
//Create Test Data
List<OpportunityTeamMember> currentTeamMemberListTest=[select id,OpportunityId,TeamMemberRole,UserId,OpportunityAccessLevel 
from OpportunityTeamMember limit 1];
// Add parameters to page URL
ApexPages.currentPage().getParameters().put('id', currentTeamMemberListTest[0].Id);
// Instantiate a new controller with all parameters in the page
VFCntrlr_UpdateSalesTeamEdit controller = new VFCntrlr_UpdateSalesTeamEdit();
controller.setOwner(false);
List<SelectOption> options=controller.getAccessLevels();
OpportunityTeamMember currentTeamMemberfrmFunction=controller.getCurrentTeamMember();
System.assertEquals(currentTeamMemberfrmFunction.id,currentTeamMemberListTest[0].id);
String access=controller.getAccess();
System.debug(access);
boolean dataavailable=controller.getDataAvailable();
//OpportunityShare currentShareTest=controller.getCurrentShare();
boolean isOwner=controller.getIsOwner();
//System.assertEquals(currentShareTest.opportunityId,currentTeamMemberListTest[0].OpportunityId);
System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamEditgetMethods()');
TriggerExecutionController.setSkipAllTriggers(false);
}*/
    /* public static testMethod void testVFCntrlr_UpdateSalesTeamEditCancelNoDataAvailable() {
TriggerExecutionController.setSkipAllTriggers(true); 
//Create test data
Account account=new Account(name='Test Account');
insert account;

RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
Type='Deal/Bid Direct', CloseDate= system.today(), 
Solution_Type__c='Business Processing', 
StageName='Plan - 1%');     

insert testOpportunity;

//Create Test User Data  
Profile userProfile= [select id,name from profile where name like '%Sales Rep%'limit 1 ];
User testUser =   new User(Username='Test1' + System.currentTimeMillis() + '@dell.com',
Alias = 'test', 
Email='test'+'@dell.com', 
FirstName='Tfirst', 
LastName='TLast',
ProfileId = userProfile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST12345');

insert testUser;
OpportunityTeamMember OppTeamMemb =new OpportunityTeamMember(userId=testUser.Id,
TeamMemberRole='Account Executive',
opportunityId = testOpportunity.id);

insert OppTeamMemb;             


//Test method for NoDataAvailable
System.debug('#KP:START of testVFCntrlr_UpdateSalesTeamEditCancelNoDataAvailable()');
PageReference pageRef = Page.edit_salesteammember;
Test.setCurrentPage(pageRef);
List<OpportunityTeamMember> currentTeamMemberListTest=[select id,OpportunityId,TeamMemberRole,UserId,OpportunityAccessLevel 
from OpportunityTeamMember limit 1];
// Add parameters to page URL
ApexPages.currentPage().getParameters().put('id', currentTeamMemberListTest[0].Id);
// Instantiate a new controller with all parameters in the page
VFCntrlr_UpdateSalesTeamEdit controller = new VFCntrlr_UpdateSalesTeamEdit();
controller.setOwner(false);
controller.setDataAvailable(false);

Opportunity tempOpp=[select id from Opportunity where id=:currentTeamMemberListTest[0].OpportunityId limit 1];
delete tempOpp;       

String nextPage = controller.cancel().getUrl();
// Verify that the success page displays
System.assertEquals('/006/o', nextPage);
System.debug('#KP:END of testVFCntrlr_UpdateSalesTeamEditCancelNoDataAvailable()');
TriggerExecutionController.setSkipAllTriggers(false);

} */
    public static testMethod void testVFCntrlrUpdateSalesTeamEditSaveNoDataAvailable() {
        TriggerExecutionController.setSkipAllTriggers(true); 
        //Create test data
        /*  Account account=new Account(name='Test Account');
insert account;

RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
Type='Deal/Bid Direct', CloseDate= system.today(), 
Solution_Type__c='Business Processing', 
StageName='Plan - 1%');     

insert testOpportunity;
*/
        list<Opportunity> listOpp=[Select id from Opportunity Limit 1];
        //Create Test User Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%'limit 1 ];
        User testUser =   new User(Username='Test1' + System.currentTimeMillis() + '@dell.com',
                                   Alias = 'test', 
                                   Email='test'+'@dell.com', 
                                   FirstName='Tfirst', 
                                   LastName='TLast',
                                   ProfileId = userProfile.Id, 
                                   LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US', 
                                   EmailEncodingKey='UTF-8', 
                                   TimeZoneSidKey='America/Los_Angeles',
                                   Badge_Number__c='TEST12345');
        
        insert testUser;
        OpportunityTeamMember oppTeamMemb =new OpportunityTeamMember(userId=testUser.Id,
                                                                     TeamMemberRole='Account Executive',
                                                                     opportunityId = listOpp[0].id);
        
        insert oppTeamMemb;             
        
        
        //Test method for NoDataAvailable
        System.debug('#KP:START of testVFCntrlr_UpdateSalesTeamEditSaveNoDataAvailable()');
        PageReference pageRef = Page.edit_salesteammember;
        Test.setCurrentPage(pageRef);
        List<OpportunityTeamMember> listcurrentTeamMemberTest=[select id,OpportunityId,TeamMemberRole,UserId,OpportunityAccessLevel 
                                                               from OpportunityTeamMember limit 1];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listcurrentTeamMemberTest[0].Id);
        ApexPages.currentPage().getParameters().put('oid', listcurrentTeamMemberTest[0].OpportunityId);
        
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamEdit controller = new VFCntrlr_UpdateSalesTeamEdit();
        controller.setOwner(true);
        
        controller.setAccess('Read');    
        
        Opportunity tempOpp=[select id from Opportunity where id=:listcurrentTeamMemberTest[0].OpportunityId limit 1];
        delete tempOpp;       
        
        // Verify that the Save returns null
        System.assertEquals(null, controller.Save());
        System.debug('#KP:END of testVFCntrlr_UpdateSalesTeamEditSaveNoDataAvailable()');
        TriggerExecutionController.setSkipAllTriggers(false);
        
    } 
    
}