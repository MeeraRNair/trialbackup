@IsTest
public class SnPVendorsTriggerHandlerADTest {
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdSetting;
    }   

static testMethod void testDeleteSnPVendors(){
      
    	String strMockMetaData = '';

         Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterDelete' => new List<Boolean>{false, false, false, true, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "S_P_Vendors__c", "Class_Name__c": "SnPVendorsTriggerHandlerAD"},';
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
        
        Id ibRTId= IdLookupUtils.getRecordTypeId('APC','S_P_Vendors__c',true);
        
        
        List<S_P_Vendors__c> listSnV = new List<S_P_Vendors__c>();
        listSnV.add(new S_P_Vendors__c(Opportunity__c = opp.id, Qualified_for_S_P_Deal_Reg_Program__c = 'Yes', RecordTypeid = ibRTId));
        listSnV.add(new S_P_Vendors__c(Opportunity__c = opp.id, Qualified_for_S_P_Deal_Reg_Program__c = 'Yes', RecordTypeid = ibRTId));
        listSnV.add(new S_P_Vendors__c(Opportunity__c = opp.id, Qualified_for_S_P_Deal_Reg_Program__c = 'Yes', RecordTypeid = ibRTId));
        insert listSnV;
        
        S_P_Vendors__c sV = [SELECT Id, Opportunity__c, Qualified_for_S_P_Deal_Reg_Program__c FROM S_P_Vendors__c WHERE Id = :listSnV[0].Id LIMIT 1];
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        
        Test.startTest();
        delete sV;
        Test.stopTest();
        
        opp = [SELECT Qualified_Vendor_Count_Temp__c FROM Opportunity WHERE Id = :opp.Id];

        System.AssertEquals(2, opp.Qualified_Vendor_Count_Temp__c);
    }
}