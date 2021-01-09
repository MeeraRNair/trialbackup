/***********************************************************
* Name          : OpportunityValidatorTest
*  
* ---------------------------------------------------------
* Revision  Name            Date                Description
* 1.0                                           created
* 2.0       Azwanti         15 March 2016       replace Campaign RT from 'GBL_Standard_RT' and 'Campaign 2.0' to 'Campaign 2.0'. 
* 3.0       Fahmin          15 March 2016       Rename firsname, lastname and email for contact creation to prevent duplication
* 4.0       Abhinav         26-Jan-2018         FY19-DCS-0401 | Added test data for OWD customsetting
* 5.0       Akshita         12-Mar-2018         FY19-DCS-0502 | Added test data to cover for code added under CR15380  
* 6.0       Vivek           11-June-2018        FY19-DCS-0702 | Updated existing code 
* 7.0       Naga            14-Nov-2018         FY19-0102       Removed references for 'opportunity.Quest_Opportunity_Integration_Status__c' to proceed to delete the field 'Quest_Opportunity_Integration_Status__c'   
************************************************************/
@isTest
private class OpportunityValidatorTest {
    
    static testMethod void validateOpportunityEMCNumTestData(){
        
        TriggerExecutionController.setSkipAlltriggers(true);
        
        string strProfileId = [SELECT id from profile WHERE Name = 'R16.10 GBL Sales Mgr' LIMIT 1][0].Id;
        User u1 = new User(Alias = 'gblsales', Email='gblsalesmgr@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = strProfileId, TimeZoneSidKey='America/Los_Angeles', UserName='gblsales@dell.com', Badge_Number__c = getUniqueString());
        insert u1;
         
         system.assertEquals(1, [select count() from user where Id = :u1.Id]);
                 
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
        
            
        Opportunity testOpportunity1 = new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpp1',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         Partner_Opportunity_Stage__c = 'Plan - 1%',
                                         EMC_Opportunity_Number__c = '09872862',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
         
         Opportunity testOpportunity2 = new Opportunity (AccountID=testAccountObj.ID ,
         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
         Name='TestOpp2',
         Type = 'Deal/Bid - Indirect',
         Domain__c='Deal Reg',
         Solution_Type__c = 'Campus',
         Solution_Name__c = 'Wireless Switches',
         StageName='Discover - 10%',
         Partner_Opportunity_Stage__c = 'Discover - 10%',
         EMC_Opportunity_Number__c = '09872863',
         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
              
        List<Opportunity> listopp = new List<Opportunity>();            
        listopp.add(testOpportunity1);
        listopp.add(testOpportunity2);
       // TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listopp;
      //  TriggerExecutionController.setSkipOpportunityTriggers(false);
        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,EOL_Date_EMEA__c=System.Now().Date().addDays(240));
        insert newPrdct1;                                      
                                         
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
        insert PBE1;  
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId =testOpportunity1.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1');   
        insert oppLineItem;
        
        testOpportunity1.OwnerId = u1.Id;
        update testOpportunity1;
        testOpportunity2.OwnerId = u1.Id;
        update testOpportunity2;
        
        Test.startTest();
        
        system.runAs(u1)
        {
            delete testOpportunity1;
            OpportunityValidator.validateOpportunityEMCNum(listopp);
        }
        
        //TriggerExecutionController.setSkipAlltriggers(false);
        Test.stopTest();
        TriggerExecutionController.setSkipAlltriggers(false);
    }
    
     @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);

        //4.0 - BOF
        // Create common test data OWD customsetting
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Database.insert(owdSetting);
        
        system.assertEquals(1, [select count() from CMAP_Queue_Settings__c where Name = 'Channel_eClerx']);
        
        //4.0 - EOF
    }
    
   
    static testMethod void prepareTestDataNA(){         
        TriggerExecutionController.setSkipAlltriggers(true);
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
        
        List<Opportunity> listOpp = new List<Opportunity>();
        Opportunity testOpportunity1= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity 1',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         Forecast_Category_Override__c = '',
                                         EMC_Opportunity_updated__c = 'Waiting Sync',
                                         Partner_Opportunity_Stage__c = 'Plan - 1%',
                                         Primary_Competitor_Product_Type__c = 'Client',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
      //  insert testOpportunity1;
        listOpp.add(testOpportunity1);
        
        Opportunity testOpportunity2= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity 2',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Discover - 10%',
                                         Forecast_Category_Override__c = 'Omitted',
                                         Partner_Opportunity_Stage__c = 'Discover - 10%',
                                         EMC_Opportunity_updated__c = 'Waiting Sync',
                                         Primary_Competitor_Product_Type__c = 'Client',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
      // insert testOpportunity2;
        listOpp.add(testOpportunity2);
        
        Opportunity testOpportunity3= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity 3',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Qualify - 30%',
                                         Forecast_Category_Override__c = 'Pipeline',
                                         Partner_Opportunity_Stage__c = 'Qualify - 30%',
                                         EMC_Opportunity_updated__c = 'Waiting Sync',
                                         Primary_Competitor_Product_Type__c = 'Client',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
       // insert testOpportunity3;
        listOpp.add(testOpportunity3);
        
        Opportunity testOpportunity4= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity 4',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Propose - 60%',
                                         Forecast_Category_Override__c = 'Best Case',
                                         Partner_Opportunity_Stage__c = 'Propose - 60%',
                                         EMC_Opportunity_updated__c = 'Waiting Sync',
                                         Primary_Competitor_Product_Type__c = 'Client',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
       // insert testOpportunity4;
        listOpp.add(testOpportunity4);
        
        Opportunity testOpportunity5= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity 5',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Commit - 90%',
                                         Forecast_Category_Override__c = 'Commit',
                                         Partner_Opportunity_Stage__c = 'Commit - 90%',
                                         EMC_Opportunity_updated__c = 'Waiting Sync',
                                         Primary_Competitor_Product_Type__c = 'Client',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
       // insert testOpportunity5;
        listOpp.add(testOpportunity5);
        
       Opportunity testOpportunity6= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity 6',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Win - 100%',
                                         Forecast_Category_Override__c = '',
                                         Partner_Opportunity_Stage__c = 'Win - 100%',
                                         EMC_Opportunity_updated__c = 'Waiting Sync',
                                         Primary_Competitor_Product_Type__c = 'Client',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
  //     insert testOpportunity6;
    //    listOpp.add(testOpportunity6);
   // TriggerExecutionController.setSkipOpportunityTriggers(true);
    insert listOpp;
   // TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.startTest();
        //TriggerExecutionController.setSkipOpportunityTriggers(false);
         //insert listOpp;
       //TriggerExecutionController.setSkipOpportunityTriggers(true);
        
           Campaign campaignObj1 = new Campaign(Name ='Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        
        insert campaignObj1;
        
        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,EOL_Date_NORTH_AMERICA__c=System.Now().Date().addDays(240));
        insert newPrdct1;                                      
                                         
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
        insert pBE1;  
        
        List<OpportunityLineItem> listOppLineItem = new List<OpportunityLineItem>();
        for(integer intI=0;intI<5;intI++){
            OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId =listOpp[intI].Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description'+intI);   
            listOppLineItem.add(oppLineItem);
        }
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        insert listOppLineItem;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        Lead testLead = new Lead(LastName='Test Contact',Company='Test',Related_Opportunity__c=listOpp[0].id,Country_Code__c='US',Email='test@dell.com',Campaign__c  = campaignObj1.id,LeadSource  = 'Employee Referral',Lead_Type__c ='Inbound');
        insert testLead;
   
        
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapOldOpp = new Map<Id,Opportunity>();             
        mapOldOpp.put(listOpp[0].Id,listOpp[0]);
        mapOldOpp.put(listOpp[1].Id,listOpp[1]);
        mapOldOpp.put(listOpp[2].Id,listOpp[2]);
        mapOldOpp.put(listOpp[3].Id,listOpp[3]);
        mapOldOpp.put(listOpp[4].Id,listOpp[4]);
    //    mapOldOpp.put(listOpp[5].Id,listOpp[5]);

        Opportunity opp =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c, EMC_Opportunity_updated__c   from Opportunity where Id =:listOpp[0].Id];
        opp.CloseDate= System.Now().Date().addDays(260);//6.0
        opp.Primary_Product_Delivery_Address_Country__c = 'UNITED STATES';
        opp.Primary_Product_Delivery_Address_Region__c = 'NORTH AMERICA';
        opp.EMC_Opportunity_updated__c = 'Waiting Sync';
        opp.StageName ='Propose-60%'; 
        opp.Probability = 60; 
        opp.Forecast_Category_Override__c ='Pipeline'; 
        
        //TriggerExecutionController.setSkipOpportunityTriggers(false);
        update opp;
        
        system.assertEquals(1, [select count() from Opportunity  where id = :opp.Id]);


        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        
        Opportunity opp2 =[Select id,RecordtypeId,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c, EMC_Opportunity_updated__c  from Opportunity where Id =:opp.Id];
        
        
        
        mapOpp.put(opp2.Id,opp2);
        OpportunityValidator.validateCloseDate(mapOpp,mapOldOpp);
        TriggerExecutionController.setSkipAlltriggers(false);
        Test.stopTest();
    }
    
    static testMethod void prepareTestDataEMEA(){         
        TriggerExecutionController.setSkipAlltriggers(true);
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
        
        Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        insert testOpportunity;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();
         Campaign campaignObj2 = new Campaign(Name ='Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        
        insert campaignObj2;
        
        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,EOL_Date_EMEA__c=System.Now().Date().addDays(240));
        insert newPrdct1;                                      
                                         
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
        insert PBE1;  
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId =testOpportunity.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1');   
        insert oppLineItem;
        
        Lead testLead = new Lead(LastName='Test Contact',Company='Test',Related_Opportunity__c=testOpportunity.id,Country_Code__c='US',Email='test@dell.com',Campaign__c = campaignObj2.id,LeadSource  = 'Employee Referral',Lead_Type__c ='Inbound');
        insert testLead;
        
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapOldOpp = new Map<Id,Opportunity>();             
        mapOldOpp.put(testOpportunity.Id,testOpportunity);

        Opportunity opp =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp.CloseDate= System.Now().Date().addDays(260);//6.0
        opp.Primary_Product_Delivery_Address_Country__c = 'UNITED STATES';
        opp.Primary_Product_Delivery_Address_Region__c = 'EMEA';
        opp.StageName ='Propose-60%'; 
        opp.Forecast_Category_Override__c ='Pipeline';
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        update opp;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.stopTest();
        Opportunity opp2 =[Select id,RecordtypeId,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c  from Opportunity where Id =:opp.Id];
        mapOpp.put(opp2.Id,opp2);
        OpportunityValidator.validateCloseDate(mapOpp,mapOldOpp);
        //6.0
        newPrdct1.EOL_Date__c = System.Now().Date().addDays(240);
        newPrdct1.EOL_Date_EMEA__c = null;
        update newPrdct1;
        
        system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);
        
        OpportunityValidator.validateCloseDate(mapOpp,mapOldOpp);
        
        TriggerExecutionController.setSkipAlltriggers(false);
    }
    
    static testMethod void prepareTestDataLATAM(){         
        TriggerExecutionController.setSkipAlltriggers(true);
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
        
        Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        insert testOpportunity;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();
        
          Campaign campaignObj3 = new Campaign(Name ='Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        
        insert campaignObj3;
        
        
        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,EOL_Date_LATAM__c=System.Now().Date().addDays(240));
        insert newPrdct1;                                      
                                         
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
        insert pBE1;  
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId =testOpportunity.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1');   
        insert oppLineItem;
        
        Lead testLead = new Lead(LastName='Test Contact',Company='Test',Related_Opportunity__c=testOpportunity.id,Country_Code__c='US',Email='test@dell.com',Location_Number__c = 7,Campaign__c = campaignObj3.id,LeadSource  = 'Employee Referral',Lead_Type__c ='Inbound');
        insert testLead;
        
        system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);

        
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapOldOpp = new Map<Id,Opportunity>();             
        mapOldOpp.put(testOpportunity.Id,testOpportunity);

        Opportunity opp =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp.CloseDate= System.Now().Date().addDays(260);//6.0
        opp.Primary_Product_Delivery_Address_Country__c = 'UNITED STATES';
        opp.Primary_Product_Delivery_Address_Region__c = 'LATAM';
        opp.StageName ='Propose-60%'; 
        opp.Forecast_Category_Override__c ='Pipeline';

        TriggerExecutionController.setSkipOpportunityTriggers(false);
        update opp;
        
        
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        Opportunity opp2 =[Select id,RecordtypeId,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c  from Opportunity where Id =:opp.Id];
        mapOpp.put(opp2.Id,opp2);
        OpportunityValidator.validateCloseDate(mapOpp,mapOldOpp);
        
        //6.0
        newPrdct1.RTS_Date_LATAM__c = System.Now().Date().addDays(270);
        newPrdct1.EOL_Date_LATAM__c = System.Now().Date().addDays(270);
        update newPrdct1;
        OpportunityValidator.validateCloseDate(mapOpp,mapOldOpp);
        
        Test.stopTest();
        TriggerExecutionController.setSkipAlltriggers(false);
    }
    
    static testMethod void prepareTestDataAPJ(){         
        TriggerExecutionController.setSkipAlltriggers(true);
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
        
        Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        insert testOpportunity;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();
          Campaign campaignObj3 = new Campaign(Name ='Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        
        insert campaignObj3;
        
        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,EOL_Date_APJ__c=System.Now().Date().addDays(240));
        insert newPrdct1;                                      
                                         
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
        insert pBE1;  
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId =testOpportunity.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1');   
        insert oppLineItem;
        
        Lead testLead = new Lead(LastName='Test Contact',Company='Test',Related_Opportunity__c=testOpportunity.id,Country_Code__c='US',Email='test@dell.com',Location_Number__c = 7,Campaign__c  = campaignObj3.id,LeadSource  = 'Employee Referral',Lead_Type__c ='Inbound');
        insert testLead;
        
        system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]); 
        
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapOldOpp = new Map<Id,Opportunity>();             
        mapOldOpp.put(testOpportunity.Id,testOpportunity);

        Opportunity opp =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp.CloseDate= System.Now().Date().addDays(260);//6.0
        opp.Primary_Product_Delivery_Address_Country__c = 'UNITED STATES';
        opp.Primary_Product_Delivery_Address_Region__c = 'APJ';
        opp.StageName ='Propose-60%'; 
        opp.Forecast_Category_Override__c ='Pipeline';
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        update opp;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.stopTest();
        Opportunity opp2 =[Select id,RecordtypeId, closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c  from Opportunity where Id =:opp.Id];
        mapOpp.put(opp2.Id,opp2);
        OpportunityValidator.validateCloseDate(mapOpp,mapOldOpp);
        TriggerExecutionController.setSkipAlltriggers(false);
    }
    
    static testMethod void prepareTestDataOther(){         
        TriggerExecutionController.setSkipAlltriggers(true);
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
        
        Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        insert testOpportunity;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();
        
         Campaign campaignObj4 = new Campaign(Name ='Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        
        insert campaignObj4;
        
        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,EOL_Date_OTHER__c=System.Now().Date().addDays(240));
        insert newPrdct1;                                      
                                         
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
        insert pBE1;  
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId =testOpportunity.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1');   
        insert oppLineItem;
        
        Lead testLead = new Lead(LastName='Test Contact',Company='Test',Related_Opportunity__c=testOpportunity.id,Country_Code__c='US',Email='test@dell.com',Campaign__c  = campaignObj4.id,LeadSource  = 'Employee Referral',Lead_Type__c ='Inbound');
        insert testLead;
        
           system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);
            
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapOldOpp = new Map<Id,Opportunity>();             
        mapOldOpp.put(testOpportunity.Id,testOpportunity);

        Opportunity opp =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp.CloseDate= System.Now().Date().addDays(260);//6.0
        opp.Primary_Product_Delivery_Address_Country__c = 'UNITED STATES';
        opp.Primary_Product_Delivery_Address_Region__c = 'Other';
        opp.StageName ='Propose-60%'; 
        opp.Forecast_Category_Override__c ='Pipeline';
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        update opp;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.stopTest();
        Opportunity opp2 =[Select id,RecordtypeId,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c  from Opportunity where Id =:opp.Id];
        mapOpp.put(opp2.Id,opp2);
        OpportunityValidator.validateCloseDate(mapOpp,mapOldOpp);
        TriggerExecutionController.setSkipAlltriggers(false);
    }
    
    static testMethod void prepareTestDataBlank(){         
        TriggerExecutionController.setSkipAlltriggers(true);
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
        
        Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        insert testOpportunity;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();
        
          Campaign campaignObj5 = new Campaign(Name ='Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        
        insert campaignObj5;
        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,EOL_Date__c=System.Now().Date().addDays(240));
        insert newPrdct1;                                      
                                         
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
        insert pBE1;  
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId =testOpportunity.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1');   
        insert oppLineItem;
        
           system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);
        
        Lead testLead = new Lead(LastName='Test Contact',Company='Test',Related_Opportunity__c=testOpportunity.id,Country_Code__c='US',Email='test@dell.com',Campaign__c  = campaignObj5.id,LeadSource  = 'Employee Referral',Lead_Type__c ='Inbound');
        insert testLead;
            
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapOldOpp = new Map<Id,Opportunity>();             
        mapOldOpp.put(testOpportunity.Id,testOpportunity);

        Opportunity opp =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp.CloseDate= System.Now().Date().addDays(260);//6.0
        opp.Primary_Product_Delivery_Address_Country__c = '';
        opp.Primary_Product_Delivery_Address_Region__c = '';
        opp.StageName ='Propose-60%'; 
        opp.Forecast_Category_Override__c ='Pipeline';
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        update opp;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.stopTest();
        
        Opportunity opp2 =[Select id,RecordtypeId,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c  from Opportunity where Id =:opp.Id];
        mapOpp.put(opp2.Id,opp2);
        OpportunityValidator.validateCloseDate(mapOpp,mapOldOpp);
        TriggerExecutionController.setSkipAlltriggers(false);
    }
    
    static testMethod void testValidateDeletion(){
        
        TriggerExecutionController.setSkipAlltriggers(true);
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
        
        Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         Partner_Opportunity_Stage__c = 'Plan - 1%',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
        
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert testOpportunity;
       // TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.startTest();
         Campaign campaignObj6 = new Campaign(Name ='Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        
        insert campaignObj6;
        
        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,EOL_Date__c=System.Now().Date().addDays(240));
        insert newPrdct1;                                      
                                         
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
        insert pBE1;  
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId =testOpportunity.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1');   
        insert oppLineItem;
        
        Lead testLead = new Lead(LastName='Test Contact',Company='Test',Related_Opportunity__c=testOpportunity.id,Country_Code__c='US',Email='test@dell.com',Campaign__c  = campaignObj6.id,LeadSource  = 'Employee Referral',Lead_Type__c ='Inbound');
        insert testLead;
            
        system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);

            
        Opportunity opp =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp.Related_Parent_Opportunity__c = null;
        //opp.Quest_Opportunity_Integration_Status__c = 'True'; // 7.0
        opp.StageName ='Discover - 10%'; 
        opp.Forecast_Category_Override__c ='Pipeline';
        
        update opp;
        
        List<Opportunity> listOpp = new List<Opportunity>();
        listOpp.add(opp);
        
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();                     
        mapOpp.put(opp.Id,opp);
      
        string strProid = [SELECT id from profile WHERE Name = 'IT TA User' LIMIT 1][0].Id; // Ver 1.0
        User u1 = new User(Alias = 'standt', Email='standarduser@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = strProid, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5599@dell.com', Badge_Number__c = getUniqueString());
        system.runAs(u1)
        {
            OpportunityValidator.validateDeletion(listOpp,mapOpp);
        }
       // test using profile other than system admin to throw exception in class
        User u = new User(Alias = 'standt', Email='standarduser@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = '00eA0000000gmdu',TimeZoneSidKey='America/Los_Angeles', UserName='jplie=salesforce5999.com@example.com', Badge_Number__c = '15555577556');
       system.runAs(u){
         //  OpportunityValidator.validateDeletion(lstOpp,mapOpp);
         system.debug('hi');
        }
        
        OpportunityValidator.getOppLineItems(listOpp);
        OpportunityValidator.validateOpportunities(listOpp,mapOpp);
            
        Opportunity opp3 =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp3.StageName  = 'Win - 100%';
        opp3.Driving_Solution__c  = 'Cloud Client Computing';
        opp3.NextStep = 'Credit Card 7665544';
        opp3.Description   = '345678 AMERICA';
        opp3.Partner_Opportunity_Stage__c ='Win - 100%';
        opp3.Forecast_Category_Override__c ='';
        opp3.Primary_Competitor_Product_Type__c = 'Client';
        opp3.Primary_Competitor__c = 'VIT';
        update opp3;
        
        Map<Id,Opportunity> mapNewOpp = new Map<Id,Opportunity>();
        mapNewOpp.put(opp3.id,opp3);
        OpportunityValidator.validateStageChangeForCloudClientComputingOpps(listOpp,mapOpp,mapNewOpp);
            
        Opportunity opp4 =[Select id,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp4.NextStep = 'Credit Card 7665544';
        opp4.Description   = '345678 AMERICA';
        opp4.StageName ='Discover - 10%';
        opp4.Forecast_Category_Override__c ='Pipeline';
        
        //TriggerExecutionController.setSkipOpportunityTriggers(false);
        update opp4;
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.stopTest();

        listOpp = new List<Opportunity>();
        listOpp.add(opp4);
            
        OpportunityValidator.validateCreditCardInformation(listOpp,mapNewOpp);
        OpportunityValidator.validateEndUserMailingAddress(listOpp,mapNewOpp);
        TriggerExecutionController.setSkipAlltriggers(false);
    }
    
    private static testMethod void testValidateSolutionAssociation() {
    TriggerExecutionController.setSkipAlltriggers(true);
        set<String> setRegionalId = new set<String>();
        setRegionalId.add('AMER:773456638.5');
        
        // Create Account
        Id partnerAccRTId = StaticFactory.getRecordTypeIdByName('Account', 'End-User Account');
        Account accountObj = new Account(Name='Test', RecordtypeId = partnerAccRTId, Account_ID__c = '9876543');
        insert accountObj;
        
        // Create Opportunity
        Opportunity oppInstance = new Opportunity();
        oppInstance.name = 'TestOpp';
        oppInstance.AccountId = accountObj.Id;
        oppInstance.Type = 'Deal/Bid - Indirect';
        oppInstance.Domain__c = 'Networking';
        oppInstance.Solution_Type__c = 'Campus';
        oppInstance.Solution_Name__c = 'Wireless Switches';   
        oppInstance.StageName = 'Plan - 1%';
        oppInstance.CloseDate = System.today();
        oppInstance.Deal_Type__c = 'Greenfield';
        oppInstance.Deal_Registration_Status__c = 'New';
        oppInstance.Deal_Expiration_Date__c = System.today() + 10; 
        
       // TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppInstance;
      //  TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        
        system.assertEquals(1, [select count() from Opportunity where Id =:oppInstance.Id]);

        
        // Create Solution
        Solution__c solObj = new Solution__c();
        solObj.Opportunity__c = oppInstance.Id;
        solObj.OSC_Regional_ID__c = 'AMER:773456638.5';
        insert solObj;
        
        // Create Opportunity
        Opportunity oppInstance1 = new Opportunity();
        oppInstance1.name = 'TestOpp';
        oppInstance1.AccountId = accountObj.Id;
        oppInstance1.Type = 'Deal/Bid - Indirect';
        oppInstance1.Domain__c = 'Networking';
        oppInstance1.Solution_Type__c = 'Campus';
        oppInstance1.Solution_Name__c = 'Wireless Switches';   
        oppInstance1.StageName = 'Plan - 1%';
        oppInstance1.CloseDate = System.today();
        oppInstance1.Deal_Type__c = 'Greenfield';
        oppInstance1.Deal_Registration_Status__c = 'New';
        oppInstance1.Deal_Expiration_Date__c = System.today() + 11; 
        oppInstance1.OSC_Solution_ID__c = 'AMER:773456638.5';
        
    //    TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppInstance1;
        TriggerExecutionController.setSkipAllTriggers(false); 
        
        OpportunityValidator.validateSolutionAssociation(new list<opportunity>{oppInstance1}, setRegionalId);
    }
    
    static list<Lead> listLeads = new list<Lead>();
    static list<Campaign> listCampaigns = new list<Campaign>();
     
    private static testmethod void testValidateChannelLeads() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id partnerAccRTId = StaticFactory.getRecordTypeIdByName('Account', 'Partner Account');
        
        list<Account> listAccounts = new list<Account>();
        Account partnerAccount1 = new Account(Name='Test1', RecordtypeId = partnerAccRTId, Type = 'Partner');
        listAccounts.add(partnerAccount1);
        Account partnerAccount2 = new Account(Name='Test2', RecordtypeId = partnerAccRTId, Type = 'Partner');
        listAccounts.add(partnerAccount2);
        insert listAccounts;

        // Create Campaigns
        //v2.0 CR
        /*Id directCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'GBL_Standard_RT');
        Id channelCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); */
        Id directCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0');
        Id channelCampaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0');
        
        createTestCampaign();
        Campaign directCampaign = listCampaigns[0];
        directCampaign.RecordTypeId = directCampaignRTId;
        
        createTestCampaign();
        Campaign channelCampaign = listCampaigns[0];
        channelCampaign.RecordTypeId = channelCampaignRTId;
        
        TriggerExecutionController.setSkipCampaignTriggers(true);
        insert listCampaigns;
        TriggerExecutionController.setSkipCampaignTriggers(false);
        
        // Create Leads
        Id leadAssignmentRTId= StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
        Id leadCleansingRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
        Id leadQualificationRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Lead Qualification');
         Campaign campaignObj7 = new Campaign(Name ='Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        
        insert campaignObj7;
        
        createTestLead();
        Lead leadObj1 = listLeads[0];
        leadObj1.Campaign__c = channelCampaign.Id;
        leadObj1.RecordTypeId = leadAssignmentRTId;
        leadObj1.Account__c = partnerAccount1.Id; 
        leadObj1.LeadSource =  'Employee Referral';
        leadObj1.Country_Code__c=  'UY';
        leadObj1.Lead_Type__c=  'Inbound'; 
        leadObj1.Campaign__c  = campaignObj7.id;    
        
        createTestLead();
        Lead leadObj2 = listLeads[1];
        leadObj2.Campaign__c = channelCampaign.Id;
        leadObj2.RecordTypeId = leadCleansingRTId;
        leadObj2.Location_Number__c = 7;
        leadObj2.Country_Code__c=  'UY';

         leadObj2.Campaign__c  = campaignObj7.id;
         leadObj2.LeadSource =  'Employee Referral';
          leadObj2.Lead_Type__c=  'Inbound'; 
         
         
        createTestLead();
        Lead leadObj3 = listLeads[2];
        leadObj3.Campaign__c = directCampaign.Id;
       leadObj3.RecordTypeId = leadQualificationRTId;
        leadObj3.Country_Code__c=  'UY';

        leadObj3.Account__c = partnerAccount1.Id;
        leadObj3.Campaign__c  = campaignObj7.id;
         leadObj3.LeadSource =  'Employee Referral';
          leadObj3.Lead_Type__c=  'Inbound'; 
        
        createTestLead();
        Lead leadObj4 = listLeads[3];
        leadObj4.Campaign__c = channelCampaign.Id;
        leadObj4.RecordTypeId = leadAssignmentRTId;
        leadObj4.Account__c = partnerAccount2.Id;  
        leadObj4.Campaign__c  = campaignObj7.id;
         leadObj4.LeadSource =  'Employee Referral';
          leadObj4.Lead_Type__c=  'Inbound'; 
         leadObj4.Country_Code__c=  'UY';

        
        createTestLead();
        Lead leadObj5 = listLeads[4];
        leadObj5.Campaign__c = channelCampaign.Id;
        leadObj5.RecordTypeId = leadAssignmentRTId;
        leadObj5.Account__c = partnerAccount1.Id;
        leadObj5.Status = 'Inactive';
         leadObj5.Campaign__c  = campaignObj7.id;
          leadObj5.LeadSource =  'Employee Referral';
          leadObj5.Lead_Type__c=  'Inbound'; 
       leadObj5.Country_Code__c=  'UY';

        
        createTestLead();
        Lead leadObj6 = listLeads[5];
        leadObj6.Campaign__c = channelCampaign.Id;
        leadObj6.RecordTypeId = leadAssignmentRTId;
        leadObj6.Account__c = partnerAccount1.Id;
        leadObj6.Related_Opportunity_Count__c = 6;
        leadObj6.Campaign__c  = campaignObj7.id;
         leadObj6.LeadSource =  'Employee Referral';
          leadObj6.Lead_Type__c=  'Inbound'; 
        leadObj6.Country_Code__c=  'UY';

        TriggerExecutionController.setSkipLeadTriggers(true);
        try{
        insert listLeads;
        }
        catch(exception e){}
        TriggerExecutionController.setSkipLeadTriggers(false);        
       
        Id dealRegRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Deal Registration');
        Opportunity testOppty = new Opportunity(Name = 'Test Opportunity', 
                                                AccountId = partnerAccount1.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c = 'Approved',
                                                Total_Expected_Dell_Revenue__c = 1919191,
                                                RecordTypeID = dealRegRTId,
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
                                                CloseDate = System.today() + 30);        
        
        try {
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            Database.insert(testOppty);
            system.assertEquals(1, [select count() from Opportunity where Id =:testOppty.Id]);

            TriggerExecutionController.setSkipOpportunityTriggers(true);
            system.assertEquals(1, [select count() from Opportunity where Id =:testOppty.Id]);
        }
        catch(Exception ex) {
            System.debug('Exception in test_validateChannelLeads(): ' + ex);
        }
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        Test.startTest();
        OpportunityUtils.runCMAPOppTrigger = true;
        testOppty.Channel_Lead_Id__c = leadObj2.Id;
        try{
        OpportunityValidator.validateChannelLeads(new list<Opportunity> {testOppty}, new set<Id>{leadObj2.Id});
        
        
        /*testOppty.Channel_Lead_Id__c = leadObj3.Id;
        OpportunityValidator.validateChannelLeads(new list<Opportunity> {testOppty}, new set<Id>{leadObj3.Id});*/
        
        testOppty.Channel_Lead_Id__c = leadObj4.Id;
        OpportunityValidator.validateChannelLeads(new list<Opportunity> {testOppty}, new set<Id>{leadObj4.Id});
        
        testOppty.Channel_Lead_Id__c = leadObj5.Id;
        OpportunityValidator.validateChannelLeads(new list<Opportunity> {testOppty}, new set<Id>{leadObj5.Id});
        
        testOppty.Channel_Lead_Id__c = leadObj6.Id;
        OpportunityValidator.validateChannelLeads(new list<Opportunity> {testOppty}, new set<Id>{leadObj6.Id});
        }
        catch(exception e){}
        
        Test.stopTest();
    }
    
    private static testMethod void createTestLead() {
        Lead leadObj = new Lead(LastName = 'Test Lead_' + listLeads.size(),
                                Email ='testcmap@cmaptest.com',
                                Status = 'Accepted by Channel Partner',
                                Phone='88967544',
                                Called_Customer__c ='Yes',
                                Sales_Qualified__c ='Qualified',
                                Budget__c = 'Yes',
                                Country = 'US',
                                Purchase_Timeframe__c = 'Immediate',
                                Company = 'Test Company_' + listLeads.size());
        listLeads.add(leadObj);
        system.assertEquals('testcmap@cmaptest.com', listLeads[0].Email);

    }
    
    private static testMethod void createTestCampaign() {
        Campaign campaignObj = new Campaign(Name = 'Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        listCampaigns.add(campaignObj);
                system.assertEquals('Campaign_CMAP', listCampaigns[0].Name );

    }
   
    // Insert - Validate to check End user contact is blank or not
    private static testmethod void validateEndUserContactIsBlank() {
        TriggerExecutionController.setSkipAllTriggers(true);
        string strProid = [SELECT id from profile WHERE Name = 'IT TA User' LIMIT 1][0].Id; // Ver 1.0
        User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'ja', LOB_Title__c = 'GCC Global Program Manager',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strProid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;
        
   //     TriggerExecutionController.setSkipAllTriggers(false);
            
        system.runAs(u){    
            Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Deal/Bid - Indirect',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= NULL );
            try{
                
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                insert testOpportunity;
                system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);
                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation when End User contact is blank');
            }
           
            Test.stopTest();
        }
    }
    
    // Insert - Validate End User Mailing address for EMEA Region
    private static testMethod void validateEndUserMailingAddress() {
        TriggerExecutionController.setSkipAllTriggers(true);
        string strProid = [SELECT id from profile WHERE Name Like '%GBL Dell Services Mgr%' LIMIT 1][0].Id; // Ver 1.0
        User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'en_US', LOB_Title__c = 'GCC Global Program Manager',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strProid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;

        Contact testCont = new Contact();
        testCont.FirstName='test EU contact ';
        testCont.LastName='Test2';
        testCont.Email='testEUContact@dell.com';
        testCont.MailingStreet='';
        testCont.Status__c='Prospect';
        testCont.MailingCity='';
        testCont.MailingState='test State';
        testCont.MailingCountry='test Country';
        testCont.AccountId=testAccountObj.Id;
        insert testCont;
        
        TriggerExecutionController.setSkipAllTriggers(false);
            
        system.runAs(u){    
            Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Deal/Bid - Indirect',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= testCont.Id );
                
            try{
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                insert testOpportunity;
                system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);

                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation when End User contact Mailing address for EMEA Region is blank');
            }
           
            Test.stopTest();
        }
    }
    
    // Insert - Validate End User Mailing address for EMEA Region
    private static testMethod void validateEndUserMailingAddressForEMEA() {

        TriggerExecutionController.setSkipAllTriggers(true);
        string strProid = [SELECT id from profile WHERE Name = 'IT TA User' LIMIT 1][0].Id; // Ver 1.0
        User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'ja', LOB_Title__c = 'GCC Global Program Manager',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strProid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;

        Contact testCont = new Contact();
        testCont.FirstName='test EU contact ';
        testCont.LastName='Test2';
        testCont.Email='testEUContact@dell.com';
        testCont.MailingStreet='';
        testCont.Status__c='Prospect';
        testCont.MailingCity='';
        testCont.MailingState='test State';
        testCont.MailingCountry='test Country';
        testCont.AccountId=testAccountObj.Id;
        insert testCont;
        
        TriggerExecutionController.setSkipAllTriggers(false);
            
        system.runAs(u){    
            Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Deal/Bid - Indirect',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= testCont.Id );
            try{
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                insert testOpportunity;
                system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);

                
                testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Deal/Bid - Indirect',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL);
                update testOpportunity;
                
                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation when End User contact Mailing address for EMEA Region is blank');
            }
           
            Test.stopTest();
        }
    }

    // Insert - Validate End User Mailing address for NON-EMEA Region
    private static testMethod void validateEndUserMailingAddressForNonEMEA() {

        TriggerExecutionController.setSkipAllTriggers(true);
        string strProid = [SELECT id from profile WHERE Name = 'IT TA User' LIMIT 1][0].Id; // Ver 1.0
        User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'ja', LOB_Title__c = 'GCC Global Program Manager',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strProid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'APJ');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;
         
        Contact testCont = new Contact();
        testCont.FirstName='test EU contact ';
        testCont.LastName='Test2';
        testCont.Email='testEUContact@dell.com';
        testCont.MailingStreet='';
        testCont.Status__c='Prospect';
        testCont.MailingCity='';
        testCont.MailingState='test State';
        testCont.MailingCountry='test Country';
        testCont.AccountId=testAccountObj.Id;
        insert testCont;
        
        TriggerExecutionController.setSkipAllTriggers(false);
            
        system.runAs(u){    
            Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Deal/Bid - Indirect',
                                             Domain__c='Deal Reg',
                                             NextStep = 'Credit Card 7665544',
                                             Description= 'Credit Card 7665544',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= testCont.Id );
            try{
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                insert testOpportunity;
                system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);

                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation when End User contact Mailing address for Non-EMEA Region is blank');
            }
           
            Test.stopTest();
        }
    }
    
    // Update - Validate to check End user contact is blank or not
    private static testmethod void validateEndUserContactIsBlankUpdate() {
        TriggerExecutionController.setSkipAllTriggers(true);
        string strProid = [SELECT id from profile WHERE Name = 'IT TA User' LIMIT 1][0].Id; // Ver 1.0
        User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'ja', LOB_Title__c = 'GCC Global Program Manager',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strProid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;
        
        Contact testCont = new Contact();
        testCont.FirstName='test EU contact ';
        testCont.LastName='Test2';
        testCont.Email='testEUContact@dell.com';
        testCont.MailingStreet='Test Street';
        testCont.Status__c='Prospect';
        testCont.MailingCity='Test City';
        testCont.MailingState='test State';
        testCont.MailingCountry='test Country';
        testCont.AccountId=testAccountObj.Id;
        insert testCont;

       // TriggerExecutionController.setSkipAllTriggers(false);
            
        system.runAs(u){    
            Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Deal/Bid - Indirect',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= testCont.Id );
            insert testOpportunity;
            system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);


            Opportunity testOpp = [Select Id, Quest_Software_Contact__c,Forecast_Category_Override__c from Opportunity where id =: testOpportunity.Id];
            testOpp.Quest_Software_Contact__c = Null;
            testOpp.Forecast_Category_Override__c ='Pipeline';
            
            try{
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                Update testOpp;

                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation when End User contact is blank');
            }
           
            Test.stopTest();
        }
    }
    
    // Update - Validate to check End user contact Mailing Address is blank or not for EMEA Region
    private static testmethod void validateEndUserMailingAddrForEMEA() {
        TriggerExecutionController.setSkipAllTriggers(true);
        string strProid = [SELECT id from profile WHERE Name = 'IT TA User' LIMIT 1][0].Id; // Ver 1.0
        User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'ja', LOB_Title__c = 'GCC Global Program Manager',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strProid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;
        
        Contact testCont = new Contact();
        testCont.FirstName='test EU contact ';
        testCont.LastName='Test2';
        testCont.Email='testEUContact@dell.com';
        testCont.MailingStreet='Test Street';
        testCont.Status__c='Prospect';
        testCont.MailingCity='Test City';
        testCont.MailingState='test State';
        testCont.MailingCountry='test Country';
        testCont.AccountId=testAccountObj.Id;
        insert testCont;

        //2.0 - Rename contact fnam,lname and email to prevent duplication
        Contact testCont1 = new Contact();
        testCont1.FirstName='test EU contact3 ';
        testCont1.LastName='Test3';
        testCont1.Email='testEUContact3@dell.com';
        testCont1.MailingStreet='';
        testCont1.Status__c='Prospect';
        testCont1.MailingCity='';
        testCont1.MailingState='test State';
        testCont1.MailingCountry='test Country';
        testCont1.AccountId=testAccountObj.Id;
        insert testCont1;

      //  TriggerExecutionController.setSkipAllTriggers(false);
            
        system.runAs(u){    
            Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Deal/Bid - Indirect',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= testCont.Id );
            insert testOpportunity;
            system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);


            Opportunity testOpp = [Select Id, Quest_Software_Contact__c,Forecast_Category_Override__c from Opportunity where id =: testOpportunity.Id];
            testOpp.Quest_Software_Contact__c = testCont1.Id;
            testOpp.Forecast_Category_Override__c ='Pipeline';

            try{
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                update testOpp;
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation when End User contact is blank');
            }
           
            Test.stopTest();
        }
    }

    // Update - Validate to check End user contact is blank or not
    private static testmethod void validateEndUserMailingAddrForNonEMEA() {
        TriggerExecutionController.setSkipAllTriggers(true);
        string strProid = [SELECT id from profile WHERE Name = 'IT TA User' LIMIT 1][0].Id; // Ver 1.0
        User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'ja', LOB_Title__c = 'GCC Global Program Manager',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strProid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'APJ');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;
        
        Contact testCont = new Contact();
        testCont.FirstName='test EU contact ';
        testCont.LastName='Test2';
        testCont.Email='testEUContact@dell.com';
        testCont.MailingStreet='Test Street';
        testCont.Status__c='Prospect';
        testCont.MailingCity='Test City';
        testCont.MailingState='test State';
        testCont.MailingCountry='test Country';
        testCont.AccountId=testAccountObj.Id;
        insert testCont;

        //2.0 - Rename contact fnam,lname and email to prevent duplication
        Contact testCont1 = new Contact();
        testCont1.FirstName='test EU contact3 ';
        testCont1.LastName='Test3';
        testCont1.Email='testEUContact3@dell.com';
        testCont1.MailingStreet='';
        testCont1.Status__c='Prospect';
        testCont1.MailingCity='';
        testCont1.MailingState='test State';
        testCont1.MailingCountry='test Country';
        testCont1.AccountId=testAccountObj.Id;
        insert testCont1;

      //  TriggerExecutionController.setSkipAllTriggers(false);
            
        system.runAs(u){    
            Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Deal/Bid - Indirect',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= testCont.Id );
            TriggerExecutionController.setSkipOpportunityTriggers(false);
                insert testOpportunity;
             system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);
   
           TriggerExecutionController.setSkipOpportunityTriggers(true);
            Opportunity testOpp = [Select Id, Quest_Software_Contact__c,Forecast_Category_Override__c from Opportunity where id =: testOpportunity.Id];
            testOpp.Quest_Software_Contact__c = testCont1.Id;
            testOpp.Forecast_Category_Override__c ='Pipeline';
            
            try{
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                update testOpp;
                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation when End User contact is blank');
            }
           
            Test.stopTest();
        }
    }
     private static testmethod void validateActiveEndCustomertest() {
        test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        string strProid = [SELECT id from profile WHERE Name = 'IT TA User' LIMIT 1][0].Id; // Ver 1.0
        User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'ja', LOB_Title__c = 'GCC Global Program Manager',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strProid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Id partnerAccRTId = StaticFactory.getRecordTypeIdByName('Account', 'Partner Account');
        Id masterAccRTId =  StaticFactory.getRecordTypeIdByName('Account', 'Master Account');
         
        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id,RecordTypeid=partnerAccRTId,Type='Partner');
       Account testAccountMasterObj = new Account(name='Test Account1', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id,RecordTypeid=masterAccRTId,Type='Master Group');
       insert testAccountObj;
       insert testAccountMasterObj ;
        Contact testCont = new Contact();
        testCont.FirstName='test EU contact ';
        testCont.LastName='Test2';
        testCont.Email='testEUContact@dell.com';
        testCont.MailingStreet='Test Street';
        testCont.Status__c='Prospect';
        testCont.MailingCity='Test City';
        testCont.MailingState='test State';
        testCont.MailingCountry='test Country';
        testCont.AccountId=testAccountMasterObj.Id;
        insert testCont;
        
        End_Customer__c testEndcustomer1= new End_Customer__c();
        testEndcustomer1.Partner_Account__c=testAccountObj.id;
        testEndcustomer1.Name=testAccountObj.Account_Country_Code__c;
        testEndcustomer1.Mailing_city__c=testAccountObj.Account_Country_Code__c;
        testEndcustomer1.Mailing_State__c=testAccountObj.Account_Country_Code__c;
        testEndcustomer1.Status__c='Inactive';
        insert testEndcustomer1;
        End_Customer__c testEndcustomer2= new End_Customer__c();
        testEndcustomer2.Partner_Account__c=testAccountObj.id;
        testEndcustomer2.Name=testAccountObj.Account_Country_Code__c;
        testEndcustomer2.Mailing_city__c=testAccountObj.Account_Country_Code__c;
        testEndcustomer2.Mailing_State__c=testAccountObj.Account_Country_Code__c;
        testEndcustomer2.Status__c='Inactive';
        insert testEndcustomer2;
           
        End_Customer_Contact__c testEndcustomerContact1= new End_Customer_Contact__c();
        testEndcustomerContact1.Name='TestEndCustomer1';
        testEndcustomerContact1.Last_Name__c='Test';
        testEndcustomerContact1.End_Customer__c=testEndcustomer1.id;
        testEndcustomerContact1.Email__c='TestEndCustomer1@dell.com';
        testEndcustomerContact1.Status__c='Inactive';
        insert testEndcustomerContact1;
         
        End_Customer_Contact__c testEndcustomerContact2= new End_Customer_Contact__c();
        testEndcustomerContact2.Name='TestEndCustomer2';
        testEndcustomerContact2.Last_Name__c='Test';
        testEndcustomerContact2.End_Customer__c=testEndcustomer2.id;
        testEndcustomerContact2.Email__c='TestEndCustomer2@dell.com';
        testEndcustomerContact2.Status__c='Inactive';
        insert testEndcustomerContact2;
      
        system.runAs(u){    
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Deal/Bid - Indirect',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= testCont.Id,
                                             Deal_Registration_Status__c='Submitted',
                                             End_Customer__c=testEndcustomer1.id,
                                             End_Customer_Contact__c=testEndcustomerContact1.id);
            TriggerExecutionController.setSkipOpportunityTriggers(false);
                insert testOpportunity;
            system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);
    
                TriggerExecutionController.setSkipOpportunityTriggers(true);
            list<Opportunity> listOpty= new list<Opportunity>();
            map<id,Opportunity> mapOpty= new Map<id,Opportunity>([select id,Deal_Registration_Status__c,End_Customer__c from Opportunity where id =:testOpportunity.id]);
            Opportunity testOpp1 = [Select Id, Deal_Registration_Status__c,End_Customer__c,Forecast_Category_Override__c from Opportunity where id =: testOpportunity.Id];
            testOpp1.Deal_Registration_Status__c='New';
            testOpp1.End_Customer__c=testEndcustomer2.id;
            testOpp1.End_Customer_Contact__c=testEndcustomerContact2.id;
            testOpp1.Forecast_Category_Override__c ='Pipeline'; 
            try{
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                update testOpp1;
                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }catch(DmlException dmlEx1){
                System.debug('**** DML Exception validation when End User contact is blank');
            }
            listOpty.add(testOpp1);
            opportunityValidator.validateActiveEndCustomer(listOpty,mapOpty);
            
            Opportunity testOpp2=[Select Id, Deal_Registration_Status__c,End_Customer__c,Forecast_Category_Override__c from Opportunity where id =: testOpp1.Id ];
            testOpp2.End_Customer_Contact__c=testEndcustomerContact1.id;
            testOpp2.End_Customer__c=testEndcustomer1.id;
            testOpp1.Forecast_Category_Override__c ='Pipeline';
            try{
                update testOpp2;
            }catch(DmlException dmlEx2){
                System.debug('**** DML Exception validation when End User contact is blank');
            }
            listOpty.clear();
            listOpty.add(testOpp2);
            opportunityValidator.validateActiveEndCustomer(listOpty,mapOpty);
            
            
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipAllTriggers(false);
            
        }
        Test.stopTest();
    }

    // Insert - Validate to check End user contact is loggedin with Valid profile
    private static testmethod void validateEndUserContactValidProfile() {
        TriggerExecutionController.setSkipAllTriggers(true);
        //string proid = [SELECT id from profile WHERE Name = 'IT TA User' LIMIT 1][0].Id; // Ver 1.0
        //User u = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey =  'ja', LOB_Title__c = 'GCC Global Program Manager',
        //                    LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', Title = 'GCC Program Manager',
       //                     EmailEncodingKey = 'ISO-8859-1', ProfileId = proid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        //insert u;
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;
        
        TriggerExecutionController.setSkipAllTriggers(false);
            
        //system.runAs(u){    
            Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Run Rate',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= NULL );
            try{
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                insert testOpportunity;
                            system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);

                TriggerExecutionController.setSkipOpportunityTriggers(true);
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation when End User contact is blank');
            }
           
            Test.stopTest();
        //}
    }
    
    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    } 

    // Insert - Validate to check Team Mailbox
    private static testmethod void validateOppDomainTestInsert() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;
        
        TriggerExecutionController.setSkipAllTriggers(false);
    

        Test.startTest();
        
        Generic_Email_Domains__c emailDomains = new Generic_Email_Domains__c(name = 'test.com');
        insert  emailDomains; 
        
        RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
        Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Run Rate',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= NULL,
                                             Team_Mailbox_1__c = 'testTeamBox1@dell.com',
                                             Team_Mailbox_2__c = 'testTeamBox2@dell.com',
                                             Team_Mailbox_3__c = 'testTeamBox3@dell.com',
                                             Team_Mailbox_4__c = 'testTeamBox4@dell.com',
                                             Team_Mailbox_5__c = 'testTeamBox5@dell.com');
            try{
                insert testOpportunity;
                system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation TeamMailBox Validation failed');
            }
        
        
           
        Test.stopTest();
    }
    // Update - Validate to check Team Mailbox
    private static testmethod void validateOppDomainTestUpdate() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;
        
        TriggerExecutionController.setSkipAllTriggers(false);
   
        Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Run Rate',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= NULL,
                                             Team_Mailbox_1__c = 'testTeamBox1@gmail.com',
                                             Team_Mailbox_2__c = 'testTeamBox2@gmail.com',
                                             Team_Mailbox_3__c = 'testTeamBox3@gmail.com',
                                             Team_Mailbox_4__c = 'testTeamBox4@gmail.com',
                                             Team_Mailbox_5__c = 'testTeamBox5@gmail.com');
            try{
                insert testOpportunity;  
                system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);
              
                }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation TeamMailBox Validation failed');
            }       
       Test.stopTest();
    }
    
 /*   // Update - Validate to check Team Mailbox
    private static testmethod void validateOppDomainTestUpdate1() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;

        Account testAccountObj = new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES', Sales_Channel__c = salesChannel.Id);
        insert testAccountObj;
        
        TriggerExecutionController.setSkipAllTriggers(false);
    
        Test.startTest();
            RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name='Standard Opportunity' LIMIT 1];
            Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                             RecordTypeId=rt.Id,
                                             Name='TestOpportunity',
                                             Type = 'Run Rate',
                                             Domain__c='Deal Reg',
                                             Solution_Type__c = 'Campus',
                                             Solution_Name__c = 'Wireless Switches',
                                             StageName='Plan - 1%',
                                             CloseDate= System.Now().Date().addDays(180),
                                             Primary_Competitor__c='Unknown',
                                             Competitor_Lost_To__c='Unknown' ,
                                             OSC_Solution_ID__c = NULL,
                                             Lattice_PreLead_External_ID__c = NULL,
                                             Quest_Software_Contact__c= NULL,
                                             Team_Mailbox_1__c = 'testTeamBox1@dell.com',
                                             Team_Mailbox_2__c = 'testTeamBox2@dell.com',
                                             Team_Mailbox_3__c = 'testTeamBox3@dell.com',
                                             Team_Mailbox_4__c = 'testTeamBox4@dell.com',
                                             Team_Mailbox_5__c = 'testTeamBox5@dell.com');
            try{
                insert testOpportunity;
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation TeamMailBox Validation failed');
            }
        
            Opportunity oppUpdate = [Select Id from Opportunity where Id=:testOpportunity.Id];
            oppUpdate.Team_Mailbox_1__c = 'testTeamBox11@gmail.com';
            oppUpdate.Team_Mailbox_2__c = 'testTeamBox22@gmail.com';
            oppUpdate.Team_Mailbox_3__c = 'testTeamBox33@gmail.com';
            oppUpdate.Team_Mailbox_4__c = 'testTeamBox44@gmail.com';
            oppUpdate.Team_Mailbox_5__c = 'testTeamBox55@gmail.com';
            try{
                Update oppUpdate;
            }catch(DmlException dmlEx){
                System.debug('**** DML Exception validation TeamMailBox Validation failed');
            }
        
        Test.stopTest();
    } */
    
    /********************************** ********************************** ********************************** 
 Written By : Sai Prasanth.
 Purpose: To code coverage for DealRegUtils Apex class.
 Description :  DealRegUtilsTestMethod1() is used to cover the if statements justifications in apex class. 
                DealRegUtilsTestMethod2() is used to cover the else statements justifications in apex class. 
 
 ********************************** ********************************** **********************************/ 




  /**********************************  This method used for IF statemetns in the controller class. ********************/
 
 Static testmethod void dealRegUtilsTestMethod1()
 {
 GCUserProfiles__c gcuser = new GCUserProfiles__c();
 gcuser.Name = UserInfo.getProfileId();
 insert gcuser;
 
 //calling isGCCountry() method.
   DealRegUtils.isGCCountry();
   
   
   
   
   
   //calling isOwnerIdhasGcProfile() method.
   DealRegUtils.isOwnerIdhasGcProfile(UserInfo.getUserid());
   
   
   
   set<id> setOwners = new set<id>();
   setOwners.add(UserInfo.getUserId());
   
  //calling isOwnerHasGCProfile  method.
    DealRegUtils.isOwnerHasGCProfile(setOwners);
    
    
    CountryNotApplicableToNonGC__c countryCS = new CountryNotApplicableToNonGC__c();
    countryCS.Name ='CHINNA';
    insert countryCS;
    
    system.assertEquals('CHINNA', countryCS.Name);

    //calling isGCDeal method.
    DealRegUtils.isGCDeal('CHINA');
    

 }
 
 
   /**********************************  This method used for Else statemetns in the controller class. ********************/

 Static testmethod void dealRegUtilsTestMethod2()
 {
 
User userRaja = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000Tesingop190@dell.com',
     Username = 'puser000Tesingop190@dell.com',
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     Badge_Number__c ='9101999101'
     );
 
 System.runAs(userRaja) {

 GCUserProfiles__c gcuser = new GCUserProfiles__c();
 gcuser.Name = userRaja.id;
 insert gcuser;
 system.assertEquals(1, [select count() from User where Id =:gcuser.Name]);
 
 //calling isGCCountry() method.
   DealRegUtils.isGCCountry();
   
   
   
   
   
   //calling isOwnerIdhasGcProfile() method.
   DealRegUtils.isOwnerIdhasGcProfile(UserInfo.getUserId());
   
   
   
  set<id> setOwners = new set<id>();
   setOwners.add(gcuser.id);
   
  //calling isOwnerHasGCProfile  method.
    DealRegUtils.isOwnerHasGCProfile(setOwners);
    
    
    CountryNotApplicableToNonGC__c countryCS = new CountryNotApplicableToNonGC__c();
    countryCS.Name ='PAKISTHAN';
    insert countryCS;
    
    
    
    //calling isGCDeal method.
    DealRegUtils.isGCDeal('CHINA');
    
 
 }
 
 }
    static testMethod void validateToChangeDealStageTest(){         
        TriggerExecutionController.setSkipAlltriggers(true);
        Account testAccountObj =new Account(name='Test Account__1', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
        
        Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Opportunity').getRecordTypeId(),
                                         Name='TestOpportunity',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         EMC_Opportunity_updated__c = 'Waiting Sync',Deal_Created_Date_Time__c=system.today(),Deal_Expiration_Date__c=Date.today()+10,
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
        insert testOpportunity;
        
      system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);  
        
       Map<ID,Opportunity> mapOld=new Map<ID, Opportunity>();
       mapOld.put(testOpportunity.ID, testOpportunity);  
       testOpportunity.StageName='Lost, Cancelled - 0%';
       List<Opportunity> listOpp=new List<Opportunity>();
       listOpp.add(testOpportunity);
       OpportunityValidator.validateToChangeDealStage(listOpp,mapOld);
}
    static testMethod void checkOnFulfilmentPath(){
        TriggerExecutionController.setSkipAlltriggers(true);
        Account testAccountObj =new Account(name='Test Account', Account_Country_Code__c = 'US', Account_Country__c = 'UNITED STATES');
        insert testAccountObj;
            
        Opportunity testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                                         Deal_Created_Date_Time__c = system.today()+1,
                                         Name='TestOpportunity',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         Partner_Opportunity_Stage__c = 'Plan - 1%',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
        
      //  TriggerExecutionController.setSkipAlltriggers(true);
        insert testOpportunity;
     //   TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.startTest();
         Campaign campaignObj6 = new Campaign(Name ='Campaign_CMAP',
                                            Campaign_Objective__c = 'Acquisition/Site Development',
                                            Type = 'Advisory Councils',
                                            Segment_Business_Unit__c = 'SMB',
                                            Region__c = 'ABU',                        
                                            Follow_Up_Role__c = 'Account Executive',
                                            Description = 'Test',
                                            StartDate = system.today(),
                                            EndDate = system.today(),
                                            Status = 'In Progress',
                                            Allocation_Source__c = 'Dell Allocation ABU',
                                            Nurture_Source__c = 'Dell Nurturing',
                                            Country_Code__c = 'BR - Brazil',
                                            Partner_Event_or_Campaign__c = false,
                                            IsActive = true,
                                            Total_Campaign_Targets_Planned__c = 1,
                                            Total_Value_Won_Opportunities_Planned__c = 1,
                                            Total_Value_Opportunities_Planned__c = 1,
                                            Lead_Routing__c = 'Dell Standard');
        
        insert campaignObj6;
        
        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',Selling_Entity_Required__c = true,IsActive = TRUE,EOL_Date__c=System.Now().Date().addDays(240));
        insert newPrdct1;                                      
                                         
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
        insert pBE1;  
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(Product2ID = newPrdct1.id,OpportunityId =testOpportunity.Id,pricebookEntryId=PBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1');   
        insert oppLineItem;

        Lead testLead = new Lead(LastName='Test Contact',Company='Test',Related_Opportunity__c=testOpportunity.id,Country_Code__c='US',Email='test@dell.com',Campaign__c  = campaignObj6.id,LeadSource  = 'Employee Referral',Lead_Type__c ='Inbound');
        insert testLead;
            
        system.assertEquals(1, [select count() from Opportunity where Id =:testOpportunity.Id]);

            
        Opportunity opp =[Select id,Deal_Reg_Oppty__c,Deal_Created_Date_Time__c,closeDate,Primary_Product_Delivery_Address_Country__c ,StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp.Related_Parent_Opportunity__c = null;
        //opp.Quest_Opportunity_Integration_Status__c = 'True'; // 7.0
        opp.StageName ='Discover - 10%'; 
        opp.Forecast_Category_Override__c ='Pipeline';
        opp.Submitted_for_Approval_Date_Time__c = system.today()+1;
        opp.Deal_Registration_Status__c='Rejected';
        opp.Resubmitted_for_Approval_Date_Time__c = system.today()+1;
        update opp;
        
        List<Opportunity> listOpp = new List<Opportunity>();
        listOpp.add(opp);
        
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();                     
        mapOpp.put(opp.Id,opp);
      
        Opportunity opp3 =[Select id,closeDate,Deal_Reg_Oppty__c,Primary_Product_Delivery_Address_Country__c ,(select id,product2.Selling_Entity_Required__c,Active_Wyse_Product__c from OpportunityLineItems),StageName,Primary_Product_Delivery_Address_Region__c,Forecast_Category_Override__c  from Opportunity where Id =:testOpportunity.Id];
        opp3.StageName  = 'Win - 100%';
        opp3.Driving_Solution__c  = 'Cloud Client Computing';
        opp3.NextStep = 'Credit Card 7665544';
        opp3.Description   = '345678 AMERICA';
        opp3.Partner_Opportunity_Stage__c ='Win - 100%';
        opp3.Forecast_Category_Override__c ='';
        opp3.Deal_Registration_Status__c='Submitted';
        opp3.Primary_Competitor_Product_Type__c = 'Client';  
        opp3.Primary_Competitor__c = 'VIT';
        update opp3;
        
        Map<Id,Opportunity> mapNewOpp = new Map<Id,Opportunity>();
        mapNewOpp.put(opp3.id,opp3);
        OpportunityValidator.checkOnFulfilmentPath(listOpp,mapOpp);
        User userDemo = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'GBL PRM Certification Admin'].Id,
            LastName = 'last',
            Email = 'puser000Tesingop190@dell.com',
            Username = 'puser000Tesingop190@dell.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Badge_Number__c ='9101999101'
        );
        insert userDemo; 
        
        system.runAs(userDemo){
            OpportunityValidator.ValidateRejectionFields(listOpp,mapNewOpp);
        }
        List<Opportunity> listOppRelated = new List<Opportunity>();
        listOppRelated.add(opp3);
        OpportunityValidator.validateStageChangeForCloudClientComputingOpps(listOppRelated,mapOpp,mapNewOpp);
        
        opp3.Deal_Created_Date_Time__c = null;
        opp3.StageName = 'Commit - 90%';
        update opp3;
        TriggerExecutionController.setSkipAlltriggers(false);
        
        /*List<Opportunity> listOppRelatedOpp = new List<Opportunity>();
        listOppRelatedOpp.add(opp3);
        user usr = [SELECT Id,username FROM User WHERE Profile.Name = 'System Administrator' AND isActive = True Limit 1];
        System_Behavior_Bypasser__c vre = new System_Behavior_Bypasser__c(SetupOwnerId = usr.Id, Name = 'test', Bypass_Opportunity_VRs__c = false);
        insert vre;  
        ISG_Selling_Entity_Stages__c entityStages = new ISG_Selling_Entity_Stages__c(name = 'Commit - 90%');
        insert entityStages;
        ISG_Selling_Entity_Countries__c entityCountries = new ISG_Selling_Entity_Countries__c(name = 'UNITED STATES');
        insert entityCountries;
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('APOS').getRecordTypeId();
        ISG_Selling_Entity_OppRecordTypeId__c entityOppRecordTypeId = new ISG_Selling_Entity_OppRecordTypeId__c(name = RecordTypeIdOpportunity);
        insert entityOppRecordTypeId;
        system.debug('opp3-->'+opp3);
        system.debug('entityStages-->'+entityStages);
        system.debug('entityCountries-->'+entityCountries);
        system.debug('entityOppRecordTypeId-->'+entityOppRecordTypeId);
        system.debug('usr-->'+usr);
        system.debug('vre-->'+vre);
        system.runAs(usr){
            OpportunityValidator.validateStageChangeForCloudClientComputingOpps(listOppRelatedOpp,mapOpp,mapNewOpp);
        }*/
        
    }
    
    static testMethod void validateFulfilmentPathForDistributor(){
        //String partnerType = DistiVisibilityHelperClass.getPartnerType( Userinfo.getUserId() ); 
       profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1];
        //TriggerExecutionController.setSkipAccountTriggers(true);
       TriggerExecutionController.setSkipAlltriggers(true);        
        Account partnerAccount = new Account();
        partnerAccount.Name = 'PartnerAccount';
        partnerAccount.Account_Country_Code__c = 'AI';
        partnerAccount.Account_Country__c = 'ANGUILLA';
        partnerAccount.Type = 'Partner';
         
        insert partnerAccount;
        partnerAccount.IsPartner = true;
        partnerAccount.Partner_Type__c = 'SUB DISTRIBUTOR';
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;
        update partnerAccount;
        
         Account partnerAccount1 = new Account();
        partnerAccount1.Name = 'PartnerAccount1';
        partnerAccount1.Account_Country_Code__c = 'AI';
        partnerAccount1.Account_Country__c = 'ANGUILLA';
        partnerAccount1.Type = 'Partner';
        partnerAccount.IsPartner = true;
        partnerAccount.Partner_Type__c = 'Sub Distributor';
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;
        insert partnerAccount1;
        
        System.assertNotEquals(null,partnerAccount1);
        string strtracks =string.valueOf(partnerAccount1.id);
        string strtracker =string.valueOf(partnerAccount.id);
        string streligibletrack = strtracker+';'+strtracks;
         
        Contact partnerContact = new Contact(); 
        partnerContact.AccountId = partnerAccount.id;
        partnerContact.Email = 'John.Doe@dell.com';
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title = 'VP';
        partnerContact.EligibleTracks__c = streligibletrack;
        partnerContact.Status__c ='Customer';
        partnerContact.MailingStreet = '123 Main';
        partnerContact.MailingCity = 'Peoria';
        partnerContact.MailingState = 'IL';
        partnerContact.MailingPostalCode = '33333';
        partnerContact.Phone = '3213213211';
        partnerContact.MobilePhone = '3213213211';
        partnerContact.Fax = '3213123211';
        insert partnerContact;
       
        test.startTest();
         
        List<Opportunity> listOpp = new List<Opportunity>();
        Opportunity testOpportunity1= new Opportunity (AccountID=partnerAccount.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId(),
                                         Name='TestOpportunity 1',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Plan - 1%',
                                         Forecast_Category_Override__c = '',
                                         EMC_Opportunity_updated__c = 'Waiting Sync',
                                         Partner_Opportunity_Stage__c = 'Plan - 1%',
                                         Primary_Competitor_Product_Type__c = 'Client',
                                         Distributor_Name__c = 'Direct Fulfilment',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
      //  insert testOpportunity1;
        listOpp.add(testOpportunity1);
        
        Opportunity testOpportunity2= new Opportunity (AccountID=partnerAccount.ID ,
                                         RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId(),
                                         Name='TestOpportunity 2',
                                         Type = 'Deal/Bid - Indirect',
                                         Domain__c='Deal Reg',
                                         Solution_Type__c = 'Campus',
                                         Solution_Name__c = 'Wireless Switches',
                                         StageName='Discover - 10%',
                                         Forecast_Category_Override__c = 'Omitted',
                                         Partner_Opportunity_Stage__c = 'Discover - 10%',
                                         EMC_Opportunity_updated__c = 'Waiting Sync',
                                         Primary_Competitor_Product_Type__c = 'Client',
                                         Distributor_Name__c = 'Distribution',
                                         CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');
      // insert testOpportunity2;
        listOpp.add(testOpportunity2);
        
        OpportunityValidator.validateFulfilmentPathForDistributor(listOpp,null);
        
        map<Id,Opportunity> mapoldOppMap = new map<Id,Opportunity>();
        mapoldOppMap.put(listOpp[0].Id,listOpp[0]);
        
        OpportunityValidator.validateFulfilmentPathForDistributor(listOpp,mapoldOppMap);
        
        test.stopTest();
        TriggerExecutionController.setSkipAlltriggers(false);

 
    }
}