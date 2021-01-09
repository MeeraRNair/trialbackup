@isTest
public class ExtendedAssetController_Test {
    private static List<ID> lstIds = new List<ID>(); 

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
        
        
        List<Profile> userProfile= [select id,name from profile where name like '%Sales%' order by name limit 2];
        User usr = new User(Username='test_test@dell.com', Alias='test', Email='test_test@dell.com', FirstName='Tfirst', LastName='TLast', ProfileId = userProfile[0].Id, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test'+System.currentTimeMillis(), Title='Test Title', CurrencyIsoCode='USD');
        insert usr;
        
        Account newAcc = new Account(Name='Test Account');
        insert newAcc;
        
        Opportunity oppty = new Opportunity(AccountID=newAcc.ID, Name='Test Oppty', Type='Standard Opportunity', StageName='Plan - 1%', 
                                            Partner_Opportunity_Stage__c = 'Plan - 1%',CloseDate=System.Now().Date().addDays(180));
        insert oppty;
    
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
        lstIds.add(asset.Id);
               
        Dell_Asset_RMA__Opportunity_Asset_Junction__c jnc = new Dell_Asset_RMA__Opportunity_Asset_Junction__c();
        jnc.Dell_Asset_RMA__Related_Asset__c = asset.Id;
        jnc.Dell_Asset_RMA__Related_Opportunity__c = Oppty.Id;
        insert jnc;
        
    TriggerExecutionController.setSkipAllTriggers(false);  
        
    }

    @isTest
    static void testmethod1()
    {
        Dell_Asset_RMA__Asset__c listAssetId = [SELECT Id FROM Dell_Asset_RMA__Asset__c WHERE Name='Test Asset' LIMIT 1];
        Test.startTest();
        public_assets_extobj__x mockedRequest = new public_assets_extobj__x(
        external_asset_id_c__c = listAssetId.Id
        );

        ExtendedAssetController.mockedRequests.add(mockedRequest);
        ExtendedAssetController.getExtAssetObj(listAssetId.id);
        Test.stopTest();
        
        ExtendedAssetController.sFetchAvamarNodes(listAssetId.id);
    }
    
    @isTest
    static void testmethod2()
    {
        String query= 'SELECT Id FROM Dell_Asset_RMA__Asset__c WHERE Name=\'Test Asset\' LIMIT 1';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(query));
        Test.startTest();
        setCtrl.setSelected([SELECT Id FROM Dell_Asset_RMA__Asset__c WHERE Name='Test Asset' LIMIT 1]);
        AssetPassToRenewalsController ctlr = new AssetPassToRenewalsController(setCtrl);
        ctlr.deferAsset();
        Test.stopTest();
        
    }
    
    @isTest
    static void testmethod3()
    {
        String query= 'SELECT id FROM Dell_Asset_RMA__Opportunity_Asset_Junction__c limit 1';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(query));
        Test.startTest();
        setCtrl.setSelected([SELECT id FROM Dell_Asset_RMA__Opportunity_Asset_Junction__c limit 1]);
        AssetOppMgmtController ctlr = new AssetOppMgmtController(setCtrl);
        ctlr.unlink();
        ctlr.unlinkDefer();
        Test.stopTest();
    }

}