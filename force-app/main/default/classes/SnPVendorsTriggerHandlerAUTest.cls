@IsTest
public class SnPVendorsTriggerHandlerAUTest {
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
    
    static testmethod void testUpdateSnPVendors1(){

        TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipSnPVendorTriggers(true);
       // SnPVendorsUtilities.isTest = true;
       // ProcessFlowTriggerController.isTest = true;
        String strMockMetaData = '';

         Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "S_P_Vendors__c", "Class_Name__c": "SnPVendorsTriggerHandlerAU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;

            
         Opportunity opp = new Opportunity(Name = 'testOpportunity',
                                          StageName = 'Plan - 1%',    
                                          CloseDate = System.today(),
                                          CurrencyIsoCode = 'USD',
                                          Qualified_Vendor_Count_Temp__c = 1
                                         );
                                                                       
        insert opp;
        Id pbk1 = Test.getStandardPricebookId();
        
        Product2 objProduct = new Product2 (Name = 'VMware', Product_Line_Desc__c = 'Test Product', IsActive = TRUE, SOC_Qualified__c = true, S_P_Registerable__c = true, Product_ID__c = 'Test_Prod_ID_123');
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
                
        S_P_Vendor_Automation_Exception__c svAe = new S_P_Vendor_Automation_Exception__c(Field_API_Name__c = 'test__c',Is_Active__c=true, S_P_Vendor_Automation_Id__c =svAuto.Id);
        
        insert svAe;        
               
        Id ibRTId= IdLookupUtils.getRecordTypeId('VMware','S_P_Vendors__c',true);
                              
        S_P_Vendors__c snpget = new S_P_Vendors__c(Opportunity__c = opp.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='USD',
                                                  RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Rejected',  Rejection_Reason__c = 'unit test',
                                                  automated__c = true,S_P_Vendors_Name__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
                                                  How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
                                                  Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
                                                  Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
                                                  Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='INDIA',City__c='sada',Zip__c='awqwe323',
                                                  Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
                                                  Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
                                                  Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
                                                  Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center', Product_Add_Success_Msg__c='Product3PSId=01t5B0000038MTZAAA',
                                                  First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000);
               
        insert snpget;
          
        S_P_Vendors__c snp = [SELECT Id, Opportunity__c,City__c, Deal_Expiration_Date__c,S_P_Deal_Status__c,S_P_Vendors_Name__c,
                              Qualified_for_S_P_Deal_Reg_Program__c, Product_Add_Success_Msg__c 
                              FROM S_P_Vendors__c WHERE Id = :snpget.Id LIMIT 1];      
        snp.S_P_Deal_Status__c = 'Sent to Vendor';
		snp.Product_Add_Success_Msg__c = 'Product3PSId=01t5B0000038MTZBBB';
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipSnPVendorTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        Test.startTest();
        try{
          update snp;
        }catch(Exception ex){
          system.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
        }
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        //opp = [SELECT Qualified_Vendor_Count_Temp__c FROM Opportunity WHERE Id = :opp.Id];
        
    }
}