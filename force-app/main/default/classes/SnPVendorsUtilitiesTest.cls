/*
 * Revision CR Number   Release No       Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0       13902     FY17-DCS-0202   18-Jan-2017       Ismail          Update SnPVendors roll up summary in Opportunity by invoke a flow
 * 2.0       14618     FY18-DCS-0802   10-Jul-2017       Jessie          Update Lead_on_Services__c of Opp Product with value of Dell_Leading_Professional_Services__c of S&P Vendor
 *3.0        16400     FY19-DCS-1002   29-Aug-2018       Swathi          testcoverage for SnPVendorsUtilities
*/


@isTest
public class SnPVendorsUtilitiesTest {

  
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
    
    
    static testMethod void testDeleteSnPVendors(){
      
        TriggerExecutionController.setSkipAllTriggers(true);
        SnPVendorsUtilities.isTest = true;
        ProcessFlowTriggerController.isTest = true;
        
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
        
         System.AssertEquals('testOpportunity', opp.Name);
        Id ibRTId= IdLookupUtils.getRecordTypeId('APC','S_P_Vendors__c',true);
        
        
        List<S_P_Vendors__c> listSnV = new List<S_P_Vendors__c>();
        listSnV.add(new S_P_Vendors__c(Opportunity__c = opp.id, Qualified_for_S_P_Deal_Reg_Program__c = 'Yes', RecordTypeid = ibRTId));
        listSnV.add(new S_P_Vendors__c(Opportunity__c = opp.id, Qualified_for_S_P_Deal_Reg_Program__c = 'Yes', RecordTypeid = ibRTId));
        listSnV.add(new S_P_Vendors__c(Opportunity__c = opp.id, Qualified_for_S_P_Deal_Reg_Program__c = 'Yes', RecordTypeid = ibRTId));
        insert listSnV;
        
        opp = [SELECT Qualified_Vendor_Count_Temp__c FROM Opportunity WHERE Id = :opp.Id];
        
        S_P_Vendors__c sV = [SELECT Id, Opportunity__c, Qualified_for_S_P_Deal_Reg_Program__c FROM S_P_Vendors__c WHERE Id = :listSnV[0].Id LIMIT 1];
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        Test.startTest();
         //TriggerExecutionController.setSkipOpportunityTriggers(true);
        delete sV;
        //TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.stopTest();
        
        opp = [SELECT Qualified_Vendor_Count_Temp__c FROM Opportunity WHERE Id = :opp.Id];
        
    }
  
    
    
    //v2.0 - start
    static testmethod void testUpdateSnPVendors(){
   
        TriggerExecutionController.setSkipAllTriggers(true);
        SnPVendorsUtilities.isTest = true;
        ProcessFlowTriggerController.isTest = true;
        
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
        S_P_Vendor_Partner_Information__c svpInfo2 = new S_P_Vendor_Partner_Information__c(
                                                S_P_Vendor_Automation_ID__c=svAuto.id,country__c='INDIA',
                                                Is_Active__c=true,Account_Name__c='test');
        Insert svpInfo2; 
        
        
        S_P_Vendor_Automation_Exception__c svAe = new S_P_Vendor_Automation_Exception__c(Field_API_Name__c = 'test__c',Is_Active__c=true, S_P_Vendor_Automation_Id__c =svAuto.Id);
        
        insert svAe;     
        
        
        Id ibRTId= IdLookupUtils.getRecordTypeId('VMware','S_P_Vendors__c',true);
                
        List<S_P_Vendors__c> listSnV = new List<S_P_Vendors__c>();
        listSnV.add(new S_P_Vendors__c( Opportunity__c = opp.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
         RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='InDiA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000));
          
          listSnV.add(new S_P_Vendors__c( Opportunity__c = opp.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='USD',
         RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='CommVault',Partner_ID__c=svpInfo1.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='INDIA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000));
        
    
        insert listSnV;
        
        opp = [SELECT Qualified_Vendor_Count_Temp__c FROM Opportunity WHERE Id = :opp.Id];
        
        S_P_Vendors__c sV = [SELECT Id, Opportunity__c, Qualified_for_S_P_Deal_Reg_Program__c FROM S_P_Vendors__c WHERE Id = :listSnV[0].Id LIMIT 1];
        S_P_Vendors__c sV1 = [SELECT Id, Opportunity__c, Qualified_for_S_P_Deal_Reg_Program__c FROM S_P_Vendors__c WHERE Id = :listSnV[1].Id LIMIT 1];
       
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        
        Product2 objProduct2 = new Product2 (Name = 'VMware', Product_Line_Desc__c = 'Test Product 2', IsActive = TRUE, SOC_Qualified__c = true, S_P_Registerable__c = true, Product_ID__c = 'Test_Prod_ID_1234');
        insert objProduct2 ;
        
        PricebookEntry pBE2 = new PricebookEntry (Product2ID=objProduct2.id, Pricebook2ID=pbk1, isActive=true, useStandardPrice=false, UnitPrice = 50);
        insert pBE2;
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid = opp.Id, pricebookEntryId = pBE2.id, Mrgn__c =6, Discount_off__c = 7, UnitPrice = 100,
                                                                    Quantity =2, Description = 'Line Description'); 
                                                                    
        insert testLineItem2;
        
        Test.startTest();
        
        sv.S_P_Deal_Status__c = 'Sent to Vendor';
        sV.Ready_to_submit_to_vendor__c = 'Yes';
        sV.Vendor_Tracking_Number__c = 'TestVenTrackNum001';
        sV.Dell_Leading_Professional_Services__c = 'Yes';
        sV.Product_Add_Success_Msg__c = 'SUCCESS: Product3PSId=' + testLineItem2.Id;
        update sV;
        sv1.S_P_Deal_Status__c ='Sent to Vendor';
        update sV1; 
      
        
        Test.stopTest();
        
        opp = [SELECT Qualified_Vendor_Count_Temp__c FROM Opportunity WHERE Id = :opp.Id];
        
    }
    
    static testmethod void testUpdateSnPVendors1(){

        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipSnPVendorTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        SnPVendorsUtilities.isTest = true;
        ProcessFlowTriggerController.isTest = true;
        
        S_P_Vendors__c snp;
        
    try{
     
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
                
              
          S_P_Vendors__c snpget = new S_P_Vendors__c(Opportunity__c = opp.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
         RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='INDIA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000);
          
                
          insert snpget;
          
          snp = [SELECT Id, Opportunity__c,City__c, Deal_Expiration_Date__c,S_P_Deal_Status__c,S_P_Vendors_Name__c,Qualified_for_S_P_Deal_Reg_Program__c FROM S_P_Vendors__c WHERE Id = :snpget.Id LIMIT 1];
      
        
        
        Product2 objProduct2 = new Product2 (Name = 'VMware', Product_Line_Desc__c = 'Test Product 2', IsActive = TRUE, SOC_Qualified__c = true, S_P_Registerable__c = true, Product_ID__c = 'Test_Prod_ID_1234');
        insert objProduct2 ;
        
        PricebookEntry pBE2 = new PricebookEntry (Product2ID=objProduct2.id, Pricebook2ID=pbk1, isActive=true, useStandardPrice=false, UnitPrice = 50);
        insert pBE2;
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid = opp.Id, pricebookEntryId = pBE2.id, Mrgn__c =6, Discount_off__c = 7, UnitPrice = 100,
                                                                    Quantity =2, Description = 'Line Description'); 
                                                                    
        insert testLineItem2;
         List<S_P_Vendors__c> listSnV1 = new List<S_P_Vendors__c>();
       }
       catch(Exception e)
       {
           system.debug('********************error' + e);
       }        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipSnPVendorTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
         
        Test.startTest();
        
        {
       try{
        
       snp.Deal_Expiration_Date__c = System.Now().Date().addDays(20);
       snp.S_P_Vendors_Name__c = 'VMware';  
       snp.CurrencyISOCode = 'COP';
       snp.Total_Net__c = 600000;
       snp.S_P_Deal_Status__c='Sent to Vendor';
       snp.City__c='TRENTONTRENTON qwe123@翻译!%';
       snp.Contact_Name__c = 'TRENTONTRENTON qwe123@翻译!%';
       snp.Customer_Decision_Maker__c = 'TRENTONTRENTON qwe123@翻译!%';
       snp.Customer_Decision_Maker_Title__c = 'TRENTONTRENTON qwe123@翻译!%'; 
       snp.Customer_Name__c = 'TRENTONTRENTON qwe123@翻译!%';
       snp.Email__c = 'TRENTONTRENTON qwe123@翻译!%';
       snp.Final_Approver_in_Customer_Organization__c ='qwe123@翻译';
       snp.Final_Approver_Title__c ='qwe123@翻译';
       snp.How_did_you_uncover_this_opportunity1__c='qwe123@翻译';
       snp.Other__c='qwe123@翻译';
       snp.Phone__c='1213123翻译';
       snp.Role__c ='qwe123@翻译';
      // snp.S_P_Vendors_Name__c='qwe123@翻译';
       snp.Ship_to_Address__c ='qwe123@翻译';
       snp.VMware_Are_you_the_Primary_Sales_Contact__c='qwe123@翻译';
       snp.VMware_Job_Role__c='qwe123@翻译';
       snp.VMware_Preferred_Channel__c='1213123翻译';
       snp.VMware_Product_Mapping__c='qwe123@翻译';
       snp.What_is_the_Customer_Initial_Order__c='qwe123@翻译';
       snp.Is_VMware_Sales_Engaged__c='qwe123@翻译';
       snp.Zip__c='qwe123@翻译';
       snp.Sales_Rep_s_Phone__c='qwe123@翻译';
       snp.VMware_Custom_Created_By__c='qwe123@翻译';
       snp.VMware_Is_VMware_Sales_Engaged__c='qwe123@翻译';
       
       update snp;
      
      
       
       
       }
        catch(Exception e){
        
       

        Boolean bexpectedExceptionThrown =  e.getMessage().contains('This field contains non-English character.') ? true : false;
        Boolean bexpectedExceptionThrown1 =  e.getMessage().contains('VMware accepts English characters only. Please review, update and save.') ? true : false;
               

        System.AssertEquals(bexpectedExceptionThrown, true);
        if(bexpectedExceptionThrown1 == true){
           System.AssertEquals(bexpectedExceptionThrown, true);
         }
        
        
       } 
      }
        Test.stopTest();
        //opp = [SELECT Qualified_Vendor_Count_Temp__c FROM Opportunity WHERE Id = :opp.Id];
        
    }
    
       //v2.0 - end
    
    
    static testmethod void testUpdateSnPVendors2(){

        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipSnPVendorTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        SnPVendorsUtilities.isTest = true;
        ProcessFlowTriggerController.isTest = true;
        
        S_P_Vendors__c snp;
        S_P_Vendors__c snp1;
        
    try{
     
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
                
              
          S_P_Vendors__c snpget = new S_P_Vendors__c(Opportunity__c = opp.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
         RecordTypeid = ibRTId,S_P_Deal_Status__c = 'Approved',Vendor_Approval_Number__c='ORAN121213',Vendor_Tracking_Number__c='ORTN1234',
          automated__c = true,Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',Deal_Expiration_Date__c=system.today(),
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='INDIA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000);
          
                
          insert snpget;
          
          S_P_Vendors__c snpget1 = new S_P_Vendors__c(Opportunity__c = opp.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
         RecordTypeid = ibRTId,S_P_Deal_Status__c = 'Sent to Vendor',
          automated__c = true,Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',Deal_Expiration_Date__c=system.today(),
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='INDIA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000);
           insert snpget1;
         
          snp = [SELECT Id, Opportunity__c,City__c, Deal_Expiration_Date__c,S_P_Deal_Status__c,S_P_Vendors_Name__c,Qualified_for_S_P_Deal_Reg_Program__c FROM S_P_Vendors__c WHERE Id = :snpget.Id LIMIT 1];
          
           snp1 = [SELECT Id, Opportunity__c,City__c, Deal_Expiration_Date__c,S_P_Deal_Status__c,S_P_Vendors_Name__c,Qualified_for_S_P_Deal_Reg_Program__c FROM S_P_Vendors__c WHERE Id = :snpget1.Id LIMIT 1];
      
         //SnPVendorsUtilities.updateSendNotification(null,snp);
        //  SnPVendorsUtilities.beforeInsertUpdate(snp);
        
        Product2 objProduct2 = new Product2 (Name = 'VMware', Product_Line_Desc__c = 'Test Product 2', IsActive = TRUE, SOC_Qualified__c = true, S_P_Registerable__c = true, Product_ID__c = 'Test_Prod_ID_1234');
        insert objProduct2 ;
        
        PricebookEntry pBE2 = new PricebookEntry (Product2ID=objProduct2.id, Pricebook2ID=pbk1, isActive=true, useStandardPrice=false, UnitPrice = 50);
        insert pBE2;
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid = opp.Id, pricebookEntryId = pBE2.id, Mrgn__c =6, Discount_off__c = 7, UnitPrice = 100,
                                                                    Quantity =2, Description = 'Line Description'); 
                                                                    
        insert testLineItem2;
         List<S_P_Vendors__c> listSnV1 = new List<S_P_Vendors__c>();
       }
       catch(Exception e)
       {
           system.debug('********************error' + e);
       }        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipSnPVendorTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
         
        Test.startTest();
        
        {
       try{
       snp.S_P_Deal_Status__c ='Sent to Vendor'; 
       snp.Deal_Expiration_Date__c = System.Now().Date().addDays(20);
      // snp.S_P_Vendors_Name__c = 'VMware';  
       snp.CurrencyISOCode = 'COP';
       snp.Total_Net__c = 600000;
              
       update snp;
      snp1.S_P_Deal_Status__c ='Pending';
      update snp1;
       
       
       }
        catch(Exception e){
        
       

        Boolean bexpectedExceptionThrown =  e.getMessage().contains('Use the \'Submit to Vendor\' button to submit the form.') ? true : false;
        //Boolean bexpectedExceptionThrown1 =  e.getMessage().contains('VMware accepts English characters only. Please review, update and save.') ? true : false;
               

        System.AssertEquals(bexpectedExceptionThrown, true);
        //if(bexpectedExceptionThrown1 == true){
          // System.AssertEquals(bexpectedExceptionThrown, true);
         //}
        
        
       } 
      }
        Test.stopTest();
        //opp = [SELECT Qualified_Vendor_Count_Temp__c FROM Opportunity WHERE Id = :opp.Id];
        
    }
    
   
}