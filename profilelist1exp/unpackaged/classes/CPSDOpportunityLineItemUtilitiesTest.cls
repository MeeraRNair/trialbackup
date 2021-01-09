/*
* Author   : Ranjith Mergu
* Purpose  : CPSDOpportunityLineItemUtilitiesTest test class for creating OpportunityLineItem related data. 
*
*/
@isTest
public class CPSDOpportunityLineItemUtilitiesTest {
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
    static testmethod void cpsdBeforeInsertOLI(){
        //insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeInsert' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBI"},';
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
        
        User sysadmin = [select id,name from User where profileId='00e30000000nJ6K' and isActive=true limit 1];
        System.runAs(sysadmin){
            testOppty.AccountId=testAccount1.Id;
            testOppty.Cloned_Parent_Id__c=testOldOppty.Id;
            testOppty.Oppty_Self_Id__c='0063B000002yf7U'; 
        }
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
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=pbk1,
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        listPricebook.add(apppBE);
        insert listPricebook;
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    CPSD_Integration_Status__c='completed',
                                                                    CPSD_Opportunity_Product_ID__c='123132331',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        
        listOpplnItem.add(testLineItem);
        
        
        Test.startTest();
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listOpplnItem;
        testOppty.CPSD_Integration_Status__c='Waiting Sync';
        testOppty.Specialty_BU_Products__c = 'DPS,MDC,UDS';
        update testOppty;
        testAccount1.CPSD_Integration_Status__c ='Waiting Sync';
        update testAccount1;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); 
        Test.stopTest();
        
        OpportunityLineItem oli = [select Id, CPSD_Integration_Status__c from OpportunityLineItem where Id =:listOpplnItem[0].Id limit 1];
        system.assertEquals('Waiting Sync', testOppty.CPSD_Integration_Status__c);
        system.assertEquals('Waiting Sync', testAccount1.CPSD_Integration_Status__c);
        
    }
    
    // Special BU Products 
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
}