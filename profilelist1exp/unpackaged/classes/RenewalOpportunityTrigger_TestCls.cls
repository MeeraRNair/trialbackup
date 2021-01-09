/*        
* Revision Ref Number  Release No  Date            Modified By     Description
* -------- ----------  ----------  -----------     ------------    -----------
* CR-17797  Story 6302878 FY20-0802  10-July- 2019  Ankur Saxena    RE024- Creation of a Dummy line Item
* CR-18376  Story 7754350 FY21-0202  05-Feb-2020    Shubham Bhatt   Fixing 101 issue 
*/

@isTest(SeeAllData= false)
Public Class RenewalOpportunityTrigger_TestCls { 
    @testSetup static void setup() {
        
        //create custom setting
        EMC_General_Settings__c objGS = New EMC_General_Settings__c(Create_Quote_Encrypt_Key__c = 'dg67ewh1ImzndDwy1ISgMQ==',
                                                                    Direct_Distribution_Channels__c = 'Direct' ,
                                                                    Hybris_URL__c = 'https://myquotes-qav.emc.com/createQuote/createQuoteFromSFDC');
        
        //insert objGS; 
        
        OWD__c owdSetting = New OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert owdSetting;    
        
        
        list<RenewalsLabels__c> listRenLabels = New list<RenewalsLabels__c>();
        
        listRenLabels.add(New RenewalsLabels__c(Name = 'sourceSystem_EMC_Core', labelValue__c = 'EMC Core'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'sourceSystem_Renewals_EBIA', labelValue__c = 'Renewals EBIA'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'teamMemberRole', labelValue__c = 'Service Global Renewals Sales Rep'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'type_EMC_Renewals_Direct', labelValue__c = 'EMC Renewals Direct'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'type_EMC_Renewals_In_Direct', labelValue__c = 'EMC Renewals In-Direct'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'Standard Price Book', labelValue__c = '01s300000001iPv'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'LA Standard Catalog', labelValue__c = '01s300000001iPv'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'EMEA Standard Catalog', labelValue__c = '01s30000000EIah'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'ABU/APJ Standard Catalog', labelValue__c = '01s30000000EIYH'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'RenewalWaitingSync', labelValue__c = 'Renewal Waiting Sync'));
        
        insert listRenLabels;   
        
    }
    
    
    Public Static String getAPOSRecordTypeId(){
        id idAPOSRecordType = [select id, name from RecordType where DeveloperName='APOS' and sObjectType = 'Opportunity' limit 1].id;
        Return String.valueOf(idAPOSRecordType);
    }
    
    
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
    
    
    
    Public Static testMethod void addDummy2(){
        String strPId = createBasicObject();
        
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "RenewalOpportunityTriggerHandlerBI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Boomi Integration API Only' LIMIT 1];
        User usr = New User(LastName = 'Integration User',
                            FirstName ='Renewals Core',
                            Alias = 'jliv',
                            Email = 'jason.liveston@dell.com',
                            Username = 'jason.liveston@dell.com',
                            ProfileId = profileId.id,
                            Badge_Number__c='12348769',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        
        System_Behavior_Bypasser__c  sc = new System_Behavior_Bypasser__c();
        sc.Bypass_Opportunity_VRs__c = true;
        sc.SetupOwnerId = usr.profileId;
        insert Sc;
        
        list<Product2> listProduct = New list<Product2>();
        // Creating Products
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
        
        Recordtype idAPOSRecordType = [select id, name, DeveloperName from RecordType where DeveloperName='APOS' and sObjectType = 'Opportunity' limit 1];
        
        list<Opportunity> listOpp = New list<opportunity>();
        list<opportunity> listopp1 = New list<opportunity>();
        System.runAs(usr){
            //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            list<Sales_Channel_Group__c> listscr = new list<Sales_Channel_Group__c >();
            Sales_Channel_Group__c scr = new Sales_Channel_Group__c();
            scr.name = 'test1';
            scr.Regional_Parent_Name__c ='AMER';
            scr.Regional_Sub_Parent_Name__c='NORTH AMER';
            listscr.add(scr);
            
            Sales_Channel_Group__c scr1 = new Sales_Channel_Group__c();
            scr1.name = 'test1';
            scr1.Regional_Parent_Name__c ='APJ';
            scr1.Regional_Sub_Parent_Name__c='Test';
            listscr.add(scr1);
            
            Sales_Channel_Group__c scr2 = new Sales_Channel_Group__c();
            scr2.name = 'test1';
            scr2.Regional_Parent_Name__c ='EMEA';
            scr2.Regional_Sub_Parent_Name__c='Test';
            listscr.add(scr2);
            
            Sales_Channel_Group__c scr3 = new Sales_Channel_Group__c();
            scr3.name = 'test1';
            scr3.Regional_Parent_Name__c ='APJ';
            scr3.Regional_Sub_Parent_Name__c='Test';
            listscr.add(scr3);
            insert listscr;
            
            //Creating Account
            list<Account> listAcc = new list<Account>();
            Account testAcc = New Account();
            testAcc.name = 'Some test Account2';        
            testAcc.status__c = 'Active';
            testAcc.Sales_Channel__c = listscr[0].id;
            testAcc.Account_Country_Code__c='US';              
            listAcc.add(testAcc);
            
            Account testAcc1 = New Account();
            testAcc1.name = 'Some test Account2';        
            testAcc1.status__c = 'Active';
            testAcc1.Sales_Channel__c = listscr[1].id;
            testAcc1.Account_Country_Code__c='US';              
            listAcc.add(testAcc1); 
            
            Account testAcc2 = New Account();
            testAcc2.name = 'Some test Account2';        
            testAcc2.status__c = 'Active';
            testAcc2.Sales_Channel__c = listscr[2].id; 
            testAcc2.Account_Country_Code__c='US';              
            listAcc.add(testAcc2);   
            
            insert listAcc;            
            //Creating Opportunity
            List<Opportunity> oppLst = new List<Opportunity>();
            Opportunity testOpportunity = New Opportunity();
            testOpportunity.RecordTypeid = idAPOSRecordType.id;
            system.debug('==== testOpportunity.RecordTypeid =='+testOpportunity.RecordTypeid);
            testOpportunity.name='test APOS2';
            testOpportunity.Accountid=listAcc[0].id; 
            testOpportunity.CloseDate=system.today()  + 5;
            testopportunity.pricebook2Id = strPId;             
            testOpportunity.CurrencyIsoCode='USD';                        
            testOpportunity.StageName='Discover - 10%';                                   
            testOpportunity.LeadSource = 'Contract Renewal';
            testOpportunity.Source_System__c = 'Renewals EBIA';
            testOpportunity.amount = 501;
            //testOpportunity.Type = 'EMC Renewals-Direct';
            testOpportunity.EMC_Opportunity_Amount__c = 50000;  
            //insert testOpportunity;
            oppLst.add(testOpportunity);
            
            //Creating Opportunity
            Opportunity testOpportunity1 = New Opportunity();
            testOpportunity1.RecordTypeid = idAPOSRecordType.id;
            system.debug('==== testOpportunity.RecordTypeid =='+testOpportunity.RecordTypeid);
            testOpportunity1.name='test APOS2';
            testOpportunity1.Accountid=listAcc[0].id; 
            testOpportunity1.CloseDate=system.today()  + 5;
            //testopportunity.pricebook2Id = strPId;             
            testOpportunity1.CurrencyIsoCode='USD';                        
            testOpportunity1.StageName='Discover - 10%';                                   
            testOpportunity1.LeadSource = 'Contract Renewal';
            testOpportunity1.Source_System__c = 'Renewals EBIA';
            testOpportunity1.amount = 501;
            //testOpportunity.Type = 'EMC Renewals-Direct';
            testOpportunity1.EMC_Opportunity_Amount__c = 50000;  
            //insert testOpportunity1;
            oppLst.add(testOpportunity1);
            
            insert oppLst;
            
            set<id> setId = new set<id>();
            setId.add(listAcc[0].id);
            setId.add(listAcc[1].id);
            setId.add(listAcc[2].id);
            //list<Account> listtest = [select id,name,Regional_Parent_Name_lookup__c,Regional_Sub_Parent_Name_lookup__c,Sales_Channel__c from Account where ID IN : setId];
            // system.debug('listtest===='+ listtest);
            //map<id,Account> mapAcc = new map<id,Account>(listtest);
            RenewalOpportunityTriggerHandler.getValidatePricebook(setId);
            // Creating Opportunity Line Items   
            list<OpportunityLineItem> listlineItem = New list<OpportunityLineItem >();
            OpportunityLineItem oppli = New OpportunityLineItem(); //---->Create OpportunityLineItem.
            oppli.PricebookEntryId= listPricebook[3].id;
            oppli.OpportunityId = testOpportunity.id;
            oppli.Quantity = 1;
            oppli.TotalPrice = 500;
            oppli.product2Id = listProduct[3].id;
            listlineItem.add(Oppli);
            insert listlineitem;
            
            Test.startTest();
            strMockMetaData = '';
            mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
            };
                
                for(String strEvent : mapEvents.keySet()) {
                    strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                        + '"NamespacePrefix": "",'
                        + '"Event__c": "' + strEvent + '", '
                        + '"sObject__c": "Opportunity", "Class_Name__c": "RenewalOpportunityTriggerHandlerAU"},';
                }
            
            strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
            
            MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
            
            Opportunity opptyG = [Select id, stageName from opportunity where id = :testOpportunity.Id];
            system.debug('Gan bf= ' + opptyG.id + ' Stage: ' + opptyG.StageName);
            testOpportunity.StageName='Plan - 1%';
            testOpportunity.EMC_Opportunity_Amount__c = 500;
            update testOpportunity;
            
            // Creating Second Opportunity   
            Opportunity testOpportunity2 = New Opportunity();
            testOpportunity2.RecordTypeid = idAPOSRecordType.id;
            system.debug('==== testOpportunity.RecordTypeid =='+testOpportunity2.RecordTypeid);
            testOpportunity2.name='test APOS21';
            testOpportunity2.Accountid=listAcc[1].id; 
            testOpportunity2.CloseDate=system.today()  + 5;
            testOpportunity2.pricebook2Id = strPId;             
            testOpportunity2.CurrencyIsoCode='USD';                        
            testOpportunity2.StageName='Discover - 10%';                                   
            testOpportunity2.LeadSource = 'Contract Renewal';
            testOpportunity2.Source_System__c = 'Renewals EBIA';
            testOpportunity2.amount = 501;
            //testOpportunity.Type = 'EMC Renewals-Direct';
            testOpportunity2.EMC_Opportunity_Amount__c = 501;  
            insert testOpportunity2;
            
            Opportunity testOpportunity3 = New Opportunity();
            testOpportunity.RecordTypeid = idAPOSRecordType.id;
            system.debug('==== testOpportunity.RecordTypeid =='+testOpportunity.RecordTypeid);
            testOpportunity3.name='test APOS2';
            testOpportunity3.Accountid=listAcc[0].id; 
            testOpportunity3.CloseDate=system.today()  + 5;
            testopportunity3.pricebook2Id = RenewalsLabels__c.getInstance('LA Standard Catalog').labelValue__c;            
            testOpportunity3.CurrencyIsoCode='USD';                        
            testOpportunity3.StageName='Discover - 10%';                                   
            testOpportunity3.LeadSource = 'Contract Renewal';
            testOpportunity3.Source_System__c = 'Renewals EBIA';
            testOpportunity3.amount = 501;
            //testOpportunity.Type = 'EMC Renewals-Direct';
            testOpportunity3.EMC_Opportunity_Amount__c = 501;  
            TriggerExecutionController.setSkipAllTriggers(true);
            insert testOpportunity3;
            TriggerExecutionController.setSkipAllTriggers(false);
            // Creating Opportunity Line Item
            OpportunityLineItem oppl = New OpportunityLineItem(); //---->Create OpportunityLineItem.
            oppl.PricebookEntryId= listPricebook[1].id;
            oppl.OpportunityId = testOpportunity2.id;
            oppl.Quantity = 1;
            oppl.TotalPrice = 500;
            oppl.product2Id = listProduct[1].id;
            //insert oppl;
            
            OpportunityLineItem oppl1 = New OpportunityLineItem(); //---->Create OpportunityLineItem.
            oppl1.PricebookEntryId= listPricebook[1].id;
            oppl1.OpportunityId = testOpportunity2.id;
            oppl1.Quantity = 1;
            oppl1.TotalPrice = 500;
            oppl1.product2Id = listProduct[1].id;
            //insert oppl1;
            
            //delete oppl1;
            
            //Updating Second Opportunity
            Opportunity opptyG1 = [Select id, stageName from opportunity where id = :testOpportunity2.Id];
            system.debug('Gan bf= ' + opptyG1.id + ' Stage: ' + opptyG1.StageName);
            testOpportunity2.StageName='Plan - 1%';
            testOpportunity2.EMC_Opportunity_Amount__c = 501;
            update testOpportunity2;  
            
            
            /*   
list<OpportunityLineItem> listlineItems = New list<OpportunityLineItem >();
OpportunityLineItem oppl = New OpportunityLineItem(); //---->Create OpportunityLineItem.
oppl.PricebookEntryId= listPricebook[1].id;
oppl.OpportunityId = testOpportunity.id;
oppl.Quantity = 1;
oppl.TotalPrice = 500;
oppl.product2Id = listProduct[1].id;
listlineItems.add(Oppl);


OpportunityLineItem oppl1 = New OpportunityLineItem(); //---->Create OpportunityLineItem.
oppl1.PricebookEntryId= listPricebook[2].id;
oppl1.OpportunityId = testOpportunity.id;
oppl1.Quantity = 1;
oppl1.TotalPrice = 500;
oppl1.product2Id = listProduct[2].id;
listlineItems.add(Oppl1);
insert listlineitems; */
            
            opptyG = [Select id,EMC_Opportunity_Amount__c ,amount, stageName from opportunity where id = :testOpportunity.Id];
            System.assertEquals(testOpportunity3.EMC_Opportunity_Amount__c,testOpportunity3.Amount);                                
            test.StopTest();
        }
    }
    //Creating new method 
    Public Static testMethod void addDummy3(){
        String strPId = createBasicObject();
        
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeUpdate' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "RenewalOpportunityTriggerHandlerBU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Boomi Integration API Only' LIMIT 1];
        User usr = New User(LastName = 'Integration User',
                            FirstName ='Renewals Core',
                            Alias = 'jliv',
                            Email = 'jason.liveston@dell.com',
                            Username = 'jason.liveston@dell.com',
                            ProfileId = profileId.id,
                            Badge_Number__c='12348769',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        
        System_Behavior_Bypasser__c  sc = new System_Behavior_Bypasser__c();
        sc.Bypass_Opportunity_VRs__c = true;
        sc.SetupOwnerId = usr.profileId;
        insert Sc;
        
        list<Product2> listProduct = New list<Product2>();
        // Creating Products
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
        
        Recordtype idAPOSRecordType = [select id, name, DeveloperName from RecordType where DeveloperName='APOS' and sObjectType = 'Opportunity' limit 1];
        
        list<Opportunity> listOpp = New list<opportunity>();
        list<opportunity> listopp1 = New list<opportunity>();
        System.runAs(usr){
            //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
            //TriggerExecutionController.setSkipOpportunityTriggers(true);
            
            //Creating Account
            Account testAcc = New Account();
            testAcc.name = 'Some test Account2';        
            testAcc.status__c = 'Active';
            testAcc.Account_Country_Code__c='US';              
            insert testAcc;
            //Creating Opportunity
            Opportunity testOpportunity = New Opportunity();
            testOpportunity.RecordTypeid = idAPOSRecordType.id;
            system.debug('==== testOpportunity.RecordTypeid =='+testOpportunity.RecordTypeid);
            testOpportunity.name='test APOS2';
            testOpportunity.Accountid=testAcc.id; 
            testOpportunity.CloseDate=system.today()  + 5;
            testopportunity.pricebook2Id = strPId;             
            testOpportunity.CurrencyIsoCode='USD';                        
            testOpportunity.StageName='Discover - 10%';                                   
            testOpportunity.LeadSource = 'Contract Renewal';
            testOpportunity.Source_System__c = 'Renewals EBIA';
            testOpportunity.amount = 501;
            //testOpportunity.Type = 'EMC Renewals-Direct';
            testOpportunity.EMC_Opportunity_Amount__c = 50000;  
            insert testOpportunity;
            
            // Creating Opportunity Line Items   
            list<OpportunityLineItem> listlineItem = New list<OpportunityLineItem >();
            OpportunityLineItem oppli = New OpportunityLineItem(); //---->Create OpportunityLineItem.
            oppli.PricebookEntryId= listPricebook[1].id;
            oppli.OpportunityId = testOpportunity.id;
            oppli.Quantity = 1;
            oppli.TotalPrice = 400;
            oppli.product2Id = listProduct[1].id;
            
            
            
            insert listlineitem;
            
            Test.startTest();
            
            
            strMockMetaData = '';
            mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
            };
                
                for(String strEvent : mapEvents.keySet()) {
                    strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                        + '"NamespacePrefix": "",'
                        + '"Event__c": "' + strEvent + '", '
                        + '"sObject__c": "Opportunity", "Class_Name__c": "RenewalOpportunityTriggerHandlerAU"},';
                }
            
            strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
            
            MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
            
            Opportunity opptyG = [Select id, stageName from opportunity where id = :testOpportunity.Id];
            system.debug('Gan bf= ' + opptyG.id + ' Stage: ' + opptyG.StageName);
            testOpportunity.StageName='Plan - 1%';
            testOpportunity.EMC_Opportunity_Amount__c = 500;
            //testOpportunity.Pricebook2Id = null;
            update testOpportunity;
            
            OpportunityLineItem oppli1 = New OpportunityLineItem(); //---->Create OpportunityLineItem.
            oppli1.PricebookEntryId= listPricebook[2].id;
            oppli1.OpportunityId = testOpportunity.id;
            oppli1.Quantity = 1;
            oppli1.TotalPrice = 200;
            oppli1.product2Id = listProduct[2].id;
            insert oppli1;
            
            opptyG = [Select id,EMC_Opportunity_Amount__c ,amount, stageName from opportunity where id = :testOpportunity.Id];
            System.assertEquals(opptyG.EMC_Opportunity_Amount__c,opptyG.Amount);                                
            test.StopTest();
        }
    }
     
    
    
    /*********------ Added by Shahid_Hussain-------STORY-7643105 ***************/
    Public Static testMethod void setEMCOpportunityUpdatedtestBI(){
        String strPId = createBasicObject();
        
        Test.startTest(); 
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "RenewalOpportunityTriggerHandlerBI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Business Admin' LIMIT 1];
        
        User usr = New User(LastName = 'User',
                            FirstName ='Business',
                            Alias = 'jliv',
                            Email = 'jason.liveston@dell.com',
                            Username = 'jason.liveston@dell.com',
                            ProfileId = profileId.id,
                            Badge_Number__c='12348769',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        System_Behavior_Bypasser__c  sc = new System_Behavior_Bypasser__c();
        sc.Bypass_Opportunity_VRs__c = true;
        sc.SetupOwnerId = usr.profileId;
        insert Sc;
        
        Recordtype idAPOSRecordType = [select id, name, DeveloperName from RecordType where DeveloperName='APOS' and sObjectType = 'Opportunity' limit 1];
        
        System.runAs(usr){
            Account testAcc = New Account();
            testAcc.name = 'Some test Account2';        
            testAcc.status__c = 'Active';
            testAcc.Account_Country_Code__c='US';              
            insert testAcc;
            
            // Positive Scenario
            Opportunity testOpportunity1 = New Opportunity();
            testOpportunity1.RecordTypeid = idAPOSRecordType.id;
            testOpportunity1.name='test APOS3';
            testOpportunity1.Accountid= testAcc.id;
            testOpportunity1.CloseDate=system.today()  + 5;
            testOpportunity1.CurrencyIsoCode='USD';                        
            testOpportunity1.StageName='Discover - 10%';                                  
            
            testOpportunity1.Source_System__c = 'Renewals EBIA';
            
            // TriggerExecutionController.setSkipAllTriggers(true);
            insert testOpportunity1;
            //TriggerExecutionController.setSkipAllTriggers(false);
            opportunity opp1 = [select id, EMC_Opportunity_updated__c from opportunity where id =:testOpportunity1.id ];
            system.assertequals(opp1.EMC_Opportunity_updated__c,'Renewal Waiting Sync');
            
            test.StopTest();
        }
        
    }  
    
    Public Static testMethod void setEMCOpportunityUpdatedtestBU(){
        String strPId = createBasicObject();
        Test.startTest(); 
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeUpdate' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "RenewalOpportunityTriggerHandlerBU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Business Admin' LIMIT 1];
        
        User usr = New User(LastName = 'Business User',
                            FirstName ='Business Core',
                            Alias = 'jliv',
                            Email = 'jason.liveston@dell.com',
                            Username = 'jason.liveston@dell.com',
                            ProfileId = profileId.id,
                            Badge_Number__c='12348769',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        
        System_Behavior_Bypasser__c  sc = new System_Behavior_Bypasser__c();
        sc.Bypass_Opportunity_VRs__c = true;
        sc.SetupOwnerId = usr.profileId;
        insert Sc;
        
        Recordtype idAPOSRecordType = [select id, name, DeveloperName from RecordType where DeveloperName='APOS' and sObjectType = 'Opportunity' limit 1];
        
        System.runAs(usr){
            Account testAcc = New Account();
            testAcc.name = 'Some test Account2';        
            testAcc.status__c = 'Active';
            testAcc.Account_Country_Code__c='US';              
            insert testAcc;
            
            
            list<Opportunity> listOpp = new list<Opportunity>();
            
            
            Opportunity testOpportunity1 = New Opportunity();
            testOpportunity1.RecordTypeid = idAPOSRecordType.id;
            
            testOpportunity1.name='test APOS3';
            testOpportunity1.Accountid=testAcc.id;
            testOpportunity1.CloseDate=system.today()  + 5;
            testOpportunity1.CurrencyIsoCode='USD';                        
            testOpportunity1.StageName='Discover - 10%';                                  
            testOpportunity1.LeadSource = 'Contract Renewal';
            testOpportunity1.Source_System__c = 'Renewals EBIA';
            testOpportunity1.amount = 501;
            testOpportunity1.EMC_Opportunity_Amount__c = 50000;
            testOpportunity1.PO_at_Partner__c = false;
            testOpportunity1.ForecastCategoryName = 'Pipeline';
            testOpportunity1.VCE_Forecast_Amount__c =10000;
            //testOpportunity1.Support_Level__c = 'Basic';
            testOpportunity1.PO_Number__c = 'test123';
            testOpportunity1.Renewals_Campaign__c = 'Call Out';
            
            
            testOpportunity1.Primary_Alliance_Partner__c = 'test 123';
            testOpportunity1.Reason_Won_Lost__c = 'Incumbent';
            testOpportunity1.Confirm_Competitor_Lost_To__c = 'Advantech';
            testOpportunity1.Confirm_Competitor_Lost_To_Product__c = 'Block';
            testOpportunity1.Probability = 50;
            testOpportunity1.Discount_Percentage__c = 5;
            testOpportunity1.EMC_Opportunity_updated__c = 'Waiting Sync';
            listOpp.add(testOpportunity1);
            insert listOpp;
            system.debug('-testOpportunity1.EMC_Opportunity_updated__c--'+testOpportunity1.EMC_Opportunity_updated__c);
            //Positive Scenario
            //testOpportunity.CloseDate=system.today()  + 10;
            
            
            testOpportunity1.Discount_Percentage__c = 15;
            testOpportunity1.Probability = 10;
            testOpportunity1.amount = 12;
            update testOpportunity1;
            system.debug('-testOpportunity1.testOpportunity1---'+testOpportunity1);
            opportunity opp1 = [select id, EMC_Opportunity_updated__c from opportunity where id =:testOpportunity1.id ];
            system.assertequals(opp1.EMC_Opportunity_updated__c,'Renewal Waiting Sync');
            
            test.StopTest();
        } 
        
    }  
    /*********------ Added by Shahid_Hussain-------STORY-7643105 ***************/
    
}