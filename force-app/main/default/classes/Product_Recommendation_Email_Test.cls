/*
History:
  Revision CR Number   Release No      Date            Modified By     Description     
--------------------------------------------------------------------------------------
* 1.0       13574      DCS-FY17-1101                     Shivam         Test Class for Product_Recommendation_Email_Scheduler and Product_Recommendation_Email
  2.0       14932      FY18-DCS-1101                     Naga           Added new methods to handle 'Null' value for 'Segment_Name__c' and added 'Segment_Business_Unit_Name__c' field value in the existing methods.
*/
@isTest
private class Product_Recommendation_Email_Test {

	//insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
	@testSetup static void setup() {
		OWD__c OWDsetting = new OWD__c();
		OWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
		OWDsetting.Oppty_Stage10__c = 'Discover - 10%';
		OWDsetting.Oppty_Stage100__c = 'Win - 100%';
		OWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
		OWDsetting.Oppty_Stage60__c = 'Propose - 60%';
		OWDsetting.Oppty_Stage90__c = 'Commit - 90%';
		OWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
		OWDsetting.Oppty_Stage1__c = 'Plan - 1%';
		
		insert OWDsetting;
	}	
	//insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
    
    //Fetching custom settings for OWD
    static OWD__c owd = OWD__c.getOrgDefaults();

    static testMethod void octaneEmailTest(){
        TriggerExecutionController.setSkipAccountTriggers(true); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);        
        
        Octane_Segment_Quantity_Mapping__c objCst = new Octane_Segment_Quantity_Mapping__c(Name='CHANNEL',Quantity__c = 100,IsActive__c=true,Segment_Name__c ='CHANNEL',Segment_Business_Unit_Name__c = 'NA COMMERCIAL');
        insert objCst;
        
        Octane_Segment_Quantity_Mapping_EMEA__c objCstEMEA = new Octane_Segment_Quantity_Mapping_EMEA__c(Name='ACQUISITION PRIVATE',Quantity__c = 100,IsActive__c=true,Segment_Name_EMEA__c ='ACQUISITION PRIVATE',Segment_Business_Unit_Name_EMEA__c = 'EMEA COMMERCIAL');
        insert objCstEMEA;
        
        Octane_Segment_Quantity_Mapping_APJ__c objCstAPJ = new Octane_Segment_Quantity_Mapping_APJ__c(Name='SBJP',Quantity__c = 100,IsActive__c=true,Segment_Name_APJ__c='SBJP',Segment_Business_Unit_Name_APJ__c = 'APJ CSB');
        insert objCstAPJ;
        
        Octane_Config_Settings__c objCustom_Production = new Octane_Config_Settings__c(Name='Production',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME',Hour_Limit_for_Sending_Email__c=2);
        insert objCustom_Production;
        Octane_Config_Settings__c objCustom_Sandbox = new Octane_Config_Settings__c(Name='Sandbox',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME',Hour_Limit_for_Sending_Email__c=2);
        insert objCustom_Sandbox;
        
        Sales_Channel_Group__c sl = new Sales_Channel_Group__c(Name='Test',Segment_Business_Unit_Name__c = 'NA COMMERCIAL');
        INSERT sl;
        
        Account testAccount = new Account(Name='Test SAVO Account',Sales_Channel__c=sl.Id,Account_Country_Code__c='US');        
        insert testAccount;     
        
        //Create Opportunity
        Opportunity testOpp = new Opportunity(Name='Test SAVO Opportunity', AccountId=testAccount.Id,RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp;

        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newProd = new Product2(Name = 'Test Product1',ProductCode = 'TP1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,Product_ID__c='911');                      
        insert newProd;
        
        PricebookEntry PBE1= new PricebookEntry (Product2ID=newProd.id,Pricebook2ID=pbk1,isActive=true,useStandardPrice=false,UnitPrice = 50);                                      
        insert PBE1;
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOpp.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =1002,Description = 'Line Description1'); 
        insert testLineItem;
        
        Opportunity testOpp1 = new Opportunity(Name='Test Demo Opportunity', AccountId=testAccount.Id,RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp1;
        
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOpp1.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =1002,Description = 'Line Description1'); 
        insert testLineItem1;
        
        Datetime yesterday = Datetime.now().addDays(-3);
        Test.setCreatedDate(testLineItem1.Id, yesterday);
        
        Datetime yesterday1 = Datetime.now().addDays(-3);
        Test.setCreatedDate(testLineItem.Id, yesterday1);
        
        TriggerExecutionController.setSkipAccountTriggers(false); 
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);       

        Test.startTest();
        Product_Recommendation_Email batchObj = new Product_Recommendation_Email('Select Id,StageName,Account.Sales_Channel__r.Segment_Name__c,Account.Account_Country_Code__c,Account.Sales_Channel__r.Segment_Business_Unit_Name__c ,OwnerId,RecordType.Name from Opportunity');
        database.executebatch(batchObj,2);
        Test.stopTest();
    }
    
    static testMethod void octaneEmailTest2(){
        TriggerExecutionController.setSkipAccountTriggers(true); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);        
        
        Octane_Segment_Quantity_Mapping__c objCst = new Octane_Segment_Quantity_Mapping__c(Name='CHANNEL',Quantity__c = 100,IsActive__c=true,Segment_Name__c ='CHANNEL',Segment_Business_Unit_Name__c = 'NA COMMERCIAL');
        insert objCst;
        
        Octane_Segment_Quantity_Mapping_EMEA__c objCstEMEA = new Octane_Segment_Quantity_Mapping_EMEA__c(Name='ACQUISITION PRIVATE',Quantity__c = 100,IsActive__c=true,Segment_Name_EMEA__c ='ACQUISITION PRIVATE',Segment_Business_Unit_Name_EMEA__c = 'EMEA COMMERCIAL');
        insert objCstEMEA;
        
        Octane_Segment_Quantity_Mapping_APJ__c objCstAPJ = new Octane_Segment_Quantity_Mapping_APJ__c(Name='SBJP',Quantity__c = 100,IsActive__c=true,Segment_Name_APJ__c='SBJP',Segment_Business_Unit_Name_APJ__c = 'APJ CSB');
        insert objCstAPJ;
        
        Octane_Config_Settings__c objCustom_Production = new Octane_Config_Settings__c(Name='Production',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME',Hour_Limit_for_Sending_Email__c=2);
        insert objCustom_Production;
        Octane_Config_Settings__c objCustom_Sandbox = new Octane_Config_Settings__c(Name='Sandbox',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME',Hour_Limit_for_Sending_Email__c=2);
        insert objCustom_Sandbox;
        
        Sales_Channel_Group__c sl = new Sales_Channel_Group__c(Name='Test',Segment_Name__c='CHANNEL',Segment_Business_Unit_Name__c = 'NA COMMERCIAL');
        INSERT sl;
        
        Account testAccount = new Account(Name='Test SAVO Account',Sales_Channel__c=sl.Id,Account_Country_Code__c='US');        
        insert testAccount;     
        
        //Create Opportunity
        Opportunity testOpp = new Opportunity(Name='Test SAVO Opportunity', AccountId=testAccount.Id,RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp;

        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newProd = new Product2(Name = 'Test Product1',ProductCode = 'TP1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,Product_ID__c='911');                      
        insert newProd;
        
        PricebookEntry PBE1= new PricebookEntry (Product2ID=newProd.id,Pricebook2ID=pbk1,isActive=true,useStandardPrice=false,UnitPrice = 50);                                      
        insert PBE1;
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOpp.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =1002,Description = 'Line Description1'); 
        insert testLineItem;
        
        Opportunity testOpp1 = new Opportunity(Name='Test Demo Opportunity', AccountId=testAccount.Id,RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp1;
        
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOpp1.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =1002,Description = 'Line Description1'); 
        insert testLineItem1;
        
        Datetime yesterday = Datetime.now().addDays(-3);
        Test.setCreatedDate(testLineItem1.Id, yesterday);
        
        Datetime yesterday1 = Datetime.now().addDays(-3);
        Test.setCreatedDate(testLineItem.Id, yesterday1);
        
        TriggerExecutionController.setSkipAccountTriggers(false); 
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);       

        Test.startTest();
        Product_Recommendation_Email batchObj = new Product_Recommendation_Email('Select Id,StageName,Account.Account_Country_Code__c,Account.Sales_Channel__r.Segment_Name__c,Account.Sales_Channel__r.Segment_Business_Unit_Name__c ,OwnerId,RecordType.Name from Opportunity');
        database.executebatch(batchObj,2);
        Test.stopTest();
    }
    
    //v2.0 created for code coverage on Product_Recommendation_Email_Scheduler  class
    static testMethod void Product_Recommendation_EmailSchedulerTest() {
        TriggerExecutionController.setSkipAccountTriggers(true); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);        
        
        Octane_Segment_Quantity_Mapping__c objCst = new Octane_Segment_Quantity_Mapping__c(Name='CHANNEL',Quantity__c = 100,IsActive__c=true,Segment_Name__c ='CHANNEL',Segment_Business_Unit_Name__c = 'NA COMMERCIAL');
        insert objCst;
        
        Octane_Segment_Quantity_Mapping_EMEA__c objCstEMEA = new Octane_Segment_Quantity_Mapping_EMEA__c(Name='ACQUISITION PRIVATE',Quantity__c = 100,IsActive__c=true,Segment_Name_EMEA__c ='ACQUISITION PRIVATE',Segment_Business_Unit_Name_EMEA__c = 'EMEA COMMERCIAL');
        insert objCstEMEA;
        
        Octane_Segment_Quantity_Mapping_APJ__c objCstAPJ = new Octane_Segment_Quantity_Mapping_APJ__c(Name='SBJP',Quantity__c = 100,IsActive__c=true,Segment_Name_APJ__c='SBJP',Segment_Business_Unit_Name_APJ__c = 'APJ CSB');
        insert objCstAPJ;
        
        Octane_Config_Settings__c objCustom_Production = new Octane_Config_Settings__c(Name='Production',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME',Hour_Limit_for_Sending_Email__c=2);
        insert objCustom_Production;
        Octane_Config_Settings__c objCustom_Sandbox = new Octane_Config_Settings__c(Name='Sandbox',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME',Hour_Limit_for_Sending_Email__c=2);
        insert objCustom_Sandbox;
        
        Sales_Channel_Group__c sl = new Sales_Channel_Group__c(Name='Test',Segment_Name__c='CHANNEL',Segment_Business_Unit_Name__c = 'NA COMMERCIAL');
        INSERT sl;
        
        Account testAccount = new Account(Name='Test SAVO Account',Sales_Channel__c=sl.Id,Account_Country_Code__c='US');        
        insert testAccount;     
        
        //Create Opportunity
        Opportunity testOpp = new Opportunity(Name='Test SAVO Opportunity', AccountId=testAccount.Id,RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp;

        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newProd = new Product2(Name = 'Test Product1',ProductCode = 'TP1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,Description='Latitude',Product_ID__c='912');                      
        insert newProd;
        
        PricebookEntry PBE1= new PricebookEntry (Product2ID=newProd.id,Pricebook2ID=pbk1,isActive=true,useStandardPrice=false,UnitPrice = 50);                                      
        insert PBE1;
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOpp.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =1002,Description = 'Line Description1'); 
        insert testLineItem;
        
        Opportunity testOpp1 = new Opportunity(Name='Test Demo Opportunity', AccountId=testAccount.Id,RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp1;
        
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOpp1.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =1002,Description = 'Line Description1'); 
        insert testLineItem1;
        
        Datetime yesterday = Datetime.now().addDays(-3);
        Test.setCreatedDate(testLineItem1.Id, yesterday);
        
        Datetime yesterday1 = Datetime.now().addDays(-3);
        Test.setCreatedDate(testLineItem.Id, yesterday1);
        
        TriggerExecutionController.setSkipAccountTriggers(false); 
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        
        Test.startTest();
        String CRON_EXP = '0 0 0 * * ?';
        Product_Recommendation_Email_Scheduler  sch = new Product_Recommendation_Email_Scheduler();
        String jobId = System.schedule('batchWeeklyEmail TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
    
    static testMethod void Product_Recommendation_EmailSchedulerTest2() {
        TriggerExecutionController.setSkipAccountTriggers(true); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);        
        
        Octane_Segment_Quantity_Mapping__c objCst = new Octane_Segment_Quantity_Mapping__c(Name='CHANNEL',Quantity__c = 100,IsActive__c=true,Segment_Name__c ='CHANNEL',Segment_Business_Unit_Name__c = 'NA COMMERCIAL');
        insert objCst;
        
        Octane_Segment_Quantity_Mapping_EMEA__c objCstEMEA = new Octane_Segment_Quantity_Mapping_EMEA__c(Name='ACQUISITION PRIVATE',Quantity__c = 100,IsActive__c=true,Segment_Name_EMEA__c ='ACQUISITION PRIVATE',Segment_Business_Unit_Name_EMEA__c = 'EMEA COMMERCIAL');
        insert objCstEMEA;
        
        Octane_Segment_Quantity_Mapping_APJ__c objCstAPJ = new Octane_Segment_Quantity_Mapping_APJ__c(Name='SBJP',Quantity__c = 100,IsActive__c=true,Segment_Name_APJ__c='SBJP',Segment_Business_Unit_Name_APJ__c = 'APJ CSB');
        insert objCstAPJ;
        
        Octane_Config_Settings__c objCustom_Production = new Octane_Config_Settings__c(Name='Production',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME',Hour_Limit_for_Sending_Email__c=2);
        insert objCustom_Production;
        Octane_Config_Settings__c objCustom_Sandbox = new Octane_Config_Settings__c(Name='Sandbox',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME',Hour_Limit_for_Sending_Email__c=2);
        insert objCustom_Sandbox;
        
        Sales_Channel_Group__c sl = new Sales_Channel_Group__c(Name='Test',Segment_Business_Unit_Name__c = 'NA COMMERCIAL');
        INSERT sl;
        
        Account testAccount = new Account(Name='Test SAVO Account',Sales_Channel__c=sl.Id,Account_Country_Code__c='US');        
        insert testAccount;     
        
        //Create Opportunity
        Opportunity testOpp = new Opportunity(Name='Test SAVO Opportunity', AccountId=testAccount.Id,RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp;

        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newProd = new Product2(Name = 'Test Product1',ProductCode = 'TP1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,Description='Latitude',Product_ID__c='912');                      
        insert newProd;
        
        PricebookEntry PBE1= new PricebookEntry (Product2ID=newProd.id,Pricebook2ID=pbk1,isActive=true,useStandardPrice=false,UnitPrice = 50);                                      
        insert PBE1;
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOpp.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =1002,Description = 'Line Description1'); 
        insert testLineItem;
        
        Opportunity testOpp1 = new Opportunity(Name='Test Demo Opportunity', AccountId=testAccount.Id,RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp1;
        
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOpp1.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =1002,Description = 'Line Description1'); 
        insert testLineItem1;
        
        Datetime yesterday = Datetime.now().addDays(-3);
        Test.setCreatedDate(testLineItem1.Id, yesterday);
        
        Datetime yesterday1 = Datetime.now().addDays(-3);
        Test.setCreatedDate(testLineItem.Id, yesterday1);
        
        TriggerExecutionController.setSkipAccountTriggers(false); 
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        
        Test.startTest();
        String CRON_EXP = '0 0 0 * * ?';
        Product_Recommendation_Email_Scheduler  sch = new Product_Recommendation_Email_Scheduler();
        String jobId = System.schedule('batchWeeklyEmail TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
    
}