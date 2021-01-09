/*
Author: Prateek Gupta

History:
Version  Date          Release No       Modified By     CR Number     Description
--------------------------------------------------------------------------------------
1.0      16-Jul-2015                    Prateek Gupta                 Test class for LOTOCEANUtils class
1.1      03-Aug-2015                    Azwanti Zuber                 Add test to increase code coverage for LotOcean
1.2      30-Nov-2015                    Noraiman Afiq                 Comment removed method from main class
2.0      22-May-2018   FY19-DCS-0703    Venkat Sharan   CR15845       Added test methods - testGetters, testLOTOppty2 to increase the LOTOcean code coverage.
         12-Dec-2018   FY20O2O2         Hari A                       STORY 5907651 Removed reference for the field total_aggregated_volume__c
*/


@isTest
public class LOTOCEANUtils_Test
{

    //Making list for Skip VRs
    static List<String> lstObjAPINames = new List<String>{'Opportunity'};
    //Added custom settings to populate StageName values.
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
    }
    
    public static testMethod void TestMethod_1()
    {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        // Fenny [5-Sep-2016] - Fix 0902 test failure
        Enable_Codes_Settings__c emcCode = new Enable_Codes_Settings__c(Name='EMC Codes', Enable__c=true);
        insert emcCode;
        
        Opportunity objOpp, objOpp3, objOpp2;
        List<Product2> lstProd;
        PriceBookEntry pbe1;
        PriceBookEntry pbe2;
        PriceBookEntry pbe3;
        List<OpportunityLineItem> oliList;
        
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        Sales_Channel_Group__c objSalesChannelGrp;
        Account objAccount;

        objSalesChannelGrp = new Sales_Channel_Group__c();
        objSalesChannelGrp.Name = 'TestChannelGroup1';
        objSalesChannelGrp.Region_Name__c = 'REGION1';
        objSalesChannelGrp.Regional_Parent_Name__c ='AMER';
        objSalesChannelGrp.Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE';        
        insert objSalesChannelGrp;
        
        objAccount = new Account();
        objAccount.Name = 'TestAccount';
        objAccount.Sales_Channel__c = objSalesChannelGrp.Id;
        insert objAccount;
        
        objOceanData = new Ocean_Data__c();
        objOceanData.Days_in_country_Delivery__c = 70;
        objOceanData.On_the_sea_by_ODM__c = 70;
        objOceanData.CFI_Delivery_Time_in_Weeks__c = 10;
        objOceanData.CFS_Delivery_Time_in_Weeks__c=10;
        objOceanData.Exception_Country__c = 'COUNTRY1';
        objOceanData.MSP_Incremental_in_Weeks__c = 10;
        objOceanData.Region__c = 'REGION1';
        objOceanData.Ship_Rate__c = 4;
        objOceanData.Source__c = 'Compal';
        objOceanData.Pallet_Rate__c = 2;        
        insert objOceanData;
        
        objLOTRegion = new LOT_Region__c();
        objLOTRegion.Name = 'COUNTRY1';
        objLOTRegion.Region__c = 'REGION1';
        objLOTRegion.Threshold_Region__c = 'EMEA';        
        insert objLOTRegion;
            
        objLOTOceanEmail = new LOT_OCEAN_EMAIL__c();
        objLOTOceanEmail.Country__c = objLOTRegion.Id;
        objLOTOceanEmail.Country_LE__c = 'test@testmail.com';
        objLOTOceanEmail.region__c = 'REGION1';            
        insert objLOTOceanEmail;
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        
        objOpp = new Opportunity();
        objOpp.RecordTypeId = '012300000004zf2';
        objOpp.Quote_Numbers__c = '123456';
        objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
        objOpp.StageName= 'Propose - 60%';
        objOpp.Probability = 60;
        objOpp.AccountId = objAccount.Id;
        objOpp.Name = 'TEST Oppty 1';
        objOpp.CloseDate = System.today() + 30;
        objOpp.Primary_Product_Delivery_Address_Region__c = 'REGION1';
        objOpp.Primary_Product_Delivery_Address_Country__c = 'COUNTRY1';
        objOpp.Region__c = 'APJ';
        objOpp.Competitor_Lost_To__c = 'Unknown';
        lstOpp.add(objOpp);
        
        insert lstOpp;
        
        lstProd = new List<Product2>();
        Product2 objProd1 = new Product2(Product_ID__c = '1234',Name='Test Product', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10,Source__c='Compal', Pallet_Quantity__c=6);
        lstProd.add(objProd1);
        
        Product2 objProd2 = new Product2(Product_ID__c = '1235',Name='Test Product', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=20,Source__c='Compal', Pallet_Quantity__c=12);
        lstProd.add(objProd2);
    
        Product2 objProd3 = new Product2(Product_ID__c = '1236',Name='Test Product', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2,EMEA__c=10, Container_Volume__c=30,Source__c=null, Pallet_Quantity__c=18);
        lstProd.add(objProd3);
        
        insert lstProd;                
        
        String standardPBId = Test.getStandardPricebookId();
        
        PriceBook2 objCustomPB = new PriceBook2(Name='Test PriceBook');
        insert objCustomPB;
        
        PriceBookEntry pbes1 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd1.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        PriceBookEntry pbes2 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd2.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        PriceBookEntry pbes3 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd3.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        
        pbe1 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd1.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);     
        pbe2 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd2.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);
        pbe3 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd3.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        pbeList.add(pbes1);
        pbeList.add(pbes2);
        pbeList.add(pbes3);
        pbeList.add(pbe1);
        pbeList.add(pbe2);
        pbeList.add(pbe3);
        
        insert pbeList;
            
        oliList = new List<OpportunityLineItem>();
        for(integer i=1; i <= 5; i++)
        {
            oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1));
            oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe2.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
            oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe3.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));        
        }
        //TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        //////TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        Test.startTest();
        insert oliList;
        Test.stopTest();
        
        LOTOCEANUtils.getIntegrationProfiles();
        LOTOCEANUtils.getprofileIdToSkipLOTOcean();
        // 1.2 Start LOTOCEANUtils.setRMCountryMappingMap();
        LOTOCEANUtils.setupCountryToRegionMap();
        
        Map<Id, Opportunity> mapOppIdToOpp = new Map<Id, Opportunity>();
        for(Opportunity opp : lstOpp)
        {
            mapOppIdToOpp.put(opp.Id, opp);
        }
        LOTOCEANUtils objLOU = new LOTOCEANUtils(mapOppIdToOpp);
        
        objLOU.processLOTQualifiedOppty();
        objLOU.processOCEANQualifiedOppty();
        objLOU.getNotificationTargetEmail(objSalesChannelGrp.Segment_Business_Unit_Name__c.toUpperCase(), StringUtils.defaultString(objOpp.Primary_Product_Delivery_Address_Country__c).toUpperCase(), StringUtils.defaultString(objOpp.Primary_Product_Delivery_Address_Region__c).toUpperCase());
        objLOU.getNotificationTargetEmail(objSalesChannelGrp.Segment_Business_Unit_Name__c.toUpperCase(), 'COUNTRY2', StringUtils.defaultString(objOpp.Primary_Product_Delivery_Address_Region__c).toUpperCase());
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        //////TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        /////TriggerExecutionController.setSkipOpportunityTriggers(false);
    }
    
    public static testMethod void TestMethod_2()
    {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        // Fenny [5-Sep-2016] - Fix 0902 test failure
        Enable_Codes_Settings__c emcCode = new Enable_Codes_Settings__c(Name='EMC Codes', Enable__c=true);
        insert emcCode;
        
        Opportunity objOpp, objOpp3, objOpp2;
        List<Product2> lstProd;
        PriceBookEntry pbe1;
        PriceBookEntry pbe2;
        PriceBookEntry pbe3;
        List<OpportunityLineItem> oliList;
        
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        Sales_Channel_Group__c objSalesChannelGrp;
        Account objAccount;

        objSalesChannelGrp = new Sales_Channel_Group__c();
        objSalesChannelGrp.Name = 'TestChannelGroup1';
        objSalesChannelGrp.Region_Name__c = 'REGION1';
        objSalesChannelGrp.Regional_Parent_Name__c ='APJ CHINA';
        objSalesChannelGrp.Segment_Business_Unit_Name__c = null;        
        insert objSalesChannelGrp;
        
        objAccount = new Account();
        objAccount.Name = 'TestAccount';
        objAccount.Sales_Channel__c = objSalesChannelGrp.Id;
        insert objAccount;
        
        objOceanData = new Ocean_Data__c();
        objOceanData.Days_in_country_Delivery__c = 70;
        objOceanData.On_the_sea_by_ODM__c = 70;
        objOceanData.CFI_Delivery_Time_in_Weeks__c = 10;
        objOceanData.CFS_Delivery_Time_in_Weeks__c=10;
        objOceanData.Exception_Country__c = 'COUNTRY1';
        objOceanData.MSP_Incremental_in_Weeks__c = 10;
        objOceanData.Region__c = 'REGION1';
        objOceanData.Ship_Rate__c = 4;
        objOceanData.Source__c = 'Compal';
        objOceanData.Pallet_Rate__c = 2;        
        insert objOceanData;
        
        objLOTRegion = new LOT_Region__c();
        objLOTRegion.Name = 'COUNTRY1';
        objLOTRegion.Region__c = 'REGION1';
        objLOTRegion.Threshold_Region__c = 'EMEA';        
        insert objLOTRegion;
            
        objLOTOceanEmail = new LOT_OCEAN_EMAIL__c();
        objLOTOceanEmail.Country__c = objLOTRegion.Id;
        objLOTOceanEmail.Country_LE__c = 'test@testmail.com';
        objLOTOceanEmail.region__c = 'REGION1';            
        insert objLOTOceanEmail;

        List<Opportunity> lstOpp = new List<Opportunity>();
        
        objOpp = new Opportunity();
        objOpp.RecordTypeId = '012300000004zf2';
        objOpp.Quote_Numbers__c = '123456';
        objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
        objOpp.StageName = 'Propose - 60%';
        objOpp.Probability = 60;
        objOpp.AccountId = objAccount.Id;
        objOpp.Name = 'TEST Oppty 1';
        objOpp.CloseDate = System.today() + 30;
        objOpp.Primary_Product_Delivery_Address_Region__c = 'REGION1';
        objOpp.Primary_Product_Delivery_Address_Country__c = 'COUNTRY1';
        objOpp.Region__c = 'APJ';
        objOpp.Competitor_Lost_To__c = 'Unknown';
        lstOpp.add(objOpp);
        
        insert lstOpp;
        
        lstProd = new List<Product2>();
        Product2 objProd1 = new Product2(Product_ID__c = '2535',Name='Test Product', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10,Source__c='Compal', Pallet_Quantity__c=6);
        lstProd.add(objProd1);
        
        Product2 objProd2 = new Product2(Product_ID__c = '2536',Name='Test Product', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=20,Source__c='Compal', Pallet_Quantity__c=12);
        lstProd.add(objProd2);
    
        Product2 objProd3 = new Product2(Product_ID__c = '2537',Name='Test Product', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2,EMEA__c=10, Container_Volume__c=30,Source__c=null, Pallet_Quantity__c=18);
        lstProd.add(objProd3);
        
        insert lstProd;                
        
        String standardPBId = Test.getStandardPricebookId();
        
        PriceBook2 objCustomPB = new PriceBook2(Name='Test PriceBook');
        insert objCustomPB;
        
        PriceBookEntry pbes1 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd1.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        PriceBookEntry pbes2 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd2.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        PriceBookEntry pbes3 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd3.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        
        pbe1 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd1.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);     
        pbe2 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd2.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);
        pbe3 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd3.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        pbeList.add(pbes1);
        pbeList.add(pbes2);
        pbeList.add(pbes3);
        pbeList.add(pbe1);
        pbeList.add(pbe2);
        pbeList.add(pbe3);
        
        insert pbeList;
            
        oliList = new List<OpportunityLineItem>();
        for(integer i=1; i <= 5; i++)
        {
            oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1));
            oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe2.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
            oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe3.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
        }
        //TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        //////TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();
        insert oliList;
        Test.stopTest();
        
        LOTOCEANUtils.getIntegrationProfiles();
        LOTOCEANUtils.getprofileIdToSkipLOTOcean();
        // 1.2 Start LOTOCEANUtils.setRMCountryMappingMap();
        LOTOCEANUtils.setupCountryToRegionMap();
        
        Map<Id, Opportunity> mapOppIdToOpp = new Map<Id, Opportunity>();
        for(Opportunity opp : lstOpp)
        {
            mapOppIdToOpp.put(opp.Id, opp);
        }
        LOTOCEANUtils objLOU = new LOTOCEANUtils(mapOppIdToOpp);
        objLOU.processLOTQualifiedOppty();
        objLOU.processOCEANQualifiedOppty();
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
    }
    
    public static testMethod void testLOTOceanForChannel(){
    
        System_Behavior_Bypasser__c vr  = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        
        Opportunity objOpp, objOpp3, objOpp2;
        List<Product2> lstProd;
        PriceBookEntry pbe1,pbe2,pbe3;
        List<OpportunityLineItem> oliList;
        
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        Sales_Channel_Group__c objSalesChannelGrp;
        Account objAccount;
        
        objSalesChannelGrp = new Sales_Channel_Group__c(Name = 'TestChannelGroup1',Regional_Parent_Name__c ='APJ ASIA', Region_Name__c = 'APJ', Country_Name__c='MALAYSIA', Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE');
        insert objSalesChannelGrp;
        
        objAccount = new Account(Name = 'TestAccount', Sales_Channel__c = objSalesChannelGrp.Id);
        insert objAccount;
        
        objOceanData = new Ocean_Data__c(Days_in_country_Delivery__c = 70,On_the_sea_by_ODM__c = 70,CFI_Delivery_Time_in_Weeks__c = 10,CFS_Delivery_Time_in_Weeks__c=10,Exception_Country__c = 'COUNTRY1',
                                        MSP_Incremental_in_Weeks__c = 10, Region__c = 'REGION1', Ship_Rate__c = 4, Source__c = 'Compal', Pallet_Rate__c = 2);
        insert objOceanData;
        
        objLOTRegion = new LOT_Region__c(Name = 'MALAYSIA', Region__c = 'APJ', Threshold_Region__c = 'APJ ASIA');
        insert objLOTRegion;
            
        objLOTOceanEmail = new LOT_OCEAN_EMAIL__c(Country__c = objLOTRegion.Id, Country_LE__c = 'test@testmail.com', region__c = 'REGION1');
        insert objLOTOceanEmail;
        
        Test.startTest();
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        
        objOpp = new Opportunity();
        objOpp.RecordTypeId = '012300000004zf2';
        objOpp.Quote_Numbers__c = '123456';
        objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
        objOpp.StageName = 'Qualify - 30%';
        objOpp.Probability = 30;
        objOpp.AccountId = objAccount.Id;
        objOpp.Name = 'TEST Oppty 1';
        objOpp.CloseDate = System.today() + 30;
        objOpp.How_many_shipments__c = 1;
        objOpp.End_User_Mailing_Country__c = 'MALAYSIA';
        objOpp.Primary_Product_Delivery_Address_Region__c = 'APJ';
        objOpp.Primary_Product_Delivery_Address_Country__c = 'MALAYSIA';
        objOpp.Region__c = 'APJ';
        objOpp.Competitor_Lost_To__c = 'Unknown';
        lstOpp.add(objOpp);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert lstOpp;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        Product2 objProd1 = new Product2(Product_ID__c = '3234',Name='Test Product', APJ_ASIA__c=70, Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10,Source__c='Compal', Pallet_Quantity__c=6);
        insert objProd1;                
        
        String standardPBId = Test.getStandardPricebookId();
        
        PriceBook2 objCustomPB = new PriceBook2(Name='Test PriceBook');
        insert objCustomPB;
        
        PriceBookEntry pbes1 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd1.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        
        pbe1 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd1.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);     
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        pbeList.add(pbes1);
        pbeList.add(pbe1);
        insert pbeList; 
       
         
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        OpportunityLineItem insertOLI = new OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1, Quote__c='123451');
        insert insertOLI;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        
        
        Opportunity testOppty = [Select Primary_Product_Delivery_Address_Region__c, Primary_Product_Delivery_Address_Country__c, Customer_Requested_Delivery_Date__c, CloseDate,
                                StageName, Probability, Quote_Numbers__c, Is_CFI_included__c, Additional_vol_to_team_Quarterly__c, Adjustment_weeks__c, How_many_shipments__c,
                                 Direct_Trailer_Opportunity__c, Adjustment_Potential_Cost_Saving__c, Must_Arrive_By_Date__c
                                from Opportunity where Id = :objOpp.Id LIMIT 1];
        testOppty.RecordTypeId = '012300000004zf2';
        testOppty.Primary_Product_Delivery_Address_Region__c = 'NORTH AMERICA';
        testOppty.Primary_Product_Delivery_Address_Country__c = 'UNITED STATES';
        testOppty.Customer_Requested_Delivery_Date__c = system.today() + 70;
        testOppty.CloseDate = System.today() + 35;
        testOppty.StageName= 'Propose - 60%';
        testOppty.Probability = 60;
        testOppty.Quote_Numbers__c = '123451';
        testOppty.Is_CFI_included__c = 'Yes';
        testOppty.Additional_vol_to_team_Quarterly__c = 'Yes';
        testOppty.Adjustment_weeks__c = 2;
        testOppty.How_many_shipments__c = 2;
        testOppty.Direct_Trailer_Opportunity__c = 'Yes';
        testOppty.Adjustment_Potential_Cost_Saving__c = 2;
        testOppty.Must_Arrive_By_Date__c = true;
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        update testOppty;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Map<Id, Opportunity> newOppIdToOppMap = new Map<Id, Opportunity>();
        newOppIdToOppMap.put(testOppty.Id, testOppty);
        
        Map<Id, Opportunity> oldOppIdToOppMap = new Map<Id, Opportunity>();
        oldOppIdToOppMap.put(objOpp.Id, objOpp);
        
        
        LOTOcean.lotOceanCalculation(newOppIdToOppMap, oldOppIdToOppMap);
        Test.stopTest();
        
        //system.assert(testOppty.LOT_OCEAN_Field_Changes__c.contains('Changes made on'));
    }
    
    public static testMethod void testLOTOceanNoChannel(){
        Opportunity objOpp, objOpp3, objOpp2;
        List<Product2> lstProd;
        PriceBookEntry pbe1,pbe2,pbe3;
        List<OpportunityLineItem> oliList;
        
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;  
        Account objAccount;
        
        objAccount = new Account(Name = 'TestAccount');
        insert objAccount;
        
        objOceanData = new Ocean_Data__c(Days_in_country_Delivery__c = 70,On_the_sea_by_ODM__c = 70,CFI_Delivery_Time_in_Weeks__c = 10,CFS_Delivery_Time_in_Weeks__c=10,Exception_Country__c = 'COUNTRY1',
                                        MSP_Incremental_in_Weeks__c = 10, Region__c = 'REGION1', Ship_Rate__c = 4, Source__c = 'Compal', Pallet_Rate__c = 2);
        insert objOceanData;
        
        objLOTRegion = new LOT_Region__c(Name = 'COUNTRY1', Region__c = 'REGION1', Threshold_Region__c = 'EMEA');
        insert objLOTRegion;
            
        objLOTOceanEmail = new LOT_OCEAN_EMAIL__c(Country__c = objLOTRegion.Id, Country_LE__c = 'test@testmail.com', region__c = 'REGION1');
        insert objLOTOceanEmail;

        List<Opportunity> lstOpp = new List<Opportunity>();
        objOpp = new Opportunity();
        objOpp.RecordTypeId = '012300000004zf2';
        objOpp.Quote_Numbers__c = '123456';
        objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
        objOpp.StageName= 'Propose - 60%';
        objOpp.Probability = 60;
        objOpp.AccountId = objAccount.Id;
        objOpp.Name = 'TEST Oppty 1';
        objOpp.CloseDate = System.today() + 30;
        objOpp.End_User_Mailing_Country__c = 'COUNTRY1';
        objOpp.Region__c = 'APJ';
        objOpp.Competitor_Lost_To__c = 'Unknown';
        lstOpp.add(objOpp);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert lstOpp;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        Product2 objProd1 = new Product2(Product_ID__c = '4234',Name='Test Product', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10,Source__c='Compal', Pallet_Quantity__c=6);
        insert objProd1;                
        
        String standardPBId = Test.getStandardPricebookId();
        
        PriceBook2 objCustomPB = new PriceBook2(Name='Test PriceBook');
        insert objCustomPB;
        
        PriceBookEntry pbes1 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd1.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        
        pbe1 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd1.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);     
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        pbeList.add(pbes1);
        pbeList.add(pbe1);
        insert pbeList; 
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        OpportunityLineItem insertOLI = new OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1,
                                                                Quote__c = '12345', Customer_Requested_Date__c = system.today() + 60);
        
        Test.startTest();
        insert insertOLI;
        Test.stopTest();
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
     //   system.assertEquals(Object expected, Object actual);
        
    }
    
    public static testMethod void testLOTOppty(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        // Fenny [5-Sep-2016] - Fix 0902 test failure
        Enable_Codes_Settings__c emcCode = new Enable_Codes_Settings__c(Name='EMC Codes', Enable__c=true);
        insert emcCode;
        
        Opportunity objOpp, objOpp3, objOpp2;
        List<Product2> lstProd;
        PriceBookEntry pbe1,pbe2,pbe3;
        List<OpportunityLineItem> oliList;
        
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        Sales_Channel_Group__c objSalesChannelGrp;
        Account objAccount;
        
        objSalesChannelGrp = new Sales_Channel_Group__c(Name = 'TestChannelGroup1', Regional_Parent_Name__c ='EMEA',Region_Name__c = 'APJ', Country_Name__c='MALAYSIA', Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE');
        insert objSalesChannelGrp;
        
        objAccount = new Account(Name = 'TestAccount', Sales_Channel__c = objSalesChannelGrp.Id);
        insert objAccount;
        
        objOceanData = new Ocean_Data__c(Days_in_country_Delivery__c = 70,On_the_sea_by_ODM__c = 70,CFI_Delivery_Time_in_Weeks__c = 10,CFS_Delivery_Time_in_Weeks__c=10,Exception_Country__c = 'COUNTRY1',
                                        MSP_Incremental_in_Weeks__c = 10, Region__c = 'REGION1', Ship_Rate__c = 4, Source__c = 'Compal', Pallet_Rate__c = 2);
        insert objOceanData;
        
        objLOTRegion = new LOT_Region__c(Name = 'MALAYSIA', Region__c = 'APJ', Threshold_Region__c = 'APJ ASIA');
        insert objLOTRegion;
            
        objLOTOceanEmail = new LOT_OCEAN_EMAIL__c(Country__c = objLOTRegion.Id, Country_LE__c = 'test@testmail.com', region__c = 'REGION1');
        insert objLOTOceanEmail;
        
        objOpp = new Opportunity();
        objOpp.RecordTypeId = '012300000004zf2';
        objOpp.Quote_Numbers__c = '123456';
        objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
        objOpp.StageName= 'Propose - 60%';
        objOpp.Probability = 60;
        objOpp.AccountId = objAccount.Id;
        objOpp.Name = 'TEST Oppty 1';
        objOpp.CloseDate = System.today() + 30;
        objOpp.How_many_shipments__c = 1;
        objOpp.End_User_Mailing_Country__c = 'MALAYSIA';
        objOpp.Primary_Product_Delivery_Address_Region__c = 'APJ';
        objOpp.Primary_Product_Delivery_Address_Country__c = 'MALAYSIA';
        objOpp.Region__c = 'APJ';
        objOpp.Competitor_Lost_To__c = 'Unknown';
        insert objOpp;
        
        Product2 objProd1 = new Product2(Product_ID__c = '5234',Name='Test Product', APJ_ASIA__c=70, Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10,Source__c='Compal', Pallet_Quantity__c=6);
        insert objProd1;                
        
        String standardPBId = Test.getStandardPricebookId();
        
        PriceBook2 objCustomPB = new PriceBook2(Name='Test PriceBook');
        insert objCustomPB;
        
        PriceBookEntry pbes1 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd1.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        
        pbe1 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd1.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);     
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        pbeList.add(pbes1);
        pbeList.add(pbe1);
        insert pbeList; 
        
        //TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        Test.startTest();
        OpportunityLineItem insertOLI = new OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1, Quote__c='123451');
        insert insertOLI;
        
        Opportunity testOppty = [Select Adjustment_Potential_Cost_Saving__c
                                from Opportunity where Id = :objOpp.Id];
        testOppty.RecordTypeId = '012300000004zf2';
        testOppty.Adjustment_Potential_Cost_Saving__c = 2;
        update testOppty;
        
        Map<Id, Opportunity> newOppIdToOppMap = new Map<Id, Opportunity>();
        newOppIdToOppMap.put(testOppty.Id, testOppty);
        
        Map<Id, Opportunity> oldOppIdToOppMap = new Map<Id, Opportunity>();
        oldOppIdToOppMap.put(objOpp.Id, objOpp);
        
        LOTOcean.lotOceanCalculation(newOppIdToOppMap, oldOppIdToOppMap);
        LOTOcean.lotOceanCalculation(newOppIdToOppMap, null);
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);       
        Test.stopTest();
    }

    public static testMethod void testLOTOppty1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        // Fenny [5-Sep-2016] - Fix 0902 test failure
        Enable_Codes_Settings__c emcCode = new Enable_Codes_Settings__c(Name='EMC Codes', Enable__c=true);
        insert emcCode;
        
        Opportunity objOpp, objOpp3, objOpp2;
        List<Product2> lstProd;
        PriceBookEntry pbe1,pbe2,pbe3;
        List<OpportunityLineItem> oliList;
        
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        Sales_Channel_Group__c objSalesChannelGrp;
        Account objAccount;
        
        objSalesChannelGrp = new Sales_Channel_Group__c(Name = 'TestChannelGroup1', Regional_Parent_Name__c ='EMEA',Region_Name__c = 'APJ', Country_Name__c='MALAYSIA', Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE');
        insert objSalesChannelGrp;
        
        objAccount = new Account(Name = 'TestAccount', Sales_Channel__c = objSalesChannelGrp.Id);
        insert objAccount;
        
        objOceanData = new Ocean_Data__c(Days_in_country_Delivery__c = 70,On_the_sea_by_ODM__c = 70,CFI_Delivery_Time_in_Weeks__c = 10,CFS_Delivery_Time_in_Weeks__c=10,Exception_Country__c = 'COUNTRY1',
                                        MSP_Incremental_in_Weeks__c = 10, Region__c = 'REGION1', Ship_Rate__c = 4, Source__c = 'Compal', Pallet_Rate__c = 2);
        insert objOceanData;
        
        objLOTRegion = new LOT_Region__c(Name = 'MALAYSIA', Region__c = 'APJ', Threshold_Region__c = 'APJ ASIA');
        insert objLOTRegion;
            
        objLOTOceanEmail = new LOT_OCEAN_EMAIL__c(Country__c = objLOTRegion.Id, Country_LE__c = 'test@testmail.com', region__c = 'REGION1');
        insert objLOTOceanEmail;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityValidator(true);
        ProcessFlowTriggerController.isTest = true;

        objOpp = new Opportunity();
        objOpp.RecordTypeId = '012300000004zf2';
        objOpp.Quote_Numbers__c = '123456';
        objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
        objOpp.StageName= 'Propose - 60%';
        //objOpp.Probability = 60;
        //objOpp.Forecast_Category_Override__c = 'Best Case';
        objOpp.AccountId = objAccount.Id;
        objOpp.Name = 'TEST Oppty 1';
        objOpp.CloseDate = System.today() + 30;
        objOpp.How_many_shipments__c = 1;
        objOpp.End_User_Mailing_Country__c = 'MALAYSIA';
        objOpp.Primary_Product_Delivery_Address_Region__c = null;
        objOpp.Primary_Product_Delivery_Address_Country__c = null;
        objOpp.Region__c = 'APJ';
        objOpp.Competitor_Lost_To__c = 'Unknown';
        objOpp.Partner_Opportunity_Stage__c = 'Propose - 60%';
        Test.startTest();
        System.debug('objOpp :'+objOpp);
        System.debug('objOpp StageName :'+objOpp.StageName);
        System.debug('objOpp Probability :'+objOpp.Probability);
        System.debug('objOpp Forecast_Category_Override__c :'+objOpp.Forecast_Category_Override__c);
        insert objOpp;
        Test.stopTest();
        
        TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityValidator(false);
        
        Product2 objProd1 = new Product2(Product_ID__c = '6234',Name='Test Product', APJ_ASIA__c=70, Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10,Source__c='Compal', Pallet_Quantity__c=6);
        insert objProd1;                
        
        String standardPBId = Test.getStandardPricebookId();
        
        PriceBook2 objCustomPB = new PriceBook2(Name='Test PriceBook');
        insert objCustomPB;
        
        PriceBookEntry pbes1 = new PriceBookEntry(PriceBook2Id = standardPBId, Product2Id = objProd1.Id, IsActive = true, UnitPrice = 8, UseStandardPrice = false);
        
        pbe1 = new PriceBookEntry(PriceBook2Id = objCustomPB.Id, Product2Id = objProd1.Id,IsActive = true, UnitPrice = 8, UseStandardPrice = true);     
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        pbeList.add(pbes1);
        pbeList.add(pbe1);
        insert pbeList; 
        
        OpportunityLineItem insertOLI = new OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId = objOpp.Id, quantity=80, unitPrice=80, Mrgn__c = 1, Quote__c='123451');
        insert insertOLI;
        
        Opportunity testOppty = [Select Adjustment_Potential_Cost_Saving__c
                                from Opportunity where Id = :objOpp.Id];
        testOppty.RecordTypeId = '012300000004zf2';
        testOppty.Adjustment_Potential_Cost_Saving__c = 2;
        update testOppty;
        
        Map<Id, Opportunity> newOppIdToOppMap = new Map<Id, Opportunity>();
        newOppIdToOppMap.put(testOppty.Id, testOppty);
        
        Map<Id, Opportunity> oldOppIdToOppMap = new Map<Id, Opportunity>();
        oldOppIdToOppMap.put(objOpp.Id, objOpp);
        
        LOTOcean.lotOceanCalculation(newOppIdToOppMap, oldOppIdToOppMap);
        LOTOcean.lotOceanCalculation(newOppIdToOppMap, null);
        
        TriggerExecutionController.setSkipAccountTriggers(false); 
        
    }
    
    public static testmethod void testGetters() {
        //making use of the controller to execute the getters
        System.debug('###DEBUG FROM TEST### START testGetters');
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Sales_Channel_Group__c objTestSalesChannelGrp = new Sales_Channel_Group__c(Name='TestChannelGroup1', Region_Name__c='REGION1', Segment_Business_Unit_Name__c='LARGE ENTERPRISE',Country_Name__c='UNITED STATES',Regional_Parent_Name__c ='AMER');

        insert objTestSalesChannelGrp;

        Account objTestAccount = new Account(Name='TestAccount', Sales_Channel__c=objTestSalesChannelGrp.Id);
        insert objTestAccount;

        Ocean_Data__c objTestOceanData = new Ocean_Data__c(CFI_Delivery_Time_in_Weeks__c=10, CFS_Delivery_Time_in_Weeks__c=10,
                                            Exception_Country__c='COUNTRY1',    Lead_Time_in_Weeks__c=10,
                                            MSP_Incremental_in_Weeks__c=10, Region__c='REGION1',
                                            Ship_Rate__c=4, Source__c='Compal', Pallet_Rate__c=2,Days_in_country_Delivery__c = 70,
                                            On_the_sea_by_ODM__c = 70);

        insert objTestOceanData;

        LOT_Region__c objTestLOTRegion = new LOT_Region__c(Name='COUNTRY1', Region__c='REGION1', threshold_region__c='EMEA');

        insert objTestLOTRegion;
        
        LOT_OCEAN_EMAIL__c objLOTOceanEmail = new LOT_OCEAN_EMAIL__c(Country__c = objTestLOTRegion.Id, Country_LE__c = 'test@testmail.com', region__c = 'REGION1');
        insert objLOTOceanEmail;
        
        List<Opportunity> listOppty = new List<Opportunity>();
        Opportunity objTestOppty = new Opportunity(RecordTypeId='012300000004zf2', Quote_Numbers__c = '123456', Customer_Requested_Delivery_Date__c=system.today() + 60, StageName='Propose - 60%', Forecast_Category_Override__c = 'Omitted', Probability=60, AccountId=objTestAccount.Id, Name='TEST Oppty 1', CloseDate = System.today() + 30, Primary_Product_Delivery_Address_Region__c = 'REGION1', Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',Region__c='APJ',Competitor_Lost_To__c='Unknown',End_User_Mailing_Country__c='GERMANY');
        listOppty.add(objTestOppty);
        insert listOppty;
        
        List<Product2> listTestProd = new List<Product2>();
        Product2 objTestProd1 = new Product2(Product_ID__c = '12545',Name='Test Product', Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=10,Source__c='Compal', Pallet_Quantity__c=6);
        listTestProd.add(objTestProd1);

        Product2 objTestProd2 = new Product2(Product_ID__c = '12546',Name='Test Product',Volume_to_Dollar_Ratio__c=2, EMEA__c=10, Container_Volume__c=20,Source__c='Compal', Pallet_Quantity__c=12);
        listTestProd.add(objTestProd2);

        Product2 objTestProd3 = new Product2(Product_ID__c = '12547',Name='Test Product', Volume_to_Dollar_Ratio__c=2,EMEA__c=10, Container_Volume__c=30,Source__c='Compal', Pallet_Quantity__c=18);
        listTestProd.add(objTestProd3);

        insert listTestProd;
               
        Id idStandardPB = Test.getStandardPricebookId();
            
        PriceBook2 objTestPB = new PriceBook2(Name='Test PriceBook');
        insert objTestPB;
        
        List<PriceBookEntry> listPriceBookEntries = new List<PriceBookEntry>();
        
        PriceBookEntry pbes1 = new PriceBookEntry(PriceBook2Id=idStandardPB, Product2Id = objTestProd1.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
        listPriceBookEntries.add(pbes1);
        PriceBookEntry pbes2 = new PriceBookEntry(PriceBook2Id=idStandardPB, Product2Id = objTestProd2.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
        listPriceBookEntries.add(pbes2);
        PriceBookEntry pbes3 = new PriceBookEntry(PriceBook2Id=idStandardPB, Product2Id = objTestProd3.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
        listPriceBookEntries.add(pbes3);
        
        PriceBookEntry pbe1 = new PriceBookEntry(PriceBook2Id=objTestPB.Id, Product2Id = objTestProd1.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);
        listPriceBookEntries.add(pbe1);
        PriceBookEntry pbe2 = new PriceBookEntry(PriceBook2Id=objTestPB.Id, Product2Id = objTestProd2.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = true);
        listPriceBookEntries.add(pbe2);
        PriceBookEntry pbe3 = new PriceBookEntry(PriceBook2Id=objTestPB.Id, Product2Id = objTestProd3.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = true);
        listPriceBookEntries.add(pbe3);

        insert listPriceBookEntries;

        List<OpportunityLineItem> listOli = new List<OpportunityLineItem>();
        for(integer i=1; i <= 5; i++) {
            listOli.add(new OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId=objTestOppty.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
            listOli.add(new OpportunityLineItem(PriceBookEntryId = pbe2.Id, OpportunityId=objTestOppty.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
            listOli.add(new OpportunityLineItem(PriceBookEntryId = pbe3.Id, OpportunityId=objTestOppty.Id, quantity=80, unitPrice=80, Mrgn__c = 1 ));
        }
        insert listOli;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;


        Test.startTest();

        OpportunityLOTProductListController controller = new OpportunityLOTProductListController(objTestOppty.Id, 2, true);

        List<String> resultText = controller.getTableRowTextList();

        System.debug('######DEBUG ' + resultText);
        
        LOTOcean.populateLOTOceanRelatedDetails(listOppty);
        LOTOCEANUtils.getIntegrationProfiles();
        LOTOCEANUtils.getprofileIdToSkipLOTOcean();
        LOTOCEANUtils.setupCountryToRegionMap();
        system.assertEquals(listOppty[0].LOT_OCEAN_Field_Changes__c,null);
        Test.stopTest();
    }
    
    public static testMethod void testLOTOppty2(){
        TriggerExecutionController.setSkipAllTriggers(true);
          
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        Sales_Channel_Group__c objSalesChannelGrp;
        Account objAccount;
        
        objSalesChannelGrp = new Sales_Channel_Group__c(Name = 'TestChannelGroup1', Regional_Parent_Name__c ='EMEA',Region_Name__c = 'APJ', Country_Name__c='MALAYSIA', Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE');
        insert objSalesChannelGrp;
        
        objAccount = new Account(Name = 'TestAccount', Sales_Channel__c = objSalesChannelGrp.Id);
        insert objAccount;
        
        objOceanData = new Ocean_Data__c(Days_in_country_Delivery__c = 70,On_the_sea_by_ODM__c = 70,CFI_Delivery_Time_in_Weeks__c = 10,CFS_Delivery_Time_in_Weeks__c=10,Exception_Country__c = 'COUNTRY1',
                                        MSP_Incremental_in_Weeks__c = 10, Region__c = 'REGION1', Ship_Rate__c = 4, Source__c = 'Compal', Pallet_Rate__c = 2);
        insert objOceanData;
        
        objLOTRegion = new LOT_Region__c(Name = 'MALAYSIA', Region__c = 'APJ', Threshold_Region__c = 'APJ ASIA');
        insert objLOTRegion;
            
        objLOTOceanEmail = new LOT_OCEAN_EMAIL__c(Country__c = objLOTRegion.Id, Country_LE__c = 'test@testmail.com', region__c = 'REGION1');
        insert objLOTOceanEmail;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityValidator(true);
        ProcessFlowTriggerController.isTest = true;
        
        Opportunity objOpp = new Opportunity();
        objOpp.RecordTypeId = '012300000004zf2';
        objOpp.Quote_Numbers__c = '123456'; 
        objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
        objOpp.StageName= 'Propose - 60%';
        objOpp.Probability = 60;
        objOpp.AccountId = objAccount.Id;
        objOpp.Name = 'TEST Oppty 1';
        objOpp.CloseDate = System.today() + 30;
        objOpp.How_many_shipments__c = 1;
        objOpp.End_User_Mailing_Country__c = 'MALAYSIA';
        objOpp.Primary_Product_Delivery_Address_Region__c = null;
        objOpp.Primary_Product_Delivery_Address_Country__c = null;
        objOpp.Region__c = 'APJ';
        objOpp.Competitor_Lost_To__c = 'Unknown';
        objOpp.Is_CFI_included__c ='Yes';
        objOpp.Adjustment_weeks__c = 1;
        objOpp.Direct_Trailer_Opportunity__c = 'Yes';
        objOpp.Must_Arrive_By_Date__c = true;
        objOpp.Adjustment_Potential_Cost_Saving__c = 60;
        objOpp.Ocean_Opportunity_Notification_Pop_Up__c = false;
        objOpp.Recalculate_LOT_OCEAN__c = True;
        objOpp.Additional_vol_to_team_Quarterly__c = 'Yes';
        objOpp.Potential_Cost_Savings_If_Ocean__c = 5.00;
        
        Map<Id, Opportunity> mapNewOppIdToOpp = new Map<Id, Opportunity>();
        mapNewOppIdToOpp.put(objOpp.Id, objOpp);
        
        Test.startTest();
        LOTOcean.lotOceanCalculation(mapNewOppIdToOpp, null);
        system.assertNotEquals(objOpp.LOT_OCEAN_Field_Changes__c,null);
        Test.stopTest();
    }
    
}