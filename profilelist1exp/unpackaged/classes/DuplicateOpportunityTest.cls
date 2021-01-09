/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*
* Author   : Harry
* Purpose  : Test Class for Dell_Asset_RMA Logic
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      XXXXX       FY20-DCE-0702   20-May-2019     Harry           Initial Creation
* 2.0      XXXXX       FY20-DCE-0702   20-May-2019     Afiq            Added Custom Settings and bypass triggers during record creation
 */
@isTest
private class DuplicateOpportunityTest {

    
    //2.0 Start - Added custom settings to populate StageName values.
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);  
        
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "RMAOpportunityTriggerHandlerAU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        
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
        system.assertEquals('Qualify - 30%',owdSetting.Oppty_Stage30__c );
        
        
        Opportunity_Details_Extra_Creation__c opExtra = new Opportunity_Details_Extra_Creation__c(SetupOwnerId=Userinfo.getUserId());
        opExtra.Is_Opty_Details_Extra_Create__c = false;
        insert opExtra;
        
        //2.0 Start
        List<Dell_Asset_RMA__CustomSettingDataValueMap__c> dataValues = new List <Dell_Asset_RMA__CustomSettingDataValueMap__c>();
        dataValues.add(     new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='EMC Install Record Type',
            Dell_Asset_RMA__DataValue__c ='0125C000000cQ8T'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='EMC Install - NonActionable',
            Dell_Asset_RMA__DataValue__c ='0125C000000cQ8T'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='IntegrationUser',
            Dell_Asset_RMA__DataValue__c ='0125C000000cQ8T'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='R2R_lead_Status',
            Dell_Asset_RMA__DataValue__c ='New;Working;Nurture;Appointment;Qualified;Pre-Qualified'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='R2R_Admin_Profiles',
            Dell_Asset_RMA__DataValue__c ='00e70000000wRaBAAU;00e70000000wBzaAAE'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='R2R_UserIdsToByPass',
            Dell_Asset_RMA__DataValue__c ='00570000001gnQRAAY;00570000001etksAAA;00570000001eyc5AAA;00570000002G1FMAA0;0056F0000098uoC'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='R2R_Closed_lead_Staus',
            Dell_Asset_RMA__DataValue__c ='Closed;Converted To Opportunity;Closed by Sales;Converted to New Opportunity ; Converted to Existing Opportunity'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='R2R_Install_Base_Status',
            Dell_Asset_RMA__DataValue__c ='Deleted;Displaced by EMC;Displaced by Competitor'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='R2R Actionable Status',
            Dell_Asset_RMA__DataValue__c ='Awaiting Customer Install;Competitor Maintained;Install;Install - T&M;Reseller Maintained;Shipped'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='R2R Non-Actionable Asset Status',
            Dell_Asset_RMA__DataValue__c ='Billing Failed;Complete;Converted;Corrected;Created;Defective Returns;Deinstall – Mech Rep;Deinstall - Rtn to Mfg;Deinstall - Rtn to Mfg;Deinstall - Upgrade Conversion;Expired;Installed;Latest;NA;Replaced;Replacement;Returned for Repair;Spare Part;'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='R2R Non-Actionable Asset Status1',
            Dell_Asset_RMA__DataValue__c ='Terminate;UN;Undetermined;Deinstall - Cust Site'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='R2R_SYS_Admin_Profiles',
            Dell_Asset_RMA__DataValue__c ='00e70000000wRaBAAU;00e70000000wBzaAAE'));
        dataValues.add(new Dell_Asset_RMA__CustomSettingDataValueMap__c(name='OpptyClosedStatus',
            Dell_Asset_RMA__DataValue__c ='Lost, Cancelled - 0%;Order Submitted - 99%;Win - 100%'));
        Insert dataValues;
        //2.0 End
        
        
        //create account
        Account newAcc = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert newAcc;      
        
        Id assetRecordTypeId = Schema.SObjectType.Dell_Asset_RMA__Asset__c.getRecordTypeInfosByName().get('Competitive Install').getRecordTypeId();
        
        Dell_Asset_RMA__Asset__c asset = new Dell_Asset_RMA__Asset__c(name= 'Test Asset',
            Dell_Asset_RMA__Customer_Name__c = newAcc.Id,
            Dell_Asset_RMA__Install_Base_Status__c='Install',
            recordtypeid = assetRecordTypeId,
            Dell_Asset_RMA__Product_Name_Vendor__c='Dell',
            Dell_Asset_RMA__Product_Family__c = 'Other',
            Dell_Asset_RMA__Model__c='N/A/',
            Dell_Asset_RMA__Serial_Number__c='1111',
            Dell_Asset_RMA__Install_Date__c=System.Now().Date(),
            Dell_Asset_RMA__Leased_Purchased__c='Purchased',
            Dell_Asset_RMA__Drive__c=100,
            Dell_Asset_RMA__X1_Drive__c =1,
            Dell_Asset_RMA__X2_Drive_Capacity_GB__c =100,
            Dell_Asset_RMA__X2_Drive__c =1,
            Dell_Asset_RMA__X3_Drive_Capacity_GB__c =100,
            Dell_Asset_RMA__X3_Drive_Quantity__c    =1,
            Dell_Asset_RMA__X4_Drive_Capacity_GB__c =100,
            Dell_Asset_RMA__X4_Drive_Quantity__c    =1,
            Dell_Asset_RMA__X5_Drive_Capacity_GB__c =100,
            Dell_Asset_RMA__X5_Drive_Quantity__c    =1,
            Dell_Asset_RMA__Trade_In_Swap_ID__c='1',
            Dell_Asset_RMA__Registration_Type__c='Swap'         
            );
        List<Dell_Asset_RMA__Asset__c> assetList = new List<Dell_Asset_RMA__Asset__c>();
        assetList.add(asset);
        insert asset;
        
        
        Opportunity_Details_Extra__c opDExtra = new Opportunity_Details_Extra__c(name ='Test Extra');
        insert opDExtra;
        
        TriggerExecutionController.setSkipAllTriggers(false);  
        
    }
    //2.0 - End


    static testMethod void myUnitTest() {
        
        List<String> lstObjAPINames = new List<String>{'Opportunity'};
        SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);
        
        TriggerExecutionController.setSkipAllTriggers(true);  
         String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
                 };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "RMAOpportunityTriggerHandlerAU"},'; 
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity';
        tec.RecursiveCount__c = 1;
        insert tec;
        
        Dell_Asset_RMA__Asset__c listAssetId = [SELECT Id FROM Dell_Asset_RMA__Asset__c WHERE Name='Test Asset' LIMIT 1];
        Account listAcc = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        Opportunity_Details_Extra__c listextra = [Select id from Opportunity_Details_Extra__c where name = 'Test Extra' limit 1];
        
        Opportunity opp1 = new Opportunity (AccountID=listAcc.ID ,
                                           Name='TestOpp1',
                                           Type = 'Renewal',
                                           Domain__c='Deal Reg',
                                           Solution_Type__c = 'Campus',
                                           Solution_Name__c = 'Wireless Switches',
                                           StageName='Plan - 1%',
                                           Deal_Expiration_Timeframe__c='60',                                               
                                           Request_Status__c='New', 
                                           CloseDate= System.Now().Date().addDays(180),
                                           Fiscal_Year_Start_Date__c = System.Now().Date().addDays(200),
                                           Forecast_Category_Override__c = 'Omitted',
                                           Opportunity_Details_Extra__c = listextra.id);
                                           
         //insert opp1;
         
         Opportunity opp2 = new Opportunity (AccountID=listAcc.ID ,
                                           Name='TestOpp2',
                                           Type = 'Renewal',
                                           Domain__c='Deal Reg',
                                           Solution_Type__c = 'Campus',
                                           Solution_Name__c = 'Wireless Switches',
                                           StageName='Plan - 1%',
                                           Deal_Expiration_Timeframe__c='60',                                               
                                           Request_Status__c='New', 
                                           CloseDate= System.Now().Date().addDays(180), 
                                           Forecast_Category_Override__c = 'Omitted');    

                                            
        //insert opp2;
        
        List<Opportunity> optyList = new List<Opportunity>();
        
        optyList.add(opp1);
        optyList.add(opp2);
        
        insert optyList;
        system.assertEquals('Plan - 1%',optyList[1].StageName);
        
        List<Dell_Asset_RMA__Opportunity_Asset_Junction__c> listoaJunctionList = new List<Dell_Asset_RMA__Opportunity_Asset_Junction__c>();
        listoaJunctionList.add(new Dell_Asset_RMA__Opportunity_Asset_Junction__c(Dell_Asset_RMA__Related_Asset__c = listAssetId.Id,
        Dell_Asset_RMA__Related_Opportunity__c=opp1.Id) );
        
        //TriggerExecutionController.setSkipAllTriggers(false);
        
        insert listoaJunctionList; 
        TriggerExecutionController.setSkipAllTriggers(false);
        //2.0 > Change StartTest location skip triggers location
        Test.startTest();
        opp1.Dell_Asset_RMA__Duplicate_Opportunity__c = opp2.Id;
        update opp1;
        
        
        //Did dup opp id get copied to hidden field ?
        Opportunity opp = [select Duplicate_Opportunity_ID__c from opportunity where id = :opp1.id];
        opp1.Duplicate_Opportunity_ID__c = opp.Duplicate_Opportunity_ID__c;
        System.debug('hmassets:'+opp1.Duplicate_Opportunity_ID__c + ':' + opp.Duplicate_Opportunity_ID__c + ':' + opp2.Id);
      //  System.AssertEquals(opp1.Duplicate_Opportunity_ID__c,opp2.Id);
        
        Test.stopTest();
        
        //Dell_Asset_RMA__Duplicate_Opportunity__c = '',);
        opp1.StageName = 'Lost, Cancelled - 0%';
        opp1.Probability = 0;
        opp1.Competitor_Lost_To__c = 'Microsoft';
        opp1.Reason_Won_Lost__c = 'Duplicate';
        update opp1;
        

        
        
    }
}