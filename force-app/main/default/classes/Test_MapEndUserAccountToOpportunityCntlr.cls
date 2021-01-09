/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/

@isTest(seealldata=false)
private class Test_MapEndUserAccountToOpportunityCntlr{
    static list<Account> listAcc;
    static list<Contact> listCon;
    static list<Opportunity> listOpp;
    //Added custom settings to populate StageName values.
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(2,'Partner Account');
        insert listAccTdf;
        list<Contact> listConTdf=TestDataFactory.createNContacts(2);
        insert listConTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1,'Standard Opportunity');
        insert listOppTdf;
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
    }
    
    /*public static void setupdata(){

List<Account> accList = new List<Account>();
for(integer i=0;i<100;i++){
Account accRecord = new Account();
accRecord.Name = 'TestAccount';
accRecord.Account_Country__c= 'UNITED STATES';
accRecord.BillingStreet = '105 Challenger rd';
accList.add(accRecord);

}
insert accList;
system.assertNotEquals(acclist,null);      
}*/
    
    public static testMethod void testMyController(){
        PageReference pageRef = Page.MapEndUserAccountToOpportunity;
        Test.setCurrentPage(pageRef); 
        listAcc = [select Id from Account limit 1];
        listOpp = [Select Id from Opportunity limit 1];
        system.assertNotEquals(listAcc[0].id, null);
        listOpp[0].CloseDate= System.Now().Date().addDays(180);
        listOpp[0].StageName='Plan - 1%';
        listOpp[0].Partner_Opportunity_Stage__c='Plan - 1%';
        TriggerExecutionController.setSkipOpportunityTriggers(True);    
        TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
        update listOpp[0];
        /*Opportunity oppRecord = new Opportunity (StageName='Plan - 1%',Partner_Opportunity_Stage__c='Plan - 1%',CloseDate= System.Now().Date().addDays(180),
RecordTypeId= '0127000000057ES' ,Name='TestOpportunity' ,End_User_Account_Name__c = 'TestAccount',
End_User_Mailing_Country__c = 'UNITED STATES' , End_User_Mailing_Street__c = '105 Challenger rd', End_User_Email__c='test@test.com');
TriggerExecutionController.setSkipOpportunityTriggers(True);    
TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
insert oppRecord; */      
        MapEndUserAccountToOpportunityController controller = new MapEndUserAccountToOpportunityController(new ApexPages.StandardController(listOpp[0]));      
        controller.Selecteditem = 'Account Details';   
        /*Account accRecord = new Account(Name = 'TestAccount', NameLocal = 'TestAccount1',Account_Country__c= 'UNITED STATES',BillingStreet = '105 Challenger rd',status__c='A');
insert accRecord;
Account accRecord1 = new Account(Name = 'LocalTest', NameLocal = 'TestAccount',Account_Country__c= 'UNITED STATES',BillingStreet = '105 Challenger rd',status__c='A');
insert accRecord1;*/
        Id[] listfixedSearchResults = new Id[]{listAcc[0].Id};
            Test.setFixedSearchResults(listfixedSearchResults);
        controller.getaccounts();
        controller.searchAccounts(); 
        /* controller.first();
controller.last();
controller.next();
controller.previous();    */            
    }
    public static testMethod void testMyController1(){
        listAcc = [select Id from Account limit 1];
        listOpp = [Select Id from Opportunity limit 1];
        system.assertNotEquals(listAcc[0].id, null);
        listOpp[0].CloseDate= System.Now().Date().addDays(180);
        listOpp[0].StageName='Plan - 1%';
        listOpp[0].Partner_Opportunity_Stage__c='Plan - 1%';
        TriggerExecutionController.setSkipOpportunityTriggers(True);    
        TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
        update listOpp[0];
        //List<Account> accList = new List<Account>();
        PageReference pageRef = Page.MapEndUserAccountToOpportunity;
        Test.setCurrentPage(pageRef);      
        /*Opportunity oppRecord = new Opportunity (StageName='Plan - 1%',Partner_Opportunity_Stage__c='Plan - 1%',CloseDate= System.Now().Date().addDays(180),
RecordTypeId= '0127000000057ES',Name='TestOpportunity',End_User_Account_Name__c = '',End_User_Mailing_Country__c ='UNITED STATES',
End_User_Mailing_Street__c = '',End_User_Email__c='test@test.com');
TriggerExecutionController.setSkipOpportunityTriggers(True);
TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
insert oppRecord;*/
        MapEndUserAccountToOpportunityController controller = new MapEndUserAccountToOpportunityController(new ApexPages.StandardController(listOpp[0]));
        
        /* for(integer i=0;i<100;i++){
Account accRecord = new Account();
accRecord.Name = 'TestAccount';
accRecord.Account_Country__c= 'UNITED STATES';
accRecord.BillingStreet = '105 Challenger rd';
accRecord.status__c='A';
accList.add(accRecord);        
}
insert accList;*/
        
        Id[] listfixedSearchResults = new Id[]{listAcc[0].Id};
            Test.setFixedSearchResults(listfixedSearchResults);
        controller.searchAccounts();
        controller.saveOppRecord();
        controller.enableSaveButton();
    }
    
    public static testMethod void testMyController2(){
        listAcc = [select Id from Account limit 1];
        listOpp = [Select Id from Opportunity limit 1];
        listOpp[0].CloseDate= System.Now().Date().addDays(180);
        listOpp[0].StageName='Plan - 1%';
        listOpp[0].Partner_Opportunity_Stage__c='Plan - 1%';
        TriggerExecutionController.setSkipOpportunityTriggers(True);    
        TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
        update listOpp[0];
        PageReference pageRef = Page.MapEndUserAccountToOpportunity;
        Test.setCurrentPage(pageRef);      
        /*Opportunity oppRecord = new Opportunity (StageName='Plan - 1%',Partner_Opportunity_Stage__c='Plan - 1%',CloseDate= System.Now().Date().addDays(180),
RecordTypeId= '0127000000057ES',Name='TestOpportunity',End_User_Account_Name__c = 'a',End_User_Mailing_Country__c ='UNITED STATES',
End_User_Mailing_Street__c = 's' ,End_User_Email__c='test@test.com');
TriggerExecutionController.setSkipOpportunityTriggers(True);
TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
insert oppRecord;
setupdata();*/
        MapEndUserAccountToOpportunityController controller = new MapEndUserAccountToOpportunityController(new ApexPages.StandardController(listOpp[0]));
        /*Account accRecord = new Account(Name = 'TestAccount',Account_Country__c= 'UNITED STATES',BillingStreet = '105 Challenger rd',status__c='A');
insert accRecord;*/
        
        Id[] listfixedSearchResults = new Id[]{listAcc[0].Id};
            Test.setFixedSearchResults(listfixedSearchResults);
        controller.searchAccounts();
        controller.saveOppRecord();
        controller.enableSaveButton();
        
        controller.SelectedItem = 'Contact Email Domain';
        controller.EmailDomain = '';
        controller.searchAccounts();
        controller.getAccounts();
    }
    
    public static testMethod void testMyController3(){
        listAcc = [select Id from Account limit 1];
        
        PageReference pageRef = Page.MapEndUserAccountToOpportunity;
        Test.setCurrentPage(pageRef); 
        listOpp = [Select Id,End_User_Email__c from Opportunity limit 1];
        listOpp[0].CloseDate= System.Now().Date().addDays(180);
        listOpp[0].StageName='Plan - 1%';
        listOpp[0].End_User_Email__c='test@dell.com';
        listOpp[0].Partner_Opportunity_Stage__c='Plan - 1%';
        TriggerExecutionController.setSkipOpportunityTriggers(True);    
        TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
        update listOpp[0];
        listCon = [Select Id,email from Contact limit 1];
        listCon[0].accountid=listAcc[0].id;
        listCon[0].email='test@dell.com';
        TriggerExecutionController.setSkipContactTriggers(True);
        update listcon;
        /*Opportunity oppRecord = new Opportunity (StageName='Plan - 1%',Partner_Opportunity_Stage__c='Plan - 1%',CloseDate= System.Now().Date().addDays(180),
RecordTypeId= '0127000000057ES',Name='TestOpportunity',End_User_Account_Name__c = 'test',End_User_Mailing_Country__c ='UNITED STATES',
End_User_Mailing_Street__c = 's',End_User_Email__c='test@dell.com');
TriggerExecutionController.setSkipOpportunityTriggers(True);
TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
insert oppRecord;
setupdata();*/
        MapEndUserAccountToOpportunityController controller = new MapEndUserAccountToOpportunityController(new ApexPages.StandardController(listOpp[0]));
        /*Account accRecord = new Account(Name = 'TestAccount',Account_Country__c= 'UNITED STATES',BillingStreet = '105 Challenger rd',Status__c ='Active');
insert accRecord;
Contact testcon =  new contact(lastname = 'test',firstname ='contact',email='test@dell.com',accountid=accRecord.id);
TriggerExecutionController.setSkipContactTriggers(True);
insert testcon;*/
        
        system.assertEquals('Plan - 1%', listOpp[0].StageName);
        //system.assertEquals(listOpp[0].End_User_Email__c, listCon[0].email);
        controller.searchAccounts();
        controller.saveOppRecord();
        controller.enableSaveButton();
        controller.getitems();
        controller.getNewLine();
        controller.hasNext = true;
        controller.hasPrevious = true;
        controller.pageNumber =1;
        //controller.first();
        //controller.last();
        
    } 
}