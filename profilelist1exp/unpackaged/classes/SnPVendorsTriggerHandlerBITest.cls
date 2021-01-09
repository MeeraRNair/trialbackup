@IsTest
public class SnPVendorsTriggerHandlerBITest {
  //8.0 - BOF
    //Making list for Skip VRs
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
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
    //8.0 - EOF
    
    
    static testMethod void testInsertSnPVendors(){
      
         String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "S_P_Vendors__c", "Class_Name__c": "SnPVendorsTriggerHandlerBI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionController.setSkipAllTriggers(true);
        SnPVendorsUtilities.isTest = true;
        //ProcessFlowTriggerController.isTest = true;
        
        //Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        //insert testAccountObj;
        Opportunity opp = new Opportunity(Name = 'testOpportunity',
                                          //AccountID=testAccountObj.ID,
                                          //StageName  = 'Open',
                                          StageName = 'Plan - 1%',                                         
                                          CloseDate = System.today() + 30,
                                          CurrencyIsoCode = 'USD',
                                          Qualified_Vendor_Count_Temp__c = 1
                                                                                                                          
                                         );
        insert opp; 

        Id pbk1 = Test.getStandardPricebookId();
        
        Product2 objProduct = new Product2 (Name = 'VMware', Product_Line_Desc__c = 'Test Product', IsActive = TRUE, SOC_Qualified__c = true, S_P_Registerable__c = true, Product_ID__c = 'Test_Prod_ID_123', Description = 'Test VMware');
        insert objProduct ;
        
        PricebookEntry pBE= new PricebookEntry (Product2ID=objProduct.id, Pricebook2ID=pbk1, isActive=true, useStandardPrice=false, UnitPrice = 50);
        insert pBE;
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid = opp.Id, pricebookEntryId = pBE.id, Mrgn__c =6, Discount_off__c = 7, UnitPrice = 100,
                                                                    Quantity =2, Description = 'Line Description'); 
                                                                    
        insert testLineItem;

        TriggerExecutionController.setSkipAllTriggers(false);        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        
        Id ibRTId= IdLookupUtils.getRecordTypeId('APC','S_P_Vendors__c',true);
        
        List<S_P_Vendors__c> listSnP = new List<S_P_Vendors__c>();
        S_P_Vendors__c snp1 = new S_P_Vendors__c(Opportunity__c = opp.id, Qualified_for_S_P_Deal_Reg_Program__c = 'Yes', 
                                                RecordTypeid = ibRTId, S_P_Vendors_Name__c = 'VMware');
        S_P_Vendors__c snp2 = new S_P_Vendors__c(Opportunity__c = opp.id, Qualified_for_S_P_Deal_Reg_Program__c = 'Yes', 
                                                RecordTypeid = ibRTId, S_P_Vendors_Name__c = 'CommVault');
        listSnP.add(snp1);
        listSnP.add(snp2);
        insert listSnP;
        
        S_P_Vendors__c insertedSnP1 = [SELECT VMware_Product_Mapping__c from S_P_Vendors__c WHERE Id = :snp1.Id];
        S_P_Vendors__c insertedSnP2 = [SELECT VMware_Product_Mapping__c from S_P_Vendors__c WHERE Id = :snp2.Id];
        System.assertEquals('Test VMware;', insertedSnP1.VMware_Product_Mapping__c);
        System.assertEquals(null, insertedSnP2.VMware_Product_Mapping__c);
        
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        
    }
  
}