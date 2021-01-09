@isTest
public class SpecialtyBUProductsTest {
static List<String> listObjAPINames = new List<String>{'Opportunity'};
        @testsetup 
        static void setup(){
            OWD__c oWDsetting = new OWD__c();
            oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
            oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
            oWDsetting.Oppty_Stage100__c = 'Win - 100%';
            oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
            oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
            oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
            oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
            oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
            insert oWDsetting;
            
            EMC_General_Settings__c settingData = new EMC_General_Settings__c();
            settingData.ProfilesBypassMyquotesOpptyValidation__c='Boomi Integration API Only;';        
            insert settingData;
            
        }
    static testmethod void updateSpecialBUProducts(){
        //insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "CPSDOpportunityLineItemTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;   
        Account testAccount1 = new Account(Name='Test Account');  
        insert testAccount1;
        
        Opportunity testOldOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                   AccountId=testAccount.Id, 
                                                   stagename='Discover - 10%',
                                                   Probability=10.0,
                                                   RecordTypeId=newOppRecordTypeID,
                                                   CloseDate = System.Today() + 30 ); 
        
        insert testOldOppty; 
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
                                                RecordTypeId=newOppRecordTypeID,
                                                CloseDate = System.Today() + 30 ); 
        
        insert testOppty; 
        
        update testOppty;        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            Product_ID__c='test prod id2',
                                            Sales_Configurator_Identifier__c='ACT', 
                                            IsActive = TRUE,
                                            FPG_DPS__c = true,
                                            FPG_MDC__c = true,
                                            FPG_UDS__c = true);
        listProduct2.add(newappPrdct);
        
        Product2 newappPrdct2 = new Product2(Name = 'Test Product212',
                                             Product_Line_Desc__c = 'AppAssure233',
                                             Product_ID__c='test prod id223',
                                             Sales_Configurator_Identifier__c='ACT', 
                                             IsActive = TRUE,
                                             FPG_DPS__c = true,
                                             FPG_MDC__c = false,
                                             FPG_UDS__c = true);
        listProduct2.add(newappPrdct2);
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        listPricebook.add(apppBE);
        PricebookEntry apppBE1= new PricebookEntry (Product2ID=newappPrdct2.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 40);
        listPricebook.add(apppBE1);
        insert listPricebook;
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description123',
                                                                    CPSD_Integration_Status__c='completed',
                                                                    CPSD_Opportunity_Product_ID__c='12313233231',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        
        listOpplnItem.add(testLineItem);
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                     pricebookEntryId=listPricebook[1].id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description',
                                                                     CPSD_Integration_Status__c='completed',
                                                                     CPSD_Opportunity_Product_ID__c='123132331',
                                                                     Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listOpplnItem.add(testLineItem2);
        
        
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpplnItem;
        testOppty.Specialty_BU_Products__c = 'DPS,UDS';
        update testOppty;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.stopTest();
        OpportunityLineItem oli = [select Id, CPSD_Integration_Status__c from OpportunityLineItem where Id =:listOpplnItem[0].Id limit 1];
        system.assertEquals('DPS,UDS', testOppty.Specialty_BU_Products__c);
    }
     static testmethod void updateSpecialBUProducts1(){
        //insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "CPSDOpportunityLineItemTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;   
        Account testAccount1 = new Account(Name='Test Account');  
        insert testAccount1;
        
        Opportunity testOldOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                   AccountId=testAccount.Id, 
                                                   stagename='Discover - 10%',
                                                   Probability=10.0,
                                                   RecordTypeId=newOppRecordTypeID,
                                                   CloseDate = System.Today() + 30 ); 
        
        insert testOldOppty; 
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
                                                RecordTypeId=newOppRecordTypeID,
                                                CloseDate = System.Today() + 30 ); 
        
        insert testOppty; 
        
        update testOppty;        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            Product_ID__c='test prod id2',
                                            Sales_Configurator_Identifier__c='ACT', 
                                            IsActive = TRUE,
                                            FPG_DPS__c = False,
                                            FPG_MDC__c = False,
                                            FPG_UDS__c = true);
        listProduct2.add(newappPrdct);
        
        Product2 newappPrdct2 = new Product2(Name = 'Test Product212',
                                             Product_Line_Desc__c = 'AppAssure233',
                                             Product_ID__c='test prod id223',
                                             Sales_Configurator_Identifier__c='ACT', 
                                             IsActive = TRUE,
                                             FPG_DPS__c = true,
                                             FPG_MDC__c = false,
                                             FPG_UDS__c = true);
        listProduct2.add(newappPrdct2);
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        listPricebook.add(apppBE);
        PricebookEntry apppBE1= new PricebookEntry (Product2ID=newappPrdct2.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 40);
        listPricebook.add(apppBE1);
        insert listPricebook;
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description123',
                                                                    CPSD_Integration_Status__c='completed',
                                                                    CPSD_Opportunity_Product_ID__c='12313233231',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        
        listOpplnItem.add(testLineItem);
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                     pricebookEntryId=listPricebook[1].id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description',
                                                                     CPSD_Integration_Status__c='completed',
                                                                     CPSD_Opportunity_Product_ID__c='123132331',
                                                                     Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listOpplnItem.add(testLineItem2);
        
        
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpplnItem;
        testOppty.Specialty_BU_Products__c = 'DPS,UDS';
        update testOppty;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.stopTest();
        OpportunityLineItem oli = [select Id, CPSD_Integration_Status__c from OpportunityLineItem where Id =:listOpplnItem[0].Id limit 1];
        system.assertEquals('DPS,UDS', testOppty.Specialty_BU_Products__c);
    }
    static testmethod void updateSpecialBUProducts2(){
        //insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "CPSDOpportunityLineItemTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;   
        Account testAccount1 = new Account(Name='Test Account');  
        insert testAccount1;
        
        Opportunity testOldOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                   AccountId=testAccount.Id, 
                                                   stagename='Discover - 10%',
                                                   Probability=10.0,
                                                   RecordTypeId=newOppRecordTypeID,
                                                   CloseDate = System.Today() + 30 ); 
        
        insert testOldOppty; 
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
                                                RecordTypeId=newOppRecordTypeID,
                                                CloseDate = System.Today() + 30 ); 
        
        insert testOppty; 
        
        update testOppty;        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            Product_ID__c='test prod id2',
                                            Sales_Configurator_Identifier__c='ACT', 
                                            IsActive = TRUE,
                                            FPG_DPS__c = False,
                                            FPG_MDC__c = False,
                                            FPG_UDS__c = False);
        listProduct2.add(newappPrdct);
        
        Product2 newappPrdct2 = new Product2(Name = 'Test Product212',
                                             Product_Line_Desc__c = 'AppAssure233',
                                             Product_ID__c='test prod id223',
                                             Sales_Configurator_Identifier__c='ACT', 
                                             IsActive = TRUE,
                                             FPG_DPS__c = true,
                                             FPG_MDC__c = false,
                                             FPG_UDS__c = False);
        listProduct2.add(newappPrdct2);
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        listPricebook.add(apppBE);
        PricebookEntry apppBE1= new PricebookEntry (Product2ID=newappPrdct2.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 40);
        listPricebook.add(apppBE1);
        insert listPricebook;
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description123',
                                                                    CPSD_Integration_Status__c='completed',
                                                                    CPSD_Opportunity_Product_ID__c='12313233231',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        
        listOpplnItem.add(testLineItem);
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                     pricebookEntryId=listPricebook[1].id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description',
                                                                     CPSD_Integration_Status__c='completed',
                                                                     CPSD_Opportunity_Product_ID__c='123132331',
                                                                     Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listOpplnItem.add(testLineItem2);
        
        
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpplnItem;
        testOppty.Specialty_BU_Products__c = 'DPS,UDS';
        update testOppty;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.stopTest();
        OpportunityLineItem oli = [select Id, CPSD_Integration_Status__c from OpportunityLineItem where Id =:listOpplnItem[0].Id limit 1];
        system.assertEquals('DPS,UDS', testOppty.Specialty_BU_Products__c);
    }
     static testmethod void updateSpecialBUProducts3(){
        //insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "CPSDOpportunityLineItemTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;   
        Account testAccount1 = new Account(Name='Test Account');  
        insert testAccount1;
        
        Opportunity testOldOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                   AccountId=testAccount.Id, 
                                                   stagename='Discover - 10%',
                                                   Probability=10.0,
                                                   RecordTypeId=newOppRecordTypeID,
                                                   CloseDate = System.Today() + 30 ); 
        
        insert testOldOppty; 
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
                                                RecordTypeId=newOppRecordTypeID,
                                                CloseDate = System.Today() + 30 ); 
        
        insert testOppty; 
        
        update testOppty;        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            Product_ID__c='test prod id2',
                                            Sales_Configurator_Identifier__c='ACT', 
                                            IsActive = TRUE,
                                            FPG_DPS__c = False,
                                            FPG_MDC__c = False,
                                            FPG_UDS__c = False);
        listProduct2.add(newappPrdct);
        
        Product2 newappPrdct2 = new Product2(Name = 'Test Product212',
                                             Product_Line_Desc__c = 'AppAssure233',
                                             Product_ID__c='test prod id223',
                                             Sales_Configurator_Identifier__c='ACT', 
                                             IsActive = TRUE,
                                             FPG_DPS__c = False,
                                             FPG_MDC__c = True,
                                             FPG_UDS__c = False);
        listProduct2.add(newappPrdct2);
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        listPricebook.add(apppBE);
        PricebookEntry apppBE1= new PricebookEntry (Product2ID=newappPrdct2.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 40);
        listPricebook.add(apppBE1);
        insert listPricebook;
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description123',
                                                                    CPSD_Integration_Status__c='completed',
                                                                    CPSD_Opportunity_Product_ID__c='12313233231',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        
        listOpplnItem.add(testLineItem);
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                     pricebookEntryId=listPricebook[1].id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description',
                                                                     CPSD_Integration_Status__c='completed',
                                                                     CPSD_Opportunity_Product_ID__c='123132331',
                                                                     Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listOpplnItem.add(testLineItem2);
        
        
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpplnItem;
        testOppty.Specialty_BU_Products__c = 'DPS,UDS';
        update testOppty;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.stopTest();
        OpportunityLineItem oli = [select Id, CPSD_Integration_Status__c from OpportunityLineItem where Id =:listOpplnItem[0].Id limit 1];
        system.assertEquals('DPS,UDS', testOppty.Specialty_BU_Products__c);
    }
    static testmethod void updateSpecialBUProducts4(){
        //insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "CPSDOpportunityLineItemTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;   
        Account testAccount1 = new Account(Name='Test Account');  
        insert testAccount1;
        
        Opportunity testOldOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                   AccountId=testAccount.Id, 
                                                   stagename='Discover - 10%',
                                                   Probability=10.0,
                                                   RecordTypeId=newOppRecordTypeID,
                                                   CloseDate = System.Today() + 30 ); 
        
        insert testOldOppty; 
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
                                                RecordTypeId=newOppRecordTypeID,
                                                CloseDate = System.Today() + 30 ); 
        
        insert testOppty; 
        
        update testOppty;        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            Product_ID__c='test prod id2',
                                            Sales_Configurator_Identifier__c='ACT', 
                                            IsActive = TRUE,
                                            FPG_DPS__c = False,
                                            FPG_MDC__c = True,
                                            FPG_UDS__c = False);
        listProduct2.add(newappPrdct);
        
        Product2 newappPrdct2 = new Product2(Name = 'Test Product212',
                                             Product_Line_Desc__c = 'AppAssure233',
                                             Product_ID__c='test prod id223',
                                             Sales_Configurator_Identifier__c='ACT', 
                                             IsActive = TRUE,
                                             FPG_DPS__c = False,
                                             FPG_MDC__c = False,
                                             FPG_UDS__c = True);
        listProduct2.add(newappPrdct2);
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        listPricebook.add(apppBE);
        PricebookEntry apppBE1= new PricebookEntry (Product2ID=newappPrdct2.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 40);
        listPricebook.add(apppBE1);
        insert listPricebook;
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description123',
                                                                    CPSD_Integration_Status__c='completed',
                                                                    CPSD_Opportunity_Product_ID__c='12313233231',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        
        listOpplnItem.add(testLineItem);
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                     pricebookEntryId=listPricebook[1].id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description',
                                                                     CPSD_Integration_Status__c='completed',
                                                                     CPSD_Opportunity_Product_ID__c='123132331',
                                                                     Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listOpplnItem.add(testLineItem2);
        
        
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpplnItem;
        //testOppty.Specialty_BU_Products__c = 'DPS,UDS';
        //update testOppty;
        //OpportunityLineItem oli = [select Id, CPSD_Integration_Status__c from OpportunityLineItem where Id =:listOpplnItem[0].Id limit 1];
        //system.assertEquals('DPS,UDS', testOppty.Specialty_BU_Products__c);
        Test.startTest();
        delete listOpplnItem;
        Test.stopTest();
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        system.assertEquals(0, [select count() from OpportunityLineItem]);
        
    }
    static testmethod void updateSpecialBUProducts5(){
        //insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "CPSDOpportunityLineItemTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;   
        Account testAccount1 = new Account(Name='Test Account');  
        insert testAccount1;
        
        Opportunity testOldOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                   AccountId=testAccount.Id, 
                                                   stagename='Discover - 10%',
                                                   Probability=10.0,
                                                   RecordTypeId=newOppRecordTypeID,
                                                   CloseDate = System.Today() + 30 ); 
        
        insert testOldOppty; 
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
                                                RecordTypeId=newOppRecordTypeID,
                                                CloseDate = System.Today() + 30 ); 
        
        insert testOppty; 
        
        update testOppty;        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            Product_ID__c='test prod id2',
                                            Sales_Configurator_Identifier__c='ACT', 
                                            IsActive = TRUE,
                                            FPG_DPS__c = False,
                                            FPG_MDC__c = False,
                                            FPG_UDS__c = False);
        listProduct2.add(newappPrdct);
        
        Product2 newappPrdct2 = new Product2(Name = 'Test Product212',
                                             Product_Line_Desc__c = 'AppAssure233',
                                             Product_ID__c='test prod id223',
                                             Sales_Configurator_Identifier__c='ACT', 
                                             IsActive = TRUE,
                                             FPG_DPS__c = False,
                                             FPG_MDC__c = False,
                                             FPG_UDS__c = True);
        listProduct2.add(newappPrdct2);
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        listPricebook.add(apppBE);
        PricebookEntry apppBE1= new PricebookEntry (Product2ID=newappPrdct2.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 40);
        listPricebook.add(apppBE1);
        insert listPricebook;
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description123',
                                                                    CPSD_Integration_Status__c='completed',
                                                                    CPSD_Opportunity_Product_ID__c='12313233231',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        
        listOpplnItem.add(testLineItem);
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                     pricebookEntryId=listPricebook[1].id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description',
                                                                     CPSD_Integration_Status__c='completed',
                                                                     CPSD_Opportunity_Product_ID__c='123132331',
                                                                     Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listOpplnItem.add(testLineItem2);
        
        
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpplnItem;
        testOppty.Specialty_BU_Products__c = 'DPS,UDS';
        update testOppty;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.stopTest();
        OpportunityLineItem oli = [select Id, CPSD_Integration_Status__c from OpportunityLineItem where Id =:listOpplnItem[0].Id limit 1];
        system.assertEquals('DPS,UDS', testOppty.Specialty_BU_Products__c);
    }
    static testmethod void updateSpecialBUProducts6(){
        //insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "CPSDOpportunityLineItemTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;   
        Account testAccount1 = new Account(Name='Test Account');  
        insert testAccount1;
        
        Opportunity testOldOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                   AccountId=testAccount.Id, 
                                                   stagename='Discover - 10%',
                                                   Probability=10.0,
                                                   RecordTypeId=newOppRecordTypeID,
                                                   CloseDate = System.Today() + 30 ); 
        
        insert testOldOppty; 
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
                                                RecordTypeId=newOppRecordTypeID,
                                                CloseDate = System.Today() + 30 ); 
        
        insert testOppty; 
        
        update testOppty;        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            Product_ID__c='test prod id2',
                                            Sales_Configurator_Identifier__c='ACT', 
                                            IsActive = TRUE,
                                            FPG_DPS__c = False,
                                            FPG_MDC__c = False,
                                            FPG_UDS__c = False);
        listProduct2.add(newappPrdct);
        
        Product2 newappPrdct2 = new Product2(Name = 'Test Product212',
                                             Product_Line_Desc__c = 'AppAssure233',
                                             Product_ID__c='test prod id223',
                                             Sales_Configurator_Identifier__c='ACT', 
                                             IsActive = TRUE,
                                             FPG_DPS__c = True,
                                             FPG_MDC__c = False,
                                             FPG_UDS__c = True);
        listProduct2.add(newappPrdct2);
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        listPricebook.add(apppBE);
        PricebookEntry apppBE1= new PricebookEntry (Product2ID=newappPrdct2.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 40);
        listPricebook.add(apppBE1);
        insert listPricebook;
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description123',
                                                                    CPSD_Integration_Status__c='completed',
                                                                    CPSD_Opportunity_Product_ID__c='12313233231',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        
        listOpplnItem.add(testLineItem);
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                     pricebookEntryId=listPricebook[1].id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description',
                                                                     CPSD_Integration_Status__c='completed',
                                                                     CPSD_Opportunity_Product_ID__c='123132331',
                                                                     Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listOpplnItem.add(testLineItem2);
        
        
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpplnItem;
        testOppty.Specialty_BU_Products__c = 'DPS,UDS';
        update testOppty;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.stopTest();
        OpportunityLineItem oli = [select Id, CPSD_Integration_Status__c from OpportunityLineItem where Id =:listOpplnItem[0].Id limit 1];
        system.assertEquals('DPS,UDS', testOppty.Specialty_BU_Products__c);
    }
    
    static testmethod void updateSpecialBUProducts7(){
        //insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "CPSDOpportunityLineItemTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;   
        Account testAccount1 = new Account(Name='Test Account');  
        insert testAccount1;
        
        Opportunity testOldOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                   AccountId=testAccount.Id, 
                                                   stagename='Discover - 10%',
                                                   Probability=10.0,
                                                   RecordTypeId=newOppRecordTypeID,
                                                   CloseDate = System.Today() + 30 ); 
        
        insert testOldOppty; 
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
                                                RecordTypeId=newOppRecordTypeID,
                                                CloseDate = System.Today() + 30 ); 
        
        insert testOppty; 
        
        update testOppty;        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            Product_ID__c='test prod id2',
                                            Sales_Configurator_Identifier__c='ACT', 
                                            IsActive = TRUE,
                                            FPG_DPS__c = False,
                                            FPG_MDC__c = False,
                                            FPG_UDS__c = False);
        listProduct2.add(newappPrdct);
        
        Product2 newappPrdct2 = new Product2(Name = 'Test Product212',
                                             Product_Line_Desc__c = 'AppAssure233',
                                             Product_ID__c='test prod id223',
                                             Sales_Configurator_Identifier__c='ACT', 
                                             IsActive = TRUE,
                                             FPG_DPS__c = True,
                                             FPG_MDC__c = True,
                                             FPG_UDS__c = False);
        listProduct2.add(newappPrdct2);
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        listPricebook.add(apppBE);
        PricebookEntry apppBE1= new PricebookEntry (Product2ID=newappPrdct2.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 40);
        listPricebook.add(apppBE1);
        insert listPricebook;
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description123',
                                                                    CPSD_Integration_Status__c='completed',
                                                                    CPSD_Opportunity_Product_ID__c='12313233231',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        
        listOpplnItem.add(testLineItem);
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                     pricebookEntryId=listPricebook[1].id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description',
                                                                     CPSD_Integration_Status__c='completed',
                                                                     CPSD_Opportunity_Product_ID__c='123132331',
                                                                     Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listOpplnItem.add(testLineItem2);
        
        
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpplnItem;
        testOppty.Specialty_BU_Products__c = 'DPS,UDS';
        update testOppty;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.stopTest();
        OpportunityLineItem oli = [select Id, CPSD_Integration_Status__c from OpportunityLineItem where Id =:listOpplnItem[0].Id limit 1];
        system.assertEquals('DPS,UDS', testOppty.Specialty_BU_Products__c);
    }
     static testmethod void cpsdafterdeletetest(){
        TriggerExecutionController.setSkipAllTriggers(true);
         Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity', TRUE); 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
                                                Forecast_Category_Override__c='Omitted',
                                                RecordTypeId=newOppRecordTypeID,
                                                CloseDate = System.Today() + 30 ); 
                                                      
        insert testOppty; 
        

        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id1',
                                         Sales_Configurator_Identifier__c='ACT',
                                         IsActive = TRUE
                                         );
        listProduct2.add(newPrdct);                                 
        //insert newPrdct;
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id2',
                                         Sales_Configurator_Identifier__c='ACT', 
                                         IsActive = TRUE
                                           );
        listProduct2.add(newappPrdct);
        insert listProduct2;
        //insert newappPrdct;
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE);                                        
        //insert pBE;
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        //insert apppBE;
        listPricebook.add(apppBE);
        insert listPricebook;
       
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        
         //TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    
                                                                    CPSD_Opportunity_Product_ID__c='123456wdert',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
     /*   OpportunityLineItem  testappLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[1].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                     
                                                                    CPSD_Opportunity_Product_ID__c='1234567erty',   
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); */
        
        listOpplnItem.add(testLineItem);
       // listOpplnItem.add(testappLineItem); 
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        //TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        insert listOpplnItem;
        Oppty_Product_Deleted__c opd=new Oppty_Product_Deleted__c();
        opd.CPSD_Opportunity_Line_Item_Deleted__c='Waiting Sync';
        opd.CPSD_Opportunity_Product_ID__c='12345erty';
        opd.Dell_Opportunity_ID__c=testOppty.Id;
        opd.CPSD_Opportunity_Product_ID__c=listOpplnItem[0].id;
        insert opd;
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        system.assertEquals('Line Description',listOpplnItem[0].Description ); 
        Test.startTest();
        delete listOpplnItem;
         Test.stopTest(); 
        //UpdateOpportunityLineItemCPSDstatus.backupCPSDOpportunityLineItem(listOpplnItem);
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
        //insert testappLineItem;
             
    }
  
}