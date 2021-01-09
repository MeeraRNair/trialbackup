/*
REVISION HISTORY
================
Version    Author          Date               Release#         CR#          Description
-------    ------          ----               --------         ---          -----------
1.0        Emily           21-Mar-2018        FY19-DCE-0502    15540        Field Trip clean up for Opportunity
*/

@isTest
public class ServicesProjectsCtrlTest{
    static List <Services_Project__c> listSp ;
    @testSetup static void setup() { 
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
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(4, 'Standard Opportunity');
        listOppTdf[0].Skip_Calculate_LOT_OCEAN__c=true;
        listOppTdf[0].Type='Deal/Bid Direct';
        listOppTdf[0].DGR_Level__c = 'Level 0';
        listOppTdf[0].Dell_Defined_Industry__c='Banking Financial Services & Insurance (BFSI)';
        listOppTdf[0].Dell_Defined_LOB__c='Infrastructure & Cloud Computing';
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        
        listSp = new List <Services_Project__c> ();
        for(Integer inti=0;inti<55;inti++){
            Services_Project__c sp = new Services_Project__c (Opportunity__c = listOppTdf[0].Id);
            listSp.add(sp);
        }
        insert listSp;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    // static Opportunity testOpportunity;
    //static Account testAccount;
    
    /*  static void createSPList(){
spList = new List <Services_Project__c> ();
for(Integer i=0;i<55;i++){

Services_Project__c sp = new Services_Project__c (Opportunity__c = testOpportunity.Id);
spList.add(sp);

}
TriggerExecutionController.setSkipAllTriggers(true);
insert spList;
TriggerExecutionController.setSkipAllTriggers(false);
}
*/
    /*  static void createOpportunity(){

Date dCloseDate = System.Today()+10;

testOpportunity = new Opportunity(Name='Test Opportunity 1', 
Skip_Calculate_LOT_OCEAN__c=true, 
AccountId=testAccount.Id,
Type='Deal/Bid Direct', 
RecordTypeId='012300000004zf2',
CloseDate=dCloseDate,
StageName='Discover - 10%',
DGR_Level__c = 'Level 0'
,Dell_Defined_Industry__c='Banking Financial Services & Insurance (BFSI)',
Dell_Defined_LOB__c='Infrastructure & Cloud Computing'
//1.0 Delivery_Region_s__c='EMEA;AMER'
);

TriggerExecutionController.setSkipOpportunityTriggers(true);
insert testOpportunity;   
TriggerExecutionController.setSkipOpportunityTriggers(false);
}
*/
    /* static void createAccount(){

testAccount = new Account(Name='Test Account 10');
insert testAccount;

}*/
    //Test Method 1: 
    public static testMethod void servicesProjectsCtrlTestNoData() {
        // createAccount();
        //createOpportunity();
        //createSPList();            
        //Create Test Data 
        list<Account> listAcc=[select id from Account Limit 1];
        system.assertNotEquals(listAcc[0].id, null);
        PageReference pageRef = Page.ServicesProjects;
        Test.setCurrentPage(pageRef);
        
        ServicesProjectsCtrl controller = new ServicesProjectsCtrl();
        controller.dealID = '';
        controller.affinityAccountID = '';
        controller.projectID = '';
        Test.StartTest();
        controller.ViewData();
        controller.search();
        Test.StopTest();
    }
    
    //Test Method 1: 
    public static testMethod void servicesProjectsCtrlTestWithData() {
        // createAccount();
        //createOpportunity();
        //createSPList();            
        //Create Test Data 
        list<Account> listAcc=[select id from Account Limit 1];
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        List <Services_Project__c> listServicePro=[select id,Opportunity__c from Services_Project__c limit 54];
        system.assertNotEquals(listAcc[0].id, null);
        PageReference pageRef = Page.ServicesProjects;
        Test.setCurrentPage(pageRef);
        
        ServicesProjectsCtrl controller = new ServicesProjectsCtrl();
        //ApexPages.currentPage().getParameters().put('oppId', 'xxxxx');
        controller.dealID = '';
        controller.affinityAccountID = '12345';
        controller.opp.Dell_Defined_LOB__c = 'Infrastructure & Cloud Computing';
        controller.projectID = '';
        Test.StartTest();
        controller.search();
        controller.openReport();
        controller.getspList();
        controller.getTotalPages();
        controller.getSortDirection();
        //controller.getOpenNewReport();
        Test.StopTest();
    }
    
    
    
    //Test Method 1: 
    public static testMethod void servicesProjectsCtrlTestOpenReport() {
        // createAccount();
        //createOpportunity();
        //createSPList();            
        //Create Test Data
        list<Account> listAcc=[select id from Account Limit 1];
        system.assertNotEquals(listAcc[0].id, null);
        PageReference pageReftest = Page.ServicesProjectsExport;
        PageReference pageRef = Page.ServicesProjects;
        
        Test.setCurrentPage(pageRef);
        
        ServicesProjectsCtrl controller = new ServicesProjectsCtrl();
        //ApexPages.currentPage().getParameters().put('dlid', testOpportunity.Deal_Id__c);
        controller.dealID = '';
        controller.affinityAccountID = '12345';
        controller.opp.Dell_Defined_LOB__c = 'Infrastructure & Cloud Computing';
        controller.projectID = '';
        controller.opp.Dell_Defined_Industry__c = '';
        Test.StartTest();
        controller.search();
        controller.openReport();
        System.debug('#######'+controller.openReport());
        //System.assertEquals(pageReftest , controller.openReport());
        Test.StopTest();
    }
    
    public static testMethod void testDellServicesInd(){
        //Create Test Data
        // createAccount();
        list<Account> listAcc=[select id from Account Limit 1];
        //create Opportunity test record
        /*  List<Opportunity> testOpportunityList = new List<Opportunity>();
Opportunity testOppty;

for(Integer i=0;i<4;i++){
Date dCloseDate = System.Today()+10;            
testOppty = new Opportunity(Name='Test Opportunity '+i, 
Skip_Calculate_LOT_OCEAN__c=true, AccountId=testAccount.Id, Type='Deal/Bid Direct', 
RecordTypeId='012300000004zf2', CloseDate=dCloseDate, StageName='Discover - 10%', DGR_Level__c = 'Level 0',Dell_Defined_Industry__c='Banking Financial Services & Insurance (BFSI)',Dell_Defined_LOB__c='Infrastructure & Cloud Computing'
//1.0 Delivery_Region_s__c='EMEA;AMER'
);
testOpportunityList.add(testOppty); 
} 
TriggerExecutionController.setSkipOpportunityTriggers(true);      
insert testOpportunityList;           
*/
        list<Opportunity> listOpp=[select id from Opportunity Limit 4];
        listOpp[1].Dell_Defined_Industry__c = 'Commercial';
        listOpp[2].Dell_Defined_Industry__c = 'Education, State & Local (ESL)';
        TriggerExecutionController.setSkipOpportunityTriggers(true);      
        update listOpp;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        PageReference pageRef = Page.ServicesProjects;
        
        Test.setCurrentPage(pageRef);
        ServicesProjectsCtrl controller = new ServicesProjectsCtrl();
        
        controller.dealID = '';
        controller.affinityAccountID = '12345';
        controller.opp.Dell_Defined_LOB__c = 'Infrastructure & Cloud Computing';
        controller.projectID = '';        
        List<String> listTestDellServInd = new List<string>{'Banking Financial Services & Insurance (BFSI)','Commercial','Education, State & Local (ESL)'};
            
            Test.StartTest();
        controller.dellServIndLeftselected.addAll(listTestDellServInd);
        controller.dellServIndSelectclick();        
        controller.getdellServIndSelectedValues();
        controller.dellServIndRightselected.add('Commercial');
        controller.dellServIndUnselectclick();
        controller.getdellServIndUnSelectedValues();
        controller.search();        
        
        Test.StopTest();        
        system.debug('########### 8954 queryString :'+controller.queryString);
        system.assertEquals(controller.queryString.contains('Dell_Services_Industry__c'), true);
    }
    
}