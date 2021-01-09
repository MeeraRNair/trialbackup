/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 6.0      6637336    FY20-DCS-1002     4-sep-2019     Anusha         Story 6637336  08037 - S&P Deal Reg Link in Product info(Autopopulating S&PVendor Field Values into Opportunity Line Item)  
*/
@isTest
Private class VmwareSNPVendorDatatoOLIAITest { 

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
    static testMethod void testRestrictNewlineItemsforApproveddealstwo1() {

        // 7.4 To create customsettings
//        insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
     
        TriggerExecutionController.setSkipAllTriggers(true);
     String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'TriggerHandler' => new List<Boolean>{false, false, false, true, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "VmwareSNPVendorDatatoOLIAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account', RecordTypeId = accRTId);
        TriggerExecutionController.setSkipAllTriggers(true); 
        // GlobalVariables.BYPASS_ACCOUNT_TRIGGER = true;        
        insert testAccount;        
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        system.assertEquals('testing',newCont.Last_Operation_Performed__c );
         insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='9966513', 
                            isActive = TRUE,
                           //IsPortalEnabled = TRUE,
                            //AccountId = testAccount.Id,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
           // List<Opportunity> lstOpp =new List<Opportunity>();
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                          //      Engagement_Type__c = 'Public Tender',
                                                RecordTypeID = DealRTId,
                                               // Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                           //     Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );

        System.runAs(PartnerUser){
        //  TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOppty;
            system.debug(LoggingLevel.Error,'@@testOppty@@@'+testOppty);
        }
 
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     

        Product2 newPrdcttwo = new Product2(Name = 'VMware',
                                         Product_Line_Desc__c = 'VMware',Product_ID__c='test',
                                         S_P_Registerable__c = true,
                                          Channel_Product_LOB__c = '',
                                      //    DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        

        listProduct2.add(newPrdcttwo);
        
        insert listProduct2;                                  
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        

        PricebookEntry pBEtwo = new PricebookEntry (Product2ID=newPrdcttwo.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEtwo);
                                                
        insert listPricebook;
        //TriggerExecutionController.setSkipAllTriggers(false);
        List<OpportunityLineItem> listOppLineitemToInsert = new List<OpportunityLineItem>();
    
        OpportunityLineItem  testLineItemtwo = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBEtwo.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        OpportunityLineItem  testLineItemone = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBEtwo.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                          
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
                                                                     
        listOppLineitemToInsert.add(testLineItemtwo);
        system.debug(LoggingLevel.Error,'@@@limits @@'+ limits.getlimitqueries() );
        S_P_Vendor_Automation__c svAuto = new S_P_Vendor_Automation__c(
                                            Vendor_Name__c='vmware',Is_Active__c=true,Expiration_Date__c=system.today(),
                                            Automation_Type__c='Full Automation');
            Insert svAuto;  
        S_P_Vendor_Partner_Information__c svpInfo = new S_P_Vendor_Partner_Information__c(Segment__c='CHANNEL',
                                                S_P_Vendor_Automation_ID__c=svAuto.id,country__c='INDIA',
                                                Is_Active__c=true,Account_Name__c='test');
       insert svpInfo;
        Id ibRTId= IdLookupUtils.getRecordTypeId('VMware','S_P_Vendors__c',true);
                
        List<S_P_Vendors__c> listSnV = new List<S_P_Vendors__c>();
        listSnV.add(new S_P_Vendors__c( Opportunity__c = testOppty.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
         RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='VMware',S_P_Vendors_Name_Hidden__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='InDiA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center', 
          Vendor_Tracking_Number__c = 'TestVenTrackNum001',Vendor_Approval_Number__c = 'TestVenApprNum003',Rejection_Reason__c = 'Test',Distributor_Name__c = 'Test',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000));
          insert  listSnV;   
          
          S_P_Vendors__c snpObj = new S_P_Vendors__c( Opportunity__c = testOppty.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
          RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='VMware',S_P_Vendors_Name_Hidden__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='InDiA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center', 
          Vendor_Tracking_Number__c = 'TestVenTrackNum001',Vendor_Approval_Number__c = 'TestVenApprNum003',Rejection_Reason__c = 'Test',Distributor_Name__c = 'Test',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000);
          insert  snpObj;  
          
          S_P_Vendors__c snpObj1 = new S_P_Vendors__c( Opportunity__c = testOppty.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
          RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(20) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='VMware',S_P_Vendors_Name_Hidden__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='InDiA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center', 
          Vendor_Tracking_Number__c = 'TestVenTrackNum0011',Vendor_Approval_Number__c = 'TestVenApprNum0031',Rejection_Reason__c = 'Test1',Distributor_Name__c = 'Test1',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='OEA/Alliance',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000);
          insert  snpObj1;  
          
          Map<Id, sObject> mapOld = new Map<Id, sObject>();
          mapOld.put(snpObj.id, snpObj);
          
          Map<Id, S_P_Vendors__c> mapOld1 = new Map<Id, S_P_Vendors__c>();
          mapOld1.put(listSnV[0].id, snpObj1);
          
           Map<String, S_P_Vendors__c> mapOld2 = new Map<String, S_P_Vendors__c>();
          mapOld2.put('VMware',snpObj);
         
          Set<Id> oppIt= new Set<Id>();
          oppIt.add(testOppty.id);
        Test.startTest();      
        System.runAs(PartnerUser){
            //try{
                insert listOppLineitemToInsert ;
                
                VmwareSNPVendorDatatoOLI.afterUpdate(listSnV,mapOld1,listOppLineitemToInsert,false);
                VMwareSnPTriggerHandlerAU  oppHandler = New VMwareSnPTriggerHandlerAU();
                oppHandler.handleAfterUpdate(listSnV,mapOld1);
          //  }catch(Exception e){
           // }
        }   
        Test.stopTest(); 
    
        TriggerExecutionController.setSkipAllTriggers(false);
    }   

  static testMethod void testRestrictNewlineItemsforApproveddealstwo2() {

        // 7.4 To create customsettings
//        insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
     
        TriggerExecutionController.setSkipAllTriggers(true);
     String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'TriggerHandler' => new List<Boolean>{false, false, false, true, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "VmwareSNPVendorDatatoOLIAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account', RecordTypeId = accRTId);
        TriggerExecutionController.setSkipAllTriggers(true); 
        // GlobalVariables.BYPASS_ACCOUNT_TRIGGER = true;        
        insert testAccount;        
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        system.assertEquals('testing',newCont.Last_Operation_Performed__c );
         insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='9966513', 
                            isActive = TRUE,
                           //IsPortalEnabled = TRUE,
                            //AccountId = testAccount.Id,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
           // List<Opportunity> lstOpp =new List<Opportunity>();
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                          //      Engagement_Type__c = 'Public Tender',
                                                RecordTypeID = DealRTId,
                                                //Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                           //     Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );

        System.runAs(PartnerUser){
        //  TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOppty;
            system.debug(LoggingLevel.Error,'@@testOppty@@@'+testOppty);
        }
 
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     

        Product2 newPrdcttwo = new Product2(Name = 'VMware',
                                         Product_Line_Desc__c = 'VMware',Product_ID__c='test',
                                         S_P_Registerable__c = true,
                                          Channel_Product_LOB__c = '',
                                      //    DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        

        listProduct2.add(newPrdcttwo);
        
        insert listProduct2;                                  
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        

        PricebookEntry pBEtwo = new PricebookEntry (Product2ID=newPrdcttwo.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEtwo);
                                                
        insert listPricebook;
        //TriggerExecutionController.setSkipAllTriggers(false);
        List<OpportunityLineItem> listOppLineitemToInsert = new List<OpportunityLineItem>();
    
        OpportunityLineItem  testLineItemtwo = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBEtwo.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                     
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        OpportunityLineItem  testLineItemone = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBEtwo.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                     
                                                          
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
                                                                     
        listOppLineitemToInsert.add(testLineItemtwo);
        system.debug(LoggingLevel.Error,'@@@limits @@'+ limits.getlimitqueries() );
        S_P_Vendor_Automation__c svAuto = new S_P_Vendor_Automation__c(
                                            Vendor_Name__c='vmware',Is_Active__c=true,Expiration_Date__c=system.today(),
                                            Automation_Type__c='Full Automation');
            Insert svAuto;  
        S_P_Vendor_Partner_Information__c svpInfo = new S_P_Vendor_Partner_Information__c(Segment__c='CHANNEL',
                                                S_P_Vendor_Automation_ID__c=svAuto.id,country__c='INDIA',
                                                Is_Active__c=true,Account_Name__c='test');
       insert svpInfo;
        Id ibRTId= IdLookupUtils.getRecordTypeId('VMware','S_P_Vendors__c',true);
                
        List<S_P_Vendors__c> listSnV = new List<S_P_Vendors__c>();
        listSnV.add(new S_P_Vendors__c( Opportunity__c = testOppty.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
         RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='VMware',S_P_Vendors_Name_Hidden__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='InDiA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center', 
          Vendor_Tracking_Number__c = 'TestVenTrackNum001',Vendor_Approval_Number__c = 'TestVenApprNum003',Rejection_Reason__c = 'Test',Distributor_Name__c = 'Test',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000));
          insert  listSnV;   
          
          S_P_Vendors__c snpObj = new S_P_Vendors__c( Opportunity__c = testOppty.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
         RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='VMware',S_P_Vendors_Name_Hidden__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='InDiA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center', 
          Vendor_Tracking_Number__c = 'TestVenTrackNum001',Vendor_Approval_Number__c = 'TestVenApprNum003',Rejection_Reason__c = 'Test',Distributor_Name__c = 'Test',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000);
          insert  snpObj;   
          
          Map<Id, sObject> mapOld = new Map<Id, sObject>();
          mapOld.put(snpObj.id, snpObj);
          
        Test.startTest();      
        System.runAs(PartnerUser){
            //try{
                insert listOppLineitemToInsert ;
                listOppLineitemToInsert = new List<OpportunityLineItem>();
    
                OpportunityLineItem  testLineItemtwo2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                            pricebookEntryId=pBEtwo.id,
                                                                            Mrgn__c =6,
                                                                            Discount_off__c = 7,
                                                                            UnitPrice = 100,
                                                                            Quantity =2,
                                                                            
                                                                            Description = 'Line Description',
                                                                            Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                            ); 
                OpportunityLineItem  testLineItemone1 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                            pricebookEntryId=pBEtwo.id,
                                                                            Mrgn__c =6,
                                                                            Discount_off__c = 7,
                                                                            UnitPrice = 100,
                                                                            Quantity =2,
                                                                            
                                                                            Description = 'Line Description',
                                                                            Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                            ); 
                                                                             
                listOppLineitemToInsert.add(testLineItemtwo);
                VmwareSNPVendorDatatoOLI.afterUpdate(null,null,listOppLineitemToInsert,true);
                 VMWareOLITriggerHandlerBI  oliHandler = New VMWareOLITriggerHandlerBI();
                oliHandler.handleBeforeInsert(listOppLineitemToInsert);
                
          //  }catch(Exception e){
           // }
        }   
        Test.stopTest(); 
    
        
    }   
        static testMethod void testRestrictNewlineItemsforApproveddealstwo3() {

        // 7.4 To create customsettings
//        insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
     
        TriggerExecutionController.setSkipAllTriggers(true);
     String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'TriggerHandler' => new List<Boolean>{false, false, false, true, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "VmwareSNPVendorDatatoOLIAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account', RecordTypeId = accRTId);
        TriggerExecutionController.setSkipAllTriggers(true); 
        // GlobalVariables.BYPASS_ACCOUNT_TRIGGER = true;        
        insert testAccount;        
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        system.assertEquals('testing',newCont.Last_Operation_Performed__c );
         insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='9966513', 
                            isActive = TRUE,
                           //IsPortalEnabled = TRUE,
                            //AccountId = testAccount.Id,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
           // List<Opportunity> lstOpp =new List<Opportunity>();
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                          //      Engagement_Type__c = 'Public Tender',
                                                RecordTypeID = DealRTId,
                                                //Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                           //     Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );

        System.runAs(PartnerUser){
        //  TriggerExecutionController.setSkipOpportunityTriggers(true);
            insert testOppty;
            system.debug(LoggingLevel.Error,'@@testOppty@@@'+testOppty);
        }
 
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     

        Product2 newPrdcttwo = new Product2(Name = 'VMware',
                                         Product_Line_Desc__c = 'VMware',Product_ID__c='test',
                                         S_P_Registerable__c = true,
                                          Channel_Product_LOB__c = '',
                                      //    DGR_Eligible__c = 'Yes',
                                         IsActive = TRUE);
        

        listProduct2.add(newPrdcttwo);
        
        insert listProduct2;                                  
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        

        PricebookEntry pBEtwo = new PricebookEntry (Product2ID=newPrdcttwo.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBEtwo);
                                                
        insert listPricebook;
        //TriggerExecutionController.setSkipAllTriggers(false);
        List<OpportunityLineItem> listOppLineitemToInsert = new List<OpportunityLineItem>();
    
        OpportunityLineItem  testLineItemtwo = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBEtwo.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        OpportunityLineItem  testLineItemone = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=pBEtwo.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                          
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
                                                                     
        listOppLineitemToInsert.add(testLineItemtwo);
        system.debug(LoggingLevel.Error,'@@@limits @@'+ limits.getlimitqueries() );
        S_P_Vendor_Automation__c svAuto = new S_P_Vendor_Automation__c(
                                            Vendor_Name__c='vmware',Is_Active__c=true,Expiration_Date__c=system.today(),
                                            Automation_Type__c='Full Automation');
            Insert svAuto;  
        S_P_Vendor_Partner_Information__c svpInfo = new S_P_Vendor_Partner_Information__c(Segment__c='CHANNEL',
                                                S_P_Vendor_Automation_ID__c=svAuto.id,country__c='INDIA',
                                                Is_Active__c=true,Account_Name__c='test');
       insert svpInfo;
        Id ibRTId= IdLookupUtils.getRecordTypeId('VMware','S_P_Vendors__c',true);
                
        List<S_P_Vendors__c> listSnV = new List<S_P_Vendors__c>();
        listSnV.add(new S_P_Vendors__c( Opportunity__c = testOppty.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
         RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='VMware',S_P_Vendors_Name_Hidden__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='InDiA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center', 
          Vendor_Tracking_Number__c = 'TestVenTrackNum001',Vendor_Approval_Number__c = 'TestVenApprNum003',Rejection_Reason__c = 'Test',Distributor_Name__c = 'Test',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000));
          insert  listSnV;   
          
          S_P_Vendors__c snpObj = new S_P_Vendors__c( Opportunity__c = testOppty.id,Qualified_for_S_P_Deal_Reg_Program__c = 'Yes',CurrencyISOCode='HUF',
          RecordTypeid = ibRTId,Deal_Expiration_Date__c=System.Now().Date().addDays(30) ,S_P_Deal_Status__c = 'Pending',
          automated__c = true,S_P_Vendors_Name__c='VMware',S_P_Vendors_Name_Hidden__c='VMware',Partner_ID__c=svpInfo.id,Customer_Decision_Maker__c='test',
          How_did_you_uncover_this_opportunity1__c='tets',Sales_Rep_s_Phone__c='98842837',SnS_Type__c='Basic',SnS_Term__c='3 year',
          Opportunity_Source__c=' VMware Generated Lead',Customer_Market_Segment__c=' Commercial',
          Customer_Name__c='tets',Contact_Name__c='qweq',Phone__c='123112312',Email__c='test@dell.com',Customer_Domain__c='tets',
          Role__c='uasydsa',Ship_to_Address__c='asdad',Country__c='InDiA',City__c='sada',Zip__c='awqwe323',
          Does_the_Customer_have_Approved_Budget__c='Yes',CIO_Sponsorship__c='Yes',Is_VMware_Sales_Engaged__c='1231asdaa',
          Does_the_Customer_have_Shared_Storage__c='Yes',Project_Focus__c='Desktop Management',CustomerTryingToSolve__c='1213asd',
          Number_of_Servers_in_Organization__c='51-100',Number_of_Desktops_in_Organization__c=' 1001-2500',
          Value_Selling_Activities__c='Assessment NSX',Solution_Initiative__c='Data Center', 
          Vendor_Tracking_Number__c = 'TestVenTrackNum001',Vendor_Approval_Number__c = 'TestVenApprNum003',Rejection_Reason__c = 'Test',Distributor_Name__c = 'Test',
          First_Activity_for_this_Deal_MM_DD_YYYY__c=system.today(),SnP_or_OEM__c='S&P',Ready_to_submit_to_vendor__c='Yes',Total_NET__c =90000);
          insert  snpObj;  
           
          
          Map<Id, sObject> mapOld = new Map<Id, sObject>();
          mapOld.put(snpObj.id, snpObj);
          
          Map<Id, S_P_Vendors__c> mapOld1 = new Map<Id, S_P_Vendors__c>();
          mapOld1.put(listSnV[0].id, snpObj);
          
         
          Set<Id> oppIt= new Set<Id>();
          oppIt.add(testOppty.id);
        Test.startTest();      
        System.runAs(PartnerUser){
            //try{
                insert listOppLineitemToInsert ;
                
                VmwareSNPVendorDatatoOLI.afterUpdate(listSnV,mapOld1,listOppLineitemToInsert,false);
                VMwareSnPTriggerHandlerAU  oppHandler = New VMwareSnPTriggerHandlerAU();
                oppHandler.handleAfterUpdate(listSnV,mapOld1);
          //  }catch(Exception e){
           // }
        }   
        Test.stopTest(); 
    
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
}