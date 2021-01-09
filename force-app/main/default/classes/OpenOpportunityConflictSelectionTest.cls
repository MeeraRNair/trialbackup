/* 10 -12-2018         Haribabu.A     STORY 5907651 Removed reference for the field direct_account_name__c */
@isTest(SeeAllData=false)
private class OpenOpportunityConflictSelectionTest{
    
    static testMethod void OpenOpportunityConflictSelectionTest1() {
        string countryCode = 'US';
        string languageCode = 'ja';
         TriggerExecutionController.setSkipAllTriggers(true);   
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
        Id directDealRT = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true);
        Id partnerDealRT = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true);
        
        Account endUserAccount = createEndUserAccount();
        User partnerUser = createPartnerUser(countryCode, languageCode);
        createExistingDirectDeals(endUserAccount,directDealRT);        
        createExistingPartnerDeals(endUserAccount,partnerDealRT,partnerUser.Id); 
          
        
         Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=endUserAccount.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 ); 
         TriggerExecutionController.setSkipAllTriggers(true);  
          insert testOppty;
      

        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod1 = new Product2(Name = 'Laptop 250',Channel_Product_LOB__c = 'test1',
            Family = 'Hardware',product_id__c = '56226645');
        insert prod1;
                
        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice1.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical');
           
        
        database.insert(testLineItem1,false);
        
        Product2 prod2 = new Product2(Name = 'Laptop X200',Channel_Product_LOB__c = 'test1,test2',
            Family = 'Hardware',product_id__c = '566645988');
        insert prod2;
                
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice2.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical');
           
        
        database.insert( testLineItem2,false);
                                                     
        ApexPages.StandardController std=new ApexPages.StandardController(testOppty);
        Test.setCurrentPageReference(new PageReference('Page.OpenOpportunityConflictSelection')); 
        System.currentPageReference().getParameters().put('id', testOppty.Id);
        VFCntrl_OpenOpportunityConflictSelection con =new VFCntrl_OpenOpportunityConflictSelection(std);
        
        con.wcList[0].selected =true;
        con.SelectedConflicts();
        con.wcList[1].selected =true;
        con.SelectedConflicts();
        con.SaveFunction();
        con.CancelFunction();            
        

         
        OpportunityApprovalActionPannelExt con2 = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(testOppty)); 
    }
    
     static testMethod void OpenOpportunityConflictSelectionTest2() {
        
        string countryCode = 'US';
        string languageCode = 'ja';
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
        Id directDealRT = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true);
        Id partnerDealRT = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true);
        TriggerExecutionController.setSkipAllTriggers(true);
        Account endUserAccount = createEndUserAccount();
        User partnerUser = createPartnerUser(countryCode, languageCode);
        createExistingDirectDeals(endUserAccount,directDealRT);        
        createExistingPartnerDeals(endUserAccount,partnerDealRT,partnerUser.Id);        
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=endUserAccount.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 ); 
        insert testOppty;

        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod1 = new Product2(Name = 'Laptop 250',Channel_Product_LOB__c = 'test1, test2',
            Family = 'Hardware',product_id__c = '56664590099');
        insert prod1;
                
        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice1.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical');
           
        
        insert testLineItem1;
        
        Product2 prod2 = new Product2(Name = 'Laptop X200',Channel_Product_LOB__c = 'test1,test2',
            Family = 'Hardware',product_id__c = '5689986645');
        insert prod2;
                
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        integer i;
        list<Opportunitylineitem> testlineitemList = new list<Opportunitylineitem>();
        
        for(i=0;i<20;i++){
            OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice2.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical');
           testlineitemList.add(testLineItem2);  
         }  
        
        insert testlineitemList;
                                                     
        PageReference pageRef = Page.OpenOpportunityConflictSelection;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',testOppty.Id);
        VFCntrl_OpenOpportunityConflictSelection con = new VFCntrl_OpenOpportunityConflictSelection (new ApexPages.StandardController(testOppty));
        con.wcList[0].selected =false;
        con.SelectedConflicts();
        con.wcList[1].selected =true;
        con.SelectedConflicts();
        con.SaveFunction();
        con.CancelFunction();
         
        
        OpportunityApprovalActionPannelExt con2 = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(testOppty)); 
    }
    
    static testMethod void OpenOpportunityConflictSelectionTest3() {
        
        string countryCode = 'US';
        string languageCode = 'ja';
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
        Id directDealRT = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true);
        Id partnerDealRT = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true);
        TriggerExecutionController.setSkipAllTriggers(true);
        Account endUserAccount = createEndUserAccount();
        User partnerUser = createPartnerUser(countryCode, languageCode);
        createExistingDirectDeals(endUserAccount,directDealRT);        
        createExistingPartnerDeals(endUserAccount,partnerDealRT,partnerUser.Id);        
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=endUserAccount.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 ); 
        insert testOppty;

        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod1 = new Product2(Name = 'Laptop 250',Channel_Product_LOB__c = 'test1',
            Family = 'Hardware',product_id__c = '56664875');
        insert prod1;
                
        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice1.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical');
           
        
        insert testLineItem1;
        
        Product2 prod2 = new Product2(Name = 'Laptop X200',Channel_Product_LOB__c = 'test1',
            Family = 'Hardware',product_id__c = '5666499665');
        insert prod2;
                
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        integer i;
        list<Opportunitylineitem> testlineitemList = new list<Opportunitylineitem>();
        
       
       OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice2.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical');
           
        insert testLineItem2 ;
                                                     
        PageReference pageRef = Page.OpenOpportunityConflictSelection;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',testOppty.Id);
        VFCntrl_OpenOpportunityConflictSelection con = new VFCntrl_OpenOpportunityConflictSelection (new ApexPages.StandardController(testOppty));
        /*con.wcList[0].selected =true;
        con.SelectedConflicts();
        con.wcList[2].selected =true;
        con.SelectedConflicts();*/
        con.SaveFunction();
        con.CancelFunction();
       
         
        
        OpportunityApprovalActionPannelExt con2 = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(testOppty)); 
    }
    
     private static Account createEndUserAccount(){
         Id endUserAccountRT = [select Name from RecordType where Name ='End-User Account' limit 1].Id;
         Account EUacc = new Account();
         EUacc.Name = 'Test Account';
         EUacc.Participating_in_LOB_Program__c = true;
         EUacc.RecordTypeId = endUserAccountRT;
         EUacc.Account_Country__c = 'UNITED STATES';
         EUacc.ShippingStreet = '12';
         EUacc.ShippingCity = 'testStreet';
         EUacc.ShippingState = 'testTexas';
         EUacc.ShippingPostalCode = '1324';
         EUacc.Tax_Registration_Number__c = '124214';
         EUacc.Partner_Type__c = 'Distributor (GCC)';
         insert EUacc;
         return EUacc;
     }
      
     
     
     private static User createPartnerUser(string accountCountryCode, string userLanguageCode){
        string accountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'PARTNER ACCOUNT'][0].Id;
        Account acc = new Account(Name = 'Partner Account', Account_Country_Code__c = accountCountryCode, 
                                  Is_GTM_Partner__c = true, RecordTypeId = accountRTId);
        insert acc;
       acc.IsPartner = true;
       Update acc;
        Contact con = new Contact(AccountId = acc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT');
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        string proid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = userLanguageCode,
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = proid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        return u;
    }

    private static void createExistingDirectDeals(Account EUacc,string DealRTId){
        
        TriggerExecutionController.setSkipAllTriggers(true);     
        
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=0;i<=20;i++){
         Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty'+i, 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 ); 
            oppList.add(testOppty);                       
        }    
        try{    
        insert oppList; 
     }
     catch(Exception e){}
        Id pricebookId = Test.getStandardPricebookId();
        
         Product2 prod1 = new Product2(Name = 'Laptop 250',Channel_Product_LOB__c = 'test',
            Family = 'Hardware',Product_id__c= '23231112');
            
        insert prod1;
               
               
        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        Product2 prod2 = new Product2(Name = 'Laptop X200',Channel_Product_LOB__c = 'test1,test2',
            Family = 'Hardware', product_id__c='34298993244');
        insert prod2;
                
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for(Opportunity testOppty: oppList){
            OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice1.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );
            oliList.add(testLineItem);  
            
            OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice2.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );
            oliList.add(testLineItem2);                                                                  
        }
        try{
        insert oliList; 
        }
        catch(exception e){}                                                                        
    } 
    
    private static void createExistingPartnerDeals(Account EUacc,string DealRTId,string partnerUserId){
       System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs; 
      TriggerExecutionController.setSkipAllTriggers(true);
      List<Opportunity> oppList = new List<Opportunity>();
      for(integer i=0;i<=20;i++){
         Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty'+i, 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                ownerid = partnerUserId,
                                                CloseDate = System.Today() + 30 ); 
            oppList.add(testOppty);                       
        }
        insert oppList;
        
        Id pricebookId = Test.getStandardPricebookId();
        
         Product2 prod1 = new Product2(Name = 'Laptop 250',Channel_Product_LOB__c = 'test',
            Family = 'Hardware',product_id__c = '56556645');
        insert prod1;
                
        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        Product2 prod2 = new Product2(Name = 'Laptop X200',Channel_Product_LOB__c = 'test1,test2',
            Family = 'Hardware',product_id__c = '533366645');
        insert prod2;
                
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for(Opportunity testOppty: oppList){
            OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice1.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );
            oliList.add(testLineItem);  
            
            OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=standardPrice2.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );
            oliList.add(testLineItem2);                                                                  
        }
        TriggerExecutionController.setSkipAllTriggers(true);
        Database.insert( oliList,false);
        
    }
    
    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
    
 

}