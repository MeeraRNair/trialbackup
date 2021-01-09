/*
REVISION HISTORY
================
Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           6-dec-2019          Implimented TestDataFactory        
*/
@isTest
public class VFCntrlr_CTICallLogEdit_Test{
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

        TriggerExecutionControl__c oTec = new TriggerExecutionControl__c();
        oTec.Name = 'Opportunity';
        oTec.RecursiveCount__c = 2;
        insert oTec;

        TriggerExecutionControl__c oliTect = new TriggerExecutionControl__c();
        oliTect.Name = 'OpportunityLineItem';
        oliTect.RecursiveCount__c = 2;
        insert oliTect;

        TriggerExecutionController.setSkipAllTriggers(true);

        list<Account> listAccTdf=TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Channel Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;

        TriggerExecutionController.setSkipAllTriggers(false);
    }
    public static testMethod void testMethod1(){
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        
        Opportunity objOpp;
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        Sales_Channel_Group__c objSalesChannelGrp;
        Account objAccount;
        
        objSalesChannelGrp = new Sales_Channel_Group__c();
        objSalesChannelGrp.Name = 'TestChannelGroup1';
        objSalesChannelGrp.Region_Name__c = 'REGION1';
        objSalesChannelGrp.Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE';        
        insert objSalesChannelGrp;
        
        /* objAccount = new Account();
objAccount.Name = 'TestAccount';
objAccount.Sales_Channel__c = objSalesChannelGrp.Id;
insert objAccount;
*/
        list<Account> listAcc=[Select id from Account Limit 1];
        listAcc[0].Sales_Channel__c = objSalesChannelGrp.Id;
        update listAcc;
        CTI_Call_Log__c objCTICL = new CTI_Call_Log__c();
        objCTICL.Account__c = listAcc[0].Id;
        insert objCTICL;
        system.assertNotEquals(listAcc[0].Id, null);
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
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        /*   objOpp= new Opportunity (AccountID=objAccount.Id ,
RecordTypeId= '012A0000000Vjtg',
Name='TestOpp 4',
Type = 'Run Rate',
Domain__c='Deal Reg',
Solution_Type__c = 'Campus',
Solution_Name__c = 'Wireless Switches',
StageName='Commit - 90%',
Deal_Registration_Status__c = 'Recalled',
Deal_Created_Date_Time__c = System.Now(),
Deal_Expiration_Timeframe__c='60',
// Related_Parent_Opportunity__c = testParentOpportunity.Id, 
CloseDate= System.Now().Date().addDays(180),
Deal_Expiration_Date__c=System.Now().Date().addDays(4),
Request_Status__c='New', 
Forecast_Category_Override__c = 'Omitted');
insert objOpp;  
*/
        list<Opportunity> listOpp=[Select id from Opportunity Limit 1];
        
        /*     objOpp = new Opportunity();
objOpp.RecordTypeId = '012300000004zf2';
objOpp.Quote_Numbers__c = '123456';
objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
//objOpp.StageName='Propose - 60%';
// objOpp.Probability = 60;
objOpp.AccountId = objAccount.Id;
objOpp.Name = 'TEST Oppty 1';
objOpp.CloseDate = System.today() + 30;
objOpp.Primary_Product_Delivery_Address_Region__c = 'REGION1';
objOpp.Primary_Product_Delivery_Address_Country__c = 'COUNTRY1';
objOpp.Region__c = 'APJ';
objOpp.Competitor_Lost_To__c = 'Unknown';
objOpp.CTI_Call_Log_Id__c = objCTICL.Id;
objOpp.StageName = 'Plan - 1%';
objOpp.Probability = 1;
//  Test.startTest();
insert objOpp; */
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);         
        TriggerControlHandler.setOpportunityTriggersActive();
        
        Contact objCon = new Contact();
        objCon.FirstName = 'Test FName';
        objCon.LastName = 'Test LastName';
        objCon.CTI_Call_Log_Id__c = objCTICL.Id;
        objCon.AccountId = listAcc[0].Id;
        objCon.Phone = '1234567890';
        insert objCon;
        
        VFCntrlr_CTICallLogEdit objVFCTICL = new VFCntrlr_CTICallLogEdit(new ApexPages.StandardController(objCTICL));
        objVFCTICL.refreshOpportunity();
        objVFCTICL.refreshContact();
        objVFCTICL.saveRecord();
    }
    
    public static testMethod void testMethod2(){
        Test.startTest();
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        Opportunity objOpp;
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        Sales_Channel_Group__c objSalesChannelGrp;
        //Account objAccount;
        //Account objAccount1;
        
        objSalesChannelGrp = new Sales_Channel_Group__c();
        objSalesChannelGrp.Name = 'TestChannelGroup1';
        objSalesChannelGrp.Region_Name__c = 'REGION1';
        objSalesChannelGrp.Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE';        
        insert objSalesChannelGrp;
        
        /* objAccount = new Account();
objAccount.Name = 'TestAccount';
objAccount.Sales_Channel__c = objSalesChannelGrp.Id;
insert objAccount;

objAccount1 = new Account();
objAccount1.Name = 'TestAccount1';
objAccount1.Sales_Channel__c = objSalesChannelGrp.Id;
insert objAccount1;
*/
        list<Account> listAcc=[Select id from Account Limit 2];
        listAcc[0].Sales_Channel__c = objSalesChannelGrp.Id;
        listAcc[1].Sales_Channel__c = objSalesChannelGrp.Id;
        update listAcc;
        CTI_Call_Log__c objCTICL = new CTI_Call_Log__c();
        objCTICL.Account__c = listAcc[0].Id;
        insert objCTICL;
        system.assertNotEquals(listAcc[0].id, null);
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
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        /*    objOpp = new Opportunity();
objOpp.RecordTypeId = '012300000004zf2';
objOpp.Quote_Numbers__c = '123456';
objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
objOpp.StageName='Propose - 60%';
objOpp.Probability = 60;
objOpp.AccountId = objAccount1.Id;
objOpp.Name = 'TEST Oppty 1';
objOpp.CloseDate = System.today() + 30;
objOpp.Primary_Product_Delivery_Address_Region__c = 'REGION1';
objOpp.Primary_Product_Delivery_Address_Country__c = 'COUNTRY1';
objOpp.Region__c = 'APJ';
objOpp.Competitor_Lost_To__c = 'Unknown';
insert objOpp; */
        /* objOpp= new Opportunity (AccountID=objAccount.Id ,
RecordTypeId= '012A0000000Vjtg',
Name='TestOpp 4',
Type = 'Run Rate',
Domain__c='Deal Reg',
Solution_Type__c = 'Campus',
Solution_Name__c = 'Wireless Switches',
StageName='Commit - 90%',
Deal_Registration_Status__c = 'Recalled',
Deal_Created_Date_Time__c = System.Now(),
Deal_Expiration_Timeframe__c='60',
// Related_Parent_Opportunity__c = testParentOpportunity.Id, 
CloseDate= System.Now().Date().addDays(180),
Deal_Expiration_Date__c=System.Now().Date().addDays(4),
Request_Status__c='New', 
Forecast_Category_Override__c = 'Omitted');
insert objOpp;  

*/
        list<Opportunity> listOpp=[Select id from Opportunity Limit 1];
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);  
        
        Contact objCon = new Contact();
        objCon.FirstName = 'Test FName';
        objCon.LastName = 'Test LastName';
        objCon.AccountId = listAcc[1].Id;
        objCon.Phone = '1234567890';
        insert objCon;
        Test.stopTest();
        
        VFCntrlr_CTICallLogEdit objVFCTICL = new VFCntrlr_CTICallLogEdit(new ApexPages.StandardController(objCTICL));
        objVFCTICL.objCTI.Opportunity__c = listOpp[0].Id;
        objVFCTICL.saveRecord();
        objVFCTICL.getRecordTypes();
        objVFCTICL.testMethod1();
        objVFCTICL.createOpportunity();
        objVFCTICL.objCTI.Contact__c = objCon.Id;
        objVFCTICL.saveRecord();
    }
}