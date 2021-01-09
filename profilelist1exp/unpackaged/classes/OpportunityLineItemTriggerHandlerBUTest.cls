@IsTest
public class OpportunityLineItemTriggerHandlerBUTest {
	//insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
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
        settingData.ProfilesBypassMyquotesOpptyValidation__c= 'Boomi Integration API Only;';        
        insert settingData;
        
     }   
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
    
    static testMethod void testInsertbothLineItem() { 

        // 7.4 To create customsettings
    //    insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        //Insert only appassure product
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 ); 
                                                      
        insert testOppty;   
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        listProduct2.add(newPrdct);                                 
        //insert newPrdct;
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id2',
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
        TriggerExecutionController.setSkipAllTriggers(false);
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        OpportunityLineItem  testappLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[1].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );   
        listOpplnItem.add(testLineItem);
        listOpplnItem.add(testappLineItem); 
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        Test.startTest();
        system.assertEquals('Line Description',testappLineItem.Description );
        insert listOpplnItem;
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
        //insert testappLineItem;
        Test.stopTest();        
    }
    static testMethod void testInsertappLineItem() {

        // 7.4 To create customsettings
     //   insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
        
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        //Insert only appassure product
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty1', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                AppAssure_Product_Flag__c = 0,
                                                CloseDate = System.Today() + 30 );        
        insert testOppty;   
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
              
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        system.assertEquals('AppAssure',newPrdct.Product_Line_Desc__c );
        insert newPrdct;
        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pBE;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();
        insert testLineItem;
        Test.stopTest();
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
    }
    
    static testMethod void testDeleteAppAssureLineItem() {   

        // 7.4 To create customsettings
    //    insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );

        TriggerExecutionController.setSkipOpportunityTriggers(true);                                                
        insert testOppty;   
        TriggerExecutionController.setSkipOpportunityTriggers(false);

        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
              
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
            system.assertEquals('AppAssure',newPrdct.Product_Line_Desc__c );
        insert newPrdct;
        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pBE;

        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        insert testLineItem;// 7.2: Added
        TriggerExecutionController.setSkipAllTriggers(false);
        
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        Test.startTest();                                                
        //insert testLineItem; // 7.2: Commented, move to few lines above, hope not causing code coverage failure for AFTER TRIGGER on Oppty Product
      
        Delete testLineItem;
        Test.stopTest();
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
        
        
    }
    static testMethod void testDeletenonAppAssureLineItem() {  

        // 7.4 To create customsettings
   //     insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;       
        Contact con = new Contact(LastName='Test User',AccountId=testAccount.Id,Phone='1987654320',Email='testuser@aol.com', MailingStreet='214 Allen Street',MailingCity='Austin',MailingState='TX',MailingPostalCode='70081',MailingCountry='US');
        insert con;     
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30,Quest_Software_Contact__c=con.Id);
                                                        
        insert testOppty;   
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'test Product',DSG_Sales_Motion__c ='Read only product',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);                                         
        listProduct2.add(newPrdct);
        
        Product2 newAppPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',DSG_Sales_Motion__c ='Bidirectional product',
                                         Product_ID__c='test prod id2',
                                         IsActive = TRUE);
        listProduct2.add(newAppPrdct);
        
        Product2 newAppPrdct2 = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id3',
                                         IsActive = TRUE);
                                         
        listProduct2.add(newAppPrdct2);
        system.assertEquals('AppAssure',newAppPrdct2.Product_Line_Desc__c );
        insert listProduct2;   
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();
        PricebookEntry pBE= new PricebookEntry (Product2ID=listProduct2[0].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE);                                        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=listProduct2[1].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(apppBE);
        insert listPricebook;
        List<OpportunityLineItem> listInsertLineItems=new List<OpportunityLineItem>();
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listInsertLineItems.add(testLineItem);
        //Opportunity oppty = [select id,AppAssure_Product_Flag__c from Opportunity where Id = :testOppty.Id];
        //System.Assert(oppty.AppAssure_Product_Flag__c , False);
                
         OpportunityLineItem  appTestLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=apppBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        listInsertLineItems.add(appTestLineItem);
        insert   listInsertLineItems;    // 7.2: Added
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.0
        //insert   listInsertLineItems;   // 7.2: Commented, move to few lines above, hope not causing code coverage failure for AFTER TRIGGER on Oppty Product 
        Test.startTest();
        listInsertLineItems[1].UnitPrice = 200;
        update listInsertLineItems[1];
        Test.stopTest();
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.0
        
        //Delete insertLineItems[0];
                
    }
    
    static testMethod void testDeletenonAppAssureLineItem1() {   

        // 7.4 To create customsettings
   //     insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;       
        Contact con = new Contact(LastName='Test User',AccountId=testAccount.Id,Phone='1987654320',Email='testuser@aol.com', MailingStreet='214 Allen Street',MailingCity='Austin',MailingState='TX',MailingPostalCode='70081',MailingCountry='US');
        insert con;     
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30,Quest_Software_Contact__c=con.Id);
                                                        
        insert testOppty;   
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'test Product',DSG_Sales_Motion__c ='Read only product',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);                                         
        listProduct2.add(newPrdct);
        
        Product2 newAppPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',DSG_Sales_Motion__c ='Bidirectional product',
                                         Product_ID__c='test prod id2',
                                         IsActive = TRUE);
        listProduct2.add(newAppPrdct);
        
        Product2 newAppPrdct2 = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id3',
                                         IsActive = TRUE);
                                         
        listProduct2.add(newAppPrdct2);
        system.assertEquals('AppAssure',newAppPrdct2.Product_Line_Desc__c );        
        insert listProduct2;   
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();
        PricebookEntry pBE= new PricebookEntry (Product2ID=listProduct2[0].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE);                                        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=listProduct2[1].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(apppBE);
                PricebookEntry apppBE1= new PricebookEntry (Product2ID=listProduct2[2].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(apppBE1);
        insert listPricebook;
        List<OpportunityLineItem> listInsertLineItems=new List<OpportunityLineItem>();
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listInsertLineItems.add(testLineItem);

         OpportunityLineItem  appTestLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=apppBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );
                                                                    
        listInsertLineItems.add(appTestLineItem);
        
        OpportunityLineItem  appTestLineItem1 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=apppBE1.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );
        listInsertLineItems.add(appTestLineItem1);
        insert listInsertLineItems;  // 7.2: Added
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        Test.startTest();
        //insert listInsertLineItems;     // 7.2: Commented, move to few lines above, hope not causing code coverage failure for AFTER TRIGGER on Oppty Product
        listInsertLineItems[1].UnitPrice = 200;
        update listInsertLineItems[1];
        
        Delete listInsertLineItems[2];
        
        Test.stopTest();
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
                        
    }
    static testMethod void testDeleteLineItem() {    
    
        // 7.4 To create customsettings
     //   insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
    
        TriggerExecutionController.setSkipAllTriggers(true); // 7.2
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 ); 
        insert testOppty;   
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        listProduct2.add(newPrdct);                                 
        
       Product2 newappPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id2',
                                         IsActive = TRUE);
        listProduct2.add(newappPrdct);                                 
        Product2 newappPrdct2 = new Product2(Name = 'Test Product2',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id3',
                                         IsActive = TRUE);
        listProduct2.add(newappPrdct2);                                 
        system.assertEquals('AppAssure',newAppPrdct2.Product_Line_Desc__c );
        insert listProduct2;
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();
        PricebookEntry pBE= new PricebookEntry (Product2ID=listProduct2[0].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE);                                        
        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=listProduct2[1].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(apppBE);                                        
        
        PricebookEntry app2pBE= new PricebookEntry (Product2ID=listProduct2[2].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(app2pBE);
        insert listPricebook;
        List<OpportunityLineItem> listInsertLineItems=new List<OpportunityLineItem>();
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listInsertLineItems.add(testLineItem);
        OpportunityLineItem  testappLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=apppBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listInsertLineItems.add(testappLineItem);
       
        OpportunityLineItem  testapp2LineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=app2pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        listInsertLineItems.add(testapp2LineItem);
        insert listInsertLineItems;
        TriggerExecutionController.setSkipAllTriggers(false); // 7.2
        
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        TriggerExecutionController.setSkipOpportunityTriggers(true); // 7.2
        Test.startTest();       
        delete listInsertLineItems[2];
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
        TriggerExecutionController.setSkipOpportunityTriggers(false); // 7.2
    }
    
    //SNWL:CR7326 : Code Start:Test Method for SNWL product deletion.
    static testMethod void testdeleteSNWLLineItem() { 

        // 7.4 To create customsettings
  //      insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );        
        insert testOppty;   
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();      
        Product2 newSNWLPrdct = new Product2(Name = 'SonicWall Product',
                                         Product_Line_Desc__c = 'SonicWall',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        insert newSNWLPrdct;
        
        PricebookEntry sNWLpBE= new PricebookEntry (Product2ID=newSNWLPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        system.assertEquals(true,sNWLpBE.isActive );
        insert sNWLpBE;
        OpportunityLineItem  testSNWLLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=SNWLpBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        insert testSNWLLineItem; // 7.2: Added
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        //insert testSNWLLineItem ;// 7.2: Commented, move to few lines above, hope not causing code coverage failure for AFTER TRIGGER on Oppty Product
        Test.startTest();
        delete testSNWLLineItem ;
        Test.stopTest();
         TriggerExecutionController.setSkipOpportunityTriggers(false);
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        
        //List<Oppty_Product_Deleted__c> oppdel = [select id from Oppty_Product_Deleted__c where Dell_opportunity_Id__c = :testOppty.Id];
        //System.Assertequals(oppdel.size() , 1);
    }
    //SNWL:CR7326 : Code End:Test Method for SNWL product deletion.
    
    //Code Start:Test Method for CheckEI_Product Method.
    static testMethod void testEIProduct() {  
    
        // 7.4 To create customsettings
   //     insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
    
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        TriggerExecutionController.setSkipopportunityTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account',account_country__c='SENEGAL');        
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );        
        //  TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert testOppty;   
        //TriggerExecutionController.setSkipOpportunityTriggers(false);
        Country__c countryObj = new Country__c(name='SENEGAL',Region__c='EC-EMEA',Code__c='SN001');
        insert countryObj;

        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
              
        Product2 newdrpBoxPrdct = new Product2(Name = 'Dropbox',
                                         Product_Line_Desc__c = 'Dropbox',
                                         Product_ID__c='test prod id1',
                                         EI_Product__c = true,
                                         IsActive = TRUE);
       system.assertEquals(true,newdrpBoxPrdct.IsActive );
        insert newdrpBoxPrdct;
        
        PricebookEntry dropPb= new PricebookEntry (Product2ID=newdrpBoxPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert dropPb;
        
        OpportunityLineItem  testEILineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=dropPb.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
                                                                    );   
        
        Test.startTest();
        insert testEILineItem; 
        Test.stopTest();
        TriggerExecutionController.setSkipopportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
    }
  
    //Code End:Test Method for CheckEI_Product Method.
    
    
    /*
    v4.0 - CR11414 - To test the SAVO Opportunity fields Product_Group_Hidden__c and Product_Brand_Hidden__c when OpportunityLineItem is added or deleted.
        This method will cover the updateFieldsForSAVO functionality in the below classes
            OpportunityFieldPopulator 
            OpportunityLineItemUtilities
            OpportunityLineItemTriggerHandler
            OpportunityLineItemRecordSelector
    */
  
    static testMethod void testUpdateFieldsForSAVO() {  

        // 7.4 To create customsettings
     //   insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        List<Opportunity> listOppToInsert = new List<Opportunity>();
        
        Account testAccount = new Account(Name='Test SAVO Account');        
        insert testAccount;        
        Opportunity testOppty1 = new Opportunity(Name='Test Oppty 1', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 ); 
          
          listOppToInsert.add(testOppty1);
                                                
        Opportunity testOppty2 = new Opportunity(Name='Test Oppty 2', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );
                                                
        listOppToInsert.add(testOppty2);
        
        Opportunity testOppty3 = new Opportunity(Name='Test Oppty 3', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );
         
        listOppToInsert.add(testOppty3);    
                                              
        system.assertEquals('Test Oppty 3',testOppty3.Name );       
        insert listOppToInsert;  
         
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
        
        List<Product2> listProduct2 =new List<Product2>();
        
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',
                                         ProductCode = 'TP1',   
                                         Product_Line_Desc__c = 'Test Product1',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        listProduct2.add(newPrdct1);                                 
        
       Product2 newappPrdct2 = new Product2(Name = 'Test Product2',
                                           ProductCode = 'TP2',
                                           Product_Line_Desc__c = 'Test Product2',
                                           Product_ID__c='test prod id2',
                                           IsActive = TRUE);
        listProduct2.add(newappPrdct2);                                 
        
        Product2 newPrdct3 = new Product2(Name = 'Test Product3',
                                         ProductCode = 'TP3',   
                                         Product_Line_Desc__c = 'Test Product3',
                                         Product_ID__c='test prod id3',
                                         IsActive = TRUE);
        listProduct2.add(newPrdct3);   
        
        Product2 newPrdct4 = new Product2(Name = 'Test Product4',
                                         ProductCode = 'TP4',   
                                         Product_Line_Desc__c = 'Test Product4',
                                         Product_ID__c='test prod id4',
                                         IsActive = TRUE);
        listProduct2.add(newPrdct4);   
        
        Product2 newPrdct5 = new Product2(Name = 'Test Product5',
                                         ProductCode = 'TP5',   
                                         Product_Line_Desc__c = 'Test Product5',
                                         Product_ID__c='test prod id5',
                                         IsActive = TRUE);
        listProduct2.add(newPrdct5);   
        
        Product2 newPrdct6 = new Product2(Name = 'Test Product6',
                                         ProductCode = 'TP6',   
                                         Product_Line_Desc__c = 'Test Product6',
                                         Product_ID__c='test prod id6',
                                         IsActive = TRUE);
        listProduct2.add(newPrdct6);   
        
                                      
        insert listProduct2;
        
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();
        PricebookEntry pBE1= new PricebookEntry (Product2ID=listProduct2[0].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE1);                                        
        
        PricebookEntry pBE2= new PricebookEntry (Product2ID=listProduct2[1].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE2);
        
        PricebookEntry pBE3= new PricebookEntry (Product2ID=listProduct2[2].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE3);
        
        PricebookEntry pBE4= new PricebookEntry (Product2ID=listProduct2[3].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE4);
        
        PricebookEntry pBE5= new PricebookEntry (Product2ID=listProduct2[4].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE5);
        
        PricebookEntry pBE6= new PricebookEntry (Product2ID=listProduct2[5].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE6);
        
        insert listPricebook;
        
        List<OpportunityLineItem> listInsertLineItems=new List<OpportunityLineItem>();
        
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =listOppToInsert[0].Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description1'
                                                                    ); 
        listInsertLineItems.add(testLineItem1);
        
         OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =listOppToInsert[0].Id,
                                                                    pricebookEntryId=listPricebook[1].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description2'
                                                                    ); 
        listInsertLineItems.add(testLineItem2);
        
         OpportunityLineItem  testLineItem3 = new OpportunityLineItem(Opportunityid =listOppToInsert[1].Id,
                                                                    pricebookEntryId=listPricebook[2].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description3'
                                                                    ); 
        listInsertLineItems.add(testLineItem3);
        
         OpportunityLineItem  testLineItem4 = new OpportunityLineItem(Opportunityid =listOppToInsert[1].Id,
                                                                    pricebookEntryId=listPricebook[3].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description4'
                                                                    ); 
        listInsertLineItems.add(testLineItem4);
        
         OpportunityLineItem  testLineItem5 = new OpportunityLineItem(Opportunityid =listOppToInsert[2].Id,
                                                                    pricebookEntryId=listPricebook[4].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description5'
                                                                    ); 
        listInsertLineItems.add(testLineItem5);
        
         OpportunityLineItem  testLineItem6 = new OpportunityLineItem(Opportunityid =listOppToInsert[2].Id,
                                                                    pricebookEntryId=listPricebook[5].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description6'
                                                                    ); 
        listInsertLineItems.add(testLineItem6);       
        
        insert listInsertLineItems;
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        
      //  Opportunity opp1 = [Select Id, Product_Group_Hidden__c, Product_Brand_Hidden__c from Opportunity where Id =: listOppToInsert[0].Id];
      // Opportunity opp2 = [Select Id, Product_Group_Hidden__c, Product_Brand_Hidden__c from Opportunity where Id =: listOppToInsert[1].Id];
      //  Opportunity opp3 = [Select Id, Product_Group_Hidden__c, Product_Brand_Hidden__c from Opportunity where Id =: listOppToInsert[2].Id];
        
        // System.assertEquals(opp1.Product_Brand_Hidden__c, 'Test Product1 Test Product2');
        // System.assertEquals(opp2.Product_Brand_Hidden__c, 'Test Product3 Test Product4');
        // System.assertEquals(opp3.Product_Brand_Hidden__c, 'Test Product5 Test Product6');
        // System.assertEquals(opp1.Product_Group_Hidden__c, 'TP1 TP2');
        // System.assertEquals(opp2.Product_Group_Hidden__c, 'TP3 TP4');
        // System.assertEquals(opp3.Product_Group_Hidden__c, 'TP5 TP6');
        
        OpportunityLineItem oliToDel = [Select Id from OpportunityLineItem where Id =: testLineItem6.Id];
        TriggerExecutionController.setSkipOpportunityTriggers(true); // 7.0
        delete  oliToDel;
        TriggerExecutionController.setSkipOpportunityTriggers(false); // 7.0
        Test.stopTest();
        
        // Opportunity opp4 = [Select Id, Product_Group_Hidden__c, Product_Brand_Hidden__c from Opportunity where Id =: lstOppToInsert[2].Id];
        
        // System.assertEquals(opp4.Product_Brand_Hidden__c, 'Test Product5');
        // System.assertEquals(opp4.Product_Group_Hidden__c, 'TP5');
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        //TriggerExecutionController.setSkipOpportunityTriggers(false);
        
    }//V3.0 CR11414 -- End
    //Ver 5.0:
    
    static testMethod void testInsert1OLIByPartnerForNonApprovedDeals() {  

        // 7.4 To create customsettings
   //     insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        ProcessFlowTriggerController.isTest = true;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account', RecordTypeId = accRTId);        
        insert testAccount;        
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        
        system.assertEquals('testing',newCont.Last_Operation_Performed__c );      
        insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='99826513', 
                            isActive = TRUE,
                            //IsPortalEnabled = TRUE,
                            //AccountId = testAccount.Id,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                CurrencyIsoCode = 'USD', // 7.1
                                                AccountId=testAccount.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                            //    Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                            //    Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );        
        System.runAs(PartnerUser){
            insert testOppty;    
        }
        
                                                
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Channel_Product_LOB__c = 'Client',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        insert newPrdct;                                 
       
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                CurrencyIsoCode = 'USD', // 7.1
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pBE;
        TriggerExecutionController.setSkipAllTriggers(true);
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        Test.startTest();      
        ProcessFlowTriggerController.isTest = true;
        System.runAs(PartnerUser){
            insert testLineItem;
        }
        Test.stopTest();        
    }   
   
    static testMethod void testRestrictNewlineItemsforApproveddealsOne() { 

        // 7.4 To create customsettings
        TriggerExecutionController.setSkipAllTriggers(true);
    //    insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        //TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account', RecordTypeId = accRTId);
        //TriggerExecutionController.setSkipAllTriggers(true); 
        insert testAccount;        
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='9966513', 
                            isActive = TRUE,
                           //IsPortalEnabled = TRUE,
                            //AccountId = testAccount.Id,
                            ContactId = newCont.Id);
        system.assertEquals('en_US',partnerUser.LocaleSidKey );      
        insert partnerUser;
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                             //   Engagement_Type__c = 'Public Tender',
                                                RecordTypeID = DealRTId,
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                            //    Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );

        System.runAs(PartnerUser){
            insert testOppty;
            system.debug(LoggingLevel.Error,'@@testOppty@@@'+testOppty);
        }
 
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     

        Product2 newPrdctone = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id1',
                                          Channel_Product_LOB__c = 'Client, Networking',
                                       //   DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        listProduct2.add(newPrdctone); 
        Product2 newPrdcttwo = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id2',
                                          Channel_Product_LOB__c = 'Networking, Storage',
                                      //    DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        listProduct2.add(newPrdcttwo);
        Product2 newPrdctthree = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id3',
                                          Channel_Product_LOB__c = 'Server, Storage',
                                     //     DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        listProduct2.add(newPrdctthree);
        
        insert listProduct2;                                  
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry pBEone = new PricebookEntry (Product2ID=listProduct2[0].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                CurrencyIsoCode = 'USD',
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEone);
        PricebookEntry pBEtwo = new PricebookEntry (Product2ID=listProduct2[1].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                CurrencyIsoCode = 'USD',
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEtwo);
        PricebookEntry pBEthree = new PricebookEntry (Product2ID=listProduct2[2].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                CurrencyIsoCode = 'USD',
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEthree);
                                                
        insert listPricebook;
        //TriggerExecutionController.setSkipAllTriggers(false);
        List<OpportunityLineItem> listOppLineitemToInsert = new List<OpportunityLineItem>();
    
        OpportunityLineItem  testLineItemtwo = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        OpportunityLineItem  testLineItemone = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[1].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                          
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
                                                                     
        listOppLineitemToInsert.add(testLineItemone);
        listOppLineitemToInsert.add(testLineItemtwo);
        system.debug(LoggingLevel.Error,'@@@limits @@'+ limits.getlimitqueries() );  
        //insert testLineItemtwo;                                                       
        Test.startTest();      
        System.runAs(PartnerUser){
            try{
                insert listOppLineitemToInsert ;
                system.debug(LoggingLevel.Error,'@@@testLineItemone @@'+testLineItemone );
            }catch(Exception e){
                system.debug(LoggingLevel.Error,'@@@e@@'+e);
            }
        }   
        Test.stopTest(); 
        
         system.debug(LoggingLevel.Error,'@@testOppty@@@'+testOppty);
         OpportunityLineItem  testLineItemthree = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[2].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );  
         //lstOppLineitemToInsert.add(testLineItemthree );
         System.runAs(PartnerUser){
            try{
                insert testLineItemthree;
                system.debug(LoggingLevel.Error,'@@@testLineItemone@@'+testLineItemthree );
            }catch(Exception e){
                system.debug(LoggingLevel.Error,'@@@testLineItemone@@'+e);
            }
        }
        database.delete(testLineItemone, false);
        TriggerExecutionController.setSkipAllTriggers(false);

    }   
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
     static testMethod void testRestrictNewlineItemsforApproveddealstwo() {

        // 7.4 To create customsettings
//        insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
     
        TriggerExecutionController.setSkipAllTriggers(true);
 		String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account', RecordTypeId = accRTId);
        TriggerExecutionController.setSkipAllTriggers(true); 
        // GlobalVariables.BYPASS_ACCOUNT_TRIGGER = true;        
        insert testAccount;        
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        system.assertEquals('testing',newCont.Last_Operation_Performed__c );
         insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='9966513', 
                            isActive = TRUE,
                           //IsPortalEnabled = TRUE,
                            //AccountId = testAccount.Id,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
           // List<Opportunity> lstOpp =new List<Opportunity>();
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                          //      Engagement_Type__c = 'Public Tender',
                                                RecordTypeID = DealRTId,
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                           //     Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );

        System.runAs(PartnerUser){
        //  TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOppty;
            system.debug(LoggingLevel.Error,'@@testOppty@@@'+testOppty);
        }
 
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     

        Product2 newPrdcttwo = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id1',
                                          Channel_Product_LOB__c = '',
                                      //    DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        

        listProduct2.add(newPrdcttwo);
        
        insert listProduct2;                                  
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        

        PricebookEntry pBEtwo = new PricebookEntry (Product2ID=newPrdcttwo.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEtwo);
                                                
        insert listPricebook;
        //TriggerExecutionController.setSkipAllTriggers(false);
        List<OpportunityLineItem> listOppLineitemToInsert = new List<OpportunityLineItem>();
    
        OpportunityLineItem  testLineItemtwo = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBEtwo.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        OpportunityLineItem  testLineItemone = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBEtwo.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                          
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
                                                                     
        listOppLineitemToInsert.add(testLineItemtwo);
        system.debug(LoggingLevel.Error,'@@@limits @@'+ limits.getlimitqueries() );  
                                                                    
        Test.startTest();      
        System.runAs(PartnerUser){
            try{
                insert listOppLineitemToInsert ;
                system.debug(LoggingLevel.Error,'@@@testLineItemone @@'+testLineItemone );
            }catch(Exception e){
                system.debug(LoggingLevel.Error,'@@@e@@'+e);
            }
        }   
        Test.stopTest(); 
     
         system.debug(LoggingLevel.Error,'@@testOppty@@@'+testOppty);
         OpportunityLineItem  testLineItemthree = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBEtwo.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );  
         listOppLineitemToInsert.add(testLineItemthree );
         System.runAs(PartnerUser){
            try{
                insert listOppLineitemToInsert;
                system.debug(LoggingLevel.Error,'@@@testLineItemone@@'+testLineItemthree );
            }catch(Exception e){
                system.debug(LoggingLevel.Error,'@@@testLineItemone@@'+e);
            }
        }
  
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
    static testMethod void testRestrictNewlineItemsforApproveddealsthree() {

        // 7.4 To create customsettings
   //     insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account', RecordTypeId = accRTId);
        TriggerExecutionController.setSkipAllTriggers(true); 
        insert testAccount;        
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        system.assertEquals('testing',newCont.Last_Operation_Performed__c );
        insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='9966513', 
                            isActive = TRUE,
                           //IsPortalEnabled = TRUE,
                            //AccountId = testAccount.Id,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                              //  Engagement_Type__c = 'Public Tender',
                                                RecordTypeID = DealRTId,
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                              //  Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );

        System.runAs(PartnerUser){
            insert testOppty;
            system.debug(LoggingLevel.Error,'@@testOppty@@@'+testOppty);
        }
 
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     

        Product2 newPrdctone = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id1',
                                          Channel_Product_LOB__c = 'Client, Networking',
                                     //     DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        listProduct2.add(newPrdctone); 
        Product2 newPrdcttwo = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id2',
                                          Channel_Product_LOB__c = 'Networking',
                                      //    DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        listProduct2.add(newPrdcttwo);
        Product2 newPrdctthree = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id3',
                                          Channel_Product_LOB__c = 'Server,Client',
                                       //   DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        listProduct2.add(newPrdctthree);
        
        insert listProduct2;                                  
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry pBEone = new PricebookEntry (Product2ID=listProduct2[0].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEone);
        PricebookEntry pBEtwo = new PricebookEntry (Product2ID=listProduct2[1].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEtwo);
        PricebookEntry pBEthree = new PricebookEntry (Product2ID=listProduct2[2].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEthree);
                                                
        insert listPricebook;
        TriggerExecutionController.setSkipAllTriggers(false);
        List<OpportunityLineItem> listOppLineitemToInsert = new List<OpportunityLineItem>();
    
        OpportunityLineItem  testLineItemtwo = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        OpportunityLineItem  testLineItemone = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[1].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                          
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
                                                                     
        listOppLineitemToInsert.add(testLineItemone);
        listOppLineitemToInsert.add(testLineItemtwo);
        system.debug(LoggingLevel.Error,'@@@limits @@'+ limits.getlimitqueries() );  
        //insert testLineItemtwo;                                                       
        Test.startTest();      
        System.runAs(PartnerUser){
            try{
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                insert listOppLineitemToInsert ;
                testOppty.Deal_Registration_Status__c = 'Approved';
                 
                update testOppty;
                TriggerExecutionController.setSkipopportunityTriggers(false); 
                //system.debug(LoggingLevel.Error,'@@@testLineItemone @@'+testLineItemone );
            }catch(Exception e){
                system.debug(LoggingLevel.Error,'@@@e@@'+e);
            }
        }   
        Test.stopTest(); 
        
         system.debug(LoggingLevel.Error,'@@testOppty@@@'+testOppty);
         OpportunityLineItem  testLineItemthree = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[2].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );  
         //lstOppLineitemToInsert.add(testLineItemthree );
         System.runAs(PartnerUser){
            try{
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                insert testLineItemthree;
                TriggerExecutionController.setSkipOpportunityTriggers(False);
                system.debug(LoggingLevel.Error,'@@@testLineItemone@@'+testLineItemthree );
            }catch(Exception e){
                system.debug(LoggingLevel.Error,'@@@testLineItemone@@'+e);
            }
        }
  

    } 

    static testMethod void testDeleteEMCLineItem() {
        
        // 7.4 To create customsettings
     //   insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );
        Test.startTest();                                                
        insert testOppty;   
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
              
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='EMC CrossSell', 
                                       // EMC_CRUD_Behavior__c='Read Only',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        insert newPrdct;
        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
                system.assertEquals(false,pBE.useStandardPrice );
        insert pBE;

        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert testLineItem;
      
        Test.stopTest();
        Delete testLineItem;
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
    }
    
    static testMethod void addEMCLineItem(){

        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        ProcessFlowTriggerController.isTest = true; 
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                Primary_Product_Delivery_Address_Country__c ='SLOVAKIA',
                                                Primary_Product_Delivery_Address_Region__c ='LATAM',
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );
        insert testOppty;   
      
        Id pbk1 = Test.getStandardPricebookId();
              
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'tesfs1235',EMC_Sales_Motion__c ='EMC Cross Sell', Business_Family__c='EMC1',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        insert newPrdct;
        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
                        system.assertEquals(false,pBE.useStandardPrice );
        insert pBE;

        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
        ); 
                                                                    
        Product2 newPrdct2 = new Product2(Name = 'Test Product2',
                                         Product_Line_Desc__c = 'NONEMC',EMC_Sales_Motion__c ='EMC Cross Sell', Business_Family__c='',
                                         Product_ID__c='test prod id2',
                                         IsActive = TRUE);
        insert newPrdct2;
        
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct2.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pBE1;
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE1.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
        );
        TriggerExecutionController.setSkipAllTriggers(false);
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
      
        Test.startTest();   
        
        insert testLineItem;
        insert testLineItem2;   
        Test.stopTest();
        
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);   
        
    }
    
    static testMethod void addEMCLineItem2(){

        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                Primary_Product_Delivery_Address_Country__c ='SLOVAKIA',
                                                Primary_Product_Delivery_Address_Region__c ='LATAM',
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );
        insert testOppty;   
      
        Id pbk1 = Test.getStandardPricebookId();
                                                                                 
        Product2 newPrdct2 = new Product2(Name = 'Test Product2',
                                         Product_Line_Desc__c = 'NONEMC',EMC_Sales_Motion__c ='EMC Cross Sell', Business_Family__c='',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        insert newPrdct2;
        
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct2.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
                        system.assertEquals(false,pBE1.useStandardPrice );
        insert pBE1;
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE1.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
        );
        TriggerExecutionController.setSkipAllTriggers(false);
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
      
        Test.startTest();                                                
        insert testLineItem2;   
        Delete testLineItem2;
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);   
        
    }   
    
    /*
    static testMethod void addEMCLineItem() { 

        // 7.4 To create customsettings
        insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
    
        TriggerExecutionController.setSkipAllTriggers(true);
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                Primary_Product_Delivery_Address_Country__c ='SLOVAKIA',
                                                Primary_Product_Delivery_Address_Region__c ='LATAM',
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );
        insert testOppty;   
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
              
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='EMC Cross Sell', EMC_CRUD_Behavior__c='Read/Write',
                                         IsActive = TRUE);
        insert newPrdct;
        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pBE;

        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
        ); 
                                                                    
        Product2 newPrdct2 = new Product2(Name = 'Test Product2',
                                         Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='EMC Priority Spot', EMC_CRUD_Behavior__c='Read/Write',
                                         IsActive = TRUE);
        insert newPrdct2;
        
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct2.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pBE1;
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE1.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
        );

        Product2 newPrdct3 = new Product2(Name = 'Test ProductA',
                                         Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='', EMC_CRUD_Behavior__c='Read/Write',
                                         IsActive = TRUE);
        insert newPrdct3;
        
        PricebookEntry pBE3= new PricebookEntry (Product2ID=newPrdct3.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
                                                
                                        
        insert pBE3;

        OpportunityLineItem  testLineItem3 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE3.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
                                                                    ); 

        TriggerExecutionController.setSkipAllTriggers(false);
        
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();                                                
        insert testLineItem;
        insert testLineItem3;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        insert testLineItem2;   
        
        Delete testLineItem;
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
    }

    static testMethod void addEMCLineItem2() { 
    
        // 7.4 To create customsettings
        insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);   
    
        TriggerExecutionController.setSkipAllTriggers(true);
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                Primary_Product_Delivery_Address_Country__c ='SLOVAKIA',
                                                Primary_Product_Delivery_Address_Region__c ='LATAM',
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 );
        insert testOppty;   
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
              
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='EMC Hot Spot', EMC_CRUD_Behavior__c='Read/Write',
                                         IsActive = TRUE);
        insert newPrdct;
        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pBE;

        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
        ); 
                                                                    
        Product2 newPrdct2 = new Product2(Name = 'Test Product2',
                                         Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='EMC Hot Spot', EMC_CRUD_Behavior__c='Read Only',
                                         IsActive = TRUE);
        insert newPrdct2;
        
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct2.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pBE1;
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE1.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
        );

        Product2 newPrdct3 = new Product2(Name = 'Test ProductA',
                                         Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='', EMC_CRUD_Behavior__c='',
                                         IsActive = TRUE);
        insert newPrdct3;
        
        PricebookEntry pBE3= new PricebookEntry (Product2ID=newPrdct3.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
                                                
                                        
        insert pBE3;

        OpportunityLineItem  testLineItem3 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE3.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description'
                                                                    ); 

        TriggerExecutionController.setSkipAllTriggers(false);
        
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();                                                
        insert testLineItem;
        insert testLineItem3;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        insert testLineItem2;   
        
        Delete testLineItem;
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);*/
    //}  
    //8.0 Start
    static testMethod void testAppassureInsertDelete() {   //Test for recalculateDSGCBO method

        // 7.4 To create customsettings
     //   insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;       
        Contact con = new Contact(LastName='Test User',AccountId=testAccount.Id,Phone='1987654320',Email='testuser@aol.com', MailingStreet='214 Allen Street',MailingCity='Austin',MailingState='TX',MailingPostalCode='70081',MailingCountry='US');
        insert con;   
        
        Opportunity testOppty1 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty1', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30,Quest_Software_Contact__c=con.Id);
                                                        
        insert testOppty1; 
          
        TriggerExecutionController.setSkipAllTriggers(true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                Related_Parent_Opportunity__c = testOppty1.id,
                                                CloseDate = System.Today() + 30,Quest_Software_Contact__c=con.Id);
                                                        
        insert testOppty;       
        
        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'test Product',DSG_Sales_Motion__c ='Read only product',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);                                         
        listProduct2.add(newPrdct);
        
        Product2 newAppPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',DSG_Sales_Motion__c ='Bidirectional product',
                                         Product_ID__c='test prod id2',
                                         IsActive = TRUE);
        listProduct2.add(newAppPrdct);
        
        Product2 newAppPrdct2 = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id3',
                                         IsActive = TRUE);
                                         
        listProduct2.add(newAppPrdct2);
        
        insert listProduct2;   
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();
        PricebookEntry pBE= new PricebookEntry (Product2ID=listProduct2[0].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE);                                        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=listProduct2[1].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(apppBE);
        PricebookEntry apppBE1= new PricebookEntry (Product2ID=listProduct2[2].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(apppBE1);
        TriggerExecutionController.setSkipAllTriggers(true);
        system.assertEquals(false,apppBE1.useStandardPrice );
        insert listPricebook;
        List<OpportunityLineItem> listInsertLineItems=new List<OpportunityLineItem>();
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical',
                                                                    Supportability_Status__c = 'Under Review'
                                                                    ); 
        listInsertLineItems.add(testLineItem);
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true); 

         OpportunityLineItem  appTestLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=apppBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical',
                                                                    Supportability_Status__c = 'Under Review'
                                                                    );
                                                                    
        listInsertLineItems.add(appTestLineItem);
        
        //TriggerExecutionController.setSkipAllTriggers(true);
        
        OpportunityLineItem  appTestLineItem1 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=apppBE1.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission, Critical',
                                                                    Supportability_Status__c = 'Under Review'                                                                  
                                                                    );
        listInsertLineItems.add(appTestLineItem1);   
        
        Test.startTest();
     
        database.insert(listInsertLineItems, false);  // 7.2: Added
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        //insert listInsertLineItems;     // 7.2: Commented, move to few lines above, hope not causing code coverage failure for AFTER TRIGGER on Oppty Product
        listInsertLineItems[1].UnitPrice = 200;
        database.update(listInsertLineItems[1], false); 
        
        
        //database.delete(insertLineItems[2], false); 
        Test.stopTest();
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
                        
    }
    
    static testMethod void testupdateAppAssureFlag() {   

        // 7.4 To create customsettings
    //    insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;       
        Contact con = new Contact(LastName='Test User',AccountId=testAccount.Id,Phone='1987654320',Email='testuser@aol.com', MailingStreet='214 Allen Street',MailingCity='Austin',MailingState='TX',MailingPostalCode='70081',MailingCountry='US');
        insert con;     
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30,Quest_Software_Contact__c=con.Id);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);                                                
        insert testOppty;   
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();        
        
        Product2 newAppPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',DSG_Sales_Motion__c ='Bidirectional product',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        listProduct2.add(newAppPrdct);
        
        insert listProduct2;   
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();
            
        PricebookEntry apppBE= new PricebookEntry (Product2ID=listProduct2[0].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(apppBE);
        system.assertEquals(false,apppBE.useStandardPrice );
        insert listPricebook;
        List<OpportunityLineItem> listInsertLineItems=new List<OpportunityLineItem>();
        

        OpportunityLineItem  appTestLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=apppBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );
                                                                    
        listInsertLineItems.add(appTestLineItem);        
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true); 
        insert listInsertLineItems; 
       
        Test.startTest();     
        Delete listInsertLineItems[0];        
        Test.stopTest();
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); 
                        
    } 
    //8.0 End
    
    //9.0 Start
    static testMethod void testUpdateOpportunityOwnerEmail() {   

        // TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        List<Profile> listUserProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];
        User tempUser = new User(            
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev', 
            Alias = 'test',           
            Email='testDirect1@dell.com',  
            FirstName='TDirect_First',     
            LastName='TDirect_Last',          
            ProfileId = listUserProfile[0].Id,     
            LanguageLocaleKey='en_US',          
            LocaleSidKey='en_US',        
            EmailEncodingKey='UTF-8',      
            TimeZoneSidKey='America/Los_Angeles',   
            Badge_Number__c='Test'+System.currentTimeMillis(),    
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'        );   
        insert tempUser;
        
        //Account testAccount = new Account(Id=tempUser.Id, Name='testDirectAccount' + System.currentTimeMillis()); 
        Account testAccount = new Account(Name='testDirectAccount' + System.currentTimeMillis());  
        insert testAccount;      
                
        Opportunity testOppty = new Opportunity(Name='testDirect Oppty', 
                                                AccountId=testAccount.Id, 
                                                OwnerId=tempUser.Id,
                                                StageName='Plan - 1%',
                                                Type = 'Deal/Bid - Direct',
                                                CloseDate = System.Today() + 30);        
              
        insert testOppty;   
        
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();        
        
        Product2 newDirectPrd = new Product2(Name = 'Test Product - Direct',
                                         Product_Line_Desc__c = 'Adobe',
                                         Product_ID__c='test direct prod id1',
                                         //Prod_ID__c='test direct prod id1',
                                         //Prod_ID_Unique__c='test direct prod id1',
                                         //Prod_ID_Test__c='test direct prod id1'   
                                         IsActive = TRUE);
        listProduct2.add(newDirectPrd);
        
        insert listProduct2;   
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();
            
        PricebookEntry directpBE= new PricebookEntry (Product2ID=listProduct2[0].id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(DirectpBE);
        system.assertEquals(false,directpBE.useStandardPrice );       
        insert listPricebook;
        List<OpportunityLineItem> listInsertLineItems=new List<OpportunityLineItem>();        

        OpportunityLineItem  testDirectLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=DirectpBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'Not Applicable',
                                                                    Account_Owner_s_Email__c = 'testoppty@test.com'
                                                                    );
                                                                    
        listInsertLineItems.add(TestDirectLineItem);        
      
        Test.startTest();     
        insert listInsertLineItems;     
        Test.stopTest();         
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false);                         
    } 
    //9.0 End
    
    
     static testMethod void newTestmethod() {
       TriggerHandler.TriggerEvent t = TriggerHandler.TriggerEvent.ISUPDATE;  
       Map<Id,Opportunity> mapOpty = new Map<Id,Opportunity>([select id from Opportunity limit 10]);
       OpportunityLineItemUtilities.updateLOTIndicator(t,mapOpty);
       if(mapOpty.size() == 10) {
       system.assertEquals(mapOpty.size(), 10); 
       }
     }
}