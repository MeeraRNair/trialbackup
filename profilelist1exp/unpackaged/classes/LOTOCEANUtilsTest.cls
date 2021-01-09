/*
Author: Raymond Yip

History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      23-Apr-2010    Raymond         Updated for CR2559, CR2560, R11.5
1.1      29-Jun-2010    Carmen          Updated for CR2804
1.2      15-Sep-2012    Krishnamoorthi  Updated for Production Assertion Issues during  SonicWall config deployment (lines commented 141 and 205)
2.0      21-Feb-2013    MenMee          Updated for Too many SOQL queries exception. move Test.startTest() after setupTestData()
3.0     08-June-2016    Fenny           Fix "Too many SOQL queries: 101"
                                        Manipulate test data to cover OpportunityLineItemUtilities.updaetLOTIndicator
                                        Add a new test method testUpdateLOTIndicator to cover OpportunityLineItemUtitlies.updateLOTIndicator
4.0      02-Jan-2020    Shubham Bhatt   FY21-DCS-0202    CR 18399- defined @testSetup and added custom setting in setup(GroupName__c) (added for opportunity split ) 
*/ 
@isTest 
Private Class LOTOCEANUtilsTest { 
    
    @testSetup static void setup() {
        //added by Shubham Bhatt(rubicon)   Added custom setting in setup(GroupName__c) (added for opportunity split ) 
        list<GroupName__c> listGroupName = New list<GroupName__c>();
        listGroupName.add(New GroupName__c(Name = 'FPG_DPS__c', Group_Name__c = 'DPS',Label__c = 'Forecast Product Group DPS',API_Name__c = 'FPG_DPS__c'));
        listGroupName.add(New GroupName__c(Name = 'FPG_MDC__c', Group_Name__c = 'MDC',Label__c = 'Forecast Product Group DPS',API_Name__c = 'FPG_MDC__c'));
        listGroupName.add(New GroupName__c(Name = 'FPG_UDS__c', Group_Name__c = 'UDS',Label__c = 'Forecast Product Group DPS',API_Name__c = 'FPG_UDS__c'));
        listGroupName.add(New GroupName__c(Name = 'FPG_Enterprise__c', Group_Name__c = 'Enterprise',Label__c = 'Forecast Product Group DPS',API_Name__c = 'FPG_Enterprise__c'));
        insert listGroupName;
        
        
    }
    Static Opportunity testOppty,testOppty3;
    Static List<Product2> listTestProd;
    Static PriceBookEntry pbe1;
    Static PriceBookEntry pbe2;
    Static PriceBookEntry pbe3;
    Static List<OpportunityLineItem> listOli;
    
    Static List<Ocean_Data__c> listOceanData = New List<Ocean_Data__c>(); // 3.0
    Static List<LOT_Region__c> listLOTRegion = New List<LOT_Region__c>(); // 3.0
    Static Ocean_Data__c testOceanData;
    Static LOT_REGION__c testLOTRegion;
    Static LOT_OCEAN_EMAIL__c testLOTOceanEmail;    
    Static Sales_Channel_Group__c testSalesChannelGrp;
    Static Account testAccount;
    
    /*
    Private Static void setupTestData() {  
        
        testSalesChannelGrp = New Sales_Channel_Group__c(Name='TestChannelGroup1', Region_Name__c='REGION1', Segment_Business_Unit_Name__c='LARGE ENTERPRISE');
        
        insert testSalesChannelGrp;
        
        testAccount = New Account(Name='TestAccount', Sales_Channel__c=testSalesChannelGrp.Id);
        insert testAccount;
        
        testOceanData = New Ocean_Data__c(Days_in_country_Delivery__c=70,On_the_sea_by_ODM__c=70,
                                          CFI_Delivery_Time_in_Weeks__c=10, CFS_Delivery_Time_in_Weeks__c=10,
                                          Exception_Country__c='ABC',    //Lead_Time_in_Weeks__c=10,
                                          MSP_Incremental_in_Weeks__c=10, Region__c='ABC',
                                          Ship_Rate__c=4, Source__c='Compal', Pallet_Rate__c=2);
        
        // 3.0
        Ocean_Data__c testOceanData2 = New Ocean_Data__c(Days_in_country_Delivery__c = 70, On_the_sea_by_ODM__c = 70,
                                                         CFI_Delivery_Time_in_Weeks__c = 10, CFS_Delivery_Time_in_Weeks__c = 10,
                                                         Exception_Country__c ='COUNTRY1',    //Lead_Time_in_Weeks__c=10,
                                                         MSP_Incremental_in_Weeks__c = 10, Region__c ='REGION1',
                                                         Ship_Rate__c = 4, Source__c ='Compal', Pallet_Rate__c=2);
        
        listOceanData.add(testOceanData);
        listOceanData.add(testOceanData2);
        insert listOceanData;
        
        //insert testOceanData; // 3.0
        
        testLOTRegion = New LOT_Region__c(Name='COUNTRY1', Region__c='REGION1', Threshold_Region__c='EMEA');
        LOT_Region__c testLOTRegion2 = New LOT_Region__c(Name ='ABC', Region__c='ABC', Threshold_Region__c='EMEA'); // 3.0
        listLOTRegion.add(testLOTRegion);
        listLOTRegion.add(testLOTRegion2);
        insert listLOTRegion;
        
        //insert testLOTRegion; // 3.0
        
        testLOTOceanEmail = New LOT_OCEAN_EMAIL__c(Country__c=testLOTRegion.Id, Country_LE__c='test@testmail.com', region__c='REGION1');
        
        insert testLOTOceanEmail;
        
        List<Opportunity> listOpp = New List<Opportunity>();
        testOppty3 = New Opportunity(RecordTypeId='012300000004zf2', Quote_Numbers__c = '123456', Customer_Requested_Delivery_Date__c=system.today() + 60, StageName='Qualify - 30%', Probability=30, AccountId=testAccount.Id, Name='TEST Oppty 3', CloseDate = System.today() + 30, Primary_Product_Delivery_Address_Region__c = 'REGION1', Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',Region__c='APJ',Competitor_Lost_To__c='Unknown',Partner_Opportunity_Stage__c='Qualify - 30%');
        //insert testOppty3;
        listOpp.add(testOppty3);
        
        testOppty = New Opportunity(RecordTypeId='012300000004zf2AAA', Primary_Competitor__c='Unknown', Quote_Numbers__c = '123456', Customer_Requested_Delivery_Date__c=system.today() + 60, StageName='Plan - 1%', Probability=60, AccountId=testAccount.Id, Name='TEST Oppty 1', CloseDate = System.today() + 30, Primary_Product_Delivery_Address_Region__c = 'REGION1', Primary_Product_Delivery_Address_Country__c = 'COUNTRY1' ,Region__c='APJ',Competitor_Lost_To__c='BMC',Partner_Opportunity_Stage__c='Propose - 60%');
        //insert testOppty;
        listOpp.add(testOppty);
        insert listOpp;
        
        listTestProd = New List<Product2>();
        Product2 testProd1 = New Product2(Name ='Test Product', Product_ID__c='prod id1', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10,Source__c='Compal', Pallet_Quantity__c=6);
        listTestProd.add(testProd1);
        
        Product2 testProd2 = New Product2(Name ='Test Product', Product_ID__c='prod id2', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=20,Source__c='Compal', Pallet_Quantity__c=12);
        listTestProd.add(testProd2);
        
        Product2 testProd3 = New Product2(Name ='Test Product', Product_ID__c='prod id3', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2,EMEA__c=10, Container_Volume__c=30,Source__c='Compal', Pallet_Quantity__c=18);
        listTestProd.add(testProd3);
        
        insert listTestProd;      
        
        PriceBook2 standardPB = [SELECT Id FROM PriceBook2 WHERE IsStandard = TRUE];
        
        PriceBook2 testPB = New PriceBook2(Name ='Test PriceBook');
        insert testPB;
        
        PriceBookEntry pbes1 = New PriceBookEntry(PriceBook2Id = standardPB.Id, Product2Id = testProd1.Id, IsActive = True, UnitPrice = 8, UseStandardPrice = False);
        PriceBookEntry pbes2 = New PriceBookEntry(PriceBook2Id = standardPB.Id, Product2Id = testProd2.Id, IsActive = True, UnitPrice = 8, UseStandardPrice = False);
        PriceBookEntry pbes3 = New PriceBookEntry(PriceBook2Id = standardPB.Id, Product2Id = testProd3.Id, IsActive = True, UnitPrice = 8, UseStandardPrice = False);
        
        pbe1 = New PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd1.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);     
        pbe2 = New PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd2.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = true);
        pbe3 = New PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd3.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = true);
        
        List<PriceBookEntry> listPbe = New List<PriceBookEntry>();
        listPbe.add(pbes1);
        listPbe.add(pbes2);
        listPbe.add(pbes3);
        listPbe.add(pbe1);
        listPbe.add(pbe2);
        listPbe.add(pbe3);
        insert listPbe;
        
        listOli = New List<OpportunityLineItem>();
        For (Integer intI= 1; intI <= 5; intI++) {
            listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId=testOppty.Id, quantity=80, unitPrice=80, Mrgn__c = 1));
            listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe2.Id, OpportunityId=testOppty.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
            listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe3.Id, OpportunityId=testOppty.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
            listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId=testOppty3.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
            listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe2.Id, OpportunityId=testOppty3.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
            listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe3.Id, OpportunityId=testOppty3.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
            
        }
        
        insert listOli;
        
    }
    */
    
    Private Static void setupTestData1() {  
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User usr = New User(LastName = 'User',
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
        
        system.runAs(usr){
            System_Behavior_Bypasser__c  sc = New System_Behavior_Bypasser__c();
        sc.Bypass_Opportunity_VRs__c = true;
        sc.SetupOwnerId = usr.profileId;
        insert Sc;
            
            testSalesChannelGrp = New Sales_Channel_Group__c(Name='TestChannelGroup1', Region_Name__c='REGION1', Segment_Business_Unit_Name__c='LARGE ENTERPRISE');
            
            insert testSalesChannelGrp;
            
            testAccount = New Account(Name='TestAccount', Sales_Channel__c=testSalesChannelGrp.Id);
            insert testAccount;
            
            testOceanData = New Ocean_Data__c(Days_in_country_Delivery__c=70,On_the_sea_by_ODM__c=70,
                                              CFI_Delivery_Time_in_Weeks__c=10, CFS_Delivery_Time_in_Weeks__c=10,
                                              Exception_Country__c='ABC',    //Lead_Time_in_Weeks__c=10,
                                              MSP_Incremental_in_Weeks__c=10, Region__c='ABC',
                                              Ship_Rate__c=4, Source__c='Compal', Pallet_Rate__c=2);
            
            // 3.0
            Ocean_Data__c testOceanData2 = New Ocean_Data__c(Days_in_country_Delivery__c = 70, On_the_sea_by_ODM__c = 70,
                                                             CFI_Delivery_Time_in_Weeks__c = 10, CFS_Delivery_Time_in_Weeks__c = 10,
                                                             Exception_Country__c ='COUNTRY1',    //Lead_Time_in_Weeks__c=10,
                                                             MSP_Incremental_in_Weeks__c = 10, Region__c ='REGION1',
                                                             Ship_Rate__c = 4, Source__c ='Compal', Pallet_Rate__c=2);
            
            listOceanData.add(testOceanData);
            listOceanData.add(testOceanData2);
            insert listOceanData;
            
            //insert testOceanData; // 3.0
            
            testLOTRegion = New LOT_Region__c(Name='COUNTRY1', Region__c='REGION1', Threshold_Region__c='EMEA');
            LOT_Region__c testLOTRegion2 = New LOT_Region__c(Name ='ABC', Region__c='ABC', Threshold_Region__c='EMEA'); // 3.0
            listLOTRegion.add(testLOTRegion);
            listLOTRegion.add(testLOTRegion2);
            insert listLOTRegion;
            
            //insert testLOTRegion; // 3.0
            
            testLOTOceanEmail = New LOT_OCEAN_EMAIL__c(Country__c=testLOTRegion.Id, Country_LE__c='test@testmail.com', region__c='REGION1');
            
            insert testLOTOceanEmail;
            
            List<Opportunity> listOpp = New List<Opportunity>();
            testOppty3 = New Opportunity(RecordTypeId='012300000004zf2', Quote_Numbers__c = '123456', Customer_Requested_Delivery_Date__c=system.today() + 60, StageName='Qualify - 30%', Probability=30, AccountId=testAccount.Id, Name='TEST Oppty 3', CloseDate = System.today() + 30, Primary_Product_Delivery_Address_Region__c = 'REGION1', Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',Region__c='APJ',Competitor_Lost_To__c='Unknown',Partner_Opportunity_Stage__c='Qualify - 30%');
            //insert testOppty3;
            listOpp.add(testOppty3);
            
            testOppty = New Opportunity(RecordTypeId='012300000004zf2AAA', Primary_Competitor__c='Unknown', Quote_Numbers__c = '123456', Customer_Requested_Delivery_Date__c=system.today() + 60, StageName='Plan - 1%', Probability=60, AccountId=testAccount.Id, Name='TEST Oppty 1', CloseDate = System.today() + 30, Primary_Product_Delivery_Address_Region__c = 'REGION1', Primary_Product_Delivery_Address_Country__c = 'COUNTRY1' ,Region__c='APJ',Competitor_Lost_To__c='BMC',Partner_Opportunity_Stage__c='Propose - 60%');
            //insert testOppty;
            listOpp.add(testOppty);
            TriggerExecutionController.setSkipAllTriggers(true);
            insert listOpp;
            
            listTestProd = New List<Product2>();
            Product2 testProd1 = New Product2(Name ='Test Product', Product_ID__c='prod id1', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10, Source__c='Compal', Pallet_Quantity__c=6);
            listTestProd.add(testProd1);
            
            Product2 testProd2 = New Product2(Name ='Test Product', Product_ID__c='prod id2', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10, Source__c='Compal');
            listTestProd.add(testProd2);
            
            Product2 testProd3 = New Product2(Name ='Test Product', Product_ID__c='prod id3', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2,EMEA__c=10, Container_Volume__c=30,Source__c='Compal', Pallet_Quantity__c=18);
            listTestProd.add(testProd3);
            
            insert listTestProd;      
            

            
             Pricebook2 standardPB = New Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = True
        );
            
            PriceBook2 testPB = New PriceBook2(Name ='Test PriceBook');
            insert testPB;
            
            PriceBookEntry pbes1 = New PriceBookEntry(PriceBook2Id = standardPB.Id, Product2Id = testProd1.Id, IsActive = True, UnitPrice = 8, UseStandardPrice = False);
            PriceBookEntry pbes2 = New PriceBookEntry(PriceBook2Id = standardPB.Id, Product2Id = testProd2.Id, IsActive = True, UnitPrice = 8, UseStandardPrice = False);
            PriceBookEntry pbes3 = New PriceBookEntry(PriceBook2Id = standardPB.Id, Product2Id = testProd3.Id, IsActive = True, UnitPrice = 8, UseStandardPrice = False);
            
            pbe1 = New PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd1.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);     
            pbe2 = New PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd2.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = true);
            pbe3 = New PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd3.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = true);
            
            List<PriceBookEntry> listPbe = New List<PriceBookEntry>();
            listPbe.add(pbes1);
            listPbe.add(pbes2);
            listPbe.add(pbes3);
            listPbe.add(pbe1);
            listPbe.add(pbe2);
            listPbe.add(pbe3);
            insert listPbe;
            
            listOli = New List<OpportunityLineItem>();
            For (Integer intI= 1; intI <= 5; intI++) {
                listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId=testOppty.Id, quantity=80, unitPrice=80, Mrgn__c = 1,Supportability_Status__c = 'test'));
                listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe2.Id, OpportunityId=testOppty.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
                listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe3.Id, OpportunityId=testOppty.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
                listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId=testOppty3.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
                listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe2.Id, OpportunityId=testOppty3.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
                listOli.add(New OpportunityLineItem(PriceBookEntryId = pbe3.Id, OpportunityId=testOppty3.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
                
            }
            
            insert listOli;
			TriggerExecutionController.setSkipAllTriggers(false);
        }
    }
    
    Static testmethod void testUpdateLOTIndicator() {
        
        setupTestData1();
        
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
        
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
        
        List<Opportunity> listOpp = New List<Opportunity>();
        List<LOT_Region__c> listLOTRegions = New List<LOT_Region__c>();
        List<Product2> listProduct = New List<Product2>();
        //List<PriceBook2> listPriceBook = New List<Pricebook2>();
        List<PriceBookEntry> listBookEntry = New List<PriceBookEntry>();
        List<OpportunityLineItem> listOLI = New List<OpportunityLineItem>();
        
        Pricebook2 standardPB = New Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = True
        );
        String[] listArrayRegion = New String[]{'AMER','APJ ASIA','APJ China','APJ India','APJ HONG KONG, JAPAN & KOREA','Brazil','EMEA','FED','LATAM'};
            
            For (Integer intI = 0; intI < 9; intI++){
                listOpp.add(New Opportunity(RecordTypeId='012300000004zf2AAA', Quote_Numbers__c = '123456', Customer_Requested_Delivery_Date__c=system.today() + 60, 
                                            StageName='Propose - 60%', Probability=60, AccountId=testAccount.Id, Name='TEST Oppty'+intI, CloseDate = System.today() + 30, 
                                            Primary_Product_Delivery_Address_Region__c = 'REGION'+intI, Primary_Product_Delivery_Address_Country__c = 'COUNTRY'+intI ,
                                            Region__c=listArrayRegion[intI],Competitor_Lost_To__c='Unknown'));
                
                listLOTRegions.add(New LOT_Region__c(Name='COUNTRY'+intI, Region__c='REGION'+intI, Threshold_Region__c=listArrayRegion[intI]));
                
                listProduct.add(New Product2(Name='Test Product', Product_ID__c='test prod id4'+intI, Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, APJ_ASIA__c=10, AMER__c=10, APJ_China__c=10, 
                                             APJ_ICC__c=10, APJ_HK_JPN_KOR__c=10, Brazil__c=10, FED__c=10, LATAM__c=10, 
                                             Container_Volume__c=10, Source__c='Compal', Pallet_Quantity__c=6));
                
                //listPriceBook.add(New PriceBook2(Name='Test PriceBook'+i));
                
            }
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listOpp;
        
        system.assertEquals(1, [select count() from Opportunity where Id =:listOpp[0].Id]);        
        insert listLOTRegions;
        insert listProduct;
        
        //insert listPriceBook;
        
        For (Integer intJ = 0; intJ < listProduct.size(); intJ++){
            listBookEntry.add(New PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = listProduct[intJ].Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE));
        }
        insert listBookEntry;
        
        For (Integer intK = 0; intK < listBookEntry.size(); intK++){
            listOLI.add(New OpportunityLineItem(PriceBookEntryId = listBookEntry[intK].Id, OpportunityId=listOpp[intK].Id, quantity=80, unitPrice=80, Mrgn__c = 1));    
        }
        insert listOLI;
        
        Map<Id, Opportunity> mapOpp = New map<Id, Opportunity>([select Id,recordtypeid,Source_System__c,type, Primary_Product_Delivery_Address_Country__c,Primary_Product_Delivery_Address_Region__c,
                                                                Regional_Parent_Name__c, Sales_Channel_Region__c,Pricebook2Id,Name,StageName, AccountId, Account.Account_ID__c, 
                                                                CreatedBy.Profile.Name, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Contact.Email, 
                                                                Owner.Contact.AccountId, Owner.Contact.Phone, Owner.Contact.Account.Partner_Relationship__c, 
                                                                Owner.Profile.Name,Distributor_Reseller_Name__c,Distributor_Name__c, 
                                                                Distributor_Reseller_Name__r.Partner_Relationship__c,Distributor_Reseller_Name__r.Dell_Certification_Areas__c,
                                                                (select Id, OpportunityId,PricebookEntryId,Quantity,Ocean_Indicator__c,LOT_Indicator__c, Active_Wyse_Product__c, 
                                                                 Product_Line_Desc__c, Description from OpportunityLineItems)
                                                                from Opportunity where Id In :Utility.getIds(listOpp)]);
        
        map<id, opportunitylineitem> mapOldLineItems = New map<id, opportunitylineitem>(listOLI);
        
        OpportunityLineItemUtilities.updateLOTIndicator(TriggerHandler.TriggerEvent.ISUPDATE, mapOpp);
        OpportunityLineItemUtilities.updateSupportabilityIndicator(TriggerHandler.TriggerEvent.ISUPDATE, listOLI,   mapOldLineItems);
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();
        //TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    
    Static testmethod void testSuccessCase() {
        System.debug('###DEBUG FROM TEST### START testSuccessCase');
        
        //Test.startTest(); //2.0
        //TriggerExecutionController.setSkipAllTriggers(true);
        setupTestData1();
        System.debug('###DEBUG FROM TEST### testSuccessCase --2 ');
        Test.startTest(); //2.0
        testOppty.Recalculate_LOT_OCEAN__c = true;
        testOppty.CloseDate = System.today() + 30;
        testOppty.Customer_Requested_Delivery_Date__c = System.today() + 40;
        testOppty.Quote_Numbers__c = '1234567';
        testOppty.Primary_Product_Delivery_Address_Country__c = 'COUNTRY1';
        testOppty.Primary_Product_Delivery_Address_Region__c = 'REGION1';
        testOppty.Is_CFI_included__c = 'Yes';       
        testOppty.Additional_vol_to_team_Quarterly__c = 'Yes';
        testOppty.Direct_Trailer_Opportunity__c = 'Yes';
        testOppty.How_many_shipments__c = 1;
        testOppty.StageName='Propose - 60%';
        testOppty.Partner_Opportunity_Stage__c = 'Propose - 60%';
        
        
        //TriggerExecutionController.setSkipAccountTriggers(true); // 3.0
        //TriggerExecutionController.setSkipOpportunityTriggers(true); // 3.0
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true); // 3.0
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
        TriggerExecutionController.setSkipAllTriggers(true);
        update testOppty;
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();
        
        List<Opportunity> listOpptyResult = [SELECT Id, Name, Probability, Primary_Product_Delivery_Address_Country__c,
                                             Primary_Product_Delivery_Address_Region__c,  
                                             Account.Sales_Channel__r.Region_Name__c,StageName,Partner_Opportunity_Stage__c,
                                             Account.Sales_Channel__r.Segment_Business_Unit_Name__c,
                                             Account.Sales_Channel__r.Segment_Desc__c ,LOT_Large_Opportunity__c,
                                             LOT_Large_Opportunity_Potential__c,Calculated_Delivery_in_Weeks__c,
                                             Eligible_for_Ocean__c, Potential_Cost_Savings_If_Ocean__c,LOT_OCEAN_Email_Notification__c,
                                             Customer_Requested_Delivery_Date__c,
                                             CloseDate, Ocean_Opportunity_Notification_Pop_Up__c, Confirmed_for_Ocean_by_Finance_Gbl_Ops__c,
                                             Additional_vol_to_team_Quarterly__c,Is_CFI_included__c
                                             FROM Opportunity
                                             WHERE Id = : testOppty.Id];
        //  System.assert(listOpptyResult[0].LOT_Large_Opportunity__c);
        System.assert(!listOpptyResult[0].LOT_Large_Opportunity_Potential__c);
        //System.assert(listOpptyResult[0].Eligible_for_Ocean__c == 'Yes');
        // System.assert(opptyResult[0].LOT_OCEAN_Email_Notification__c != null);
        //System.assertEquals(50, opptyResult[0].Calculated_Delivery_in_Weeks__c);
        
        List<Opportunity> listOpptyResult2 = [SELECT Id, Name, Probability, Primary_Product_Delivery_Address_Country__c,
                                              Primary_Product_Delivery_Address_Region__c,  
                                              Account.Sales_Channel__r.Region_Name__c, 
                                              Account.Sales_Channel__r.Segment_Business_Unit_Name__c,
                                              Account.Sales_Channel__r.Segment_Desc__c ,LOT_Large_Opportunity__c,
                                              LOT_Large_Opportunity_Potential__c,Calculated_Delivery_in_Weeks__c,
                                              Eligible_for_Ocean__c, Potential_Cost_Savings_If_Ocean__c,LOT_OCEAN_Email_Notification__c,
                                              Customer_Requested_Delivery_Date__c,
                                              CloseDate, Ocean_Opportunity_Notification_Pop_Up__c, Confirmed_for_Ocean_by_Finance_Gbl_Ops__c,
                                              Additional_vol_to_team_Quarterly__c,Is_CFI_included__c
                                              FROM Opportunity
                                              WHERE Id = : testOppty3.Id];
        
        System.assert(!listOpptyResult2[0].LOT_Large_Opportunity__c);
        
        //TriggerExecutionController.setSkipAccountTriggers(false); // 3.0
        //TriggerExecutionController.setSkipOpportunityTriggers(false); // 3.0
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false); // 3.0
        
    }
    
    Static testmethod void testCountryAndRegionNotSetupCase() {
        System.debug('###DEBUG FROM TEST### START testNonCountryAndRegionCase');
        //TriggerExecutionController.setSkipAccountTriggers(true);
        //Test.startTest(); //2.0
        setupTestData1();
        Test.startTest(); //2.0
        testOppty.Recalculate_LOT_OCEAN__c = true;
        testOppty.CloseDate = System.today() + 30;
        testOppty.Quote_Numbers__c = '1234567';
        testOppty.Primary_Product_Delivery_Address_Country__c = 'ABC';
        testOppty.Primary_Product_Delivery_Address_Region__c = 'Other';
        testOppty.Is_CFI_included__c = 'Yes';
        testOppty.Additional_vol_to_team_Quarterly__c = 'Yes';
        testOppty.StageName='Propose - 60%';
        testOppty.Partner_Opportunity_Stage__c ='Propose - 60%';
        
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
        //TriggerExecutionController.setSkipAccountTriggers(true); // 3.0
        //TriggerExecutionController.setSkipOpportunityTriggers(true); // 3.0
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true); // 3.0
        TriggerExecutionController.setSkipAllTriggers(true);
        update testOppty;
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();
        //TriggerExecutionController.setSkipAccountTriggers(false);
        
        List<Opportunity> listOpptyResult = [SELECT Id, Name, Probability, Primary_Product_Delivery_Address_Country__c,
                                             Primary_Product_Delivery_Address_Region__c,  
                                             Account.Sales_Channel__r.Region_Name__c,Partner_Opportunity_Stage__c,StageName,
                                             Account.Sales_Channel__r.Segment_Business_Unit_Name__c,
                                             Account.Sales_Channel__r.Segment_Desc__c ,LOT_Large_Opportunity__c,
                                             LOT_Large_Opportunity_Potential__c,Calculated_Delivery_in_Weeks__c,
                                             Eligible_for_Ocean__c, Potential_Cost_Savings_If_Ocean__c,LOT_OCEAN_Email_Notification__c,
                                             Customer_Requested_Delivery_Date__c,LOT_Mandatory_Fields__c,
                                             CloseDate, Ocean_Opportunity_Notification_Pop_Up__c, Confirmed_for_Ocean_by_Finance_Gbl_Ops__c,
                                             Additional_vol_to_team_Quarterly__c,Is_CFI_included__c
                                             FROM Opportunity
                                             WHERE Id = : testOppty.Id];
        system.debug('###DEBUG### listOpptyResult = ' + listOpptyResult);   
        System.assert(!listOpptyResult[0].LOT_Large_Opportunity__c);
        System.assert(!listOpptyResult[0].LOT_Large_Opportunity_Potential__c);
        //System.assertEquals(null, listOpptyResult[0].Calculated_Delivery_in_Weeks__c);
        
        //TriggerExecutionController.setSkipAccountTriggers(false); // 3.0
        //TriggerExecutionController.setSkipOpportunityTriggers(false); // 3.0
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false); // 3.0
        System.debug('###DEBUG FROM TEST### END testNonCountryAndRegionCase');
    }
    
    Static testmethod void testUpdateOpptyLineItemCase() {
        System.debug('###DEBUG FROM TEST### START testUpdateOpptyLineItemCase');
        //Test.startTest(); //2.0
        setupTestData1();
        Test.startTest(); //2.0
        for(OpportunityLineItem oli : listOli) {
            oli.Quantity = 1;
        }
        
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
        //TriggerExecutionController.setSkipAccountTriggers(true); // 3.0
        // TriggerExecutionController.setSkipOpportunityTriggers(true); // 3.0
        TriggerExecutionController.setSkipAllTriggers(true);
        update listOli;
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
        List<Opportunity> listOpptyResult = [SELECT Id, Name, Probability, Primary_Product_Delivery_Address_Country__c,
                                             Primary_Product_Delivery_Address_Region__c,  
                                             Account.Sales_Channel__r.Region_Name__c,Partner_Opportunity_Stage__c,StageName, 
                                             Account.Sales_Channel__r.Segment_Business_Unit_Name__c,
                                             Account.Sales_Channel__r.Segment_Desc__c ,LOT_Large_Opportunity__c,
                                             LOT_Large_Opportunity_Potential__c,Calculated_Delivery_in_Weeks__c,
                                             Eligible_for_Ocean__c, Potential_Cost_Savings_If_Ocean__c,LOT_OCEAN_Email_Notification__c,
                                             Customer_Requested_Delivery_Date__c,
                                             CloseDate, Ocean_Opportunity_Notification_Pop_Up__c, Confirmed_for_Ocean_by_Finance_Gbl_Ops__c,
                                             Additional_vol_to_team_Quarterly__c,Is_CFI_included__c
                                             FROM Opportunity
                                             WHERE Id = :testOppty.Id];
        system.assertEquals(null, listOpptyResult[0].Potential_Cost_Savings_If_Ocean__c );
        system.assert(!listOpptyResult[0].LOT_Large_Opportunity_Potential__c);
        
        //TriggerExecutionController.setSkipAccountTriggers(false); // 3.0
        //TriggerExecutionController.setSkipOpportunityTriggers(false); // 3.0
        System.debug('###DEBUG FROM TEST### END testUpdateOpptyLineItemCase');
    }
    
    static testmethod void testDeleteOpptyLineItemCase() {
        System.debug('###DEBUG FROM TEST### START testDeleteOpptyLineItemCase');
        //Test.startTest(); //2.0        
        setupTestData1();
        Test.startTest(); //2.0
        //TriggerExecutionController.setSkipAccountTriggers(true); // 3.0
        //TriggerExecutionController.setSkipOpportunityTriggers(true); // 3.0
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
        TriggerExecutionController.setSkipAllTriggers(true);
        delete listOli;
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();
        
        List<Opportunity> listOpptyResult = [SELECT Id, Name, Probability, Primary_Product_Delivery_Address_Country__c,
                                             Primary_Product_Delivery_Address_Region__c,  
                                             Account.Sales_Channel__r.Region_Name__c,Partner_Opportunity_Stage__c,StageName,  
                                             Account.Sales_Channel__r.Segment_Business_Unit_Name__c,
                                             Account.Sales_Channel__r.Segment_Desc__c ,LOT_Large_Opportunity__c,
                                             LOT_Large_Opportunity_Potential__c,Calculated_Delivery_in_Weeks__c,
                                             Eligible_for_Ocean__c, Potential_Cost_Savings_If_Ocean__c,LOT_OCEAN_Email_Notification__c,
                                             Customer_Requested_Delivery_Date__c,
                                             CloseDate, Ocean_Opportunity_Notification_Pop_Up__c, Confirmed_for_Ocean_by_Finance_Gbl_Ops__c,
                                             Additional_vol_to_team_Quarterly__c,Is_CFI_included__c
                                             FROM Opportunity
                                             WHERE Id = :testOppty.Id];
        
        system.assertEquals(null, listOpptyResult[0].Potential_Cost_Savings_If_Ocean__c );
        system.assert(!listOpptyResult[0].LOT_Large_Opportunity_Potential__c);
        
        //TriggerExecutionController.setSkipAccountTriggers(false); // 3.0
        //TriggerExecutionController.setSkipOpportunityTriggers(false); // 3.0
        System.debug('###DEBUG FROM TEST### END testDeleteOpptyLineItemCase');
    }
}