/***********************************************************
* Name          : SupportRequestEmailUtilsTest
* Description   : Test Class for SupportRequestEmailUtils
* ---------------------------------------------------------
* Revision  Name            Date        Description
* 1.0                                   creation
* 1.1       Azwanti         27.08.2013  CR8531-replace HW_SW_or_other_Financing_Dell_owned__c value from 'true' to 'Yes' due to field type change to picklist. 
* 2.0       Kokila          30.06.2015  CR11633-Sales Role Change for Services Sales Executive and Services Account Executive on Support Request Object
* 3.0       Krishnamoorthi  23.12.2015  R16.12 CR12512 - Pre Sales -  Remove picklist value 'US FED Specialized Support' from Support Request field Custom Service Support  
*/
@isTest  
private class SupportRequestEmailUtilsTest { 
    
    //Test method for CR 8527 and CR 8534 - Start
    static PricebookEntry pricebookEntry;
    static void createProduct(){
      
      Product2 product = new product2(name='Test Product 1',family='Services',isActive=true, Dgr_Eligible__c = 'Yes',Product_ID__c = '12SV');
      insert product;
      
      Pricebook2 pb = [select Id from Pricebook2 where isStandard=true ];
            
      pricebookEntry = new PricebookEntry(pricebook2id=pb.id,
          product2id=product.id, unitprice=1000.0, isActive=true);
      insert pricebookEntry;
      
      
        /*CSSR_Pursuit_Support__c cssr1 = new CSSR_Pursuit_Support__c(Pursuit_Team_Mailbox__c='proposals_global_services_proposal_support@dell.com.dit2', Resource_Type_Name__c='Services Proposal Support', Name='Proposal');
        CSSR_Pursuit_Support__c cssr2 = new CSSR_Pursuit_Support__c(Pursuit_Team_Mailbox__c='global_dgr_support@dell.com.dit2', Resource_Type_Name__c='Deal Governance Review Support', Name='DGR');
        CSSR_Pursuit_Support__c cssr3 = new CSSR_Pursuit_Support__c(Pursuit_Team_Mailbox__c='services_global_pricing_support@dell.com.dit2', Resource_Type_Name__c='Services Finance Support', Name='Finance');
        CSSR_Pursuit_Support__c cssr4 = new CSSR_Pursuit_Support__c(Pursuit_Team_Mailbox__c='legal_us_services_contract_support@dell.com.dit2', Resource_Type_Name__c='Services Legal Support', Name='Legal');
        List<CSSR_Pursuit_Support__c> cssrList = new List<CSSR_Pursuit_Support__c>();
        cssrList.add(cssr1);
        cssrList.add(cssr2);
        cssrList.add(cssr3);
        cssrList.add(cssr4);
        insert cssrList;*/
     }
     
    static testmethod void test_AAACSSREmailOperationUponCreateorUpdate(){
            RecordType[] rType;
            Support_Request__c[] srArray=new List<Support_Request__c>();
            Account account=new Account(name='Test Account');
            Test.startTest();
            TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
    
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
            Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Qualify - 30%', Competitor_Lost_To__c='Unknown');
                                        
                              
            // Added for Too Many SOQL Queries Issue ---- Sreehari Ambati On 27/10/2014
            //Start
            
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOpportunity;            
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            //End
            createProduct();
            System.Debug('The SOQL QUERIES'+Limits.getQueries());
            
            OpportunityLineItem oli = new OpportunityLineItem(opportunityid=testOpportunity.id, UnitPrice=5000000, quantity=2, pricebookentryid=pricebookEntry.Id,Product_Type__c='Services');
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert oli; 
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipAllTriggers(false);
            
            System.Debug('The SOQL QUERIES'+Limits.getQueries());
            rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];
            Support_Request__c SupportRequestItem1=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                                Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                                Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', InquireCancel_Finance__c = 'Submit Inquiry',
                                Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes',
                                Deal_Governance_Review_Support__c = 'Yes', InquireCancel_DGR__c = 'Submit Inquiry',
                                Services_Legal_Support__c = 'Yes', InquireCancel_Legal__c = 'Submit Inquiry',
                                Services_Proposal_Support__c = 'Yes', InquireCancel_Proposal__c = 'Submit Inquiry');
            srArray.add(SupportRequestItem1);  
            
            //Test.startTest(); 
            TriggerExecutionController.setSkipOpportunityTriggers(true);

            insert srArray;
            
            TriggerExecutionController.setSkipOpportunityTriggers(false);

            
            System.Debug('The SOQL QUERIES'+Limits.getQueries());
            
             Support_Request__c supportRequestVar=[select InquireCancel_DGR__c, InquireCancel_Finance__c, InquireCancel_Legal__c, InquireCancel_Proposal__c,
                                                    Deal_Governance_Review_Support_Name__c, Services_Legal_Support_Name__c, Services_Proposal_Support_Name__c, Services_Finance_Support_Name__c    
                                                from Support_Request__c WHERE id=:SupportRequestItem1.Id];

            supportRequestVar.Services_Proposal_Support_Name__c = UserInfo.getUserId();
            
            SupportRequestEmailUtils.resetAlreadyMailSentForTestMethod();
            
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            update supportRequestVar;            
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            System.Debug('The SOQL QUERIES'+Limits.getQueries());
           Test.stopTest(); System.Debug('The SOQL QUERIES'+Limits.getQueries());  
    }
    
    static TestMethod void test_AAACSSREmailOperationUponCreateorUpdate_157_DeploymentIssueFix(){
            RecordType[] rType;
            Support_Request__c[] srArray=new List<Support_Request__c>();
            Account account=new Account(name='Test Account');
            //TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
    
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
            Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Qualify - 30%', Competitor_Lost_To__c='Unknown');
            Test.startTest();
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            ProcessFlowTriggerController.isTest = true;
            insert testOpportunity;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            createProduct();
            OpportunityLineItem oli = new OpportunityLineItem(opportunityid=testOpportunity.id, UnitPrice=5000000,quantity=1, pricebookentryid=pricebookEntry.Id,Product_Type__c='Services');
            
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert oli; 
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            //TriggerExecutionController.setSkipAllTriggers(false);
            rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];
            Support_Request__c SupportRequestItem1=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                                Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                                Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', InquireCancel_Finance__c = 'Submit Inquiry',
                                Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes',
                                Deal_Governance_Review_Support__c = 'Yes', InquireCancel_DGR__c = 'Submit Inquiry',
                                Services_Legal_Support__c = 'Yes', InquireCancel_Legal__c = 'Submit Inquiry',
                                Services_Proposal_Support__c = 'Yes', InquireCancel_Proposal__c = 'Submit Inquiry');
            try{                    
            srArray.add(SupportRequestItem1);                    
            //Test.startTest();
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert srArray;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            }catch(Exception ex){
                system.debug('Exception Occured--'+ex.getMessage());            
            }
            
            
             Support_Request__c supportRequestVar=[select InquireCancel_DGR__c, InquireCancel_Finance__c, InquireCancel_Legal__c, InquireCancel_Proposal__c,
                                                    Deal_Governance_Review_Support_Name__c, Services_Legal_Support_Name__c, Services_Proposal_Support_Name__c, Services_Finance_Support_Name__c    
                                                from Support_Request__c WHERE id=:SupportRequestItem1.Id];

            supportRequestVar.Services_Finance_Support_Name__c = UserInfo.getUserId();
            
            SupportRequestEmailUtils.resetAlreadyMailSentForTestMethod();
            
            update supportRequestVar;
            
           Test.stopTest();   
    }
    
    static testmethod void test_AAACSSREmailOperationUponCreateorUpdate1(){
            RecordType[] rType;
            Account account=new Account(name='Test Account');
            Test.startTest();
            TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
            
    
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
            Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Qualify - 30%', Competitor_Lost_To__c='Unknown');
            
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOpportunity;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            createProduct();
            OpportunityLineItem oli = new OpportunityLineItem(opportunityid=testOpportunity.id, UnitPrice=5000000, quantity=2, pricebookentryid=pricebookEntry.Id,Product_Type__c='Services');
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert oli;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipAllTriggers(false);
            
            rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];
            Support_Request__c SupportRequestItem2=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                        Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                        Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes',
                        Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes',
                        Deal_Governance_Review_Support__c = 'Yes',
                        Services_Legal_Support__c = 'Yes',
                        Services_Proposal_Support__c = 'Yes' );                 
            //Test.startTest(); 
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert SupportRequestItem2;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            
             Support_Request__c supportRequestVar=[select InquireCancel_DGR__c, InquireCancel_Finance__c, InquireCancel_Legal__c, InquireCancel_Proposal__c,
                                                    Deal_Governance_Review_Support_Name__c, Services_Legal_Support_Name__c, Services_Proposal_Support_Name__c, Services_Finance_Support_Name__c,
                                                    Deal_Governance_Review_Support__c, Services_Finance_Support__c, Services_Legal_Support__c, Services_Proposal_Support__c    
                                                from Support_Request__c WHERE id=:SupportRequestItem2.Id];

            supportRequestVar.InquireCancel_DGR__c = 'Cancel Request';
            
            system.debug('supportRequestVar2 supportRequestVar2:::'+supportRequestVar);
            SupportRequestEmailUtils.resetAlreadyMailSentForTestMethod();
            
            
            update supportRequestVar;
            
            Test.stopTest();   
    }
    
    static testmethod void test_AAACSSREmailOperationUponCreateorUpdate12(){
            RecordType[] rType;
            Account account=new Account(name='Test Account');
            Test.startTest();
            TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
    
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
            Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Qualify - 30%', Competitor_Lost_To__c='Unknown');
            
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOpportunity;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            createProduct();
            OpportunityLineItem oli = new OpportunityLineItem(opportunityid=testOpportunity.id, UnitPrice=5000000, quantity=2, pricebookentryid=pricebookEntry.Id,Product_Type__c='Services');
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert oli;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipAllTriggers(false);
            
            rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];
            Support_Request__c SupportRequestItem2=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                        Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                        Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes',
                        Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes',
                        Deal_Governance_Review_Support__c = 'Yes',
                        Services_Legal_Support__c = 'Yes',
                        Services_Proposal_Support__c = 'Yes' );                 
            //Test.startTest();    
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert SupportRequestItem2;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
             Support_Request__c supportRequestVar=[select InquireCancel_DGR__c, InquireCancel_Finance__c, InquireCancel_Legal__c, InquireCancel_Proposal__c,
                                                    Deal_Governance_Review_Support_Name__c, Services_Legal_Support_Name__c, Services_Proposal_Support_Name__c, Services_Finance_Support_Name__c,
                                                    Deal_Governance_Review_Support__c, Services_Finance_Support__c, Services_Legal_Support__c, Services_Proposal_Support__c    
                                                from Support_Request__c WHERE id=:SupportRequestItem2.Id];

            
            supportRequestVar.InquireCancel_Legal__c = 'Cancel Request';
                        
            system.debug('supportRequestVar2 supportRequestVar2:::'+supportRequestVar);
            SupportRequestEmailUtils.resetAlreadyMailSentForTestMethod();
            
            update supportRequestVar;
            
            Test.stopTest();   
    }
    
    static testmethod void test_AAACSSREmailOperationUponCreateorUpdate13(){
            RecordType[] rType;
            Account account=new Account(name='Test Account');
            TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
    
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
            Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Qualify - 30%', Competitor_Lost_To__c='Unknown');
            Test.startTest();
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOpportunity;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            createProduct();
            OpportunityLineItem oli = new OpportunityLineItem(opportunityid=testOpportunity.id, UnitPrice=5000000, quantity=2, pricebookentryid=pricebookEntry.Id,Product_Type__c='Services');
            
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert oli;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipAllTriggers(false);
            
            rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];
            Support_Request__c SupportRequestItem2=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                        Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                        Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes',
                        Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes',
                        Deal_Governance_Review_Support__c = 'Yes',
                        Services_Legal_Support__c = 'Yes',
                        Services_Proposal_Support__c = 'Yes' );                 
            //Test.startTest(); 
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert SupportRequestItem2;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            Support_Request__c supportRequestVar=[select InquireCancel_DGR__c, InquireCancel_Finance__c, InquireCancel_Legal__c, InquireCancel_Proposal__c,
                                                    Deal_Governance_Review_Support_Name__c, Services_Legal_Support_Name__c, Services_Proposal_Support_Name__c, Services_Finance_Support_Name__c,
                                                    Deal_Governance_Review_Support__c, Services_Finance_Support__c, Services_Legal_Support__c, Services_Proposal_Support__c    
                                                from Support_Request__c WHERE id=:SupportRequestItem2.Id];


            supportRequestVar.InquireCancel_Proposal__c = 'Cancel Request';
                    
            system.debug('supportRequestVar2 supportRequestVar2:::'+supportRequestVar);
            SupportRequestEmailUtils.resetAlreadyMailSentForTestMethod();
            
            update supportRequestVar;
            
            Test.stopTest();   
    }
    
    static testmethod void test_AAACSSREmailOperationUponCreateorUpdate14(){
            RecordType[] rType;
            Account account=new Account(name='Test Account');
            TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
    
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
            Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Qualify - 30%', Competitor_Lost_To__c='Unknown');
            Test.startTest();
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOpportunity;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            createProduct();
            OpportunityLineItem oli = new OpportunityLineItem(opportunityid=testOpportunity.id, UnitPrice=50000000, quantity=2, pricebookentryid=pricebookEntry.Id,Product_Type__c='Services');
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert oli;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipAllTriggers(false);
            
            rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];
            Support_Request__c SupportRequestItem2=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                        Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                        Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes',
                        Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes',
                        Deal_Governance_Review_Support__c = 'Yes',
                        Services_Legal_Support__c = 'Yes',
                        Services_Proposal_Support__c = 'Yes' );                 
            //Test.startTest();    
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert SupportRequestItem2;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            
             Support_Request__c supportRequestVar=[select InquireCancel_DGR__c, InquireCancel_Finance__c, InquireCancel_Legal__c, InquireCancel_Proposal__c,
                                                    Deal_Governance_Review_Support_Name__c, Services_Legal_Support_Name__c, Services_Proposal_Support_Name__c, Services_Finance_Support_Name__c,
                                                    Deal_Governance_Review_Support__c, Services_Finance_Support__c, Services_Legal_Support__c, Services_Proposal_Support__c    
                                                from Support_Request__c WHERE id=:SupportRequestItem2.Id];

            supportRequestVar.InquireCancel_Finance__c = 'Cancel Request';
            
            system.debug('supportRequestVar2 supportRequestVar2:::'+supportRequestVar);
            SupportRequestEmailUtils.resetAlreadyMailSentForTestMethod();
            
            update supportRequestVar;
            
            Test.stopTest();   
    }
    
    static testmethod void test_AAACSSREmailOperationUponCreateorUpdate2(){
            //Test.startTest();
            RecordType[] rType;
            Account account=new Account(name='Test Account');
            TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
    
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
            Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Qualify - 30%', Competitor_Lost_To__c ='Unknown');
            //Test.startTest();
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOpportunity;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            createProduct();
            OpportunityLineItem oli = new OpportunityLineItem(opportunityid=testOpportunity.id, UnitPrice=5000000, quantity=2, pricebookentryid=pricebookEntry.Id);
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert oli;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipAllTriggers(false);
            
            rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];
            
            Support_Request__c SupportRequestItem3=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                                                    Project_Duration_months__c = 12.00,
                                                    Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes', Deal_Governance_Review_Support__c = 'Yes');
            Test.startTest();
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert SupportRequestItem3;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            Test.stopTest(); 
            
            Support_Request__c supportRequestVar1=[select InquireCancel_DGR__c, InquireCancel_Finance__c, InquireCancel_Legal__c, InquireCancel_Proposal__c,
                                        Deal_Governance_Review_Support_Name__c, Services_Legal_Support_Name__c, Services_Proposal_Support_Name__c, Services_Finance_Support_Name__c,
                                        Deal_Governance_Review_Support__c, Services_Finance_Support__c, Services_Legal_Support__c, Services_Proposal_Support__c    
                                    from Support_Request__c WHERE id=:SupportRequestItem3.Id];                                                  
                                                    
            supportRequestVar1.Services_Finance_Support__c = 'No';

            SupportRequestEmailUtils.resetAlreadyMailSentForTestMethod();

            update supportRequestVar1;
            
    }   
    
     static testmethod void test_AAACSSREmailOperationUponCreateorUpdate22(){
            
            RecordType[] rType;
            Account account=new Account(name='Test Account');
            TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
    
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
            Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Qualify - 30%', Competitor_Lost_To__c ='Unknown');
            //Test.startTest();
           //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOpportunity;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            createProduct();
            OpportunityLineItem oli = new OpportunityLineItem(opportunityid=testOpportunity.id, UnitPrice=50000000, quantity=2, pricebookentryid=pricebookEntry.Id);
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert oli;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipAllTriggers(false);
            
            rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];
            
            Support_Request__c SupportRequestItem3=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                                                    Project_Duration_months__c = 12.00,
                                                    Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes', Deal_Governance_Review_Support__c = 'Yes');
            Test.startTest();
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert SupportRequestItem3; 
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            Test.stopTest();
                                                            
            Support_Request__c supportRequestVar1=[select InquireCancel_DGR__c, InquireCancel_Finance__c, InquireCancel_Legal__c, InquireCancel_Proposal__c,
                                        Deal_Governance_Review_Support_Name__c, Services_Legal_Support_Name__c, Services_Proposal_Support_Name__c, Services_Finance_Support_Name__c,
                                        Deal_Governance_Review_Support__c, Services_Finance_Support__c, Services_Legal_Support__c, Services_Proposal_Support__c    
                                    from Support_Request__c WHERE id=:SupportRequestItem3.Id];                                                  
                                                    

            supportRequestVar1.Services_Legal_Support__c = 'Yes';
               
            SupportRequestEmailUtils.resetAlreadyMailSentForTestMethod();
            
            update supportRequestVar1;
            
    }
    
     static testmethod void test_AAACSSREmailOperationUponCreateorUpdate23(){
            //Test.startTest();
            RecordType[] rType;
            Account account=new Account(name='Test Account');
            TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
    
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
            Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Qualify - 30%', Competitor_Lost_To__c ='Unknown');
            //Test.startTest();
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOpportunity;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            createProduct();
            OpportunityLineItem oli = new OpportunityLineItem(opportunityid=testOpportunity.id, UnitPrice=5000000, quantity=2, pricebookentryid=pricebookEntry.Id,Product_Type__c='Services');
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert oli;
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipAllTriggers(false);
            
            rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];
            
            Support_Request__c SupportRequestItem3=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                                                    Project_Duration_months__c = 12.00,
                                                    Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes', Deal_Governance_Review_Support__c = 'Yes');
            Test.startTest();
            insert SupportRequestItem3; 
            Test.stopTest();
            
            Support_Request__c supportRequestVar1=[select InquireCancel_DGR__c, InquireCancel_Finance__c, InquireCancel_Legal__c, InquireCancel_Proposal__c,
                                        Deal_Governance_Review_Support_Name__c, Services_Legal_Support_Name__c, Services_Proposal_Support_Name__c, Services_Finance_Support_Name__c,
                                        Deal_Governance_Review_Support__c, Services_Finance_Support__c, Services_Legal_Support__c, Services_Proposal_Support__c    
                                    from Support_Request__c WHERE id=:SupportRequestItem3.Id];                                                  
                                                    
            supportRequestVar1.Services_Proposal_Support__c = 'Yes';
            
            SupportRequestEmailUtils.resetAlreadyMailSentForTestMethod();
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            update supportRequestVar1;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
           
    }        
    //Test method for CR 8527 and CR 8534 - End 
    
    static testmethod void test_supportAccTeamEmailAssignment() {
        TriggerExecutionController.setSkipAllTriggers(true);
        system.debug('##KP: Start test_supportAccTeamEmailAssignment');
        Support_Request__c[] srArray=new List<Support_Request__c>();
        AccountTeamMember[] atmArray=new List<AccountTeamMember>();        
        RecordType[] rType;
        Support_Request__c SupportRequestItem;
        List<User> testUserList = new List<User>();
            
        //Create Test Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        for (integer i=0; i<4;i++){
            User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
                                Alias = 'test'+i, 
                                Email='test'+ i +'@dell.com', 
                                FirstName='Tfirst'+i, 
                                LastName='TLast'+i,
                                ProfileId = userProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='TEST12345'+i );
                
            testUserList.add(user);   
        }
            
        insert testUserList;
        
        Account testAccount=new Account(name='testAccount');
        insert testAccount;     

        AccountTeamMember atm01=new AccountTeamMember(userId=testUserList[0].Id,
                                                     TeamMemberRole='Proposals Manager',
                                                     accountId = testAccount.id); 
        atmArray.add(atm01);

        AccountTeamMember atm02=new AccountTeamMember(userId=testUserList[1].Id,
                                                     TeamMemberRole='Contract Manager',
                                                     accountId = testAccount.id); 
        atmArray.add(atm02);

        AccountTeamMember atm03=new AccountTeamMember(userId=testUserList[2].Id,
                                                     TeamMemberRole='SOW Manager',
                                                     accountId = testAccount.id); 
        atmArray.add(atm03);

        AccountTeamMember atm04=new AccountTeamMember(userId=testUserList[3].Id,
                                                     TeamMemberRole='Services Intake Manager',
                                                     accountId = testAccount.id); 
        atmArray.add(atm04);

        insert atmArray;   
        
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId= rectype.Id, 
                                                        Name='Test Opportunity', AccountId= testAccount.Id, CurrencyIsoCode='USD',
                                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                                        Solution_Type__c='Business Processing', 
                                                        StageName='Plan - 1%');     
         ProcessFlowTriggerController.isTest = true;
        insert testOpportunity;
        
        //Ranjini
        Support_Request_Submission_Rule__c SRRule1 = new Support_Request_Submission_Rule__c();
        SRRule1.name = 'Test SRRule';
        SRRule1.Resource_Type__c = 'Services Finance Support';
        SRRule1.Condition__c = '>=';
        SRRule1.Unweighted_Rev_Services_Only__c = 0;
        SRRule1.Stage__c = 'Plan - 1%';
        insert SRRule1;
        //Ranjini
        
        rType = [select id,name from RecordType where SobjectType='Support_Request__c'];


        for(RecordType rt:rType){              
            if(rt.Name=='Request Proposal Support'){
                    
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00);
                srArray.add(SupportRequestItem);    
            }//end of if 'Request Proposal Support'

            else if(rt.Name=='Request Contracts Support'){                       
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.Id,CSMB_Contract_Request_Type__c ='Statement of Work',
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00); 
                srArray.add(SupportRequestItem);
                
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Contract_Support__c ='Statement of Work' , Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00);
                srArray.add(SupportRequestItem);
            }//end of if 'Request Contract Support'
            
            else if(rt.Name=='Request Custom Service Support'){
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                    Project_Duration_months__c = 12.00, Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Firm offer', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);
                
                //R3.0
                /*SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='US FED Specialized Support', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                    Project_Duration_months__c = 12.00, Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Firm offer', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);*/
            }
        } //end of for loop
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
            insert srArray;
            TriggerExecutionController.setSkipAllTriggers(false);
        // Stop the test
        Test.stopTest();      
        
        List<Support_Request__c> srList=[select Custom_Service_Support__c,RecordType.name, WFEmailStatus__c,WFEMailField__c from Support_Request__c where id IN:srArray];       
        
        //R3.0
        /*for (Support_Request__c srItem : srList){
            if(srItem.Custom_Service_Support__c=='US FED Specialized Support'){
                System.assertEquals(srItem.WFEmailStatus__c,'Blank value');
            }else if(srItem.Custom_Service_Support__c=='Custom Service Solution'){
                //System.assertEquals(srItem.WFEMailField__c,testUserList[3].email);
            }
        }*/
    
                     
        system.debug('##KP: Stop test_supportAccTeamEmailAssignment');      
        
    }//end of test_supportAccTeamEmailAssignment 
    
    static testmethod void test_supportAccTeamEmail_OwnerAssignment() {
        TriggerExecutionController.setSkipAllTriggers(true);
        system.debug('##MN: Start test_supportAccTeamEmail_OwnerAssignment');
        Support_Request__c[] srArray=new List<Support_Request__c>();
        AccountTeamMember[] atmArray=new List<AccountTeamMember>();        
        RecordType[] rType;
        Support_Request__c SupportRequestItem;
        List<User> testUserList = new List<User>();
        User testUser;
            
        //Create Test Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        
            testUser = new User( Username='test' + System.currentTimeMillis() + '@test.com',
                                Alias = 'test', 
                                Email='test'+ System.currentTimeMillis() +'@dell.com', 
                                FirstName='Tfirst', 
                                LastName='TLast',
                                ProfileId = userProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='TEST12345bn' );
                
              
       
            
        insert testUser;
        
        Account testAccount=new Account(name='testAccount');
        insert testAccount;     

        AccountTeamMember atm01=new AccountTeamMember(userId=testUser.Id,
                                                     TeamMemberRole='Proposals Manager',
                                                     accountId = testAccount.id); 
        atmArray.add(atm01);       

        insert atmArray;   
        
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId= rectype.Id, 
                                                        Name='Test Opportunity', AccountId= testAccount.Id, CurrencyIsoCode='USD',
                                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                                        Solution_Type__c='Business Processing', 
                                                        StageName='Plan - 1%');     
        ProcessFlowTriggerController.isTest = true;
        insert testOpportunity;
        
        rType = [select id,name from RecordType where SobjectType='Support_Request__c'];


        for(RecordType rt:rType){              
            if(rt.Name=='Request Proposal Support'){
                    
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00);
                srArray.add(SupportRequestItem);    
            }//end of if 'Request Proposal Support'

           
        } //end of for loop
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
            insert srArray;
        // Stop the test
        Test.stopTest();      
        
        List<Support_Request__c> srList=[select Custom_Service_Support__c,RecordType.name, WFEmailStatus__c,WFEMailField__c,Support_Owner__c from Support_Request__c where id IN:srArray];       
        
        for (Support_Request__c srItem : srList){
            System.assertEquals(srItem.Support_Owner__c, testUser.Id);
        }
    
                     
        system.debug('##MN: Stop test_supportAccTeamEmail_OwnerAssignment');      
        
    }//end of test_supportAccTeamEmailAssignment 
    
    static testmethod void test_supportWithoutAccTeam() {
        TriggerExecutionController.setSkipAllTriggers(true);
        system.debug('##KP: Start test_supportWithoutAccTeam');
        Support_Request__c[] srArray=new List<Support_Request__c>();              
        RecordType[] rType;
        
        Support_Request__c SupportRequestItem;
        
        Account testAccount=new Account(name='testAccount',Account_Country__c='testcountry');
        insert testAccount; 
        
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId= rectype.Id, 
                                                        Name='Test Opportunity', AccountId= testAccount.Id, CurrencyIsoCode='USD',
                                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                                        Solution_Type__c='Business Processing', 
                                                        StageName='Plan - 1%');     
         ProcessFlowTriggerController.isTest = true;
        insert testOpportunity;
        
        //Ranjini
        Support_Request_Submission_Rule__c SRRule1 = new Support_Request_Submission_Rule__c();
        SRRule1.name = 'Test SRRule';
        SRRule1.Resource_Type__c = 'Services Finance Support';
        SRRule1.Condition__c = '>=';
        SRRule1.Unweighted_Rev_Services_Only__c = 0;
        SRRule1.Stage__c = 'Plan - 1%';
        insert SRRule1;
        //Ranjini
        
        rType = [select id,name from RecordType where SobjectType='Support_Request__c'];
        Country__c CountryRecord = new Country__c(US_Fed_OCONUS_Support__c='test_ocunus@test.com',SOW_Support_Email__c='test_sow@test.com',                                                                          Proposal_Support_Email__c='test_proposal@test.com',
                                                                          Custom_Service_Solution_EMail__c='test_service@test.com', 
                                                                          Contract_Support_Email__c='test_support@test.com', 
                                                                          Name='testcountry',Code__c='T1');

        insert CountryRecord;
        
        for(RecordType rt:rType){              
            if(rt.Name=='Request Proposal Support'){
                    
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00);
                srArray.add(SupportRequestItem);    
            }//end of if 'Request Proposal Support'

            else if(rt.Name=='Request Contracts Support'){                       
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00); 
                srArray.add(SupportRequestItem);
                
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Contract_Support__c ='Statement of Work' , Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00);
                srArray.add(SupportRequestItem);
            }//end of if 'Request Contract Support'
            
            else if(rt.Name=='Request Custom Service Support'){
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                    Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Firm offer', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);
                
                //R3.0
                /*SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='US FED Specialized Support', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                    Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Firm offer', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);*/
            }
        } //end of for loop
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
            insert srArray;
            TriggerExecutionController.setSkipAllTriggers(false);
        // Stop the test
        Test.stopTest();      
        
        //R3.0
        /*List<Support_Request__c> srList=[select Custom_Service_Support__c,RecordType.name, WFEmailStatus__c,WFEMailField__c 
                                        from Support_Request__c WHERE id IN:srArray AND (Custom_Service_Support__c='US FED Specialized Support'                                         OR Custom_Service_Support__c='test_service@test.com')]; */
        
        List<Support_Request__c> srList=[select Custom_Service_Support__c,RecordType.name, WFEmailStatus__c,WFEMailField__c 
                                        from Support_Request__c WHERE id IN:srArray AND Custom_Service_Support__c='test_service@test.com'];
                                        
        for (Support_Request__c srItem : srList){
            //R3.0
            /*if(srItem.Custom_Service_Support__c=='US FED Specialized Support'){
                //System.assertEquals('test_ocunus@test.com',srItem.WFEMailField__c);
            }else */
                
            if(srItem.Custom_Service_Support__c=='Custom Service Solution'){
                System.assertEquals('test_service@test.com',srItem.WFEMailField__c);
            }
        }
    
                     
        system.debug('##KP: Stop test_supportWithoutAccTeam');      
        
    }//end of test_supportWithoutAccTeam 
    
    static testmethod void test_supportWithoutAccount() {
        TriggerExecutionController.setSkipAllTriggers(true);
        system.debug('##KP: Start test_supportWithoutAccTeam');
        Support_Request__c[] srArray=new List<Support_Request__c>();              
        RecordType[] rType;
        
        Support_Request__c SupportRequestItem;
        
        Account testAccount=new Account(name='testAccount',Account_Country__c='testcountry');
        insert testAccount; 
        
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId= rectype.Id, 
                                                        Name='Test Opportunity', AccountId= testAccount.Id, CurrencyIsoCode='USD',
                                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                                        Solution_Type__c='Business Processing', 
                                                        StageName='Plan - 1%');     
         ProcessFlowTriggerController.isTest = true;
        insert testOpportunity;
        
        //Ranjini
        Support_Request_Submission_Rule__c SRRule1 = new Support_Request_Submission_Rule__c();
        SRRule1.name = 'Test SRRule';
        SRRule1.Resource_Type__c = 'Services Finance Support';
        SRRule1.Condition__c = '>=';
        SRRule1.Unweighted_Rev_Services_Only__c = 0;
        SRRule1.Stage__c = 'Plan - 1%';
        insert SRRule1;
        //Ranjini
        
        rType = [select id,name from RecordType where SobjectType='Support_Request__c'];
        Country__c CountryRecord = new Country__c(US_Fed_OCONUS_Support__c='test_ocunus@test.com',SOW_Support_Email__c='test_sow@test.com',                                                                          Proposal_Support_Email__c='test_proposal@test.com',
                                                                          Custom_Service_Solution_EMail__c='test_service@test.com', 
                                                                          Contract_Support_Email__c='test_support@test.com', 
                                                                          Name='testcountry',Code__c='T3');

        insert CountryRecord;
        
        for(RecordType rt:rType){              
            if(rt.Name=='Request Proposal Support'){
                    
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00);
                srArray.add(SupportRequestItem);    
            }//end of if 'Request Proposal Support'

            else if(rt.Name=='Request Contracts Support'){                       
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00); 
                srArray.add(SupportRequestItem);
                
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Contract_Support__c ='Statement of Work' , Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00);
                srArray.add(SupportRequestItem);
            }//end of if 'Request Contract Support'
            
            else if(rt.Name=='Request Custom Service Support'){
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                    Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Preliminary/indicative pricing', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);
                
                //R3.0
                /*SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='US FED Specialized Support', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                    Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Preliminary/conditional pricing', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);*/
            }
        } //end of for loop
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
            insert srArray;
            TriggerExecutionController.setSkipAllTriggers(false);
        // Stop the test
        Test.stopTest();      
        
        //R3.0
        /*List<Support_Request__c> srList=[select Custom_Service_Support__c,RecordType.name, WFEmailStatus__c,WFEMailField__c 
                                        from Support_Request__c WHERE id IN:srArray AND (Custom_Service_Support__c='US FED Specialized Support' 
                                        OR Custom_Service_Support__c='test_service@test.com')];  */ 

        List<Support_Request__c> srList=[select Custom_Service_Support__c,RecordType.name, WFEmailStatus__c,WFEMailField__c 
                                        from Support_Request__c WHERE id IN:srArray AND Custom_Service_Support__c='test_service@test.com'];                                     
        
        for (Support_Request__c srItem : srList){
            
            //R3.0
            /*if(srItem.Custom_Service_Support__c=='US FED Specialized Support'){
                //System.assertEquals('test_ocunus@test.com',srItem.WFEMailField__c);
            }else */
                
            if(srItem.Custom_Service_Support__c=='Custom Service Solution'){
                System.assertEquals('test_service@test.com',srItem.WFEMailField__c);
            }
        }
    
                     
        system.debug('##KP: Stop test_supportWithoutAccTeam');      
        
    }//end of test_supportWithoutAccTeam 
    
    static testmethod void test_supportRequestWithNoSupport() {
        TriggerExecutionController.setSkipAllTriggers(true);
        system.debug('##KP: Start test_supportRequestWithNoSupport');
        Support_Request__c[] srArray=new List<Support_Request__c>();              
        RecordType[] rType;
        
        Support_Request__c SupportRequestItem;
        
        Account testAccount=new Account(name='testAccount',Account_Country__c='testcountry');
        insert testAccount; 
        
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId= rectype.Id, 
                                                        Name='Test Opportunity', AccountId= testAccount.Id, CurrencyIsoCode='USD',
                                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                                        Solution_Type__c='Business Processing', 
                                                        StageName='Plan - 1%');     
         ProcessFlowTriggerController.isTest = true;
        insert testOpportunity;
        
        //Ranjini
        Support_Request_Submission_Rule__c SRRule1 = new Support_Request_Submission_Rule__c();
        SRRule1.name = 'Test SRRule';
        SRRule1.Resource_Type__c = 'Services Finance Support';
        SRRule1.Condition__c = '>=';
        SRRule1.Unweighted_Rev_Services_Only__c = 0;
        SRRule1.Stage__c = 'Plan - 1%';
        insert SRRule1;
        //Ranjini
        
        rType = [select id,name from RecordType where SobjectType='Support_Request__c'];
        
        Country__c CountryRecord = new Country__c(Name='testcountry',Code__c='T2');
        insert CountryRecord;
        
        for(RecordType rt:rType){              
            if(rt.Name=='Request Proposal Support'){
                    
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00);
                srArray.add(SupportRequestItem);    
            }//end of if 'Request Proposal Support'

            else if(rt.Name=='Request Contracts Support'){                       
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00); 
                srArray.add(SupportRequestItem);
                
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Contract_Support__c ='Statement of Work' , Opportunity__c=testOpportunity.Id,
                                                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                Project_Duration_months__c = 12.00);
                srArray.add(SupportRequestItem);
            }//end of if 'Request Contract Support'
            
            else if(rt.Name=='Request Custom Service Support'){
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                    Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Firm offer', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);
                
                //R3.0
                /*SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='US FED Specialized Support', Opportunity__c=testOpportunity.Id,
                                                    Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                                                    Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Firm offer', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);*/
            }
        } //end of for loop
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
            insert srArray;
            TriggerExecutionController.setSkipAllTriggers(false);
        // Stop the test
        Test.stopTest();      
        
        //R3.0
        /*List<Support_Request__c> srList=[select Custom_Service_Support__c,RecordType.name, WFEmailStatus__c,WFEMailField__c 
                                        FROM Support_Request__c WHERE id IN:srArray AND Custom_Service_Support__c='US FED Specialized Support' LIMIT 1];       
        
        
        System.assertEquals(null,srList[0].WFEMailField__c);*/
        //System.assertEquals('No support for this country',srList[0].WFEmailStatus__c);
                     
        system.debug('##KP: Stop test_supportRequestWithNoSupport');        
        
    }//end of test_supportRequestWithNoSupport 
    
    
    static testmethod void test_addItemToStringToSupportRequestListMap() {
        
        system.debug('##KP: Start test_addItemToStringToSupportRequestListMap');                      
        Map<String, List<Support_Request__c>> stringToSupportRequestListMap = new Map<String, List<Support_Request__c>>();      
        
        Support_Request__c SupportRequestItem = new Support_Request__c(Proposal_Support__c='RFI/PQQ');
        
        Test.startTest();
        SupportRequestEmailUtils.addItemToStringToSupportRequestListMap(stringToSupportRequestListMap, 'key1', SupportRequestItem);
        
        SupportRequestItem = new Support_Request__c(Custom_Service_Support__c='Custom Service Solution');
        SupportRequestEmailUtils.addItemToStringToSupportRequestListMap(stringToSupportRequestListMap, 'key1', SupportRequestItem);
        
        //R3.0
        /*SupportRequestItem = new Support_Request__c(Custom_Service_Support__c='US FED Specialized Support');
        SupportRequestEmailUtils.addItemToStringToSupportRequestListMap(stringToSupportRequestListMap, 'key2', SupportRequestItem);  */   
        
        SupportRequestEmailUtils.addItemToStringToSupportRequestListMap(stringToSupportRequestListMap, 'key3', stringToSupportRequestListMap.get('key1'));
        
        // Stop the test
        Test.stopTest();      
        
        
        System.assertEquals(2,stringToSupportRequestListMap.get('key1').size());
        
        //R3.0
        //System.assertEquals('US FED Specialized Support',(stringToSupportRequestListMap.get('key2'))[0].Custom_Service_Support__c);
                             
        system.debug('##KP: Stop test_addItemToStringToSupportRequestListMap');     
        
    }//end of test_addItemToStringToSupportRequestListMap 
   
    static testmethod void test_AssociateSalesTeamMemberEmail(){
        TriggerExecutionController.setSkipAllTriggers(true);
        OpportunityTeamMember[] opportunityTM=new List<OpportunityTeamMember>();
        List<User> testUsrList = new List<User>();
        List<Support_Request__c> testSupportRequestList = new List<Support_Request__c>();
        Support_Request__c[] srArray=new List<Support_Request__c>();
        Support_Request__c SupportRequestItem;
        RecordType[] rType;

        Account account=new Account(name='Test Account');
        insert account;

        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                    Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                    Type='Deal/Bid Direct', CloseDate= system.today(), 
                                    Solution_Type__c='Business Processing', 
                                    StageName='Plan - 1%');     

        //insert testOpportunity;

        Opportunity testOpportunity2 = new Opportunity(RecordTypeId=rectype.Id, 
                                    Name='Test Opportunity2', AccountId= account.Id, CurrencyIsoCode='USD',
                                    Type='Deal/Bid Direct', CloseDate= system.today(), 
                                    Solution_Type__c='Business Processing', 
                                    StageName='Plan - 1%');     

        //insert testOpportunity2;

        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList.add(testOpportunity);
        opportunityList.add(testOpportunity2);
        ProcessFlowTriggerController.isTest = true;
        insert opportunityList;
        
        

        //Ranjini
        Support_Request_Submission_Rule__c SRRule1 = new Support_Request_Submission_Rule__c();
        SRRule1.name = 'Test SRRule';
        SRRule1.Resource_Type__c = 'Services Finance Support';
        SRRule1.Condition__c = '>=';
        SRRule1.Unweighted_Rev_Services_Only__c = 0;
        SRRule1.Stage__c = 'Plan - 1%';
        insert SRRule1;
        //Ranjini

        //Create Test User Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        for (integer i=0; i<7;i++){
            User user = new User(Username='test' +i+ System.currentTimeMillis() + '@test.com',
            Alias = 'test'+i, 
            Email='test'+ i +'@dell.com', 
            FirstName='Tfirst'+i, 
            LastName='TLast'+i,
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345'+i );

            testUsrList.add(user);   
        }

        insert testUsrList;

        OpportunityTeamMember otm01=new OpportunityTeamMember(userId=testUsrList[0].Id,
                                    TeamMemberRole='Account Executive',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm01);

        OpportunityTeamMember otm02=new OpportunityTeamMember(userId=testUsrList[1].Id,
                                    TeamMemberRole='Global Account Manager',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm02);

        OpportunityTeamMember otm03=new OpportunityTeamMember(userId=testUsrList[2].Id,
                                    TeamMemberRole='Inside Sales Rep',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm03);

        OpportunityTeamMember otm04=new OpportunityTeamMember(userId=testUsrList[3].Id,
                                    //TeamMemberRole='Services Account Executive',
                                    TeamMemberRole='Services Sales Rep Bus. Solution Svcs', //v2.0 - CR11633 - Sales Role Change
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm04);

        OpportunityTeamMember otm05=new OpportunityTeamMember(userId=testUsrList[4].Id,
                                    TeamMemberRole='Inside Sales Rep',
                                    opportunityId = testOpportunity2.id); 
        opportunityTM.add(otm05);

        OpportunityTeamMember otm06=new OpportunityTeamMember(userId=testUsrList[5].Id,
                                    //TeamMemberRole='Services Account Executive',
                                    TeamMemberRole='Services Sales Rep Bus. Solution Svcs', //v2.0 - CR11633 - Sales Role Change
                                    opportunityId = testOpportunity2.id); 
        opportunityTM.add(otm06);
        
        //v2.0 Start - CR11633 - Added Sales Role Change
        OpportunityTeamMember otm07=new OpportunityTeamMember(userId=testUsrList[6].Id,
                                    TeamMemberRole='Services Sales Exec Bus. Solutions Svcs', 
                                    opportunityId = testOpportunity2.id); 
        opportunityTM.add(otm07); //v2.0 End

        insert opportunityTM;   
        TriggerExecutionController.setSkipAllTriggers(false);
        rType = [select id,name from RecordType where SobjectType='Support_Request__c'];

        for(RecordType rt:rType){              
            if(rt.Name=='Request Proposal Support'){

                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.id,
                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                Project_Duration_months__c = 12.00,Support_owner__c=testUsrList[0].Id,Support_Owner_Team_Role__c='Buddy');
                srArray.add(SupportRequestItem); 

                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity2.id,
                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                Project_Duration_months__c = 12.00,Support_owner__c=testUsrList[0].Id,Support_Owner_Team_Role__c='Buddy');
                srArray.add(SupportRequestItem);     
            }//end of if 'Request Proposal Support'

            else if(rt.Name=='Request Contracts Support'){                       
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Contract_Support__c ='New Contract' , Opportunity__c=testOpportunity.id,
                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                Project_Duration_months__c = 12.00); 
                srArray.add(SupportRequestItem);

                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Contract_Support__c ='Statement of Work' , Opportunity__c=testOpportunity.Id,
                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                Project_Duration_months__c = 12.00,Support_owner__c=testUsrList[2].Id,Support_Owner_Team_Role__c='APOS Inside Sales Rep');
                srArray.add(SupportRequestItem);
            }//end of if 'Request Contract Support'

            else if(rt.Name=='Request Custom Service Support'){
                SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                Project_Duration_months__c = 12.00, Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Preliminary/conditional pricing', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);

                //R3.0
                /*SupportRequestItem=new Support_Request__c(RecordTypeId=rt.Id, Custom_Service_Support__c='US FED Specialized Support', Opportunity__c=testOpportunity.Id,
                Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                Project_Duration_months__c = 12.00,Support_owner__c=testUsrList[3].Id,Support_Owner_Team_Role__c='ISG Inside Sales Rep', Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Contract renegotiation', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
                srArray.add(SupportRequestItem);*/
            }
        } //end of for loop

        Test.startTest();
       
       TriggerExecutionController.setSkipAllTriggers(true);
        insert srArray;        
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest(); 

        List<Support_Request__c> srList=[select Account_Executive_Email__c,Global_Account_Manager_Email__c,
                                        Inside_Sales_Rep_Email__c,Services_Account_Executive_Email__c,
                                        Services_Client_Specialist_Email__c,Services_Enterprise_Specialist_Email__c,
                                        Services_Sales_Rep_Email__c,Sys_Eng_Email__c,System_Consultant_Email__c,
                                        Technical_Sales_Rep_Email__c,Support_owner__c,Opportunity__c, Services_Sales_Executive_Email__c   
                                        from Support_Request__c 
                                        WHERE id IN:srArray];       
                                         
        for (Support_Request__c srItem :srList){
            if(srItem.Support_owner__c!=null){
                if(srItem.Opportunity__c==testOpportunity.Id){  

                    System.assertEquals(testUsrList[0].Email,srItem.Account_Executive_Email__c);            
                    System.assertEquals(testUsrList[1].Email,srItem.Global_Account_Manager_Email__c);           
                    System.assertEquals(testUsrList[2].Email,srItem.Inside_Sales_Rep_Email__c);            
                    System.assertEquals(testUsrList[3].Email,srItem.Services_Account_Executive_Email__c);
                    System.assertEquals(null,srItem.Services_Client_Specialist_Email__c);            
                    System.assertEquals(null,srItem.Services_Enterprise_Specialist_Email__c);           
                    System.assertEquals(null,srItem.Services_Sales_Rep_Email__c);            
                    System.assertEquals(null,srItem.Sys_Eng_Email__c);
                    System.assertEquals(null,srItem.System_Consultant_Email__c);           
                    System.assertEquals(null,srItem.Technical_Sales_Rep_Email__c);

                } 
                if(srItem.Opportunity__c==testOpportunity2.Id){  

                    System.assertEquals(null,srItem.Account_Executive_Email__c);            
                    System.assertEquals(null,srItem.Global_Account_Manager_Email__c);           
                    System.assertEquals(testUsrList[4].Email,srItem.Inside_Sales_Rep_Email__c);            
                    System.assertEquals(testUsrList[5].Email,srItem.Services_Account_Executive_Email__c);
                    System.assertEquals(testUsrList[6].Email,srItem.Services_Sales_Executive_Email__c); //v2.0 Added
                    System.assertEquals(null,srItem.Services_Client_Specialist_Email__c);            
                    System.assertEquals(null,srItem.Services_Enterprise_Specialist_Email__c);           
                    System.assertEquals(null,srItem.Services_Sales_Rep_Email__c);            
                    System.assertEquals(null,srItem.Sys_Eng_Email__c);
                    System.assertEquals(null,srItem.System_Consultant_Email__c);           
                    System.assertEquals(null,srItem.Technical_Sales_Rep_Email__c);

                } 

            } 
            if(srItem.Support_owner__c==null){
                System.assertEquals(null,srItem.Account_Executive_Email__c);            
                System.assertEquals(null,srItem.Global_Account_Manager_Email__c);           
                System.assertEquals(null,srItem.Inside_Sales_Rep_Email__c);            
                System.assertEquals(null,srItem.Services_Account_Executive_Email__c);
                System.assertEquals(null,srItem.Services_Client_Specialist_Email__c);            
                System.assertEquals(null,srItem.Services_Enterprise_Specialist_Email__c);           
                System.assertEquals(null,srItem.Services_Sales_Rep_Email__c);            
                System.assertEquals(null,srItem.Sys_Eng_Email__c);
                System.assertEquals(null,srItem.System_Consultant_Email__c);           
                System.assertEquals(null,srItem.Technical_Sales_Rep_Email__c);
            }

        }


        system.debug('##HJ: Stop test_AssociateSalesTeamMemberEmail');         

    }//end of test_AssociateSalesTeamMemberEmail

    static testmethod void test_ChangeSupportOwnerAndTMRole(){
        TriggerExecutionController.setSkipAllTriggers(true);
        OpportunityTeamMember[] opportunityTM=new List<OpportunityTeamMember>();
        List<User> testUsrList = new List<User>();
        List<Support_Request__c> testSupportRequestList = new List<Support_Request__c>();
        Support_Request__c[] srArray=new List<Support_Request__c>();
        Support_Request__c SupportRequestItem;
        RecordType rType;

        Account account=new Account(name='Test Account');
        insert account;

        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                        Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                        Solution_Type__c='Business Processing', 
                                        StageName='Plan - 1%');     
        ProcessFlowTriggerController.isTest = true;
        insert testOpportunity;



        //Create Test User  Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        for (integer i=0; i<4;i++){
            User user = new User(Username='test' +i+ System.currentTimeMillis() + '@test.com',
            Alias = 'test'+i, 
            Email='test'+ i +'@dell.com', 
            FirstName='Tfirst'+i, 
            LastName='TLast'+i,
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345'+i );

            testUsrList.add(user);   
        }

        insert testUsrList;

        OpportunityTeamMember otm01=new OpportunityTeamMember(userId=testUsrList[0].Id,
                                    TeamMemberRole='Account Executive',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm01);

        OpportunityTeamMember otm02=new OpportunityTeamMember(userId=testUsrList[1].Id,
                                    TeamMemberRole='Global Account Manager',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm02);

        OpportunityTeamMember otm03=new OpportunityTeamMember(userId=testUsrList[2].Id,
                                    TeamMemberRole='Inside Sales Rep',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm03);

        OpportunityTeamMember otm04=new OpportunityTeamMember(userId=testUsrList[3].Id,
                                    //TeamMemberRole='Services Account Executive', 
                                    TeamMemberRole='Services Sales Rep Bus. Solution Svcs', //v2.0 - CR11633 - Sales Role Change
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm04);

        insert opportunityTM;   

        rType = [select id,name from RecordType where SobjectType='Support_Request__c' and name='Request Proposal Support' limit 1];



        SupportRequestItem=new Support_Request__c(RecordTypeId=rType.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.id,
                            Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                            Project_Duration_months__c = 12.00,Support_owner__c=testUsrList[0].Id,Support_Owner_Team_Role__c='Buddy');


        TriggerExecutionController.setSkipAllTriggers(false);    
        Test.startTest();
        insert SupportRequestItem;


        Support_Request__c supportRequestVar=[select Account_Executive_Email__c,Global_Account_Manager_Email__c,
                                            Inside_Sales_Rep_Email__c,Services_Account_Executive_Email__c,
                                            Services_Client_Specialist_Email__c,Services_Enterprise_Specialist_Email__c,
                                            Services_Sales_Rep_Email__c,Sys_Eng_Email__c,System_Consultant_Email__c,
                                            Technical_Sales_Rep_Email__c,Support_owner__c  
                                            from Support_Request__c 
                                            WHERE id=:SupportRequestItem.Id];       



        if(SupportRequestItem.Support_owner__c!=null){
            System.assertEquals(testUsrList[0].Email,supportRequestVar.Account_Executive_Email__c);            
            System.assertEquals(testUsrList[1].Email,supportRequestVar.Global_Account_Manager_Email__c);           
            System.assertEquals(testUsrList[2].Email,supportRequestVar.Inside_Sales_Rep_Email__c);            
            System.assertEquals(testUsrList[3].Email,supportRequestVar.Services_Account_Executive_Email__c);
            System.assertEquals(null,supportRequestVar.Services_Client_Specialist_Email__c);            
            System.assertEquals(null,supportRequestVar.Services_Enterprise_Specialist_Email__c);           
            System.assertEquals(null,supportRequestVar.Services_Sales_Rep_Email__c);            
            System.assertEquals(null,supportRequestVar.Sys_Eng_Email__c);
            System.assertEquals(null,supportRequestVar.System_Consultant_Email__c);           
            System.assertEquals(null,supportRequestVar.Technical_Sales_Rep_Email__c);
        }

        SupportRequestItem.Support_owner__c=testUsrList[2].Id;
        otm03.TeamMemberRole='Services Enterprise Specialist';             

        update otm03; 
        update SupportRequestItem;
        Test.stopTest();

        Support_Request__c supportRequestElt=[select Account_Executive_Email__c,Global_Account_Manager_Email__c,
                                            Inside_Sales_Rep_Email__c,Services_Account_Executive_Email__c,
                                            Services_Client_Specialist_Email__c,Services_Enterprise_Specialist_Email__c,
                                            Services_Sales_Rep_Email__c,Sys_Eng_Email__c,System_Consultant_Email__c,
                                            Technical_Sales_Rep_Email__c,Support_owner__c  
                                            from Support_Request__c 
                                            WHERE id=:SupportRequestItem.Id];       



        if(SupportRequestItem.Support_owner__c!=null){
            System.assertEquals(testUsrList[0].Email,supportRequestElt.Account_Executive_Email__c);            
            System.assertEquals(testUsrList[1].Email,supportRequestElt.Global_Account_Manager_Email__c);           
            System.assertEquals(null,supportRequestElt.Inside_Sales_Rep_Email__c);            
            System.assertEquals(testUsrList[3].Email,supportRequestElt.Services_Account_Executive_Email__c);
            System.assertEquals(null,supportRequestElt.Services_Client_Specialist_Email__c);            
            System.assertEquals(testUsrList[2].Email,supportRequestElt.Services_Enterprise_Specialist_Email__c);           
            System.assertEquals(null,supportRequestElt.Services_Sales_Rep_Email__c);            
            System.assertEquals(null,supportRequestElt.Sys_Eng_Email__c);
            System.assertEquals(null,supportRequestElt.System_Consultant_Email__c);           
            System.assertEquals(null,supportRequestElt.Technical_Sales_Rep_Email__c);
        }


        system.debug('##HJ: Stop test_ChangeSupportOwnerAndTMRole');         

    }//end of test_ChangeSupportOwnerAndTMRole
    
    static testmethod void test_ChangeTMRole(){
        TriggerExecutionController.setSkipAllTriggers(true);
        OpportunityTeamMember[] opportunityTM=new List<OpportunityTeamMember>();
        List<User> testUsrList = new List<User>();
        List<Support_Request__c> testSupportRequestList = new List<Support_Request__c>();
        Support_Request__c[] srArray=new List<Support_Request__c>();
        Support_Request__c SupportRequestItem;
        RecordType rType;

        Account account=new Account(name='Test Account');
        insert account;

        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                    Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                    Type='Deal/Bid Direct', CloseDate= system.today(), 
                                    Solution_Type__c='Business Processing', 
                                    StageName='Plan - 1%');     
                                    
        ProcessFlowTriggerController.isTest = true;
        insert testOpportunity;  // inserting test opportunity     


        //Create Test User Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        for (integer i=0; i<4;i++){
            User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
            Alias = 'test'+i, 
            Email='test'+ i +'@dell.com', 
            FirstName='Tfirst'+i, 
            LastName='TLast'+i,
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345'+i );

            testUsrList.add(user);   
        }

        insert testUsrList;

        OpportunityTeamMember otm01=new OpportunityTeamMember(userId=testUsrList[0].Id,
                                    TeamMemberRole='Account Executive',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm01);

        OpportunityTeamMember otm02=new OpportunityTeamMember(userId=testUsrList[1].Id,
                                    TeamMemberRole='Global Account Manager',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm02);

        OpportunityTeamMember otm03=new OpportunityTeamMember(userId=testUsrList[2].Id,
                                    TeamMemberRole='Inside Sales Rep',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm03);



        insert opportunityTM;   

        rType = [select id,name from RecordType where SobjectType='Support_Request__c' and name='Request Proposal Support' limit 1];



        SupportRequestItem=new Support_Request__c(RecordTypeId=rType.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.id,
        Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
        Project_Duration_months__c = 12.00,Support_owner__c=testUsrList[0].Id,Support_Owner_Team_Role__c='Buddy');


        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        insert SupportRequestItem;


        Support_Request__c supportRequestVar=[select Account_Executive_Email__c,Global_Account_Manager_Email__c,
                                            Inside_Sales_Rep_Email__c,Services_Account_Executive_Email__c,
                                            Services_Client_Specialist_Email__c,Services_Enterprise_Specialist_Email__c,
                                            Services_Sales_Rep_Email__c,Sys_Eng_Email__c,System_Consultant_Email__c,
                                            Technical_Sales_Rep_Email__c,Support_owner__c  
                                            from Support_Request__c 
                                            WHERE id=:SupportRequestItem.Id];       


                                  
        System.debug('supportRequestVar.Account_Executive_Email__c'+supportRequestVar.Account_Executive_Email__c);     
        System.assertEquals(testUsrList[0].Email,supportRequestVar.Account_Executive_Email__c);            
        System.assertEquals(testUsrList[1].Email,supportRequestVar.Global_Account_Manager_Email__c);           
        System.assertEquals(testUsrList[2].Email,supportRequestVar.Inside_Sales_Rep_Email__c);            
        System.assertEquals(null,supportRequestVar.Services_Account_Executive_Email__c);
        System.assertEquals(null,supportRequestVar.Services_Client_Specialist_Email__c);            
        System.assertEquals(null,supportRequestVar.Services_Enterprise_Specialist_Email__c);           
        System.assertEquals(null,supportRequestVar.Services_Sales_Rep_Email__c);            
        System.assertEquals(null,supportRequestVar.Sys_Eng_Email__c);
        System.assertEquals(null,supportRequestVar.System_Consultant_Email__c);           
        System.assertEquals(null,supportRequestVar.Technical_Sales_Rep_Email__c);

        OpportunityTeamMember otm04=new OpportunityTeamMember(userId=testUsrList[3].Id,
                                    TeamMemberRole='Account Executive',
                                    opportunityId = testOpportunity.id); 
        insert otm04;      
        delete otm03;



        supportRequestVar.Support_owner__c=testUsrList[2].Id;          

        update supportRequestVar;

        Test.stopTest();

        OpportunityTeamMember temaMember=[Select userId,TeamMemberRole from OpportunityTeamMember where id=:otm04.id];

        Support_Request__c supportRequestElt=[select Account_Executive_Email__c,Global_Account_Manager_Email__c,
                                            Inside_Sales_Rep_Email__c,Services_Account_Executive_Email__c,
                                            Services_Client_Specialist_Email__c,Services_Enterprise_Specialist_Email__c,
                                            Services_Sales_Rep_Email__c,Sys_Eng_Email__c,System_Consultant_Email__c,
                                            Technical_Sales_Rep_Email__c,Support_owner__c  
                                            from Support_Request__c 
                                            WHERE id=:SupportRequestItem.Id];       


        System.assertNotEquals(null,supportRequestElt.Account_Executive_Email__c);           
        System.assertEquals(testUsrList[1].Email,supportRequestElt.Global_Account_Manager_Email__c);           
        System.assertEquals(null,supportRequestElt.Inside_Sales_Rep_Email__c);            
        System.assertEquals(null,supportRequestElt.Services_Account_Executive_Email__c);
        System.assertEquals(null,supportRequestElt.Services_Client_Specialist_Email__c);            
        System.assertEquals(null,supportRequestElt.Services_Enterprise_Specialist_Email__c);           
        System.assertEquals(null,supportRequestElt.Services_Sales_Rep_Email__c);            
        System.assertEquals(null,supportRequestElt.Sys_Eng_Email__c);
        System.assertEquals(null,supportRequestElt.System_Consultant_Email__c);           
        System.assertEquals(null,supportRequestElt.Technical_Sales_Rep_Email__c);           



        system.debug('##HJ: Stop test_ChangeTM');         

    }//end of test_ChangeTMRole

    
    
    static testmethod void test_NoOpportunityTeamMembers(){
        TriggerExecutionController.setSkipAllTriggers(true);
        OpportunityTeamMember[] opportunityTM=new List<OpportunityTeamMember>();
        List<User> testUsrList = new List<User>();
        List<Support_Request__c> testSupportRequestList = new List<Support_Request__c>();
        Support_Request__c[] srArray=new List<Support_Request__c>();
        Support_Request__c SupportRequestItem;
        RecordType rType;

        Account account=new Account(name='Test Account');
        insert account;

        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                    Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                    Type='Deal/Bid Direct', CloseDate= system.today(), 
                                    Solution_Type__c='Business Processing', 
                                    StageName='Plan - 1%');     
        ProcessFlowTriggerController.isTest = true;
        insert testOpportunity;  // inserting test opportunity     


        //Create Test User Data 
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ]; 
        for (integer i=0; i<4;i++){
            User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
            Alias = 'test'+i, 
            Email='test'+ i +'@dell.com', 
            FirstName='Tfirst'+i, 
            LastName='TLast'+i,
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345'+i );

            testUsrList.add(user);   
        }

        insert testUsrList;


        rType = [select id,name from RecordType where SobjectType='Support_Request__c' and name='Request Proposal Support' limit 1];



        SupportRequestItem=new Support_Request__c(RecordTypeId=rType.Id, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.id,
                            Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
                            Project_Duration_months__c = 12.00,Support_owner__c=testUsrList[0].Id,Support_Owner_Team_Role__c='Buddy');


        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        insert SupportRequestItem;


        Support_Request__c supportRequestVar=[select Account_Executive_Email__c,Global_Account_Manager_Email__c,
                                            Inside_Sales_Rep_Email__c,Services_Account_Executive_Email__c,
                                            Services_Client_Specialist_Email__c,Services_Enterprise_Specialist_Email__c,
                                            Services_Sales_Rep_Email__c,Sys_Eng_Email__c,System_Consultant_Email__c,
                                            Technical_Sales_Rep_Email__c,Support_owner__c  
                                            from Support_Request__c 
                                            WHERE id=:SupportRequestItem.Id];       



        System.debug('supportRequestVar.Account_Executive_Email__c'+supportRequestVar.Account_Executive_Email__c);     
        System.assertEquals(null,supportRequestVar.Account_Executive_Email__c);            
        System.assertEquals(null,supportRequestVar.Global_Account_Manager_Email__c);           
        System.assertEquals(null,supportRequestVar.Inside_Sales_Rep_Email__c);            
        System.assertEquals(null,supportRequestVar.Services_Account_Executive_Email__c);
        System.assertEquals(null,supportRequestVar.Services_Client_Specialist_Email__c);            
        System.assertEquals(null,supportRequestVar.Services_Enterprise_Specialist_Email__c);           
        System.assertEquals(null,supportRequestVar.Services_Sales_Rep_Email__c);            
        System.assertEquals(null,supportRequestVar.Sys_Eng_Email__c);
        System.assertEquals(null,supportRequestVar.System_Consultant_Email__c);           
        System.assertEquals(null,supportRequestVar.Technical_Sales_Rep_Email__c);

        OpportunityTeamMember otm01=new OpportunityTeamMember(userId=testUsrList[0].Id,
                                    TeamMemberRole='Account Executive',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm01);

        OpportunityTeamMember otm02=new OpportunityTeamMember(userId=testUsrList[1].Id,
                                    TeamMemberRole='Global Account Manager',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm02);

        OpportunityTeamMember otm03=new OpportunityTeamMember(userId=testUsrList[2].Id,
                                    TeamMemberRole='Inside Sales Rep',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm03);

        OpportunityTeamMember otm04=new OpportunityTeamMember(userId=testUsrList[3].Id,
                                    //TeamMemberRole='Services Account Executive',
                                    TeamMemberRole='Services Sales Rep Bus. Solution Svcs', //v2.0 - CR11633 - Sales Role Change
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm04);


        insert opportunityTM;        




        SupportRequestItem.Support_owner__c=testUsrList[2].Id;          

        update SupportRequestItem;





        Support_Request__c supportRequestElt=[select Account_Executive_Email__c,Global_Account_Manager_Email__c,
                                            Inside_Sales_Rep_Email__c,Services_Account_Executive_Email__c,
                                            Services_Client_Specialist_Email__c,Services_Enterprise_Specialist_Email__c,
                                            Services_Sales_Rep_Email__c,Sys_Eng_Email__c,System_Consultant_Email__c,
                                            Technical_Sales_Rep_Email__c,Support_owner__c  
                                            from Support_Request__c 
                                            WHERE id=:SupportRequestItem.Id];       


        System.assertEquals(testUsrList[0].Email,supportRequestElt.Account_Executive_Email__c);           
        System.assertEquals(testUsrList[1].Email,supportRequestElt.Global_Account_Manager_Email__c);           
        System.assertEquals(testUsrList[2].Email,supportRequestElt.Inside_Sales_Rep_Email__c);            
        System.assertEquals(testUsrList[3].Email,supportRequestElt.Services_Account_Executive_Email__c);
        System.assertEquals(null,supportRequestElt.Services_Client_Specialist_Email__c);            
        System.assertEquals(null,supportRequestElt.Services_Enterprise_Specialist_Email__c);           
        System.assertEquals(null,supportRequestElt.Services_Sales_Rep_Email__c);            
        System.assertEquals(null,supportRequestElt.Sys_Eng_Email__c);
        System.assertEquals(null,supportRequestElt.System_Consultant_Email__c);           
        System.assertEquals(null,supportRequestElt.Technical_Sales_Rep_Email__c);


        delete opportunityTM;

        SupportRequestItem.Support_owner__c=testUsrList[3].Id;          

        update SupportRequestItem; 

        Test.stopTest();

        Support_Request__c supportRequestObj=[select Account_Executive_Email__c,Global_Account_Manager_Email__c,
                                            Inside_Sales_Rep_Email__c,Services_Account_Executive_Email__c,
                                            Services_Client_Specialist_Email__c,Services_Enterprise_Specialist_Email__c,
                                            Services_Sales_Rep_Email__c,Sys_Eng_Email__c,System_Consultant_Email__c,
                                            Technical_Sales_Rep_Email__c,Support_owner__c  
                                            from Support_Request__c 
                                            WHERE id=:SupportRequestItem.Id];       


        System.assertEquals(null,supportRequestObj.Account_Executive_Email__c);           
        System.assertEquals(null,supportRequestObj.Global_Account_Manager_Email__c);           
        System.assertEquals(null,supportRequestObj.Inside_Sales_Rep_Email__c);            
        System.assertEquals(null,supportRequestObj.Services_Account_Executive_Email__c);
        System.assertEquals(null,supportRequestObj.Services_Client_Specialist_Email__c);            
        System.assertEquals(null,supportRequestObj.Services_Enterprise_Specialist_Email__c);           
        System.assertEquals(null,supportRequestObj.Services_Sales_Rep_Email__c);            
        System.assertEquals(null,supportRequestObj.Sys_Eng_Email__c);
        System.assertEquals(null,supportRequestObj.System_Consultant_Email__c);           
        System.assertEquals(null,supportRequestObj.Technical_Sales_Rep_Email__c);          



        system.debug('##HJ: Stop test_NoOpportunityTeamMembers');         

    }//end of test_ChangeTMRole

//Test method for CR 7098 -Start
static testmethod void test_AssociateSalesTeamMemberUserId(){
        TriggerExecutionController.setSkipAllTriggers(true);
        OpportunityTeamMember[] opportunityTM=new List<OpportunityTeamMember>();
        List<User> testUsrList = new List<User>();
        List<Support_Request__c> testSupportRequestList = new List<Support_Request__c>();
        Support_Request__c[] srArray=new List<Support_Request__c>();
        Support_Request__c SupportRequestItem;
        RecordType[] rType;

        Sales_Channel_Group__c sc1 = new Sales_Channel_Group__c (name ='SC1', Sales_Method_Name__c ='COMMERCIAL',  Segment_Business_Unit_Name__c='GLOBAl COMMERCIAL');
        Sales_Channel_Group__c sc2 = new Sales_Channel_Group__c (name ='SC2', Sales_Method_Name__c ='ENTREPRISE',  Segment_Sub_Business_Unit_Name__c ='WW GCCS');
        
        List<Sales_Channel_Group__c > scList = new List<Sales_Channel_Group__c>();
        scList.add(sc1);
        scList.add(sc2);
         
        insert scList;        
        
        Account account=new Account(name='Test Account', Sales_Channel__c= sc1.Id);
        
        Account account2=new Account(name='Test Account 2', Sales_Channel__c= sc2.Id);
        
        List<Account> accountList = new List<Account>();
        accountList.add(account);
        accountList.add(account2);
        
        insert accountList ;

        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id, 
                                    Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                    Type='Deal/Bid Direct', CloseDate= system.today(), 
                                    Solution_Type__c='Business Processing', 
                                    StageName='Plan - 1%');     

        //insert testOpportunity;

        Opportunity testOpportunity2 = new Opportunity(RecordTypeId=rectype.Id, 
                                    Name='Test Opportunity2', AccountId= account2.Id, CurrencyIsoCode='USD',
                                    Type='Deal/Bid Direct', CloseDate= system.today(), 
                                    Solution_Type__c='Business Processing', 
                                    StageName='Plan - 1%');     

        //insert testOpportunity2;

    List<Opportunity> opportunityList = new List<Opportunity>();
    opportunityList.add(testOpportunity);
    opportunityList.add(testOpportunity2);
    ProcessFlowTriggerController.isTest = true;
    insert opportunityList;
     TriggerExecutionController.setSkipAllTriggers(false);
    //Ranjini
    Support_Request_Submission_Rule__c SRRule1 = new Support_Request_Submission_Rule__c();
    SRRule1.name = 'Test SRRule';
    SRRule1.Resource_Type__c = 'Services Finance Support';
    SRRule1.Condition__c = '>=';
    SRRule1.Unweighted_Rev_Services_Only__c = 0;
    SRRule1.Stage__c = 'Plan - 1%';
    insert SRRule1;
    //Ranjini

        //Create Test User Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        for (integer i=0; i<6;i++){
            User user = new User(Username='test' +i+ System.currentTimeMillis() + '@test.com',
            Alias = 'test'+i, 
            Email='test'+ i +'@dell.com', 
            FirstName='Tfirst'+i, 
            LastName='TLast'+i,
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345'+i );

            testUsrList.add(user);   
        }

        insert testUsrList;

        OpportunityTeamMember otm01=new OpportunityTeamMember(userId=testUsrList[0].Id,
                                    TeamMemberRole='Account Executive',
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm01);

        OpportunityTeamMember otm02=new OpportunityTeamMember(userId=testUsrList[1].Id,
                                    //TeamMemberRole='Services Account Executive', 
                                    TeamMemberRole='Services Sales Rep Bus. Solution Svcs', //v2.0 - CR11633 - Sales Role Change
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm02);

        OpportunityTeamMember otm03=new OpportunityTeamMember(userId=testUsrList[2].Id,
                                    //TeamMemberRole='Services Sales Executive', 
                                    TeamMemberRole='Services Sales Exec Bus. Solutions Svcs', //v2.0 - CR11633 - Sales Role Change
                                    opportunityId = testOpportunity.id); 
        opportunityTM.add(otm03);
                                            
        OpportunityTeamMember otm04=new OpportunityTeamMember(userId=testUsrList[4].Id,
                                    //TeamMemberRole='Services Sales Executive',
                                    TeamMemberRole='Services Sales Exec Bus. Solutions Svcs', //v2.0 - CR11633 - Sales Role Change
                                    opportunityId = testOpportunity2.id); 
        opportunityTM.add(otm04);

        OpportunityTeamMember otm05=new OpportunityTeamMember(userId=testUsrList[5].Id,
                                    //TeamMemberRole='Services Account Executive',
                                    TeamMemberRole='Services Sales Rep Bus. Solution Svcs', //v2.0 - CR11633 - Sales Role Change
                                    opportunityId = testOpportunity2.id); 
        opportunityTM.add(otm05);

        OpportunityTeamMember otm06=new OpportunityTeamMember(userId=testUsrList[3].Id,
                                    TeamMemberRole='Client & Compute Sales Exec', 
                                    opportunityId = testOpportunity2.id); 
        opportunityTM.add(otm06);
        
        insert opportunityTM; 
         

        rType = [select id,name from RecordType where SobjectType='Support_Request__c' AND name='Request Custom Service Support' limit 1];

        SupportRequestItem=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity.Id,
                            Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                            Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Firm offer', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');    
        srArray.add(SupportRequestItem);                    
        SupportRequestItem=new Support_Request__c(RecordTypeId=rType[0].Id, Custom_Service_Support__c='Custom Service Solution', Opportunity__c=testOpportunity2.Id,
                        Deliverable_Due_Date__c=Date.newInstance(2012,05,07), Submission_Deadline__c=Date.newInstance(2012,12,12),
                        Project_Duration_months__c = 12.00,Services_Finance_Support__c = 'Yes', Customer_Pricing_Due_Date__c = System.Today(), Pricing_Cycle_Status__c = 'Firm offer', HW_SW_or_other_Financing_Dell_owned__c = 'Yes');                                               
        srArray.add(SupportRequestItem);                            

        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        insert srArray;        
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest(); 

        List<Support_Request__c> srList=[select Account_Executive__c,Services_Account_Executive__c,Services_Sales_Executive__c,Opportunity__c  
                                        from Support_Request__c 
                                        WHERE id =:srArray];       
                                                            
        for (Support_Request__c srItem :srList){
                if(srItem.Opportunity__c==testOpportunity.Id){  
                    System.assertEquals(testUsrList[0].Id,srItem.Account_Executive__c);            
                    System.assertEquals(testUsrList[1].Id,srItem.Services_Account_Executive__c);           
                    System.assertEquals(testUsrList[2].Id,srItem.Services_Sales_Executive__c);            
                } 
                if(srItem.Opportunity__c==testOpportunity2.Id){  
                    System.assertEquals(testUsrList[3].Id,srItem.Account_Executive__c);                   
                    System.assertEquals(testUsrList[5].Id,srItem.Services_Account_Executive__c);            
                    System.assertEquals(testUsrList[4].Id,srItem.Services_Sales_Executive__c);
                } 
        }


        system.debug('####: Stop test_AssociateSalesTeamMemberUserId');         

    }//end of test_AssociateSalesTeamMemberUserID
    
//Test method for CR 7098 -End

                    
}// end of class