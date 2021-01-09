@IsTest
public class SnPVendorsTriggerHandlerBUTest {
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

	static testmethod void testUpdateSnPVendors(){
   
        TriggerExecutionController.setSkipAllTriggers(true);
        SnPVendorsUtilities.isTest = true;
        //ProcessFlowTriggerController.isTest = true;
        
         String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "S_P_Vendors__c", "Class_Name__c": "SnPVendorsTriggerHandlerBU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        Opportunity opp = new Opportunity(Name = 'testOpportunity',
                                          //StageName  = 'Open',
                                          StageName = 'Plan - 1%',    
                                          CloseDate = System.today(),
                                          CurrencyIsoCode = 'USD',
                                          Qualified_Vendor_Count_Temp__c = 1
                                         );
        insert opp; 
        
         System.AssertEquals('testOpportunity', opp.Name);

        
        Id pbk1 = Test.getStandardPricebookId();
        
        Product2 objProduct = new Product2 (Name = 'VMware', Product_Line_Desc__c = 'Test Product', IsActive = TRUE, SOC_Qualified__c = true, S_P_Registerable__c = true, Product_ID__c = 'Test_Prod_ID_123', Description = 'Test VMware');
        insert objProduct ;
        
        PricebookEntry pBE= new PricebookEntry (Product2ID=objProduct.id, Pricebook2ID=pbk1, isActive=true, useStandardPrice=false, UnitPrice = 50);
        insert pBE;
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid = opp.Id, pricebookEntryId = pBE.id, Mrgn__c =6, Discount_off__c = 7, UnitPrice = 100,
                                                                    Quantity =2, Description = 'Line Description'); 
                                                                    
        insert testLineItem;
          S_P_Vendor_Automation__c svAuto = new S_P_Vendor_Automation__c(
                                            Vendor_Name__c='vmware',Is_Active__c=true,Expiration_Date__c=system.today(),
                                            Automation_Type__c='Full Automation');
            Insert svAuto;                         
        
        S_P_Vendor_Partner_Information__c svpInfo = new S_P_Vendor_Partner_Information__c(Segment__c='CHANNEL',
                                                S_P_Vendor_Automation_ID__c=svAuto.id,country__c='INDIA',
                                                Is_Active__c=true,Account_Name__c='test');
        Insert svpInfo; 
        S_P_Vendor_Partner_Information__c svpInfo1 = new S_P_Vendor_Partner_Information__c(Segment__c='CHANNEL',
                                                S_P_Vendor_Automation_ID__c=svAuto.id,country__c='INDIA',
                                                Is_Active__c=true,Account_Name__c='test');
        Insert svpInfo1;                                        
        S_P_Vendor_Partner_Information__c svpInfo2 = new S_P_Vendor_Partner_Information__c(
                                                S_P_Vendor_Automation_ID__c=svAuto.id,country__c='INDIA',
                                                Is_Active__c=true,Account_Name__c='test');
        Insert svpInfo2; 
        
        
        S_P_Vendor_Automation_Exception__c svAe = new S_P_Vendor_Automation_Exception__c(Field_API_Name__c = 'test__c',Is_Active__c=true, S_P_Vendor_Automation_Id__c =svAuto.Id);
        
        insert svAe;     
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        
        Id ibRTId= IdLookupUtils.getRecordTypeId('VMware','S_P_Vendors__c',true);
                
        List<S_P_Vendors__c> listSnP = new List<S_P_Vendors__c>();
        S_P_Vendors__c snp1 = new S_P_Vendors__c();
		snp1.Opportunity__c = opp.id;
		snp1.Qualified_for_S_P_Deal_Reg_Program__c = 'Yes';
		snp1.RecordTypeid = ibRTId;
		snp1.S_P_Vendors_Name__c = 'VMware';
        snp1.S_P_Deal_Status__c = 'Sent to Vendor';
        snp1.Ready_to_submit_to_vendor__c = 'Yes';
        snp1.Automated__c = true;
        snp1.City__c = 'u!nit t3st试';
        snp1.Contact_Name__c = 'u!nit t3st试';
        snp1.Customer_Decision_Maker__c = 'u!nit t3st试';
        snp1.Customer_Decision_Maker_Title__c = 'u!nit t3st试';
        snp1.Customer_Name__c = 'u!nit t3st试';
        snp1.Email__c = 'u!nit t3st试';
        snp1.Final_Approver_in_Customer_Organization__c = 'u!nit t3st试';
        snp1.Final_Approver_Title__c = 'u!nit t3st试';
        snp1.How_did_you_uncover_this_opportunity1__c = 'u!nit t3st试';
        snp1.Other__c = 'u!nit t3st试';
        snp1.Phone__c = 'u!nit t3st试';
        snp1.Role__c = 'u!nit t3st试';
        snp1.Ship_to_Address__c = 'u!nit t3st试';
        snp1.VMware_Are_you_the_Primary_Sales_Contact__c = 't3st试';
        snp1.VMware_Is_VMware_Sales_Engaged__c = 'u!nit t3st试';
        snp1.VMware_Job_Role__c = 'u!nit t3st试';
        snp1.VMware_Preferred_Channel__c = 'u!nit t3st试';
        snp1.VMware_Product_Mapping__c = 'u!nit t3st试';
        snp1.What_is_the_Customer_Initial_Order__c = 'u!nit t3st试';
        snp1.Is_VMware_Sales_Engaged__c = 'u!nit t3st试';
        snp1.Zip__c = 'u!nit t3st试';
        snp1.Sales_Rep_s_Phone__c = 'u!nit t3st试';
        snp1.VMware_Custom_Created_By__c = 'u!nit t3st试';

        S_P_Vendors__c snp2 = new S_P_Vendors__c(Opportunity__c = opp.id, Qualified_for_S_P_Deal_Reg_Program__c = 'Yes', 
                                                RecordTypeid = ibRTId, S_P_Vendors_Name__c = 'CommVault');
        listSnP.add(snp1);
        listSnP.add(snp2);
        try{
            insert listSnP;
        }catch(Exception ex){
            system.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
        }       

        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        
    }
    
}