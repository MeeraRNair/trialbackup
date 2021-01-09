/***********************************************************
* Name          : AccountPlanControllerTest
* Description   : Controller for Business Unit Report in Account Plan
* ---------------------------------------------------------
* Revision  Name                Date             Description
* 1.0       Goldy Raj           9.Dec.2019    Story 7540275:Account Planning: Strategy Business Unit Component High Impact(Vikings)
* 1.1   Srinivasarao Mandalapu  9.Dec 2019    Story 7540279:Account Planning: Strategy Transformation Component High Impact 
* 
************************************************************/
@isTest
public class AccountPlanChartControllerTest {
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
    }   
    
    Static testMethod void testController() {
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'test4534', Email='standarduser1234@dell.com', 
                          EmailEncodingKey='UTF-8', LastName='Test12348', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,Badge_Number__c='127847789',
                          TimeZoneSidKey='America/Los_Angeles', UserName='staruser91234@dell.com');
        insert u;
        Account acc = new Account(name = 'Test Account');
        insert acc;
        SFDC_Acct_Plan__c accPlan = new SFDC_Acct_Plan__c(Name='Test AccPlan',Account__c=acc.id,Virtustream__c='N',VMware__c='N',Storage_Strategy__c='N',Services__c='N',Pivotal__c='N',Networking_Strategy__c='N',Enterprise_Infrastructure__c='N',Boomi__c='N',Client_S_P__c='N',
                                                          Compute_Servers__c='N',Client_Strategy__c='N',CS__c='N',ESG__c='N',RSA__c='N',SecureWorks__c='N',DPS__c='N',Account_Plan_Owner__c =u.Id);
        insert accPlan;
        
        
         System.runAs(u){
            Test.startTest();
        SFDC_Strategy__c strategy = new SFDC_Strategy__c(Name='Test Strategy',RecordTypeId='012A0000000GXk4IAG',When_do_you_plan_to_realize_Strategy__c='FY21 Q3',SFDC_Acct_Plan__c=accPlan.id,Strategy_Summary__c='Test',Potential_Strategy_Value__c=1234,Transformation__c='IT Transformation',
                                                         Strategy_Status__c='Created', Customer_Business_Challenges_Objectives__c='Test',Dell_s_Strategy_Response__c='Test',IT_Implications__c='Test',Which_LOB_will_you_offer__c='Boomi',
                                                         Strengths__c='Test',Threats__c='Test',Opportunities__c='Test',SWOT_Threats__c='Test',Strategy_Owner__c=u.Id);
        insert strategy;
        
       
        
            SFDC_Acct_Plan__c accou=[Select id,Account__c from SFDC_Acct_Plan__c where Name='Test AccPlan' limit 1];        
            Map<String,Integer> retnValue=AccountPlanChartController.BusinessUnitControllerFetchStrategy(accou.Id);
            System.assertEquals(1,retnValue.get('Boomi'));  
             
            Id retnVal=AccountPlanChartController.getAccountId(accou.Id);
            System.assertEquals(accou.Account__c,retnVal); 
             
            Map<String,Integer> retnValuee=AccountPlanChartController.getTranformationPillarValues(accou.Id);
			System.assertEquals(1,retnValuee.get('IT Transformation')); 
            
            String strategyStatus = AccountPlanChartController.getStrategyStatus(strategy.id);
            System.assertEquals('Created',strategyStatus); 
            Test.stopTest(); 
        }
    }
    //adding
     Private Static String createBasicObject(){
        
        Pricebook2 standardPricebook = New Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = True
        );
        update standardPricebook;
        
        Pricebook2 s = [select id, name, IsActive from Pricebook2 where IsStandard = True LIMIT 1];
        String strId = s.Id;
        Return strId;
    }
    
     Static testMethod void testControllerforUnweightedPipeline() {
         String strPId = createBasicObject();
          List<String> Qrts=new List<String>();
            //DateTime d = DateTime.newInstance(2019,11,02);
         //   insert new Fiscal_Years__c(Name = 'FY20Q3',Start_Date__c= Date.newInstance(2019,08,03),End_Date__c =Date.newInstance(2019,11,1));
            insert new Fiscal_Years__c(Name = 'FY20Q4',Start_Date__c= Date.newInstance(2019,11,02),End_Date__c =Date.newInstance(2020,1,31));
            insert new Fiscal_Years__c(Name = 'FY21Q1',Start_Date__c= Date.newInstance(2020,02,01),End_Date__c =Date.newInstance(2020,05,01)); 
            Qrts= AccountPlanChartController.getAllRollingQuarters();
            System.assertEquals(2,Qrts.size());
          list<Product2> listProduct = New list<Product2>();
            Product2 newPrdct = New Product2(name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c = 'NT - 435252',
                                         IsActive = True);
        listProduct.add(newPrdct);   
        
        
        Product2 newPrdct1 = New Product2(name = 'Test Product',
                                          Product_Line_Desc__c = 'Test Product',
                                          Product_ID__c ='NT-24567',
                                          IsActive = True);
        listProduct.add(newPrdct1); 
        
        
        Product2 newPrdct2 = New Product2(name = 'Test Product3',
                                          Product_Line_Desc__c = 'Test Product3',
                                          Product_ID__c ='NT-24500',
                                          IsActive = True);
        listProduct.add(newPrdct2);
        
        Product2 newPrdct3 = New Product2(name = 'Test Product4',
                                          Product_Line_Desc__c = 'Test Product4',
                                          Product_ID__c ='DM-0941',
                                          IsActive = True);
        listProduct.add(newPrdct3); 
        
        insert listProduct;
        
        //Creating PricebookEntry
        list<PricebookEntry> listPricebook = New list<PricebookEntry>();
        
        PricebookEntry pbe = New PricebookEntry();
        pbe.Product2Id= listProduct[0].id;
        pbe.IsActive=True;
        pbe.UnitPrice=0;
        pbe.Pricebook2Id = strPId;
        pbe.UseStandardPrice=false;                              
        listPricebook.add(Pbe);
        
        PricebookEntry pbe1 = New PricebookEntry();
        pbe1.Product2Id= listProduct[1].id;
        pbe1.IsActive=True;
        pbe1.UnitPrice=0;
        pbe1.Pricebook2Id = strPId;
        pbe1.UseStandardPrice=false;                              
        listPricebook.add(Pbe1);
        
        PricebookEntry pbe2 = New PricebookEntry();
        pbe2.Product2Id= listProduct[2].id;
        pbe2.IsActive=True;
        pbe2.UnitPrice=10;
        pbe2.Pricebook2Id = strPId;
        pbe2.UseStandardPrice=false;                              
        listPricebook.add(Pbe2);
        
        
        PricebookEntry pbe3 = New PricebookEntry();
        pbe3.Product2Id= listProduct[3].id;
        pbe3.IsActive=True;
        pbe3.UnitPrice=10;
        pbe3.Pricebook2Id = strPId;
        pbe3.UseStandardPrice=false;                              
        listPricebook.add(Pbe3);
        
        insert listPricebook;  
        
        // List<PriceBookEntry> listPriceBookList = [SELECT Id, Product2Id,Product2.Product_ID__c, pricebook2id,currencyIsoCode, Product2.Name FROM PriceBookEntry WHERE Product2.Product_ID__c=:System.Label.DummyProductId];
        // system.debug('listPriceBookList.size()'+listPriceBookList);
        
        Recordtype idRecordType = [select id, name, DeveloperName from RecordType where DeveloperName='StandardOpportunity' and sObjectType = 'Opportunity' limit 1];
        
        list<Opportunity> listOpp = New list<opportunity>();
        list<opportunity> listopp1 = New list<opportunity>();
          Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = New User(LastName = 'Chart User',
                            FirstName ='Unweight Pipeline',
                            Alias = 'jliv',
                            Email = 'Chart.Unweight@dell.com',
                            Username = 'Chart.Unweight@dell.com',
                            ProfileId = profileId.id,
                            Badge_Number__c='18368736',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        System.runAs(usr){
            Test.startTest();
          //  TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
          //  TriggerExecutionController.setSkipOpportunityTriggers(true);
            
            //Creating Account
            Account testAcc = New Account();
            testAcc.name = 'Some test Account2';        
            testAcc.status__c = 'Active';
            testAcc.Account_Country_Code__c='US';              
            insert testAcc;
              SFDC_Acct_Plan__c accPlan = new SFDC_Acct_Plan__c(Name='Test AcctPlan',Account__c=testAcc.id,Virtustream__c='N',VMware__c='N',Storage_Strategy__c='N',Services__c='N',Pivotal__c='N',Networking_Strategy__c='N',Enterprise_Infrastructure__c='N',Boomi__c='N',Client_S_P__c='N',
                                                          Compute_Servers__c='N',Client_Strategy__c='N',CS__c='N',ESG__c='N',RSA__c='N',SecureWorks__c='N',DPS__c='N',Account_Plan_Owner__c =usr.Id);
        insert accPlan;
            //Creating Opportunity
          // Skip all the triggers to avoid Too Many SOQL Query issue
           TriggerExecutionController.setSkipAllTriggers(true);
           Opportunity testOpportunity = New Opportunity();
            testOpportunity.RecordTypeid = idRecordType.id;
            testOpportunity.name='test opportunity';
            testOpportunity.Accountid=testAcc.id; 
            testOpportunity.CloseDate=system.today()  + 5;
            testopportunity.pricebook2Id = strPId;             
            testOpportunity.CurrencyIsoCode='USD';                        
            testOpportunity.StageName='Discover - 10%';  
            testOpportunity.Type='Run Rate';
            testOpportunity.Forecast_Category_Override__c='Omitted';
            testOpportunity.Probability=1;
            insert testOpportunity;
            
            // Creating Opportunity Line Items   
            list<OpportunityLineItem> listlineItem = New list<OpportunityLineItem >();
            OpportunityLineItem oppli = New OpportunityLineItem(); //---->Create OpportunityLineItem.
            oppli.PricebookEntryId= listPricebook[1].id;
            oppli.OpportunityId = testOpportunity.id;
            oppli.Quantity = 1;
            oppli.TotalPrice = 400;
            oppli.Product_Type__c='S&P';
            oppli.product2Id = listProduct[1].id;
            listlineItem.add(Oppli);
            insert listlineitem; 
         
        //   Map<String,List<Double>> mapProdData= AccountPlanChartController.getProdTypeQuarterValues(accPlan.Id);
            AccountPlanChartController.productTypeChartData(accPlan.Id);
		//	System.assertEquals(8,mapProdData.keyset().size());
            Test.stopTest();
         
     }
     
     }
    
 
}