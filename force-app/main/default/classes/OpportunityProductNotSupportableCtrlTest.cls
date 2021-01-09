/*
* Revision CR Number   Release No    Date            Modified By     Description
* -------- ---------   ----------    -----------     ------------    -----------
* 1.0                  0202         12-Dec-2019     venu            Implimented TestDataFactory
*/
@isTest
public class OpportunityProductNotSupportableCtrlTest
{
    static  list<Opportunity> listOpp;
    static list<Ocean_Data__c> listOceanData;
    @testsetup static void setup(){
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
        list<Sales_Channel_Group__c> listSCGTDF = TestDataFactory.createNSalesChannelGroups(1);
        insert listSCGTDF;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Master Account');
        listAccTDF[0].Sales_Channel__c = listSCGTDF[0].Id;
        insert listAccTDF;
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTDF[0].AccountId = listAccTDF[0].Id;
        TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
        insert listOppTDF;
        list<Ocean_Data__c> listOceanDataTDF = TestDataFactory.createNOceanData(1);
        insert listOceanDataTDF;
    }
    public static testMethod void testMethod1(){
        // Opportunity objOpp;
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        // Sales_Channel_Group__c objSalesChannelGrp;
        //  Account objAccount;
        
        /*      objSalesChannelGrp = new Sales_Channel_Group__c();
objSalesChannelGrp.Name = 'TestChannelGroup1';
objSalesChannelGrp.Region_Name__c = 'REGION1';
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
insert objOceanData;*/
        listOceanData = [select id from Ocean_Data__c limit 1 ];
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
        /*
objOpp = new Opportunity();
objOpp.RecordTypeId = '012300000004zf2';
objOpp.Quote_Numbers__c = '123456';
objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
objOpp.StageName='Propose - 60%';
objOpp.Probability = 60;
objOpp.AccountId = objAccount.Id;
objOpp.Name = 'TEST Oppty 1';
objOpp.CloseDate = System.today() + 30;
objOpp.Primary_Product_Delivery_Address_Region__c = 'REGION1';
objOpp.Primary_Product_Delivery_Address_Country__c = 'COUNTRY1';
objOpp.Region__c = 'APJ';
objOpp.Competitor_Lost_To__c = 'Unknown';
TriggerExecutionController.setSkipOpportunitySplitTriggers(True);
insert objOpp;        
*/
        listOpp = [select id from Opportunity limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        OpportunityProductNotSupportableCtrl objOPNS = new OpportunityProductNotSupportableCtrl();
        objOPNS = new OpportunityProductNotSupportableCtrl(listOpp[0].Id);
        objOPNS.getOpptyRec();
        objOPNS.accName = 'Test';
        objOPNS.accBUID = 'Test';
        objOPNS.salesRepName = 'Test';
        objOPNS.salesRepEmail = 'Test';
    }
}