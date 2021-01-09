@isTest

public class LinkOppToStrategyCtrlTest{
    
    static Account testAcc = new Account();
    static SFDC_Acct_Plan__c testAP = new SFDC_Acct_Plan__c();
    static SFDC_Strategy__c testST = new SFDC_Strategy__c();
    public static list<Opportunity> opplist = new list<Opportunity>();
    public static list<Opportunity> opplist1 = new list<Opportunity>();
    public static list<OpportunityLineItem> oppListItem = new list<OpportunityLineItem>();
    public Final static Integer PAGE_SIZE = 20;
        
    
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
        system.assertEquals('Qualify - 30%',owdSetting.Oppty_Stage30__c );
        StrategyandOppValues__c strOpp = new StrategyandOppValues__c();
        strOpp.Name = 'Natworking1';
        strOpp.Bu_s_Are_Offering__c = 'Networking';
        strOpp.Bu_s_Are_Involved__c = 'Networking';
        strOpp.Product_Type__c = 'Enterprise Solution Group';
        strOpp.Product_Group__c = 'Dell Networking';
        
        insert strOpp;
        system.assertEquals('Networking',strOpp.Bu_s_Are_Offering__c);
    }
    
    public static void createData(){
        
               List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules        (listObjectNames);
        //Create a user with Standard User profile       
        Profile profile = [select id from profile where Name = 'System Administrator' limit 1];
        
        User user = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        testAcc.name = 'Test Account';
        insert testAcc;        
        
        
        RecordType OppRt = [Select Name, Id
                           From RecordType
                           where sObjectType='Opportunity' and name='Standard Opportunity' limit 1];
                                   
        Opportunity testOpp = new Opportunity();
        testOpp.RecordTypeId = OppRt.id;
        testOpp.Name = 'Test Opportunity';
        testOpp.StageName = 'Plan - 1%';
        testOpp.AccountId = testAcc.Id;
        testOpp.Closedate = System.TODAY();
        
        Opportunity testOpp1 = new Opportunity();
        testOpp1.RecordTypeId = OppRt.id;
        testOpp1.Name = 'Test Opportunity';
        testOpp1.StageName = 'Plan - 1%';
        testOpp1.AccountId = testAcc.Id;
        testOpp1.Closedate = System.TODAY();
        
        Opportunity testOpp2 = new Opportunity();
        testOpp2.RecordTypeId = OppRt.id;
        testOpp2.Name = 'Test Opportunity';
        testOpp2.StageName = 'Plan - 1%';
        testOpp2.AccountId = testAcc.Id;
        testOpp2.Closedate = System.TODAY();
        
        Opportunity testOpp3 = new Opportunity();
        testOpp3.RecordTypeId = OppRt.id;
        testOpp3.Name = 'Test Opportunity3';
        testOpp3.StageName = 'Plan - 1%';
        testOpp3.AccountId = testAcc.Id;
        testOpp3.Closedate = System.TODAY();
        
        opplist.add(testopp);
        opplist.add(testopp1);
        opplist.add(testopp2);
        opplist.add(testOpp3);
        insert opplist;
        
    /*    Pricebook2 pb = new Pricebook2(
        Name='Testbook');
        insert pb;
        Product2 p1 = new Product2();
        p1.Name='product1';
        p1.Family='Card Present';
        p1.Product_ID__c = '11';
        insert p1;
        Quote q1 = new Quote();
        q1.Name='Quote 1';
        q1.OpportunityId=testopp.id;
        insert q1;
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id=Test.getStandardPricebookId();
        pbe.Product2Id=p1.id;
        pbe.UnitPrice=3000;
        pbe.IsActive = true;
        pbe.UseStandardPrice=false;
        insert pbe;
        
        OpportunityLineItem oppLI1 = new OpportunityLineItem(PricebookEntryId = pbe.Id,UnitPrice=20000,Quantity = 2,Service_Support_US__c='Not Applicable',OpportunityId = testOpp1.id,Product_Type__c='Enterprise Solution Group');
        OpportunityLineItem oppLI2 = new OpportunityLineItem(PricebookEntryId = pbe.Id,UnitPrice=20000,Quantity = 2,Service_Support_US__c='Not Applicable',OpportunityId = testOpp2.id,Product_Type__c='Enterprise Solution Group');
        OpportunityLineItem oppLI3 = new OpportunityLineItem(PricebookEntryId = pbe.Id,UnitPrice=20000,Quantity = 2,Service_Support_US__c='Not Applicable',OpportunityId = testOpp3.id,Product_Type__c='Enterprise Solution Group');
        
        oppListItem.add(oppLI1);
        oppListItem.add(oppLI2);
        oppListItem.add(oppLI3);
        insert oppListItem;
        */
      //  testOpp.StageName = 'Discover - 10%';
       // update testOpp;
        
        RecordType ApRt= [Select Name, Id
                           From RecordType
                           where sObjectType='SFDC_Acct_Plan__c' and name='Channel/Partner Account Plan' limit 1];
                                   
        testAP.RecordTypeId = ApRt.Id;
        testAP.Name = 'Test Account Plan';
        testAP.Account__c = testAcc.Id;
        testAP.Sales_Manager__c = user.Id;
        insert testAP;
        
        testST.Name = 'Test Strategy';
        testST.Strategy_Owner__c = user.Id;
        testST.SFDC_Acct_Plan__c = testAP.Id;
        testST.Enterprise_Business_Issue__c = 'Test Customer Objective';
        testST.IT_Implications__c = 'Test IT Implications';
        testST.Dell_s_Strategy_Response__c = 'Test Dell s Strategy response';
        testST.When_do_you_plan_to_realize_Strategy__c = '1st Q (This FY)';
        testST.Region__c = 'APJ';
        testST.What_BU_s_are_involved__c = 'Networking';
        testST.Which_LOB_will_you_offer__c = 'Networking';
        testST.Which_LOB_will_you_offer__c = 'Services';
        testST.Potential_Strategy_Value__c = 10;
        testST.Strengths__c = 'Test Strengths';        
        testST.Threats__c = 'Test Threats';
        insert testST;
        
    }
 
    static testMethod void LinkOppTest() {   
     
         TriggerExecutionController.setSkipAllTriggers(true);
         createData();
         TriggerExecutionController.setSkipAllTriggers(false);
                List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
            
                      
         PageReference pref = Page.LinkOppToStrategy;
         pref.getParameters().put('id',testST.id);
         Test.setCurrentPage(pref);
      
         LinkOppToStrategyCtrl linkopp = new LinkOppToStrategyCtrl();
         SFDC_Strategy__c strategy = [Select SFDC_Acct_Plan__r.Account__c, Account_Name__c,What_BU_s_are_involved__c,Which_LOB_will_you_offer__c from SFDC_Strategy__c where Id = :testST.id];
         linkopp.accId = strategy.SFDC_Acct_Plan__r.Account__c;
         linkopp.accname = strategy.Account_Name__c;
         linkopp.componentRecords = null;
         linkopp.strategyId = testST.id;
         linkopp.noOfRecords = 0;
            
         List<LinkOppToStrategyCtrl.OppWrapper> OpportunityIteratedList = new List<LinkOppToStrategyCtrl.OppWrapper>();
         LinkOppToStrategyCtrl.OppWrapper testOppWraper = new LinkOppToStrategyCtrl.OppWrapper(opplist[0]); 
         
         String formattedCloseDate = testOppWraper.getFormattedCloseDate();
         
         Test.startTest();
         linkopp.getAccountInfo();
         OpportunityIteratedList.add(testOppWraper); 
         //testOppWraper.currentOppWrapperList = opplist;
         linkopp.componentRecords = null;
         linkopp.constructQueryString();
            
         linkopp.getOppListCount(); 
         linkopp.getOppList();    
         linkopp.selectedOppId = opplist[0].Id;
         
         TriggerExecutionController.setSkipOpportunityTriggers(True);
         linkopp.link();
         TriggerExecutionController.setSkipOpportunityTriggers(False);
         
         //linkopp.handleError(exception);
         linkopp.view();
         linkopp.back();
         linkopp.getLastPage();
       
         system.debug('testK Closedate ' +opplist[2].Closedate);
         linkopp.selectedOppId = opplist[2].Id;
         opplist[2].Closedate = System.TODAY() - 5;
         system.debug('testK Closedate ' +opplist[2].Closedate);
            
         linkopp.link();
         
         Test.stopTest();
     
    }      
}