@isTest
public class CPSDtriggerAITest {
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
    static testmethod void cpsdafterInserttest(){
       TriggerExecutionController.setSkipAllTriggers(true);
         String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false, true, false, false}
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
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Probability=10.0,
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
                                         IsActive = TRUE);
        listProduct2.add(newPrdct);                                 
        //insert newPrdct;
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id2',
                                         Sales_Configurator_Identifier__c='ACT', 
                                         IsActive = TRUE);
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
        
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    CPSD_Integration_Status__c='',
                                                                    CPSD_Opportunity_Product_ID__c='',
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
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        system.assertEquals('Line Description',listOpplnItem[0].Description ); 
         Test.startTest();
         insert listOpplnItem;
         Test.stopTest();
       
        //UpdateOpportunityLineItemCPSDstatus.backupCPSDOpportunityLineItem(listOpplnItem);
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
        //insert testappLineItem;
        
    }   
             
    }